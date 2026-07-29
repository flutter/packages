// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart' as modern; // ignore: prefer_relative_imports
import 'package:flutter/cupertino.dart' as legacy;
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// A bridge widget for applications that have migrated to `package:cupertino_ui`
/// but still contain subtrees or package dependencies using `package:flutter/cupertino.dart`.
///
/// This widget maps the parent [modern.CupertinoThemeData] from `package:cupertino_ui` into
/// a legacy [legacy.CupertinoThemeData] and overrides [legacy.Localizations] with delegates
/// so that legacy widgets in [child] can resolve `legacy.CupertinoTheme.of(context)` and
/// `legacy.CupertinoLocalizations.of(context)`.
///
/// ## App-wide usage
///
/// The recommended way to use this bridge across an entire application is to
/// wrap the app once using [modern.CupertinoApp.builder]:
///
/// ```dart
/// import 'package:cupertino_ui/cupertino_ui.dart';
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
///     return CupertinoApp(
///       theme: const CupertinoThemeData(
///         primaryColor: CupertinoColors.systemIndigo,
///       ),
///       builder: (BuildContext context, Widget? child) {
///         return CupertinoUiCompatibilityBridge(child: child!);
///       },
///       home: const HomeScreen(),
///     );
///   }
/// }
/// ```
///
/// ## Subtree usage
///
/// Alternatively, wrap specific legacy package widgets or subtrees:
///
/// ```dart
/// import 'package:cupertino_ui/cupertino_ui.dart';
/// import 'package:some_legacy_package/some_legacy_package.dart';
///
/// class MyScreen extends StatelessWidget {
///   const MyScreen({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     return CupertinoPageScaffold(
///       navigationBar: const CupertinoNavigationBar(
///         middle: Text('Migrated Screen'),
///       ),
///       child: CupertinoUiCompatibilityBridge(
///         child: LegacyPackageWidget(),
///       ),
///     );
///   }
/// }
/// ```
@Deprecated(
  'CupertinoUiCompatibilityBridge is a temporary migration utility intended for use only while '
  'dependencies are being migrated to package:cupertino_ui. '
  'This feature was deprecated to indicate it will be removed in a future release.',
)
class CupertinoUiCompatibilityBridge extends StatelessWidget {
  /// Creates a [CupertinoUiCompatibilityBridge].
  @Deprecated(
    'CupertinoUiCompatibilityBridge is a temporary migration utility intended for use only while '
    'dependencies are being migrated to package:cupertino_ui. '
    'This feature was deprecated to indicate it will be removed in a future release.',
  )
  const CupertinoUiCompatibilityBridge({super.key, required this.child, this.delegates});

  /// The widget below this widget in the tree.
  final Widget child;

  /// The localizations delegates for legacy widgets.
  ///
  /// Defaults to `[GlobalCupertinoLocalizations.delegate, GlobalWidgetsLocalizations.delegate]`.
  final List<LocalizationsDelegate<dynamic>>? delegates;

  @override
  Widget build(BuildContext context) {
    final modern.CupertinoThemeData modernTheme = modern.CupertinoTheme.of(context);

    return legacy.CupertinoTheme(
      data: _mapToLegacy(modernTheme),
      child: legacy.Localizations.override(
        context: context,
        delegates:
            delegates ??
            const <LocalizationsDelegate<dynamic>>[
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
        child: child,
      ),
    );
  }

  legacy.CupertinoThemeData _mapToLegacy(modern.CupertinoThemeData modernTheme) {
    return legacy.CupertinoThemeData(
      brightness: modernTheme.brightness,
      primaryColor: modernTheme.primaryColor,
      primaryContrastingColor: modernTheme.primaryContrastingColor,
      barBackgroundColor: modernTheme.barBackgroundColor,
      scaffoldBackgroundColor: modernTheme.scaffoldBackgroundColor,
      selectionHandleColor: modernTheme.selectionHandleColor,
      applyThemeToAll: modernTheme.applyThemeToAll,
      textTheme: legacy.CupertinoTextThemeData(
        primaryColor: modernTheme.primaryColor,
        textStyle: modernTheme.textTheme.textStyle,
        actionTextStyle: modernTheme.textTheme.actionTextStyle,
        actionSmallTextStyle: modernTheme.textTheme.actionSmallTextStyle,
        tabLabelTextStyle: modernTheme.textTheme.tabLabelTextStyle,
        navTitleTextStyle: modernTheme.textTheme.navTitleTextStyle,
        navLargeTitleTextStyle: modernTheme.textTheme.navLargeTitleTextStyle,
        navActionTextStyle: modernTheme.textTheme.navActionTextStyle,
        pickerTextStyle: modernTheme.textTheme.pickerTextStyle,
        dateTimePickerTextStyle: modernTheme.textTheme.dateTimePickerTextStyle,
      ),
    );
  }
}
