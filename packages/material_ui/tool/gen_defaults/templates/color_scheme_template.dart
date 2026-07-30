// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/color.dart';
import '../data/color_dark.dart';
import '../data/color_dark_high_contrast.dart';
import '../data/color_dark_medium_contrast.dart';
import '../data/color_light_high_contrast.dart';
import '../data/color_light_medium_contrast.dart';
import 'template.dart';

class ColorSchemeTemplateM3 extends TokenTemplateM3 {
  const ColorSchemeTemplateM3();

  @override
  String get name => 'Theme Data';

  @override
  String get parentFilePath => 'theme_data.dart';

  @override
  String get outputFileName => 'color_scheme_defaults.g.dart';

  @override
  bool get requiresGeneratedClass => false;

  static const Map<String, String> _lightTokens = <String, String>{
    'background': TokenColor.background,
    'error': TokenColor.error,
    'errorContainer': TokenColor.errorContainer,
    'inverseOnSurface': TokenColor.inverseOnSurface,
    'inversePrimary': TokenColor.inversePrimary,
    'inverseSurface': TokenColor.inverseSurface,
    'onBackground': TokenColor.onBackground,
    'onError': TokenColor.onError,
    'onErrorContainer': TokenColor.onErrorContainer,
    'onPrimary': TokenColor.onPrimary,
    'onPrimaryContainer': TokenColor.onPrimaryContainer,
    'onPrimaryFixed': TokenColor.onPrimaryFixed,
    'onPrimaryFixedVariant': TokenColor.onPrimaryFixedVariant,
    'onSecondary': TokenColor.onSecondary,
    'onSecondaryContainer': TokenColor.onSecondaryContainer,
    'onSecondaryFixed': TokenColor.onSecondaryFixed,
    'onSecondaryFixedVariant': TokenColor.onSecondaryFixedVariant,
    'onSurface': TokenColor.onSurface,
    'onSurfaceVariant': TokenColor.onSurfaceVariant,
    'onTertiary': TokenColor.onTertiary,
    'onTertiaryContainer': TokenColor.onTertiaryContainer,
    'onTertiaryFixed': TokenColor.onTertiaryFixed,
    'onTertiaryFixedVariant': TokenColor.onTertiaryFixedVariant,
    'outline': TokenColor.outline,
    'outlineVariant': TokenColor.outlineVariant,
    'primary': TokenColor.primary,
    'primaryContainer': TokenColor.primaryContainer,
    'primaryFixed': TokenColor.primaryFixed,
    'primaryFixedDim': TokenColor.primaryFixedDim,
    'scrim': TokenColor.scrim,
    'secondary': TokenColor.secondary,
    'secondaryContainer': TokenColor.secondaryContainer,
    'secondaryFixed': TokenColor.secondaryFixed,
    'secondaryFixedDim': TokenColor.secondaryFixedDim,
    'shadow': TokenColor.shadow,
    'surface': TokenColor.surface,
    'surfaceBright': TokenColor.surfaceBright,
    'surfaceContainer': TokenColor.surfaceContainer,
    'surfaceContainerHigh': TokenColor.surfaceContainerHigh,
    'surfaceContainerHighest': TokenColor.surfaceContainerHighest,
    'surfaceContainerLow': TokenColor.surfaceContainerLow,
    'surfaceContainerLowest': TokenColor.surfaceContainerLowest,
    'surfaceDim': TokenColor.surfaceDim,
    'surfaceVariant': TokenColor.surfaceVariant,
    'tertiary': TokenColor.tertiary,
    'tertiaryContainer': TokenColor.tertiaryContainer,
    'tertiaryFixed': TokenColor.tertiaryFixed,
    'tertiaryFixedDim': TokenColor.tertiaryFixedDim,
  };

