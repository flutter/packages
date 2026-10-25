// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This code is a Dart port of the Compose Material 3 loading indicator:
// https://cs.android.com/androidx/platform/frameworks/support/+/androidx-main:compose/material3/material3/src/commonMain/kotlin/androidx/compose/material3/LoadingIndicator.kt

/// @docImport 'package:flutter/semantics.dart';
///
/// @docImport 'progress_indicator.dart';
library;

import 'dart:math' as math;
import 'dart:ui' show SemanticsRole;

import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'color_scheme.dart';
import 'loading_indicator_theme.dart';
import 'material_shapes.dart';
import 'shapes/morph.dart';
import 'shapes/rounded_polygon.dart';
import 'theme.dart';

part 'generated/loading_indicator_defaults_m3e.g.dart';

/// How long the indeterminate indicator takes to morph from one shape to the
/// next.
const Duration _kMorphInterval = Duration(milliseconds: 650);

/// How long the indeterminate indicator takes to complete one full turn of
/// its constant rotation, on top of the rotation that comes with each morph.
const Duration _kGlobalRotationDuration = Duration(milliseconds: 4666);

/// The spring that drives each indeterminate morph.
///
/// Its overshoot carries the morph slightly past its end shape, which gives
/// the indicator its bounce.
///
/// Unlike Compose, which stops the spring early and snaps it back to the end
/// shape, the spring runs for the whole [_kMorphInterval], so that the
/// overshoot settles smoothly.
final SpringSimulation _kMorphSpring = SpringSimulation(
  SpringDescription.withDampingRatio(mass: 1, stiffness: 200, ratio: 0.6),
  0,
  1,
  0,
  snapToEnd: true,
);

/// A Material Design loading indicator.
///
/// A loading indicator morphs between a sequence of shapes, provided by
/// [polygons], while rotating. It shows the progress of a short wait, while
/// [CircularProgressIndicator] and [LinearProgressIndicator] are better suited
/// for longer processes.
///
/// There are two kinds of loading indicators:
///
///  * The default loading indicator draws the morphing shape on its own.
///  * The [LoadingIndicator.contained] loading indicator draws the morphing
///    shape on top of a container, which makes it stand out from busy content.
///
/// Both can be indeterminate or determinate, depending on [value]:
///
///  * An indeterminate loading indicator keeps morphing between [polygons],
///    looping back to the first one after the last, for as long as it is shown.
///  * A determinate loading indicator morphs from the first of its [polygons]
///    to the last as [value] goes from 0.0 to 1.0. This can be used, for
///    example, to show how far the user has pulled to refresh.
///
/// By default, a loading indicator is 48 by 48 logical pixels, of which the
/// active indicator takes up 38 by 38. If the incoming constraints require a
/// different size, it grows or shrinks to fit them, keeping the active
/// indicator at the same ratio to the shortest side and centered in the
/// middle. The default determinate and indeterminate shapes are drawn at the
/// same size, so that a determinate loading indicator can turn into an
/// indeterminate one without a jump in size.
///
/// <callout-box>
///
/// This example shows the default and contained loading indicators, both in
/// their indeterminate and determinate form.
///
// TODO(framework): Replace the following block with a @dartpad directive
// when it's supported. https://github.com/dart-lang/dartdoc/issues/4123
/// {@macro material_ui.dartpad_guide}
///
/// {@example /example/lib/loading_indicator/loading_indicator.0.dart#body}
///
/// </callout-box>
///
/// <callout-box>
///
/// This example shows a contained loading indicator used for pull to refresh.
/// A determinate indicator follows the pull, and hands over to an
/// indeterminate one once the list is released to refresh.
///
// TODO(framework): Replace the following block with a @dartpad directive
// when it's supported. https://github.com/dart-lang/dartdoc/issues/4123
/// {@macro material_ui.dartpad_guide}
///
/// {@example /example/lib/loading_indicator/loading_indicator.1.dart#body}
///
/// </callout-box>
///
/// See also:
///
///  * [LoadingIndicatorTheme], which can be used to configure the default
///    properties of loading indicators in a widget subtree.
///  * [MaterialShapes], which provides shapes that can be used for [polygons].
///  * [CircularProgressIndicator] and [LinearProgressIndicator], which show the
///    progress of longer processes.
///  * <https://m3.material.io/components/loading-indicator/overview>
class LoadingIndicator extends StatefulWidget {
  /// Creates a loading indicator that draws the morphing shape on its own.
  ///
  /// {@template material_ui.LoadingIndicator.LoadingIndicator}
  /// The [value] can either be null for an indeterminate loading indicator,
  /// or a non-null value between 0.0 and 1.0 for a determinate one.
  ///
  /// If non-null, [polygons] must contain at least two shapes.
  /// {@endtemplate}
  const LoadingIndicator({
    super.key,
    this.value,
    this.color,
    this.polygons,
    this.semanticsLabel,
    this.semanticsValue,
  }) : containerColor = null,
       containerShape = null,
       _contained = false;

