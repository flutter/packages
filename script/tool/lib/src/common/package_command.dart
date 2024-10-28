// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;
import 'dart:math';

import 'package:args/command_runner.dart';
import 'package:file/file.dart';
import 'package:git/git.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';
import 'package:yaml/yaml.dart';

import 'core.dart';
import 'git_version_finder.dart';
import 'output_utils.dart';
import 'process_runner.dart';
import 'repository_package.dart';

/// An entry in package enumeration for APIs that need to include extra
/// data about the entry.
class PackageEnumerationEntry {
  /// Creates a new entry for the given package.
  PackageEnumerationEntry(this.package, {required this.excluded});

  /// The package this entry corresponds to. Be sure to check `excluded` before
  /// using this, as having an entry does not necessarily mean that the package
  /// should be included in the processing of the enumeration.
  final RepositoryPackage package;

  /// Whether or not this package was excluded by the command invocation.
  final bool excluded;
}

/// Interface definition for all commands in this tool.
// TODO(stuartmorgan): Move most of this logic to PackageLoopingCommand.
abstract class PackageCommand extends Command<void> {
  /// Creates a command to operate on [packagesDir] with the given environment.
  PackageCommand(
    this.packagesDir, {
    this.processRunner = const ProcessRunner(),
    this.platform = const LocalPlatform(),
    GitDir? gitDir,
  }) : _gitDir = gitDir {
    thirdPartyPackagesDir = packagesDir.parent
        .childDirectory('third_party')
        .childDirectory('packages');

    argParser.addMultiOption(
      _packagesArg,
      help:
          'Specifies which packages the command should run on (before sharding).\n'
          'If a package name is the name of a plugin group, it will include '
          'the entire group; to avoid this, use group/package as the name '
          '(e.g., shared_preferences/shared_preferences), or pass '
          '--$_exactMatchOnlyArg',
      valueHelp: 'package1,package2,...',
      aliases: <String>[_pluginsLegacyAliasArg],
    );
    argParser.addOption(
      _shardIndexArg,
      help: 'Specifies the zero-based index of the shard to '
          'which the command applies.',
      valueHelp: 'i',
      defaultsTo: '0',
    );
    argParser.addOption(
      _shardCountArg,
      help: 'Specifies the number of shards into which packages are divided.',
      valueHelp: 'n',
      defaultsTo: '1',
    );
    argParser.addFlag(_exactMatchOnlyArg,
        help: 'Disables package group matching in package selection.',
        negatable: false);
    argParser.addMultiOption(
      _excludeArg,
      abbr: 'e',
      help: 'A list of packages to exclude from from this command.\n\n'
          'Alternately, a list of one or more YAML files that contain a list '
          'of packages to exclude.',
      defaultsTo: <String>[],
    );
    argParser.addFlag(_runOnChangedPackagesArg,
        negatable: false,
        help: 'Run the command on changed packages.\n'
            'If no packages have changed, or if there have been changes that may\n'
            'affect all packages, the command runs on all packages.\n'
            'Packages excluded with $_excludeArg are excluded even if changed.\n'
            'See $_baseShaArg if a custom base is needed to determine the diff.\n\n'
            'Cannot be combined with $_packagesArg.\n');
    argParser.addFlag(_runOnDirtyPackagesArg,
        negatable: false,
        help:
            'Run the command on packages with changes that have not been committed.\n'
            'Packages excluded with $_excludeArg are excluded even if changed.\n'
            'Cannot be combined with $_packagesArg.\n',
        hide: true);
    argParser.addFlag(_packagesForBranchArg,
        negatable: false,
        help: 'This runs on all packages changed in the last commit on main '
            '(or master), and behaves like --run-on-changed-packages on '
            'any other branch.\n\n'
            'Cannot be combined with $_packagesArg.\n\n'
            'This is intended for use in CI.\n',
        hide: true);
    argParser.addMultiOption(_filterPackagesArg,
        help: 'Filters any selected packages to only those included in this '
            'list. This is intended for use in CI with flags such as '
            '--$_packagesForBranchArg.\n\n'
            'Entries can be package names or YAML files that contain a list '
            'of package names.',
        defaultsTo: <String>[],
        hide: true);
    argParser.addFlag(_currentPackageArg,
        negatable: false,
        help:
            'Set the target package(s) based on the current working directory.\n'
            '- If the current working directory is (or is inside) a package, '
            'that package will be targeted.\n'
            '- If the current working directory is the root of a federated '
            'plugin group, that group will be targeted.\n'
            'Cannot be combined with $_packagesArg.\n');
    argParser.addOption(_baseShaArg,
        help: 'The base sha used to determine git diff. \n'
            'This is useful when $_runOnChangedPackagesArg is specified.\n'
            'If not specified, merge-base is used as base sha.');
    argParser.addOption(_baseBranchArg,
        help: 'The base branch whose merge base is used as the base SHA if '
            '--$_baseShaArg is not provided. \n'
            'If not specified, FETCH_HEAD is used as the base branch.');
    argParser.addFlag(_logTimingArg,
        help: 'Logs timing information.\n\n'
            'Currently only logs per-package timing for multi-package commands, '
            'but more information may be added in the future.');
  }