  static const Map<String, String> _darkTokens = <String, String>{
    'background': TokenColorDark.background,
    'error': TokenColorDark.error,
    'errorContainer': TokenColorDark.errorContainer,
    'inverseOnSurface': TokenColorDark.inverseOnSurface,
    'inversePrimary': TokenColorDark.inversePrimary,
    'inverseSurface': TokenColorDark.inverseSurface,
    'onBackground': TokenColorDark.onBackground,
    'onError': TokenColorDark.onError,
    'onErrorContainer': TokenColorDark.onErrorContainer,
    'onPrimary': TokenColorDark.onPrimary,
    'onPrimaryContainer': TokenColorDark.onPrimaryContainer,
    'onPrimaryFixed': TokenColorDark.onPrimaryFixed,
    'onPrimaryFixedVariant': TokenColorDark.onPrimaryFixedVariant,
    'onSecondary': TokenColorDark.onSecondary,
    'onSecondaryContainer': TokenColorDark.onSecondaryContainer,
    'onSecondaryFixed': TokenColorDark.onSecondaryFixed,
    'onSecondaryFixedVariant': TokenColorDark.onSecondaryFixedVariant,
    'onSurface': TokenColorDark.onSurface,
    'onSurfaceVariant': TokenColorDark.onSurfaceVariant,
    'onTertiary': TokenColorDark.onTertiary,
    'onTertiaryContainer': TokenColorDark.onTertiaryContainer,
    'onTertiaryFixed': TokenColorDark.onTertiaryFixed,
    'onTertiaryFixedVariant': TokenColorDark.onTertiaryFixedVariant,
    'outline': TokenColorDark.outline,
    'outlineVariant': TokenColorDark.outlineVariant,
    'primary': TokenColorDark.primary,
    'primaryContainer': TokenColorDark.primaryContainer,
    'primaryFixed': TokenColorDark.primaryFixed,
    'primaryFixedDim': TokenColorDark.primaryFixedDim,
    'scrim': TokenColorDark.scrim,
    'secondary': TokenColorDark.secondary,
    'secondaryContainer': TokenColorDark.secondaryContainer,
    'secondaryFixed': TokenColorDark.secondaryFixed,
    'secondaryFixedDim': TokenColorDark.secondaryFixedDim,
    'shadow': TokenColorDark.shadow,
    'surface': TokenColorDark.surface,
    'surfaceBright': TokenColorDark.surfaceBright,
    'surfaceContainer': TokenColorDark.surfaceContainer,
    'surfaceContainerHigh': TokenColorDark.surfaceContainerHigh,
    'surfaceContainerHighest': TokenColorDark.surfaceContainerHighest,
    'surfaceContainerLow': TokenColorDark.surfaceContainerLow,
    'surfaceContainerLowest': TokenColorDark.surfaceContainerLowest,
    'surfaceDim': TokenColorDark.surfaceDim,
    'surfaceVariant': TokenColorDark.surfaceVariant,
    'tertiary': TokenColorDark.tertiary,
    'tertiaryContainer': TokenColorDark.tertiaryContainer,
    'tertiaryFixed': TokenColorDark.tertiaryFixed,
    'tertiaryFixedDim': TokenColorDark.tertiaryFixedDim,
  };

