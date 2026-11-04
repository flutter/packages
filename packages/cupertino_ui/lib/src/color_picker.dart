// Copyright 2026 M5Stack Technology CO LTD
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'button.dart';
import 'colors.dart';
import 'icons.dart';
import 'nav_bar.dart';
import 'page_scaffold.dart';
import 'sheet.dart';
import 'sliding_segmented_control.dart';
import 'theme.dart';

/// Shows an iOS-style sheet for selecting a color.
///
/// This function presents the color editor directly, similar to presenting a
/// `UIColorPickerViewController` in UIKit. To open the same editor from a color
/// button, use [CupertinoColorPicker].
///
/// The sheet starts with [initialColor] selected and can display controls for
/// changing opacity when [supportsOpacity] is true.
///
/// The following arguments are supported:
///
///  * [context] is the build context used to find the root [Navigator].
///  * [initialColor] is the color initially selected in the color editor.
///  * [supportsOpacity] determines whether opacity controls are displayed.
///    When false, the returned color is always fully opaque.
///  * [enableDrag] determines whether the sheet can be dismissed by dragging.
///  * [settings] are used to configure the route.
///  * [topGap] is the gap between the top of the screen and the sheet as a
///    ratio of the screen height. It must be between 0.0 and 0.9.
///  * [showDragHandle] determines whether a drag handle is displayed at the top
///    of the sheet.
///  * [hasPlatformViews] should be true when the sheet or the route underneath
///    it contains a platform view.
///
/// Returns a [Future] that resolves to the selected [Color] when the sheet is
/// closed with its Close button. If the sheet is dismissed by dragging, the
/// future resolves to null.
///
/// ```dart
/// final Color? color = await showCupertinoColorPicker(
///   context: context,
///   initialColor: _color,
/// );
/// if (color != null) {
///   setState(() {
///     _color = color;
///   });
/// }
/// ```
///
/// See also:
///
///  * [CupertinoColorPicker], which displays the color editor from a button.
///  * [showCupertinoSheet], which provides the underlying sheet presentation.
///  * [CupertinoColors], which defines the colors used by Cupertino widgets.
///
/// {@example /example/lib/color_picker/cupertino_color_picker.0.dart#body}
Future<Color?> showCupertinoColorPicker({
  required BuildContext context,
  required Color initialColor,
  bool supportsOpacity = true,
  bool enableDrag = true,
  RouteSettings? settings,
  double? topGap,
  bool showDragHandle = false,
  bool hasPlatformViews = false,
}) {
  return _showCupertinoColorPicker(
    context: context,
    initialColor: initialColor,
    supportsOpacity: supportsOpacity,
    enableDrag: enableDrag,
    settings: settings,
    topGap: topGap,
    showDragHandle: showDragHandle,
    hasPlatformViews: hasPlatformViews,
  );
}

Future<Color?> _showCupertinoColorPicker({
  required BuildContext context,
  required Color initialColor,
  required bool supportsOpacity,
  required bool enableDrag,
  required RouteSettings? settings,
  required double? topGap,
  required bool showDragHandle,
  required bool hasPlatformViews,
  ValueChanged<Color>? onChanged,
}) {
  final Color normalizedColor = supportsOpacity
      ? initialColor
      : initialColor.withValues(alpha: 1.0);

  return showCupertinoSheet<Color>(
    context: context,
    enableDrag: enableDrag,
    settings: settings,
    topGap: topGap,
    showDragHandle: showDragHandle,
    hasPlatformViews: hasPlatformViews,
    scrollableBuilder: (BuildContext context, ScrollController scrollController) {
      return _CupertinoColorPickerSheet(
        initialColor: normalizedColor,
        supportsOpacity: supportsOpacity,
        onChanged: onChanged ?? _ignoreColor,
        scrollController: scrollController,
      );
    },
  );
}

void _ignoreColor(Color color) {}

