// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:path/path.dart' as p;
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:yaml/yaml.dart';

import 'core.dart';

export 'package:pubspec_parse/pubspec_parse.dart' show Pubspec;
export 'core.dart' show FlutterPlatform;

// The template file name used to draft a pending changelog file.
// This file will not be picked up by the batch release process.
const String _kTemplateFileName = 'template.yaml';

/// A package in the repository.
//
// TODO(stuartmorgan): Add more package-related info here, such as an on-demand
// cache of the parsed pubspec.
class RepositoryPackage {
  /// Creates a representation of the package at [directory].
  RepositoryPackage(this.directory);

  /// The location of the package.
  final Directory directory;

  /// The path to the package.
  String get path => directory.path;

  /// Returns the string to use when referring to the package in user-targeted
  /// messages.
  ///
  /// Callers should not expect a specific format for this string, since
  /// it uses heuristics to try to be precise without being overly verbose. If
  /// an exact format (e.g., published name, or basename) is required, that
  /// should be used instead.
  String get displayName {
    List<String> components = directory.fileSystem.path.split(directory.path);
    // Remove everything up to the packages directory.
    final int packagesIndex = components.indexOf('packages');
    if (packagesIndex != -1) {
      components = components.sublist(packagesIndex + 1);
    }
    // For the common federated plugin pattern of `foo/foo_subpackage`, drop
    // the first part since it's not useful.
    if (components.length >= 2 &&
        components[1].startsWith('${components[0]}_')) {
      components = components.sublist(1);
    }
    return p.posix.joinAll(components);
  }

  /// The package's top-level pubspec.yaml.
  File get pubspecFile => directory.childFile('pubspec.yaml');

  /// The package's top-level README.
  File get readmeFile => directory.childFile('README.md');

  /// The package's top-level README.
  File get changelogFile => directory.childFile('CHANGELOG.md');

  /// The package's top-level README.
  File get authorsFile => directory.childFile('AUTHORS');

  /// The package's top-level ci_config.yaml.
  File get ciConfigFile => directory.childFile('ci_config.yaml');

  /// The lib directory containing the package's code.
  Directory get libDirectory => directory.childDirectory('lib');

  /// The test directory containing the package's Dart tests.
  Directory get testDirectory => directory.childDirectory('test');

  /// The path to the script that is run by the `custom-test` command.
  File get customTestScript =>
      directory.childDirectory('tool').childFile('run_tests.dart');

  /// The path to the script that is run before publishing.
  File get prePublishScript =>
      directory.childDirectory('tool').childFile('pre_publish.dart');

  /// The directory containing pending changelog entries.
  Directory get pendingChangelogsDirectory =>
      directory.childDirectory('pending_changelogs');

  /// Returns the directory containing support for [platform].
  Directory platformDirectory(FlutterPlatform platform) {
    late final String directoryName;
    switch (platform) {
      case FlutterPlatform.android:
        directoryName = 'android';
      case FlutterPlatform.ios:
        directoryName = 'ios';
      case FlutterPlatform.linux:
        directoryName = 'linux';
      case FlutterPlatform.macos:
        directoryName = 'macos';
      case FlutterPlatform.web:
        directoryName = 'web';
      case FlutterPlatform.windows:
        directoryName = 'windows';
    }
    return directory.childDirectory(directoryName);
  }

  /// Returns true if the package is an app that supports [platform].
  ///
  /// The "app" prefix on this method is because this currently only works
  /// for app packages (e.g., examples).
  // TODO(stuartmorgan): Add support for non-app packages, by parsing the
  // pubspec for `flutter:platform:` or `platform:` sections.
  bool appSupportsPlatform(FlutterPlatform platform) {
    return platformDirectory(platform).existsSync();
  }

  late final Pubspec _parsedPubspec = Pubspec.parse(
    pubspecFile.readAsStringSync(),
  );

  /// Returns the parsed [pubspecFile].
  ///
  /// Caches for future use.
  Pubspec parsePubspec() => _parsedPubspec;

  late final CiConfig? _parsedCiConfig = ciConfigFile.existsSync()
      ? CiConfig._parse(ciConfigFile.readAsStringSync())
      : null;

  /// Returns the parsed [ciConfigFile], or null if it does not exist.
  ///
  /// Throws if the file exists but is not a valid ci_config.yaml.
  CiConfig? parseCiConfig() => _parsedCiConfig;

  /// Returns true if the package depends on Flutter.
  bool requiresFlutter() {
    const flutterDependency = 'flutter';
    final Pubspec pubspec = parsePubspec();
    return pubspec.dependencies.containsKey(flutterDependency) ||
        pubspec.devDependencies.containsKey(flutterDependency);
  }

