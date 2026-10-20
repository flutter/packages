// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file/file.dart';

import 'common/core.dart';
import 'common/file_filters.dart';
import 'common/output_utils.dart';
import 'common/package_looping_command.dart';
import 'common/plugin_utils.dart';
import 'common/repository_package.dart';

const int _exitInvalidArgs = 2;
const int _exitNoAvailableDevice = 3;

/// A command to run the integration tests for a package's example applications.
class DriveExamplesCommand extends PackageLoopingCommand {
  /// Creates an instance of the drive command.
  DriveExamplesCommand(super.packagesDir, {super.processRunner, super.platform, super.gitDir}) {
    argParser.addFlag(
      platformAndroid,
      help: 'Runs the Android implementation of the examples',
      aliases: const <String>[platformAndroidAlias],
    );
    argParser.addFlag(platformIOS, help: 'Runs the iOS implementation of the examples');
    argParser.addFlag(platformLinux, help: 'Runs the Linux implementation of the examples');
    argParser.addFlag(platformMacOS, help: 'Runs the macOS implementation of the examples');
    argParser.addFlag(platformWeb, help: 'Runs the web implementation of the examples');
    argParser.addFlag(platformWindows, help: 'Runs the Windows implementation of the examples');
    argParser.addFlag(kWebWasmFlag, help: 'Compile to WebAssembly rather than JavaScript');
    argParser.addOption(
      kEnableExperiment,
      defaultsTo: '',
      help: 'Runs the driver tests in Dart VM with the given experiments enabled.',
    );
    argParser.addFlag(
      _chromeDriverFlag,
      help:
          'Runs chromedriver for the duration of the test.\n\n'
          'Requires the correct version of chromedriver to be in your path.',
    );
  }

  static const String _chromeDriverFlag = 'run-chromedriver';

  static const List<String> _webChromeBrowserFlags = <String>[
    '--web-browser-flag=--no-sandbox',
    '--web-browser-flag=--disable-background-timer-throttling',
    '--web-browser-flag=--disable-renderer-backgrounding',
    '--web-browser-flag=--disable-background-networking',
    '--web-browser-flag=--disable-search-engine-choice-screen',
    '--web-browser-flag=--disable-extensions',
    '--web-browser-flag=--disable-popup-blocking',
    '--web-browser-flag=--disable-translate',
    '--web-browser-flag=--disable-default-apps',
    '--web-browser-flag=--no-default-browser-check',
    '--web-browser-flag=--no-first-run',
    '--web-browser-flag=--password-store=basic',
    '--web-browser-flag=--bwsi',
  ];

  @override
  final String name = 'drive-examples';

  @override
  final String description =
      'Runs Dart integration tests for example apps.\n\n'
      "This runs all tests in each example's integration_test directory, "
      'via "flutter test" on most platforms, and "flutter drive" on web.\n\n'
      'This command requires "flutter" to be in your path.';

  Map<String, List<String>> _targetDeviceFlags = const <String, List<String>>{};

  @override
  bool shouldIgnoreFile(String path) {
    return isRepoLevelNonCodeImpactingFile(path) ||
        isPackageSupportFile(path) ||
        // This isn't part of isRepoLevelNonCodeImpactingFile since there could
        // potentially be code-based commands that it could affect, but it
        // should not affect integration tests, and they are the most expensive
        // and flaky tests.
        path == '.gitignore';
  }

