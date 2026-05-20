// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'common/core.dart';
import 'common/git_version_finder.dart';
import 'common/output_utils.dart';
import 'common/package_command.dart';
import 'common/repository_package.dart';

const int _exitPackageNotFound = 3;

/// Converts all dependencies on target packages to path-based dependencies.
///
/// This is to allow for pre-publish testing of changes that could affect other
/// packages in the repository. For instance, this allows for catching cases
/// where a non-breaking change to a platform interface package of a federated
/// plugin would cause post-publish analyzer failures in another package of that
/// plugin.
class MakeDepsPathBasedCommand extends PackageCommand {
  /// Creates an instance of the command to convert selected dependencies to
  /// path-based.
  MakeDepsPathBasedCommand(super.packagesDir, {super.gitDir}) {
    argParser.addMultiOption(
      _targetDependenciesArg,
      help:
          'The names of the packages to convert to path-based dependencies.\n'
          'Ignored if --$_targetDependenciesWithNonBreakingUpdatesArg is '
          'passed.',
      valueHelp: 'some_package',
    );
    argParser.addFlag(
      _targetDependenciesWithNonBreakingUpdatesArg,
      help:
          'Causes all packages that have non-breaking version changes '
          'when compared against the git base to be treated as target '
          'packages.\n\nOnly packages with dependency constraints that allow '
          'the new version of a given target package will be updated. E.g., '
          'if package A depends on B: ^1.0.0, and B is updated from 2.0.0 to '
          '2.0.1, the dependency on B in A will not become path based.',
    );
  }

  static const String _targetDependenciesArg = 'target-dependencies';
  static const String _targetDependenciesWithNonBreakingUpdatesArg =
      'target-dependencies-with-non-breaking-updates';

  // The comment to add to temporary dependency overrides.
  //
  // Includes a reference to the docs so that reviewers who aren't familiar with
  // the federated plugin change process don't think it's a mistake.
  static const String _dependencyOverrideWarningComment =
      '# FOR TESTING AND INITIAL REVIEW ONLY. $kDoNotLandWarning.\n'
      '# See https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md#changing-federated-plugins';

  @override
  final String name = 'make-deps-path-based';

  @override
  final String description =
      'Converts package dependencies to path-based references.';

  @override
  Future<void> run() async {
    final bool targetByVersion = getBoolArg(
      _targetDependenciesWithNonBreakingUpdatesArg,
    );
    final Set<String> targetDependencies = targetByVersion
        ? await _getNonBreakingUpdatePackages()
        : getStringListArg(_targetDependenciesArg).toSet();

    if (targetDependencies.isEmpty) {
      print('No target dependencies; nothing to do.');
      return;
    }
    print('Rewriting references to: ${targetDependencies.join(', ')}...');

    final Map<String, RepositoryPackage> localDependencyPackages =
        _findLocalPackages(targetDependencies);
    // For targeting by version change, find the versions of the target
    // dependencies.
    final Map<String, Version?> localPackageVersions = targetByVersion
        ? <String, Version?>{
            for (final RepositoryPackage package
                in localDependencyPackages.values)
              package.directory.basename: package.parsePubspec().version,
          }
        : <String, Version>{};

    final String repoRootPath = (await gitDir).path;
    for (final File pubspec in await _getAllPubspecs()) {
      final String displayPath = p.posix.joinAll(
        path.split(path.relative(pubspec.absolute.path, from: repoRootPath)),
      );
      final bool changed = await _addDependencyOverridesIfNecessary(
        RepositoryPackage(pubspec.parent),
        localDependencyPackages,
        localPackageVersions,
      );
      if (changed) {
        print('  Modified $displayPath');
      }
    }
  }

  Map<String, RepositoryPackage> _findLocalPackages(Set<String> packageNames) {
    final targets = <String, RepositoryPackage>{};
    for (final packageName in packageNames) {
      final Directory topLevelCandidate = packagesDir.childDirectory(
        packageName,
      );
      // If packages/<packageName>/ exists, then either that directory is the
      // package, or packages/<packageName>/<packageName>/ exists and is the
      // package (in the case of a federated plugin).
      if (topLevelCandidate.existsSync()) {
        final Directory appFacingCandidate = topLevelCandidate.childDirectory(
          packageName,
        );
        targets[packageName] = RepositoryPackage(
          appFacingCandidate.existsSync()
              ? appFacingCandidate
              : topLevelCandidate,
        );
        continue;
      }
      // Check for a match in the third-party packages directory.
      final Directory thirdPartyCandidate = thirdPartyPackagesDir
          .childDirectory(packageName);
      if (thirdPartyCandidate.existsSync()) {
        targets[packageName] = RepositoryPackage(thirdPartyCandidate);
        continue;
      }
      // If there is no packages/<packageName> directory, then either the
      // packages doesn't exist, or it is a sub-package of a federated plugin.
      // If it's the latter, it will be a directory whose name is a prefix.
      for (final FileSystemEntity entity in packagesDir.listSync()) {
        if (entity is Directory && packageName.startsWith(entity.basename)) {
          final Directory subPackageCandidate = entity.childDirectory(
            packageName,
          );
          if (subPackageCandidate.existsSync()) {
            targets[packageName] = RepositoryPackage(subPackageCandidate);
            break;
          }
        }
      }

      if (!targets.containsKey(packageName)) {
        printError('Unable to find package "$packageName"');
        throw ToolExit(_exitPackageNotFound);
      }
    }
    return targets;
  }

