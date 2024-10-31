// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';

import 'package:file/file.dart';
import 'package:meta/meta.dart';

import 'common/cmake.dart';
import 'common/core.dart';
import 'common/gradle.dart';
import 'common/output_utils.dart';
import 'common/package_looping_command.dart';
import 'common/plugin_utils.dart';
import 'common/repository_package.dart';
import 'common/xcode.dart';

const String _unitTestFlag = 'unit';
const String _integrationTestFlag = 'integration';

const String _iOSDestinationFlag = 'ios-destination';

const int _exitNoIOSSimulators = 3;

/// The error message logged when a FlutterTestRunner test is not annotated with
/// @DartIntegrationTest.
@visibleForTesting
const String misconfiguredJavaIntegrationTestErrorExplanation =
    'The following files use @RunWith(FlutterTestRunner.class) '
    'but not @DartIntegrationTest, which will cause hangs when run with '
    'this command. See '
    'https://github.com/flutter/flutter/blob/master/docs/ecosystem/testing/Plugin-Tests.md#enabling-android-ui-tests '
    'for instructions.';

/// The command to run native tests for plugins:
/// - iOS and macOS: XCTests (XCUnitTest and XCUITest)
/// - Android: JUnit tests
/// - Windows and Linux: GoogleTest tests
class NativeTestCommand extends PackageLoopingCommand {
  /// Creates an instance of the test command.
  NativeTestCommand(
    super.packagesDir, {
    super.processRunner,
    super.platform,
    Abi? abi,
  })  : _abi = abi ?? Abi.current(),
        _xcode = Xcode(processRunner: processRunner, log: true) {
    argParser.addOption(
      _iOSDestinationFlag,
      help: 'Specify the destination when running iOS tests.\n'
          'This is passed to the `-destination` argument in the xcodebuild command.\n'
          'See https://developer.apple.com/library/archive/technotes/tn2339/_index.html#//apple_ref/doc/uid/DTS40014588-CH1-UNIT '
          'for details on how to specify the destination.',
    );
    argParser.addFlag(platformAndroid, help: 'Runs Android tests');
    argParser.addFlag(platformIOS, help: 'Runs iOS tests');
    argParser.addFlag(platformLinux, help: 'Runs Linux tests');
    argParser.addFlag(platformMacOS, help: 'Runs macOS tests');
    argParser.addFlag(platformWindows, help: 'Runs Windows tests');

    // By default, both unit tests and integration tests are run, but provide
    // flags to disable one or the other.
    argParser.addFlag(_unitTestFlag,
        help: 'Runs native unit tests', defaultsTo: true);
    argParser.addFlag(_integrationTestFlag,
        help: 'Runs native integration (UI) tests', defaultsTo: true);
  }

  // The ABI of the host.
  final Abi _abi;

  // The device destination flags for iOS tests.
  List<String> _iOSDestinationFlags = <String>[];

  final Xcode _xcode;

  @override
  final String name = 'native-test';

  @override
  List<String> get aliases => <String>['test-native'];

  @override
  final String description = '''
Runs native unit tests and native integration tests.

Currently supported platforms:
- Android
- iOS: requires 'xcrun' to be in your path.
- Linux (unit tests only)
- macOS: requires 'xcrun' to be in your path.
- Windows (unit tests only)

The example app(s) must be built for all targeted platforms before running
this command.
''';

  Map<String, _PlatformDetails> _platforms = <String, _PlatformDetails>{};

  List<String> _requestedPlatforms = <String>[];