  @override
  Future<void> initializeRun() async {
    final platformSwitches = <String>[
      platformAndroid,
      platformIOS,
      platformLinux,
      platformMacOS,
      platformWeb,
      platformWindows,
    ];
    final int platformCount = platformSwitches
        .where((String platform) => getBoolArg(platform))
        .length;
    // The flutter tool currently doesn't accept multiple device arguments:
    // https://github.com/flutter/flutter/issues/35733
    // If that is implemented, this check can be relaxed.
    if (platformCount != 1) {
      printError(
        'Exactly one of ${platformSwitches.map((String platform) => '--$platform').join(', ')} '
        'must be specified.',
      );
      throw ToolExit(_exitInvalidArgs);
    }

    String? androidDevice;
    if (getBoolArg(platformAndroid)) {
      final List<String> devices = await _getDevicesForPlatform('android');
      if (devices.isEmpty) {
        printError('No Android devices available');
        throw ToolExit(_exitNoAvailableDevice);
      }
      androidDevice = devices.first;
    }

    String? iOSDevice;
    if (getBoolArg(platformIOS)) {
      final List<String> devices = await _getDevicesForPlatform('ios');
      if (devices.isEmpty) {
        printError('No iOS devices available');
        throw ToolExit(_exitNoAvailableDevice);
      }
      iOSDevice = devices.first;
    }

    final bool useWasm = getBoolArg(kWebWasmFlag);
    final bool hasPlatformWeb = getBoolArg(platformWeb);
    if (useWasm && !hasPlatformWeb) {
      printError('--wasm is only supported on the web platform');
      throw ToolExit(_exitInvalidArgs);
    }

    _targetDeviceFlags = <String, List<String>>{
      if (getBoolArg(platformAndroid)) platformAndroid: <String>['-d', androidDevice!],
      if (getBoolArg(platformIOS)) platformIOS: <String>['-d', iOSDevice!],
      if (getBoolArg(platformLinux)) platformLinux: <String>['-d', 'linux'],
      if (getBoolArg(platformMacOS)) platformMacOS: <String>['-d', 'macos'],
      if (hasPlatformWeb)
        platformWeb: <String>[
          '-d',
          'web-server',
          '--web-port=7357',
          '--browser-name=chrome',
          if (useWasm) '--wasm',
          if (platform.environment.containsKey('CHROME_EXECUTABLE'))
            '--chrome-binary=${platform.environment['CHROME_EXECUTABLE']}',
          ..._webChromeBrowserFlags,
          if (platform.isMacOS) '--web-browser-flag=--use-mock-keychain',
        ],
      if (getBoolArg(platformWindows)) platformWindows: <String>['-d', 'windows'],
    };
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final bool isPlugin = isFlutterPlugin(package);

    if (package.isPlatformInterface && package.getExamples().isEmpty) {
      // Platform interface packages generally aren't intended to have
      // examples, and don't need integration tests, so skip rather than fail.
      return PackageResult.skip('Platform interfaces are not expected to have integration tests.');
    }

    // For plugin packages, skip if the plugin itself doesn't support any
    // requested platform(s).
    if (isPlugin) {
      final Iterable<String> requestedPlatforms = _targetDeviceFlags.keys;
      final Iterable<String> unsupportedPlatforms = requestedPlatforms.where(
        (String platform) => !pluginSupportsPlatform(platform, package),
      );
      for (final platform in unsupportedPlatforms) {
        print('Skipping unsupported platform $platform...');
      }
      if (unsupportedPlatforms.length == requestedPlatforms.length) {
        return PackageResult.skip(
          '${package.displayName} does not support any requested platform.',
        );
      }
    }

    var examplesFound = 0;
    var supportedExamplesFound = 0;
    var testsRan = false;
    final errors = <String>[];
    for (final RepositoryPackage example in package.getExamples()) {
      ++examplesFound;
      final String exampleName = getRelativePosixPath(example.directory, from: packagesDir);

      // Skip examples that don't support any requested platform(s).
      final List<String> deviceFlags = _deviceFlagsForExample(example);
      if (deviceFlags.isEmpty) {
        print('Skipping $exampleName; does not support any requested platforms.');
        continue;
      }

      ++supportedExamplesFound;

      final List<File> testTargets = await _getIntegrationTests(example);
      if (testTargets.isEmpty) {
        print('No integration_test/*.dart files found for $exampleName.');
        continue;
      }

      // Check files for known problematic patterns.
      testTargets.where((File file) => !_validateIntegrationTest(file)).forEach((File file) {
        // Report the issue, but continue with the test as the validation
        // errors don't prevent running.
        errors.add('${file.basename} failed validation');
      });

      // `flutter test` doesn't yet support web integration tests, so fall back
      // to `flutter drive`.
      final bool useFlutterDrive = getBoolArg(platformWeb);

      final List<File> drivers;
      if (useFlutterDrive) {
        drivers = await _getDrivers(example);
        if (drivers.isEmpty) {
          print('No driver found for $exampleName');
          continue;
        }
      } else {
        drivers = <File>[];
      }

      testsRan = true;
      if (useFlutterDrive) {
        final List<File> failingTargets;
        try {
          failingTargets = await _driveExample(
            example,
            drivers,
            testTargets,
            deviceFlags: deviceFlags,
            exampleName: exampleName,
          );
        } on _ChromeDriverStartException catch (e) {
          printError(e.message);
          errors.add('chromedriver failed to start for $exampleName');
          continue;
        }
        for (final failingTarget in failingTargets) {
          errors.add(getRelativePosixPath(failingTarget, from: package.directory));
        }
      } else {
        if (!await _runTests(example, deviceFlags: deviceFlags, testFiles: testTargets)) {
          errors.add('Integration tests failed.');
        }
      }
    }
    if (!testsRan) {
      // It is an error for a plugin not to have integration tests, because that
      // is the only way to test the method channel communication.
      if (isPlugin) {
        printError('No driver tests were run ($examplesFound example(s) found).');
        errors.add('No tests ran (use --exclude if this is intentional).');
      } else {
        return PackageResult.skip(
          supportedExamplesFound == 0
              ? 'No example supports requested platform(s).'
              : 'No example is configured for integration tests.',
        );
      }
    }
    return errors.isEmpty ? PackageResult.success() : PackageResult.fail(errors);
  }

