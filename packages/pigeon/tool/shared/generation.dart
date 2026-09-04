// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show Directory, File, Platform, Process, ProcessResult;

import 'package:path/path.dart' as p;
import 'package:pigeon/pigeon.dart';
import 'package:pigeon/src/ast.dart';
import 'package:pigeon/src/generator_tools.dart';

import 'process_utils.dart';

enum GeneratorLanguage { cpp, dart, gobject, java, kotlin, objc, swift }

// A map of pigeons/ files to the languages that they can't yet be generated
// for due to limitations of that generator.
const Map<String, Set<GeneratorLanguage>> _unsupportedFiles = <String, Set<GeneratorLanguage>>{
  'event_channel_tests': <GeneratorLanguage>{
    GeneratorLanguage.cpp,
    GeneratorLanguage.gobject,
    GeneratorLanguage.java,
    GeneratorLanguage.objc,
  },
  'event_channel_without_classes_tests': <GeneratorLanguage>{
    GeneratorLanguage.cpp,
    GeneratorLanguage.gobject,
    GeneratorLanguage.java,
    GeneratorLanguage.objc,
  },
  'proxy_api_tests': <GeneratorLanguage>{
    GeneratorLanguage.cpp,
    GeneratorLanguage.gobject,
    GeneratorLanguage.java,
    GeneratorLanguage.objc,
  },
  'native_interop_tests': <GeneratorLanguage>{
    GeneratorLanguage.cpp,
    GeneratorLanguage.gobject,
    GeneratorLanguage.java,
    GeneratorLanguage.objc,
  },
};

String _snakeToPascalCase(String snake) {
  final List<String> parts = snake.split('_');
  return parts.map((String part) => part.substring(0, 1).toUpperCase() + part.substring(1)).join();
}

// Remaps some file names for Java output, since the filename on Java will be
// the name of the generated top-level class. In some cases this is necessary
// (e.g., "list", which collides with the Java List class in tests), and in
// others it is just preserving previous behavior from the earlier Bash version
// of the generation to minimize churn during the migration.
// TODO(stuartmorgan): Remove the need for this when addressing
// https://github.com/flutter/flutter/issues/115168.
String _javaFilenameForName(String inputName) {
  const specialCases = <String, String>{'message': 'MessagePigeon'};
  return specialCases[inputName] ?? _snakeToPascalCase(inputName);
}

bool _hasAndroidSdk() {
  final String? androidHome =
      Platform.environment['ANDROID_HOME'] ?? Platform.environment['ANDROID_SDK_ROOT'];
  return androidHome != null && androidHome.isNotEmpty && Directory(androidHome).existsSync();
}

Future<String?> _getJavaHome() async {
  final String? currentJavaHome = Platform.environment['JAVA_HOME'];
  if (currentJavaHome != null && currentJavaHome.isNotEmpty) {
    return currentJavaHome;
  }
  if (Platform.isMacOS) {
    try {
      final ProcessResult result = await Process.run('/usr/libexec/java_home', <String>[
        '-v',
        '17',
      ]);
      if (result.exitCode == 0) {
        final String javaHome = result.stdout.toString().trim();
        if (javaHome.isNotEmpty) {
          return javaHome;
        }
      }
    } catch (_) {}
  }
  return null;
}

Future<bool> _hasJavaRuntime([String? javaHome]) async {
  final Map<String, String>? env = javaHome != null && javaHome.isNotEmpty
      ? <String, String>{'JAVA_HOME': javaHome}
      : null;
  final String javaExecutable = javaHome != null && javaHome.isNotEmpty
      ? p.join(javaHome, 'bin', 'java')
      : 'java';
  try {
    final ProcessResult result = await Process.run(javaExecutable, <String>[
      '-version',
    ], environment: env);
    return result.exitCode == 0;
  } catch (_) {
    return false;
  }
}