  // Package selection.
  static const String _packagesArg = 'packages';
  static const String _packagesForBranchArg = 'packages-for-branch';
  static const String _currentPackageArg = 'current-package';
  static const String _pluginsLegacyAliasArg = 'plugins';
  static const String _runOnChangedPackagesArg = 'run-on-changed-packages';
  static const String _runOnDirtyPackagesArg = 'run-on-dirty-packages';
  static const String _exactMatchOnlyArg = 'exact-match-only';
  static const String _excludeArg = 'exclude';
  static const String _filterPackagesArg = 'filter-packages-to';
  // Diff base selection.
  static const String _baseBranchArg = 'base-branch';
  static const String _baseShaArg = 'base-sha';
  // Sharding.
  static const String _shardCountArg = 'shardCount';
  static const String _shardIndexArg = 'shardIndex';
  // Utility.
  static const String _logTimingArg = 'log-timing';

  /// The directory containing the packages.
  final Directory packagesDir;

  /// The directory containing packages wrapping third-party code.
  late Directory thirdPartyPackagesDir;

  /// The process runner.
  ///
  /// This can be overridden for testing.
  final ProcessRunner processRunner;

  /// The current platform.
  ///
  /// This can be overridden for testing.
  final Platform platform;

  /// The git directory to use. If unset, [gitDir] populates it from the
  /// packages directory's enclosing repository.
  ///
  /// This can be mocked for testing.
  GitDir? _gitDir;

  int? _shardIndex;
  int? _shardCount;

  // Cached set of explicitly excluded packages.
  Set<String>? _excludedPackages;

  /// A context that matches the default for [platform].
  p.Context get path => platform.isWindows ? p.windows : p.posix;

  /// The command to use when running `flutter`.
  String get flutterCommand => platform.isWindows ? 'flutter.bat' : 'flutter';

  /// The shard of the overall command execution that this instance should run.
  int get shardIndex {
    if (_shardIndex == null) {
      _checkSharding();
    }
    return _shardIndex!;
  }

  /// The number of shards this command is divided into.
  int get shardCount {
    if (_shardCount == null) {
      _checkSharding();
    }
    return _shardCount!;
  }

  /// Returns the [GitDir] containing [packagesDir].
  Future<GitDir> get gitDir async {
    GitDir? gitDir = _gitDir;
    if (gitDir != null) {
      return gitDir;
    }

    // Ensure there are no symlinks in the path, as it can break
    // GitDir's allowSubdirectory:true.
    final String packagesPath = packagesDir.resolveSymbolicLinksSync();
    if (!await GitDir.isGitDir(packagesPath)) {
      printError('$packagesPath is not a valid Git repository.');
      throw ToolExit(2);
    }
    gitDir =
        await GitDir.fromExisting(packagesDir.path, allowSubdirectory: true);
    _gitDir = gitDir;
    return gitDir;
  }

