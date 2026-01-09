// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:yaml/yaml.dart';

/// A class representing the parsed content of a `ci_config.yaml` file.
class CIConfig {
  /// Creates a [CIConfig] from a parsed YAML map.
  CIConfig._(this.isBatchRelease);

  /// Parses a [CIConfig] from a YAML string.
  ///
  /// Throws if the YAML is not a valid ci_config.yaml.
  factory CIConfig.parse(String yaml) {
    final Object? loaded = loadYaml(yaml);
    if (loaded is! YamlMap) {
      throw const FormatException('Root of ci_config.yaml must be a map.');
    }

    _checkCIConfigEntries(loaded, syntax: _validCIConfigSyntax);

    var isBatchRelease = false;
    final Object? release = loaded['release'];
    if (release is Map) {
      isBatchRelease = release['batch'] == true;
    }

    return CIConfig._(isBatchRelease);
  }

  static const Map<String, Object?> _validCIConfigSyntax = <String, Object?>{
    'release': <String, Object?>{
      'batch': <bool>{true, false},
    },
  };

  /// Returns true if the package is configured for batch release.
  final bool isBatchRelease;

  static void _checkCIConfigEntries(
    YamlMap config, {
    required Map<String, Object?> syntax,
    String configPrefix = '',
  }) {
    for (final MapEntry<Object?, Object?> entry in config.entries) {
      if (!syntax.containsKey(entry.key)) {
        throw FormatException(
          'Unknown key `${entry.key}` in config${_formatConfigPrefix(configPrefix)}, the possible keys are ${syntax.keys.toList()}',
        );
      } else {
        final Object syntaxValue = syntax[entry.key]!;
        final newConfigPrefix = configPrefix.isEmpty
            ? entry.key! as String
            : '$configPrefix.${entry.key}';
        if (syntaxValue is Set) {
          if (!syntaxValue.contains(entry.value)) {
            throw FormatException(
              'Invalid value `${entry.value}` for key${_formatConfigPrefix(newConfigPrefix)}, the possible values are ${syntaxValue.toList()}',
            );
          }
        } else if (entry.value is! YamlMap) {
          throw FormatException(
            'Invalid value `${entry.value}` for key${_formatConfigPrefix(newConfigPrefix)}, the value must be a map',
          );
        } else {
          _checkCIConfigEntries(
            entry.value! as YamlMap,
            syntax: syntaxValue as Map<String, Object?>,
            configPrefix: newConfigPrefix,
          );
        }
      }
    }
  }

  static String _formatConfigPrefix(String configPrefix) =>
      configPrefix.isEmpty ? '' : ' `$configPrefix`';
}
