// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/core.dart';
import 'package:flutter_plugin_tools/src/common/file_utils.dart';
import 'package:flutter_plugin_tools/src/common/plugin_utils.dart';
import 'package:flutter_plugin_tools/src/common/process_runner.dart';
import 'package:flutter_plugin_tools/src/common/repository_package.dart';
import 'package:git/git.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';
import 'package:quiver/collection.dart';

import 'mocks.dart';

export 'package:flutter_plugin_tools/src/common/repository_package.dart';

const String _defaultDartConstraint = '>=2.14.0 <4.0.0';
const String _defaultFlutterConstraint = '>=2.5.0';

/// Returns the exe name that command will use when running Flutter on
/// [platform].
String getFlutterCommand(Platform platform) =>
    platform.isWindows ? 'flutter.bat' : 'flutter';

/// Creates a packages directory at an arbitrary location in the given
/// filesystem.
Directory createPackagesDirectory(FileSystem fileSystem) {
  final Directory packagesDir =
      fileSystem.currentDirectory.childDirectory('packages');
  packagesDir.createSync();
  return packagesDir;
}

/// Details for platform support in a plugin.
@immutable
class PlatformDetails {
  const PlatformDetails(
    this.type, {
    this.hasNativeCode = true,
    this.hasDartCode = false,
  });

  /// The type of support for the platform.
  final PlatformSupport type;

  /// Whether or not the plugin includes native code.
  ///
  /// Ignored for web, which does not have native code.
  final bool hasNativeCode;

  /// Whether or not the plugin includes Dart code.
  ///
  /// Ignored for web, which always has native code.
  final bool hasDartCode;
}

/// Returns the 'example' directory for [package].
///
/// This is deliberately not a method on [RepositoryPackage] since actual tool
/// code should essentially never need this, and instead be using
/// [RepositoryPackage.getExamples] to avoid assuming there's a single example
/// directory. However, needing to construct paths with the example directory
/// is very common in test code.
///
/// This returns a Directory rather than a RepositoryPackage because there is no
/// guarantee that the returned directory is a package.
Directory getExampleDir(RepositoryPackage package) {
  return package.directory.childDirectory('example');
}

/// Creates a plugin package with the given [name] in [packagesDirectory].
///
/// [platformSupport] is a map of platform string to the support details for
/// that platform.
///
/// [extraFiles] is an optional list of plugin-relative paths, using Posix
/// separators, of extra files to create in the plugin.
RepositoryPackage createFakePlugin(
  String name,
  Directory parentDirectory, {
  List<String> examples = const <String>['example'],
  List<String> extraFiles = const <String>[],
  Map<String, PlatformDetails> platformSupport =
      const <String, PlatformDetails>{},
  String? version = '0.0.1',
  String flutterConstraint = _defaultFlutterConstraint,
  String dartConstraint = _defaultDartConstraint,
}) {
  final RepositoryPackage package = createFakePackage(
    name,
    parentDirectory,
    isFlutter: true,
    examples: examples,
    extraFiles: extraFiles,
    version: version,
    flutterConstraint: flutterConstraint,
    dartConstraint: dartConstraint,
  );

  createFakePubspec(
    package,
    name: name,
    isPlugin: true,
    platformSupport: platformSupport,
    version: version,
    flutterConstraint: flutterConstraint,
    dartConstraint: dartConstraint,
  );

  return package;
}