  @override
  Future<void> initializeRun() async {
    _platforms = <String, _PlatformDetails>{
      platformAndroid: _PlatformDetails('Android', _testAndroid),
      platformIOS: _PlatformDetails('iOS', _testIOS),
      platformLinux: _PlatformDetails('Linux', _testLinux),
      platformMacOS: _PlatformDetails('macOS', _testMacOS),
      platformWindows: _PlatformDetails('Windows', _testWindows),
    };
    _requestedPlatforms = _platforms.keys
        .where((String platform) => getBoolArg(platform))
        .toList();
    _requestedPlatforms.sort();

    if (_requestedPlatforms.isEmpty) {
      printError('At least one platform flag must be provided.');
      throw ToolExit(exitInvalidArguments);
    }

    if (!(getBoolArg(_unitTestFlag) || getBoolArg(_integrationTestFlag))) {
      printError('At least one test type must be enabled.');
      throw ToolExit(exitInvalidArguments);
    }

    if (getBoolArg(platformWindows) && getBoolArg(_integrationTestFlag)) {
      logWarning('This command currently only supports unit tests for Windows. '
          'See https://github.com/flutter/flutter/issues/70233.');
    }

    if (getBoolArg(platformLinux) && getBoolArg(_integrationTestFlag)) {
      logWarning('This command currently only supports unit tests for Linux. '
          'See https://github.com/flutter/flutter/issues/70235.');
    }

    // iOS-specific run-level state.
    if (_requestedPlatforms.contains('ios')) {
      String destination = getStringArg(_iOSDestinationFlag);
      if (destination.isEmpty) {
        final String? simulatorId =
            await _xcode.findBestAvailableIphoneSimulator();
        if (simulatorId == null) {
          printError('Cannot find any available iOS simulators.');
          throw ToolExit(_exitNoIOSSimulators);
        }
        destination = 'id=$simulatorId';
      }
      _iOSDestinationFlags = <String>[
        '-destination',
        destination,
      ];
    }
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final List<String> testPlatforms = <String>[];
    for (final String platform in _requestedPlatforms) {
      if (!pluginSupportsPlatform(platform, package,
          requiredMode: PlatformSupport.inline)) {
        print('No implementation for ${_platforms[platform]!.label}.');
        continue;
      }
      if (!pluginHasNativeCodeForPlatform(platform, package)) {
        print('No native code for ${_platforms[platform]!.label}.');
        continue;
      }
      testPlatforms.add(platform);
    }

    if (testPlatforms.isEmpty) {
      return PackageResult.skip('Nothing to test for target platform(s).');
    }

    final _TestMode mode = _TestMode(
      unit: getBoolArg(_unitTestFlag),
      integration: getBoolArg(_integrationTestFlag),
    );

    bool ranTests = false;
    bool failed = false;
    final List<String> failureMessages = <String>[];
    for (final String platform in testPlatforms) {
      final _PlatformDetails platformInfo = _platforms[platform]!;
      print('Running tests for ${platformInfo.label}...');
      print('----------------------------------------');
      final _PlatformResult result =
          await platformInfo.testFunction(package, mode);
      ranTests |= result.state != RunState.skipped;
      if (result.state == RunState.failed) {
        failed = true;

        final String? error = result.error;
        // Only provide the failing platforms in the failure details if testing
        // multiple platforms, otherwise it's just noise.
        if (_requestedPlatforms.length > 1) {
          failureMessages.add(error != null
              ? '${platformInfo.label}: $error'
              : platformInfo.label);
        } else if (error != null) {
          // If there's only one platform, only provide error details in the
          // summary if the platform returned a message.
          failureMessages.add(error);
        }
      }
    }

    if (!ranTests) {
      return PackageResult.skip('No tests found.');
    }
    return failed
        ? PackageResult.fail(failureMessages)
        : PackageResult.success();
  }

