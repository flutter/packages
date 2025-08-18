// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:yaml/yaml.dart';

import 'base/common.dart';
import 'base/file_system.dart';
import 'base/logger.dart';
import 'base/project.dart';

/// Represents subdirectories of the flutter project that can be independently created.
///
/// This includes each supported platform as well as a component that represents the
/// root directory of the project.
enum FlutterProjectComponent {
  root,
  android,
  ios,
  linux,
  macos,
  web,
  windows,
  fuchsia,
}

extension SupportedPlatformExtension on SupportedPlatform {
  FlutterProjectComponent toFlutterProjectComponent() {
    final String platformName = toString().split('.').last;
    return FlutterProjectComponent.values.firstWhere(
      (FlutterProjectComponent e) =>
          e.toString() == 'FlutterProjectComponent.$platformName',
    );
  }
}

extension FlutterProjectComponentExtension on FlutterProjectComponent {
  SupportedPlatform? toSupportedPlatform() {
    final String platformName = toString().split('.').last;
    if (platformName == 'root') {
      return null;
    }
    return SupportedPlatform.values.firstWhere(
      (SupportedPlatform e) =>
          e.toString() == 'SupportedPlatform.$platformName',
    );
  }
}

enum FlutterProjectType {
  /// This is the default project with the user-managed host code.
  /// It is different than the "module" template in that it exposes and doesn't
  /// manage the platform code.
  app,

  /// A List/Detail app template that follows community best practices.
  skeleton,

  /// The is a project that has managed platform host code. It is an application with
  /// ephemeral .ios and .android directories that can be updated automatically.
  module,

  /// This is a Flutter Dart package project. It doesn't have any native
  /// components, only Dart.
  package,

  /// This is a native plugin project.
  plugin,

  /// This is an FFI native plugin project.
  ffiPlugin,
}

String flutterProjectTypeToString(FlutterProjectType? type) {
  if (type == null) {
    return '';
  }
  if (type == FlutterProjectType.ffiPlugin) {
    return 'plugin_ffi';
  }
  return getEnumName(type);
}

FlutterProjectType? stringToProjectType(String value) {
  FlutterProjectType? result;
  for (final FlutterProjectType type in FlutterProjectType.values) {
    if (value == flutterProjectTypeToString(type)) {
      result = type;
      break;
    }
  }
  return result;
}

/// Verifies the expected yaml keys are present in the file.
bool _validateMetadataMap(
  YamlMap map,
  Map<String, Type> validations,
  Logger logger,
) {
  bool isValid = true;
  for (final MapEntry<String, Object> entry in validations.entries) {
    if (!map.keys.contains(entry.key)) {
      isValid = false;
      logger.printTrace('The key `${entry.key}` was not found');
      break;
    }
    final Object? metadataValue = map[entry.key];
    if (metadataValue.runtimeType != entry.value) {
      isValid = false;
      logger.printTrace(
        'The value of key `${entry.key}` in .metadata was expected to be ${entry.value} but was ${metadataValue.runtimeType}',
      );
      break;
    }
  }
  return isValid;
}

/// A wrapper around the `.metadata` file.
class FlutterProjectMetadata {
  /// Creates a MigrateConfig by parsing an existing .migrate_config yaml file.
  FlutterProjectMetadata(this.file, Logger logger)
    : _logger = logger,
      migrateConfig = MigrateConfig() {
    if (!file.existsSync()) {
      _logger.printTrace('No .metadata file found at ${file.path}.');
      // Create a default empty metadata.
      return;
    }
    Object? yamlRoot;
    try {
      yamlRoot = loadYaml(file.readAsStringSync());
    } on YamlException {
      // Handled in _validate below.
    }
    if (yamlRoot is! YamlMap) {
      _logger.printTrace(
        '.metadata file at ${file.path} was empty or malformed.',
      );
      return;
    }
    if (_validateMetadataMap(yamlRoot, <String, Type>{
      'version': YamlMap,
    }, _logger)) {
      final Object? versionYamlMap = yamlRoot['version'];
      if (versionYamlMap is YamlMap &&
          _validateMetadataMap(versionYamlMap, <String, Type>{
            'revision': String,
            'channel': String,
          }, _logger)) {
        _versionRevision = versionYamlMap['revision'] as String?;
        _versionChannel = versionYamlMap['channel'] as String?;
      }
    }
    if (_validateMetadataMap(yamlRoot, <String, Type>{
      'project_type': String,
    }, _logger)) {
      _projectType = stringToProjectType(yamlRoot['project_type'] as String);
    }
    final Object? migrationYaml = yamlRoot['migration'];
    if (migrationYaml is YamlMap) {
      migrateConfig.parseYaml(migrationYaml, _logger);
    }
  }

