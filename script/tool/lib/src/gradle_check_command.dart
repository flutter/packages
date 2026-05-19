// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'common/package_looping_command.dart';
import 'common/repository_package.dart';
import 'validators/gradle_validator.dart';

/// A command to enforce gradle file conventions and best practices.
class GradleCheckCommand extends PackageLoopingCommand {
  /// Creates an instance of the gradle check command.
  GradleCheckCommand(super.packagesDir, {super.gitDir});

  @override
  final String name = 'gradle-check';

  @override
  List<String> get aliases => <String>['check-gradle'];

  @override
  final String description =
      'Checks that gradle files follow repository conventions.';

  @override
  bool get hasLongOutput => false;

  @override
  PackageLoopingType get packageLoopingType =>
      PackageLoopingType.includeAllSubpackages;

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    if (!package.platformDirectory(FlutterPlatform.android).existsSync()) {
      return PackageResult.skip('No android/ directory.');
    }

    final validator = GradleValidator(path: path, indentation: indentation);
    final List<String> errors = validator.validateGradle(package);

    // TODO(stuartmorgan): When combining this with other commands, use the
    // errors. For now they are dropped to keep the existing behavior.
    return errors.isEmpty ? PackageResult.success() : PackageResult.fail();
  }
}
