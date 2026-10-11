// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../data/slider.dart';
import 'template.dart';

class SliderTemplateM3 extends TokenTemplateM3 {
  const SliderTemplateM3();

  @override
  String get name => 'Slider';

  @override
  String get parentFilePath => 'slider.dart';

  // TODO(Crdzbird): Using hard-coded values for the secondary active track
  // opacity, the overlay state layer opacities, and the value indicator text
  // style due to missing tokens.
  @override
  String generateContents(String className) =>
      '''
class $className extends SliderThemeData {
  $className(this.context)
    : super(trackHeight: ${number(TokenSlider.activeTrackHeight)});

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  Color? get activeTrackColor => ${color(TokenSlider.activeTrackColor)};

  @override
  Color? get inactiveTrackColor => ${color(TokenSlider.inactiveTrackColor)};

  @override
  Color? get secondaryActiveTrackColor => ${colorWithOpacity(TokenSlider.activeTrackColor, 0.54)};

  @override
  Color? get disabledActiveTrackColor => ${colorWithOpacity(TokenSlider.disabledActiveTrackColor, TokenSlider.disabledActiveTrackOpacity)};

  @override
  Color? get disabledInactiveTrackColor => ${colorWithOpacity(TokenSlider.disabledInactiveTrackColor, TokenSlider.disabledInactiveTrackOpacity)};

  @override
  Color? get disabledSecondaryActiveTrackColor => ${colorWithOpacity(TokenSlider.disabledActiveTrackColor, TokenSlider.disabledActiveTrackOpacity)};

  @override
  Color? get activeTickMarkColor => ${color(TokenSlider.activeStopIndicatorContainerColor)}.withOpacity(${number(TokenSlider.activeStopIndicatorContainerOpacity)});

  @override
  Color? get inactiveTickMarkColor => ${color(TokenSlider.inactiveStopIndicatorContainerColor)}.withOpacity(${number(TokenSlider.inactiveStopIndicatorContainerOpacity)});

  @override
  Color? get disabledActiveTickMarkColor => ${color(TokenSlider.disabledActiveStopIndicatorContainerColor)};

  @override
  Color? get disabledInactiveTickMarkColor => ${color(TokenSlider.disabledInactiveStopIndicatorContainerColor)};

  @override
  Color? get thumbColor => ${color(TokenSlider.handleColor)};

  @override
  Color? get disabledThumbColor => ${colorWithOpacity(TokenSlider.disabledHandleColor, TokenSlider.disabledHandleOpacity)};

  @override
  Color? get overlayColor => WidgetStateColor.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.dragged)) {
      return _colors.primary.withOpacity(0.1);
    }
    if (states.contains(WidgetState.hovered)) {
      return _colors.primary.withOpacity(0.08);
    }
    if (states.contains(WidgetState.focused)) {
      return _colors.primary.withOpacity(0.1);
    }

    return Colors.transparent;
  });

  @override
  TextStyle? get valueIndicatorTextStyle => Theme.of(context).textTheme.labelLarge!.copyWith(
    color: ${color(TokenSlider.valueIndicatorLabelLabelTextColor)},
  );

  @override
  Color? get valueIndicatorColor => ${color(TokenSlider.valueIndicatorContainerColor)};

  @override
  SliderComponentShape? get valueIndicatorShape => const RoundedRectSliderValueIndicatorShape();

  @override
  SliderComponentShape? get thumbShape => const HandleThumbShape();

  @override
  SliderTrackShape? get trackShape => const GappedSliderTrackShape();

  @override
  SliderComponentShape? get overlayShape => const RoundSliderOverlayShape();

  @override
  SliderTickMarkShape? get tickMarkShape => const RoundSliderTickMarkShape(tickMarkRadius: ${number(TokenSlider.stopIndicatorSize)} / 2);

  @override
  WidgetStateProperty<Size?>? get thumbSize {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return const Size(${number(TokenSlider.disabledHandleWidth)}, ${number(TokenSlider.handleHeight)});
      }
      if (states.contains(WidgetState.hovered)) {
        return const Size(${number(TokenSlider.hoverHandleWidth)}, ${number(TokenSlider.handleHeight)});
      }
      if (states.contains(WidgetState.focused)) {
        return const Size(${number(TokenSlider.focusHandleWidth)}, ${number(TokenSlider.handleHeight)});
      }
      if (states.contains(WidgetState.pressed)) {
        return const Size(${number(TokenSlider.pressedHandleWidth)}, ${number(TokenSlider.handleHeight)});
      }
      return const Size(${number(TokenSlider.handleWidth)}, ${number(TokenSlider.handleHeight)});
    });
  }

  @override
  double? get trackGap => ${number(TokenSlider.activeHandlePadding)};
}
''';
}
