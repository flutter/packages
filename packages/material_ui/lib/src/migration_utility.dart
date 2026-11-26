// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart' as modern_cupertino;
import 'package:flutter/cupertino.dart' as legacy_cupertino;
import 'package:flutter/material.dart' as legacy;
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:material_ui/material_ui.dart' as modern; // ignore: prefer_relative_imports

/// A bridge widget for applications that have migrated to `package:material_ui`
/// but still contain subtrees or package dependencies using `package:flutter/material.dart`.
///
/// This widget maps the parent [modern.ThemeData] from `package:material_ui` into
/// a legacy [legacy.ThemeData] and overrides [legacy.Localizations] with delegates
/// so that legacy widgets in [child] can resolve `legacy.Theme.of(context)` and
/// `legacy.MaterialLocalizations.of(context)`.
///
/// ## App-wide usage
///
/// The recommended way to use this bridge across an entire application is to
/// wrap the app once using [modern.MaterialApp.builder]:
///
/// ```dart
/// import 'package:material_ui/material_ui.dart';
///
/// void main() {
///   runApp(const MyApp());
/// }
///
/// class MyApp extends StatelessWidget {
///   const MyApp({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       theme: ThemeData(
///         colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
///       ),
///       builder: (BuildContext context, Widget? child) {
///         return MaterialUiCompatibilityBridge(child: child!);
///       },
///       home: const HomeScreen(),
///     );
///   }
/// }
/// ```
///
/// ## Subtree usage (inline widgets only)
///
/// If legacy widgets do not push routes onto [Navigator] (no dialogs, pickers,
/// bottom sheets, or popup menus), you can wrap individual subtrees:
///
/// ```dart
/// import 'package:material_ui/material_ui.dart';
/// import 'package:some_legacy_package/some_legacy_package.dart';
///
/// class MyScreen extends StatelessWidget {
///   const MyScreen({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(title: const Text('Migrated Screen')),
///       body: MaterialUiCompatibilityBridge(
///         child: LegacyPackageWidget(),
///       ),
///     );
///   }
/// }
/// ```
///
/// Note that subtree placement does not provide [legacy.MaterialLocalizations]
/// to routes pushed onto [Navigator], because [InheritedTheme.capture] only
/// captures [InheritedTheme] widgets (such as [legacy.Theme]) and not
/// [Localizations]. Use app-wide placement in [modern.MaterialApp.builder] if
/// legacy widgets open dialogs, pickers, bottom sheets, or popup menus.
///
/// This is a temporary migration utility intended for use only while
/// dependencies are being migrated to `package:material_ui`, and is marked
/// `@Deprecated` to indicate it will be removed in a future release. If your
/// project runs `flutter analyze --fatal-infos`, suppress the diagnostic with
/// `// ignore: deprecated_member_use`.
@Deprecated(
  'MaterialUiCompatibilityBridge is a temporary migration utility intended for use only while '
  'dependencies are being migrated to package:material_ui. '
  'This feature was deprecated to indicate it will be removed in a future release.',
)
class MaterialUiCompatibilityBridge extends StatelessWidget {
  /// Creates a [MaterialUiCompatibilityBridge].
  @Deprecated(
    'MaterialUiCompatibilityBridge is a temporary migration utility intended for use only while '
    'dependencies are being migrated to package:material_ui. '
    'This feature was deprecated to indicate it will be removed in a future release.',
  )
  const MaterialUiCompatibilityBridge({super.key, required this.child, this.delegates});

  /// The widget below this widget in the tree.
  final Widget child;

  /// The localizations delegates for legacy widgets.
  ///
  /// Defaults to `[GlobalCupertinoLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate]`.
  final List<LocalizationsDelegate<dynamic>>? delegates;