  /// Creates a FlutterProjectMetadata by explicitly providing all values.
  FlutterProjectMetadata.explicit({
    required this.file,
    required String? versionRevision,
    required String? versionChannel,
    required FlutterProjectType? projectType,
    required this.migrateConfig,
    required Logger logger,
  }) : _logger = logger,
       _versionChannel = versionChannel,
       _versionRevision = versionRevision,
       _projectType = projectType;

  /// The name of the config file.
  static const String kFileName = '.metadata';

  String? _versionRevision;
  String? get versionRevision => _versionRevision;

  String? _versionChannel;
  String? get versionChannel => _versionChannel;

  FlutterProjectType? _projectType;
  FlutterProjectType? get projectType => _projectType;

  /// Metadata and configuration for the migrate command.
  MigrateConfig migrateConfig;

  final Logger _logger;

  final File file;

  /// Writes the .migrate_config file in the provided project directory's platform subdirectory.
  ///
  /// We write the file manually instead of with a template because this
  /// needs to be able to write the .migrate_config file into legacy apps.
  void writeFile({File? outputFile}) {
    outputFile = outputFile ?? file;
    outputFile
      ..createSync(recursive: true)
      ..writeAsStringSync(toString(), flush: true);
  }

  @override
  String toString() {
    return '''
# This file tracks properties of this Flutter project.
# Used by Flutter tool to assess capabilities and perform upgrades etc.
#
# This file should be version controlled.

version:
  revision: $_versionRevision
  channel: $_versionChannel

project_type: ${flutterProjectTypeToString(projectType)}
${migrateConfig.getOutputFileString()}''';
  }

  void populate({
    List<SupportedPlatform>? platforms,
    required Directory projectDirectory,
    String? currentRevision,
    String? createRevision,
    bool create = true,
    bool update = true,
    required Logger logger,
  }) {
    migrateConfig.populate(
      platforms: platforms,
      projectDirectory: projectDirectory,
      currentRevision: currentRevision,
      createRevision: createRevision,
      create: create,
      update: update,
      logger: logger,
    );
  }

  /// Finds the fallback revision to use when no base revision is found in the migrate config.
  String getFallbackBaseRevision(Logger logger, String frameworkRevision) {
    // Use the .metadata file if it exists.
    if (versionRevision != null) {
      return versionRevision!;
    }
    return frameworkRevision;
  }
}

/// Represents the migrate command metadata section of a .metadata file.
///
/// This file tracks the flutter sdk git hashes of the last successful migration ('base') and
/// the version the project was created with.
///
/// Each platform tracks a different set of revisions because flutter create can be
/// used to add support for new platforms, so the base and create revision may not always be the same.
class MigrateConfig {
  MigrateConfig({
    Map<FlutterProjectComponent, MigratePlatformConfig>? platformConfigs,
    this.unmanagedFiles = kDefaultUnmanagedFiles,
  }) : platformConfigs =
           platformConfigs ??
           <FlutterProjectComponent, MigratePlatformConfig>{};

  /// A mapping of the files that are unmanaged by defult for each platform.
  static const List<String> kDefaultUnmanagedFiles = <String>[
    'lib/main.dart',
    'ios/Runner.xcodeproj/project.pbxproj',
  ];

  /// The metadata for each platform supported by the project.
  final Map<FlutterProjectComponent, MigratePlatformConfig> platformConfigs;

  /// A list of paths relative to this file the migrate tool should ignore.
  ///
  /// These files are typically user-owned files that should not be changed.
  List<String> unmanagedFiles;

  bool get isEmpty =>
      platformConfigs.isEmpty &&
      (unmanagedFiles.isEmpty || unmanagedFiles == kDefaultUnmanagedFiles);

