// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';

import 'common/core.dart';
import 'common/git_version_finder.dart';
import 'common/output_utils.dart';
import 'common/package_looping_command.dart';
import 'common/repository_package.dart';
import 'common/tool_config.dart';
import 'validators/dependabot_validator.dart';
import 'validators/gradle_validator.dart';
import 'validators/pubspec_validator.dart';
import 'validators/readme_validator.dart';
import 'validators/repo_info_validator.dart';
import 'validators/version_and_changelog_validator.dart';

const int _missingMinSdkVersionExitCode = 3;
const int _unknownVersionMappingExitCode = 4;

/// The set of possible validators.
///
/// Exposed for testing so that unit tests can target a single validator's
/// behavior via the command without having to set everything required for
/// every other validator to pass.
///
/// This is done instead of testing validators directly to ensure that testing
/// includes things like command line parsing and run initialization.
@visibleForTesting
// ignore: public_member_api_docs
enum Validator { dependabot, gradle, pubspec, readme, repoInfo, version }

/// A command to validate that packages follow various team conventions,
/// guidelines, and best practices.
///
/// This includes:
/// - repository-level metadata about packages, such as repo README and
///   auto-label entries
/// - pubspec format and contents
/// - dependabot configuration coverage
/// - gradle configurations
class ValidateCommand extends PackageLoopingCommand {
  /// Creates Dependabot check command instance.
  ValidateCommand(
    super.packagesDir, {
    this.targetedValidators,
    super.processRunner,
    super.platform,
    super.gitDir,
  }) {
    argParser.addOption(
      _prLabelsArg,
      help:
          'A comma-separated list of labels associated with this PR, '
          'if applicable.\n\n'
          'If supplied, labels may override or disable some checks.',
      hide: true,
    );
    argParser.addFlag(
      _checkForMissingChanges,
      help:
          'Validates that changes to packages include CHANGELOG and '
          'version changes unless they meet an established exemption.\n\n'
          'If used with --$_prLabelsArg, this should only be used in '
          'pre-submit CI checks, to prevent post-submit breakage '
          'when labels are no longer applicable.',
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
  static const String _ignorePlatformInterfaceBreaks = 'ignore-platform-interface-breaks';

  /// The validators to run.
  ///
  /// If null, all validators are run.
  final Set<Validator>? targetedValidators;

  late Directory _repoRoot;

  late final GitVersionFinder _gitVersionFinder;

  late final Set<String> _prLabels = _getPRLabels();

  /// Data from the root README.md table of packages.
  final Map<String, List<String>> _readmeTableEntries = <String, List<String>>{};

  /// Packages with entries in labeler.yml.
  final Set<String> _autoLabeledPackages = <String>{};

  /// The set of directories covered by the repo's Dependabot configuration.
  late DependabotCoverage _dependabotCoverage;

  /// The set of packages that are allowed as dependencies.
  final AllowPackageLists _allowedPackages = (
    local: <String>{},
    pinned: <String>{},
    unpinned: <String>{},
  );

  /// The minimum version of Flutter that is allowed for any package.
  Version? _minMinFlutterVersion;

  /// The minimum version of Dart that is allowed for any package.
  Version? _minMinDartVersion;

  @override
  final String name = 'validate';

  @override
  final String description = 'Checks that packages follow team guidelines.';

  @override
  final PackageLoopingType packageLoopingType = PackageLoopingType.includeAllSubpackages;

  @override
  final bool hasLongOutput = false;

  @override
  Future<void> initializeRun() async {
    _gitVersionFinder = await retrieveVersionFinder();
    _repoRoot = packagesDir.fileSystem.directory((await gitDir).path);

    if (_shouldRun(Validator.repoInfo)) {
      // Extract all of the repo-level README.md table entries.
      _readmeTableEntries.addAll(
        RepoInfoValidator.loadReadmeTableEntries(
          repoRoot: _repoRoot,
          packagesDir: packagesDir,
          thirdPartyPackagesDir: thirdPartyPackagesDir,
        ),
      );
      // Extract all of the labeler.yml package entries.
      _autoLabeledPackages.addAll(RepoInfoValidator.loadAutoLabeledPackages(repoRoot: _repoRoot));
    }
    if (_shouldRun(Validator.pubspec)) {
      await _loadAllowedDependencies();
      final (flutter: Version? minFlutter, dart: Version? minDart) = _loadMinMinSdkVersions();
      _minMinFlutterVersion = minFlutter;
      _minMinDartVersion =
          minDart ?? (minFlutter == null ? null : getDartSdkForFlutterSdk(minFlutter));
      if (_minMinDartVersion == null) {
        printError(
          'Dart SDK version for Flutter SDK version $_minMinFlutterVersion is unknown. '
          'Please update the map for getDartSdkForFlutterSdk with the '
          'corresponding Dart version.',
        );
        throw ToolExit(_unknownVersionMappingExitCode);
      }
    }
    if (_shouldRun(Validator.dependabot)) {
      _dependabotCoverage = DependabotValidator.loadConfig(repoRoot: _repoRoot);
    }
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    // Packages excluded via .pubignore are not published, consumer-facing
    // artifacts, so they are exempt from the hygiene checks enforced by this command.
    if (package.isPubIgnored) {
      return PackageResult.skip('Ignored by .pubignore');
    }

    final List<String> errors = [
      if (_shouldRun(Validator.repoInfo)) ...await _validateRepoInfo(package),
      if (_shouldRun(Validator.pubspec)) ...await _validatePubspec(package),
      if (_shouldRun(Validator.readme)) ...await _validateReadme(package),
      if (_shouldRun(Validator.dependabot)) ...await _validateDependabot(package),
      if (_shouldRun(Validator.gradle)) ...await _validateGradle(package),
      if (_shouldRun(Validator.version)) ...await _validateVersionAndChangelog(package),
    ];

    return errors.isEmpty ? PackageResult.success() : PackageResult.fail(errors);
  }

  bool _shouldRun(Validator validator) => targetedValidators?.contains(validator) ?? true;

  /// Runs repo-level checks.
  Future<List<String>> _validateRepoInfo(RepositoryPackage package) async {
    // Repo-level checks only apply to top-level packages.
    if (!package.isTopLevel) {
      return <String>[];
    }
    final validator = RepoInfoValidator(
      readmeTableEntries: _readmeTableEntries,
      autoLabeledPackages: _autoLabeledPackages,
      gitDir: await gitDir,
      repoRoot: _repoRoot,
      indentation: indentation,
    );
    return validator.validatePackage(package);
  }

  Future<List<String>> _validateDependabot(RepositoryPackage package) async {
    final validator = DependabotValidator(
      coverage: _dependabotCoverage,
      path: path,
      repoRoot: _repoRoot,
      indentation: indentation,
    );
    return validator.validateDependabotCoverage(package);
  }

  Future<List<String>> _validateGradle(RepositoryPackage package) async {
    if (!package.platformDirectory(FlutterPlatform.android).existsSync()) {
      return [];
    }

    final validator = GradleValidator(path: path, indentation: indentation);
    return validator.validateGradle(package);
  }

  Future<List<String>> _validatePubspec(RepositoryPackage package) async {
    final validator = PubspecValidator(
      path: path,
      indentation: indentation,
      warningLogger: printWarning,
      allowedPackages: _allowedPackages,
      repoRoot: rootDir,
      minMinFlutterVersion: _minMinFlutterVersion,
      minMinDartVersion: _minMinDartVersion,
    );
    return validator.validatePubspec(package);
  }

  Future<List<String>> _validateReadme(RepositoryPackage package) async {
    // TODO(stuartmorgan): Consider restructuring this to just check the
    //  current package's README for all packages, now that this is part of an
    //  includeAllSubpackages command. The current logic is from when it was
    //  its own top-level-only command.
    if (!package.isTopLevel) {
      return [];
    }

    final validator = ReadmeValidator(
      path: path,
      indentation: indentation,
      warningLogger: printWarning,
    );

    final List<String> errors = validator.validateReadme(
      package.readmeFile,
      mainPackage: package,
      isExample: false,
    );
    for (final RepositoryPackage packageToCheck in package.getExamples()) {
      errors.addAll(
        validator.validateReadme(packageToCheck.readmeFile, mainPackage: package, isExample: true),
      );
    }

    // If there's an example/README.md for a multi-example package, validate
    // that as well, as it will be shown on pub.dev.
    final Directory exampleDir = package.directory.childDirectory('example');
    final File exampleDirReadme = exampleDir.childFile('README.md');
    if (exampleDir.existsSync() && !isPackage(exampleDir)) {
      errors.addAll(
        validator.validateReadme(exampleDirReadme, mainPackage: package, isExample: true),
      );
    }

    return errors;
  }

  Future<List<String>> _validateVersionAndChangelog(RepositoryPackage package) async {
    if (!package.isTopLevel) {
      return [];
    }

    final Directory repoRoot = packagesDir.fileSystem.directory((await gitDir).path);

    final validator = VersionAndChangelogValidator(
      path: path,
      indentation: indentation,
      warningLogger: logWarning,
      gitVersionFinder: _gitVersionFinder,
      repoRoot: repoRoot,
      changedFiles: changedFiles,
      prLabels: _prLabels,
    );

    return validator.validateChangelogAndVersion(
      package,
      checkForMissingChanges: getBoolArg(_checkForMissingChanges),
      ignorePlatformInterfaceBreaks: getBoolArg(_ignorePlatformInterfaceBreaks),
    );
  }

  Stream<String> _findAllPublishedPackages() async* {
    for (final File pubspecFile
        in (await _repoRoot.list(recursive: true, followLinks: false).toList())
            .whereType<File>()
            .where((File entity) => p.basename(entity.path) == 'pubspec.yaml')) {
      final Pubspec? pubspec = _tryParsePubspec(pubspecFile.readAsStringSync());
      if (pubspec != null && pubspec.publishTo != 'none') {
        yield pubspec.name;
      }
    }
  }

  Future<void> _loadAllowedDependencies() async {
    // Find all local, published packages.
    _allowedPackages.local.addAll(await _findAllPublishedPackages().toList());

    final ({List<String> pinned, List<String> unpinned}) allowedDeps = getAllowedDependencies(
      _repoRoot,
    );
    _allowedPackages.unpinned.addAll(allowedDeps.unpinned);
    _allowedPackages.pinned.addAll(allowedDeps.pinned);
  }

  ({Version? flutter, Version? dart}) _loadMinMinSdkVersions() {
    final String? minFlutter = getMinFlutterVersion(_repoRoot);
    final String? minDart = getMinDartVersion(_repoRoot);
    if (minFlutter == null && minDart == null) {
      printError(
        'Either min_flutter or min_dart must be provided '
        'in the repo tool configuration.',
      );
      throw ToolExit(_missingMinSdkVersionExitCode);
    }
    return (
      flutter: minFlutter == null ? null : Version.parse(minFlutter),
      dart: minDart == null ? null : Version.parse(minDart),
    );
  }

  Pubspec? _tryParsePubspec(String pubspecContents) {
    try {
      return Pubspec.parse(pubspecContents);
    } on Exception catch (exception) {
      print('  Cannot parse pubspec.yaml: $exception');
    }
    return null;
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
