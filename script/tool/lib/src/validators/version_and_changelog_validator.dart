// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';

import '../common/file_utils.dart';
import '../common/git_version_finder.dart';
import '../common/output_utils.dart';
import '../common/package_state_utils.dart';
import '../common/repository_package.dart';

/// Categories of version change types.
enum NextVersionType {
  /// A breaking change.
  BREAKING_MAJOR,

  /// A minor change (e.g., added feature).
  MINOR,

  /// A bugfix change.
  PATCH,

  /// The release of an existing pre-1.0 version.
  V1_RELEASE,
}

/// Returns the set of allowed next non-prerelease versions, with their change
/// type, for [version].
///
/// [newVersion] is used to check whether this is a pre-1.0 version bump, as
/// those have different semver rules.
@visibleForTesting
Map<Version, NextVersionType> getAllowedNextVersions(
  Version version, {
  required Version newVersion,
}) {
  final allowedNextVersions = <Version, NextVersionType>{
    version.nextMajor: NextVersionType.BREAKING_MAJOR,
    version.nextMinor: NextVersionType.MINOR,
    version.nextPatch: NextVersionType.PATCH,
  };

  if (version.major < 1 && newVersion.major < 1) {
    var nextBuildNumber = -1;
    if (version.build.isEmpty) {
      nextBuildNumber = 1;
    } else {
      final currentBuildNumber = version.build.first as int;
      nextBuildNumber = currentBuildNumber + 1;
    }
    final nextBuildVersion = Version(
      version.major,
      version.minor,
      version.patch,
      build: nextBuildNumber.toString(),
    );
    allowedNextVersions.clear();
    allowedNextVersions[version.nextMajor] = NextVersionType.V1_RELEASE;
    allowedNextVersions[version.nextMinor] = NextVersionType.BREAKING_MAJOR;
    allowedNextVersions[version.nextPatch] = NextVersionType.MINOR;
    allowedNextVersions[nextBuildVersion] = NextVersionType.PATCH;
  }
  return allowedNextVersions;
}

/// A validator that checks that the version and changelog of a package are
/// consistent, and match the policy for the files changed.
class VersionAndChangelogValidator {
  /// Creates a new instance of the validator with the given command context.
  VersionAndChangelogValidator({
    required path.Context path,
    required String indentation,
    required Directory repoRoot,
    required void Function(String) warningLogger,
    required GitVersionFinder gitVersionFinder,
    required List<String> changedFiles,
    required Set<String> prLabels,
  }) : _path = path,
       _indentation = indentation,
       _repoRoot = repoRoot,
       _logWarning = warningLogger,
       _gitVersionFinder = gitVersionFinder,
       _changedFiles = changedFiles,
       _prLabels = prLabels;

  final path.Context _path;
  final String _indentation;
  final Directory _repoRoot;
  final void Function(String) _logWarning;
  final GitVersionFinder _gitVersionFinder;
  final List<String> _changedFiles;
  final Set<String> _prLabels;

  /// The label that must be on a PR to allow a breaking
  /// change to a platform interface.
  static const String _breakingChangeOverrideLabel =
      'override: allow breaking change';

  /// The label that must be on a PR to allow skipping a version change for a PR
  /// that would normally require one.
  static const String _missingVersionChangeOverrideLabel =
      'override: no versioning needed';

  /// The label that must be on a PR to allow skipping a CHANGELOG change for a
  /// PR that would normally require one.
  static const String _missingChangelogChangeOverrideLabel =
      'override: no changelog needed';