/// Creates a plugin package with the given [name] in [packagesDirectory].
///
/// [extraFiles] is an optional list of package-relative paths, using unix-style
/// separators, of extra files to create in the package.
///
/// If [includeCommonFiles] is true, common but non-critical files like
/// CHANGELOG.md, README.md, and AUTHORS will be included.
///
/// If non-null, [directoryName] will be used for the directory instead of
/// [name].
RepositoryPackage createFakePackage(
  String name,
  Directory parentDirectory, {
  List<String> examples = const <String>['example'],
  List<String> extraFiles = const <String>[],
  bool isFlutter = false,
  String? version = '0.0.1',
  String flutterConstraint = _defaultFlutterConstraint,
  String dartConstraint = _defaultDartConstraint,
  bool includeCommonFiles = true,
  String? directoryName,
  String? publishTo,
}) {
  final RepositoryPackage package =
      RepositoryPackage(parentDirectory.childDirectory(directoryName ?? name));
  package.directory.createSync(recursive: true);

  package.libDirectory.createSync();
  createFakePubspec(package,
      name: name,
      isFlutter: isFlutter,
      version: version,
      flutterConstraint: flutterConstraint,
      dartConstraint: dartConstraint,
      publishTo: publishTo);
  if (includeCommonFiles) {
    package.changelogFile.writeAsStringSync('''
## $version
  * Some changes.
  ''');
    package.readmeFile.writeAsStringSync('A very useful package');
    package.authorsFile.writeAsStringSync('Google Inc.');
  }

  if (examples.length == 1) {
    createFakePackage('${name}_example', package.directory,
        directoryName: examples.first,
        examples: <String>[],
        includeCommonFiles: false,
        isFlutter: isFlutter,
        publishTo: 'none',
        flutterConstraint: flutterConstraint,
        dartConstraint: dartConstraint);
  } else if (examples.isNotEmpty) {
    final Directory examplesDirectory = getExampleDir(package)..createSync();
    for (final String exampleName in examples) {
      createFakePackage(exampleName, examplesDirectory,
          examples: <String>[],
          includeCommonFiles: false,
          isFlutter: isFlutter,
          publishTo: 'none',
          flutterConstraint: flutterConstraint,
          dartConstraint: dartConstraint);
    }
  }

  final p.Context posixContext = p.posix;
  for (final String file in extraFiles) {
    childFileWithSubcomponents(package.directory, posixContext.split(file))
        .createSync(recursive: true);
  }

  return package;
}

/// Creates a `pubspec.yaml` file for [package].
///
/// [platformSupport] is a map of platform string to the support details for
/// that platform. If empty, no `plugin` entry will be created unless `isPlugin`
/// is set to `true`.
void createFakePubspec(
  RepositoryPackage package, {
  String name = 'fake_package',
  bool isFlutter = true,
  bool isPlugin = false,
  Map<String, PlatformDetails> platformSupport =
      const <String, PlatformDetails>{},
  String? publishTo,
  String? version,
  String dartConstraint = _defaultDartConstraint,
  String flutterConstraint = _defaultFlutterConstraint,
}) {
  isPlugin |= platformSupport.isNotEmpty;

  String environmentSection = '''
environment:
  sdk: "$dartConstraint"
''';
  String dependenciesSection = '''
dependencies:
''';
  String pluginSection = '';

  // Add Flutter-specific entries if requested.
  if (isFlutter) {
    environmentSection += '''
  flutter: "$flutterConstraint"
''';
    dependenciesSection += '''
  flutter:
    sdk: flutter
''';

    if (isPlugin) {
      pluginSection += '''
flutter:
  plugin:
    platforms:
''';
      for (final MapEntry<String, PlatformDetails> platform
          in platformSupport.entries) {
        pluginSection +=
            _pluginPlatformSection(platform.key, platform.value, name);
      }
    }
  }

  // Default to a fake server to avoid ever accidentally publishing something
  // from a test. Does not use 'none' since that changes the behavior of some
  // commands.
  final String publishToSection =
      'publish_to: ${publishTo ?? 'http://no_pub_server.com'}';

  final String yaml = '''
name: $name
${(version != null) ? 'version: $version' : ''}
$publishToSection

$environmentSection

$dependenciesSection

$pluginSection
''';

  package.pubspecFile.createSync();
  package.pubspecFile.writeAsStringSync(yaml);
}

