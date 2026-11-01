// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'elevated_button.dart';
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'button_style.dart';
import 'theme.dart';
import 'theme_data.dart';

// Examples can assume:
// late BuildContext context;

/// A [ButtonStyle] that overrides the default appearance of
/// [ElevatedButton]s when it's used with [ElevatedButtonTheme] or with the
/// overall [Theme]'s [ThemeData.elevatedButtonTheme].
///
/// The [style]'s properties override [ElevatedButton]'s default style,
/// i.e. the [ButtonStyle] returned by [ElevatedButton.defaultStyleOf]. Only
/// the style's non-null property values or resolved non-null
/// [WidgetStateProperty] values are used.
///
/// See also:
///
///  * [ElevatedButtonTheme], the theme which is configured with this class.
///  * [ElevatedButton.defaultStyleOf], which returns the default [ButtonStyle]
///    for text buttons.
///  * [ElevatedButton.styleFrom], which converts simple values into a
///    [ButtonStyle] that's consistent with [ElevatedButton]'s defaults.
///  * [WidgetStateProperty.resolve], "resolve" a material state property
///    to a simple value based on a set of [WidgetState]s.
///  * [ThemeData.elevatedButtonTheme], which can be used to override the default
///    [ButtonStyle] for [ElevatedButton]s below the overall [Theme].
@immutable
class ElevatedButtonThemeData with Diagnosticable {
  /// Creates an [ElevatedButtonThemeData].
  ///
  /// The [style] may be null.
  const ElevatedButtonThemeData({this.style, this.variant});

  /// Overrides for [ElevatedButton]'s default style.
  ///
  /// Non-null properties or non-null resolved [WidgetStateProperty]
  /// values override the [ButtonStyle] returned by
  /// [ElevatedButton.defaultStyleOf].
  ///
  /// If [style] is null, then this theme doesn't override anything.
  final ButtonStyle? style;

  /// The style variant of Material Design used by [ElevatedButton].
  ///
  /// Set this to [StyleVariant.material3Expressive] to opt elevated buttons
  /// into the Material 3 Expressive style.
  ///
  /// If null, the variant is inherited from the closest enclosing
  /// [ElevatedButtonTheme] that specifies one, and then from
  /// [ThemeData.elevatedButtonTheme]. If none of them specify a variant,
  /// [ElevatedButton] uses [StyleVariant.material3]. To keep a subtree on
  /// Material 3 when an ancestor opts into Material 3 Expressive, set this to
  /// [StyleVariant.material3].
  ///
  /// An enclosing [ElevatedButtonTheme] takes precedence over
  /// [ThemeData.elevatedButtonTheme], even when a closer [Theme] specifies a
  /// different variant. This matches [ElevatedButtonTheme.of], which only uses
  /// [ThemeData.elevatedButtonTheme] when there is no enclosing
  /// [ElevatedButtonTheme]. To change the variant of a subtree, wrap it in an
  /// [ElevatedButtonTheme].
  ///
  /// See also:
  ///
  ///  * [ElevatedButtonTheme.variantOf], which returns the variant that
  ///    applies at a given location.
  final StyleVariant? variant;

  /// Linearly interpolate between two elevated button themes.
  static ElevatedButtonThemeData? lerp(
    ElevatedButtonThemeData? a,
    ElevatedButtonThemeData? b,
    double t,
  ) {
    if (identical(a, b)) {
      return a;
    }
    return ElevatedButtonThemeData(
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
    return other is ElevatedButtonThemeData && other.style == style && other.variant == variant;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ButtonStyle>('style', style, defaultValue: null));
    properties.add(EnumProperty<StyleVariant>('variant', variant, defaultValue: null));
  }
}

/// Overrides the default [ButtonStyle] of its [ElevatedButton] descendants.
///
/// See also:
///
///  * [ElevatedButtonThemeData], which is used to configure this theme.
///  * [ElevatedButton.defaultStyleOf], which returns the default [ButtonStyle]
///    for elevated buttons.
///  * [ElevatedButton.styleFrom], which converts simple values into a
///    [ButtonStyle] that's consistent with [ElevatedButton]'s defaults.
///  * [ThemeData.elevatedButtonTheme], which can be used to override the default
///    [ButtonStyle] for [ElevatedButton]s below the overall [Theme].
class ElevatedButtonTheme extends InheritedTheme {
  /// Create a [ElevatedButtonTheme].
  const ElevatedButtonTheme({super.key, required this.data, required super.child});

  /// The configuration of this theme.
  final ElevatedButtonThemeData data;

  /// Retrieves the [ElevatedButtonThemeData] from the closest ancestor [ElevatedButtonTheme].
  ///
  /// If there is no enclosing [ElevatedButtonTheme] widget, then
  /// [ThemeData.elevatedButtonTheme] is used.
  ///
  /// The returned [ElevatedButtonThemeData.variant] is the value specified by
  /// that theme, which can be null even when an ancestor specifies a variant.
  /// Use [variantOf] to get the variant that applies at the given [context].
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// ElevatedButtonThemeData theme = ElevatedButtonTheme.of(context);
  /// ```
  static ElevatedButtonThemeData of(BuildContext context) {
    final ElevatedButtonTheme? buttonTheme = context
        .dependOnInheritedWidgetOfExactType<ElevatedButtonTheme>();
    return buttonTheme?.data ?? Theme.of(context).elevatedButtonTheme;
  }

  /// Returns the [StyleVariant] that [ElevatedButton]s use at the given
  /// [context].
  ///
  /// The closest enclosing [ElevatedButtonTheme] whose
  /// [ElevatedButtonThemeData.variant] is non-null determines the variant, so
  /// an [ElevatedButtonTheme] that doesn't specify a variant inherits it from
  /// its ancestors. If none of the enclosing [ElevatedButtonTheme]s specify a
  /// variant, the variant of [ThemeData.elevatedButtonTheme] is used. If that
  /// is also null, [StyleVariant.material3] is returned.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// final StyleVariant variant = ElevatedButtonTheme.variantOf(context);
  /// ```
  static StyleVariant variantOf(BuildContext context) {
    InheritedElement? element = context
        .getElementForInheritedWidgetOfExactType<ElevatedButtonTheme>();
    while (element != null) {
      // Depend on every theme that is visited, so that a change to any of them
      // rebuilds the dependent.
      context.dependOnInheritedElement(element);
      final StyleVariant? variant = (element.widget as ElevatedButtonTheme).data.variant;
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
      element = parent?.getElementForInheritedWidgetOfExactType<ElevatedButtonTheme>();
    }
    return Theme.of(context).elevatedButtonTheme.variant ?? StyleVariant.material3;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return ElevatedButtonTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(ElevatedButtonTheme oldWidget) => data != oldWidget.data;
}
