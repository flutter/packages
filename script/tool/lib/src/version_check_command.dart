// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';

import 'common/git_version_finder.dart';
import 'common/output_utils.dart';
import 'common/package_looping_command.dart';
import 'common/repository_package.dart';
import 'validators/version_and_changelog_validator.dart';

/// A command to validate version changes to packages.
class VersionCheckCommand extends PackageLoopingCommand {
  /// Creates an instance of the version check command.
  VersionCheckCommand(
    super.packagesDir, {
    super.processRunner,
    super.platform,
    super.gitDir,
  }) {
    argParser.addOption(
      _prLabelsArg,
      help:
          'A comma-separated list of labels associated with this PR, '
          'if applicable.\n\n'
          'If supplied, this may be to allow overrides to some version '
          'checks.',
    );
    argParser.addFlag(
      _checkForMissingChanges,
      help:
          'Validates that changes to packages include CHANGELOG and '
          'version changes unless they meet an established exemption.\n\n'
          'If used with --$_prLabelsArg, this is should only be '
          'used in pre-submit CI checks, to  prevent post-submit breakage '
          'when labels are no longer applicable.',
      hide: true,
    );
    argParser.addFlag(
      _ignorePlatformInterfaceBreaks,
      help:
          'Bypasses the check that platform interfaces do not contain '
          'breaking changes.\n\n'
          'This is only intended for use in post-submit CI checks, to '
          'prevent post-submit breakage when overriding the check with '
          'labels. Pre-submit checks should always use '
          '--$_prLabelsArg instead.',
      hide: true,
    );
  }

  static const String _prLabelsArg = 'pr-labels';
  static const String _checkForMissingChanges = 'check-for-missing-changes';
  static const String _ignorePlatformInterfaceBreaks =
      'ignore-platform-interface-breaks';

  late final GitVersionFinder _gitVersionFinder;

  late final Set<String> _prLabels = _getPRLabels();

  @override
  final String name = 'version-check';

  @override
  List<String> get aliases => <String>['check-version'];

  @override
  final String description =
      'Checks if the versions of packages have been incremented per pub specification.\n'
      'Also checks if the latest version in CHANGELOG matches the version in pubspec.\n\n'
      'This command requires "flutter" to be in your path.';

  @override
  bool get hasLongOutput => false;

  @override
  Future<void> initializeRun() async {
    _gitVersionFinder = await retrieveVersionFinder();
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final Pubspec? pubspec = _tryParsePubspec(package);
    if (pubspec == null) {
      // No remaining checks make sense, so fail immediately.
      return PackageResult.fail(<String>['Invalid pubspec.yaml.']);
    }

    if (pubspec.publishTo == 'none') {
      return PackageResult.skip('Found "publish_to: none".');
    }
    final Directory repoRoot = packagesDir.fileSystem.directory(
      (await gitDir).path,
    );

    final validator = VersionAndChangelogValidator(
      path: path,
      indentation: indentation,
      warningLogger: logWarning,
      gitVersionFinder: _gitVersionFinder,
      repoRoot: repoRoot,
      changedFiles: changedFiles,
      prLabels: _prLabels,
    );

    final List<String> errors = await validator.validateChangelogAndVersion(
      package,
      checkForMissingChanges: getBoolArg(_checkForMissingChanges),
      ignorePlatformInterfaceBreaks: getBoolArg(_ignorePlatformInterfaceBreaks),
    );
    return errors.isEmpty
        ? PackageResult.success()
        : PackageResult.fail(errors);
  }

  Pubspec? _tryParsePubspec(RepositoryPackage package) {
    try {
      final Pubspec pubspec = package.parsePubspec();
      return pubspec;
    } on Exception catch (exception) {
      printError('${indentation}Failed to parse `pubspec.yaml`: $exception}');
      return null;
    }
  }

  /// Returns the labels associated with this PR, if any, or an empty set
  /// if that flag is not provided.
  Set<String> _getPRLabels() {
    final String labels = getStringArg(_prLabelsArg);
    if (labels.isEmpty) {
      return <String>{};
    }
    return labels.split(',').map((String label) => label.trim()).toSet();
  }
}