  /// Convenience accessor for boolean arguments.
  bool getBoolArg(String key) {
    return (argResults![key] as bool?) ?? false;
  }

  /// Convenience accessor for boolean arguments.
  bool? getNullableBoolArg(String key) {
    return argResults![key] as bool?;
  }

  /// Convenience accessor for String arguments.
  String getStringArg(String key) {
    return (argResults![key] as String?) ?? '';
  }

  /// Convenience accessor for String arguments.
  String? getNullableStringArg(String key) {
    return argResults![key] as String?;
  }

  /// Convenience accessor for List<String> arguments.
  List<String> getStringListArg(String key) {
    // Clone the list so that if a caller modifies the result it won't change
    // the actual arguments list for future queries.
    return List<String>.from(argResults![key] as List<String>? ?? <String>[]);
  }

  /// If true, commands should log timing information that might be useful in
  /// analyzing their runtime (e.g., the per-package time for multi-package
  /// commands).
  bool get shouldLogTiming => getBoolArg(_logTimingArg);

  void _checkSharding() {
    final int? shardIndex = int.tryParse(getStringArg(_shardIndexArg));
    final int? shardCount = int.tryParse(getStringArg(_shardCountArg));
    if (shardIndex == null) {
      usageException('$_shardIndexArg must be an integer');
    }
    if (shardCount == null) {
      usageException('$_shardCountArg must be an integer');
    }
    if (shardCount < 1) {
      usageException('$_shardCountArg must be positive');
    }
    if (shardIndex < 0 || shardCount <= shardIndex) {
      usageException(
          '$_shardIndexArg must be in the half-open range [0..$shardCount[');
    }
    _shardIndex = shardIndex;
    _shardCount = shardCount;
  }

  /// Converts a list of items which are either package names or yaml files
  /// containing a list of package names to a flat list of package names by
  /// reading all the file contents.
  Set<String> _expandYamlInPackageList(List<String> items) {
    return items.expand<String>((String item) {
      if (item.endsWith('.yaml')) {
        final File file = packagesDir.fileSystem.file(item);
        return (loadYaml(file.readAsStringSync()) as YamlList)
            .toList()
            .cast<String>();
      }
      return <String>[item];
    }).toSet();
  }

  /// Returns the set of packages to exclude based on the `--exclude` argument.
  Set<String> getExcludedPackageNames() {
    final Set<String> excludedPackages = _excludedPackages ??
        _expandYamlInPackageList(getStringListArg(_excludeArg));
    // Cache for future calls.
    _excludedPackages = excludedPackages;
    return excludedPackages;
  }

  /// Returns the root diretories of the packages involved in this command
  /// execution.
  ///
  /// Depending on the command arguments, this may be a user-specified set of
  /// packages, the set of packages that should be run for a given diff, or all
  /// packages.
  ///
  /// By default, packages excluded via --exclude will not be in the stream, but
  /// they can be included by passing false for [filterExcluded].
  Stream<PackageEnumerationEntry> getTargetPackages(
      {bool filterExcluded = true}) async* {
    // To avoid assuming consistency of `Directory.list` across command
    // invocations, we collect and sort the package folders before sharding.
    // This is considered an implementation detail which is why the API still
    // uses streams.
    final List<PackageEnumerationEntry> allPackages =
        await _getAllPackages().toList();
    allPackages.sort((PackageEnumerationEntry p1, PackageEnumerationEntry p2) =>
        p1.package.path.compareTo(p2.package.path));
    final int shardSize = allPackages.length ~/ shardCount +
        (allPackages.length % shardCount == 0 ? 0 : 1);
    final int start = min(shardIndex * shardSize, allPackages.length);
    final int end = min(start + shardSize, allPackages.length);

    for (final PackageEnumerationEntry package
        in allPackages.sublist(start, end)) {
      if (!(filterExcluded && package.excluded)) {
        yield package;
      }
    }
  }

