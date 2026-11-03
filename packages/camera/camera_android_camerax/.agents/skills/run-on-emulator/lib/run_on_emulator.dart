// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' show Platform, Process, ProcessException, ProcessResult, ProcessStartMode, stdout;
import 'dart:math' show max;

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:process/process.dart';

/// Exit codes returned by the run-on-emulator tool.
///
/// Each failure category has a distinct code so that callers can branch on
/// the result deterministically.
abstract final class ExitCodes {
  /// Every requested step succeeded.
  static const int success = 0;

  /// The Android CLI (`android`) is not installed or is not the Android CLI.
  static const int androidCliMissing = 2;

  /// Another required tool (`adb` or `flutter`) is missing.
  static const int toolMissing = 3;

  /// No usable Android Virtual Device (AVD) is available.
  static const int avdUnavailable = 4;

  /// The emulator failed to start or boot.
  static const int emulatorFailed = 5;

  /// The example app failed to build, install, or launch.
  static const int appFailed = 6;

  /// The integration tests failed, timed out, or could not be started.
  static const int testsFailed = 7;

  /// The tool was invoked with invalid arguments.
  static const int usage = 64;
}

/// The application ID of the camera_android_camerax example app.
const String exampleAppId = 'io.flutter.plugins.cameraxexample';

/// The integration test file run by default, relative to `example/`.
const String defaultIntegrationTestTarget = 'integration_test/integration_test.dart';

/// The commands supported by the run-on-emulator tool.
enum RunMode {
  /// Only verify that the required tools are installed.
  check('check'),

  /// Verify tools and ensure an emulator is booted.
  emulator('emulator'),

  /// Verify tools, boot an emulator, and build, install, and launch the
  /// example app.
  app('app'),

  /// Verify tools, boot an emulator, and run the example app's integration
  /// tests.
  integrationTest('integration-test');

  const RunMode(this.cliName);

  /// The name used to select this mode on the command line.
  final String cliName;

  /// Whether this mode exercises the camera and therefore needs an AVD with
  /// at least one emulated camera.
  bool get usesCamera => this == app || this == integrationTest;

  /// Whether this mode needs the `flutter` tool.
  bool get usesFlutter => usesCamera;
}

/// Options controlling a run of the tool.
class RunOptions {
  /// Creates a new set of options.
  const RunOptions({
    required this.mode,
    this.avd,
    this.target = defaultIntegrationTestTarget,
    this.plainName,
    this.bootTimeout = defaultBootTimeout,
    this.testTimeout = defaultTestTimeout,
    this.stopEmulator = false,
    this.allowNoCamera = false,
    this.headless = false,
  });

  /// Parses command line [args].
  ///
  /// Throws a [FormatException] if the arguments are invalid.
  factory RunOptions.parse(List<String> args) {
    final RunMode mode = _parseMode(args);
    final Map<String, String?> flags = _parseFlags(args);
    return RunOptions(
      mode: mode,
      avd: flags['avd'],
      target: flags['target'] ?? defaultIntegrationTestTarget,
      plainName: flags['plain-name'],
      bootTimeout: _parseDuration(flags, 'boot-timeout', defaultBootTimeout),
      testTimeout: _parseDuration(flags, 'test-timeout', defaultTestTimeout),
      stopEmulator: flags.containsKey('stop-emulator'),
      allowNoCamera: flags.containsKey('allow-no-camera'),
      headless: flags.containsKey('headless'),
    );
  }

  /// Default time allowed for an emulator to start and finish booting.
  static const Duration defaultBootTimeout = Duration(minutes: 5);

  /// Default time allowed for the integration tests to finish.
  ///
  /// This guards against hangs, e.g. from a system dialog blocking the app.
  static const Duration defaultTestTimeout = Duration(minutes: 30);