Future<int> _compileNativeInteropExampleApp() async {
  if (!_hasAndroidSdk()) {
    return 0;
  }
  final String? javaHome = await _getJavaHome();
  if (!await _hasJavaRuntime(javaHome)) {
    return 0;
  }

  final environment = <String, String>{if (javaHome != null) 'JAVA_HOME': javaHome};

  const appDir = './example/native_interop_app';
  final String androidDir = p.join(appDir, 'android');
  if (!Directory(androidDir).existsSync()) {
    return 0;
  }

  final gradlew = Platform.isWindows ? 'gradlew.bat' : 'gradlew';
  final gradlewFile = File(p.join(androidDir, gradlew));
  if (!gradlewFile.existsSync()) {
    final flutterCommand = Platform.isWindows ? 'flutter.bat' : 'flutter';
    final int configExitCode = await runProcess(
      flutterCommand,
      <String>['build', 'apk', '--config-only'],
      workingDirectory: appDir,
      environment: environment,
      runInShell: Platform.isWindows,
      logFailure: true,
    );
    if (configExitCode != 0) {
      return configExitCode;
    }
  }

  if (!Platform.isWindows && gradlewFile.existsSync()) {
    try {
      await Process.run('chmod', <String>['+x', gradlewFile.path]);
    } catch (_) {}
  }

  final gradleCommand = Platform.isWindows ? r'.\gradlew.bat' : './gradlew';
  return runProcess(
    gradleCommand,
    <String>[':app:compileReleaseKotlin'],
    workingDirectory: androidDir,
    environment: environment,
    runInShell: Platform.isWindows,
    logFailure: true,
  );
}

Future<int> generateExamplePigeons() async {
  var success = 0;
  success = await runPigeon(
    input: './example/app/pigeons/messages.dart',
    basePath: './example/app',
    suppressVersion: true,
  );
  success += await runPigeon(
    input: './example/app/pigeons/event_channel_messages.dart',
    basePath: './example/app',
    suppressVersion: true,
  );

  final int compileResult = await _compileNativeInteropExampleApp();
  if (compileResult != 0) {
    return compileResult;
  }

  success += await runPigeon(
    input: './example/native_interop_app/pigeons/native_interop_example.dart',
    appDirectory: './example/native_interop_app',
    swiftAppDirectory: './example/native_interop_app',
    basePath: './example/native_interop_app',
    suppressVersion: true,
    dartOut: 'lib/src/native_interop_example.g.dart',
    kotlinOut:
        'android/app/src/main/kotlin/dev/flutter/pigeonnativeinteropapp/NativeInteropExample.g.kt',
    kotlinPackage: 'dev.flutter.pigeonnativeinteropapp',
    swiftOut: 'ios/Runner/NativeInteropExample.g.swift',
    copyrightHeader: 'pigeons/copyright.txt',
  );
  return success;
}

