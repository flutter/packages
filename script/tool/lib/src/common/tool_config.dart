// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:meta/meta.dart';
import 'package:yaml/yaml.dart';
import 'core.dart';
import 'output_utils.dart';

/// The name of the tool configuration file, at the root of the repository.
const String configFilename = '.repo_tool_config.yaml';

YamlMap? _toolConfig;

/// Clears the cached tool configuration.
///
/// Visible for testing only.
@visibleForTesting
void clearToolConfigCache() {
  _toolConfig = null;
}

YamlMap _getToolConfig(Directory repoRoot) {
  if (_toolConfig == null) {
    final File configFile = repoRoot.childFile(configFilename);
    if (!configFile.existsSync()) {
      printError('Configuration file $configFilename not found at repository root.');
      throw ToolExit(exitInvalidArguments);
    }
    final Object yaml = loadYamlNode(configFile.readAsStringSync());
    if (yaml is! YamlMap) {
      printError('Configuration file $configFilename is must be a map.');
      throw ToolExit(exitInvalidArguments);
    }
    _toolConfig = yaml;
  }
  return _toolConfig!;
}

/// Returns the name of the repository.
String getRepositoryName(Directory repoRoot) {
  final name = _getToolConfig(repoRoot)['repo_name'] as String?;
  if (name == null) {
    printError('repo_name is missing in $configFilename');
    throw ToolExit(exitInvalidArguments);
  }
  return name;
}

/// Returns the minimum Flutter version allowed.
String? getMinFlutterVersion(Directory repoRoot) {
  final Object? yaml = _getToolConfig(repoRoot)['min_flutter'];
  if (yaml == null) {
    return null;
  }
  if (yaml is! String) {
    printError('min_flutter must be a full version string (e.g., "3.44.0").');
    throw ToolExit(exitInvalidArguments);
  }
  return yaml;
}

/// Returns the minimum Dart version allowed.
String? getMinDartVersion(Directory repoRoot) {
  final Object? yaml = _getToolConfig(repoRoot)['min_dart'];
  if (yaml == null) {
    return null;
  }
  if (yaml is! String) {
    printError('min_dart must be a full version string (e.g., "3.10.0").');
    throw ToolExit(exitInvalidArguments);
  }
  return yaml;
}

/// Returns the allowed dependencies, grouped by 'pinned' and 'unpinned'.
({List<String> pinned, List<String> unpinned}) getAllowedDependencies(Directory repoRoot) {
  final allowedDeps = _getToolConfig(repoRoot)['allowed_dependencies'] as YamlMap?;
  if (allowedDeps == null) {
    return (pinned: <String>[], unpinned: <String>[]);
  }

  final List<String> pinned =
      (allowedDeps['pinned'] as YamlList?)?.map((e) => e as String).toList() ?? <String>[];
  final List<String> unpinned =
      (allowedDeps['unpinned'] as YamlList?)?.map((e) => e as String).toList() ?? <String>[];

  return (pinned: pinned, unpinned: unpinned);
}

/// Returns a map from package names to non-standard issue labels used for those
/// packages. Packages that use the default label `p: <package_name>` are not
/// included in the returned map.
Map<String, String> getNonStandardPackageLabels(Directory repoRoot) {
  final customLabels = _getToolConfig(repoRoot)['package_labels'] as YamlMap?;
  if (customLabels == null) {
    return <String, String>{};
  }

  return customLabels.map((key, value) => MapEntry(key as String, value as String));
}