  static const Map<String, String> _lightMediumContrastTokens = <String, String>{
    'error': TokenColorLightMediumContrast.error,
    'errorContainer': TokenColorLightMediumContrast.errorContainer,
    'inverseOnSurface': TokenColorLightMediumContrast.inverseOnSurface,
    'onBackground': TokenColorLightMediumContrast.onBackground,
    'onError': TokenColorLightMediumContrast.onError,
    'onErrorContainer': TokenColorLightMediumContrast.onErrorContainer,
    'onPrimary': TokenColorLightMediumContrast.onPrimary,
    'onPrimaryContainer': TokenColorLightMediumContrast.onPrimaryContainer,
    'onPrimaryFixed': TokenColorLightMediumContrast.onPrimaryFixed,
    'onPrimaryFixedVariant': TokenColorLightMediumContrast.onPrimaryFixedVariant,
    'onSecondary': TokenColorLightMediumContrast.onSecondary,
    'onSecondaryContainer': TokenColorLightMediumContrast.onSecondaryContainer,
    'onSecondaryFixed': TokenColorLightMediumContrast.onSecondaryFixed,
    'onSecondaryFixedVariant': TokenColorLightMediumContrast.onSecondaryFixedVariant,
    'onSurface': TokenColorLightMediumContrast.onSurface,
    'onSurfaceVariant': TokenColorLightMediumContrast.onSurfaceVariant,
    'onTertiary': TokenColorLightMediumContrast.onTertiary,
    'onTertiaryContainer': TokenColorLightMediumContrast.onTertiaryContainer,
    'onTertiaryFixed': TokenColorLightMediumContrast.onTertiaryFixed,
    'onTertiaryFixedVariant': TokenColorLightMediumContrast.onTertiaryFixedVariant,
    'outline': TokenColorLightMediumContrast.outline,
    'outlineVariant': TokenColorLightMediumContrast.outlineVariant,
    'primary': TokenColorLightMediumContrast.primary,
    'primaryContainer': TokenColorLightMediumContrast.primaryContainer,
    'primaryFixed': TokenColorLightMediumContrast.primaryFixed,
    'primaryFixedDim': TokenColorLightMediumContrast.primaryFixedDim,
    'secondary': TokenColorLightMediumContrast.secondary,
    'secondaryContainer': TokenColorLightMediumContrast.secondaryContainer,
    'secondaryFixed': TokenColorLightMediumContrast.secondaryFixed,
    'secondaryFixedDim': TokenColorLightMediumContrast.secondaryFixedDim,
    'tertiary': TokenColorLightMediumContrast.tertiary,
    'tertiaryContainer': TokenColorLightMediumContrast.tertiaryContainer,
    'tertiaryFixed': TokenColorLightMediumContrast.tertiaryFixed,
    'tertiaryFixedDim': TokenColorLightMediumContrast.tertiaryFixedDim,
  };

  static const Map<String, String> _lightHighContrastTokens = <String, String>{
    'error': TokenColorLightHighContrast.error,
    'errorContainer': TokenColorLightHighContrast.errorContainer,
    'inverseOnSurface': TokenColorLightHighContrast.inverseOnSurface,
    'onBackground': TokenColorLightHighContrast.onBackground,
    'onError': TokenColorLightHighContrast.onError,
    'onErrorContainer': TokenColorLightHighContrast.onErrorContainer,
    'onPrimary': TokenColorLightHighContrast.onPrimary,
    'onPrimaryContainer': TokenColorLightHighContrast.onPrimaryContainer,
    'onPrimaryFixed': TokenColorLightHighContrast.onPrimaryFixed,
    'onPrimaryFixedVariant': TokenColorLightHighContrast.onPrimaryFixedVariant,
    'onSecondary': TokenColorLightHighContrast.onSecondary,
    'onSecondaryContainer': TokenColorLightHighContrast.onSecondaryContainer,
    'onSecondaryFixed': TokenColorLightHighContrast.onSecondaryFixed,
    'onSecondaryFixedVariant': TokenColorLightHighContrast.onSecondaryFixedVariant,
    'onSurface': TokenColorLightHighContrast.onSurface,
    'onSurfaceVariant': TokenColorLightHighContrast.onSurfaceVariant,
    'onTertiary': TokenColorLightHighContrast.onTertiary,
    'onTertiaryContainer': TokenColorLightHighContrast.onTertiaryContainer,
    'onTertiaryFixed': TokenColorLightHighContrast.onTertiaryFixed,
    'onTertiaryFixedVariant': TokenColorLightHighContrast.onTertiaryFixedVariant,
    'outline': TokenColorLightHighContrast.outline,
    'outlineVariant': TokenColorLightHighContrast.outlineVariant,
    'primary': TokenColorLightHighContrast.primary,
    'primaryContainer': TokenColorLightHighContrast.primaryContainer,
    'primaryFixed': TokenColorLightHighContrast.primaryFixed,
    'primaryFixedDim': TokenColorLightHighContrast.primaryFixedDim,
    'secondary': TokenColorLightHighContrast.secondary,
    'secondaryContainer': TokenColorLightHighContrast.secondaryContainer,
    'secondaryFixed': TokenColorLightHighContrast.secondaryFixed,
    'secondaryFixedDim': TokenColorLightHighContrast.secondaryFixedDim,
    'tertiary': TokenColorLightHighContrast.tertiary,
    'tertiaryContainer': TokenColorLightHighContrast.tertiaryContainer,
    'tertiaryFixed': TokenColorLightHighContrast.tertiaryFixed,
    'tertiaryFixedDim': TokenColorLightHighContrast.tertiaryFixedDim,
  };