  /// If [pubspecFile] has any non-path dependencies on packages in
  /// [localDependencies], adds dependency_overrides entries to redirect them to
  /// the local version using path-based dependencies.
  ///
  /// Returns true if any overrides were added.
  ///
  /// If [additionalPackagesToOverride] are provided, they will get
  /// dependency_overrides even if there is no direct dependency. This is
  /// useful for overriding transitive dependencies.
  Future<bool> _addDependencyOverridesIfNecessary(
    RepositoryPackage package,
    Map<String, RepositoryPackage> localDependencies,
    Map<String, Version?> versions, {
    Iterable<String> additionalPackagesToOverride = const <String>{},
  }) async {
    final String pubspecContents = package.pubspecFile.readAsStringSync();

    // Returns true if [dependency] allows a dependency on [version]. Always
    // returns true if [version] is null, to err on the side of assuming it
    // will apply in cases where we don't have a target version.
    bool allowsVersion(Dependency dependency, Version? version) {
      return version == null ||
          dependency is! HostedDependency ||
          dependency.version.allows(version);
    }

    // Determine the dependencies to be overridden.
    final pubspec = Pubspec.parse(pubspecContents);
    final Iterable<String> combinedDependencies = <String>[
      // Filter out any dependencies with version constraint that wouldn't allow
      // the target if published, and anything that is already path-based.
      ...<MapEntry<String, Dependency>>[
            ...pubspec.dependencies.entries,
            ...pubspec.devDependencies.entries,
          ]
          .where(
            (MapEntry<String, Dependency> element) =>
                element.value is! PathDependency,
          )
          .where(
            (MapEntry<String, Dependency> element) =>
                allowsVersion(element.value, versions[element.key]),
          )
          .map((MapEntry<String, Dependency> entry) => entry.key),
      ...additionalPackagesToOverride,
    ];
    final List<String> packagesToOverride = combinedDependencies
        .where(
          (String packageName) => localDependencies.containsKey(packageName),
        )
        .toList();

    if (packagesToOverride.isEmpty) {
      return false;
    }

    // Find the relative path to the common base.
    final String repoRootPath = packagesDir.parent.path;
    final int packageDepth = path
        .split(
          path.relative(package.directory.absolute.path, from: repoRootPath),
        )
        .length;
    final relativeBasePathComponents = List<String>.filled(packageDepth, '..');

    // Add the overrides.
    final editablePubspec = YamlEditor(pubspecContents);
    final YamlNode root = editablePubspec.parseAt(<String>[]);
    const dependencyOverridesKey = 'dependency_overrides';

    // Add in any existing overrides, then sort the combined list to avoid
    // sort_pub_dependencies lint violations.
    final existingOverrides =
        (root as YamlMap)[dependencyOverridesKey] as YamlMap?;
    final List<String> allDependencyOverrides = <String>{
      ...existingOverrides?.keys.cast<String>() ?? <String>[],
      ...packagesToOverride,
    }.toList();
    allDependencyOverrides.sort();

    // Build a fresh overrides section, to ensure that new entries are sorted
    // with any existing entries. This does mean comments will be removed, but
    // since this command's changes will always be reverted anyway, that
    // shouldn't be an issue, whereas lint violations will cause analysis
    // failures.
    // This uses string concatenation rather than YamlMap because the latter
    // doesn't guarantee any particular output order for its entries.
    final newOverrideLines = <String>[];
    for (final packageName in allDependencyOverrides) {
      final String overrideValue;
      if (packagesToOverride.contains(packageName)) {
        // Create a new override.

        // Find the relative path from the common base to the local package.
        final List<String> repoRelativePathComponents = path.split(
          path.relative(
            localDependencies[packageName]!.path,
            from: repoRootPath,
          ),
        );
        final String pathValue = p.posix.joinAll(<String>[
          ...relativeBasePathComponents,
          ...repoRelativePathComponents,
        ]);
        overrideValue = '{path: $pathValue}';
      } else {
        // Re-use the pre-existing override.
        overrideValue = existingOverrides![packageName].toString();
      }
      newOverrideLines.add('  $packageName: $overrideValue');
    }
    // Create an empty section as a placeholder to replace.
    editablePubspec.update(<String>[dependencyOverridesKey], YamlMap());
    var newContent = editablePubspec.toString();

    // Add the warning if it's not already there.
    final warningComment =
        newContent.contains(_dependencyOverrideWarningComment)
        ? ''
        : '$_dependencyOverrideWarningComment\n';
    // Replace the placeholder with the new section.
    newContent = newContent.replaceFirst(
      RegExp('$dependencyOverridesKey:\\s*{}\\n'),
      '''
$warningComment$dependencyOverridesKey:
${newOverrideLines.join('\n')}
''',
    );

    // Write the new pubspec.
    package.pubspecFile.writeAsStringSync(newContent);

    // Update any examples. This is important for cases like integration tests
    // of app-facing packages in federated plugins, where the app-facing
    // package depends directly on the implementation packages, but the
    // example app doesn't. Since integration tests are run in the example app,
    // it needs the overrides in order for tests to pass.
    for (final RepositoryPackage example in package.getExamples()) {
      await _addDependencyOverridesIfNecessary(
        example,
        localDependencies,
        versions,
        additionalPackagesToOverride: packagesToOverride,
      );
    }

    return true;
  }