  /// Creates a loading indicator that draws the morphing shape on top of a
  /// container.
  ///
  /// {@macro material_ui.LoadingIndicator.LoadingIndicator}
  const LoadingIndicator.contained({
    super.key,
    this.value,
    this.color,
    this.containerColor,
    this.containerShape,
    this.polygons,
    this.semanticsLabel,
    this.semanticsValue,
  }) : _contained = true;

  /// If non-null, the value of this loading indicator.
  ///
  /// A value of 0.0 means no progress and 1.0 means that progress is complete.
  /// The value will be clamped to be in the range 0.0-1.0.
  ///
  /// If null, this loading indicator is indeterminate, which means it keeps
  /// morphing between its [polygons] without indicating how much actual
  /// progress is being made.
  ///
  /// When the value changes to null, the indicator starts morphing from its
  /// first indeterminate shape at the rotation it was last drawn at. The
  /// default [determinatePolygons] end on the first of the default
  /// [indeterminatePolygons], so a determinate indicator that reaches 1.0 can
  /// turn into an indeterminate one without a visible seam, for example when a
  /// pull to refresh is released.
  final double? value;

  /// The color of the active indicator, the morphing shape.
  ///
  /// If null, then [LoadingIndicatorThemeData.color] is used for the default
  /// loading indicator, and [LoadingIndicatorThemeData.containedColor] for the
  /// [LoadingIndicator.contained] one. If that is also null, then
  /// [ColorScheme.primary] is used for the default loading indicator, and
  /// [ColorScheme.onPrimaryContainer] for the contained one.
  final Color? color;

  /// The color of the container that the active indicator is drawn on.
  ///
  /// Only used by the [LoadingIndicator.contained] loading indicator.
  ///
  /// If null, then [LoadingIndicatorThemeData.containerColor] is used. If that
  /// is also null, then [ColorScheme.primaryContainer] is used.
  final Color? containerColor;

  /// The shape of the container that the active indicator is drawn on.
  ///
  /// Only used by the [LoadingIndicator.contained] loading indicator.
  ///
  /// If null, then [LoadingIndicatorThemeData.containerShape] is used. If that
  /// is also null, then a [StadiumBorder] is used, which is a circle at the
  /// default size.
  final ShapeBorder? containerShape;

  /// The sequence of shapes that this loading indicator morphs between.
  ///
  /// The shapes don't need to be normalized, as the loading indicator
  /// normalizes them and scales them to fit its size, leaving enough room for
  /// them to rotate without being clipped. The default [indeterminatePolygons]
  /// and [determinatePolygons] are scaled together, so they are drawn at the
  /// same size.
  ///
  /// Must contain at least two shapes.
  ///
  /// When the shapes change, the indicator starts over from the first of the
  /// new shapes, at the rotation it was last drawn at.
  ///
  /// If null, then [indeterminatePolygons] is used for an indeterminate
  /// loading indicator, and [determinatePolygons] for a determinate one.
  final List<RoundedPolygon>? polygons;

  /// {@macro material_ui.progress_indicator.ProgressIndicator.semanticsLabel}
  final String? semanticsLabel;

  /// {@macro material_ui.progress_indicator.ProgressIndicator.semanticsValue}
  final String? semanticsValue;

  final bool _contained;

  /// The default sequence of shapes that an indeterminate loading indicator
  /// morphs between.
  static final List<RoundedPolygon> indeterminatePolygons = List<RoundedPolygon>.unmodifiable(
    <RoundedPolygon>[
      MaterialShapes.softBurst,
      MaterialShapes.cookie9Sided,
      MaterialShapes.pentagon,
      MaterialShapes.pill,
      MaterialShapes.sunny,
      MaterialShapes.cookie4Sided,
      MaterialShapes.oval,
    ],
  );

