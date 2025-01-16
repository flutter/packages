// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file/file.dart';

import 'common/core.dart';
import 'common/output_utils.dart';
import 'common/package_looping_command.dart';
import 'common/plugin_utils.dart';
import 'common/repository_package.dart';

const int _exitInvalidArgs = 2;
const int _exitNoAvailableDevice = 3;

// From https://flutter.dev/to/integration-test-on-web
const int _chromeDriverPort = 4444;

/// A command to run the integration tests for a package's example applications.
class DriveExamplesCommand extends PackageLoopingCommand {
  /// Creates an instance of the drive command.
  DriveExamplesCommand(
    super.packagesDir, {
    super.processRunner,
    super.platform,
  }) {
    argParser.addFlag(platformAndroid,
        help: 'Runs the Android implementation of the examples',
        aliases: const <String>[platformAndroidAlias]);
    argParser.addFlag(platformIOS,
        help: 'Runs the iOS implementation of the examples');
    argParser.addFlag(platformLinux,
        help: 'Runs the Linux implementation of the examples');
    argParser.addFlag(platformMacOS,
        help: 'Runs the macOS implementation of the examples');
    argParser.addFlag(platformWeb,
        help: 'Runs the web implementation of the examples');
    argParser.addFlag(platformWindows,
        help: 'Runs the Windows implementation of the examples');
    argParser.addFlag(kWebWasmFlag,
        help: 'Compile to WebAssembly rather than JavaScript');
    argParser.addOption(
      kEnableExperiment,
      defaultsTo: '',
      help:
          'Runs the driver tests in Dart VM with the given experiments enabled.',
    );
    argParser.addFlag(_chromeDriverFlag,
        help: 'Runs chromedriver for the duration of the test.\n\n'
            'Requires the correct version of chromedriver to be in your path.');
  }

  static const String _chromeDriverFlag = 'run-chromedriver';

  @override
  final String name = 'drive-examples';

  @override
  final String description = 'Runs Dart integration tests for example apps.\n\n'
      "This runs all tests in each example's integration_test directory, "
      'via "flutter test" on most platforms, and "flutter drive" on web.\n\n'
      'This command requires "flutter" to be in your path.';

  Map<String, List<String>> _targetDeviceFlags = const <String, List<String>>{};

