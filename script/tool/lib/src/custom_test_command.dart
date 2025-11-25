// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';

import 'common/package_looping_command.dart';
import 'common/pub_utils.dart';
import 'common/repository_package.dart';

const String _legacyScriptName = 'run_tests.sh';

/// A command to run custom, package-local tests on packages.
///
/// This is an escape hatch for adding tests that this tooling doesn't support.
/// It should be used sparingly; prefer instead to add functionality to this
/// tooling to eliminate the need for bespoke tests.
class CustomTestCommand extends PackageLoopingCommand {
  /// Creates a custom test command instance.
  CustomTestCommand(
    super.packagesDir, {
    super.processRunner,
    super.platform,
    super.gitDir,
  });

  @override
  final String name = 'custom-test';

  @override
  List<String> get aliases => <String>['test-custom'];

  @override
  final String description =
      'Runs package-specific custom tests defined in '
      "a package's custom test script.\n\n"
      'This command requires "dart" to be in your path.';

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final File script = package.customTestScript;
    final String relativeScriptPath = getRelativePosixPath(
      script,
      from: package.directory,
    );
    final File legacyScript = package.directory.childFile(_legacyScriptName);
    String? customSkipReason;
    var ranTests = false;

    // Run the custom Dart script if presest.
    if (script.existsSync()) {
      // Ensure that dependencies are available.
      if (!await runPubGet(package, processRunner, platform)) {
        return PackageResult.fail(<String>[
          'Unable to get script dependencies',
        ]);
      }

      final int testExitCode = await processRunner.runAndStream(
        'dart',
        <String>['run', relativeScriptPath],
        workingDir: package.directory,
      );
      if (testExitCode != 0) {
        return PackageResult.fail();
      }
      ranTests = true;
    }

    // Run the legacy script if present.
    if (legacyScript.existsSync()) {
      if (platform.isWindows) {
        customSkipReason =
            '$_legacyScriptName is not supported on Windows. '
            'Please migrate to $relativeScriptPath.';
      } else {
        final int exitCode = await processRunner.runAndStream(
          legacyScript.path,
          <String>[],
          workingDir: package.directory,
        );
        if (exitCode != 0) {
          return PackageResult.fail();
        }
        ranTests = true;
      }
    }

    if (!ranTests) {
      return PackageResult.skip(
        customSkipReason ?? 'No $relativeScriptPath file',
      );
    }

    return PackageResult.success();
  }
}
