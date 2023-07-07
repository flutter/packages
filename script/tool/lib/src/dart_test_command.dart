// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:platform/platform.dart';

import 'common/core.dart';
import 'common/package_looping_command.dart';
import 'common/plugin_utils.dart';
import 'common/process_runner.dart';
import 'common/pub_utils.dart';
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
      help: 'Runs tests on the given platform instead of the default platform '
          '("vm" in most cases, "chrome" for web plugin implementations).',
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

    String? platform = getNullableStringArg(_platformFlag);

    // Skip running plugin tests for non-web-supporting plugins (or non-web
    // federated plugin implementations) on web, since there's no reason to
    // expect them to work.
    final bool webPlatform = platform != null && platform != 'vm';
    final bool explicitVMPlatform = platform == 'vm';
    final bool isWebOnlyPluginImplementation = pluginSupportsPlatform(
            platformWeb, package,
            requiredMode: PlatformSupport.inline) &&
        package.directory.basename.endsWith('_web');
    if (webPlatform) {
      if (isFlutterPlugin(package) &&
          !pluginSupportsPlatform(platformWeb, package)) {
        return PackageResult.skip(
            "Non-web plugin tests don't need web testing.");
      }
      if (_requiresVM(package)) {
        // This explict skip is necessary because trying to run tests in a mode
        // that the package has opted out of returns a non-zero exit code.
        return PackageResult.skip('Package has opted out of non-vm testing.');
      }
    } else if (explicitVMPlatform) {
      if (isWebOnlyPluginImplementation) {
        return PackageResult.skip("Web plugin tests don't need vm testing.");
      }
      if (_requiresNonVM(package)) {
        // This explict skip is necessary because trying to run tests in a mode
        // that the package has opted out of returns a non-zero exit code.
        return PackageResult.skip('Package has opted out of vm testing.');
      }
    } else if (platform == null && isWebOnlyPluginImplementation) {
      // If no explicit mode is requested, run web plugin implementations in
      // Chrome since their tests are not expected to work in vm mode. This
      // allows easily running all unit tests locally, without having to run
      // both modes.
      platform = 'chrome';
    }

    bool passed;
    if (package.requiresFlutter()) {
      passed = await _runFlutterTests(package, platform: platform);
    } else {
      passed = await _runDartTests(package, platform: platform);
    }
    return passed ? PackageResult.success() : PackageResult.fail();
  }

  /// Runs the Dart tests for a Flutter package, returning true on success.
  Future<bool> _runFlutterTests(RepositoryPackage package,
      {String? platform}) async {
    final String experiment = getStringArg(kEnableExperiment);

    final int exitCode = await processRunner.runAndStream(
      flutterCommand,
      <String>[
        'test',
        '--color',
        if (experiment.isNotEmpty) '--enable-experiment=$experiment',
        // Flutter defaults to VM mode (under a different name) and explicitly
        // setting it is deprecated, so pass nothing in that case.
        if (platform != null && platform != 'vm') '--platform=$platform',
      ],
      workingDir: package.directory,
    );
    return exitCode == 0;
  }

  /// Runs the Dart tests for a non-Flutter package, returning true on success.
  Future<bool> _runDartTests(RepositoryPackage package,
      {String? platform}) async {
    // Unlike `flutter test`, `dart run test` does not automatically get
    // packages
    if (!await runPubGet(package, processRunner, super.platform)) {
      printError('Unable to fetch dependencies.');
      return false;
    }

    final String experiment = getStringArg(kEnableExperiment);

    final int exitCode = await processRunner.runAndStream(
      'dart',
      <String>[
        'run',
        if (experiment.isNotEmpty) '--enable-experiment=$experiment',
        'test',
        if (platform != null) '--platform=$platform',
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
    // simple directive is all that is currently supported.
    final RegExp vmRequrimentRegex = RegExp(r'^test_on:\s*vm$');
    return testConfig
        .readAsLinesSync()
        .any((String line) => vmRequrimentRegex.hasMatch(line));
  }

  bool _requiresNonVM(RepositoryPackage package) {
    final File testConfig = package.directory.childFile('dart_test.yaml');
    if (!testConfig.existsSync()) {
      return false;
    }
    // test_on lines can be very complex, but in pratice the packages in this
    // repo currently only need the ability to require vm or not, so a simple
    // one-target directive is all that's supported currently. Making it
    // deliberately strict avoids the possibility of accidentally skipping vm
    // coverage due to a complex expression that's not handled correctly.
    final RegExp testOnRegex = RegExp(r'^test_on:\s*([a-z])*\s*$');
    return testConfig.readAsLinesSync().any((String line) {
      final RegExpMatch? match = testOnRegex.firstMatch(line);
      return match != null && match.group(1) != 'vm';
    });
  }
}
