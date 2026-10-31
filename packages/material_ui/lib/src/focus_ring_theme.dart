// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'colors.dart';
/// @docImport 'ink_well.dart';
/// @docImport 'snack_bar.dart';
library;

import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'theme.dart';

// Examples can assume:
// late BuildContext context;

/// Defines the keyboard focus ring that Material widgets draw around the
/// focused control.
///
/// Material 3 specifies a solid focus indicator for each component, in
/// addition to the focus state layer. When [visible] is true, [InkResponse]
/// and the widgets built on it, such as buttons, list tiles, chips, tabs and
/// navigation destinations, draw this ring while they have keyboard focus.
///
/// The ring only appears when [FocusManager.highlightMode] is
/// [FocusHighlightMode.traditional], so touch and mouse interactions do not
/// show it.
///
/// Typically a [FocusRingThemeData] is specified as part of the overall
/// [Theme] with [ThemeData.focusRingTheme].
///
/// All [FocusRingThemeData] properties are `null` by default, which draws no
/// ring.
///
/// See also:
///
///  * [FocusRingTheme], which overrides the focus ring for a subtree.
///  * [InkResponse.focusRingOffset], which positions the ring relative to the
///    highlight shape of a widget.
@immutable
class FocusRingThemeData with Diagnosticable {
  /// Creates a theme that configures the keyboard focus ring.
  const FocusRingThemeData({this.visible, this.color, this.innerColor, this.width});

  /// Whether Material widgets draw a focus ring while they have keyboard
  /// focus.
  ///
  /// If null, defaults to false.
  final bool? visible;

  /// The color of the focus ring.
  ///
  /// If null, defaults to [ColorScheme.secondary], the Material 3
  /// `focus.indicator.color` token.
  final Color? color;

  /// The color of a second band drawn just inside the ring, on the side
  /// closer to the widget.
  ///
  /// A single ring color can blend into some backgrounds, for example a
  /// [ColorScheme.secondary] ring on a [ColorScheme.primary] app bar or on a
  /// dark [SnackBar]. A contrasting inner band keeps one of the two visible
  /// on any background.
  ///
  /// The band has the same [width] as the ring. If null, defaults to
  /// [ColorScheme.onSecondary], so the default ring pairs [ColorScheme.secondary]
  /// with [ColorScheme.onSecondary]. Use [Colors.transparent] to draw the ring
  /// alone.
  final Color? innerColor;

  /// The thickness of the focus ring in logical pixels.
  ///
  /// If null, defaults to 3.0, the Material 3
  /// `md.sys.state.focus-indicator.thickness` token.
  final double? width;

  /// Creates a copy of this object but with the given fields replaced with the
  /// new values.
  FocusRingThemeData copyWith({bool? visible, Color? color, Color? innerColor, double? width}) {
    return FocusRingThemeData(
      visible: visible ?? this.visible,
      color: color ?? this.color,
      innerColor: innerColor ?? this.innerColor,
      width: width ?? this.width,
    );
  }

  /// Linearly interpolate between two focus ring themes.
  static FocusRingThemeData lerp(FocusRingThemeData? a, FocusRingThemeData? b, double t) {
    if (identical(a, b) && a != null) {
      return a;
    }
    return FocusRingThemeData(
      visible: t < 0.5 ? a?.visible : b?.visible,
      color: Color.lerp(a?.color, b?.color, t),
      innerColor: Color.lerp(a?.innerColor, b?.innerColor, t),
      width: lerpDouble(a?.width, b?.width, t),
    );
  }

  @override
  int get hashCode => Object.hash(visible, color, innerColor, width);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is FocusRingThemeData &&
        other.visible == visible &&
        other.color == color &&
        other.innerColor == innerColor &&
        other.width == width;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('visible', visible, defaultValue: null));
    properties.add(ColorProperty('color', color, defaultValue: null));
    properties.add(ColorProperty('innerColor', innerColor, defaultValue: null));
    properties.add(DoubleProperty('width', width, defaultValue: null));
  }
}

/// An inherited widget that overrides the keyboard focus ring for Material
/// widgets in this widget's subtree.
///
/// See also:
///
///  * [FocusRingThemeData], which describes the focus ring.
class FocusRingTheme extends InheritedTheme {
  /// Creates a theme that overrides the focus ring for Material widgets in
  /// this widget's subtree.
  const FocusRingTheme({super.key, required this.data, required super.child});

  /// Specifies the focus ring for descendant Material widgets.
  final FocusRingThemeData data;

  /// Retrieves the [FocusRingThemeData] from the closest ancestor
  /// [FocusRingTheme].
  ///
  /// If there is no enclosing [FocusRingTheme] widget, then
  /// [ThemeData.focusRingTheme] is used.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// FocusRingThemeData theme = FocusRingTheme.of(context);
  /// ```
  static FocusRingThemeData of(BuildContext context) {
    final FocusRingTheme? focusRingTheme = context
        .dependOnInheritedWidgetOfExactType<FocusRingTheme>();
    return focusRingTheme?.data ?? Theme.of(context).focusRingTheme;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return FocusRingTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(FocusRingTheme oldWidget) => data != oldWidget.data;
}
