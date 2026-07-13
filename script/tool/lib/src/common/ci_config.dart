// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:yaml/yaml.dart';

const String _releaseModeKey = 'release';
const String _isBatchModeKey = 'batch';
const String _exemptFromExcerptsKey = 'exempt_from_excerpts';
const String _analyzeSkillsKey = 'analyze_skills';
const String _allowCustomAnalysisOptionsKey = 'allow_custom_analysis_options';

/// A class representing the parsed content of a `ci_config.yaml` file.
class CIConfig {
  /// Creates a [CIConfig] from a parsed YAML map.
  CIConfig._({
    required this.isBatchRelease,
    required this.requiresExcerpts,
    required this.analyzeSkills,
    required this.allowCustomAnalysisOptions,
  });

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
    final Object? release = loaded[_releaseModeKey];
    if (release is Map) {
      isBatchRelease = release[_isBatchModeKey] == true;
    }

    // Any package that hasn't been explicitly exempted is assumed to require
    // excerpts.
    final requiresExcerpts = loaded[_exemptFromExcerptsKey] != true;

    final analyzeSkills = loaded[_analyzeSkillsKey] == true;

    final allowCustomAnalysisOptions = loaded[_allowCustomAnalysisOptionsKey] == true;

    return CIConfig._(
      isBatchRelease: isBatchRelease,
      requiresExcerpts: requiresExcerpts,
      analyzeSkills: analyzeSkills,
      allowCustomAnalysisOptions: allowCustomAnalysisOptions,
    );
  }

  static const Map<String, Object?> _validCIConfigSyntax = <String, Object?>{
    _releaseModeKey: <String, Object?>{
      _isBatchModeKey: <bool>{true, false},
    },
    _exemptFromExcerptsKey: <bool>{true, false},
    _analyzeSkillsKey: <bool>{true, false},
    _allowCustomAnalysisOptionsKey: <bool>{true, false},
  };

  /// Returns true if the package is configured for batch release.
  final bool isBatchRelease;

  /// Returns true if the package is configured to require excerpts.
  final bool requiresExcerpts;

  /// Returns true if the package has its agent skills analyzed.
  final bool analyzeSkills;

  /// Returns true if the package is allowed to have its own analysis options.
  final bool allowCustomAnalysisOptions;

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