  /// Usage text for the command line tool.
  static const String usage =
      '''
Usage: dart run .agents/skills/run-on-emulator/tool/run.dart <command> [options]

Commands:
  check              Verify that the Android CLI, adb, and flutter are installed.
  emulator           check + ensure an emulator is running and booted.
  app                emulator + build, install, and launch the example app.
  integration-test   emulator + run the example app's integration tests.

Options:
  --avd=<id>             AVD to use. Defaults to the running emulator, or the
                         first AVD from `android emulator list`.
  --target=<path>        Integration test file, relative to example/.
                         Defaults to $defaultIntegrationTestTarget.
  --plain-name=<name>    Only run integration tests whose name contains <name>.
  --boot-timeout=<sec>   Seconds to wait for the emulator to boot (default 300).
  --test-timeout=<sec>   Seconds to wait for integration tests (default 1800).
  --stop-emulator        Stop the emulator afterwards if this tool started it.
  --allow-no-camera      Warn instead of failing if the AVD has no camera.
  --headless             Start the emulator without a window.
  --help                 Show this message.

Exit codes:
  0 success, 2 Android CLI missing, 3 adb/flutter missing, 4 no usable AVD,
  5 emulator failed to boot, 6 app failed, 7 integration tests failed,
  64 usage error.''';

  static const Set<String> _valueFlags = <String>{
    'avd',
    'target',
    'plain-name',
    'boot-timeout',
    'test-timeout',
  };
  static const Set<String> _boolFlags = <String>{'stop-emulator', 'allow-no-camera', 'headless'};

  /// The command to run.
  final RunMode mode;

  /// The AVD ID to use, if one was requested explicitly.
  final String? avd;

  /// The integration test file to run, relative to the example directory.
  final String target;

  /// If set, only integration tests whose name contains this are run.
  final String? plainName;

  /// Time allowed for an emulator to start and finish booting.
  final Duration bootTimeout;

  /// Time allowed for the integration tests to finish.
  final Duration testTimeout;

  /// Whether to stop the emulator at the end if this tool started it.
  final bool stopEmulator;

  /// Whether to continue (with a warning) when the AVD has no camera.
  final bool allowNoCamera;

  /// Whether to start the emulator without a window.
  final bool headless;

  static RunMode _parseMode(List<String> args) {
    final List<String> positional = args.where((String a) => !a.startsWith('--')).toList();
    if (positional.length != 1) {
      throw FormatException('Expected exactly one command, got: ${positional.join(' ')}');
    }
    return RunMode.values.firstWhere(
      (RunMode m) => m.cliName == positional.single,
      orElse: () => throw FormatException('Unknown command "${positional.single}".'),
    );
  }

  static Map<String, String?> _parseFlags(List<String> args) {
    final flags = <String, String?>{};
    for (final String arg in args.where((String a) => a.startsWith('--'))) {
      final int eq = arg.indexOf('=');
      final String name = eq == -1 ? arg.substring(2) : arg.substring(2, eq);
      final String? value = eq == -1 ? null : arg.substring(eq + 1);
      if (_valueFlags.contains(name)) {
        if (value == null || value.isEmpty) {
          throw FormatException('Option "--$name" requires a value (--$name=<value>).');
        }
      } else if (_boolFlags.contains(name)) {
        if (value != null) {
          throw FormatException('Option "--$name" does not take a value.');
        }
      } else {
        throw FormatException('Unknown option "--$name".');
      }
      flags[name] = value;
    }
    return flags;
  }

  static Duration _parseDuration(Map<String, String?> flags, String name, Duration fallback) {
    final String? value = flags[name];
    if (value == null) {
      return fallback;
    }
    final int? seconds = int.tryParse(value);
    if (seconds == null || seconds <= 0) {
      throw FormatException('Option "--$name" must be a positive number of seconds.');
    }
    return Duration(seconds: seconds);
  }
}

/// Instructions shown when the Android CLI is not available.
const String androidCliInstallInstructions = '''
Install the Android CLI from https://developer.android.com/tools/agents, make
sure the `android` executable is on your PATH (verify with `which android`),
then run `android update` to get the latest version.''';

/// The oldest supported Android CLI version.
///
/// 1.1 added `--install-options` to `android install`, `--device` to
/// `android screen capture`, and `android input`, which this skill relies on.
const String minimumAndroidCliVersion = '1.1.0';