  /// True if this appears to be a federated plugin package, according to
  /// repository conventions.
  bool get isFederated =>
      directory.parent.basename != 'packages' &&
      directory.basename.startsWith(directory.parent.basename);

  /// True if this appears to be the app-facing package of a federated plugin,
  /// according to repository conventions.
  bool get isAppFacing =>
      directory.parent.basename != 'packages' &&
      directory.basename == directory.parent.basename;

  /// True if this appears to be a platform interface package, according to
  /// repository conventions.
  bool get isPlatformInterface =>
      directory.basename.endsWith('_platform_interface');

  /// True if this appears to be a platform implementation package, according to
  /// repository conventions.
  bool get isPlatformImplementation =>
      // Any part of a federated plugin that isn't the platform interface and
      // isn't the app-facing package should be an implementation package.
      isFederated &&
      !isPlatformInterface &&
      directory.basename != directory.parent.basename;

  /// True if this appears to be an example package, according to package
  /// conventions.
  bool get isExample {
    final RepositoryPackage? enclosingPackage = getEnclosingPackage();
    if (enclosingPackage == null) {
      // An example package is enclosed in another package.
      return false;
    }
    // Check whether this is one of the enclosing package's examples.
    return enclosingPackage.getExamples().any(
      (RepositoryPackage p) => p.path == path,
    );
  }

  /// Returns the Flutter example packages contained in the package, if any.
  Iterable<RepositoryPackage> getExamples() {
    final Directory exampleDirectory = directory.childDirectory('example');
    if (!exampleDirectory.existsSync()) {
      return <RepositoryPackage>[];
    }
    if (isPackage(exampleDirectory)) {
      return <RepositoryPackage>[RepositoryPackage(exampleDirectory)];
    }
    // Only look at the subdirectories of the example directory if the example
    // directory itself is not a Dart package, and only look one level below the
    // example directory for other Dart packages.
    return exampleDirectory
        .listSync()
        .where((FileSystemEntity entity) => isPackage(entity))
        // isPackage guarantees that the cast to Directory is safe.
        .map(
          (FileSystemEntity entity) => RepositoryPackage(entity as Directory),
        );
  }

  /// Returns the package that this package is a part of, if any.
  ///
  /// Currently this is limited to checking up two directories, since that
  /// covers all the example structures currently used.
  RepositoryPackage? getEnclosingPackage() {
    final Directory parent = directory.parent;
    if (isPackage(parent)) {
      return RepositoryPackage(parent);
    }
    if (isPackage(parent.parent)) {
      return RepositoryPackage(parent.parent);
    }
    return null;
  }

  /// Returns all Dart package folders (e.g., examples) under this package.
  Iterable<RepositoryPackage> getSubpackages({bool includeExamples = true}) {
    return directory
        .listSync(recursive: true, followLinks: false)
        .where(isPackage)
        .map(
          (FileSystemEntity directory) =>
              // isPackage guarantees that this cast is valid.
              RepositoryPackage(directory as Directory),
        )
        .where(
          (RepositoryPackage p) =>
              includeExamples || (p.directory.basename != 'example'),
        );
  }

  /// Returns true if the package is not marked as "publish_to: none".
  bool isPublishable() {
    return parsePubspec().publishTo != 'none';
  }

  /// Returns the parsed changelog entries for the package.
  ///
  /// This method reads through the files in the pending_changelogs folder
  /// and parses each file as a changelog entry.
  ///
  /// Throws if the folder does not exist, or if any of the files are not
  /// valid changelog entries.
  List<PendingChangelogEntry> getPendingChangelogs() {
    final List<PendingChangelogEntry> entries = <PendingChangelogEntry>[];

    final Directory pendingChangelogsDir = pendingChangelogsDirectory;
    if (!pendingChangelogsDir.existsSync()) {
      throw FormatException(
          'No pending_changelogs folder found for $displayName.');
    }

    final List<File> allFiles =
        pendingChangelogsDir.listSync().whereType<File>().toList();

    final List<File> pendingChangelogFiles = <File>[];
    for (final File file in allFiles) {
      final String basename = p.basename(file.path);
      if (basename.endsWith('.yaml')) {
        if (basename != _kTemplateFileName) {
          pendingChangelogFiles.add(file);
        }
      } else {
        throw FormatException(
            'Found non-YAML file in pending_changelogs: ${file.path}');
      }
    }

    for (final File file in pendingChangelogFiles) {
      try {
        entries
            .add(PendingChangelogEntry._parse(file.readAsStringSync(), file));
      } on FormatException catch (e) {
        throw FormatException(
            'Malformed pending changelog file: ${file.path}\n$e');
      }
    }
    return entries;
  }
}

