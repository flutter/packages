// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file/memory.dart';
import 'package:process/process.dart';
import 'package:run_on_emulator/run_on_emulator.dart';
import 'package:test/test.dart';

/// A fake [Process] whose exit code is controlled by the test.
class FakeProcess implements Process {
  FakeProcess(this._exitCode);

  final Future<int> _exitCode;
  bool killed = false;

  @override
  Future<int> get exitCode => _exitCode;

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    killed = true;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeProcessManager implements ProcessManager {
  final Set<String> missingExecutables = <String>{};

  /// Responses for [run], keyed by the space-joined command.
  final Map<String, ProcessResult Function()> runResponses = <String, ProcessResult Function()>{};

  /// Exit codes for [start], keyed by the space-joined command. A `null`
  /// value means the process never exits.
  final Map<String, int?> startExitCodes = <String, int?>{};

  /// Callbacks invoked when a command is started, keyed by the space-joined
  /// command.
  final Map<String, void Function()> onStart = <String, void Function()>{};

  final List<String> invocations = <String>[];
  final List<FakeProcess> startedProcesses = <FakeProcess>[];

  @override
  bool canRun(dynamic executable, {String? workingDirectory}) =>
      !missingExecutables.contains(executable as String);

  @override
  Future<ProcessResult> run(
    List<dynamic> command, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    Encoding? stdoutEncoding = systemEncoding,
    Encoding? stderrEncoding = systemEncoding,
  }) async {
    final String key = command.join(' ');
    invocations.add(key);
    return runResponses[key]?.call() ?? ProcessResult(0, 0, '', '');
  }

