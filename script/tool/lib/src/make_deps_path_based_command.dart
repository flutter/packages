// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:git/git.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'common/core.dart';
import 'common/git_version_finder.dart';
import 'common/package_command.dart';
import 'common/repository_package.dart';

const int _exitPackageNotFound = 3;

enum _RewriteOutcome { changed, noChangesNeeded }

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
  MakeDepsPathBasedCommand(
    Directory packagesDir, {
    GitDir? gitDir,
  }) : super(packagesDir, gitDir: gitDir) {
    argParser.addMultiOption(_targetDependenciesArg,
        help:
            'The names of the packages to convert to path-based dependencies.\n'
            'Ignored if --$_targetDependenciesWithNonBreakingUpdatesArg is '
            'passed.',
        valueHelp: 'some_package');
    argParser.addFlag(
      _targetDependenciesWithNonBreakingUpdatesArg,
      help: 'Causes all packages that have non-breaking version changes '
          'when compared against the git base to be treated as target '
          'packages.',
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
      '# FOR TESTING AND INITIAL REVIEW ONLY. DO NOT MERGE.\n'
      '# See https://github.com/flutter/flutter/wiki/Contributing-to-Plugins-and-Packages#changing-federated-plugins';

  @override
  final String name = 'make-deps-path-based';

  @override
  final String description =
      'Converts package dependencies to path-based references.';

  @override
  Future<void> run() async {
    final Set<String> targetDependencies =
        getBoolArg(_targetDependenciesWithNonBreakingUpdatesArg)
            ? await _getNonBreakingUpdatePackages()
            : getStringListArg(_targetDependenciesArg).toSet();

    if (targetDependencies.isEmpty) {
      print('No target dependencies; nothing to do.');
      return;
    }
    print('Rewriting references to: ${targetDependencies.join(', ')}...');

    final Map<String, RepositoryPackage> localDependencyPackages =
        _findLocalPackages(targetDependencies);

    final String repoRootPath = (await gitDir).path;
    for (final File pubspec in await _getAllPubspecs()) {
      final String displayPath = p.posix.joinAll(
          path.split(path.relative(pubspec.absolute.path, from: repoRootPath)));
      final _RewriteOutcome outcome = await _addDependencyOverridesIfNecessary(
          RepositoryPackage(pubspec.parent), localDependencyPackages);
      switch (outcome) {
        case _RewriteOutcome.changed:
          print('  Modified $displayPath');
          break;
        case _RewriteOutcome.noChangesNeeded:
          break;
      }
    }
  }

  Map<String, RepositoryPackage> _findLocalPackages(Set<String> packageNames) {
    final Map<String, RepositoryPackage> targets =
        <String, RepositoryPackage>{};
    for (final String packageName in packageNames) {
      final Directory topLevelCandidate =
          packagesDir.childDirectory(packageName);
      // If packages/<packageName>/ exists, then either that directory is the
      // package, or packages/<packageName>/<packageName>/ exists and is the
      // package (in the case of a federated plugin).
      if (topLevelCandidate.existsSync()) {
        final Directory appFacingCandidate =
            topLevelCandidate.childDirectory(packageName);
        targets[packageName] = RepositoryPackage(appFacingCandidate.existsSync()
            ? appFacingCandidate
            : topLevelCandidate);
        continue;
      }
      // If there is no packages/<packageName> directory, then either the
      // packages doesn't exist, or it is a sub-package of a federated plugin.
      // If it's the latter, it will be a directory whose name is a prefix.
      for (final FileSystemEntity entity in packagesDir.listSync()) {
        if (entity is Directory && packageName.startsWith(entity.basename)) {
          final Directory subPackageCandidate =
              entity.childDirectory(packageName);
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

  /// If [pubspecFile] has any dependencies on packages in [localDependencies],
  /// adds dependency_overrides entries to redirect them to the local version
  /// using path-based dependencies.
  ///
  /// If [additionalPackagesToOverride] are provided, they will get
  /// dependency_overrides even if there is no direct dependency. This is
  /// useful for overriding transitive dependencies.
  Future<_RewriteOutcome> _addDependencyOverridesIfNecessary(
    RepositoryPackage package,
    Map<String, RepositoryPackage> localDependencies, {
    Iterable<String> additionalPackagesToOverride = const <String>{},
  }) async {
    final String pubspecContents = package.pubspecFile.readAsStringSync();

    // Determine the dependencies to be overridden.
    final Pubspec pubspec = Pubspec.parse(pubspecContents);
    final Iterable<String> combinedDependencies = <String>[
      ...pubspec.dependencies.keys,
      ...pubspec.devDependencies.keys,
      ...additionalPackagesToOverride,
    ];
    final List<String> packagesToOverride = combinedDependencies
        .where(
            (String packageName) => localDependencies.containsKey(packageName))
        .toList();
    // Sort the combined list to avoid sort_pub_dependencies lint violations.
    packagesToOverride.sort();

    if (packagesToOverride.isEmpty) {
      return _RewriteOutcome.noChangesNeeded;
    }

    // Find the relative path to the common base.
    final String commonBasePath = packagesDir.path;
    final int packageDepth = path
        .split(path.relative(package.directory.absolute.path,
            from: commonBasePath))
        .length;
    final List<String> relativeBasePathComponents =
        List<String>.filled(packageDepth, '..');

    // Add the overrides.
    final YamlEditor editablePubspec = YamlEditor(pubspecContents);
    final YamlNode root = editablePubspec.parseAt(<String>[]);
    const String dependencyOverridesKey = 'dependency_overrides';
    // Ensure that there's a `dependencyOverridesKey` entry to update.
    if ((root as YamlMap)[dependencyOverridesKey] == null) {
      editablePubspec.update(<String>[dependencyOverridesKey], YamlMap());
    }
    for (final String packageName in packagesToOverride) {
      // Find the relative path from the common base to the local package.
      final List<String> repoRelativePathComponents = path.split(path.relative(
          localDependencies[packageName]!.path,
          from: commonBasePath));
      editablePubspec.update(<String>[
        dependencyOverridesKey,
        packageName
      ], <String, String>{
        'path': p.posix.joinAll(<String>[
          ...relativeBasePathComponents,
          ...repoRelativePathComponents,
        ])
      });
    }

    // Add the warning if it's not already there.
    String newContent = editablePubspec.toString();
    if (!newContent.contains(_dependencyOverrideWarningComment)) {
      newContent = newContent.replaceFirst('$dependencyOverridesKey:', '''

$_dependencyOverrideWarningComment
$dependencyOverridesKey:
''');
    }

    // Write the new pubspec.
    package.pubspecFile.writeAsStringSync(newContent);

    // Update any examples. This is important for cases like integration tests
    // of app-facing packages in federated plugins, where the app-facing
    // package depends directly on the implementation packages, but the
    // example app doesn't. Since integration tests are run in the example app,
    // it needs the overrides in order for tests to pass.
    for (final RepositoryPackage example in package.getExamples()) {
      _addDependencyOverridesIfNecessary(example, localDependencies,
          additionalPackagesToOverride: packagesToOverride);
    }

    return _RewriteOutcome.changed;
  }

  /// Returns all pubspecs anywhere under the packages directory.
  Future<List<File>> _getAllPubspecs() => packagesDir.parent
      .list(recursive: true, followLinks: false)
      .where((FileSystemEntity entity) =>
          entity is File && p.basename(entity.path) == 'pubspec.yaml')
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

    final Set<String> changedPackages = <String>{};
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
      final RepositoryPackage package =
          RepositoryPackage(packagesDir.fileSystem.file(changedPath).parent);
      // Ignored deleted packages, as they won't be published.
      if (!package.pubspecFile.existsSync()) {
        final String directoryName = p.posix.joinAll(path.split(path.relative(
            package.directory.absolute.path,
            from: packagesDir.path)));
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
      // TODO(stuartmorgan): Remove this special-casing once this tool checks
      // for major version differences relative to the dependencies being
      // updated rather than the version change in the PR:
      // https://github.com/flutter/flutter/issues/121246
      if (packageName == 'pigeon') {
        print('  Skipping $packageName; see '
            'https://github.com/flutter/flutter/issues/121246');
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

    final String pubspecGitPath = p.posix.joinAll(path.split(path.relative(
        package.pubspecFile.absolute.path,
        from: (await gitDir).path)));
    final GitVersionFinder gitVersionFinder = await retrieveVersionFinder();
    final Version? previousVersion =
        await gitVersionFinder.getPackageVersion(pubspecGitPath);
    if (previousVersion == null) {
      // The plugin is new, so nothing can be depending on it yet.
      return false;
    }
    final Version newVersion = pubspec.version!;
    if ((newVersion.major > 0 && newVersion.major != previousVersion.major) ||
        (newVersion.major == 0 && newVersion.minor != previousVersion.minor)) {
      // Breaking changes aren't targetted since they won't be picked up
      // automatically.
      return false;
    }
    return newVersion != previousVersion;
  }
}