  /// The default sequence of shapes that a determinate loading indicator
  /// morphs between as its [value] goes from 0.0 to 1.0.
  ///
  /// It ends on [MaterialShapes.softBurst], the first shape of
  /// [indeterminatePolygons], so a determinate loading indicator that completes
  /// can turn into an indeterminate one without a jump in shape. See [value].
  static final List<RoundedPolygon> determinatePolygons = List<RoundedPolygon>.unmodifiable(
    <RoundedPolygon>[
      // Rotating the circle by half the angle between two of its vertices
      // lines them up with the soft burst's, so it morphs into the soft burst
      // more smoothly.
      _rotate(MaterialShapes.circle, 2 * math.pi / 20),
      MaterialShapes.softBurst,
    ],
  );

  /// Rotates [polygon] by [angle] radians around its center.
  static RoundedPolygon _rotate(RoundedPolygon polygon, double angle) {
    final Offset center = polygon.calculateBounds().center;
    final double cos = math.cos(angle);
    final double sin = math.sin(angle);

    return polygon.transformed((double x, double y) {
      final double dx = x - center.dx;
      final double dy = y - center.dy;
      return (center.dx + dx * cos - dy * sin, center.dy + dx * sin + dy * cos);
    });
  }

  double? get _effectiveValue => value == null ? null : clampDouble(value!, 0.0, 1.0);

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('value', value, defaultValue: null));
    properties.add(ColorProperty('color', color, defaultValue: null));
    properties.add(ColorProperty('containerColor', containerColor, defaultValue: null));
    properties.add(
      DiagnosticsProperty<ShapeBorder>('containerShape', containerShape, defaultValue: null),
    );
    properties.add(IterableProperty<RoundedPolygon>('polygons', polygons, defaultValue: null));
    properties.add(StringProperty('semanticsLabel', semanticsLabel, defaultValue: null));
    properties.add(StringProperty('semanticsValue', semanticsValue, defaultValue: null));
    properties.add(FlagProperty('contained', value: _contained, ifTrue: 'contained'));
  }
}

/// The shape and rotation of a loading indicator at one point in time.
typedef _LoadingIndicatorPose = ({int morphIndex, double morphProgress, double rotation});

/// The rotation of a determinate loading indicator at [value], which turns
/// counterclockwise by half a turn over the whole range.
double _determinateRotation(double value) => -value * math.pi;

/// The pose of a determinate loading indicator with [morphCount] morphs at
/// [value].
_LoadingIndicatorPose _determinatePose(double value, int morphCount) {
  // A determinate indicator spends an equal share of its value on each morph.
  // Without the special case, a value of 1.0 would land at the start of a
  // morph past the last one.
  return (
    morphIndex: math.min((value * morphCount).floor(), morphCount - 1),
    morphProgress: value == 1.0 ? 1.0 : (value * morphCount) % 1.0,
    rotation: _determinateRotation(value),
  );
}

/// The pose of an indeterminate loading indicator with [morphCount] morphs,
/// [elapsed] into an animation that started at [startRotation].
_LoadingIndicatorPose _indeterminatePose(Duration elapsed, int morphCount, double startRotation) {
  final int elapsedUs = elapsed.inMicroseconds;
  final int intervalUs = _kMorphInterval.inMicroseconds;
  final int globalRotationUs = _kGlobalRotationDuration.inMicroseconds;
  final int completedMorphs = elapsedUs ~/ intervalUs;
  final double morphProgress = _kMorphSpring.x(
    (elapsedUs % intervalUs) / Duration.microsecondsPerSecond,
  );
  final double globalTurns = (elapsedUs % globalRotationUs) / globalRotationUs;
  // Each morph adds a quarter turn on top of the constant rotation.
  final double morphTurns = (completedMorphs % 4 + morphProgress) / 4;

  return (
    morphIndex: completedMorphs % morphCount,
    morphProgress: morphProgress,
    rotation: startRotation + 2 * math.pi * (globalTurns + morphTurns),
  );
}

