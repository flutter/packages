// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// The system for managing pending changelog entries.
///
/// When package opts into batch release (through ci_config.yaml), it uses a "pending
/// changelog" system. When a PR makes a change that requires a changelog entry,
/// the entry is written to a new YAML file in the `pending_changelogs` directory
/// of the package, rather than editing `CHANGELOG.md` directly.
///
/// ## Directory Structure
/// For batch release packages, it has a `pending_changelogs` directory containing:
/// - A `template.yaml` file (which is ignored by the release tooling).
/// - One or more YAML files for pending changes (e.g., `fix_issue_123.yaml`).
///
/// ## File Format
/// The YAML file must contain the following keys:
/// - `changelog`: The text of the changelog entry.
/// - `version`: The type of version bump (`major`, `minor`, `patch`, or `skip`).
///
/// Example:
/// ```yaml
/// changelog: Fixes a bug in the foo widget.
/// version: patch
/// ```
///
/// During a release (specifically the `update-changelogs` command), all
/// pending entries are aggregated, the package version is updated based on the
/// highest priority change, and `CHANGELOG.md` is updated.

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
  PendingChangelogEntry({
    required this.changelog,
    required this.version,
    required this.file,
  });

  /// Creates a PendingChangelogEntry from a YAML string.
  ///
  /// Throws if the YAML is not a valid pending changelog entry.
  factory PendingChangelogEntry.parse(String yamlContent, File file) {
    final dynamic yaml = loadYaml(yamlContent);
    if (yaml is! YamlMap) {
      throw FormatException(
        'Expected a YAML map, but found ${yaml.runtimeType}.',
      );
    }

    final dynamic changelogYaml = yaml['changelog'];
    if (changelogYaml is! String) {
      throw FormatException(
        'Expected "changelog" to be a string, but found ${changelogYaml.runtimeType}.',
      );
    }
    final String changelog = changelogYaml.trim();

    final versionString = yaml['version'] as String?;
    if (versionString == null) {
      throw const FormatException('Missing "version" key.');
    }
    final VersionChange version = VersionChange.values.firstWhere(
      (VersionChange e) => e.name == versionString,
      orElse: () =>
          throw FormatException('Invalid version type: $versionString'),
    );

    return PendingChangelogEntry(
      changelog: changelog,
      version: version,
      file: file,
    );
  }

  /// The template file name used to draft a pending changelog file.
  /// This file will not be picked up by the batch release process.
  static const String _batchReleaseChangelogTemplateFileName = 'template.yaml';

  /// Returns true if the file is a template file.
  static bool isTemplate(File file) {
    return p.basename(file.path) == _batchReleaseChangelogTemplateFileName;
  }

  /// The changelog messages for this entry.
  final String changelog;

  /// The type of version change for this entry.
  final VersionChange version;

  /// The file that this entry was parsed from.
  final File file;
}
