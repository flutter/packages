// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'text_button.dart';
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'button_style.dart';
import 'theme.dart';
import 'theme_data.dart';

// Examples can assume:
// late BuildContext context;

/// A [ButtonStyle] that overrides the default appearance of
/// [TextButton]s when it's used with [TextButtonTheme] or with the
/// overall [Theme]'s [ThemeData.textButtonTheme].
///
/// The [style]'s properties override [TextButton]'s default style,
/// i.e. the [ButtonStyle] returned by [TextButton.defaultStyleOf]. Only
/// the style's non-null property values or resolved non-null
/// [WidgetStateProperty] values are used.
///
/// See also:
///
///  * [TextButtonTheme], the theme which is configured with this class.
///  * [TextButton.defaultStyleOf], which returns the default [ButtonStyle]
///    for text buttons.
///  * [TextButton.styleFrom], which converts simple values into a
///    [ButtonStyle] that's consistent with [TextButton]'s defaults.
///  * [WidgetStateProperty.resolve], "resolve" a material state property
///    to a simple value based on a set of [WidgetState]s.
///  * [ThemeData.textButtonTheme], which can be used to override the default
///    [ButtonStyle] for [TextButton]s below the overall [Theme].
@immutable
class TextButtonThemeData with Diagnosticable {
  /// Creates a [TextButtonThemeData].
  ///
  /// The [style] may be null.
  const TextButtonThemeData({this.style, this.variant});

  /// Overrides for [TextButton]'s default style.
  ///
  /// Non-null properties or non-null resolved [WidgetStateProperty]
  /// values override the [ButtonStyle] returned by
  /// [TextButton.defaultStyleOf].
  ///
  /// If [style] is null, then this theme doesn't override anything.
  final ButtonStyle? style;

  /// The style variant of Material Design used by [TextButton].
  ///
  /// Set this to [StyleVariant.material3Expressive] to opt text buttons into
  /// the Material 3 Expressive style.
  ///
  /// If null, the variant is inherited from the closest enclosing
  /// [TextButtonTheme] that specifies one, and then from
  /// [ThemeData.textButtonTheme]. If none of them specify a variant,
  /// [TextButton] uses [StyleVariant.material3]. To keep a subtree on
  /// Material 3 when an ancestor opts into Material 3 Expressive, set this to
  /// [StyleVariant.material3].
  ///
  /// An enclosing [TextButtonTheme] takes precedence over
  /// [ThemeData.textButtonTheme], even when a closer [Theme] specifies a
  /// different variant. This matches [TextButtonTheme.of], which only uses
  /// [ThemeData.textButtonTheme] when there is no enclosing
  /// [TextButtonTheme]. To change the variant of a subtree, wrap it in a
  /// [TextButtonTheme].
  ///
  /// See also:
  ///
  ///  * [TextButtonTheme.variantOf], which returns the variant that applies
  ///    at a given location.
  final StyleVariant? variant;

  /// Linearly interpolate between two text button themes.
  static TextButtonThemeData? lerp(TextButtonThemeData? a, TextButtonThemeData? b, double t) {
    if (identical(a, b)) {
      return a;
    }
    return TextButtonThemeData(
      style: ButtonStyle.lerp(a?.style, b?.style, t),
      variant: t < 0.5 ? a?.variant : b?.variant,
    );
  }

  @override
  int get hashCode => Object.hash(style, variant);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is TextButtonThemeData && other.style == style && other.variant == variant;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ButtonStyle>('style', style, defaultValue: null));
    properties.add(EnumProperty<StyleVariant>('variant', variant, defaultValue: null));
  }
}

/// Overrides the default [ButtonStyle] of its [TextButton] descendants.
///
/// See also:
///
///  * [TextButtonThemeData], which is used to configure this theme.
///  * [TextButton.defaultStyleOf], which returns the default [ButtonStyle]
///    for text buttons.
///  * [TextButton.styleFrom], which converts simple values into a
///    [ButtonStyle] that's consistent with [TextButton]'s defaults.
///  * [ThemeData.textButtonTheme], which can be used to override the default
///    [ButtonStyle] for [TextButton]s below the overall [Theme].
class TextButtonTheme extends InheritedTheme {
  /// Create a [TextButtonTheme].
  const TextButtonTheme({super.key, required this.data, required super.child});

  /// The configuration of this theme.
  final TextButtonThemeData data;

  /// Retrieves the [TextButtonThemeData] from the closest ancestor [TextButtonTheme].
  ///
  /// If there is no enclosing [TextButtonTheme] widget, then
  /// [ThemeData.textButtonTheme] is used.
  ///
  /// The returned [TextButtonThemeData.variant] is the value specified by
  /// that theme, which can be null even when an ancestor specifies a variant.
  /// Use [variantOf] to get the variant that applies at the given [context].
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// TextButtonThemeData theme = TextButtonTheme.of(context);
  /// ```
  static TextButtonThemeData of(BuildContext context) {
    final TextButtonTheme? buttonTheme = context
        .dependOnInheritedWidgetOfExactType<TextButtonTheme>();
    return buttonTheme?.data ?? Theme.of(context).textButtonTheme;
  }

  /// Returns the [StyleVariant] that [TextButton]s use at the given
  /// [context].
  ///
  /// The closest enclosing [TextButtonTheme] whose
  /// [TextButtonThemeData.variant] is non-null determines the variant, so a
  /// [TextButtonTheme] that doesn't specify a variant inherits it from its
  /// ancestors. If none of the enclosing [TextButtonTheme]s specify a
  /// variant, the variant of [ThemeData.textButtonTheme] is used. If that is
  /// also null, [StyleVariant.material3] is returned.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// final StyleVariant variant = TextButtonTheme.variantOf(context);
  /// ```
  static StyleVariant variantOf(BuildContext context) {
    InheritedElement? element = context.getElementForInheritedWidgetOfExactType<TextButtonTheme>();
    while (element != null) {
      // Depend on every theme that is visited, so that a change to any of them
      // rebuilds the dependent.
      context.dependOnInheritedElement(element);
      final StyleVariant? variant = (element.widget as TextButtonTheme).data.variant;
      if (variant != null) {
        return variant;
      }
      // Calling getElementForInheritedWidgetOfExactType on the element itself
      // would return the same element, so continue the search from its parent.
      Element? parent;
      element.visitAncestorElements((Element ancestor) {
        parent = ancestor;
        return false;
      });
      element = parent?.getElementForInheritedWidgetOfExactType<TextButtonTheme>();
    }
    return Theme.of(context).textButtonTheme.variant ?? StyleVariant.material3;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return TextButtonTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(TextButtonTheme oldWidget) => data != oldWidget.data;
}
