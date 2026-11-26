// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'outlined_button.dart';
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'button_style.dart';
import 'theme.dart';
import 'theme_data.dart';

// Examples can assume:
// late BuildContext context;

/// A [ButtonStyle] that overrides the default appearance of
/// [OutlinedButton]s when it's used with [OutlinedButtonTheme] or with the
/// overall [Theme]'s [ThemeData.outlinedButtonTheme].
///
/// The [style]'s properties override [OutlinedButton]'s default style,
/// i.e. the [ButtonStyle] returned by [OutlinedButton.defaultStyleOf]. Only
/// the style's non-null property values or resolved non-null
/// [WidgetStateProperty] values are used.
///
/// See also:
///
///  * [OutlinedButtonTheme], the theme which is configured with this class.
///  * [OutlinedButton.defaultStyleOf], which returns the default [ButtonStyle]
///    for outlined buttons.
///  * [OutlinedButton.styleFrom], which converts simple values into a
///    [ButtonStyle] that's consistent with [OutlinedButton]'s defaults.
///  * [WidgetStateProperty.resolve], "resolve" a material state property
///    to a simple value based on a set of [WidgetState]s.
///  * [ThemeData.outlinedButtonTheme], which can be used to override the default
///    [ButtonStyle] for [OutlinedButton]s below the overall [Theme].
@immutable
class OutlinedButtonThemeData with Diagnosticable {
  /// Creates an [OutlinedButtonThemeData].
  ///
  /// The [style] may be null.
  const OutlinedButtonThemeData({this.style, this.variant});

  /// Overrides for [OutlinedButton]'s default style.
  ///
  /// Non-null properties or non-null resolved [WidgetStateProperty]
  /// values override the [ButtonStyle] returned by
  /// [OutlinedButton.defaultStyleOf].
  ///
  /// If [style] is null, then this theme doesn't override anything.
  final ButtonStyle? style;

  /// The style variant of Material Design used by [OutlinedButton].
  ///
  /// Set this to [StyleVariant.material3Expressive] to opt outlined buttons into
  /// the Material 3 Expressive style.
  ///
  /// If null, the variant is inherited from the closest enclosing
  /// [OutlinedButtonTheme] that specifies one, and then from
  /// [ThemeData.outlinedButtonTheme]. If none of them specify a variant,
  /// [OutlinedButton] uses [StyleVariant.material3]. To keep a subtree on
  /// Material 3 when an ancestor opts into Material 3 Expressive, set this to
  /// [StyleVariant.material3].
  ///
  /// An enclosing [OutlinedButtonTheme] takes precedence over
  /// [ThemeData.outlinedButtonTheme], even when a closer [Theme] specifies a
  /// different variant. This matches [OutlinedButtonTheme.of], which only uses
  /// [ThemeData.outlinedButtonTheme] when there is no enclosing
  /// [OutlinedButtonTheme]. To change the variant of a subtree, wrap it in an
  /// [OutlinedButtonTheme].
  ///
  /// See also:
  ///
  ///  * [OutlinedButtonTheme.variantOf], which returns the variant that applies
  ///    at a given location.
  final StyleVariant? variant;

  /// Linearly interpolate between two outlined button themes.
  static OutlinedButtonThemeData? lerp(
    OutlinedButtonThemeData? a,
    OutlinedButtonThemeData? b,
    double t,
  ) {
    if (identical(a, b)) {
      return a;
    }
    return OutlinedButtonThemeData(
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
    return other is OutlinedButtonThemeData && other.style == style && other.variant == variant;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ButtonStyle>('style', style, defaultValue: null));
    properties.add(EnumProperty<StyleVariant>('variant', variant, defaultValue: null));
  }
}

/// Overrides the default [ButtonStyle] of its [OutlinedButton] descendants.
///
/// See also:
///
///  * [OutlinedButtonThemeData], which is used to configure this theme.
///  * [OutlinedButton.defaultStyleOf], which returns the default [ButtonStyle]
///    for outlined buttons.
///  * [OutlinedButton.styleFrom], which converts simple values into a
///    [ButtonStyle] that's consistent with [OutlinedButton]'s defaults.
///  * [ThemeData.outlinedButtonTheme], which can be used to override the default
///    [ButtonStyle] for [OutlinedButton]s below the overall [Theme].
class OutlinedButtonTheme extends InheritedTheme {
  /// Create an [OutlinedButtonTheme].
  const OutlinedButtonTheme({super.key, required this.data, required super.child});

  /// The configuration of this theme.
  final OutlinedButtonThemeData data;

  /// Retrieves the [OutlinedButtonThemeData] from the closest ancestor [OutlinedButtonTheme].
  ///
  /// If there is no enclosing [OutlinedButtonTheme] widget, then
  /// [ThemeData.outlinedButtonTheme] is used.
  ///
  /// The returned [OutlinedButtonThemeData.variant] is the value specified by
  /// that theme, which can be null even when an ancestor specifies a variant.
  /// Use [variantOf] to get the variant that applies at the given [context].
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// OutlinedButtonThemeData theme = OutlinedButtonTheme.of(context);
  /// ```
  static OutlinedButtonThemeData of(BuildContext context) {
    final OutlinedButtonTheme? buttonTheme = context
        .dependOnInheritedWidgetOfExactType<OutlinedButtonTheme>();
    return buttonTheme?.data ?? Theme.of(context).outlinedButtonTheme;
  }

  /// Returns the [StyleVariant] that [OutlinedButton]s use at the given
  /// [context].
  ///
  /// The closest enclosing [OutlinedButtonTheme] whose
  /// [OutlinedButtonThemeData.variant] is non-null determines the variant, so a
  /// [OutlinedButtonTheme] that doesn't specify a variant inherits it from its
  /// ancestors. If none of the enclosing [OutlinedButtonTheme]s specify a
  /// variant, the variant of [ThemeData.outlinedButtonTheme] is used. If that is
  /// also null, [StyleVariant.material3] is returned.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// final StyleVariant variant = OutlinedButtonTheme.variantOf(context);
  /// ```
  static StyleVariant variantOf(BuildContext context) {
    InheritedElement? element = context
        .getElementForInheritedWidgetOfExactType<OutlinedButtonTheme>();
    while (element != null) {
      // Depend on every theme that is visited, so that a change to any of them
      // rebuilds the dependent.
      context.dependOnInheritedElement(element);
      final StyleVariant? variant = (element.widget as OutlinedButtonTheme).data.variant;
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
      element = parent?.getElementForInheritedWidgetOfExactType<OutlinedButtonTheme>();
    }
    return Theme.of(context).outlinedButtonTheme.variant ?? StyleVariant.material3;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return OutlinedButtonTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(OutlinedButtonTheme oldWidget) => data != oldWidget.data;
}
