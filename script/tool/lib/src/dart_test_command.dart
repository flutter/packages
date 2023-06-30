// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:platform/platform.dart';

import 'common/core.dart';
import 'common/package_looping_command.dart';
import 'common/plugin_utils.dart';
import 'common/process_runner.dart';
import 'common/repository_package.dart';

/// A command to run Dart unit tests for packages.
class DartTestCommand extends PackageLoopingCommand {
  /// Creates an instance of the test command.
  DartTestCommand(
    Directory packagesDir, {
    ProcessRunner processRunner = const ProcessRunner(),
    Platform platform = const LocalPlatform(),
  }) : super(packagesDir, processRunner: processRunner, platform: platform) {
    argParser.addOption(
      kEnableExperiment,
      defaultsTo: '',
      help:
          'Runs Dart unit tests in Dart VM with the given experiments enabled. '
          'See https://github.com/dart-lang/sdk/blob/main/docs/process/experimental-flags.md '
          'for details.',
    );
    argParser.addOption(
      _platformFlag,
      defaultsTo: '',
      help:
          'Runs Dart unit tests on the given platform instead of the Dart VM.',
    );
  }

  static const String _platformFlag = 'platform';

  @override
  final String name = 'dart-test';

  // TODO(stuartmorgan): Eventually remove 'test', which is a legacy name from
  // before there were other test commands that made it ambiguous. For now it's
  // an alias to avoid breaking people's workflows.
  @override
  List<String> get aliases => <String>['test', 'test-dart'];

  @override
  final String description = 'Runs the Dart tests for all packages.\n\n'
      'This command requires "flutter" to be in your path.';

  @override
  PackageLoopingType get packageLoopingType =>
      PackageLoopingType.includeAllSubpackages;

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    if (!package.testDirectory.existsSync()) {
      return PackageResult.skip('No test/ directory.');
    }

    // Skip running plugin tests for non-web-supporting plugins (or non-web
    // federated plugin implementations) on web, since there's no reason to
    // expect them to work.
    final bool webPlatform = getStringArg(_platformFlag).isNotEmpty &&
        getStringArg(_platformFlag) != 'vm';
    if (webPlatform) {
      if (isFlutterPlugin(package) &&
          !pluginSupportsPlatform(platformWeb, package)) {
        return PackageResult.skip(
            "Non-web plugin tests don't need web testing.");
      }
      if (_requiresVM(package)) {
        return PackageResult.skip('Package has opted out of non-vm testing.');
      }
    }

    bool passed;
    if (package.requiresFlutter()) {
      passed = await _runFlutterTests(package);
    } else {
      passed = await _runDartTests(package);
    }
    return passed ? PackageResult.success() : PackageResult.fail();
  }

  /// Runs the Dart tests for a Flutter package, returning true on success.
  Future<bool> _runFlutterTests(RepositoryPackage package) async {
    final String experiment = getStringArg(kEnableExperiment);
    final String platform = getStringArg(_platformFlag);

    final int exitCode = await processRunner.runAndStream(
      flutterCommand,
      <String>[
        'test',
        '--color',
        if (experiment.isNotEmpty) '--enable-experiment=$experiment',
        if (platform.isNotEmpty) '--platform=$platform',
      ],
      workingDir: package.directory,
    );
    return exitCode == 0;
  }

  /// Runs the Dart tests for a non-Flutter package, returning true on success.
  Future<bool> _runDartTests(RepositoryPackage package) async {
    // Unlike `flutter test`, `pub run test` does not automatically get
    // packages
    int exitCode = await processRunner.runAndStream(
      'dart',
      <String>['pub', 'get'],
      workingDir: package.directory,
    );
    if (exitCode != 0) {
      printError('Unable to fetch dependencies.');
      return false;
    }

    final String experiment = getStringArg(kEnableExperiment);
    final String platform = getStringArg(_platformFlag);

    exitCode = await processRunner.runAndStream(
      'dart',
      <String>[
        'run',
        if (experiment.isNotEmpty) '--enable-experiment=$experiment',
        'test',
        if (platform.isNotEmpty) '--platform=$platform',
      ],
      workingDir: package.directory,
    );

    return exitCode == 0;
  }

  bool _requiresVM(RepositoryPackage package) {
    final File testConfig = package.directory.childFile('dart_test.yaml');
    if (!testConfig.existsSync()) {
      return false;
    }
    // test_on lines can be very complex, but in pratice the packages in this
    // repo currently only need the ability to require vm or not, so that
    // simple directive is all that is supported.
    final RegExp vmRequrimentRegex = RegExp(r'^test_on:\s*vm$');
    return testConfig
        .readAsLinesSync()
        .any((String line) => vmRequrimentRegex.hasMatch(line));
  }
}
