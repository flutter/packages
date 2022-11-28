// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:path/path.dart' as p;

import 'process_utils.dart';

enum GeneratorLanguages {
  cpp,
  java,
  kotlin,
  objc,
  swift,
}

// A map of pigeons/ files to the languages that they can't yet be generated
// for due to limitations of that generator.
const Map<String, Set<GeneratorLanguages>> _unsupportedFiles =
    <String, Set<GeneratorLanguages>>{
  'enum_args': <GeneratorLanguages>{GeneratorLanguages.cpp},
};

String _snakeToPascalCase(String snake) {
  final List<String> parts = snake.split('_');
  return parts
      .map((String part) =>
          part.substring(0, 1).toUpperCase() + part.substring(1))
      .join();
}

// Remaps some file names for Java output, since the filename on Java will be
// the name of the generated top-level class. In some cases this is necessary
// (e.g., "list", which collides with the Java List class in tests), and in
// others it is just preserving previous behavior from the earlier Bash version
// of the generation to minimize churn during the migration.
// TODO(stuartmorgan): Remove the need for this when addressing
// https://github.com/flutter/flutter/issues/115168.
String _javaFilenameForName(String inputName) {
  const Map<String, String> specialCases = <String, String>{
    'android_unittests': 'Pigeon',
    'host2flutter': 'Host2Flutter',
    'list': 'PigeonList',
    'message': 'MessagePigeon',
    'voidflutter': 'VoidFlutter',
    'voidhost': 'VoidHost',
  };
  return specialCases[inputName] ?? _snakeToPascalCase(inputName);
}

Future<int> generatePigeons({required String baseDir}) async {
  // TODO(stuartmorgan): Make this dynamic rather than hard-coded. Or eliminate
  // it entirely; see https://github.com/flutter/flutter/issues/115169.
  const List<String> inputs = <String>[
    'all_datatypes',
    'all_void',
    'android_unittests',
    'async_handlers',
    'background_platform_channels',
    'enum_args',
    'enum',
    'host2flutter',
    'java_double_host_api',
    'list',
    'message',
    'multiple_arity',
    'non_null_fields',
    'null_fields',
    'nullable_returns',
    'primitive',
    'void_arg_flutter',
    'void_arg_host',
    'voidflutter',
    'voidhost',
  ];

  final String outputBase = p.join(baseDir, 'platform_tests', 'test_plugin');
  final String alternateOutputBase =
      p.join(baseDir, 'platform_tests', 'alternate_language_test_plugin');
  // TODO(stuartmorgan): Eliminate this and use alternateOutputBase.
  // See https://github.com/flutter/packages/pull/2816.
  final String iosObjCBase =
      p.join(baseDir, 'platform_tests', 'ios_unit_tests');

  for (final String input in inputs) {
    final String pascalCaseName = _snakeToPascalCase(input);
    final Set<GeneratorLanguages> skipLanguages =
        _unsupportedFiles[input] ?? <GeneratorLanguages>{};

    // Generate the default language test plugin output.
    int generateCode = await runPigeon(
      input: './pigeons/$input.dart',
      dartOut: '$outputBase/lib/$input.gen.dart',
      // Android
      kotlinOut: skipLanguages.contains(GeneratorLanguages.kotlin)
          ? null
          : '$outputBase/android/src/main/kotlin/com/example/test_plugin/$pascalCaseName.gen.kt',
      kotlinPackage: 'com.example.test_plugin',
      // iOS
      swiftOut: skipLanguages.contains(GeneratorLanguages.swift)
          ? null
          : '$outputBase/ios/Classes/$pascalCaseName.gen.swift',
      // Windows
      cppHeaderOut: skipLanguages.contains(GeneratorLanguages.cpp)
          ? null
          : '$outputBase/windows/pigeon/$input.gen.h',
      cppSourceOut: skipLanguages.contains(GeneratorLanguages.cpp)
          ? null
          : '$outputBase/windows/pigeon/$input.gen.cpp',
      cppNamespace: '${input}_pigeontest',
    );
    if (generateCode != 0) {
      return generateCode;
    }

    // macOS has to be run as a separate generation, since currently Pigeon
    // doesn't have a way to output separate macOS and iOS Swift output in a
    // single invocation.
    generateCode = await runPigeon(
      input: './pigeons/$input.dart',
      swiftOut: skipLanguages.contains(GeneratorLanguages.swift)
          ? null
          : '$outputBase/macos/Classes/$pascalCaseName.gen.swift',
    );
    if (generateCode != 0) {
      return generateCode;
    }

    // Generate the alternate language test plugin output.
    generateCode = await runPigeon(
      input: './pigeons/$input.dart',
      dartOut: '$alternateOutputBase/lib/$input.gen.dart',
      // Android
      // This doesn't use the '.gen' suffix since Java has strict file naming
      // rules.
      javaOut: skipLanguages.contains(GeneratorLanguages.java)
          ? null
          : '$alternateOutputBase/android/src/main/java/com/example/'
              'alternate_language_test_plugin/${_javaFilenameForName(input)}.java',
      javaPackage: 'com.example.alternate_language_test_plugin',
      // iOS
      objcHeaderOut: skipLanguages.contains(GeneratorLanguages.objc)
          ? null
          : '$iosObjCBase/ios/Runner/$pascalCaseName.gen.h',
      objcSourceOut: skipLanguages.contains(GeneratorLanguages.objc)
          ? null
          : '$iosObjCBase/ios/Runner/$pascalCaseName.gen.m',
    );
    if (generateCode != 0) {
      return generateCode;
    }
  }
  return 0;
}