  /// Returns the root Dart package folders of the packages involved in this
  /// command execution, assuming there is only one shard. Depending on the
  /// command arguments, this may be a user-specified set of packages, the
  /// set of packages that should be run for a given diff, or all packages.
  ///
  /// This will return packages that have been excluded by the --exclude
  /// parameter, annotated in the entry as excluded.
  ///
  /// Packages can exist in the following places relative to the packages
  /// directory:
  ///
  /// 1. As a Dart package in a directory which is a direct child of the
  ///    packages directory. This is a non-plugin package, or a non-federated
  ///    plugin.
  /// 2. Several plugin packages may live in a directory which is a direct
  ///    child of the packages directory. This directory groups several Dart
  ///    packages which implement a single plugin. This directory contains an
  ///    "app-facing" package which declares the API for the plugin, a
  ///    platform interface package which declares the API for implementations,
  ///    and one or more platform-specific implementation packages.
  /// 3./4. Either of the above, but in a third_party/packages/ directory that
  ///    is a sibling of the packages directory. This is used for a small number
  ///    of packages in the flutter/packages repository.
  Stream<PackageEnumerationEntry> _getAllPackages() async* {
    final Set<String> packageSelectionFlags = <String>{
      _packagesArg,
      _runOnChangedPackagesArg,
      _runOnDirtyPackagesArg,
      _packagesForBranchArg,
      _currentPackageArg,
    };
    if (packageSelectionFlags
            .where((String flag) => argResults!.wasParsed(flag))
            .length >
        1) {
      printError('Only one of the package selection arguments '
          '(${packageSelectionFlags.join(", ")}) '
          'can be provided.');
      throw ToolExit(exitInvalidArguments);
    }

    // Whether to require that a package name exactly match to be included,
    // rather than allowing package groups for federated plugins. Any cases
    // where the set of packages is determined programatically based on repo
    // state should use exact matching.
    final bool allowGroupMatching = !(getBoolArg(_exactMatchOnlyArg) ||
        argResults!.wasParsed(_runOnChangedPackagesArg) ||
        argResults!.wasParsed(_runOnDirtyPackagesArg) ||
        argResults!.wasParsed(_packagesForBranchArg));

    Set<String> packages = Set<String>.from(getStringListArg(_packagesArg));

    final GitVersionFinder? changedFileFinder;
    if (getBoolArg(_runOnChangedPackagesArg)) {
      changedFileFinder = await retrieveVersionFinder();
    } else if (getBoolArg(_packagesForBranchArg)) {
      final String? branch = await _getBranch();
      if (branch == null) {
        printError('Unable to determine branch; --$_packagesForBranchArg can '
            'only be used in a git repository.');
        throw ToolExit(exitInvalidArguments);
      } else {
        // Configure the change finder the correct mode for the branch.
        // Log the mode to make it easier to audit logs to see that the
        // intended diff was used (or why).
        final bool lastCommitOnly;
        if (branch == 'main' || branch == 'master') {
          print('--$_packagesForBranchArg: running on default branch.');
          lastCommitOnly = true;
        } else if (await _isCheckoutFromBranch('main')) {
          print(
              '--$_packagesForBranchArg: running on a commit from default branch.');
          lastCommitOnly = true;
        } else {
          print('--$_packagesForBranchArg: running on branch "$branch".');
          lastCommitOnly = false;
        }
        if (lastCommitOnly) {
          print(
              '--$_packagesForBranchArg: using parent commit as the diff base.');
          changedFileFinder = GitVersionFinder(await gitDir, baseSha: 'HEAD~');
        } else {
          changedFileFinder = await retrieveVersionFinder();
        }
      }
    } else {
      changedFileFinder = null;
    }

    if (changedFileFinder != null) {
      final String baseSha = await changedFileFinder.getBaseSha();
      final List<String> changedFiles =
          await changedFileFinder.getChangedFiles();
      if (_changesRequireFullTest(changedFiles)) {
        print('Running for all packages, since a file has changed that could '
            'affect the entire repository.');
      } else {
        print(
            'Running for all packages that have diffs relative to "$baseSha"\n');
        packages = _getChangedPackageNames(changedFiles);
      }
    } else if (getBoolArg(_runOnDirtyPackagesArg)) {
      final GitVersionFinder gitVersionFinder =
          GitVersionFinder(await gitDir, baseSha: 'HEAD');
      print('Running for all packages that have uncommitted changes\n');
      // _changesRequireFullTest is deliberately not used here, as this flag is
      // intended for use in CI to re-test packages changed by
      // 'make-deps-path-based'.
      packages = _getChangedPackageNames(
          await gitVersionFinder.getChangedFiles(includeUncommitted: true));
      // For the same reason, empty is not treated as "all packages" as it is
      // for other flags.
      if (packages.isEmpty) {
        return;
      }
    } else if (getBoolArg(_currentPackageArg)) {
      final String? currentPackageName = _getCurrentDirectoryPackageName();
      if (currentPackageName == null) {
        printError('Unable to determine packages; --$_currentPackageArg can '
            'only be used within a repository package or package group.');
        throw ToolExit(exitInvalidArguments);
      }
      packages = <String>{currentPackageName};
    }

    final Set<String> excludedPackageNames = getExcludedPackageNames();
    final bool hasFilter = argResults?.wasParsed(_filterPackagesArg) ?? false;
    final Set<String>? excludeAllButPackageNames = hasFilter
        ? _expandYamlInPackageList(getStringListArg(_filterPackagesArg))
        : null;
    if (excludeAllButPackageNames != null &&
        excludeAllButPackageNames.isNotEmpty) {
      final List<String> sortedList = excludeAllButPackageNames.toList()
        ..sort();
      print('--$_filterPackagesArg is excluding packages that are not '
          'included in: ${sortedList.join(',')}');
    }
    // Returns true if a package that could be identified by any of
    // `possibleNames` should be excluded.
    bool isExcluded(Set<String> possibleNames) {
      if (excludedPackageNames.intersection(possibleNames).isNotEmpty) {
        return true;
      }
      return excludeAllButPackageNames != null &&
          excludeAllButPackageNames.intersection(possibleNames).isEmpty;
    }

    await for (final RepositoryPackage package in _everyTopLevelPackage()) {
      if (packages.isEmpty ||
          packages
              .intersection(_possiblePackageIdentifiers(package,
                  allowGroup: allowGroupMatching))
              .isNotEmpty) {
        // Exclusion is always human input, so groups should always be allowed
        // unless they have been specifically forbidden.
        final bool excluded = isExcluded(_possiblePackageIdentifiers(package,
            allowGroup: !getBoolArg(_exactMatchOnlyArg)));
        yield PackageEnumerationEntry(package, excluded: excluded);
      }
    }
  }