  static const Map<String, String> _darkMediumContrastTokens = <String, String>{
    'error': TokenColorDarkMediumContrast.error,
    'errorContainer': TokenColorDarkMediumContrast.errorContainer,
    'inverseOnSurface': TokenColorDarkMediumContrast.inverseOnSurface,
    'inversePrimary': TokenColorDarkMediumContrast.inversePrimary,
    'onBackground': TokenColorDarkMediumContrast.onBackground,
    'onError': TokenColorDarkMediumContrast.onError,
    'onErrorContainer': TokenColorDarkMediumContrast.onErrorContainer,
    'onPrimary': TokenColorDarkMediumContrast.onPrimary,
    'onPrimaryContainer': TokenColorDarkMediumContrast.onPrimaryContainer,
    'onPrimaryFixed': TokenColorDarkMediumContrast.onPrimaryFixed,
    'onPrimaryFixedVariant': TokenColorDarkMediumContrast.onPrimaryFixedVariant,
    'onSecondary': TokenColorDarkMediumContrast.onSecondary,
    'onSecondaryContainer': TokenColorDarkMediumContrast.onSecondaryContainer,
    'onSecondaryFixed': TokenColorDarkMediumContrast.onSecondaryFixed,
    'onSecondaryFixedVariant': TokenColorDarkMediumContrast.onSecondaryFixedVariant,
    'onSurface': TokenColorDarkMediumContrast.onSurface,
    'onSurfaceVariant': TokenColorDarkMediumContrast.onSurfaceVariant,
    'onTertiary': TokenColorDarkMediumContrast.onTertiary,
    'onTertiaryContainer': TokenColorDarkMediumContrast.onTertiaryContainer,
    'onTertiaryFixed': TokenColorDarkMediumContrast.onTertiaryFixed,
    'onTertiaryFixedVariant': TokenColorDarkMediumContrast.onTertiaryFixedVariant,
    'outline': TokenColorDarkMediumContrast.outline,
    'outlineVariant': TokenColorDarkMediumContrast.outlineVariant,
    'primary': TokenColorDarkMediumContrast.primary,
    'primaryContainer': TokenColorDarkMediumContrast.primaryContainer,
    'primaryFixed': TokenColorDarkMediumContrast.primaryFixed,
    'primaryFixedDim': TokenColorDarkMediumContrast.primaryFixedDim,
    'secondary': TokenColorDarkMediumContrast.secondary,
    'secondaryContainer': TokenColorDarkMediumContrast.secondaryContainer,
    'secondaryFixed': TokenColorDarkMediumContrast.secondaryFixed,
    'secondaryFixedDim': TokenColorDarkMediumContrast.secondaryFixedDim,
    'tertiary': TokenColorDarkMediumContrast.tertiary,
    'tertiaryContainer': TokenColorDarkMediumContrast.tertiaryContainer,
    'tertiaryFixed': TokenColorDarkMediumContrast.tertiaryFixed,
    'tertiaryFixedDim': TokenColorDarkMediumContrast.tertiaryFixedDim,
  };