  @override
  Future<Process> start(
    List<dynamic> command, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    ProcessStartMode mode = ProcessStartMode.normal,
  }) async {
    final String key = command.join(' ');
    invocations.add(key);
    onStart[key]?.call();
    final int? code = startExitCodes.containsKey(key) ? startExitCodes[key] : 0;
    final process = FakeProcess(code == null ? Completer<int>().future : Future<int>.value(code));
    startedProcesses.add(process);
    return process;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ProcessResult ok([String stdout = '']) => ProcessResult(0, 0, stdout, '');
ProcessResult fail([String stderr = 'failed']) => ProcessResult(0, 1, '', stderr);

const String packageRoot = '/workspace/camera_android_camerax';
const String exampleDir = '$packageRoot/example';
const String adb = '/sdk/platform-tools/adb';
const String apk = '$exampleDir/build/app/outputs/flutter-apk/app-debug.apk';
const String avdHome = '/home/.android/avd';
const String serial = 'emulator-5554';

const String avdListOutput = '''
AVD ID                   AVD Name                      API Level      Status         Serial
Pixel_9                  Pixel 9                       android-36.1   Offline
Small_Phone              Small Phone                   android-35     Offline
''';

void main() {
  late MemoryFileSystem fileSystem;
  late FakeProcessManager processManager;
  late List<String> logs;
  late EmulatorRunner runner;

  void writeAvdConfig(String avd, String config) {
    fileSystem.file('$avdHome/$avd.ini')
      ..createSync(recursive: true)
      ..writeAsStringSync('path=$avdHome/$avd.avd\n');
    fileSystem.file('$avdHome/$avd.avd/config.ini')
      ..createSync(recursive: true)
      ..writeAsStringSync(config);
  }

  /// Makes `adb devices` report [serial] running the AVD [avd].
  void markEmulatorRunning(String avd) {
    processManager.runResponses['$adb devices'] = () =>
        ok('List of devices attached\n$serial\tdevice\n\n');
    processManager.runResponses['$adb -s $serial emu avd name'] = () => ok('$avd\r\nOK\r\n');
  }

  Future<int> runTool(List<String> args) =>
      runner.run(RunOptions.parse(args), packageRoot: packageRoot);

  bool logged(String substring) => logs.any((String line) => line.contains(substring));

  setUp(() {
    fileSystem = MemoryFileSystem.test();
    processManager = FakeProcessManager();
    logs = <String>[];
    runner = EmulatorRunner(
      fileSystem: fileSystem,
      processManager: processManager,
      environment: <String, String>{'HOME': '/home'},
      log: logs.add,
      delay: (Duration _) async {},
      pollInterval: const Duration(seconds: 1),
    );

    fileSystem.file(adb).createSync(recursive: true);
    fileSystem.file('$exampleDir/$defaultIntegrationTestTarget').createSync(recursive: true);
    fileSystem.file(apk).createSync(recursive: true);
    writeAvdConfig('Pixel_9', 'hw.camera.back=virtualscene\nhw.camera.front=emulated\n');

    processManager.runResponses['android --version'] = () => ok('1.1.16717390\n');
    processManager.runResponses['android info sdk'] = () => ok('/sdk\n');
    processManager.runResponses['android emulator list'] = () => ok(avdListOutput);
    processManager.runResponses['$adb devices'] = () => ok('List of devices attached\n\n');
    processManager.runResponses['$adb -s $serial shell getprop sys.boot_completed'] = () =>
        ok('1\n');
    processManager
        .runResponses['android install --apks=$apk --device=$serial --install-options=-g'] = () =>
        ok('Success\n');
    processManager.runResponses['$adb -s $serial shell pidof $exampleAppId'] = () => ok('1234\n');
    processManager.onStart['android emulator start Pixel_9'] = () => markEmulatorRunning('Pixel_9');
  });

  group('RunOptions.parse', () {
    test('uses defaults', () {
      final options = RunOptions.parse(<String>['integration-test']);
      expect(options.mode, RunMode.integrationTest);
      expect(options.avd, isNull);
      expect(options.target, defaultIntegrationTestTarget);
      expect(options.plainName, isNull);
      expect(options.bootTimeout, RunOptions.defaultBootTimeout);
      expect(options.testTimeout, RunOptions.defaultTestTimeout);
      expect(options.stopEmulator, isFalse);
      expect(options.allowNoCamera, isFalse);
    });

    test('parses all options', () {
      final options = RunOptions.parse(<String>[
        'app',
        '--avd=Pixel_9',
        '--target=integration_test/other.dart',
        '--plain-name=video',
        '--boot-timeout=60',
        '--test-timeout=120',
        '--stop-emulator',
        '--allow-no-camera',
      ]);
      expect(options.mode, RunMode.app);
      expect(options.avd, 'Pixel_9');
      expect(options.target, 'integration_test/other.dart');
      expect(options.plainName, 'video');
      expect(options.bootTimeout, const Duration(seconds: 60));
      expect(options.testTimeout, const Duration(seconds: 120));
      expect(options.stopEmulator, isTrue);
      expect(options.allowNoCamera, isTrue);
    });

    for (final args in <List<String>>[
      <String>[],
      <String>['app', 'emulator'],
      <String>['launch'],
      <String>['app', '--unknown'],
      <String>['app', '--avd'],
      <String>['app', '--avd='],
      <String>['app', '--stop-emulator=true'],
      <String>['app', '--boot-timeout=soon'],
      <String>['app', '--test-timeout=0'],
    ]) {
      test('rejects ${args.join(' ')}', () {
        expect(() => RunOptions.parse(args), throwsFormatException);
      });
    }
  });

  group('output parsers', () {
    test('parseEmulatorSerials returns online and offline emulators only', () {
      const output =
          'List of devices attached\n'
          'emulator-5554\tdevice\n'
          'emulator-5556\toffline\n'
          'R5CT1234\tdevice\n\n';
      expect(parseEmulatorSerials(output), <String>['emulator-5554', 'emulator-5556']);
    });

    test('parseAvdList returns AVD IDs and skips the header', () {
      expect(parseAvdList(avdListOutput), <String>['Pixel_9', 'Small_Phone']);
      expect(parseAvdList('AVD ID   AVD Name\n\n'), isEmpty);
    });

    test('parseAvdList handles the header-less format from Android CLI 1.1', () {
      expect(parseAvdList('Pixel_9\nSmall_Phone\n'), <String>['Pixel_9', 'Small_Phone']);
    });

    test('parseVersion parses major.minor.patch', () {
      expect(parseVersion('1.1.16717390\n'), <int>[1, 1, 16717390]);
      expect(parseVersion('The "android" command is deprecated.'), isNull);
    });

    test('compareVersions orders versions', () {
      expect(compareVersions(<int>[1, 0, 9], <int>[1, 1, 0]), isNegative);
      expect(compareVersions(<int>[1, 1, 0], <int>[1, 1, 0]), isZero);
      expect(compareVersions(<int>[2, 0, 0], <int>[1, 9, 9]), isPositive);
    });

    test('parseIni parses key/value pairs', () {
      expect(parseIni('a=1\nb = two \n#comment\n\n'), <String, String>{'a': '1', 'b': 'two'});
    });
  });

  group('check', () {
    test('fails with androidCliMissing when android is not on the PATH', () async {
      processManager.missingExecutables.add('android');

      expect(await runTool(<String>['check']), ExitCodes.androidCliMissing);
      expect(logged('developer.android.com/tools/agents'), isTrue);
      expect(processManager.invocations, isEmpty);
    });

    test('fails with androidCliMissing for a legacy android tool', () async {
      processManager.runResponses['android --version'] = () =>
          ok('The "android" command is deprecated and no longer supported.\n');

      expect(await runTool(<String>['check']), ExitCodes.androidCliMissing);
      expect(logged('legacy Android SDK'), isTrue);
    });

    test('fails with androidCliMissing when the Android CLI is too old', () async {
      processManager.runResponses['android --version'] = () => ok('1.0.15498356\n');

      expect(await runTool(<String>['check']), ExitCodes.androidCliMissing);
      expect(logged('Run `android update`'), isTrue);
    });

    test('fails with toolMissing when adb cannot be found', () async {
      fileSystem.file(adb).deleteSync();
      processManager.missingExecutables.add('adb');

      expect(await runTool(<String>['check']), ExitCodes.toolMissing);
      expect(logged('android sdk install platform-tools'), isTrue);
    });

    test('falls back to adb on the PATH', () async {
      fileSystem.file(adb).deleteSync();

      expect(await runTool(<String>['check']), ExitCodes.success);
      expect(logged('Using adb from the PATH.'), isTrue);
    });

    test('succeeds without touching any device', () async {
      expect(await runTool(<String>['check']), ExitCodes.success);
      expect(logged('RESULT: SUCCESS mode=check'), isTrue);
      expect(processManager.invocations.where((String c) => c.startsWith(adb)), isEmpty);
    });

    test('app mode fails with toolMissing when flutter is not on the PATH', () async {
      processManager.missingExecutables.add('flutter');

      expect(await runTool(<String>['app']), ExitCodes.toolMissing);
      expect(processManager.invocations, isNot(contains('$adb devices')));
    });
  });

  group('emulator', () {
    test('reuses a running emulator', () async {
      markEmulatorRunning('Pixel_9');

      expect(await runTool(<String>['emulator']), ExitCodes.success);
      expect(processManager.invocations, isNot(contains('android emulator start Pixel_9')));
      expect(logged('RESULT: SUCCESS mode=emulator serial=$serial avd=Pixel_9'), isTrue);
    });

    test('starts the first AVD when none is running', () async {
      expect(await runTool(<String>['emulator']), ExitCodes.success);
      expect(processManager.invocations, contains('android emulator start Pixel_9'));
    });

    test('--headless starts the emulator without a window', () async {
      processManager.onStart['android emulator start --headless Pixel_9'] = () =>
          markEmulatorRunning('Pixel_9');

      expect(await runTool(<String>['emulator', '--headless']), ExitCodes.success);
      expect(processManager.invocations, contains('android emulator start --headless Pixel_9'));
    });

    test('starts the requested AVD instead of an unrelated running one', () async {
      markEmulatorRunning('Pixel_9');
      processManager.onStart['android emulator start Small_Phone'] = () =>
          markEmulatorRunning('Small_Phone');

      expect(await runTool(<String>['emulator', '--avd=Small_Phone']), ExitCodes.success);
      expect(processManager.invocations, contains('android emulator start Small_Phone'));
    });

    test('fails with avdUnavailable when no AVDs exist', () async {
      processManager.runResponses['android emulator list'] = () => ok('AVD ID  AVD Name\n');

      expect(await runTool(<String>['emulator']), ExitCodes.avdUnavailable);
      expect(logged('android emulator create medium_phone'), isTrue);
    });

    test('fails with avdUnavailable when the requested AVD does not exist', () async {
      expect(await runTool(<String>['emulator', '--avd=Nope']), ExitCodes.avdUnavailable);
      expect(logged('Available AVDs: Pixel_9, Small_Phone'), isTrue);
    });

    test('fails with emulatorFailed when the emulator fails to start', () async {
      processManager.onStart.clear();
      processManager.startExitCodes['android emulator start Pixel_9'] = 1;

      expect(await runTool(<String>['emulator']), ExitCodes.emulatorFailed);
      expect(logged('--cold'), isTrue);
    });

    test('fails with emulatorFailed when the emulator start times out', () async {
      processManager.onStart.clear();
      processManager.startExitCodes['android emulator start Pixel_9'] = null;

      expect(await runTool(<String>['emulator', '--boot-timeout=1']), ExitCodes.emulatorFailed);
      expect(processManager.startedProcesses.single.killed, isTrue);
    });

    test('fails with emulatorFailed when the emulator never finishes booting', () async {
      processManager.runResponses['$adb -s $serial shell getprop sys.boot_completed'] = () =>
          ok('\n');

      expect(await runTool(<String>['emulator', '--boot-timeout=3']), ExitCodes.emulatorFailed);
      expect(
        processManager.invocations.where((String c) => c.endsWith('sys.boot_completed')),
        hasLength(3),
      );
    });

    test('does not check camera configuration', () async {
      writeAvdConfig('Pixel_9', 'hw.camera.back=none\nhw.camera.front=none\n');

      expect(await runTool(<String>['emulator']), ExitCodes.success);
    });
  });

  group('camera configuration', () {
    test('fails with avdUnavailable before booting an AVD without cameras', () async {
      writeAvdConfig('Pixel_9', 'hw.camera.back=none\nhw.camera.front=none\n');

      expect(await runTool(<String>['integration-test']), ExitCodes.avdUnavailable);
      expect(logged('hw.camera.back=virtualscene'), isTrue);
      expect(processManager.invocations, isNot(contains('android emulator start Pixel_9')));
    });

    test('treats a missing hw.camera.back as the emulated default', () async {
      writeAvdConfig('Pixel_9', 'hw.camera.front=none\n');

      expect(await runTool(<String>['integration-test']), ExitCodes.success);
      expect(logged('back=emulated, front=none'), isTrue);
    });

    test('only warns when --allow-no-camera is passed', () async {
      writeAvdConfig('Pixel_9', 'hw.camera.back=none\nhw.camera.front=none\n');

      expect(await runTool(<String>['integration-test', '--allow-no-camera']), ExitCodes.success);
      expect(logged('WARNING: AVD "Pixel_9" has no cameras'), isTrue);
    });

    test('only warns when the AVD config cannot be found', () async {
      fileSystem.directory(avdHome).deleteSync(recursive: true);

      expect(await runTool(<String>['integration-test']), ExitCodes.success);
      expect(logged('WARNING: Could not find config.ini'), isTrue);
    });

    test('honors ANDROID_AVD_HOME', () async {
      runner = EmulatorRunner(
        fileSystem: fileSystem,
        processManager: processManager,
        environment: <String, String>{'HOME': '/home', 'ANDROID_AVD_HOME': '/custom/avd'},
        log: logs.add,
        delay: (Duration _) async {},
      );
      fileSystem.file('/custom/avd/Pixel_9.avd/config.ini')
        ..createSync(recursive: true)
        ..writeAsStringSync('hw.camera.back=none\nhw.camera.front=none\n');

      expect(await runTool(<String>['integration-test']), ExitCodes.avdUnavailable);
      expect(logged('/custom/avd/Pixel_9.avd/config.ini'), isTrue);
    });
  });

  group('app', () {
    test('builds, installs with permissions granted, and launches the app', () async {
      expect(await runTool(<String>['app']), ExitCodes.success);
      expect(
        processManager.invocations,
        containsAllInOrder(<String>[
          'flutter build apk --debug --target=lib/main.dart',
          'android install --apks=$apk --device=$serial --install-options=-g',
          '$adb -s $serial shell am start -W -n $exampleAppId/.MainActivity',
          '$adb -s $serial shell pidof $exampleAppId',
        ]),
      );
    });

    test('fails with appFailed when the build fails', () async {
      processManager.startExitCodes['flutter build apk --debug --target=lib/main.dart'] = 1;

      expect(await runTool(<String>['app']), ExitCodes.appFailed);
    });

    test('fails with appFailed when adb reports an install failure', () async {
      processManager
          .runResponses['android install --apks=$apk --device=$serial --install-options=-g'] = () =>
          ok('Failure [INSTALL_FAILED_INSUFFICIENT_STORAGE]\n');

      expect(await runTool(<String>['app']), ExitCodes.appFailed);
    });

    test('fails with appFailed when the app crashes on launch', () async {
      processManager.runResponses['$adb -s $serial shell pidof $exampleAppId'] = () => fail('');

      expect(await runTool(<String>['app']), ExitCodes.appFailed);
      expect(logged('logcat -d -b crash'), isTrue);
    });
  });

  group('integration-test', () {
    const testCommand = 'flutter test $defaultIntegrationTestTarget -d $serial';

    test('grants permissions before running the tests', () async {
      expect(await runTool(<String>['integration-test']), ExitCodes.success);
      expect(
        processManager.invocations,
        containsAllInOrder(<String>[
          'flutter build apk --debug --target=$defaultIntegrationTestTarget',
          'android install --apks=$apk --device=$serial --install-options=-g',
          testCommand,
        ]),
      );
    });

    test('forwards --plain-name', () async {
      expect(
        await runTool(<String>['integration-test', '--plain-name=Video capture']),
        ExitCodes.success,
      );
      expect(processManager.invocations, contains('$testCommand --plain-name Video capture'));
    });

    test('fails with usage when the target does not exist', () async {
      expect(
        await runTool(<String>['integration-test', '--target=integration_test/nope.dart']),
        ExitCodes.usage,
      );
      expect(processManager.invocations, isEmpty);
    });

    test('fails with testsFailed when the tests fail', () async {
      processManager.startExitCodes[testCommand] = 1;

      expect(await runTool(<String>['integration-test']), ExitCodes.testsFailed);
    });

    test('fails with testsFailed and kills the tests when they time out', () async {
      processManager.startExitCodes[testCommand] = null;

      expect(
        await runTool(<String>['integration-test', '--test-timeout=1']),
        ExitCodes.testsFailed,
      );
      expect(processManager.startedProcesses.last.killed, isTrue);
      expect(logged('android screen capture'), isTrue);
    });

    test('--stop-emulator stops an emulator the tool started, even on failure', () async {
      processManager.startExitCodes[testCommand] = 1;

      expect(await runTool(<String>['integration-test', '--stop-emulator']), ExitCodes.testsFailed);
      expect(processManager.invocations, contains('android emulator stop $serial'));
    });

    test('--stop-emulator leaves an already-running emulator alone', () async {
      markEmulatorRunning('Pixel_9');

      expect(await runTool(<String>['integration-test', '--stop-emulator']), ExitCodes.success);
      expect(processManager.invocations, isNot(contains('android emulator stop $serial')));
    });
  });
}