  /// Parses the project for all supported platforms and populates the [MigrateConfig]
  /// to reflect the project.
  void populate({
    List<SupportedPlatform>? platforms,
    required Directory projectDirectory,
    String? currentRevision,
    String? createRevision,
    bool create = true,
    bool update = true,
    required Logger logger,
  }) {
    final FlutterProject flutterProject = FlutterProject(projectDirectory);
    platforms ??= flutterProject.getSupportedPlatforms();

    final List<FlutterProjectComponent> components =
        <FlutterProjectComponent>[];
    for (final SupportedPlatform platform in platforms) {
      components.add(platform.toFlutterProjectComponent());
    }
    components.add(FlutterProjectComponent.root);
    for (final FlutterProjectComponent component in components) {
      if (platformConfigs.containsKey(component)) {
        if (update) {
          platformConfigs[component]!.baseRevision = currentRevision;
        }
      } else {
        if (create) {
          platformConfigs[component] = MigratePlatformConfig(
            component: component,
            createRevision: createRevision,
            baseRevision: currentRevision,
          );
        }
      }
    }
  }

  /// Returns the string that should be written to the .metadata file.
  String getOutputFileString() {
    String unmanagedFilesString = '';
    for (final String path in unmanagedFiles) {
      unmanagedFilesString += "\n    - '$path'";
    }

    String platformsString = '';
    for (final MapEntry<FlutterProjectComponent, MigratePlatformConfig> entry
        in platformConfigs.entries) {
      platformsString +=
          '\n    - platform: ${entry.key.toString().split('.').last}\n      create_revision: ${entry.value.createRevision == null ? 'null' : "${entry.value.createRevision}"}\n      base_revision: ${entry.value.baseRevision == null ? 'null' : "${entry.value.baseRevision}"}';
    }

    return isEmpty
        ? ''
        : '''

# Tracks metadata for the flutter migrate command
migration:
  platforms:$platformsString

  # User provided section

  # List of Local paths (relative to this file) that should be
  # ignored by the migrate tool.
  #
  # Files that are not part of the templates will be ignored by default.
  unmanaged_files:$unmanagedFilesString
''';
  }

  /// Parses and validates the `migration` section of the .metadata file.
  void parseYaml(YamlMap map, Logger logger) {
    final Object? platformsYaml = map['platforms'];
    if (_validateMetadataMap(map, <String, Type>{
      'platforms': YamlList,
    }, logger)) {
      if (platformsYaml is YamlList && platformsYaml.isNotEmpty) {
        for (final YamlMap platformYamlMap
            in platformsYaml.whereType<YamlMap>()) {
          if (_validateMetadataMap(platformYamlMap, <String, Type>{
            'platform': String,
            'create_revision': String,
            'base_revision': String,
          }, logger)) {
            final FlutterProjectComponent
            component = FlutterProjectComponent.values.firstWhere(
              (FlutterProjectComponent val) =>
                  val.toString() ==
                  'FlutterProjectComponent.${platformYamlMap['platform'] as String}',
            );
            platformConfigs[component] = MigratePlatformConfig(
              component: component,
              createRevision: platformYamlMap['create_revision'] as String?,
              baseRevision: platformYamlMap['base_revision'] as String?,
            );
          } else {
            // malformed platform entry
            continue;
          }
        }
      }
    }
    if (_validateMetadataMap(map, <String, Type>{
      'unmanaged_files': YamlList,
    }, logger)) {
      final Object? unmanagedFilesYaml = map['unmanaged_files'];
      if (unmanagedFilesYaml is YamlList && unmanagedFilesYaml.isNotEmpty) {
        unmanagedFiles = List<String>.from(
          unmanagedFilesYaml.value.cast<String>(),
        );
      }
    }
  }
}

/// Holds the revisions for a single platform for use by the flutter migrate command.
class MigratePlatformConfig {
  MigratePlatformConfig({
    required this.component,
    this.createRevision,
    this.baseRevision,
  });

  /// The platform this config describes.
  FlutterProjectComponent component;

  /// The Flutter SDK revision this platform was created by.
  ///
  /// Null if the initial create git revision is unknown.
  final String? createRevision;

  /// The Flutter SDK revision this platform was last migrated by.
  ///
  /// Null if the project was never migrated or the revision is unknown.
  String? baseRevision;

  bool equals(MigratePlatformConfig other) {
    return component == other.component &&
        createRevision == other.createRevision &&
        baseRevision == other.baseRevision;
  }
}