  static const Map<String, String> _darkHighContrastTokens = <String, String>{
    'error': TokenColorDarkHighContrast.error,
    'errorContainer': TokenColorDarkHighContrast.errorContainer,
    'inverseOnSurface': TokenColorDarkHighContrast.inverseOnSurface,
    'inversePrimary': TokenColorDarkHighContrast.inversePrimary,
    'onBackground': TokenColorDarkHighContrast.onBackground,
    'onError': TokenColorDarkHighContrast.onError,
    'onErrorContainer': TokenColorDarkHighContrast.onErrorContainer,
    'onPrimary': TokenColorDarkHighContrast.onPrimary,
    'onPrimaryContainer': TokenColorDarkHighContrast.onPrimaryContainer,
    'onPrimaryFixed': TokenColorDarkHighContrast.onPrimaryFixed,
    'onPrimaryFixedVariant': TokenColorDarkHighContrast.onPrimaryFixedVariant,
    'onSecondary': TokenColorDarkHighContrast.onSecondary,
    'onSecondaryContainer': TokenColorDarkHighContrast.onSecondaryContainer,
    'onSecondaryFixed': TokenColorDarkHighContrast.onSecondaryFixed,
    'onSecondaryFixedVariant': TokenColorDarkHighContrast.onSecondaryFixedVariant,
    'onSurface': TokenColorDarkHighContrast.onSurface,
    'onSurfaceVariant': TokenColorDarkHighContrast.onSurfaceVariant,
    'onTertiary': TokenColorDarkHighContrast.onTertiary,
    'onTertiaryContainer': TokenColorDarkHighContrast.onTertiaryContainer,
    'onTertiaryFixed': TokenColorDarkHighContrast.onTertiaryFixed,
    'onTertiaryFixedVariant': TokenColorDarkHighContrast.onTertiaryFixedVariant,
    'outline': TokenColorDarkHighContrast.outline,
    'outlineVariant': TokenColorDarkHighContrast.outlineVariant,
    'primary': TokenColorDarkHighContrast.primary,
    'primaryContainer': TokenColorDarkHighContrast.primaryContainer,
    'primaryFixed': TokenColorDarkHighContrast.primaryFixed,
    'primaryFixedDim': TokenColorDarkHighContrast.primaryFixedDim,
    'secondary': TokenColorDarkHighContrast.secondary,
    'secondaryContainer': TokenColorDarkHighContrast.secondaryContainer,
    'secondaryFixed': TokenColorDarkHighContrast.secondaryFixed,
    'secondaryFixedDim': TokenColorDarkHighContrast.secondaryFixedDim,
    'tertiary': TokenColorDarkHighContrast.tertiary,
    'tertiaryContainer': TokenColorDarkHighContrast.tertiaryContainer,
    'tertiaryFixed': TokenColorDarkHighContrast.tertiaryFixed,
    'tertiaryFixedDim': TokenColorDarkHighContrast.tertiaryFixedDim,
  };

  @override
  String generateContents(String className) {
    return <String>[
      _colorScheme('_colorSchemeLightM3', 'Brightness.light', _lightTokens),
      _colorScheme('_colorSchemeDarkM3', 'Brightness.dark', _darkTokens),
      _colorScheme(
        '_colorSchemeLightMediumContrastM3',
        'Brightness.light',
        _lightMediumContrastTokens,
        fallbackTokens: _lightTokens,
      ),
      _colorScheme(
        '_colorSchemeLightHighContrastM3',
        'Brightness.light',
        _lightHighContrastTokens,
        fallbackTokens: _lightTokens,
      ),
      _colorScheme(
        '_colorSchemeDarkMediumContrastM3',
        'Brightness.dark',
        _darkMediumContrastTokens,
        fallbackTokens: _darkTokens,
      ),
      _colorScheme(
        '_colorSchemeDarkHighContrastM3',
        'Brightness.dark',
        _darkHighContrastTokens,
        fallbackTokens: _darkTokens,
      ),
    ].join('\n');
  }