  @override
  Widget build(BuildContext context) {
    final modern.ThemeData modernTheme = modern.Theme.of(context);

    return legacy.Theme(
      data: _mapToLegacy(modernTheme),
      child: legacy.Localizations.override(
        context: context,
        delegates:
            delegates ??
            const <LocalizationsDelegate<dynamic>>[
              GlobalCupertinoLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
        child: child,
      ),
    );
  }

  legacy.ThemeData _mapToLegacy(modern.ThemeData modernTheme) {
    final modern.ColorScheme scheme = modernTheme.colorScheme;
    final modern.TextTheme textTheme = modernTheme.textTheme;

    return legacy.ThemeData(
      platform: modernTheme.platform,
      visualDensity: legacy.VisualDensity(
        horizontal: modernTheme.visualDensity.horizontal,
        vertical: modernTheme.visualDensity.vertical,
      ),
      colorScheme: legacy.ColorScheme(
        brightness: scheme.brightness,
        primary: scheme.primary,
        onPrimary: scheme.onPrimary,
        primaryContainer: scheme.primaryContainer,
        onPrimaryContainer: scheme.onPrimaryContainer,
        secondary: scheme.secondary,
        onSecondary: scheme.onSecondary,
        secondaryContainer: scheme.secondaryContainer,
        onSecondaryContainer: scheme.onSecondaryContainer,
        tertiary: scheme.tertiary,
        onTertiary: scheme.onTertiary,
        tertiaryContainer: scheme.tertiaryContainer,
        onTertiaryContainer: scheme.onTertiaryContainer,
        error: scheme.error,
        onError: scheme.onError,
        errorContainer: scheme.errorContainer,
        onErrorContainer: scheme.onErrorContainer,
        surface: scheme.surface,
        onSurface: scheme.onSurface,
        surfaceDim: scheme.surfaceDim,
        surfaceBright: scheme.surfaceBright,
        surfaceContainerLowest: scheme.surfaceContainerLowest,
        surfaceContainerLow: scheme.surfaceContainerLow,
        surfaceContainer: scheme.surfaceContainer,
        surfaceContainerHigh: scheme.surfaceContainerHigh,
        surfaceContainerHighest: scheme.surfaceContainerHighest,
        onSurfaceVariant: scheme.onSurfaceVariant,
        outline: scheme.outline,
        outlineVariant: scheme.outlineVariant,
        shadow: scheme.shadow,
        scrim: scheme.scrim,
        inverseSurface: scheme.inverseSurface,
        onInverseSurface: scheme.onInverseSurface,
        inversePrimary: scheme.inversePrimary,
        surfaceTint: scheme.surfaceTint,
      ),
      textTheme: legacy.TextTheme(
        displayLarge: textTheme.displayLarge,
        displayMedium: textTheme.displayMedium,
        displaySmall: textTheme.displaySmall,
        headlineLarge: textTheme.headlineLarge,
        headlineMedium: textTheme.headlineMedium,
        headlineSmall: textTheme.headlineSmall,
        titleLarge: textTheme.titleLarge,
        titleMedium: textTheme.titleMedium,
        titleSmall: textTheme.titleSmall,
        bodyLarge: textTheme.bodyLarge,
        bodyMedium: textTheme.bodyMedium,
        bodySmall: textTheme.bodySmall,
        labelLarge: textTheme.labelLarge,
        labelMedium: textTheme.labelMedium,
        labelSmall: textTheme.labelSmall,
      ),
      cupertinoOverrideTheme: _mapCupertinoOverrideTheme(
        modernTheme.cupertinoOverrideTheme,
        modernTheme.colorScheme.primary,
      ),
    );
  }

  legacy_cupertino.NoDefaultCupertinoThemeData? _mapCupertinoOverrideTheme(
    modern_cupertino.NoDefaultCupertinoThemeData? override,
    Color fallbackPrimaryColor,
  ) {
    if (override == null) {
      return null;
    }
    final modern_cupertino.CupertinoTextThemeData? textTheme = override.textTheme;
    return legacy_cupertino.NoDefaultCupertinoThemeData(
      brightness: override.brightness,
      primaryColor: override.primaryColor,
      primaryContrastingColor: override.primaryContrastingColor,
      barBackgroundColor: override.barBackgroundColor,
      scaffoldBackgroundColor: override.scaffoldBackgroundColor,
      selectionHandleColor: override.selectionHandleColor,
      applyThemeToAll: override.applyThemeToAll,
      textTheme: textTheme == null
          ? null
          : legacy_cupertino.CupertinoTextThemeData(
              primaryColor: override.primaryColor ?? fallbackPrimaryColor,
              textStyle: textTheme.textStyle,
              actionTextStyle: textTheme.actionTextStyle,
              actionSmallTextStyle: textTheme.actionSmallTextStyle,
              tabLabelTextStyle: textTheme.tabLabelTextStyle,
              navTitleTextStyle: textTheme.navTitleTextStyle,
              navLargeTitleTextStyle: textTheme.navLargeTitleTextStyle,
              navActionTextStyle: textTheme.navActionTextStyle,
              pickerTextStyle: textTheme.pickerTextStyle,
              dateTimePickerTextStyle: textTheme.dateTimePickerTextStyle,
            ),
    );
  }
}