class _LoadingIndicatorState extends State<LoadingIndicator> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker((Duration elapsed) => _elapsed.value = elapsed);

  /// How long the indeterminate animation has been running.
  ///
  /// The whole indeterminate animation is derived from this single clock, so
  /// that each morph and the constant rotation stay in step with each other.
  final ValueNotifier<Duration> _elapsed = ValueNotifier<Duration>(Duration.zero);

  /// The rotation that the indeterminate animation starts from, which carries
  /// over the rotation that the indicator was last drawn at.
  double _indeterminateStartRotation = 0.0;

  late List<RoundedPolygon> _polygons;
  late List<Morph> _morphs;

  /// The factor that scales the shapes so that they fit in the indicator's
  /// bounds in any rotation.
  late double _scaleFactor;

  /// The scale factor shared by the default determinate and indeterminate
  /// shapes, so that one can turn into the other without changing size.
  ///
  /// Compose scales each sequence on its own instead, which draws its
  /// determinate shapes larger than its indeterminate ones.
  static final double _defaultScaleFactor = _calculateScaleFactor(<RoundedPolygon>[
    ...LoadingIndicator.determinatePolygons,
    ...LoadingIndicator.indeterminatePolygons,
  ]);

  /// The morphs between the default indeterminate shapes.
  ///
  /// Building morphs is the most expensive part of setting up an indicator, so
  /// the morphs between the default shapes are built once and shared.
  static final List<Morph> _defaultIndeterminateMorphs = _buildMorphs(
    LoadingIndicator.indeterminatePolygons,
    loops: true,
  );

  /// The morphs between the default determinate shapes.
  ///
  /// See [_defaultIndeterminateMorphs] for why they are shared.
  static final List<Morph> _defaultDeterminateMorphs = _buildMorphs(
    LoadingIndicator.determinatePolygons,
    loops: false,
  );

  @override
  void initState() {
    super.initState();
    _updateMorphs();
    _updateTicker();
  }

  @override
  void didUpdateWidget(LoadingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    final double? oldValue = oldWidget._effectiveValue;
    if ((oldValue == null) != (widget._effectiveValue == null) ||
        !listEquals(_polygons, _effectivePolygons)) {
      // The new shapes start from the first one, but keep the rotation that
      // the indicator was last drawn at, so that they don't jump.
      _indeterminateStartRotation = oldValue == null
          ? _indeterminatePose(_elapsed.value, _morphs.length, _indeterminateStartRotation).rotation
          : _determinateRotation(oldValue);
      _updateMorphs();
      _ticker.stop();
      _elapsed.value = Duration.zero;
    }

    _updateTicker();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _elapsed.dispose();
    super.dispose();
  }

  List<RoundedPolygon> get _effectivePolygons {
    return widget.polygons ??
        (widget._effectiveValue == null
            ? LoadingIndicator.indeterminatePolygons
            : LoadingIndicator.determinatePolygons);
  }

  void _updateMorphs() {
    _polygons = _effectivePolygons;
    assert(
      _polygons.length >= 2,
      'A LoadingIndicator needs at least two polygons to morph between, '
      'but ${_polygons.length} were provided.',
    );

    final isIndeterminate = widget._effectiveValue == null;
    if (widget.polygons == null) {
      _morphs = isIndeterminate ? _defaultIndeterminateMorphs : _defaultDeterminateMorphs;
      _scaleFactor = _defaultScaleFactor;
    } else {
      _morphs = _buildMorphs(_polygons, loops: isIndeterminate);
      _scaleFactor = _calculateScaleFactor(_polygons);
    }
  }

  /// Builds the morphs between each of [polygons] and the next one.
  ///
  /// If [loops] is true, which it is for an indeterminate indicator, then an
  /// extra morph goes from the last shape back to the first one.
  static List<Morph> _buildMorphs(List<RoundedPolygon> polygons, {required bool loops}) {
    final normalized = <RoundedPolygon>[
      for (final RoundedPolygon polygon in polygons) polygon.normalized(),
    ];
    return List<Morph>.unmodifiable(<Morph>[
      for (var i = 0; i < normalized.length - (loops ? 0 : 1); i++)
        Morph(normalized[i], normalized[(i + 1) % normalized.length]),
    ]);
  }

  /// Calculates the factor that scales [polygons] so that they fit in the
  /// indicator's bounds in any rotation.
  ///
  /// The bounds of a shape only fit it in its current rotation, while its max
  /// bounds fit it in any rotation. The ratio between the two is how much the
  /// shape has to shrink to never get clipped as it rotates.
  static double _calculateScaleFactor(List<RoundedPolygon> polygons) {
    var scaleFactor = 1.0;

    for (final polygon in polygons) {
      final Rect bounds = polygon.calculateBounds();
      final Rect maxBounds = polygon.calculateMaxBounds();
      // Taking the larger of the two ratios keeps an elongated shape, like a
      // pill, from shrinking all the others too much.
      scaleFactor = math.min(
        scaleFactor,
        math.max(bounds.width / maxBounds.width, bounds.height / maxBounds.height),
      );
    }

    return scaleFactor;
  }

  void _updateTicker() {
    if (widget._effectiveValue == null) {
      if (!_ticker.isActive) {
        _ticker.start();
      }
    } else if (_ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final LoadingIndicatorThemeData theme = LoadingIndicatorTheme.of(context);
    final defaults = _LoadingIndicatorDefaultsM3E(context);
    final Color color = widget._contained
        ? widget.color ?? theme.containedColor ?? defaults.containedColor!
        : widget.color ?? theme.color ?? defaults.color!;

    Widget result = CustomPaint(
      painter: _LoadingIndicatorPainter(
        morphs: _morphs,
        value: widget._effectiveValue,
        elapsed: _elapsed,
        indeterminateStartRotation: _indeterminateStartRotation,
        color: color,
        scaleFactor:
            _scaleFactor * defaults.activeIndicatorSize / defaults.containerSize.shortestSide,
      ),
    );

    if (widget._contained) {
      result = DecoratedBox(
        decoration: ShapeDecoration(
          color: widget.containerColor ?? theme.containerColor ?? defaults.containerColor,
          shape: widget.containerShape ?? theme.containerShape ?? defaults.containerShape!,
        ),
        child: result,
      );
    }

    final double? value = widget._effectiveValue;
    final isProgressBar = value != null;

    return Semantics(
      label: widget.semanticsLabel,
      role: isProgressBar ? SemanticsRole.progressBar : SemanticsRole.loadingSpinner,
      minValue: isProgressBar ? '0' : null,
      maxValue: isProgressBar ? '100' : null,
      value: widget.semanticsValue ?? (isProgressBar ? '${(value * 100).round()}' : null),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: defaults.containerSize.width,
          minHeight: defaults.containerSize.height,
        ),
        child: result,
      ),
    );
  }
}