Future<int> generateTestPigeons({required String baseDir, bool includeOverflow = false}) async {
  // TODO(stuartmorgan): Make this dynamic rather than hard-coded. Or eliminate
  // it entirely; see https://github.com/flutter/flutter/issues/115169.
  const inputs = <String>{
    'core_tests',
    'enum',
    'event_channel_tests',
    'event_channel_without_classes_tests',
    'flutter_unittests', // Only for Dart unit tests in shared_test_plugin_code
    'message',
    'multiple_arity',
    'non_null_fields',
    'null_fields',
    'nullable_returns',
    'primitive',
    'proxy_api_tests',
    // native_interop_tests runs JNIgen which compiles test_plugin; all other
    // Kotlin files must be generated first.
    'native_interop_tests',
  };

  const testPluginName = 'test_plugin';
  const alternateTestPluginName = 'alternate_language_test_plugin';
  final String outputBase = p.join(baseDir, 'platform_tests', testPluginName);
  final String alternateOutputBase = p.join(baseDir, 'platform_tests', alternateTestPluginName);
  final String sharedDartOutputBase = p.join(baseDir, 'platform_tests', 'shared_test_plugin_code');

  for (final input in inputs) {
    final String pascalCaseName = _snakeToPascalCase(input);
    final Set<GeneratorLanguage> skipLanguages = _unsupportedFiles[input] ?? <GeneratorLanguage>{};

    final bool kotlinErrorClassGenerationTestFiles = input == 'core_tests' || input == 'primitive';

    final kotlinErrorName = kotlinErrorClassGenerationTestFiles
        ? 'FlutterError'
        : '${pascalCaseName}Error';

    final bool swiftErrorUseDefaultErrorName = input == 'core_tests' || input == 'primitive';

    final String? swiftErrorClassName = swiftErrorUseDefaultErrorName
        ? null
        : '${pascalCaseName}Error';

    // Generate the default language test plugin output.
    int generateCode = await runPigeon(
      input: './pigeons/$input.dart',
      appDirectory: '$outputBase/example/',
      dartOut: '$sharedDartOutputBase/lib/src/generated/$input.gen.dart',
      dartTestOut: input == 'message' ? '$sharedDartOutputBase/test/test_message.gen.dart' : null,
      dartPackageName: 'pigeon_integration_tests',
      suppressVersion: true,
      // Android
      kotlinOut: skipLanguages.contains(GeneratorLanguage.kotlin)
          ? null
          : '$outputBase/android/src/main/kotlin/com/example/test_plugin/$pascalCaseName.gen.kt',
      kotlinPackage: 'com.example.test_plugin',
      kotlinErrorClassName: kotlinErrorName,
      kotlinUseJni:
          !skipLanguages.contains(GeneratorLanguage.kotlin) && input == 'native_interop_tests',
      kotlinAppDirectory: '$outputBase/example',
      kotlinIncludeErrorClass: input != 'primitive',
      // iOS/macOS
      swiftOut: skipLanguages.contains(GeneratorLanguage.swift)
          ? null
          : '$outputBase/darwin/$testPluginName/Sources/$testPluginName/$pascalCaseName.gen.swift',
      swiftErrorClassName: swiftErrorClassName,
      swiftIncludeErrorClass: input != 'primitive',
      swiftUseFfi:
          !skipLanguages.contains(GeneratorLanguage.swift) && input == 'native_interop_tests',
      swiftAppDirectory: '$outputBase/example',
      // Linux
      gobjectHeaderOut: skipLanguages.contains(GeneratorLanguage.gobject)
          ? null
          : '$outputBase/linux/pigeon/$input.gen.h',
      gobjectSourceOut: skipLanguages.contains(GeneratorLanguage.gobject)
          ? null
          : '$outputBase/linux/pigeon/$input.gen.cc',
      gobjectModule: '${pascalCaseName}PigeonTest',
      // Windows
      cppHeaderOut: skipLanguages.contains(GeneratorLanguage.cpp)
          ? null
          : '$outputBase/windows/pigeon/$input.gen.h',
      cppSourceOut: skipLanguages.contains(GeneratorLanguage.cpp)
          ? null
          : '$outputBase/windows/pigeon/$input.gen.cpp',
      cppNamespace: '${input}_pigeontest',
      injectOverflowTypes: includeOverflow && input == 'core_tests',
    );
    if (generateCode != 0) {
      return generateCode;
    }

    // Generate the alternate language test plugin output.
    final objcBase =
        '$alternateOutputBase/darwin/$alternateTestPluginName/Sources/$alternateTestPluginName/';
    final objcBaseRelativeHeaderPath = 'include/$alternateTestPluginName/$pascalCaseName.gen.h';
    generateCode = await runPigeon(
      input: './pigeons/$input.dart',
      // Android
      // This doesn't use the '.gen' suffix since Java has strict file naming
      // rules.
      javaOut: skipLanguages.contains(GeneratorLanguage.java)
          ? null
          : '$alternateOutputBase/android/src/main/java/com/example/'
                'alternate_language_test_plugin/${_javaFilenameForName(input)}.java',
      javaPackage: 'com.example.alternate_language_test_plugin',
      // iOS/macOS
      objcHeaderOut: skipLanguages.contains(GeneratorLanguage.objc)
          ? null
          : '$objcBase/$objcBaseRelativeHeaderPath',
      objcSourceOut: skipLanguages.contains(GeneratorLanguage.objc)
          ? null
          : '$objcBase/$pascalCaseName.gen.m',
      objcHeaderIncludePath: './$objcBaseRelativeHeaderPath',
      objcPrefix: input == 'core_tests'
          ? 'FLT'
          : input == 'enum'
          ? 'PGN'
          : '',
      suppressVersion: true,
      dartPackageName: 'pigeon_integration_tests',
      injectOverflowTypes: includeOverflow && input == 'core_tests',
      mergeDefinitionFileOptions: input != 'enum',
    );
    if (generateCode != 0) {
      return generateCode;
    }
  }

  // Test case for useGeneratedAnnotation feature with core_tests
  final String corePascalCaseName = _snakeToPascalCase('core_tests');
  final int generateCodeWithAnnotation = await runPigeon(
    input: './pigeons/core_tests.dart',
    kotlinOut:
        '$outputBase/android/src/main/kotlin/com/example/test_plugin/annotation/${corePascalCaseName}WithAnnotation.gen.kt',
    kotlinPackage: 'com.example.test_plugin.annotation',
    kotlinErrorClassName: 'FlutterError',
    kotlinUseGeneratedAnnotation: true,
  );
  if (generateCodeWithAnnotation != 0) {
    return generateCodeWithAnnotation;
  }

  return 0;
}