  /// Returns the device flags for the intersection of the requested platforms
  /// and the platforms supported by [example].
  List<String> _deviceFlagsForExample(RepositoryPackage example) {
    final deviceFlags = <String>[];
    for (final MapEntry<String, List<String>> entry in _targetDeviceFlags.entries) {
      final String platform = entry.key;
      if (example.appSupportsPlatform(getPlatformByName(platform))) {
        deviceFlags.addAll(entry.value);
      } else {
        final String exampleName = getRelativePosixPath(example.directory, from: packagesDir);
        print('Skipping unsupported platform $platform for $exampleName');
      }
    }
    return deviceFlags;
  }

  Future<List<String>> _getDevicesForPlatform(String platform) async {
    final deviceIds = <String>[];

    final ProcessResult result = await processRunner.run(flutterCommand, <String>[
      'devices',
      '--machine',
    ], stdoutEncoding: utf8);
    if (result.exitCode != 0) {
      return deviceIds;
    }

    var output = result.stdout as String;
    // --machine doesn't currently prevent the tool from printing banners;
    // see https://github.com/flutter/flutter/issues/86055. This workaround
    // can be removed once that is fixed.
    output = output.substring(output.indexOf('['));

    final List<Map<String, dynamic>> devices = (jsonDecode(output) as List<dynamic>)
        .cast<Map<String, dynamic>>();
    for (final deviceInfo in devices) {
      final String targetPlatform = (deviceInfo['targetPlatform'] as String?) ?? '';
      if (targetPlatform.startsWith(platform)) {
        final deviceId = deviceInfo['id'] as String?;
        if (deviceId != null) {
          deviceIds.add(deviceId);
        }
      }
    }
    return deviceIds;
  }

  Future<List<File>> _getDrivers(RepositoryPackage example) async {
    final drivers = <File>[];

    final Directory driverDir = example.directory.childDirectory('test_driver');
    if (driverDir.existsSync()) {
      await for (final FileSystemEntity driver in driverDir.list()) {
        if (driver is File && driver.basename.endsWith('_test.dart')) {
          drivers.add(driver);
        }
      }
    }
    return drivers;
  }

  Future<List<File>> _getIntegrationTests(RepositoryPackage example) async {
    final tests = <File>[];
    final Directory integrationTestDir = example.directory.childDirectory('integration_test');

    if (integrationTestDir.existsSync()) {
      await for (final FileSystemEntity file in integrationTestDir.list(recursive: true)) {
        if (file is File && file.basename.endsWith('_test.dart')) {
          tests.add(file);
        }
      }
    }
    return tests;
  }

  /// Checks [testFile] for known bad patterns in integration tests, logging
  /// any issues.
  ///
  /// Returns true if the file passes validation without issues.
  bool _validateIntegrationTest(File testFile) {
    final List<String> lines = testFile.readAsLinesSync();

    final badTestPattern = RegExp(r'\s*test\(');
    if (lines.any((String line) => line.startsWith(badTestPattern))) {
      final String filename = testFile.basename;
      printError(
        '$filename uses "test", which will not report failures correctly. '
        'Use testWidgets instead.',
      );
      return false;
    }

    return true;
  }

