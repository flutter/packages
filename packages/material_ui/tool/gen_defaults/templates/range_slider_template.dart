// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/slider.dart';
import '../data/typescale.dart';
import 'template.dart';

class RangeSliderTemplateM3 extends TokenTemplateM3 {
  const RangeSliderTemplateM3();

  @override
  String get name => 'Range Slider';

  @override
  String get parentFilePath => 'range_slider.dart';

  @override
  String generateContents(String className) =>
      '''
class $className extends SliderThemeData {
  $className(this.context)
    : super(trackHeight: ${TokenSlider.activeTrackHeight});

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  Color? get activeTrackColor => ${color(TokenSlider.activeTrackColor)};

  @override
  Color? get inactiveTrackColor => ${color(TokenSlider.inactiveTrackColor)};

  @override
  Color? get disabledActiveTrackColor => ${colorWithOpacity(TokenSlider.disabledActiveTrackColor, TokenSlider.disabledActiveTrackOpacity)};

  @override
  Color? get disabledInactiveTrackColor => ${colorWithOpacity(TokenSlider.disabledInactiveTrackColor, TokenSlider.disabledInactiveTrackOpacity)};

  @override
  Color? get activeTickMarkColor => ${color(TokenSlider.activeStopIndicatorContainerColor)}.withOpacity(${TokenSlider.activeStopIndicatorContainerOpacity});

  @override
  Color? get inactiveTickMarkColor => ${color(TokenSlider.inactiveStopIndicatorContainerColor)}.withOpacity(${TokenSlider.inactiveStopIndicatorContainerOpacity});

  @override
  Color? get disabledActiveTickMarkColor => ${color(TokenSlider.disabledActiveStopIndicatorContainerColor)};

  @override
  Color? get disabledInactiveTickMarkColor => ${color(TokenSlider.disabledInactiveStopIndicatorContainerColor)};

  @override
  Color? get thumbColor => ${color(TokenSlider.handleColor)};

  @override
  Color? get overlappingShapeStrokeColor => _colors.surface;

  @override
  Color? get disabledThumbColor => ${colorWithOpacity(TokenSlider.disabledHandleColor, TokenSlider.disabledHandleOpacity)};

  @override
  Color? get overlayColor => _colors.primary.withOpacity(0.12);

  @override
  TextStyle? get valueIndicatorTextStyle => ${textStyle(TokenTypescale.labelLarge, 'Theme.of(context).textTheme')}!.copyWith(
    color: ${color(TokenSlider.valueIndicatorLabelLabelTextColor)},
  );

  @override
  Color? get valueIndicatorColor => ${color(TokenSlider.valueIndicatorContainerColor)};

  @override
  RangeSliderTrackShape? get rangeTrackShape => const GappedRangeSliderTrackShape();

  @override
  RangeSliderTickMarkShape? get rangeTickMarkShape => const RoundRangeSliderTickMarkShape(tickMarkRadius: ${TokenSlider.stopIndicatorSize} / 2);

  @override
  RangeSliderThumbShape? get rangeThumbShape => const HandleRangeSliderThumbShape();

  @override
  SliderComponentShape? get overlayShape => const RoundSliderOverlayShape();

  @override
  RangeSliderValueIndicatorShape? get rangeValueIndicatorShape => const RoundedRectRangeSliderValueIndicatorShape();

  @override
  ShowValueIndicator? get showValueIndicator => ShowValueIndicator.onlyForDiscrete;

  @override
  double? get minThumbSeparation => 0;

  @override
  WidgetStateProperty<Size?>? get thumbSize {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return const Size(${TokenSlider.disabledHandleWidth}, ${TokenSlider.handleHeight});
      }
      if (states.contains(WidgetState.hovered)) {
        return const Size(${TokenSlider.hoverHandleWidth}, ${TokenSlider.handleHeight});
      }
      if (states.contains(WidgetState.focused)) {
        return const Size(${TokenSlider.focusHandleWidth}, ${TokenSlider.handleHeight});
      }
      if (states.contains(WidgetState.pressed)) {
        return const Size(${TokenSlider.pressedHandleWidth}, ${TokenSlider.handleHeight});
      }
      return const Size(${TokenSlider.handleWidth}, ${TokenSlider.handleHeight});
    });
  }

  @override
  double? get trackGap => ${TokenSlider.activeHandlePadding};
}
''';
}
