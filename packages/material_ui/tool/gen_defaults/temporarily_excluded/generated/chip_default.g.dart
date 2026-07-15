// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class _ChipDefaultsM3 extends ChipThemeData {
  _ChipDefaultsM3(this.context, this.isEnabled)
    : super(
        elevation: 0.0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
        showCheckmark: true,
      );

  final BuildContext context;
  final bool isEnabled;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  TextStyle? get labelStyle => _textTheme.labelLarge?.copyWith(
    color: isEnabled ? _colors.onSurfaceVariant : _colors.onSurface,
  );

  @override
  WidgetStateProperty<Color?>? get color => null; // Subclasses override this getter

  @override
  Color? get shadowColor => Colors.transparent;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  Color? get checkmarkColor => null;

  @override
  Color? get deleteIconColor => isEnabled ? _colors.onSurfaceVariant : _colors.onSurface;

  @override
  BorderSide? get side =>
      isEnabled
          ? BorderSide(color: _colors.outlineVariant)
          : BorderSide(color: _colors.onSurface.withOpacity(0.12));

  @override
  IconThemeData? get iconTheme =>
      IconThemeData(color: isEnabled ? _colors.primary : _colors.onSurface, size: 18.0);

  @override
  EdgeInsetsGeometry? get padding => const EdgeInsets.all(8.0);

  /// The label padding of the chip scales with the font size specified in the
  /// [labelStyle], and the system font size settings that scale font sizes
  /// globally.
  ///
  /// The chip at effective font size 14.0 starts with 8px on each side and as
  /// the font size scales up to closer to 28.0, the label padding is linearly
  /// interpolated from 8px to 4px. Once the label has a font size of 2 or
  /// higher, label padding remains 4px.
  @override
  EdgeInsetsGeometry? get labelPadding {
    final double fontSize = labelStyle?.fontSize ?? 14.0;
    final double fontSizeRatio = MediaQuery.textScalerOf(context).scale(fontSize) / 14.0;
    return EdgeInsets.lerp(
      const EdgeInsets.symmetric(horizontal: 8.0),
      const EdgeInsets.symmetric(horizontal: 4.0),
      clampDouble(fontSizeRatio - 1.0, 0.0, 1.0),
    )!;
  }
}