  /// Drives [testTargets] for [example] across all [drivers], starting and
  /// stopping `chromedriver` when `--run-chromedriver` is enabled.
  Future<List<File>> _driveExample(
    RepositoryPackage example,
    List<File> drivers,
    List<File> testTargets, {
    required List<String> deviceFlags,
    required String exampleName,
  }) async {
    if (!getBoolArg(_chromeDriverFlag)) {
      return _driveTestsForDrivers(
        example,
        drivers,
        testTargets,
        deviceFlags: deviceFlags,
        exampleName: exampleName,
      );
    }

    final (_ChromeDriver chromedriver, int chromeDriverPort) = await _startChromeDriver();
    try {
      return await _driveTestsForDrivers(
        example,
        drivers,
        testTargets,
        deviceFlags: <String>[...deviceFlags, '--driver-port=$chromeDriverPort'],
        exampleName: exampleName,
      );
    } finally {
      print('Stopping chromedriver');
      await chromedriver.stop();
    }
  }

  /// Starts `chromedriver --port=0` and waits for it to report the bound port
  /// on stdout.
  Future<(_ChromeDriver, int)> _startChromeDriver() async {
    print('Starting chromedriver...');
    final chromedriver = _ChromeDriver(
      await processRunner.start('chromedriver', <String>['--port=0']),
    );
    try {
      final int port = await chromedriver.port;
      print('Started chromedriver on port $port');
      return (chromedriver, port);
    } on Object {
      await chromedriver.stop();
      rethrow;
    }
  }

  Future<List<File>> _driveTestsForDrivers(
    RepositoryPackage example,
    List<File> drivers,
    List<File> testTargets, {
    required List<String> deviceFlags,
    required String exampleName,
  }) async {
    final failingTargets = <File>[];
    for (final driver in drivers) {
      failingTargets.addAll(
        await _driveTests(
          example,
          driver,
          testTargets,
          deviceFlags: deviceFlags,
          exampleName: exampleName,
        ),
      );
    }
    return failingTargets;
  }

  /// For each file in [targets], uses
  /// `flutter drive --driver [driver] --target <target>`
  /// to drive [example], returning a list of any failing test targets.
  ///
  /// [deviceFlags] should contain the flags to run the test on a specific
  /// target device (plus any supporting device-specific flags). E.g.:
  ///   - `['-d', 'macos']` for driving for macOS.
  ///   - `['-d', 'web-server', '--web-port=<port>', '--browser-name=<browser>]`
  ///     for web
  Future<List<File>> _driveTests(
    RepositoryPackage example,
    File driver,
    List<File> targets, {
    required List<String> deviceFlags,
    required String exampleName,
  }) async {
    final failures = <File>[];

    final String enableExperiment = getStringArg(kEnableExperiment);
    final screenshotBasename = '${exampleName.replaceAll(platform.pathSeparator, '_')}-drive';
    final Directory? screenshotDirectory = ciLogsDirectory(
      platform,
      driver.fileSystem,
    )?.childDirectory(screenshotBasename);

    for (final target in targets) {
      final int exitCode = await processRunner.runAndStream(flutterCommand, <String>[
        'drive',
        ...deviceFlags,
        if (enableExperiment.isNotEmpty) '--enable-experiment=$enableExperiment',
        if (screenshotDirectory != null) '--screenshot=${screenshotDirectory.path}',
        '--driver',
        getRelativePosixPath(driver, from: example.directory),
        '--target',
        getRelativePosixPath(target, from: example.directory),
      ], workingDir: example.directory);
      if (exitCode != 0) {
        failures.add(target);
      }
    }
    return failures;
  }