String _pluginPlatformSection(
    String platform, PlatformDetails support, String packageName) {
  String entry = '';
  // Build the main plugin entry.
  if (support.type == PlatformSupport.federated) {
    entry = '''
      $platform:
        default_package: ${packageName}_$platform
''';
  } else {
    final List<String> lines = <String>[
      '      $platform:',
    ];
    switch (platform) {
      case platformAndroid:
        lines.add('        package: io.flutter.plugins.fake');
        continue nativeByDefault;
      nativeByDefault:
      case platformIOS:
      case platformLinux:
      case platformMacOS:
      case platformWindows:
        if (support.hasNativeCode) {
          final String className =
              platform == platformIOS ? 'FLTFakePlugin' : 'FakePlugin';
          lines.add('        pluginClass: $className');
        }
        if (support.hasDartCode) {
          lines.add('        dartPluginClass: FakeDartPlugin');
        }
      case platformWeb:
        lines.addAll(<String>[
          '        pluginClass: FakePlugin',
          '        fileName: ${packageName}_web.dart',
        ]);
      default:
        assert(false, 'Unrecognized platform: $platform');
    }
    entry = '${lines.join('\n')}\n';
  }

  return entry;
}

/// Run the command [runner] with the given [args] and return
/// what was printed.
/// A custom [errorHandler] can be used to handle the runner error as desired without throwing.
Future<List<String>> runCapturingPrint(
  CommandRunner<void> runner,
  List<String> args, {
  void Function(Error error)? errorHandler,
  void Function(Exception error)? exceptionHandler,
}) async {
  final List<String> prints = <String>[];
  final ZoneSpecification spec = ZoneSpecification(
    print: (_, __, ___, String message) {
      prints.add(message);
    },
  );
  try {
    await Zone.current
        .fork(specification: spec)
        .run<Future<void>>(() => runner.run(args));
  } on Error catch (e) {
    if (errorHandler == null) {
      rethrow;
    }
    errorHandler(e);
  } on Exception catch (e) {
    if (exceptionHandler == null) {
      rethrow;
    }
    exceptionHandler(e);
  }

  return prints;
}

/// Information about a process to return from [RecordingProcessRunner].
class FakeProcessInfo {
  const FakeProcessInfo(this.process,
      [this.expectedInitialArgs = const <String>[], this.runCallback]);

  /// The process to return.
  final io.Process process;

  /// The expected start of the argument array for the call.
  ///
  /// This does not have to be a full list of arguments, only enough of the
  /// start to ensure that the call is as expected.
  final List<String> expectedInitialArgs;

  /// If present, a function to call when the process would be run.
  ///
  /// This can be used to validate state at specific points in a command run,
  /// such as temporary file modifications.
  final void Function()? runCallback;
}

/// A mock [ProcessRunner] which records process calls.
class RecordingProcessRunner extends ProcessRunner {
  final List<ProcessCall> recordedCalls = <ProcessCall>[];

  /// Maps an executable to a list of processes that should be used for each
  /// successive call to it via [run], [runAndStream], or [start].
  ///
  /// If `expectedInitialArgs` are provided for a fake process, trying to
  /// return that process when the arguments don't match will throw a
  /// [StateError]. This allows tests to enforce that the fake results are
  /// for the expected calls when the process name itself isn't enough to tell
  /// (e.g., multiple different `dart` or `flutter` calls), without going all
  /// the way to a complex argument matching scheme that can make tests
  /// difficult to write and debug.
  final Map<String, List<FakeProcessInfo>> mockProcessesForExecutable =
      <String, List<FakeProcessInfo>>{};

  @override
  Future<int> runAndStream(
    String executable,
    List<String> args, {
    Directory? workingDir,
    Map<String, String>? environment,
    bool exitOnError = false,
  }) async {
    recordedCalls.add(ProcessCall(executable, args, workingDir?.path));
    final io.Process? processToReturn = _runFakeProcess(executable, args);
    final int exitCode =
        processToReturn == null ? 0 : await processToReturn.exitCode;
    if (exitOnError && (exitCode != 0)) {
      throw io.ProcessException(executable, args);
    }
    return Future<int>.value(exitCode);
  }

