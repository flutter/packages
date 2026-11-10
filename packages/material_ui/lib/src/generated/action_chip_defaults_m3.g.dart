// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Do not edit by hand. The code is generated from data in the Material
// Design token database by the script:
//   packages/material_ui/tool/gen_defaults/bin/gen_defaults.dart.
part of '../action_chip.dart';

class _ActionChipDefaultsM3 extends ChipThemeData {
  _ActionChipDefaultsM3(this.context, this.isEnabled, this._chipVariant)
    : super(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
        showCheckmark: true,
      );

  final BuildContext context;
  final bool isEnabled;
  final _ChipVariant _chipVariant;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  double? get elevation => _chipVariant == _ChipVariant.flat
      ? 0.0
      : isEnabled
      ? 1.0
      : 0.0;

  @override
  double? get pressElevation => 1.0;

  @override
  TextStyle? get labelStyle =>
      _textTheme.labelLarge?.copyWith(color: isEnabled ? _colors.onSurface : _colors.onSurface);

  @override
  WidgetStateProperty<Color?>? get color =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return _chipVariant == _ChipVariant.flat ? null : _colors.onSurface.withOpacity(0.12);
        }
        return _chipVariant == _ChipVariant.flat ? null : _colors.surfaceContainerLow;
      });

  @override
  Color? get shadowColor => _chipVariant == _ChipVariant.flat ? Colors.transparent : _colors.shadow;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  Color? get checkmarkColor => null;

  @override
  Color? get deleteIconColor => null;

  @override
  BorderSide? get side => _chipVariant == _ChipVariant.flat
      ? isEnabled
            ? BorderSide(color: _colors.outlineVariant)
            : BorderSide(color: _colors.onSurface.withOpacity(0.12))
      : const BorderSide(color: Colors.transparent);

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