  /// Validates that the version and changelog of a package are consistent,
  /// and match the policy for the files changed, returning a list of resulting
  /// error strings.
  ///
  /// If no errors are found, an empty list is returned.
  Future<List<String>> validateChangelogAndVersion(
    RepositoryPackage package, {
    required bool checkForMissingChanges,
    required bool ignorePlatformInterfaceBreaks,
  }) async {
    final Pubspec pubspec = package.parsePubspec();

    final Version? currentPubspecVersion = pubspec.version;
    if (currentPubspecVersion == null) {
      printError(
        '${_indentation}No version found in pubspec.yaml. A package '
        'that intentionally has no version should be marked '
        '"publish_to: none".',
      );
      // No remaining checks make sense, so fail immediately.
      return <String>['No pubspec.yaml version.'];
    }

    final errors = <String>[];

    final CIConfig? ciConfig = package.parseCIConfig();
    final bool usesBatchRelease = ciConfig?.isBatchRelease ?? false;

    // All packages with batch release enabled should have valid pending changelogs.
    if (usesBatchRelease) {
      try {
        package.getPendingChangelogs();
      } on FormatException catch (e) {
        printError('$_indentation${e.message}');
        errors.add(e.message);
      }
    } else {
      if (package.pendingChangelogsDirectory.existsSync()) {
        printError(
          '${_indentation}Package does not use batch release but has pending changelogs.',
        );
        errors.add(
          'Package does not use batch release but has pending changelogs.',
        );
      }
    }

    final _CurrentVersionState versionState = await _getVersionState(
      package,
      pubspec: pubspec,
      ignorePlatformInterfaceBreaks: ignorePlatformInterfaceBreaks,
    );
    // PR with post release label is going to sync changelog.md and pubspec.yaml
    // change back to main branch. Proceed with regular version check.
    final bool hasPostReleaseLabel = _prLabels.contains(
      'override: post-release-${pubspec.name}',
    );
    bool versionChanged;

    if (usesBatchRelease && !hasPostReleaseLabel) {
      versionChanged = await _validatePendingChangeForBatchReleasePackage(
        package: package,
        changedFiles: _changedFiles,
        errors: errors,
        versionState: versionState,
      );
      if (errors.isNotEmpty) {
        return errors;
      }
    } else {
      switch (versionState) {
        case _CurrentVersionState.unchanged:
          versionChanged = false;
        case _CurrentVersionState.validIncrease:
        case _CurrentVersionState.validRevert:
        case _CurrentVersionState.newPackage:
          versionChanged = true;
        case _CurrentVersionState.invalidChange:
          versionChanged = true;
          errors.add('Disallowed version change.');
        case _CurrentVersionState.unknown:
          versionChanged = false;
          errors.add('Unable to determine previous version.');
      }

      if (!(await _validateChangelogVersion(
        package,
        pubspec: pubspec,
        pubspecVersionState: versionState,
      ))) {
        errors.add('CHANGELOG.md failed validation.');
      }
    }

    // If there are no other issues, make sure that there isn't a missing
    // change to the version and/or CHANGELOG.
    if (checkForMissingChanges && !versionChanged && errors.isEmpty) {
      final String? error = await _checkForMissingChangeError(package);
      if (error != null) {
        errors.add(error);
      }
    }

    return errors;
  }

  /// Returns the version of [package] from git at the base comparison hash.
  Future<Version?> _getPreviousVersionFromGit(RepositoryPackage package) async {
    final File pubspecFile = package.pubspecFile;
    // Use Posix-style paths for git.
    final String gitPath = relativePosixPath(
      pubspecFile,
      from: _repoRoot,
      platformContext: _path,
    );
    return _gitVersionFinder.getPackageVersion(gitPath);
  }

  /// Returns the state of the verison of [package] relative to the comparison
  /// base (git or pub, depending on flags).
  Future<_CurrentVersionState> _getVersionState(
    RepositoryPackage package, {
    required Pubspec pubspec,
    required bool ignorePlatformInterfaceBreaks,
  }) async {
    // This method isn't called unless `version` is non-null.
    final Version currentVersion = pubspec.version!;
    final Version previousVersion =
        await _getPreviousVersionFromGit(package) ?? Version.none;
    if (previousVersion == Version.none) {
      print(
        '${_indentation}Unable to find previous version '
        'at git base.',
      );
      _logWarning(
        '${_indentation}If this package is not new, something has gone wrong.',
      );
      return _CurrentVersionState.newPackage;
    }

    if (previousVersion == currentVersion) {
      print('${_indentation}No version change.');
      return _CurrentVersionState.unchanged;
    }

    // Check for reverts when doing local validation.
    if (currentVersion < previousVersion) {
      // Since this skips validation, try to ensure that it really is likely
      // to be a revert rather than a typo by checking that the transition
      // from the lower version to the new version would have been valid.
      if (_shouldAllowVersionChange(
        oldVersion: currentVersion,
        newVersion: previousVersion,
      )) {
        _logWarning(
          '${_indentation}New version is lower than previous version. '
          'This is assumed to be a revert.',
        );
        return _CurrentVersionState.validRevert;
      }
    }

    final Map<Version, NextVersionType> allowedNextVersions =
        getAllowedNextVersions(previousVersion, newVersion: currentVersion);

    if (_shouldAllowVersionChange(
      oldVersion: previousVersion,
      newVersion: currentVersion,
    )) {
      print('$_indentation$previousVersion -> $currentVersion');
    } else {
      final String baseSha = await _gitVersionFinder.getBaseSha();
      printError(
        '${_indentation}Incorrectly updated version.\n'
        '${_indentation}HEAD: $currentVersion, $baseSha: $previousVersion.\n'
        '${_indentation}Allowed versions: $allowedNextVersions',
      );
      return _CurrentVersionState.invalidChange;
    }

    // Check whether the version (or for a pre-release, the version that
    // pre-release would eventually be released as) is a breaking change, and
    // if so, validate it.
    final Version targetReleaseVersion = currentVersion.isPreRelease
        ? currentVersion.nextPatch
        : currentVersion;
    if (allowedNextVersions[targetReleaseVersion] ==
            NextVersionType.BREAKING_MAJOR &&
        !_validateBreakingChange(
          package,
          ignorePlatformInterfaceBreaks: ignorePlatformInterfaceBreaks,
        )) {
      printError(
        '${_indentation}Breaking change detected.\n'
        '${_indentation}Breaking changes to platform interfaces are not '
        'allowed without explicit justification.\n'
        '${_indentation}See '
        'https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md '
        'for more information.',
      );
      return _CurrentVersionState.invalidChange;
    }

    return _CurrentVersionState.validIncrease;
  }