  /// Returns [io.ProcessResult] created from [mockProcessesForExecutable].
  @override
  Future<io.ProcessResult> run(
    String executable,
    List<String> args, {
    Directory? workingDir,
    Map<String, String>? environment,
    bool exitOnError = false,
    bool logOnError = false,
    Encoding stdoutEncoding = io.systemEncoding,
    Encoding stderrEncoding = io.systemEncoding,
  }) async {
    recordedCalls.add(ProcessCall(executable, args, workingDir?.path));

    final io.Process? process = _runFakeProcess(executable, args);
    final List<String>? processStdout =
        await process?.stdout.transform(stdoutEncoding.decoder).toList();
    final String stdout = processStdout?.join() ?? '';
    final List<String>? processStderr =
        await process?.stderr.transform(stderrEncoding.decoder).toList();
    final String stderr = processStderr?.join() ?? '';

    final io.ProcessResult result = process == null
        ? io.ProcessResult(1, 0, '', '')
        : io.ProcessResult(process.pid, await process.exitCode, stdout, stderr);

    if (exitOnError && (result.exitCode != 0)) {
      throw io.ProcessException(executable, args);
    }

    return Future<io.ProcessResult>.value(result);
  }

  @override
  Future<io.Process> start(String executable, List<String> args,
      {Directory? workingDirectory}) async {
    recordedCalls.add(ProcessCall(executable, args, workingDirectory?.path));
    return Future<io.Process>.value(
        _runFakeProcess(executable, args) ?? MockProcess());
  }

  /// Returns the fake process for the given executable and args after running
  /// any callback it provides.
  io.Process? _runFakeProcess(String executable, List<String> args) {
    final List<FakeProcessInfo> fakes =
        mockProcessesForExecutable[executable] ?? <FakeProcessInfo>[];
    if (fakes.isNotEmpty) {
      final FakeProcessInfo fake = fakes.removeAt(0);
      if (args.length < fake.expectedInitialArgs.length ||
          !listsEqual(args.sublist(0, fake.expectedInitialArgs.length),
              fake.expectedInitialArgs)) {
        throw StateError('Next fake process for $executable expects arguments '
            '[${fake.expectedInitialArgs.join(', ')}] but was called with '
            'arguments [${args.join(', ')}]');
      }
      fake.runCallback?.call();
      return fake.process;
    }
    return null;
  }
}

/// A recorded process call.
@immutable
class ProcessCall {
  const ProcessCall(this.executable, this.args, this.workingDir);

  /// The executable that was called.
  final String executable;

  /// The arguments passed to [executable] in the call.
  final List<String> args;

  /// The working directory this process was called from.
  final String? workingDir;

  @override
  bool operator ==(Object other) {
    return other is ProcessCall &&
        executable == other.executable &&
        listsEqual(args, other.args) &&
        workingDir == other.workingDir;
  }

  @override
  int get hashCode => Object.hash(executable, args, workingDir);

  @override
  String toString() {
    final List<String> command = <String>[executable, ...args];
    return '"${command.join(' ')}" in $workingDir';
  }
}

/// Sets up standard mocking common to most command unit test setUp methods,
/// including a packages directory in an in-memory filesystem, and a mock
/// process handling (including git commands sent by GitDir).
///
/// The returned GitDir instance forwards to a mock process runner, as described
/// in [createForwardingMockGitDir]. This process runner is separate, so that
/// tests can easily treat most git commands called as internal implementation
/// details, and assert on the exact list of non-git commands that are run.
({
  Directory packagesDir,
  RecordingProcessRunner processRunner,
  RecordingProcessRunner gitProcessRunner,
  GitDir gitDir,
}) configureBaseCommandMocks({
  Platform? platform,
  RecordingProcessRunner? customProcessRunner,
  RecordingProcessRunner? customGitProcessRunner,
}) {
  final FileSystem fileSystem = MemoryFileSystem(
      style: (platform?.isWindows ?? false)
          ? FileSystemStyle.windows
          : FileSystemStyle.posix);
  final Directory packagesDir = createPackagesDirectory(fileSystem);

  final RecordingProcessRunner processRunner =
      customProcessRunner ?? RecordingProcessRunner();

  final RecordingProcessRunner gitProcessRunner =
      customGitProcessRunner ?? RecordingProcessRunner();
  final GitDir gitDir = createForwardingMockGitDir(
    packagesDir: packagesDir,
    processRunner: gitProcessRunner,
  );

  return (
    packagesDir: packagesDir,
    processRunner: processRunner,
    gitProcessRunner: gitProcessRunner,
    gitDir: gitDir,
  );
}