/// A class representing the parsed content of a `ci_config.yaml` file.
class CiConfig {
  /// Creates a [CiConfig] from a parsed YAML map.
  CiConfig._(this.isBatchRelease);

  /// Parses a [CiConfig] from a YAML string.
  ///
  /// Throws if the YAML is not a valid ci_config.yaml.
  factory CiConfig._parse(String yaml) {
    final Object? loaded = loadYaml(yaml);
    if (loaded is! YamlMap) {
      throw const FormatException('Root of ci_config.yaml must be a map.');
    }

    _checkCiConfigEntries(loaded, syntax: _validCiConfigSyntax);

    bool isBatchRelease = false;
    final Object? release = loaded['release'];
    if (release is Map) {
      isBatchRelease = release['batch'] == true;
    }

    return CiConfig._(isBatchRelease);
  }

  static const Map<String, Object?> _validCiConfigSyntax = <String, Object?>{
    'release': <String, Object?>{
      'batch': <bool>{true, false}
    },
  };

  /// Returns true if the package is configured for batch release.
  final bool isBatchRelease;

  static void _checkCiConfigEntries(YamlMap config,
      {required Map<String, Object?> syntax, String configPrefix = ''}) {
    for (final MapEntry<Object?, Object?> entry in config.entries) {
      if (!syntax.containsKey(entry.key)) {
        throw FormatException(
            'Unknown key `${entry.key}` in config${_formatConfigPrefix(configPrefix)}, the possible keys are ${syntax.keys.toList()}');
      } else {
        final Object syntaxValue = syntax[entry.key]!;
        final String newConfigPrefix = configPrefix.isEmpty
            ? entry.key! as String
            : '$configPrefix.${entry.key}';
        if (syntaxValue is Set) {
          if (!syntaxValue.contains(entry.value)) {
            throw FormatException(
                'Invalid value `${entry.value}` for key${_formatConfigPrefix(newConfigPrefix)}, the possible values are ${syntaxValue.toList()}');
          }
        } else if (entry.value is! YamlMap) {
          throw FormatException(
              'Invalid value `${entry.value}` for key${_formatConfigPrefix(newConfigPrefix)}, the value must be a map');
        } else {
          _checkCiConfigEntries(entry.value! as YamlMap,
              syntax: syntaxValue as Map<String, Object?>,
              configPrefix: newConfigPrefix);
        }
      }
    }
  }

  static String _formatConfigPrefix(String configPrefix) =>
      configPrefix.isEmpty ? '' : ' `$configPrefix`';
}

/// The type of version change described by a changelog entry.
///
/// The order of the enum values is important as it is used to determine which version
/// take priority when multiple version changes are specified. The top most value
/// (the samller the index) has the highest priority.
enum VersionChange {
  /// A major version change (e.g., 1.2.3 -> 2.0.0).
  major,

  /// A minor version change (e.g., 1.2.3 -> 1.3.0).
  minor,

  /// A patch version change (e.g., 1.2.3 -> 1.2.4).
  patch,

  /// No version change.
  skip,
}

/// Represents a single entry in the pending changelog.
class PendingChangelogEntry {
  /// Creates a new pending changelog entry.
  PendingChangelogEntry(
      {required this.changelog, required this.version, required this.file});

  /// Creates a PendingChangelogEntry from a YAML string.
  ///
  /// Throws if the YAML is not a valid pending changelog entry.
  factory PendingChangelogEntry._parse(String yamlContent, File file) {
    final dynamic yaml = loadYaml(yamlContent);
    if (yaml is! YamlMap) {
      throw FormatException(
          'Expected a YAML map, but found ${yaml.runtimeType}.');
    }

    final dynamic changelogYaml = yaml['changelog'];
    if (changelogYaml is! String) {
      throw FormatException(
          'Expected "changelog" to be a string, but found ${changelogYaml.runtimeType}.');
    }
    final String changelog = changelogYaml.trim();

    final String? versionString = yaml['version'] as String?;
    if (versionString == null) {
      throw const FormatException('Missing "version" key.');
    }
    final VersionChange version = VersionChange.values.firstWhere(
      (VersionChange e) => e.name == versionString,
      orElse: () =>
          throw FormatException('Invalid version type: $versionString'),
    );

    return PendingChangelogEntry(
        changelog: changelog, version: version, file: file);
  }

  /// The changelog messages for this entry.
  final String changelog;

  /// The type of version change for this entry.
  final VersionChange version;

  /// The file that this entry was parsed from.
  final File file;
}