  Future<_PlatformResult> _testAndroid(
      RepositoryPackage plugin, _TestMode mode) async {
    bool exampleHasUnitTests(RepositoryPackage example) {
      return example
              .platformDirectory(FlutterPlatform.android)
              .childDirectory('app')
              .childDirectory('src')
              .childDirectory('test')
              .existsSync() ||
          plugin
              .platformDirectory(FlutterPlatform.android)
              .childDirectory('src')
              .childDirectory('test')
              .existsSync();
    }

    _JavaTestInfo getJavaTestInfo(File testFile) {
      final List<String> contents = testFile.readAsLinesSync();
      return _JavaTestInfo(
          usesFlutterTestRunner: contents.any((String line) =>
              line.trimLeft().startsWith('@RunWith(FlutterTestRunner.class)')),
          hasDartIntegrationTestAnnotation: contents.any((String line) =>
              line.trimLeft().startsWith('@DartIntegrationTest')));
    }

    Map<File, _JavaTestInfo> findIntegrationTestFiles(
        RepositoryPackage example) {
      final Directory integrationTestDirectory = example
          .platformDirectory(FlutterPlatform.android)
          .childDirectory('app')
          .childDirectory('src')
          .childDirectory('androidTest');
      // There are two types of integration tests that can be in the androidTest
      // directory:
      // - FlutterTestRunner.class tests, which bridge to Dart integration tests
      // - Purely native integration tests
      // Only the latter is supported by this command; the former will hang if
      // run here because they will wait for a Dart call that will never come.
      //
      // Find all test files, and determine which kind of test they are based on
      // the annotations they use.
      //
      // Ignore DartIntegrationTest.java, which defines the annotation used
      // below for filtering the former out when running tests.
      if (!integrationTestDirectory.existsSync()) {
        return <File, _JavaTestInfo>{};
      }
      final Iterable<File> integrationTestFiles = integrationTestDirectory
          .listSync(recursive: true)
          .whereType<File>()
          .where((File file) {
        final String basename = file.basename;
        return basename != 'DartIntegrationTest.java' &&
            basename != 'DartIntegrationTest.kt';
      });
      return <File, _JavaTestInfo>{
        for (final File file in integrationTestFiles)
          file: getJavaTestInfo(file)
      };
    }

    final Iterable<RepositoryPackage> examples = plugin.getExamples();
    final String pluginName = plugin.directory.basename;

    bool ranUnitTests = false;
    bool ranAnyTests = false;
    bool failed = false;
    bool hasMisconfiguredIntegrationTest = false;
    // Iterate through all examples (in the rare case that there is more than
    // one example); running any tests found for each one. Requirements on what
    // tests are present are enforced at the overall package level, not a per-
    // example level. E.g., it's fine for only one example to have unit tests.
    for (final RepositoryPackage example in examples) {
      final bool hasUnitTests = exampleHasUnitTests(example);
      final Map<File, _JavaTestInfo> candidateIntegrationTestFiles =
          findIntegrationTestFiles(example);
      final bool hasIntegrationTests = candidateIntegrationTestFiles.values
          .any((_JavaTestInfo info) => !info.hasDartIntegrationTestAnnotation);

      if (mode.unit && !hasUnitTests) {
        _printNoExampleTestsMessage(example, 'Android unit');
      }
      if (mode.integration && !hasIntegrationTests) {
        _printNoExampleTestsMessage(example, 'Android integration');
      }

      final bool runUnitTests = mode.unit && hasUnitTests;
      final bool runIntegrationTests = mode.integration && hasIntegrationTests;
      if (!runUnitTests && !runIntegrationTests) {
        continue;
      }

      final String exampleName = example.displayName;
      _printRunningExampleTestsMessage(example, 'Android');

      final GradleProject project = GradleProject(
        example,
        processRunner: processRunner,
        platform: platform,
      );
      if (!project.isConfigured()) {
        final int exitCode = await processRunner.runAndStream(
          flutterCommand,
          <String>['build', 'apk', '--config-only'],
          workingDir: example.directory,
        );
        if (exitCode != 0) {
          printError('Unable to configure Gradle project.');
          failed = true;
          continue;
        }
      }

      if (runUnitTests) {
        print('Running unit tests...');
        const String taskName = 'testDebugUnitTest';
        // Target the unit tests in the app and plugin specifically, to avoid
        // transitively running tests in dependencies. If unit tests have
        // already run in an earlier example, only run any app-level unit tests.
        final List<String> pluginTestTask = <String>[
          if (!ranUnitTests) '$pluginName:$taskName'
        ];
        final int exitCode = await project.runCommand('app:$taskName',
            additionalTasks: pluginTestTask);
        if (exitCode != 0) {
          printError('$exampleName unit tests failed.');
          failed = true;
        }
        ranUnitTests = true;
        ranAnyTests = true;
      }

      if (runIntegrationTests) {
        // FlutterTestRunner-based tests will hang forever if run in a normal
        // app build, since they wait for a Dart call from integration_test
        // that will never come. Those tests have an extra annotation to allow
        // filtering them out.
        final List<File> misconfiguredTestFiles = candidateIntegrationTestFiles
            .entries
            .where((MapEntry<File, _JavaTestInfo> entry) =>
                entry.value.usesFlutterTestRunner &&
                !entry.value.hasDartIntegrationTestAnnotation)
            .map((MapEntry<File, _JavaTestInfo> entry) => entry.key)
            .toList();
        if (misconfiguredTestFiles.isEmpty) {
          // Ideally we would filter out @RunWith(FlutterTestRunner.class)
          // tests directly, but there doesn't seem to be a way to filter based
          // on annotation contents, so the DartIntegrationTest annotation was
          // created as a proxy for that.
          const String filter =
              'notAnnotation=io.flutter.plugins.DartIntegrationTest';

          print('Running integration tests...');
          // Explicitly request all ABIs, as Flutter would if being called
          // without a specific target (see
          // https://github.com/flutter/flutter/pull/154476) to ensure it can
          // run on any architecture emulator.
          const List<String> abis = <String>[
            'android-arm',
            'android-arm64',
            'android-x64',
            'android-x86'
          ];
          final int exitCode = await project.runCommand(
            'app:connectedAndroidTest',
            arguments: <String>[
              '-Pandroid.testInstrumentationRunnerArguments.$filter',
              '-Ptarget-platform=${abis.join(',')}',
            ],
          );
          if (exitCode != 0) {
            printError('$exampleName integration tests failed.');
            failed = true;
          }
          ranAnyTests = true;
        } else {
          hasMisconfiguredIntegrationTest = true;
          printError('$misconfiguredJavaIntegrationTestErrorExplanation\n'
              '${misconfiguredTestFiles.map((File f) => '  ${f.path}').join('\n')}');
        }
      }
    }

    if (failed) {
      return _PlatformResult(RunState.failed);
    }
    if (hasMisconfiguredIntegrationTest) {
      return _PlatformResult(RunState.failed,
          error: 'Misconfigured integration test.');
    }
    if (!mode.integrationOnly && !ranUnitTests) {
      printError('No unit tests ran. Plugins are required to have unit tests.');
      return _PlatformResult(RunState.failed,
          error: 'No unit tests ran (use --exclude if this is intentional).');
    }
    if (!ranAnyTests) {
      return _PlatformResult(RunState.skipped);
    }
    return _PlatformResult(RunState.succeeded);
  }

