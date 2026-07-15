// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class _RangeSliderDefaultsM3 extends SliderThemeData {
  _RangeSliderDefaultsM3(this.context) : super(trackHeight: 16.0);

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  Color? get activeTrackColor => _colors.primary;

  @override
  Color? get inactiveTrackColor => _colors.secondaryContainer;

  @override
  Color? get disabledActiveTrackColor => _colors.onSurface.withOpacity(0.38);

  @override
  Color? get disabledInactiveTrackColor => _colors.onSurface.withOpacity(0.12);

  @override
  Color? get activeTickMarkColor => _colors.onPrimary.withOpacity(1.0);

  @override
  Color? get inactiveTickMarkColor => _colors.onSecondaryContainer.withOpacity(1.0);

  @override
  Color? get disabledActiveTickMarkColor => _colors.onInverseSurface;

  @override
  Color? get disabledInactiveTickMarkColor => _colors.onSurface;

  @override
  Color? get thumbColor => _colors.primary;

  @override
  Color? get overlappingShapeStrokeColor => _colors.surface;

  @override
  Color? get disabledThumbColor => _colors.onSurface.withOpacity(0.38);

  @override
  Color? get overlayColor => _colors.primary.withOpacity(0.12);

  @override
  TextStyle? get valueIndicatorTextStyle =>
      Theme.of(context).textTheme.labelLarge!.copyWith(color: _colors.onInverseSurface);

  @override
  Color? get valueIndicatorColor => _colors.inverseSurface;

  @override
  RangeSliderTrackShape? get rangeTrackShape => const GappedRangeSliderTrackShape();

  @override
  RangeSliderTickMarkShape? get rangeTickMarkShape =>
      const RoundRangeSliderTickMarkShape(tickMarkRadius: 4.0 / 2);

  @override
  RangeSliderThumbShape? get rangeThumbShape => const HandleRangeSliderThumbShape();

  @override
  SliderComponentShape? get overlayShape => const RoundSliderOverlayShape();

  @override
  RangeSliderValueIndicatorShape? get rangeValueIndicatorShape =>
      const RoundedRectRangeSliderValueIndicatorShape();

  @override
  ShowValueIndicator? get showValueIndicator => ShowValueIndicator.onlyForDiscrete;

  @override
  double? get minThumbSeparation => 0;

  @override
  WidgetStateProperty<Size?>? get thumbSize {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return const Size(4.0, 44.0);
      }
      if (states.contains(WidgetState.hovered)) {
        return const Size(4.0, 44.0);
      }
      if (states.contains(WidgetState.focused)) {
        return const Size(2.0, 44.0);
      }
      if (states.contains(WidgetState.pressed)) {
        return const Size(2.0, 44.0);
      }
      return const Size(4.0, 44.0);
    });
  }

  @override
  double? get trackGap => 6.0;
}
