// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'common/output_utils.dart';
import 'common/package_looping_command.dart';
import 'common/repository_package.dart';

/// A command to run Dart's "fix" command on packages.
class FixCommand extends PackageLoopingCommand {
  /// Creates a fix command instance.
  FixCommand(
    super.packagesDir, {
    super.processRunner,
    super.platform,
    super.gitDir,
  });

  @override
  final String name = 'fix';

  @override
  final String description = 'Fixes packages using dart fix.\n\n'
      'This command requires "dart" and "flutter" to be in your path, and '
      'assumes that dependencies have already been fetched (e.g., by running '
      'the analyze command first).';

  @override
  final bool hasLongOutput = false;

  @override
  PackageLoopingType get packageLoopingType =>
      PackageLoopingType.includeAllSubpackages;

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final int exitCode = await processRunner.runAndStream(
        'dart', <String>['fix', '--apply'],
        workingDir: package.directory);
    if (exitCode != 0) {
      printError('Unable to automatically fix package.');
      return PackageResult.fail();
    }
    return PackageResult.success();
  }
}