  /// Checks whether or not [package]'s CHANGELOG's versioning is correct,
  /// both that it matches [pubspec] and that NEXT is used correctly, printing
  /// the results of its checks.
  ///
  /// Returns false if the CHANGELOG fails validation.
  Future<bool> _validateChangelogVersion(
    RepositoryPackage package, {
    required Pubspec pubspec,
    required _CurrentVersionState pubspecVersionState,
  }) async {
    // This method isn't called unless `version` is non-null.
    final Version fromPubspec = pubspec.version!;

    // get first version from CHANGELOG
    final File changelog = package.changelogFile;
    final List<String> lines = changelog.readAsLinesSync();
    String? firstLineWithText;
    final Iterator<String> iterator = lines.iterator;
    while (iterator.moveNext()) {
      if (iterator.current.trim().isNotEmpty) {
        firstLineWithText = iterator.current.trim();
        break;
      }
    }
    // Remove all leading mark down syntax from the version line.
    String? versionString = firstLineWithText?.split(' ').last;
    String? leadingMarkdown = firstLineWithText?.split(' ').first;

    final badNextErrorMessage =
        '${_indentation}When bumping the version '
        'for release, the NEXT section should be incorporated into the new '
        "version's release notes.";

    // Skip validation for the special NEXT version that's used to accumulate
    // changes that don't warrant publishing on their own.
    final hasNextSection = versionString == 'NEXT';
    if (hasNextSection) {
      // NEXT should not be present in a commit that increases the version.
      if (pubspecVersionState == _CurrentVersionState.validIncrease ||
          pubspecVersionState == _CurrentVersionState.invalidChange) {
        printError(badNextErrorMessage);
        return false;
      }
      print(
        '${_indentation}Found NEXT; validating next version in the CHANGELOG.',
      );
      // Ensure that the version in pubspec hasn't changed without updating
      // CHANGELOG. That means the next version entry in the CHANGELOG should
      // pass the normal validation.
      versionString = null;
      leadingMarkdown = null;
      while (iterator.moveNext()) {
        if (iterator.current.trim().startsWith('## ')) {
          versionString = iterator.current.trim().split(' ').last;
          leadingMarkdown = iterator.current.trim().split(' ').first;
          break;
        }
      }
    }

    final validLeadingMarkdown = leadingMarkdown == '##';
    if (versionString == null || !validLeadingMarkdown) {
      printError('${_indentation}Unable to find a version in CHANGELOG.md');
      print(
        '${_indentation}The current version should be on a line starting '
        'with "## ", either on the first non-empty line or after a "## NEXT" '
        'section.',
      );
      return false;
    }

    final Version fromChangeLog;
    try {
      fromChangeLog = Version.parse(versionString);
    } on FormatException {
      printError('"$versionString" could not be parsed as a version.');
      return false;
    }

    if (fromPubspec != fromChangeLog) {
      printError('''
${_indentation}Versions in CHANGELOG.md and pubspec.yaml do not match.
${_indentation}The version in pubspec.yaml is $fromPubspec.
${_indentation}The first version listed in CHANGELOG.md is $fromChangeLog.
''');
      return false;
    }

    // If NEXT wasn't the first section, it should not exist at all.
    if (!hasNextSection) {
      final nextRegex = RegExp(r'^#+\s*NEXT\s*$');
      if (lines.any((String line) => nextRegex.hasMatch(line))) {
        printError(badNextErrorMessage);
        return false;
      }
    }

    // Check for blank lines between list items in the version section.
    var inList = false;
    var seenBlankLineInList = false;
    final listItemRegex = RegExp(r'^\s*[*+-]\s');
    while (iterator.moveNext()) {
      final String line = iterator.current;
      final bool isListItem = listItemRegex.hasMatch(line);
      final bool isBlank = line.trim().isEmpty;

      if (isListItem) {
        if (seenBlankLineInList) {
          printError(
            '${_indentation}Blank lines found between list items in CHANGELOG.\n'
            '${_indentation}This creates multiple separate lists on pub.dev.\n'
            '${_indentation}Remove blank lines to keep all items in a single list.',
          );
          return false;
        }
        inList = true;
      } else if (isBlank) {
        if (inList) {
          seenBlankLineInList = true;
        }
      } else {
        // Any other non-blank, non-list line resets the state (e.g. new headers, text).
        inList = false;
        seenBlankLineInList = false;
      }
    }

    return true;
  }