  /// Returns all pubspecs anywhere under the packages directory.
  Future<List<File>> _getAllPubspecs() => packagesDir.parent
      .list(recursive: true, followLinks: false)
      .where(
        (FileSystemEntity entity) =>
            entity is File && p.basename(entity.path) == 'pubspec.yaml',
      )
      .map((FileSystemEntity file) => file as File)
      .toList();

  /// Returns all packages that have non-breaking published changes (i.e., a
  /// minor or bugfix version change) relative to the git comparison base.
  ///
  /// Prints status information about what was checked for ease of auditing logs
  /// in CI.
  Future<Set<String>> _getNonBreakingUpdatePackages() async {
    final GitVersionFinder gitVersionFinder = await retrieveVersionFinder();
    final String baseSha = await gitVersionFinder.getBaseSha();
    print('Finding changed packages relative to "$baseSha"...');

    final changedPackages = <String>{};
    for (final String changedPath in await gitVersionFinder.getChangedFiles()) {
      // Git output always uses Posix paths.
      final List<String> allComponents = p.posix.split(changedPath);
      // Only pubspec changes are potential publishing events.
      if (allComponents.last != 'pubspec.yaml' ||
          allComponents.contains('example')) {
        continue;
      }
      if (!allComponents.contains(packagesDir.basename)) {
        print('  Skipping $changedPath; not in packages directory.');
        continue;
      }
      final package = RepositoryPackage(
        packagesDir.fileSystem.file(changedPath).parent,
      );
      // Ignored deleted packages, as they won't be published.
      if (!package.pubspecFile.existsSync()) {
        final String directoryName = p.posix.joinAll(
          path.split(
            path.relative(
              package.directory.absolute.path,
              from: packagesDir.parent.path,
            ),
          ),
        );
        print('  Skipping $directoryName; deleted.');
        continue;
      }
      final String packageName = package.parsePubspec().name;
      if (!await _hasNonBreakingVersionChange(package)) {
        // Log packages that had pubspec changes but weren't included for ease
        // of auditing CI.
        print('  Skipping $packageName; no non-breaking version change.');
        continue;
      }
      changedPackages.add(packageName);
    }
    return changedPackages;
  }

  Future<bool> _hasNonBreakingVersionChange(RepositoryPackage package) async {
    final Pubspec pubspec = package.parsePubspec();
    if (pubspec.publishTo == 'none') {
      return false;
    }

    final String pubspecGitPath = p.posix.joinAll(
      path.split(
        path.relative(
          package.pubspecFile.absolute.path,
          from: (await gitDir).path,
        ),
      ),
    );
    final GitVersionFinder gitVersionFinder = await retrieveVersionFinder();
    final Version? previousVersion = await gitVersionFinder.getPackageVersion(
      pubspecGitPath,
    );
    if (previousVersion == null) {
      // The plugin is new, so nothing can be depending on it yet.
      return false;
    }
    final Version newVersion = pubspec.version!;
    if ((newVersion.major > 0 && newVersion.major != previousVersion.major) ||
        (newVersion.major == 0 && newVersion.minor != previousVersion.minor)) {
      // Breaking changes aren't targeted since they won't be picked up
      // automatically.
      return false;
    }
    return newVersion != previousVersion;
  }
}