/// Thrown internally to abort a run with a specific exit code.
class _StepFailure implements Exception {
  _StepFailure(this.exitCode, this.message);

  final int exitCode;
  final String message;
}

/// A running emulator.
class _Emulator {
  _Emulator(this.serial, this.avd, {required this.startedByTool});

  final String serial;
  final String avd;
  final bool startedByTool;
}

/// Launches an emulator and runs the camera_android_camerax example app or
/// its integration tests on it.
class EmulatorRunner {
  /// Creates a new runner.
  ///
  /// All parameters are injectable for testing.
  EmulatorRunner({
    FileSystem? fileSystem,
    ProcessManager? processManager,
    Map<String, String>? environment,
    void Function(String)? log,
    Future<void> Function(Duration)? delay,
    this.pollInterval = const Duration(seconds: 2),
    this.buildTimeout = const Duration(minutes: 15),
  }) : _fs = fileSystem ?? const LocalFileSystem(),
       _processManager = processManager ?? const LocalProcessManager(),
       _environment = environment ?? Platform.environment,
       _log = log ?? stdout.writeln,
       _delay = delay ?? Future<void>.delayed;

  final FileSystem _fs;
  final ProcessManager _processManager;
  final Map<String, String> _environment;
  final void Function(String) _log;
  final Future<void> Function(Duration) _delay;

  /// How often to poll the emulator while waiting for it to boot.
  final Duration pollInterval;

  /// Time allowed for `flutter build apk` to finish.
  final Duration buildTimeout;

  /// Runs the tool with [options] for the package at [packageRoot].
  ///
  /// Returns one of the [ExitCodes].
  Future<int> run(RunOptions options, {required String packageRoot}) async {
    try {
      final String summary = await _run(options, packageRoot);
      _log('RESULT: SUCCESS $summary');
      return ExitCodes.success;
    } on _StepFailure catch (failure) {
      _log('ERROR: ${failure.message}');
      _log('RESULT: FAILED (exit code ${failure.exitCode})');
      return failure.exitCode;
    }
  }

  Future<String> _run(RunOptions options, String packageRoot) async {
    final String exampleDir = _fs.path.join(packageRoot, 'example');
    _validateTarget(options, exampleDir);

    _step('Checking that the Android CLI is installed');
    await _checkAndroidCli();
    _step('Checking for adb${options.mode.usesFlutter ? ' and flutter' : ''}');
    final String adb = await _resolveAdb();
    if (options.mode.usesFlutter) {
      _requireTool('flutter', 'Install Flutter and add it to your PATH.');
    }
    if (options.mode == RunMode.check) {
      return 'mode=check';
    }

    final _Emulator emulator = await _ensureEmulator(adb, options);
    try {
      if (options.mode == RunMode.app) {
        await _launchApp(adb, emulator.serial, exampleDir);
      } else if (options.mode == RunMode.integrationTest) {
        await _runIntegrationTests(adb, emulator.serial, exampleDir, options);
      }
    } finally {
      if (options.stopEmulator && emulator.startedByTool) {
        await _stopEmulator(emulator.serial);
      }
    }
    return 'mode=${options.mode.cliName} serial=${emulator.serial} avd=${emulator.avd}';
  }