  /// Checks whether the current breaking change to [package] should be allowed,
  /// logging extra information for auditing when allowing unusual cases.
  bool _validateBreakingChange(
    RepositoryPackage package, {
    required bool ignorePlatformInterfaceBreaks,
  }) {
    // Only platform interfaces have breaking change restrictions.
    if (!package.isPlatformInterface) {
      return true;
    }

    if (ignorePlatformInterfaceBreaks) {
      _logWarning(
        '${_indentation}Ignoring breaking change to ${package.displayName} '
        'due to command configuration.',
      );
      return true;
    }

    if (_prLabels.contains(_breakingChangeOverrideLabel)) {
      _logWarning(
        '${_indentation}Allowing breaking change to ${package.displayName} '
        'due to the "$_breakingChangeOverrideLabel" label.',
      );
      return true;
    }

    return false;
  }

  /// Returns true if the given version transition should be allowed.
  bool _shouldAllowVersionChange({
    required Version oldVersion,
    required Version newVersion,
  }) {
    // Get the non-pre-release next version mapping.
    final Map<Version, NextVersionType> allowedNextVersions =
        getAllowedNextVersions(oldVersion, newVersion: newVersion);

    if (allowedNextVersions.containsKey(newVersion)) {
      return true;
    }
    // Allow a pre-release version of a version that would be a valid
    // transition.
    if (newVersion.isPreRelease) {
      final Version targetReleaseVersion = newVersion.nextPatch;
      if (allowedNextVersions.containsKey(targetReleaseVersion)) {
        return true;
      }
    }
    return false;
  }

