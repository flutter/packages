// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'base/file_system.dart';
import 'base/logger.dart';
import 'base/project.dart';
import 'flutter_project_metadata.dart';
import 'utils.dart';

/// Handles the custom/manual merging of one file at `localPath`.
///
/// The `merge` method should be overridden to implement custom merging.
abstract class CustomMerge {
  CustomMerge({
    required this.logger,
    required this.localPath,
  });

  /// The local path (with the project root as the root directory) of the file to merge.
  final String localPath;
  final Logger logger;

  /// Called to perform a custom three way merge between the current,
  /// base, and target files.
  MergeResult merge(File current, File base, File target);
}

/// Manually merges a flutter .metadata file.
///
/// See `FlutterProjectMetadata`.
class MetadataCustomMerge extends CustomMerge {
  MetadataCustomMerge({
    required super.logger,
  }) : super(localPath: '.metadata');

  @override
  MergeResult merge(File current, File base, File target) {
    final FlutterProjectMetadata result = computeMerge(
      FlutterProjectMetadata(current, logger),
      FlutterProjectMetadata(base, logger),
      FlutterProjectMetadata(target, logger),
      logger,
    );
    return StringMergeResult.explicit(
      mergedString: result.toString(),
      hasConflict: false,
      exitCode: 0,
      localPath: localPath,
    );
  }

  FlutterProjectMetadata computeMerge(
      FlutterProjectMetadata current,
      FlutterProjectMetadata base,
      FlutterProjectMetadata target,
      Logger logger) {
    // Prefer to update the version revision and channel to latest version.
    final String? versionRevision = target.versionRevision ??
        current.versionRevision ??
        base.versionRevision;
    final String? versionChannel =
        target.versionChannel ?? current.versionChannel ?? base.versionChannel;
    // Prefer to leave the project type untouched as it is non-trivial to change project type.
    final FlutterProjectType? projectType =
        current.projectType ?? base.projectType ?? target.projectType;
    final MigrateConfig migrateConfig = mergeMigrateConfig(
      current.migrateConfig,
      target.migrateConfig,
    );
    final FlutterProjectMetadata output = FlutterProjectMetadata.explicit(
      file: current.file,
      versionRevision: versionRevision,
      versionChannel: versionChannel,
      projectType: projectType,
      migrateConfig: migrateConfig,
      logger: logger,
    );
    return output;
  }

  MigrateConfig mergeMigrateConfig(
      MigrateConfig current, MigrateConfig target) {
    // Create the superset of current and target platforms with baseRevision updated to be that of target.
    final Map<SupportedPlatform?, MigratePlatformConfig> platformConfigs =
        <SupportedPlatform, MigratePlatformConfig>{};
    for (final MapEntry<SupportedPlatform?, MigratePlatformConfig> entry
        in current.platformConfigs.entries) {
      if (target.platformConfigs.containsKey(entry.key)) {
        platformConfigs[entry.key] = MigratePlatformConfig(
            platform: entry.value.platform,
            createRevision: entry.value.createRevision,
            baseRevision: target.platformConfigs[entry.key]?.baseRevision);
      } else {
        platformConfigs[entry.key] = entry.value;
      }
    }
    for (final MapEntry<SupportedPlatform?, MigratePlatformConfig> entry
        in target.platformConfigs.entries) {
      if (!platformConfigs.containsKey(entry.key)) {
        platformConfigs[entry.key] = entry.value;
      }
    }

    // Ignore the base file list.
    final List<String> unmanagedFiles =
        List<String>.from(current.unmanagedFiles);
    for (final String path in target.unmanagedFiles) {
      if (!unmanagedFiles.contains(path) &&
          !MigrateConfig.kDefaultUnmanagedFiles.contains(path)) {
        unmanagedFiles.add(path);
      }
    }
    return MigrateConfig(
      platformConfigs: platformConfigs,
      unmanagedFiles: unmanagedFiles,
    );
  }
}