Future<int> runPigeon({
  required String input,
  String? kotlinOut,
  String? kotlinPackage,
  String? swiftOut,
  String? cppHeaderOut,
  String? cppSourceOut,
  String? cppNamespace,
  String? dartOut,
  String? dartTestOut,
  String? javaOut,
  String? javaPackage,
  String? objcHeaderOut,
  String? objcSourceOut,
  bool streamOutput = true,
}) async {
  const bool hasDart = false;
  final List<String> args = <String>[
    'run',
    'pigeon',
    '--input',
    input,
    '--copyright_header',
    './copyright_header.txt',
  ];
  if (kotlinOut != null) {
    args.addAll(<String>['--experimental_kotlin_out', kotlinOut]);
  }
  if (kotlinPackage != null) {
    args.addAll(<String>['--experimental_kotlin_package', kotlinPackage]);
  }
  if (swiftOut != null) {
    args.addAll(<String>['--experimental_swift_out', swiftOut]);
  }
  if (cppHeaderOut != null) {
    args.addAll(<String>[
      '--experimental_cpp_header_out',
      cppHeaderOut,
    ]);
  }
  if (cppSourceOut != null) {
    args.addAll(<String>[
      '--experimental_cpp_source_out',
      cppSourceOut,
    ]);
  }
  if (cppNamespace != null) {
    args.addAll(<String>[
      '--cpp_namespace',
      cppNamespace,
    ]);
  }
  if (dartOut != null) {
    args.addAll(<String>['--dart_out', dartOut]);
  }
  if (dartTestOut != null) {
    args.addAll(<String>['--dart_test_out', dartTestOut]);
  }
  if (!hasDart) {
    args.add('--one_language');
  }
  if (javaOut != null) {
    args.addAll(<String>['--java_out', javaOut]);
  }
  if (javaPackage != null) {
    args.addAll(<String>['--java_package', javaPackage]);
  }
  if (objcHeaderOut != null) {
    args.addAll(<String>['--objc_header_out', objcHeaderOut]);
  }
  if (objcSourceOut != null) {
    args.addAll(<String>['--objc_source_out', objcSourceOut]);
  }
  return runProcess('dart', args,
      streamOutput: streamOutput, logFailure: !streamOutput);
}