  /// Returns every top-level package in the repository, according to repository
  /// conventions.
  ///
  /// In particular, it returns:
  /// - Every package that is a direct child of one of the know "packages"
  ///   directories.
  /// - Every package that is a direct child of a non-package subdirectory of
  ///   one of those directories (to cover federated plugin groups).
  Stream<RepositoryPackage> _everyTopLevelPackage() async* {
    for (final Directory dir in <Directory>[
      packagesDir,
      if (thirdPartyPackagesDir.existsSync()) thirdPartyPackagesDir,
    ]) {
      await for (final FileSystemEntity entity
          in dir.list(followLinks: false)) {
        // A top-level Dart package is a standard package.
        if (isPackage(entity)) {
          yield RepositoryPackage(entity as Directory);
        } else if (entity is Directory) {
          // Look for Dart packages under this top-level directory; this is the
          // standard structure for federated plugins.
          await for (final FileSystemEntity subdir
              in entity.list(followLinks: false)) {
            if (isPackage(subdir)) {
              yield RepositoryPackage(subdir as Directory);
            }
          }
        }
      }
    }
  }

  Set<String> _possiblePackageIdentifiers(
    RepositoryPackage package, {
    required bool allowGroup,
  }) {
    final String packageName = path.basename(package.path);
    if (package.isFederated) {
      // There are three ways for a federated plugin to be identified:
      // - package name (path_provider_android).
      // - fully specified name (path_provider/path_provider_android).
      // - group name (path_provider), which includes all packages in
      //   the group.
      final io.Directory parentDir = package.directory.parent;
      return <String>{
        packageName,
        path.relative(package.path,
            from: parentDir.parent.path), // fully specified
        if (allowGroup) path.basename(parentDir.path), // group name
      };
    } else {
      return <String>{packageName};
    }
  }

