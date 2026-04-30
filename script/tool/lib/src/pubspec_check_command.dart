// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'common/core.dart';
import 'common/file_utils.dart';
import 'common/output_utils.dart';
import 'common/package_looping_command.dart';
import 'common/repository_package.dart';
import 'validators/pubspec_validator.dart';

// Config file names.
const String _versionConfigFileName = 'min_version.yaml';
const String _allowedPinnedDependenciesFileName =
    'allowed_pinned_dependencies.yaml';
const String _allowedUnpinnedDependenciesFileName =
    'allowed_unpinned_dependencies.yaml';

const int _exitCodeVersionConfigIssue = 3;

/// A command to enforce pubspec conventions across the repository.
///
/// This both ensures that repo best practices for which optional fields are
/// used are followed, and that the structure is consistent to make edits
/// across multiple pubspec files easier.
class PubspecCheckCommand extends PackageLoopingCommand {
  /// Creates an instance of the version check command.
  PubspecCheckCommand(
    super.packagesDir, {
    super.processRunner,
    super.platform,
    super.gitDir,
  });

  // The names of all published packages in the repository.
  final AllowPackageLists _allowedPackages = (
    local: <String>{},
    pinned: <String>{},
    unpinned: <String>{},
  );

  late final String _minMinFlutterVersion;

  @override
  final String name = 'pubspec-check';

  @override
  List<String> get aliases => <String>['check-pubspec'];

  @override
  final String description =
      'Checks that pubspecs follow repository conventions.';

  @override
  bool get hasLongOutput => false;

  @override
  PackageLoopingType get packageLoopingType =>
      PackageLoopingType.includeAllSubpackages;

  @override
  Future<void> initializeRun() async {
    await _loadAllowedDependencies();
    _minMinFlutterVersion = await _loadMinMinFlutterVersion();
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final validator = PubspecValidator(
      path: path,
      indentation: indentation,
      warningLogger: printWarning,
      allowedPackages: _allowedPackages,
      repoRoot: packagesDir.parent,
      minMinFlutterVersion: _minMinFlutterVersion,
    );
    final List<String> errors = await validator.validatePubspec(package);
    return errors.isEmpty
        ? PackageResult.success()
        : PackageResult.fail(errors);
  }

  Stream<String> _findAllPublishedPackages() async* {
    for (final File pubspecFile
        in (await packagesDir.parent
                .list(recursive: true, followLinks: false)
                .toList())
            .whereType<File>()
            .where(
              (File entity) => p.basename(entity.path) == 'pubspec.yaml',
            )) {
      final Pubspec? pubspec = _tryParsePubspec(pubspecFile.readAsStringSync());
      if (pubspec != null && pubspec.publishTo != 'none') {
        yield pubspec.name;
      }
    }
  }

  Future<void> _loadAllowedDependencies() async {
    final Directory repoRoot = packagesDir.fileSystem.directory(
      (await gitDir).path,
    );
    final Directory toolConfigDir = toolConfigDirectory(repoRoot);

    // Find all local, published packages.
    _allowedPackages.local.addAll(await _findAllPublishedPackages().toList());
    // Load explicitly allowed packages.
    _allowedPackages.unpinned.addAll(
      loadYamlList(
            toolConfigDir.childFile(_allowedUnpinnedDependenciesFileName),
          ) ??
          <String>[],
    );
    _allowedPackages.pinned.addAll(
      loadYamlList(
            toolConfigDir.childFile(_allowedPinnedDependenciesFileName),
          ) ??
          <String>[],
    );
  }

  Future<String> _loadMinMinFlutterVersion() async {
    final Directory repoRoot = packagesDir.fileSystem.directory(
      (await gitDir).path,
    );
    final File versionConfig = toolConfigDirectory(
      repoRoot,
    ).childFile(_versionConfigFileName);
    if (!versionConfig.existsSync()) {
      printError(
        'Minimum version configuration file not found at $_versionConfigFileName',
      );
      return '';
    }
    const minFlutterKey = 'min_flutter';
    final config = loadYaml(versionConfig.readAsStringSync()) as YamlMap?;
    if (config == null || config[minFlutterKey] == null) {
      printError(
        '$_versionConfigFileName must be a map containing a "$minFlutterKey" entry',
      );
      throw ToolExit(_exitCodeVersionConfigIssue);
    }
    return (config[minFlutterKey] as String).trim();
  }

  Pubspec? _tryParsePubspec(String pubspecContents) {
    try {
      return Pubspec.parse(pubspecContents);
    } on Exception catch (exception) {
      print('  Cannot parse pubspec.yaml: $exception');
    }
    return null;
  }
}
