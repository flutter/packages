// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:path/path.dart' as p;

import 'common/output_utils.dart';
import 'common/package_looping_command.dart';
import 'common/repository_package.dart';
import 'validators/pubspec_validator.dart';

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
  }) {
    argParser.addOption(
      _minMinFlutterVersionFlag,
      help:
          'The minimum Flutter version to allow as the minimum SDK constraint.',
    );
    argParser.addMultiOption(
      _allowDependenciesFlag,
      help:
          'Packages (comma separated) that are allowed as dependencies or '
          'dev_dependencies.\n\n'
          'Alternately, a list of one or more YAML files that contain a list '
          'of allowed dependencies.',
      defaultsTo: <String>[],
    );
    argParser.addMultiOption(
      _allowPinnedDependenciesFlag,
      help:
          'Packages (comma separated) that are allowed as dependencies or '
          'dev_dependencies only if pinned to an exact version.\n\n'
          'Alternately, a list of one or more YAML files that contain a list '
          'of allowed pinned dependencies.',
      defaultsTo: <String>[],
    );
  }

  static const String _minMinFlutterVersionFlag = 'min-min-flutter-version';
  static const String _allowDependenciesFlag = 'allow-dependencies';
  static const String _allowPinnedDependenciesFlag =
      'allow-pinned-dependencies';

  // The names of all published packages in the repository.
  final AllowPackageLists _allowedPackages = (
    local: <String>{},
    pinned: <String>{},
    unpinned: <String>{},
  );

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
    // Find all local, published packages.
    _allowedPackages.local.addAll(await _findAllPublishedPackages().toList());
    // Load explicitly allowed packages.
    _allowedPackages.unpinned.addAll(getYamlListArg(_allowDependenciesFlag));
    _allowedPackages.pinned.addAll(
      getYamlListArg(_allowPinnedDependenciesFlag),
    );
  }

  @override
  Future<PackageResult> runForPackage(RepositoryPackage package) async {
    final validator = PubspecValidator(
      path: path,
      indentation: indentation,
      warningLogger: printWarning,
      allowedPackages: _allowedPackages,
      repoRoot: packagesDir.parent,
      minMinFlutterVersion: getStringArg(_minMinFlutterVersionFlag),
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

  Pubspec? _tryParsePubspec(String pubspecContents) {
    try {
      return Pubspec.parse(pubspecContents);
    } on Exception catch (exception) {
      print('  Cannot parse pubspec.yaml: $exception');
    }
    return null;
  }
}