Future<int> runPigeon({
  required String input,
  String? appDirectory,
  String? kotlinOut,
  String? kotlinPackage,
  String? kotlinErrorClassName,
  bool kotlinUseJni = false,
  bool kotlinIncludeErrorClass = true,
  String kotlinAppDirectory = '',
  bool kotlinUseGeneratedAnnotation = false,
  bool swiftIncludeErrorClass = true,
  String? swiftOut,
  String? swiftErrorClassName,
  bool swiftUseFfi = false,
  String swiftAppDirectory = '',
  String? cppHeaderOut,
  String? cppSourceOut,
  String? cppNamespace,
  String? dartOut,
  String? dartTestOut,
  String? gobjectHeaderOut,
  String? gobjectSourceOut,
  String? gobjectModule,
  String? javaOut,
  String? javaPackage,
  String? objcHeaderOut,
  String? objcSourceOut,
  String objcPrefix = '',
  String? objcHeaderIncludePath,
  bool suppressVersion = false,
  String copyrightHeader = './copyright_header.txt',
  String? basePath,
  String? dartPackageName,
  bool injectOverflowTypes = false,
  bool mergeDefinitionFileOptions = true,
}) async {
  // Temporarily suppress the version output via the global flag if requested.
  // This is done because having the version in all the generated test output
  // means every version bump updates every test file, which is problematic in
  // review. For files where CI validates that this generation is up to date,
  // having the version in these files isn't useful.
  // TODO(stuartmorgan): Remove the option and do this unconditionally once
  // all the checked in files are being validated; currently only
  // generatePigeons is being checked in CI.
  final bool originalWarningSetting = includeVersionInGeneratedWarning;
  if (suppressVersion) {
    includeVersionInGeneratedWarning = false;
  }

  // parse results in advance when overflow is included to avoid exposing as public option
  final ParseResults parseResults = Pigeon().parseFile(input);
  if (injectOverflowTypes) {
    final addedEnums = List<Enum>.generate(totalCustomCodecKeysAllowed - 1, (int tag) {
      return Enum(
        name: 'FillerEnum$tag',
        members: <EnumMember>[EnumMember(name: 'FillerMember$tag')],
      );
    });
    addedEnums.addAll(parseResults.root.enums);
    parseResults.root.enums = addedEnums;
  }

  final int result = await Pigeon.runWithOptions(
    PigeonOptions(
      input: input,
      appDirectory: appDirectory,
      copyrightHeader: copyrightHeader,
      dartOut: dartOut,
      dartTestOut: dartTestOut,
      dartOptions: const DartOptions(ignoreLints: false),
      cppHeaderOut: cppHeaderOut,
      cppSourceOut: cppSourceOut,
      cppOptions: CppOptions(namespace: cppNamespace),
      gobjectHeaderOut: injectOverflowTypes ? null : gobjectHeaderOut,
      gobjectSourceOut: injectOverflowTypes ? null : gobjectSourceOut,
      gobjectOptions: injectOverflowTypes ? null : GObjectOptions(module: gobjectModule),
      javaOut: javaOut,
      javaOptions: JavaOptions(package: javaPackage),
      kotlinOut: kotlinOut,
      kotlinOptions: KotlinOptions(
        package: kotlinPackage,
        errorClassName: kotlinErrorClassName,
        includeErrorClass: kotlinIncludeErrorClass,
        useJni: kotlinUseJni,
        useGeneratedAnnotation: kotlinUseGeneratedAnnotation,
        appDirectory: kotlinAppDirectory.isNotEmpty ? kotlinAppDirectory : null,
        configDirectory: kotlinAppDirectory.isNotEmpty ? kotlinAppDirectory : null,
      ),
      objcHeaderOut: objcHeaderOut,
      objcSourceOut: objcSourceOut,
      objcOptions: ObjcOptions(prefix: objcPrefix, headerIncludePath: objcHeaderIncludePath),
      swiftOut: swiftOut,
      swiftOptions: SwiftOptions(
        errorClassName: swiftErrorClassName,
        includeErrorClass: swiftIncludeErrorClass,
        useFfi: swiftUseFfi,
        appDirectory: swiftAppDirectory.isNotEmpty ? swiftAppDirectory : null,
        configDirectory: swiftAppDirectory.isNotEmpty ? swiftAppDirectory : null,
      ),
      basePath: basePath,
      dartPackageName: dartPackageName,
    ),
    // ignore: invalid_use_of_visible_for_testing_member
    parseResults: injectOverflowTypes ? parseResults : null,
    mergeDefinitionFileOptions: mergeDefinitionFileOptions,
  );
  includeVersionInGeneratedWarning = originalWarningSetting;
  return result;
}