  /// Returns all Dart package folders (typically, base package + example) of
  /// the packages involved in this command execution.
  ///
  /// By default, packages excluded via --exclude will not be in the stream, but
  /// they can be included by passing false for [filterExcluded].
  ///
  /// Subpackages are guaranteed to be after the containing package in the
  /// stream.
  Stream<PackageEnumerationEntry> getTargetPackagesAndSubpackages(
      {bool filterExcluded = true}) async* {
    await for (final PackageEnumerationEntry package
        in getTargetPackages(filterExcluded: filterExcluded)) {
      yield package;
      yield* getSubpackages(package.package).map(
          (RepositoryPackage subPackage) =>
              PackageEnumerationEntry(subPackage, excluded: package.excluded));
    }
  }

  /// Returns all Dart package folders (e.g., examples) under the given package.
  Stream<RepositoryPackage> getSubpackages(RepositoryPackage package,
      {bool filterExcluded = true}) async* {
    yield* package.directory
        .list(recursive: true, followLinks: false)
        .where(isPackage)
        .map((FileSystemEntity directory) =>
            // isPackage guarantees that this cast is valid.
            RepositoryPackage(directory as Directory));
  }

  /// Returns the files contained, recursively, within the packages
  /// involved in this command execution.
  Stream<File> getFiles() {
    return getTargetPackages().asyncExpand<File>(
        (PackageEnumerationEntry entry) => getFilesForPackage(entry.package));
  }

  /// Returns the files contained, recursively, within [package].
  Stream<File> getFilesForPackage(RepositoryPackage package) {
    return package.directory
        .list(recursive: true, followLinks: false)
        .where((FileSystemEntity entity) => entity is File)
        .cast<File>();
  }

  /// Retrieve an instance of [GitVersionFinder] based on `_baseShaArg` and [gitDir].
  ///
  /// Throws tool exit if [gitDir] nor root directory is a git directory.
  Future<GitVersionFinder> retrieveVersionFinder() async {
    final String? baseSha = getNullableStringArg(_baseShaArg);
    final String? baseBranch =
        baseSha == null ? getNullableStringArg(_baseBranchArg) : null;

    final GitVersionFinder gitVersionFinder = GitVersionFinder(await gitDir,
        baseSha: baseSha, baseBranch: baseBranch);
    return gitVersionFinder;
  }

  // Returns the names of packages that have been changed given a list of
  // changed files.
  //
  // The names will either be the actual package names, or potentially
  // group/name specifiers (for example, path_provider/path_provider) for
  // packages in federated plugins.
  //
  // The paths must use POSIX separators (e.g., as provided by git output).
  Set<String> _getChangedPackageNames(List<String> changedFiles) {
    final Set<String> packages = <String>{};

    // A helper function that returns true if candidatePackageName looks like an
    // implementation package of a plugin called pluginName. Used to determine
    // if .../packages/parentName/candidatePackageName/...
    // looks like a path in a federated plugin package (candidatePackageName)
    // rather than a top-level package (parentName).
    bool isFederatedPackage(String candidatePackageName, String parentName) {
      return candidatePackageName == parentName ||
          candidatePackageName.startsWith('${parentName}_');
    }

    for (final String path in changedFiles) {
      final List<String> pathComponents = p.posix.split(path);
      final int packagesIndex =
          pathComponents.indexWhere((String element) => element == 'packages');
      if (packagesIndex != -1) {
        // Find the name of the directory directly under packages. This is
        // either the name of the package, or a plugin group directory for
        // a federated plugin.
        final String topLevelName = pathComponents[packagesIndex + 1];
        String packageName = topLevelName;
        if (packagesIndex + 2 < pathComponents.length &&
            isFederatedPackage(
                pathComponents[packagesIndex + 2], topLevelName)) {
          // This looks like a federated package; use the full specifier if
          // the name would be ambiguous (i.e., for the app-facing package).
          packageName = pathComponents[packagesIndex + 2];
          if (packageName == topLevelName) {
            packageName = '$topLevelName/$packageName';
          }
        }
        packages.add(packageName);
      }
    }
    if (packages.isEmpty) {
      print('No changed packages.');
    } else {
      final String changedPackages = packages.join(',');
      print('Changed packages: $changedPackages');
    }
    return packages;
  }

