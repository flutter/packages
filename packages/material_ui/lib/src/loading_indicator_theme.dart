// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// @docImport 'loading_indicator.dart';
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'theme.dart';

// Examples can assume:
// late BuildContext context;

/// Defines default property values for descendant [LoadingIndicator] widgets.
///
/// Descendant widgets obtain the current [LoadingIndicatorThemeData] object
/// using [LoadingIndicatorTheme.of]. Instances of [LoadingIndicatorThemeData]
/// can be customized with [LoadingIndicatorThemeData.copyWith].
///
/// Typically a [LoadingIndicatorThemeData] is specified as part of the overall
/// [Theme] with [ThemeData.loadingIndicatorTheme].
///
/// All [LoadingIndicatorThemeData] properties are `null` by default. When
/// null, the [LoadingIndicator] provides its own defaults.
///
/// See also:
///
///  * [ThemeData], which describes the overall theme information for the
///    application.
@immutable
class LoadingIndicatorThemeData with Diagnosticable {
  /// Creates the set of properties used to configure [LoadingIndicator]s.
  const LoadingIndicatorThemeData({
    this.color,
    this.containedColor,
    this.containerColor,
    this.containerShape,
  });

  /// Overrides the default value for [LoadingIndicator.color] of a default
  /// loading indicator.
  final Color? color;

  /// Overrides the default value for [LoadingIndicator.color] of a
  /// [LoadingIndicator.contained] loading indicator.
  final Color? containedColor;

  /// Overrides the default value for [LoadingIndicator.containerColor].
  final Color? containerColor;

  /// Overrides the default value for [LoadingIndicator.containerShape].
  final ShapeBorder? containerShape;

  /// Creates a copy of this object but with the given fields replaced with the
  /// new values.
  LoadingIndicatorThemeData copyWith({
    Color? color,
    Color? containedColor,
    Color? containerColor,
    ShapeBorder? containerShape,
  }) {
    return LoadingIndicatorThemeData(
      color: color ?? this.color,
      containedColor: containedColor ?? this.containedColor,
      containerColor: containerColor ?? this.containerColor,
      containerShape: containerShape ?? this.containerShape,
    );
  }

  /// Linearly interpolate between two loading indicator themes.
  static LoadingIndicatorThemeData? lerp(
    LoadingIndicatorThemeData? a,
    LoadingIndicatorThemeData? b,
    double t,
  ) {
    if (identical(a, b)) {
      return a;
    }
    return LoadingIndicatorThemeData(
      color: Color.lerp(a?.color, b?.color, t),
      containedColor: Color.lerp(a?.containedColor, b?.containedColor, t),
      containerColor: Color.lerp(a?.containerColor, b?.containerColor, t),
      containerShape: ShapeBorder.lerp(a?.containerShape, b?.containerShape, t),
    );
  }

  @override
  int get hashCode => Object.hash(color, containedColor, containerColor, containerShape);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is LoadingIndicatorThemeData &&
        other.color == color &&
        other.containedColor == containedColor &&
        other.containerColor == containerColor &&
        other.containerShape == containerShape;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('color', color, defaultValue: null));
    properties.add(ColorProperty('containedColor', containedColor, defaultValue: null));
    properties.add(ColorProperty('containerColor', containerColor, defaultValue: null));
    properties.add(
      DiagnosticsProperty<ShapeBorder>('containerShape', containerShape, defaultValue: null),
    );
  }
}

/// An inherited widget that defines the configuration for
/// [LoadingIndicator]s in this widget's subtree.
///
/// Values specified here are used for [LoadingIndicator] properties that are
/// not given an explicit non-null value.
class LoadingIndicatorTheme extends InheritedTheme {
  /// Creates a theme that controls the configurations for [LoadingIndicator]s
  /// in this widget's subtree.
  const LoadingIndicatorTheme({super.key, required this.data, required super.child});

  /// The properties for descendant [LoadingIndicator] widgets.
  final LoadingIndicatorThemeData data;

  /// Retrieves the [LoadingIndicatorThemeData] from the closest ancestor
  /// [LoadingIndicatorTheme].
  ///
  /// If there is no enclosing [LoadingIndicatorTheme] widget, then
  /// [ThemeData.loadingIndicatorTheme] is used.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// LoadingIndicatorThemeData theme = LoadingIndicatorTheme.of(context);
  /// ```
  static LoadingIndicatorThemeData of(BuildContext context) {
    final LoadingIndicatorTheme? loadingIndicatorTheme = context
        .dependOnInheritedWidgetOfExactType<LoadingIndicatorTheme>();
    return loadingIndicatorTheme?.data ?? Theme.of(context).loadingIndicatorTheme;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return LoadingIndicatorTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(LoadingIndicatorTheme oldWidget) => data != oldWidget.data;
}