/// Runs the repository tooling's format command on this package.
///
/// This is intended for formatting generated output, but since there's no
/// way to filter to specific files in with the repo tooling it runs over the
/// entire package.
Future<int> formatAllFiles({
  required String repositoryRoot,
  Set<GeneratorLanguage> languages = const <GeneratorLanguage>{
    GeneratorLanguage.cpp,
    GeneratorLanguage.dart,
    GeneratorLanguage.gobject,
    GeneratorLanguage.java,
    GeneratorLanguage.kotlin,
    GeneratorLanguage.objc,
    GeneratorLanguage.swift,
  },
}) async {
  final dartCommand = Platform.isWindows ? 'dart.exe' : 'dart';
  final String? xcodeClangFormat = await _findXcodeClangFormat();
  final useXcodeClangFormat = xcodeClangFormat != null;
  final args = <String>[
    'run',
    'script/tool/bin/flutter_plugin_tools.dart',
    'format',
    '--packages=pigeon',
    if (languages.contains(GeneratorLanguage.cpp) ||
        languages.contains(GeneratorLanguage.gobject) ||
        languages.contains(GeneratorLanguage.objc)) ...<String>[
      '--clang-format',
      if (useXcodeClangFormat) '--clang-format-path=$xcodeClangFormat',
    ] else
      '--no-clang-format',
    if (languages.contains(GeneratorLanguage.java)) '--java' else '--no-java',
    if (languages.contains(GeneratorLanguage.dart)) '--dart' else '--no-dart',
    if (languages.contains(GeneratorLanguage.kotlin)) '--kotlin' else '--no-kotlin',
    if (languages.contains(GeneratorLanguage.swift)) '--swift' else '--no-swift',
  ];

  int exitCode = await runProcess(
    dartCommand,
    args,
    workingDirectory: repositoryRoot,
    logFailure: true,
  );
  if (exitCode != 0) {
    return exitCode;
  }

  // Run a second time if formatting Objective-C files, because clang-format
  // requires two passes to reach a stable state for Swift-generated ObjC headers
  // due to complex macro wrapping.
  if (languages.contains(GeneratorLanguage.objc)) {
    exitCode = await runProcess(
      dartCommand,
      args,
      workingDirectory: repositoryRoot,
      logFailure: true,
    );
  }
  return exitCode;
}

Future<String?> _findXcodeClangFormat() async {
  if (!Platform.isMacOS) {
    return null;
  }
  try {
    final ProcessResult result = await Process.run('xcrun', <String>['-f', 'clang-format']);
    if (result.exitCode == 0) {
      final String path = result.stdout.toString().trim();
      if (path.isNotEmpty && File(path).existsSync()) {
        return path;
      }
    }
  } catch (_) {
    // Ignore errors and fall back.
  }
  return null;
}