  Future<_PlatformResult> _testIOS(RepositoryPackage plugin, _TestMode mode) {
    return _runXcodeTests(plugin, 'iOS', mode,
        extraFlags: _iOSDestinationFlags);
  }

  Future<_PlatformResult> _testMacOS(RepositoryPackage plugin, _TestMode mode) {
    return _runXcodeTests(plugin, 'macOS', mode);
  }

  /// Runs all applicable tests for [plugin], printing status and returning
  /// the test result.
  ///
  /// The tests targets must be added to the Xcode project of the example app,
  /// usually at "example/{ios,macos}/Runner.xcworkspace".
  Future<_PlatformResult> _runXcodeTests(
    RepositoryPackage plugin,
    String platform,
    _TestMode mode, {
    List<String> extraFlags = const <String>[],
  }) async {
    String? testTarget;
    const String unitTestTarget = 'RunnerTests';
    if (mode.unitOnly) {
      testTarget = unitTestTarget;
    } else if (mode.integrationOnly) {
      testTarget = 'RunnerUITests';
    }

    bool ranUnitTests = false;
    // Assume skipped until at least one test has run.
    RunState overallResult = RunState.skipped;
    for (final RepositoryPackage example in plugin.getExamples()) {
      final String exampleName = example.displayName;

      // If running a specific target, check that. Otherwise, check if there
      // are unit tests, since having no unit tests for a plugin is fatal
      // (by repo policy) even if there are integration tests.
      bool exampleHasUnitTests = false;
      final String? targetToCheck =
          testTarget ?? (mode.unit ? unitTestTarget : null);
      final Directory xcodeProject = example.directory
          .childDirectory(platform.toLowerCase())
          .childDirectory('Runner.xcodeproj');
      if (targetToCheck != null) {
        final bool? hasTarget =
            await _xcode.projectHasTarget(xcodeProject, targetToCheck);
        if (hasTarget == null) {
          printError('Unable to check targets for $exampleName.');
          overallResult = RunState.failed;
          continue;
        } else if (!hasTarget) {
          print('No "$targetToCheck" target in $exampleName; skipping.');
          continue;
        } else if (targetToCheck == unitTestTarget) {
          exampleHasUnitTests = true;
        }
      }

      _printRunningExampleTestsMessage(example, platform);
      final int exitCode = await _xcode.runXcodeBuild(
        example.directory,
        platform,
        // Clean before testing to remove cached swiftmodules from previous
        // runs, which can cause conflicts.
        actions: <String>['clean', 'test'],
        workspace: '${platform.toLowerCase()}/Runner.xcworkspace',
        scheme: 'Runner',
        configuration: 'Debug',
        extraFlags: <String>[
          if (testTarget != null) '-only-testing:$testTarget',
          ...extraFlags,
          'GCC_TREAT_WARNINGS_AS_ERRORS=YES',
        ],
      );

      // The exit code from 'xcodebuild test' when there are no tests.
      const int xcodebuildNoTestExitCode = 66;
      switch (exitCode) {
        case xcodebuildNoTestExitCode:
          _printNoExampleTestsMessage(example, platform);
        case 0:
          printSuccess('Successfully ran $platform xctest for $exampleName');
          // If this is the first test, assume success until something fails.
          if (overallResult == RunState.skipped) {
            overallResult = RunState.succeeded;
          }
          if (exampleHasUnitTests) {
            ranUnitTests = true;
          }
        default:
          // Any failure means a failure overall.
          overallResult = RunState.failed;
          // If unit tests ran, note that even if they failed.
          if (exampleHasUnitTests) {
            ranUnitTests = true;
          }
      }
    }

    if (!mode.integrationOnly && !ranUnitTests) {
      printError('No unit tests ran. Plugins are required to have unit tests.');
      // Only return a specific summary error message about the missing unit
      // tests if there weren't also failures, to avoid having a misleadingly
      // specific message.
      if (overallResult != RunState.failed) {
        return _PlatformResult(RunState.failed,
            error: 'No unit tests ran (use --exclude if this is intentional).');
      }
    }

    return _PlatformResult(overallResult);
  }