class _LoadingIndicatorPainter extends CustomPainter {
  _LoadingIndicatorPainter({
    required this.morphs,
    required this.value,
    required this.elapsed,
    required this.indeterminateStartRotation,
    required this.color,
    required this.scaleFactor,
  }) : super(repaint: elapsed);

  final List<Morph> morphs;

  /// The value of a determinate indicator, or null for an indeterminate one.
  final double? value;

  /// How long the indeterminate animation has been running.
  final ValueListenable<Duration> elapsed;

  final double indeterminateStartRotation;

  final Color color;

  /// The size of the shape relative to the shortest side of the indicator.
  final double scaleFactor;

  @override
  void paint(Canvas canvas, Size size) {
    final _LoadingIndicatorPose pose = switch (value) {
      final double value => _determinatePose(value, morphs.length),
      null => _indeterminatePose(elapsed.value, morphs.length, indeterminateStartRotation),
    };
    final double side = size.shortestSide * scaleFactor;
    final Path path = morphs[pose.morphIndex].toPath(pose.morphProgress);
    // Centering the shape by its bounds, rather than its polygon's center,
    // keeps lopsided shapes from wobbling as they rotate.
    final Offset pathCenter = path.getBounds().center;
    final Offset center = size.center(Offset.zero);

    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(pose.rotation)
      ..scale(side)
      ..translate(-pathCenter.dx, -pathCenter.dy)
      ..drawPath(path, Paint()..color = color)
      ..restore();
  }

  @override
  bool shouldRepaint(_LoadingIndicatorPainter oldPainter) {
    return oldPainter.morphs != morphs ||
        oldPainter.value != value ||
        oldPainter.elapsed != elapsed ||
        oldPainter.indeterminateStartRotation != indeterminateStartRotation ||
        oldPainter.color != color ||
        oldPainter.scaleFactor != scaleFactor;
  }
}