  String? _getCurrentDirectoryPackageName() {
    // Ensure that the current directory is within the packages directory.
    final Directory absolutePackagesDir = packagesDir.absolute;
    Directory currentDir = packagesDir.fileSystem.currentDirectory.absolute;
    if (!currentDir.path.startsWith(absolutePackagesDir.path) ||
        currentDir.path == packagesDir.path) {
      return null;
    }
    // If the current directory is a direct subdirectory of the packages
    // directory, then that's the target.
    if (currentDir.parent.path == absolutePackagesDir.path) {
      return currentDir.basename;
    }
    // Otherwise, walk up until a package is found...
    while (!isPackage(currentDir)) {
      currentDir = currentDir.parent;
      if (currentDir.path == absolutePackagesDir.path) {
        return null;
      }
    }
    // ... and then check whether it has an enclosing package.
    final RepositoryPackage package = RepositoryPackage(currentDir);
    final RepositoryPackage? enclosingPackage = package.getEnclosingPackage();
    final RepositoryPackage rootPackage = enclosingPackage ?? package;
    final String name = rootPackage.directory.basename;
    // For an app-facing package in a federated plugin, return the fully
    // qualified name, since returning just the name will cause the entire
    // group to run.
    if (rootPackage.directory.parent.basename == name) {
      return '$name/$name';
    }
    return name;
  }

  // Returns true if the current checkout is on an ancestor of [branch].
  //
  // This is used because CI may check out a specific hash rather than a branch,
  // in which case branch-name detection won't work.
  Future<bool> _isCheckoutFromBranch(String branchName) async {
    // The target branch may not exist locally; try some common remote names for
    // the branch as well.
    final List<String> candidateBranchNames = <String>[
      branchName,
      'origin/$branchName',
      'upstream/$branchName',
    ];
    for (final String branch in candidateBranchNames) {
      final io.ProcessResult result = await (await gitDir).runCommand(
          <String>['merge-base', '--is-ancestor', 'HEAD', branch],
          throwOnError: false);
      if (result.exitCode == 0) {
        return true;
      } else if (result.exitCode == 1) {
        // 1 indicates that the branch was successfully checked, but it's not
        // an ancestor.
        return false;
      }
      // Any other return code is an error, such as `branch` not being a valid
      // name in the repository, so try other name variants.
    }
    return false;
  }

  Future<String?> _getBranch() async {
    final io.ProcessResult branchResult = await (await gitDir).runCommand(
        <String>['rev-parse', '--abbrev-ref', 'HEAD'],
        throwOnError: false);
    if (branchResult.exitCode != 0) {
      return null;
    }
    return (branchResult.stdout as String).trim();
  }

  // Returns true if one or more files changed that have the potential to affect
  // any packages (e.g., CI script changes).
  bool _changesRequireFullTest(List<String> changedFiles) {
    const List<String> specialFiles = <String>[
      '.ci.yaml', // LUCI config.
      '.clang-format', // ObjC and C/C++ formatting options.
      'analysis_options.yaml', // Dart analysis settings.
    ];
    const List<String> specialDirectories = <String>[
      '.ci/', // Support files for CI.
      'script/', // This tool.
    ];
    // Directory entries must end with / to avoid over-matching, since the
    // check below is done via string prefixing.
    assert(specialDirectories.every((String dir) => dir.endsWith('/')));

    return changedFiles.any((String path) =>
        specialFiles.contains(path) ||
        specialDirectories.any((String dir) => path.startsWith(dir)));
  }
}