String _colorHex(Color color) {
  final int rgb = color.toARGB32() & 0x00FFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

/// A control that displays a color well and opens a color editor when tapped.
///
/// This is the button-based presentation mode, similar to SwiftUI's
/// `ColorPicker`. To present the color editor directly without a color button,
/// use [showCupertinoColorPicker].
///
/// The control displays an optional [label] next to a circular color well.
/// Tapping the color well presents a sheet with grid, spectrum, and slider
/// editing modes based on the iOS color picker.
///
/// The widget does not maintain the selected color. When the user selects a
/// color, the widget calls [onChanged] and the parent should rebuild the widget
/// with the new [color]. If [onChanged] is null, the control is disabled.
///
/// ```dart
/// CupertinoColorPicker(
///   color: _color,
///   onChanged: (Color color) {
///     setState(() {
///       _color = color;
///     });
///   },
///   label: const Text('Accent Color'),
/// )
/// ```
///
/// See also:
///
///  * [CupertinoButton], which provides the interaction behavior for the
///    control.
///  * [CupertinoColors], which defines the colors used by Cupertino widgets.
///
/// {@example /example/lib/color_picker/cupertino_color_picker.0.dart#body}
class CupertinoColorPicker extends StatelessWidget {
  /// Creates an iOS-style color picker.
  ///
  /// The [color] argument is required and determines the currently selected
  /// color. The [onChanged] argument is called when the user selects a new
  /// color. Pass null to display the control as disabled.
  ///
  /// The [supportsOpacity] argument defaults to true. When false, the color
  /// editor does not expose opacity controls and [onChanged] always reports an
  /// opaque color.
  ///
  /// The [label] argument is optional. If supplied, it is displayed to the
  /// leading side of the color well.
  const CupertinoColorPicker({
    super.key,
    required this.color,
    required this.onChanged,
    this.supportsOpacity = true,
    this.label,
    this.onPickerDismissed,
  });

  /// The currently selected color.
  ///
  /// The picker does not modify this value directly. Instead, it passes the
  /// newly selected color to [onChanged], and the parent is responsible for
  /// rebuilding the widget with the updated value.
  final Color color;

  /// Called when the user selects a new color.
  ///
  /// The picker passes the new color to the callback but does not maintain
  /// state until the parent widget rebuilds the picker with a new [color].
  ///
  /// If null, the color picker is disabled.
  final ValueChanged<Color>? onChanged;

  /// Whether the color editor exposes an opacity control.
  ///
  /// When false, the editor hides its opacity controls and all colors reported
  /// through [onChanged] are fully opaque.
  final bool supportsOpacity;

  /// A widget displayed to the leading side of the color well.
  ///
  /// If null, only the color well is displayed.
  final Widget? label;

  /// Called after the color editor sheet has been dismissed.
  ///
  /// This can be used to commit a color once editing is complete rather than
  /// on every value reported by a continuous control such as a slider.
  final VoidCallback? onPickerDismissed;

  bool get _isEnabled => onChanged != null;

  Color get _normalizedColor => supportsOpacity ? color : color.withValues(alpha: 1.0);

  Future<void> _showColorPicker(BuildContext context) async {
    final ValueChanged<Color>? onChanged = this.onChanged;
    if (onChanged == null) {
      return;
    }

    await _showCupertinoColorPicker(
      context: context,
      initialColor: _normalizedColor,
      supportsOpacity: supportsOpacity,
      enableDrag: true,
      settings: null,
      topGap: null,
      showDragHandle: false,
      hasPlatformViews: false,
      onChanged: (Color value) {
        onChanged(supportsOpacity ? value : value.withValues(alpha: 1.0));
      },
    );

    if (context.mounted) {
      onPickerDismissed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color currentColor = _normalizedColor;
    final Widget colorWell = _ColorWell(
      color: currentColor,
      enabled: _isEnabled,
      semanticsLabel: _CupertinoColorPickerStrings.defaults.colorWell,
    );
    final Widget? label = this.label;

    final Widget child;
    if (label == null) {
      child = Center(child: colorWell);
    } else {
      final TextStyle labelStyle = CupertinoTheme.of(context).textTheme.textStyle
          .copyWith(color: CupertinoColors.label.resolveFrom(context), fontSize: 17);
      child = ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          children: <Widget>[
            Expanded(
              child: DefaultTextStyle(style: labelStyle, child: label),
            ),
            const SizedBox(width: 12),
            colorWell,
          ],
        ),
      );
    }

    return MergeSemantics(
      child: CupertinoButton(
        key: const ValueKey<String>('cupertino-color-picker-trigger'),
        padding: EdgeInsets.zero,
        minimumSize: const Size(44, 44),
        pressedOpacity: 0.55,
        onPressed: _isEnabled ? () => _showColorPicker(context) : null,
        child: child,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('color', color));
    properties.add(
      FlagProperty(
        'supportsOpacity',
        value: supportsOpacity,
        ifTrue: 'opacity enabled',
        ifFalse: 'opacity disabled',
      ),
    );
    properties.add(DiagnosticsProperty<Widget>('label', label));
    properties.add(
      ObjectFlagProperty<ValueChanged<Color>>('onChanged', onChanged, ifNull: 'disabled'),
    );
    properties.add(
      ObjectFlagProperty<VoidCallback>(
        'onPickerDismissed',
        onPickerDismissed,
        ifNull: 'not provided',
      ),
    );
  }
}

class _CupertinoColorPickerSheet extends StatefulWidget {
  const _CupertinoColorPickerSheet({
    required this.initialColor,
    required this.supportsOpacity,
    required this.onChanged,
    required this.scrollController,
  });

  final Color initialColor;
  final bool supportsOpacity;
  final ValueChanged<Color> onChanged;
  final ScrollController scrollController;

  @override
  State<_CupertinoColorPickerSheet> createState() => _CupertinoColorPickerSheetState();
}

enum _ColorPickerMode { grid, spectrum, sliders }

enum _ColorSliderMode { rgb, hsb }

class _CupertinoColorPickerSheetState extends State<_CupertinoColorPickerSheet> {
  late HSVColor _hsb;
  late double _alpha;
  _ColorPickerMode _mode = _ColorPickerMode.grid;
  _ColorSliderMode _sliderMode = _ColorSliderMode.rgb;

  static const List<Color> _initialRecentColors = <Color>[
    Color(0xFF000000),
    Color(0xFF007AFF),
    Color(0xFF34C759),
    Color(0xFFFFCC00),
    Color(0xFFFF3B30),
  ];

  late final List<Color> _recentColors = List<Color>.of(_initialRecentColors);

  @override
  void initState() {
    super.initState();
    _hsb = HSVColor.fromColor(widget.initialColor);
    _alpha = widget.supportsOpacity ? widget.initialColor.a : 1.0;
  }

  Color get _color => _hsb.withAlpha(_alpha).toColor();

  void _emitColor(Color color, {bool preserveHue = false}) {
    final double alpha = widget.supportsOpacity ? color.a : 1.0;
    final ui.Color next = color.withValues(alpha: alpha);
    final nextHsb = HSVColor.fromColor(next);
    setState(() {
      _hsb = preserveHue
          ? _hsb
          : HSVColor.fromAHSV(1.0, nextHsb.hue, nextHsb.saturation, nextHsb.value);
      _alpha = alpha;
    });
    widget.onChanged(next);
  }

  void _setHsb({double? hue, double? saturation, double? value, double? alpha}) {
    final double nextHue = (hue ?? _hsb.hue) % 360.0;
    final double nextSaturation = (saturation ?? _hsb.saturation).clamp(0.0, 1.0);
    final double nextValue = (value ?? _hsb.value).clamp(0.0, 1.0);
    final double nextAlpha = widget.supportsOpacity ? (alpha ?? _alpha).clamp(0.0, 1.0) : 1.0;
    final ui.Color next = HSVColor.fromAHSV(
      nextAlpha,
      nextHue,
      nextSaturation,
      nextValue,
    ).toColor();
    setState(() {
      _hsb = HSVColor.fromAHSV(1.0, nextHue, nextSaturation, nextValue);
      _alpha = nextAlpha;
    });
    widget.onChanged(next);
  }

  void _setRgb({double? red, double? green, double? blue, double? alpha}) {
    final ui.Color current = _color;
    final next = Color.fromARGB(
      ((alpha ?? (widget.supportsOpacity ? _alpha : 1.0)) * 255).round().clamp(0, 255),
      ((red ?? current.r) * 255).round().clamp(0, 255),
      ((green ?? current.g) * 255).round().clamp(0, 255),
      ((blue ?? current.b) * 255).round().clamp(0, 255),
    );
    _emitColor(next);
  }

  void _swapColor(Color color) {
    _emitColor(color.withValues(alpha: widget.supportsOpacity ? _alpha : 1.0));
  }

  void _addRecentColor() {
    setState(() {
      _recentColors.removeWhere((color) => color.toARGB32() == _color.toARGB32());
      _recentColors.insert(0, _color);
      if (_recentColors.length > 5) {
        _recentColors.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const _CupertinoColorPickerStrings strings = _CupertinoColorPickerStrings.defaults;
    final CupertinoThemeData theme = CupertinoTheme.of(context);
    final CupertinoDynamicColor background = CupertinoColors.systemGroupedBackground.resolveFrom(
      context,
    );

    return CupertinoPageScaffold(
      backgroundColor: background,
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        automaticallyImplyMiddle: false,
        border: null,
        backgroundColor: background,
        padding: const .only(start: 8, end: 8),
        leading: Semantics(
          button: true,
          label: strings.spectrum,
          child: CupertinoButton(
            sizeStyle: .medium,
            onPressed: () => setState(() => _mode = _ColorPickerMode.spectrum),
            child: Icon(CupertinoIcons.eyedropper, size: 24, color: theme.primaryColor),
          ),
        ),
        middle: Text(
          strings.colors,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        trailing: Semantics(
          button: true,
          label: strings.close,
          child: CupertinoButton(
            sizeStyle: .medium,
            onPressed: () {
              Navigator.of(context).pop<Color>(_color);
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.xmark,
                size: 17,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
            ),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: SizedBox(
                height: 32,
                child: CupertinoSlidingSegmentedControl<_ColorPickerMode>(
                  groupValue: _mode,
                  backgroundColor: CupertinoColors.tertiarySystemFill.resolveFrom(context),
                  thumbColor: CupertinoColors.systemBackground.resolveFrom(context),
                  onValueChanged: (value) {
                    if (value != null) {
                      setState(() => _mode = value);
                    }
                  },
                  children: <_ColorPickerMode, Widget>{
                    _ColorPickerMode.grid: _SegmentLabel(
                      text: strings.grid,
                      selected: _mode == _ColorPickerMode.grid,
                    ),
                    _ColorPickerMode.spectrum: _SegmentLabel(
                      text: strings.spectrum,
                      selected: _mode == _ColorPickerMode.spectrum,
                    ),
                    _ColorPickerMode.sliders: _SegmentLabel(
                      text: strings.sliders,
                      selected: _mode == _ColorPickerMode.sliders,
                    ),
                  },
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: widget.scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: switch (_mode) {
                        _ColorPickerMode.grid => _ColorGrid(
                          key: const ValueKey<String>('grid-tab'),
                          color: _color,
                          alpha: _alpha,
                          supportsOpacity: widget.supportsOpacity,
                          strings: strings,
                          recentColors: _recentColors,
                          onChanged: _swapColor,
                          onAlphaChanged: (value) => _setHsb(alpha: value),
                          onAddRecent: _addRecentColor,
                        ),
                        _ColorPickerMode.spectrum => _ColorSpectrum(
                          key: const ValueKey<String>('spectrum-tab'),
                          color: _color,
                          hue: _hsb.hue,
                          saturation: _hsb.saturation,
                          value: _hsb.value,
                          alpha: _alpha,
                          supportsOpacity: widget.supportsOpacity,
                          strings: strings,
                          onChanged: ({
                            required double hue,
                            required double saturation,
                            required double value,
                          }) => _setHsb(hue: hue, saturation: saturation, value: value),
                          onAlphaChanged: (value) => _setHsb(alpha: value),
                        ),
                        _ColorPickerMode.sliders => _ColorSliders(
                          key: const ValueKey<String>('sliders-tab'),
                          color: _color,
                          hue: _hsb.hue,
                          saturation: _hsb.saturation,
                          value: _hsb.value,
                          alpha: _alpha,
                          supportsOpacity: widget.supportsOpacity,
                          sliderMode: _sliderMode,
                          strings: strings,
                          onSliderModeChanged: (mode) => setState(() => _sliderMode = mode),
                          onRgbChanged: _setRgb,
                          onHsbChanged: _setHsb,
                          onAlphaChanged: (value) => _setHsb(alpha: value),
                        ),
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorGrid extends StatelessWidget {
  const _ColorGrid({
    super.key,
    required this.color,
    required this.alpha,
    required this.supportsOpacity,
    required this.strings,
    required this.recentColors,
    required this.onChanged,
    required this.onAlphaChanged,
    required this.onAddRecent,
  });

  final Color color;
  final double alpha;
  final bool supportsOpacity;
  final _CupertinoColorPickerStrings strings;
  final List<Color> recentColors;
  final ValueChanged<Color> onChanged;
  final ValueChanged<double> onAlphaChanged;
  final VoidCallback onAddRecent;

  // Sampled from the iOS 18 color grid on an iPhone XR. Keeping the exact
  // palette gives the Flutter picker the same visual rhythm as the system UI.
  static const List<List<Color>> _colors = <List<Color>>[
    <Color>[
      Color(0xFFFFFFFF),
      Color(0xFFEBEBEB),
      Color(0xFFD6D6D6),
      Color(0xFFC2C2C2),
      Color(0xFFADADAD),
      Color(0xFF999999),
      Color(0xFF858585),
      Color(0xFF707070),
      Color(0xFF5C5C5C),
      Color(0xFF474747),
      Color(0xFF333333),
      Color(0xFF000000),
    ],
    <Color>[
      Color(0xFF133648),
      Color(0xFF081C53),
      Color(0xFF0F0538),
      Color(0xFF29083A),
      Color(0xFF360B1A),
      Color(0xFF541107),
      Color(0xFF532008),
      Color(0xFF53340D),
      Color(0xFF523E0F),
      Color(0xFF65611A),
      Color(0xFF505517),
      Color(0xFF2B3D16),
    ],
    <Color>[
      Color(0xFF2E6C8B),
      Color(0xFF1841A3),
      Color(0xFF280B72),
      Color(0xFF591D77),
      Color(0xFF6F223D),
      Color(0xFFA62C17),
      Color(0xFFA0451A),
      Color(0xFFA06B23),
      Color(0xFF9F7D27),
      Color(0xFFC2BC3C),
      Color(0xFF9DA436),
      Color(0xFF587933),
    ],
    <Color>[
      Color(0xFF3D8AB0),
      Color(0xFF2254CE),
      Color(0xFF331B8E),
      Color(0xFF702898),
      Color(0xFF8C2E4F),
      Color(0xFFD03A1F),
      Color(0xFFCA5A24),
      Color(0xFFC8862E),
      Color(0xFFC99F35),
      Color(0xFFF3EC4E),
      Color(0xFFC5D047),
      Color(0xFF729B44),
    ],
    <Color>[
      Color(0xFF479ED3),
      Color(0xFF285FF5),
      Color(0xFF4724AB),
      Color(0xFF8C32B5),
      Color(0xFFAA395D),
      Color(0xFFEB512E),
      Color(0xFFED732E),
      Color(0xFFF3AE3D),
      Color(0xFFF4C944),
      Color(0xFFFDFB66),
      Color(0xFFDCEB5C),
      Color(0xFF85B952),
    ],
    <Color>[
      Color(0xFF59C4F7),
      Color(0xFF4F85F6),
      Color(0xFF5832E2),
      Color(0xFFAF42EB),
      Color(0xFFD44A7A),
      Color(0xFFED6C58),
      Color(0xFFEF8C56),
      Color(0xFFF3B757),
      Color(0xFFF6CD5A),
      Color(0xFFFEF780),
      Color(0xFFE6EF7A),
      Color(0xFFA3D16E),
    ],
    <Color>[
      Color(0xFFA5E1FA),
      Color(0xFFADC5FA),
      Color(0xFFAB8DF7),
      Color(0xFFD695F8),
      Color(0xFFE8A7BF),
      Color(0xFFF4B8B1),
      Color(0xFFF6C7AF),
      Color(0xFFF9DAAE),
      Color(0xFFFAE5AF),
      Color(0xFFFEFBC0),
      Color(0xFFF3F7BE),
      Color(0xFFD2E7BA),
    ],
    <Color>[
      Color(0xFFD2EFFD),
      Color(0xFFD6E1FC),
      Color(0xFFD6C9FA),
      Color(0xFFE9CBFB),
      Color(0xFFF3D4DF),
      Color(0xFFF9DCD9),
      Color(0xFFFAE3D8),
      Color(0xFFFCEDD7),
      Color(0xFFFDF2D8),
      Color(0xFFFEFCE0),
      Color(0xFFF7FADE),
      Color(0xFFE2EDD6),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final int selectedRgb = color.toARGB32() & 0x00FFFFFF;
    final ui.Color placeholder = color.withValues(alpha: alpha);
    final CupertinoDynamicColor borderColor = CupertinoColors.systemBackground.resolveFrom(context);
    final CupertinoDynamicColor labelColor = CupertinoColors.secondaryLabel.resolveFrom(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 1.228,
            child: Column(
              children: <Widget>[
                for (final row in _colors)
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        for (final swatch in row)
                          Expanded(
                            child: Semantics(
                              button: true,
                              selected: (swatch.toARGB32() & 0x00FFFFFF) == selectedRgb,
                              label: '${strings.colorWell} ${_colorHex(swatch)}',
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => onChanged(swatch),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: <Widget>[
                                    ColoredBox(color: swatch),
                                    if ((swatch.toARGB32() & 0x00FFFFFF) == selectedRgb)
                                      Center(
                                        child: Container(
                                          width: 17,
                                          height: 17,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: borderColor, width: 2),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (supportsOpacity) ...<Widget>[
          const SizedBox(height: 14),
          _OpacitySlider(
            label: strings.opacity,
            color: placeholder,
            value: alpha,
            onChanged: onAlphaChanged,
          ),
        ],
        const SizedBox(height: 16),
        Container(
          height: 1 / MediaQuery.devicePixelRatioOf(context),
          color: CupertinoColors.separator.resolveFrom(context),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: <Widget>[
              _LargeColorPreview(color: placeholder),
              const SizedBox(width: 16),
              for (final swatch in recentColors.take(5)) ...<Widget>[
                _RecentColorButton(
                  color: swatch,
                  selected: (swatch.toARGB32() & 0x00FFFFFF) == selectedRgb,
                  semanticsLabel: '${strings.colorWell} ${_colorHex(swatch)}',
                  onPressed: () => onChanged(swatch),
                ),
              ],
              Semantics(
                button: true,
                label: strings.addColor,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(44, 44),
                  onPressed: onAddRecent,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(CupertinoIcons.plus, size: 18, color: labelColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ColorSpectrum extends StatelessWidget {
  const _ColorSpectrum({
    super.key,
    required this.color,
    required this.hue,
    required this.saturation,
    required this.value,
    required this.alpha,
    required this.supportsOpacity,
    required this.strings,
    required this.onChanged,
    required this.onAlphaChanged,
  });

  final Color color;
  final double hue;
  final double saturation;
  final double value;
  final double alpha;
  final bool supportsOpacity;
  final _CupertinoColorPickerStrings strings;
  final void Function({required double hue, required double saturation, required double value})
  onChanged;
  final ValueChanged<double> onAlphaChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.08,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _SpectrumField(
              hue: hue,
              saturation: saturation,
              value: value,
              color: color,
              semanticsLabel: strings.spectrum,
              semanticsValue:
                  '${strings.saturation}: ${(saturation * 100).round()}%, '
                  '${strings.brightness}: ${(value * 100).round()}%',
              onChanged: (saturation, value) =>
                  onChanged(hue: hue, saturation: saturation, value: value),
            ),
          ),
        ),
        const SizedBox(height: 18),
        _LabeledColorSlider(
          label: strings.hue,
          valueLabel: '${hue.round()}°',
          value: hue / 360.0,
          colors: const <Color>[
            Color(0xFFFF0000),
            Color(0xFFFFFF00),
            Color(0xFF00FF00),
            Color(0xFF00FFFF),
            Color(0xFF0000FF),
            Color(0xFFFF00FF),
            Color(0xFFFF0000),
          ],
          semanticsValueFormatter: (value) => '${(value * 360).round()}°',
          onChanged: (position) =>
              onChanged(hue: position * 360.0, saturation: saturation, value: value),
        ),
        if (supportsOpacity) ...<Widget>[
          const SizedBox(height: 16),
          _OpacitySlider(
            label: strings.opacity,
            color: color.withValues(alpha: alpha),
            value: alpha,
            onChanged: onAlphaChanged,
          ),
        ],
        const SizedBox(height: 18),
        _ColorValueSummary(color: color, strings: strings),
      ],
    );
  }
}

class _ColorSliders extends StatelessWidget {
  const _ColorSliders({
    super.key,
    required this.color,
    required this.hue,
    required this.saturation,
    required this.value,
    required this.alpha,
    required this.supportsOpacity,
    required this.sliderMode,
    required this.strings,
    required this.onSliderModeChanged,
    required this.onRgbChanged,
    required this.onHsbChanged,
    required this.onAlphaChanged,
  });

  final Color color;
  final double hue;
  final double saturation;
  final double value;
  final double alpha;
  final bool supportsOpacity;
  final _ColorSliderMode sliderMode;
  final _CupertinoColorPickerStrings strings;
  final ValueChanged<_ColorSliderMode> onSliderModeChanged;
  final void Function({double? red, double? green, double? blue, double? alpha}) onRgbChanged;
  final void Function({double? hue, double? saturation, double? value, double? alpha}) onHsbChanged;
  final ValueChanged<double> onAlphaChanged;

  @override
  Widget build(BuildContext context) {
    final double opacity = supportsOpacity ? alpha : 1.0;
    final base = Color.fromARGB(
      255,
      (color.r * 255).round(),
      (color.g * 255).round(),
      (color.b * 255).round(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: 32,
          child: CupertinoSlidingSegmentedControl<_ColorSliderMode>(
            groupValue: sliderMode,
            backgroundColor: CupertinoColors.tertiarySystemFill.resolveFrom(context),
            thumbColor: CupertinoColors.systemBackground.resolveFrom(context),
            onValueChanged: (mode) {
              if (mode != null) {
                onSliderModeChanged(mode);
              }
            },
            children: <_ColorSliderMode, Widget>{
              _ColorSliderMode.rgb: _SegmentLabel(
                text: 'RGB',
                selected: sliderMode == _ColorSliderMode.rgb,
              ),
              _ColorSliderMode.hsb: _SegmentLabel(
                text: 'HSB',
                selected: sliderMode == _ColorSliderMode.hsb,
              ),
            },
          ),
        ),
        const SizedBox(height: 18),
        _ColorValueSummary(color: color, strings: strings),
        const SizedBox(height: 22),
        if (sliderMode == _ColorSliderMode.rgb) ...<Widget>[
          _LabeledColorSlider(
            label: strings.red,
            valueLabel: '${(color.r * 255).round()}',
            value: color.r.clamp(0.0, 1.0),
            colors: <Color>[
              Color.fromARGB(255, 0, (color.g * 255).round(), (color.b * 255).round()),
              Color.fromARGB(255, 255, (color.g * 255).round(), (color.b * 255).round()),
            ],
            semanticsValueFormatter: (value) => '${(value * 255).round()}',
            onChanged: (position) => onRgbChanged(red: position),
          ),
          const SizedBox(height: 14),
          _LabeledColorSlider(
            label: strings.green,
            valueLabel: '${(color.g * 255).round()}',
            value: color.g.clamp(0.0, 1.0),
            colors: <Color>[
              Color.fromARGB(255, (color.r * 255).round(), 0, (color.b * 255).round()),
              Color.fromARGB(255, (color.r * 255).round(), 255, (color.b * 255).round()),
            ],
            semanticsValueFormatter: (value) => '${(value * 255).round()}',
            onChanged: (position) => onRgbChanged(green: position),
          ),
          const SizedBox(height: 14),
          _LabeledColorSlider(
            label: strings.blue,
            valueLabel: '${(color.b * 255).round()}',
            value: color.b.clamp(0.0, 1.0),
            colors: <Color>[
              Color.fromARGB(255, (color.r * 255).round(), (color.g * 255).round(), 0),
              Color.fromARGB(255, (color.r * 255).round(), (color.g * 255).round(), 255),
            ],
            semanticsValueFormatter: (value) => '${(value * 255).round()}',
            onChanged: (position) => onRgbChanged(blue: position),
          ),
        ] else ...<Widget>[
          _LabeledColorSlider(
            label: strings.hue,
            valueLabel: '${hue.round()}°',
            value: hue / 360.0,
            colors: const <Color>[
              Color(0xFFFF0000),
              Color(0xFFFFFF00),
              Color(0xFF00FF00),
              Color(0xFF00FFFF),
              Color(0xFF0000FF),
              Color(0xFFFF00FF),
              Color(0xFFFF0000),
            ],
            semanticsValueFormatter: (value) => '${(value * 360).round()}°',
            onChanged: (position) => onHsbChanged(hue: position * 360.0),
          ),
          const SizedBox(height: 14),
          _LabeledColorSlider(
            label: strings.saturation,
            valueLabel: '${(saturation * 100).round()}%',
            value: saturation,
            colors: <Color>[CupertinoColors.white, HSVColor.fromAHSV(1, hue, 1, value).toColor()],
            onChanged: (position) => onHsbChanged(saturation: position),
          ),
          const SizedBox(height: 14),
          _LabeledColorSlider(
            label: strings.brightness,
            valueLabel: '${(value * 100).round()}%',
            value: value,
            colors: <Color>[
              CupertinoColors.black,
              HSVColor.fromAHSV(1, hue, saturation, 1).toColor(),
            ],
            onChanged: (position) => onHsbChanged(value: position),
          ),
        ],
        if (supportsOpacity) ...<Widget>[
          const SizedBox(height: 16),
          _OpacitySlider(
            label: strings.opacity,
            color: base.withValues(alpha: opacity),
            value: opacity,
            onChanged: onAlphaChanged,
          ),
        ],
      ],
    );
  }
}

class _OpacitySlider extends StatelessWidget {
  const _OpacitySlider({
    required this.label,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final Color color;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final ui.Color opaque = color.withValues(alpha: 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: <Widget>[
            Expanded(
              child: _ColorGradientSlider(
                value: value,
                colors: <Color>[opaque.withValues(alpha: 0.0), opaque],
                showCheckerboard: true,
                trackHeight: 31,
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 16),
            _ValueField(text: '${(value * 100).round()}%'),
          ],
        ),
      ],
    );
  }
}

class _LabeledColorSlider extends StatelessWidget {
  const _LabeledColorSlider({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.colors,
    required this.onChanged,
    this.semanticsValueFormatter,
  });

  final String label;
  final String valueLabel;
  final double value;
  final List<Color> colors;
  final ValueChanged<double> onChanged;
  final String Function(double value)? semanticsValueFormatter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 64,
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, color: CupertinoColors.label.resolveFrom(context)),
          ),
        ),
        Expanded(
          child: _ColorGradientSlider(
            value: value,
            colors: colors,
            semanticsLabel: label,
            semanticsValueFormatter: semanticsValueFormatter,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 10),
        _ValueField(text: valueLabel),
      ],
    );
  }
}

class _ColorGradientSlider extends StatefulWidget {
  const _ColorGradientSlider({
    required this.value,
    required this.colors,
    required this.onChanged,
    this.trackHeight = 20,
    this.showCheckerboard = false,
    this.semanticsLabel,
    this.semanticsValueFormatter,
  });

  final double value;
  final List<Color> colors;
  final ValueChanged<double> onChanged;
  final double trackHeight;
  final bool showCheckerboard;
  final String? semanticsLabel;
  final String Function(double value)? semanticsValueFormatter;

  @override
  State<_ColorGradientSlider> createState() => _ColorGradientSliderState();
}

class _ColorGradientSliderState extends State<_ColorGradientSlider> {
  void _updateFromPosition(double dx, double width) {
    if (width <= 0) {
      return;
    }
    final metrics = _ColorGradientSliderMetrics.fromWidth(width, widget.trackHeight);
    final double next = metrics.valueAt(dx);
    if (next != widget.value) {
      widget.onChanged(next);
    }
  }

  String _semanticsValue(double value) {
    return widget.semanticsValueFormatter?.call(value) ?? '${(value * 100).round()}%';
  }

  @override
  Widget build(BuildContext context) {
    final double value = widget.value.clamp(0.0, 1.0);
    final double increased = (value + 0.01).clamp(0.0, 1.0);
    final double decreased = (value - 0.01).clamp(0.0, 1.0);
    return Semantics(
      slider: true,
      label: widget.semanticsLabel,
      value: _semanticsValue(value),
      increasedValue: _semanticsValue(increased),
      decreasedValue: _semanticsValue(decreased),
      onIncrease: () => widget.onChanged(increased),
      onDecrease: () => widget.onChanged(decreased),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) =>
                _updateFromPosition(details.localPosition.dx, constraints.maxWidth),
            onHorizontalDragStart: (details) =>
                _updateFromPosition(details.localPosition.dx, constraints.maxWidth),
            onHorizontalDragUpdate: (details) =>
                _updateFromPosition(details.localPosition.dx, constraints.maxWidth),
            child: SizedBox(
              height: _ColorGradientSliderMetrics.surfaceHeight,
              child: CustomPaint(
                painter: _ColorGradientSliderPainter(
                  value: value,
                  colors: widget.colors,
                  trackHeight: widget.trackHeight,
                  showCheckerboard: widget.showCheckerboard,
                  secondaryLabel: CupertinoColors.secondaryLabel.resolveFrom(context),
                  background: CupertinoColors.systemBackground.resolveFrom(context),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SpectrumField extends StatelessWidget {
  const _SpectrumField({
    required this.hue,
    required this.saturation,
    required this.value,
    required this.color,
    required this.semanticsLabel,
    required this.semanticsValue,
    required this.onChanged,
  });

  final double hue;
  final double saturation;
  final double value;
  final Color color;
  final String semanticsLabel;
  final String semanticsValue;
  final void Function(double saturation, double value) onChanged;

  void _update(Offset position, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }
    onChanged(
      (position.dx / size.width).clamp(0.0, 1.0),
      (1.0 - position.dy / size.height).clamp(0.0, 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Semantics(
          label: semanticsLabel,
          value: semanticsValue,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => _update(details.localPosition, size),
            onPanStart: (details) => _update(details.localPosition, size),
            onPanUpdate: (details) => _update(details.localPosition, size),
            child: CustomPaint(
              painter: _SpectrumPainter(
                hue: hue,
                saturation: saturation,
                value: value,
                color: color,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ColorValueSummary extends StatelessWidget {
  const _ColorValueSummary({required this.color, required this.strings});

  final Color color;
  final _CupertinoColorPickerStrings strings;

  @override
  Widget build(BuildContext context) {
    final String hex = _colorHex(color);
    return Row(
      children: <Widget>[
        _LargeColorPreview(color: color, size: 52),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                strings.hex,
                style: TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                hex,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                  color: CupertinoColors.label.resolveFrom(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LargeColorPreview extends StatelessWidget {
  const _LargeColorPreview({required this.color, this.size = 76});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CustomPaint(
              painter: _CheckerboardBackgroundPainter(
                light: CupertinoColors.systemBackground.resolveFrom(context),
                dark: CupertinoColors.systemFill.resolveFrom(context),
                cellSize: 7,
              ),
            ),
            ColoredBox(color: color),
          ],
        ),
      ),
    );
  }
}

class _RecentColorButton extends StatelessWidget {
  const _RecentColorButton({
    required this.color,
    required this.selected,
    required this.semanticsLabel,
    required this.onPressed,
  });

  final Color color;
  final bool selected;
  final String semanticsLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticsLabel,
      child: GestureDetector(
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Container(
              width: 30,
              height: 30,
              padding: EdgeInsets.all(selected ? 2 : 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: selected
                    ? Border.all(
                        color: CupertinoColors.secondaryLabel.resolveFrom(context),
                        width: 2,
                      )
                    : null,
              ),
              child: ClipOval(
                child: CustomPaint(painter: _CheckerboardColorPainter(color: color)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ValueField extends StatelessWidget {
  const _ValueField({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        maxLines: 1,
        style: TextStyle(
          fontSize: 14,
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          color: CupertinoColors.label.resolveFrom(context),
        ),
      ),
    );
  }
}

class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel({required this.text, required this.selected});

  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: .infinity,
      child: Align(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: CupertinoColors.label.resolveFrom(context),
          ),
        ),
      ),
    );
  }
}

class _ColorWell extends StatelessWidget {
  const _ColorWell({required this.color, required this.enabled, required this.semanticsLabel});

  final Color color;
  final bool enabled;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final CupertinoDynamicColor background = CupertinoColors.systemBackground.resolveFrom(context);
    final String hex = _colorHex(color);

    return Semantics(
      label: semanticsLabel,
      value: hex,
      enabled: enabled,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.45,
        child: SizedBox(
          width: 32,
          height: 32,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                startAngle: -math.pi / 2,
                endAngle: math.pi * 1.5,
                colors: <Color>[
                  Color(0xFFFFD60A),
                  Color(0xFF34C759),
                  Color(0xFF32ADE6),
                  Color(0xFF007AFF),
                  Color(0xFFAF52DE),
                  Color(0xFFFF2D55),
                  Color(0xFFFF9500),
                  Color(0xFFFFD60A),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: background.withValues(alpha: 0.88)),
                ),
                child: ClipOval(
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      CustomPaint(
                        painter: _CheckerboardBackgroundPainter(
                          light: background,
                          dark: CupertinoColors.systemFill.resolveFrom(context),
                          cellSize: 5,
                        ),
                      ),
                      ColoredBox(color: color),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorGradientSliderMetrics {
  const _ColorGradientSliderMetrics({
    required this.width,
    required this.thumbRadius,
    required this.trackPadding,
  });

  factory _ColorGradientSliderMetrics.fromWidth(double width, double trackHeight) {
    // A full-height thumb has no vertical gap to the track; in that case the
    // same formula also produces zero extra horizontal padding.
    final double thumbRadius = math.min(trackHeight / 2, 13.0);
    final double trackPadding = math.max(0.0, (trackHeight - thumbRadius * 2) / 2);
    return _ColorGradientSliderMetrics(
      width: width,
      thumbRadius: thumbRadius,
      trackPadding: trackPadding,
    );
  }

  static const double surfaceHeight = 32.0;

  final double width;
  final double thumbRadius;

  /// Extra space between the thumb and the track on every side.
  final double trackPadding;

  double get _travelStart => thumbRadius + trackPadding;

  double get _travelEnd => width - thumbRadius - trackPadding;

  Rect trackRect(double height, double trackHeight) {
    return Rect.fromLTWH(0, (height - trackHeight) / 2, width, trackHeight);
  }

  double thumbX(double value) {
    return _travelStart + (_travelEnd - _travelStart) * value;
  }

  double valueAt(double dx) {
    final double travelWidth = _travelEnd - _travelStart;
    if (travelWidth <= 0) {
      return 0;
    }
    return ((dx - _travelStart) / travelWidth).clamp(0.0, 1.0);
  }
}

class _ColorGradientSliderPainter extends CustomPainter {
  const _ColorGradientSliderPainter({
    required this.value,
    required this.colors,
    required this.trackHeight,
    required this.showCheckerboard,
    required this.secondaryLabel,
    required this.background,
  });

  final double value;
  final List<Color> colors;
  final double trackHeight;
  final bool showCheckerboard;
  final Color secondaryLabel;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = _ColorGradientSliderMetrics.fromWidth(size.width, trackHeight);
    final ui.Rect trackRect = metrics.trackRect(size.height, trackHeight);

    final radius = Radius.circular(trackHeight / 2);
    final rrect = RRect.fromRectAndRadius(trackRect, radius);

    canvas.save();
    canvas.clipRRect(rrect);
    if (showCheckerboard) {
      _paintCheckerboard(
        canvas,
        trackRect,
        cellSize: trackHeight / 2,
        light: background,
        dark: const Color(0xFFD1D1D6),
      );
    }
    final List<double>? colorStops = colors.length == 2
        ? null
        : List<double>.generate(colors.length, (index) => index / (colors.length - 1));
    final gradient = ui.Gradient.linear(
      trackRect.centerLeft,
      trackRect.centerRight,
      colors,
      colorStops,
    );
    canvas.drawRect(trackRect, Paint()..shader = gradient);
    canvas.restore();

    final thumbCenter = Offset(metrics.thumbX(value.clamp(0.0, 1.0)), trackRect.center.dy);
    // Keep the thumb and its shadow visually contained by the track as well.
    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawCircle(
      thumbCenter.translate(0, 1),
      metrics.thumbRadius,
      Paint()
        ..color = const Color(0x33000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawCircle(thumbCenter, metrics.thumbRadius, Paint()..color = background);
    canvas.drawCircle(
      thumbCenter,
      metrics.thumbRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = background,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ColorGradientSliderPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.colors != colors ||
        oldDelegate.trackHeight != trackHeight ||
        oldDelegate.showCheckerboard != showCheckerboard ||
        oldDelegate.secondaryLabel != secondaryLabel ||
        oldDelegate.background != background;
  }
}

class _SpectrumPainter extends CustomPainter {
  const _SpectrumPainter({
    required this.hue,
    required this.saturation,
    required this.value,
    required this.color,
  });

  final double hue;
  final double saturation;
  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final ui.Rect bounds = Offset.zero & size;
    final ui.Color hueColor = HSVColor.fromAHSV(1, hue, 1, 1).toColor();

    canvas.drawRect(
      bounds,
      Paint()
        ..shader = ui.Gradient.linear(bounds.centerLeft, bounds.centerRight, <Color>[
          const Color(0xFFFFFFFF),
          hueColor,
        ]),
    );
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = ui.Gradient.linear(bounds.topCenter, bounds.bottomCenter, <Color>[
          const Color(0x00000000),
          const Color(0xFF000000),
        ]),
    );

    const thumbRadius = 9.0;
    final center = Offset(
      thumbRadius + (bounds.width - thumbRadius * 2) * saturation,
      thumbRadius + (bounds.height - thumbRadius * 2) * (1.0 - value),
    );
    canvas.drawCircle(
      center.translate(0, 1),
      thumbRadius,
      Paint()
        ..color = const Color(0x55000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawCircle(
      center,
      thumbRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = const Color(0xFFFFFFFF),
    );
    canvas.drawCircle(
      center,
      6.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(covariant _SpectrumPainter oldDelegate) {
    return oldDelegate.hue != hue ||
        oldDelegate.saturation != saturation ||
        oldDelegate.value != value ||
        oldDelegate.color != color;
  }
}

class _CheckerboardBackgroundPainter extends CustomPainter {
  const _CheckerboardBackgroundPainter({
    required this.light,
    required this.dark,
    required this.cellSize,
  });

  final Color light;
  final Color dark;
  final double cellSize;

  @override
  void paint(Canvas canvas, Size size) {
    _paintCheckerboard(canvas, Offset.zero & size, cellSize: cellSize, light: light, dark: dark);
  }

  @override
  bool shouldRepaint(covariant _CheckerboardBackgroundPainter oldDelegate) {
    return oldDelegate.light != light ||
        oldDelegate.dark != dark ||
        oldDelegate.cellSize != cellSize;
  }
}

class _CheckerboardColorPainter extends CustomPainter {
  const _CheckerboardColorPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    _paintCheckerboard(
      canvas,
      Offset.zero & size,
      cellSize: 6,
      light: const Color(0xFFFFFFFF),
      dark: const Color(0xFFD1D1D6),
    );
    canvas.drawRect(Offset.zero & size, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _CheckerboardColorPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

void _paintCheckerboard(
  Canvas canvas,
  Rect rect, {
  required double cellSize,
  required Color light,
  required Color dark,
}) {
  canvas.drawRect(rect, Paint()..color = light);
  final int columns = (rect.width / cellSize).ceil();
  final int rows = (rect.height / cellSize).ceil();
  final paint = Paint()..color = dark;
  for (var row = 0; row < rows; row++) {
    for (var column = 0; column < columns; column++) {
      if ((row + column).isOdd) {
        canvas.drawRect(
          Rect.fromLTWH(
            rect.left + column * cellSize,
            rect.top + row * cellSize,
            cellSize,
            cellSize,
          ),
          paint,
        );
      }
    }
  }
}

class _CupertinoColorPickerStrings {
  const _CupertinoColorPickerStrings({
    required this.colors,
    required this.grid,
    required this.spectrum,
    required this.sliders,
    required this.opacity,
    required this.hue,
    required this.saturation,
    required this.brightness,
    required this.red,
    required this.green,
    required this.blue,
    required this.hex,
    required this.close,
    required this.addColor,
    required this.colorWell,
  });

  // American English is the base localization. Keeping the strings in this
  // standalone file avoids coupling the control to the host app's l10n setup.
  static const _CupertinoColorPickerStrings defaults = _CupertinoColorPickerStrings(
    colors: 'Colors',
    grid: 'Grid',
    spectrum: 'Spectrum',
    sliders: 'Sliders',
    opacity: 'Opacity',
    hue: 'Hue',
    saturation: 'Saturation',
    brightness: 'Brightness',
    red: 'Red',
    green: 'Green',
    blue: 'Blue',
    hex: 'Hex',
    close: 'Close',
    addColor: 'Add color',
    colorWell: 'Color',
  );

  final String colors;
  final String grid;
  final String spectrum;
  final String sliders;
  final String opacity;
  final String hue;
  final String saturation;
  final String brightness;
  final String red;
  final String green;
  final String blue;
  final String hex;
  final String close;
  final String addColor;
  final String colorWell;
}