  Future<_PlatformResult> _testWindows(
      RepositoryPackage plugin, _TestMode mode) async {
    if (mode.integrationOnly) {
      return _PlatformResult(RunState.skipped);
    }

    bool isTestBinary(File file) {
      return file.basename.endsWith('_test.exe') ||
          file.basename.endsWith('_tests.exe');
    }

    return _runGoogleTestTests(plugin, 'Windows', 'Debug',
        isTestBinary: isTestBinary);
  }

  Future<_PlatformResult> _testLinux(
      RepositoryPackage plugin, _TestMode mode) async {
    if (mode.integrationOnly) {
      return _PlatformResult(RunState.skipped);
    }

    bool isTestBinary(File file) {
      return file.basename.endsWith('_test') ||
          file.basename.endsWith('_tests');
    }

    // Since Linux uses a single-config generator, building-examples only
    // generates the build files for release, so the tests have to be run in
    // release mode as well.
    //
    // TODO(stuartmorgan): Consider adding a command to `flutter` that would
    // generate build files without doing a build, and using that instead of
    // relying on running build-examples. See
    // https://github.com/flutter/flutter/issues/93407.
    return _runGoogleTestTests(plugin, 'Linux', 'Release',
        isTestBinary: isTestBinary);
  }

  /// Finds every file in the relevant (based on [platformName], [buildMode],
  /// and [arch]) subdirectory of [plugin]'s build directory for which
  /// [isTestBinary] is true, and runs all of them, returning the overall
  /// result.
  ///
  /// The binaries are assumed to be Google Test test binaries, thus returning
  /// zero for success and non-zero for failure.
  Future<_PlatformResult> _runGoogleTestTests(
    RepositoryPackage plugin,
    String platformName,
    String buildMode, {
    required bool Function(File) isTestBinary,
  }) async {
    final List<File> testBinaries = <File>[];
    bool hasMissingBuild = false;
    bool buildFailed = false;
    String? arch;
    const String x64DirName = 'x64';
    const String arm64DirName = 'arm64';
    if (platform.isWindows) {
      arch = _abi == Abi.windowsX64 ? x64DirName : arm64DirName;
    } else if (platform.isLinux) {
      // TODO(stuartmorgan): Support arm64 if that ever becomes a supported
      // CI configuration for the repository.
      arch = 'x64';
    }
    for (final RepositoryPackage example in plugin.getExamples()) {
      CMakeProject project = CMakeProject(example.directory,
          buildMode: buildMode,
          processRunner: processRunner,
          platform: platform,
          arch: arch);
      if (platform.isWindows) {
        if (arch == arm64DirName && !project.isConfigured()) {
          // Check for x64, to handle builds newer than 3.13, but that don't yet
          // have https://github.com/flutter/flutter/issues/129807.
          // TODO(stuartmorgan): Remove this when CI no longer supports a
          // version of Flutter without the issue above fixed.
          project = CMakeProject(example.directory,
              buildMode: buildMode,
              processRunner: processRunner,
              platform: platform,
              arch: x64DirName);
        }
        if (!project.isConfigured()) {
          // Check again without the arch subdirectory, since 3.13 doesn't
          // have it yet.
          // TODO(stuartmorgan): Remove this when CI no longer supports Flutter
          // 3.13.
          project = CMakeProject(example.directory,
              buildMode: buildMode,
              processRunner: processRunner,
              platform: platform);
        }
      }
      if (!project.isConfigured()) {
        printError('ERROR: Run "flutter build" on ${example.displayName}, '
            'or run this tool\'s "build-examples" command, for the target '
            'platform before executing tests.');
        hasMissingBuild = true;
        continue;
      }

      // By repository convention, example projects create an aggregate target
      // called 'unit_tests' that builds all unit tests (usually just an alias
      // for a specific test target).
      final int exitCode = await project.runBuild('unit_tests');
      if (exitCode != 0) {
        printError('${example.displayName} unit tests failed to build.');
        buildFailed = true;
      }

      testBinaries.addAll(project.buildDirectory
          .listSync(recursive: true)
          .whereType<File>()
          .where(isTestBinary)
          .where((File file) {
        // Only run the `buildMode` build of the unit tests, to avoid running
        // the same tests multiple times.
        final List<String> components = path.split(file.path);
        return components.contains(buildMode) ||
            components.contains(buildMode.toLowerCase());
      }));
    }

    if (hasMissingBuild) {
      return _PlatformResult(RunState.failed,
          error: 'Examples must be built before testing.');
    }

    if (buildFailed) {
      return _PlatformResult(RunState.failed,
          error: 'Failed to build $platformName unit tests.');
    }

    if (testBinaries.isEmpty) {
      final String binaryExtension = platform.isWindows ? '.exe' : '';
      printError(
          'No test binaries found. At least one *_test(s)$binaryExtension '
          'binary should be built by the example(s)');
      return _PlatformResult(RunState.failed,
          error: 'No $platformName unit tests found');
    }

    bool passing = true;
    for (final File test in testBinaries) {
      print('Running ${test.basename}...');
      final int exitCode =
          await processRunner.runAndStream(test.path, <String>[]);
      passing &= exitCode == 0;
    }
    return _PlatformResult(passing ? RunState.succeeded : RunState.failed);
  }