  /// Uses `flutter test integration_test` to run [example], returning the
  /// success of the test run.
  ///
  /// [deviceFlags] should contain the flags to run the test on a specific
  /// target device (plus any supporting device-specific flags). E.g.:
  ///   - `['-d', 'macos']` for driving for macOS.
  ///   - `['-d', 'web-server', '--web-port=<port>', '--browser-name=<browser>]`
  ///     for web
  Future<bool> _runTests(
    RepositoryPackage example, {
    required List<String> deviceFlags,
    required List<File> testFiles,
  }) async {
    final String enableExperiment = getStringArg(kEnableExperiment);
    final Directory? logsDirectory = ciLogsDirectory(platform, testFiles.first.fileSystem);

    // Workaround for https://github.com/flutter/flutter/issues/135673
    // Once that is fixed on stable, this logic can be removed and the command
    // can always just be run with "integration_test".
    final bool needsMultipleInvocations =
        testFiles.length > 1 &&
        (getBoolArg(platformLinux) || getBoolArg(platformMacOS) || getBoolArg(platformWindows));
    final Iterable<String> individualRunTargets = needsMultipleInvocations
        ? testFiles.map((File f) => getRelativePosixPath(f, from: example.directory))
        : <String>['integration_test'];

    var passed = true;
    for (final target in individualRunTargets) {
      final timeoutTimer = Timer(const Duration(minutes: 10), () async {
        final screenshotBasename =
            'test-timeout-screenshot_${target.replaceAll(platform.pathSeparator, '_')}.png';
        printWarning('Test is taking a long time, taking screenshot $screenshotBasename...');
        await processRunner.runAndStream(flutterCommand, <String>[
          'screenshot',
          ...deviceFlags,
          if (logsDirectory != null) '--out=${logsDirectory.childFile(screenshotBasename).path}',
        ], workingDir: example.directory);
      });
      final int exitCode = await processRunner.runAndStream(flutterCommand, <String>[
        'test',
        ...deviceFlags,
        if (enableExperiment.isNotEmpty) '--enable-experiment=$enableExperiment',
        if (logsDirectory != null) '--debug-logs-dir=${logsDirectory.path}',
        target,
      ], workingDir: example.directory);

      timeoutTimer.cancel();
      passed = passed && (exitCode == 0);
    }
    return passed;
  }
}

/// A running `chromedriver` process started with `--port=0`.
class _ChromeDriver {
  _ChromeDriver(this._process) {
    _stderrSubscription = _process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (String line) {
            if (!_portCompleter.isCompleted) {
              _stderrBuffer.writeln(line);
            }
          },
          onError: (Object _) {
            if (!_stderrDone.isCompleted) {
              _stderrDone.complete();
            }
          },
          onDone: () {
            if (!_stderrDone.isCompleted) {
              _stderrDone.complete();
            }
          },
        );
    _stdoutSubscription = _process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (String line) {
            if (_portCompleter.isCompleted) {
              return;
            }
            _stdoutBuffer.writeln(line);
            if (_portPattern.firstMatch(line) case final RegExpMatch match) {
              _portCompleter.complete(int.parse(match.group(1)!));
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!_portCompleter.isCompleted) {
              _portCompleter.completeError(error, stackTrace);
            }
          },
          onDone: () async {
            if (!_portCompleter.isCompleted) {
              await _stderrDone.future;
              if (!_portCompleter.isCompleted) {
                _portCompleter.completeError(
                  _ChromeDriverStartException(
                    'chromedriver exited before reporting its port.\n'
                    'stdout:\n$_stdoutBuffer'
                    'stderr:\n$_stderrBuffer',
                  ),
                );
              }
            }
          },
        );
  }

  static final RegExp _portPattern = RegExp(r'started successfully on port (\d+)');

  final Process _process;
  final Completer<int> _portCompleter = Completer<int>();
  final Completer<void> _stderrDone = Completer<void>();
  final StringBuffer _stdoutBuffer = StringBuffer();
  final StringBuffer _stderrBuffer = StringBuffer();

  // Both subscriptions stay active until the process exits, since
  // `Process.start` requires reading all of its output.
  late final StreamSubscription<String> _stdoutSubscription;
  late final StreamSubscription<String> _stderrSubscription;

  /// The port that `chromedriver` reports on stdout once it is listening.
  Future<int> get port => _portCompleter.future;

  /// Kills `chromedriver`, waits for it to exit, and stops reading its output.
  Future<void> stop() async {
    _process.kill();
    await _process.exitCode;
    await Future.wait(<Future<void>>[_stdoutSubscription.cancel(), _stderrSubscription.cancel()]);
  }
}

/// Thrown when `chromedriver` exits before reporting the port it listens on.
class _ChromeDriverStartException implements Exception {
  _ChromeDriverStartException(this.message);

  final String message;

  @override
  String toString() => message;
}