  @override
  Future<void> initializeRun() async {
    final List<String> platformSwitches = <String>[
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
          'must be specified.');
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
      if (getBoolArg(platformAndroid))
        platformAndroid: <String>['-d', androidDevice!],
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
        ],
      if (getBoolArg(platformWindows))
        platformWindows: <String>['-d', 'windows'],
    };
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final bool isPlugin = isFlutterPlugin(package);

    if (package.isPlatformInterface && package.getExamples().isEmpty) {
      // Platform interface packages generally aren't intended to have
      // examples, and don't need integration tests, so skip rather than fail.
      return PackageResult.skip(
          'Platform interfaces are not expected to have integration tests.');
    }

    // For plugin packages, skip if the plugin itself doesn't support any
    // requested platform(s).
    if (isPlugin) {
      final Iterable<String> requestedPlatforms = _targetDeviceFlags.keys;
      final Iterable<String> unsupportedPlatforms = requestedPlatforms.where(
          (String platform) => !pluginSupportsPlatform(platform, package));
      for (final String platform in unsupportedPlatforms) {
        print('Skipping unsupported platform $platform...');
      }
      if (unsupportedPlatforms.length == requestedPlatforms.length) {
        return PackageResult.skip(
            '${package.displayName} does not support any requested platform.');
      }
    }

    int examplesFound = 0;
    int supportedExamplesFound = 0;
    bool testsRan = false;
    final List<String> errors = <String>[];
    for (final RepositoryPackage example in package.getExamples()) {
      ++examplesFound;
      final String exampleName =
          getRelativePosixPath(example.directory, from: packagesDir);

      // Skip examples that don't support any requested platform(s).
      final List<String> deviceFlags = _deviceFlagsForExample(example);
      if (deviceFlags.isEmpty) {
        print(
            'Skipping $exampleName; does not support any requested platforms.');
        continue;
      }

      ++supportedExamplesFound;

      final List<File> testTargets = await _getIntegrationTests(example);
      if (testTargets.isEmpty) {
        print('No integration_test/*.dart files found for $exampleName.');
        continue;
      }

      // Check files for known problematic patterns.
      testTargets
          .where((File file) => !_validateIntegrationTest(file))
          .forEach((File file) {
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
        Process? chromedriver;
        if (getBoolArg(_chromeDriverFlag)) {
          print('Starting chromedriver on port $_chromeDriverPort');
          chromedriver = await processRunner
              .start('chromedriver', <String>['--port=$_chromeDriverPort']);
        }
        for (final File driver in drivers) {
          final List<File> failingTargets = await _driveTests(
            example,
            driver,
            testTargets,
            deviceFlags: deviceFlags,
            exampleName: exampleName,
          );
          for (final File failingTarget in failingTargets) {
            errors.add(
                getRelativePosixPath(failingTarget, from: package.directory));
          }
        }
        if (chromedriver != null) {
          print('Stopping chromedriver');
          chromedriver.kill();
        }
      } else {
        if (!await _runTests(example,
            deviceFlags: deviceFlags, testFiles: testTargets)) {
          errors.add('Integration tests failed.');
        }
      }
    }
    if (!testsRan) {
      // It is an error for a plugin not to have integration tests, because that
      // is the only way to test the method channel communication.
      if (isPlugin) {
        printError(
            'No driver tests were run ($examplesFound example(s) found).');
        errors.add('No tests ran (use --exclude if this is intentional).');
      } else {
        return PackageResult.skip(supportedExamplesFound == 0
            ? 'No example supports requested platform(s).'
            : 'No example is configured for integration tests.');
      }
    }
    return errors.isEmpty
        ? PackageResult.success()
        : PackageResult.fail(errors);
  }

  /// Returns the device flags for the intersection of the requested platforms
  /// and the platforms supported by [example].
  List<String> _deviceFlagsForExample(RepositoryPackage example) {
    final List<String> deviceFlags = <String>[];
    for (final MapEntry<String, List<String>> entry
        in _targetDeviceFlags.entries) {
      final String platform = entry.key;
      if (example.appSupportsPlatform(getPlatformByName(platform))) {
        deviceFlags.addAll(entry.value);
      } else {
        final String exampleName =
            getRelativePosixPath(example.directory, from: packagesDir);
        print('Skipping unsupported platform $platform for $exampleName');
      }
    }
    return deviceFlags;
  }

  Future<List<String>> _getDevicesForPlatform(String platform) async {
    final List<String> deviceIds = <String>[];

    final ProcessResult result = await processRunner.run(
        flutterCommand, <String>['devices', '--machine'],
        stdoutEncoding: utf8);
    if (result.exitCode != 0) {
      return deviceIds;
    }

    String output = result.stdout as String;
    // --machine doesn't currently prevent the tool from printing banners;
    // see https://github.com/flutter/flutter/issues/86055. This workaround
    // can be removed once that is fixed.
    output = output.substring(output.indexOf('['));

    final List<Map<String, dynamic>> devices =
        (jsonDecode(output) as List<dynamic>).cast<Map<String, dynamic>>();
    for (final Map<String, dynamic> deviceInfo in devices) {
      final String targetPlatform =
          (deviceInfo['targetPlatform'] as String?) ?? '';
      if (targetPlatform.startsWith(platform)) {
        final String? deviceId = deviceInfo['id'] as String?;
        if (deviceId != null) {
          deviceIds.add(deviceId);
        }
      }
    }
    return deviceIds;
  }

  Future<List<File>> _getDrivers(RepositoryPackage example) async {
    final List<File> drivers = <File>[];

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
    final List<File> tests = <File>[];
    final Directory integrationTestDir =
        example.directory.childDirectory('integration_test');

    if (integrationTestDir.existsSync()) {
      await for (final FileSystemEntity file
          in integrationTestDir.list(recursive: true)) {
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

    final RegExp badTestPattern = RegExp(r'\s*test\(');
    if (lines.any((String line) => line.startsWith(badTestPattern))) {
      final String filename = testFile.basename;
      printError(
          '$filename uses "test", which will not report failures correctly. '
          'Use testWidgets instead.');
      return false;
    }

    return true;
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
    final List<File> failures = <File>[];

    final String enableExperiment = getStringArg(kEnableExperiment);
    final String screenshotBasename =
        '${exampleName.replaceAll(platform.pathSeparator, '_')}-drive';
    final Directory? screenshotDirectory =
        ciLogsDirectory(platform, driver.fileSystem)
            ?.childDirectory(screenshotBasename);

    for (final File target in targets) {
      final int exitCode = await processRunner.runAndStream(
          flutterCommand,
          <String>[
            'drive',
            ...deviceFlags,
            if (enableExperiment.isNotEmpty)
              '--enable-experiment=$enableExperiment',
            if (screenshotDirectory != null)
              '--screenshot=${screenshotDirectory.path}',
            '--driver',
            getRelativePosixPath(driver, from: example.directory),
            '--target',
            getRelativePosixPath(target, from: example.directory),
          ],
          workingDir: example.directory);
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
    final Directory? logsDirectory =
        ciLogsDirectory(platform, testFiles.first.fileSystem);

    // Workaround for https://github.com/flutter/flutter/issues/135673
    // Once that is fixed on stable, this logic can be removed and the command
    // can always just be run with "integration_test".
    final bool needsMultipleInvocations = testFiles.length > 1 &&
        (getBoolArg(platformLinux) ||
            getBoolArg(platformMacOS) ||
            getBoolArg(platformWindows));
    final Iterable<String> individualRunTargets = needsMultipleInvocations
        ? testFiles
            .map((File f) => getRelativePosixPath(f, from: example.directory))
        : <String>['integration_test'];

    bool passed = true;
    for (final String target in individualRunTargets) {
      final Timer timeoutTimer = Timer(const Duration(minutes: 10), () async {
        final String screenshotBasename =
            'test-timeout-screenshot_${target.replaceAll(platform.pathSeparator, '_')}.png';
        printWarning(
            'Test is taking a long time, taking screenshot $screenshotBasename...');
        await processRunner.runAndStream(
          flutterCommand,
          <String>[
            'screenshot',
            ...deviceFlags,
            if (logsDirectory != null)
              '--out=${logsDirectory.childFile(screenshotBasename).path}',
          ],
          workingDir: example.directory,
        );
      });
      final int exitCode = await processRunner.runAndStream(
        flutterCommand,
        <String>[
          'test',
          ...deviceFlags,
          if (enableExperiment.isNotEmpty)
            '--enable-experiment=$enableExperiment',
          if (logsDirectory != null) '--debug-logs-dir=${logsDirectory.path}',
          target,
        ],
        workingDir: example.directory,
      );

      timeoutTimer.cancel();
      passed = passed && (exitCode == 0);
    }
    return passed;
  }
}