  void _validateTarget(RunOptions options, String exampleDir) {
    if (options.mode != RunMode.integrationTest) {
      return;
    }
    final String targetPath = _fs.path.join(exampleDir, options.target);
    if (!_fs.file(targetPath).existsSync()) {
      throw _StepFailure(
        ExitCodes.usage,
        'Integration test target "${options.target}" does not exist in example/.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Tool checks.
  // ---------------------------------------------------------------------------

  Future<void> _checkAndroidCli() async {
    if (!_processManager.canRun('android')) {
      throw _StepFailure(
        ExitCodes.androidCliMissing,
        'The Android CLI (`android`) is not on the PATH.\n$androidCliInstallInstructions',
      );
    }
    // The legacy Android SDK also shipped an `android` executable, which does
    // not report a version, so this also rejects it.
    final ProcessResult result = await _runCommand(<String>['android', '--version']);
    final String version = _stdout(result);
    final List<int>? parsed = result.exitCode == 0 ? parseVersion(version) : null;
    if (parsed == null) {
      throw _StepFailure(
        ExitCodes.androidCliMissing,
        'An `android` executable is on the PATH, but `android --version` did not report a '
        'version. It may be the legacy Android SDK tool rather than the Android CLI.\n'
        '$androidCliInstallInstructions',
      );
    }
    if (compareVersions(parsed, parseVersion(minimumAndroidCliVersion)!) < 0) {
      throw _StepFailure(
        ExitCodes.androidCliMissing,
        'Android CLI $version is older than the required $minimumAndroidCliVersion. '
        'Run `android update`, then re-run.',
      );
    }
    _log('Android CLI is installed (version $version).');
  }

  Future<String> _resolveAdb() async {
    final ProcessResult info = await _runCommand(<String>['android', 'info', 'sdk']);
    final String sdkPath = info.exitCode == 0 ? _stdout(info) : '';
    if (sdkPath.isNotEmpty) {
      final adbName = _fs.path.separator == r'\' ? 'adb.exe' : 'adb';
      final String candidate = _fs.path.join(sdkPath, 'platform-tools', adbName);
      if (_fs.file(candidate).existsSync()) {
        _log('Using adb from the Android SDK: $candidate');
        return candidate;
      }
    }
    _requireTool(
      'adb',
      'Install it with `android sdk install platform-tools`, or add the SDK '
          'platform-tools directory to your PATH.',
    );
    _log('Using adb from the PATH.');
    return 'adb';
  }

  void _requireTool(String tool, String instructions) {
    if (!_processManager.canRun(tool)) {
      throw _StepFailure(ExitCodes.toolMissing, '`$tool` was not found. $instructions');
    }
  }

  // ---------------------------------------------------------------------------
  // Emulator management.
  // ---------------------------------------------------------------------------

  Future<_Emulator> _ensureEmulator(String adb, RunOptions options) async {
    _step('Looking for a running emulator');
    final _Emulator? running = await _findRunningEmulator(adb, options.avd);
    if (running != null) {
      _log('Reusing running emulator ${running.serial} (AVD: ${running.avd}).');
      _checkCamera(running.avd, options);
      await _waitForBoot(adb, running.serial, options.bootTimeout);
      return running;
    }

    final String avd = await _selectAvd(options.avd);
    _checkCamera(avd, options);
    _step('Starting emulator "$avd" (this can take a few minutes)');
    final int? code = await _stream(<String>[
      'android',
      'emulator',
      'start',
      if (options.headless) '--headless',
      avd,
    ], timeout: options.bootTimeout);
    if (code != 0) {
      throw _StepFailure(
        ExitCodes.emulatorFailed,
        code == null
            ? '`android emulator start $avd` did not finish within '
                  '${options.bootTimeout.inSeconds}s.'
            : '`android emulator start $avd` failed with exit code $code. '
                  'Try `android emulator start --cold $avd` to bypass a corrupt snapshot.',
      );
    }
    final _Emulator? started = await _findRunningEmulator(adb, avd);
    if (started == null) {
      throw _StepFailure(
        ExitCodes.emulatorFailed,
        'Emulator "$avd" reported that it started, but adb cannot see it. '
        'Check `$adb devices`.',
      );
    }
    await _waitForBoot(adb, started.serial, options.bootTimeout);
    return _Emulator(started.serial, avd, startedByTool: true);
  }

  Future<_Emulator?> _findRunningEmulator(String adb, String? requestedAvd) async {
    final ProcessResult devices = await _runCommand(<String>[adb, 'devices']);
    if (devices.exitCode != 0) {
      throw _StepFailure(ExitCodes.emulatorFailed, '`adb devices` failed: ${devices.stderr}');
    }
    for (final String serial in parseEmulatorSerials(_stdout(devices))) {
      final ProcessResult name = await _runCommand(<String>[
        adb,
        '-s',
        serial,
        'emu',
        'avd',
        'name',
      ]);
      final String avd = name.exitCode == 0 ? _stdout(name).split('\n').first.trim() : 'unknown';
      if (requestedAvd == null || avd == requestedAvd) {
        return _Emulator(serial, avd, startedByTool: false);
      }
    }
    return null;
  }

  Future<String> _selectAvd(String? requestedAvd) async {
    _step('Selecting an AVD');
    final ProcessResult list = await _runCommand(<String>['android', 'emulator', 'list']);
    if (list.exitCode != 0) {
      throw _StepFailure(
        ExitCodes.avdUnavailable,
        '`android emulator list` failed: ${list.stderr}',
      );
    }
    final List<String> avds = parseAvdList(_stdout(list));
    if (avds.isEmpty) {
      throw _StepFailure(
        ExitCodes.avdUnavailable,
        'No AVDs found. Create one with `android emulator create medium_phone` '
        '(see `android emulator create --list-profiles`), then re-run.',
      );
    }
    if (requestedAvd != null && !avds.contains(requestedAvd)) {
      throw _StepFailure(
        ExitCodes.avdUnavailable,
        'AVD "$requestedAvd" not found. Available AVDs: ${avds.join(', ')}.',
      );
    }
    final String avd = requestedAvd ?? avds.first;
    _log('Selected AVD "$avd" (available: ${avds.join(', ')}).');
    return avd;
  }

  Future<void> _waitForBoot(String adb, String serial, Duration timeout) async {
    final int attempts = max(1, timeout.inMilliseconds ~/ pollInterval.inMilliseconds);
    for (var i = 0; i < attempts; i++) {
      final ProcessResult result = await _runCommand(<String>[
        adb,
        '-s',
        serial,
        'shell',
        'getprop',
        'sys.boot_completed',
      ]);
      if (result.exitCode == 0 && _stdout(result) == '1') {
        _log('Emulator $serial has finished booting.');
        return;
      }
      await _delay(pollInterval);
    }
    throw _StepFailure(
      ExitCodes.emulatorFailed,
      'Emulator $serial did not finish booting within ${timeout.inSeconds}s.',
    );
  }

  Future<void> _stopEmulator(String serial) async {
    _step('Stopping emulator $serial');
    final ProcessResult result = await _runCommand(<String>['android', 'emulator', 'stop', serial]);
    if (result.exitCode != 0) {
      _log('WARNING: Failed to stop emulator $serial: ${result.stderr}');
    }
  }

  // ---------------------------------------------------------------------------
  // AVD camera configuration.
  // ---------------------------------------------------------------------------

  void _checkCamera(String avd, RunOptions options) {
    if (!options.mode.usesCamera) {
      return;
    }
    final String? configPath = _findAvdConfig(avd);
    if (configPath == null) {
      _log('WARNING: Could not find config.ini for AVD "$avd"; unable to verify it has a camera.');
      return;
    }
    final Map<String, String> config = parseIni(_fs.file(configPath).readAsStringSync());
    // Defaults match the emulator's hardware-properties.ini.
    final String back = config['hw.camera.back'] ?? 'emulated';
    final String front = config['hw.camera.front'] ?? 'none';
    _log('AVD "$avd" cameras: back=$back, front=$front.');
    if (back != 'none' || front != 'none') {
      return;
    }
    final message =
        'AVD "$avd" has no cameras, so the example app cannot show a preview and '
        'camera integration tests would pass vacuously. Set '
        'hw.camera.back=virtualscene and hw.camera.front=emulated in $configPath '
        '(with the emulator stopped), choose another AVD with --avd, or pass '
        '--allow-no-camera.';
    if (!options.allowNoCamera) {
      throw _StepFailure(ExitCodes.avdUnavailable, message);
    }
    _log('WARNING: $message');
  }

  String? _findAvdConfig(String avd) {
    final String? avdHome = _avdHome();
    if (avdHome == null) {
      return null;
    }
    String avdDir = _fs.path.join(avdHome, '$avd.avd');
    final File avdIni = _fs.file(_fs.path.join(avdHome, '$avd.ini'));
    if (avdIni.existsSync()) {
      final String? path = parseIni(avdIni.readAsStringSync())['path'];
      if (path != null && _fs.directory(path).existsSync()) {
        avdDir = path;
      }
    }
    final String configPath = _fs.path.join(avdDir, 'config.ini');
    return _fs.file(configPath).existsSync() ? configPath : null;
  }

  String? _avdHome() {
    final String? avdHome = _environment['ANDROID_AVD_HOME'];
    if (avdHome != null && avdHome.isNotEmpty) {
      return avdHome;
    }
    final String? userHome = _environment['ANDROID_USER_HOME'];
    if (userHome != null && userHome.isNotEmpty) {
      return _fs.path.join(userHome, 'avd');
    }
    final String? home = _environment['HOME'] ?? _environment['USERPROFILE'];
    return home == null ? null : _fs.path.join(home, '.android', 'avd');
  }

  // ---------------------------------------------------------------------------
  // Example app and integration tests.
  // ---------------------------------------------------------------------------

  Future<void> _launchApp(String adb, String serial, String exampleDir) async {
    await _buildAndInstall(serial, exampleDir, 'lib/main.dart', ExitCodes.appFailed);

    _step('Launching the example app');
    final ProcessResult start = await _runCommand(<String>[
      adb,
      '-s',
      serial,
      'shell',
      'am',
      'start',
      '-W',
      '-n',
      '$exampleAppId/.MainActivity',
    ]);
    if (start.exitCode != 0 || _stdout(start).contains('Error')) {
      throw _StepFailure(
        ExitCodes.appFailed,
        'Failed to launch the example app: ${_stdout(start)} ${start.stderr}',
      );
    }

    // Give the app a moment to crash if it is going to, then check it is alive.
    await _delay(pollInterval);
    final ProcessResult pid = await _runCommand(<String>[
      adb,
      '-s',
      serial,
      'shell',
      'pidof',
      exampleAppId,
    ]);
    if (pid.exitCode != 0 || _stdout(pid).isEmpty) {
      throw _StepFailure(
        ExitCodes.appFailed,
        'The example app is not running after launch (it likely crashed). '
        'Inspect the crash with `$adb -s $serial logcat -d -b crash`.',
      );
    }
    _log('Example app is running on $serial (pid ${_stdout(pid)}).');
  }

  Future<void> _runIntegrationTests(
    String adb,
    String serial,
    String exampleDir,
    RunOptions options,
  ) async {
    // Without pre-granted permissions, the camera permission dialog blocks the
    // tests indefinitely (https://github.com/flutter/flutter/issues/130987).
    // `flutter test` reinstalls the app with `adb install -r`, which preserves
    // runtime permission grants made here.
    await _buildAndInstall(serial, exampleDir, options.target, ExitCodes.testsFailed);

    _step('Running integration tests (${options.target})');
    final int? code = await _stream(
      <String>[
        'flutter',
        'test',
        options.target,
        '-d',
        serial,
        if (options.plainName != null) ...<String>['--plain-name', options.plainName!],
      ],
      workingDirectory: exampleDir,
      timeout: options.testTimeout,
    );
    if (code == null) {
      throw _StepFailure(
        ExitCodes.testsFailed,
        'Integration tests did not finish within ${options.testTimeout.inSeconds}s. '
        'A system dialog may be blocking the app; inspect the screen with '
        '`android screen capture --annotate -o <file>.png`.',
      );
    }
    if (code != 0) {
      throw _StepFailure(
        ExitCodes.testsFailed,
        'Integration tests failed (exit code $code). See the output above.',
      );
    }
    _log('Integration tests passed.');
  }

  Future<void> _buildAndInstall(
    String serial,
    String exampleDir,
    String target,
    int failureCode,
  ) async {
    _step('Building the example app (target: $target)');
    final int? code = await _stream(
      <String>['flutter', 'build', 'apk', '--debug', '--target=$target'],
      workingDirectory: exampleDir,
      timeout: buildTimeout,
    );
    if (code != 0) {
      throw _StepFailure(
        failureCode,
        code == null
            ? '`flutter build apk` did not finish within ${buildTimeout.inMinutes} minutes.'
            : '`flutter build apk` failed with exit code $code. See the output above.',
      );
    }
    final String apk = _fs.path.join(
      exampleDir,
      'build',
      'app',
      'outputs',
      'flutter-apk',
      'app-debug.apk',
    );
    if (!_fs.file(apk).existsSync()) {
      throw _StepFailure(failureCode, 'Expected a debug APK at $apk, but none was found.');
    }

    _step('Installing the example app with runtime permissions granted');
    final ProcessResult install = await _runCommand(<String>[
      'android',
      'install',
      '--apks=$apk',
      '--device=$serial',
      '--install-options=-g',
    ]);
    // The package manager can report a failure without a non-zero exit code,
    // so also check the output.
    if (install.exitCode != 0 || RegExp('^Failure', multiLine: true).hasMatch(_stdout(install))) {
      throw _StepFailure(
        failureCode,
        'Failed to install $apk: ${_stdout(install)} ${install.stderr}',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Process helpers.
  // ---------------------------------------------------------------------------

  void _step(String description) => _log('==> $description...');

  Future<ProcessResult> _runCommand(List<String> command) async {
    try {
      return await _processManager.run(command);
    } on ProcessException catch (e) {
      return ProcessResult(0, -1, '', e.toString());
    }
  }

  /// Runs [command] with its output streamed to this process's stdio.
  ///
  /// Returns the exit code, or `null` if [timeout] elapsed first (in which case
  /// the process is killed).
  Future<int?> _stream(
    List<String> command, {
    String? workingDirectory,
    required Duration timeout,
  }) async {
    _log('\$ ${command.join(' ')}');
    final Process process;
    try {
      process = await _processManager.start(
        command,
        workingDirectory: workingDirectory,
        mode: ProcessStartMode.inheritStdio,
      );
    } on ProcessException catch (e) {
      _log('ERROR: Failed to start `${command.first}`: $e');
      return -1;
    }
    return process.exitCode
        .then<int?>((int code) => code)
        .timeout(
          timeout,
          onTimeout: () {
            process.kill();
            return null;
          },
        );
  }

  static String _stdout(ProcessResult result) => (result.stdout as String).trim();
}

/// Returns the serials of emulators listed in `adb devices` [output].
///
/// Emulators that are still `offline` (e.g. booting) are included.
List<String> parseEmulatorSerials(String output) {
  final pattern = RegExp(r'^(emulator-\d+)\s+(device|offline)\s*$', multiLine: true);
  return pattern.allMatches(output).map((RegExpMatch m) => m.group(1)!).toList();
}

/// Returns the AVD IDs listed in `android emulator list` [output].
List<String> parseAvdList(String output) {
  return output
      .split('\n')
      .map((String line) => line.trim())
      .where((String line) => line.isNotEmpty && !line.startsWith('AVD ID'))
      .map((String line) => line.split(RegExp(r'\s+')).first)
      .toList();
}

/// Parses `key=value` lines, such as those in an AVD's config.ini.
Map<String, String> parseIni(String contents) {
  final values = <String, String>{};
  for (final String line in contents.split('\n')) {
    final int eq = line.indexOf('=');
    if (eq > 0) {
      values[line.substring(0, eq).trim()] = line.substring(eq + 1).trim();
    }
  }
  return values;
}

/// Parses the leading `major.minor.patch` of [version], or returns `null`.
List<int>? parseVersion(String version) {
  final RegExpMatch? match = RegExp(r'^(\d+)\.(\d+)\.(\d+)').firstMatch(version.trim());
  if (match == null) {
    return null;
  }
  return <int>[for (var i = 1; i <= 3; i++) int.parse(match.group(i)!)];
}

/// Compares two versions parsed by [parseVersion].
///
/// Returns a negative number if [a] is older than [b], zero if they are equal,
/// and a positive number otherwise.
int compareVersions(List<int> a, List<int> b) {
  for (var i = 0; i < 3; i++) {
    if (a[i] != b[i]) {
      return a[i] - b[i];
    }
  }
  return 0;
}