  /// Prints a standard format message indicating that [platform] tests for
  /// [plugin]'s [example] are about to be run.
  void _printRunningExampleTestsMessage(
      RepositoryPackage example, String platform) {
    print('Running $platform tests for ${example.displayName}...');
  }

  /// Prints a standard format message indicating that no tests were found for
  /// [plugin]'s [example] for [platform].
  void _printNoExampleTestsMessage(RepositoryPackage example, String platform) {
    print('No $platform tests found for ${example.displayName}');
  }
}

// The type for a function that takes a plugin directory and runs its native
// tests for a specific platform.
typedef _TestFunction = Future<_PlatformResult> Function(
    RepositoryPackage, _TestMode);

/// A collection of information related to a specific platform.
class _PlatformDetails {
  const _PlatformDetails(
    this.label,
    this.testFunction,
  );

  /// The name to use in output.
  final String label;

  /// The function to call to run tests.
  final _TestFunction testFunction;
}

/// Enabled state for different test types.
class _TestMode {
  const _TestMode({required this.unit, required this.integration});

  final bool unit;
  final bool integration;

  bool get integrationOnly => integration && !unit;
  bool get unitOnly => unit && !integration;
}

/// The result of running a single platform's tests.
class _PlatformResult {
  _PlatformResult(this.state, {this.error});

  /// The overall state of the platform's tests. This should be:
  /// - failed if any tests failed.
  /// - succeeded if at least one test ran, and all tests passed.
  /// - skipped if no tests ran.
  final RunState state;

  /// An optional error string to include in the summary for this platform.
  ///
  /// Ignored unless [state] is `failed`.
  final String? error;
}

/// The state of a .java test file.
class _JavaTestInfo {
  const _JavaTestInfo(
      {required this.usesFlutterTestRunner,
      required this.hasDartIntegrationTestAnnotation});

  /// Whether the test class uses the FlutterTestRunner.
  final bool usesFlutterTestRunner;

  /// Whether the test class has the @DartIntegrationTest annotation.
  final bool hasDartIntegrationTestAnnotation;
}