  /// Returns an error string if the changes to this package should have
  /// resulted in a version change, or shoud have resulted in a CHANGELOG change
  /// but didn't.
  ///
  /// This should only be called if the version did not change.
  Future<String?> _checkForMissingChangeError(RepositoryPackage package) async {
    // Find the relative path to the current package, as it would appear at the
    // beginning of a path reported by changedFiles (which always uses
    // Posix paths).
    final String relativePackagePath = await _getRelativePackagePath(package);

    final PackageChangeState state = await checkPackageChangeState(
      package,
      changedPaths: _changedFiles,
      relativePackagePath: relativePackagePath,
      git: _gitVersionFinder,
    );

    if (!state.hasChanges) {
      return null;
    }

    var missingVersionChange = false;
    var missingChangelogChange = false;
    if (state.needsVersionChange) {
      if (_prLabels.contains(_missingVersionChangeOverrideLabel)) {
        _logWarning(
          'Ignoring lack of version change due to the '
          '"$_missingVersionChangeOverrideLabel" label.',
        );
      } else {
        missingVersionChange = true;
        printError(
          'No version change found, but the change to this package could '
          'not be verified to be exempt\n'
          'from version changes according to repository policy.\n'
          'If this is a false positive, please comment in '
          'the PR to explain why the PR\n'
          'is exempt, and add (or ask your reviewer to add) the '
          '"$_missingVersionChangeOverrideLabel" label.\n',
        );
      }
    }

    if (!state.hasChangelogChange && state.needsChangelogChange) {
      if (_prLabels.contains(_missingChangelogChangeOverrideLabel)) {
        _logWarning(
          'Ignoring lack of CHANGELOG update due to the '
          '"$_missingChangelogChangeOverrideLabel" label.',
        );
      } else {
        missingChangelogChange = true;
        final CIConfig? config = package.parseCIConfig();
        const useOverrideChangelogLabel =
            'If this PR needs an exemption from the standard policy of listing '
            'all changes in the CHANGELOG,\n'
            'comment in the PR to explain why the PR is exempt, and add (or '
            'ask your reviewer to add) the\n'
            '"$_missingChangelogChangeOverrideLabel" label.\n';
        if (config?.isBatchRelease ?? false) {
          printError(
            'No new changelog files found in the pending_changelogs folder.\n'
            '$useOverrideChangelogLabel'
            'Otherwise, please add a changelog entry with version:skip in the pending_changelogs folder as described in '
            'the contributing guide.\n',
          );
        } else {
          printError(
            'No CHANGELOG change found.\n'
            '$useOverrideChangelogLabel'
            'Otherwise, please add a NEXT entry in the CHANGELOG as described in '
            'the contributing guide.\n',
          );
        }
      }
    }

    if (missingVersionChange && missingChangelogChange) {
      printError(
        'If this PR is not exempt, you can update version and '
        'CHANGELOG with the "update-release-info" command.\\\n'
        'See here for an example: '
        'https://github.com/flutter/packages/blob/main/script/tool/README.md#update-changelog-and-version\\\n'
        'For more details on versioning, check the contributing guide.',
      );
    }
    if (missingVersionChange) {
      return 'Missing version change';
    }
    if (missingChangelogChange) {
      return 'Missing CHANGELOG change';
    }

    return null;
  }

  /// Validates that the pending changelog files are correct for a batch release.
  ///
  /// This should only be called for package that uses batch release.
  Future<bool> _validatePendingChangeForBatchReleasePackage({
    required RepositoryPackage package,
    required List<String> changedFiles,
    required List<String> errors,
    required _CurrentVersionState versionState,
  }) async {
    final String relativePackagePath = await _getRelativePackagePath(package);
    final List<String> changedFilesInPackage = changedFiles
        .where((String path) => path.startsWith(relativePackagePath))
        .toList();

    // For batch release, only check pending changelog files.
    final List<PendingChangelogEntry> allChangelogs;
    try {
      allChangelogs = package.getPendingChangelogs();
    } on FormatException catch (e) {
      errors.add(e.message);
      return false;
    }

    final List<PendingChangelogEntry> newEntries = allChangelogs
        .where(
          (PendingChangelogEntry entry) => changedFilesInPackage.any(
            (String path) => path.endsWith(entry.file.path.split('/').last),
          ),
        )
        .toList();
    final bool versionChanged = newEntries.any(
      (PendingChangelogEntry entry) => entry.version != VersionChange.skip,
    );

    // The changelog.md and pubspec.yaml's version should not be updated directly.
    if (changedFilesInPackage.contains('$relativePackagePath/CHANGELOG.md')) {
      printError(
        'This package uses batch release, so CHANGELOG.md should not be changed directly.\n'
        'Instead, create a pending changelog file in pending_changelogs folder.',
      );
      errors.add('CHANGELOG.md changed');
    }
    if (changedFilesInPackage.contains('$relativePackagePath/pubspec.yaml')) {
      if (versionState != _CurrentVersionState.unchanged) {
        printError(
          'This package uses batch release, so the version in pubspec.yaml should not be changed directly.\n'
          'Instead, create a pending changelog file in pending_changelogs folder.',
        );
        errors.add('pubspec.yaml version changed');
      }
    }
    return versionChanged;
  }

  Future<String> _getRelativePackagePath(RepositoryPackage package) async {
    return relativePosixPath(
      package.directory,
      from: _repoRoot,
      platformContext: _path,
    );
  }
}

/// The state of a package's version relative to the comparison base.
enum _CurrentVersionState {
  /// The version is unchanged.
  unchanged,

  /// The version has increased, and the transition is valid.
  validIncrease,

  /// The version has decrease, and the transition is a valid revert.
  validRevert,

  /// The version has changed, and the transition is invalid.
  invalidChange,

  /// The package is new.
  newPackage,

  /// There was an error determining the version state.
  unknown,
}