  String _colorScheme(
    String name,
    String brightness,
    Map<String, String> tokens, {
    Map<String, String>? fallbackTokens,
  }) {
    const colorRoles = <(String, String)>[
      ('primary', 'primary'),
      ('onPrimary', 'onPrimary'),
      ('primaryContainer', 'primaryContainer'),
      ('onPrimaryContainer', 'onPrimaryContainer'),
      ('primaryFixed', 'primaryFixed'),
      ('primaryFixedDim', 'primaryFixedDim'),
      ('onPrimaryFixed', 'onPrimaryFixed'),
      ('onPrimaryFixedVariant', 'onPrimaryFixedVariant'),
      ('secondary', 'secondary'),
      ('onSecondary', 'onSecondary'),
      ('secondaryContainer', 'secondaryContainer'),
      ('onSecondaryContainer', 'onSecondaryContainer'),
      ('secondaryFixed', 'secondaryFixed'),
      ('secondaryFixedDim', 'secondaryFixedDim'),
      ('onSecondaryFixed', 'onSecondaryFixed'),
      ('onSecondaryFixedVariant', 'onSecondaryFixedVariant'),
      ('tertiary', 'tertiary'),
      ('onTertiary', 'onTertiary'),
      ('tertiaryContainer', 'tertiaryContainer'),
      ('onTertiaryContainer', 'onTertiaryContainer'),
      ('tertiaryFixed', 'tertiaryFixed'),
      ('tertiaryFixedDim', 'tertiaryFixedDim'),
      ('onTertiaryFixed', 'onTertiaryFixed'),
      ('onTertiaryFixedVariant', 'onTertiaryFixedVariant'),
      ('error', 'error'),
      ('onError', 'onError'),
      ('errorContainer', 'errorContainer'),
      ('onErrorContainer', 'onErrorContainer'),
      ('background', 'background'),
      ('onBackground', 'onBackground'),
      ('surface', 'surface'),
      ('surfaceBright', 'surfaceBright'),
      ('surfaceContainerLowest', 'surfaceContainerLowest'),
      ('surfaceContainerLow', 'surfaceContainerLow'),
      ('surfaceContainer', 'surfaceContainer'),
      ('surfaceContainerHigh', 'surfaceContainerHigh'),
      ('surfaceContainerHighest', 'surfaceContainerHighest'),
      ('surfaceDim', 'surfaceDim'),
      ('onSurface', 'onSurface'),
      ('surfaceVariant', 'surfaceVariant'),
      ('onSurfaceVariant', 'onSurfaceVariant'),
      ('outline', 'outline'),
      ('outlineVariant', 'outlineVariant'),
      ('shadow', 'shadow'),
      ('scrim', 'scrim'),
      ('inverseSurface', 'inverseSurface'),
      ('onInverseSurface', 'inverseOnSurface'),
      ('inversePrimary', 'inversePrimary'),
    ];

    final buffer = StringBuffer('''
const ColorScheme $name = ColorScheme(
  brightness: $brightness,
''');
    final Iterable<(String, String)> rolesWithTokens = colorRoles.where(
      ((String, String) role) => tokens.containsKey(role.$2),
    );
    final Iterable<(String, String)> rolesWithFallbackTokens = colorRoles.where(
      ((String, String) role) => !tokens.containsKey(role.$2),
    );

    for (final (parameterName, tokenName) in rolesWithTokens) {
      buffer.writeln('  $parameterName: Color(${tokens[tokenName]}),');
    }
    if (fallbackTokens != null && rolesWithFallbackTokens.isNotEmpty) {
      buffer.writeln(
        '  // These roles fall back to the default ${_brightnessName(brightness)} tokens.',
      );
      for (final (parameterName, tokenName) in rolesWithFallbackTokens) {
        buffer.writeln('  $parameterName: Color(${_fallbackToken(tokenName, fallbackTokens)}),');
      }
    }
    buffer.writeln(');\n');
    return buffer.toString();
  }

  String _brightnessName(String brightness) {
    return switch (brightness) {
      'Brightness.light' => 'light',
      'Brightness.dark' => 'dark',
      _ => throw StateError('Unsupported brightness: $brightness.'),
    };
  }

  String _fallbackToken(String name, Map<String, String> fallbackTokens) {
    return fallbackTokens[name] ?? (throw StateError('No fallback token is defined for $name.'));
  }
}
