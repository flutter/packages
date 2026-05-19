// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';

import 'common/core.dart';
import 'common/output_utils.dart';
import 'common/package_looping_command.dart';
import 'common/repository_package.dart';
import 'validators/readme_validator.dart';

/// A command to enforce README conventions across the repository.
class ReadmeCheckCommand extends PackageLoopingCommand {
  /// Creates an instance of the README check command.
  ReadmeCheckCommand(
    super.packagesDir, {
    super.processRunner,
    super.platform,
    super.gitDir,
  }) {
    argParser.addFlag(
      _requireExcerptsArg,
      help: 'Require that Dart code blocks be managed by code-excerpt.',
    );
  }

  static const String _requireExcerptsArg = 'require-excerpts';

  @override
  final String name = 'readme-check';

  @override
  List<String> get aliases => <String>['check-readme'];

  @override
  final String description =
      'Checks that READMEs follow repository conventions.';

  @override
  bool get hasLongOutput => false;

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final validator = ReadmeValidator(
      path: path,
      indentation: indentation,
      warningLogger: printWarning,
      requireCodeExcerpts: getBoolArg(_requireExcerptsArg),
    );

    final List<String> errors = validator.validateReadme(
      package.readmeFile,
      mainPackage: package,
      isExample: false,
    );
    for (final RepositoryPackage packageToCheck in package.getExamples()) {
      errors.addAll(
        validator.validateReadme(
          packageToCheck.readmeFile,
          mainPackage: package,
          isExample: true,
        ),
      );
    }

    // If there's an example/README.md for a multi-example package, validate
    // that as well, as it will be shown on pub.dev.
    final Directory exampleDir = package.directory.childDirectory('example');
    final File exampleDirReadme = exampleDir.childFile('README.md');
    if (exampleDir.existsSync() && !isPackage(exampleDir)) {
      errors.addAll(
        validator.validateReadme(
          exampleDirReadme,
          mainPackage: package,
          isExample: true,
        ),
      );
    }

    return errors.isEmpty
        ? PackageResult.success()
        : PackageResult.fail(errors);
  }
}
