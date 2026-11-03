// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// #region body
import 'dart:math' as math;

import 'package:flutter/physics.dart';
import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [Springs].

void main() {
  runApp(const SpringsExampleApp());
}

class SpringsExampleApp extends StatelessWidget {
  const SpringsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: SpringsExample());
  }
}

enum _MotionScheme { standard, expressive }

enum _Speed {
  fast,

  /// The default speed, which most motion should use.
  normal,

  slow,
}

class SpringsExample extends StatefulWidget {
  const SpringsExample({super.key});

  @override
  State<SpringsExample> createState() => _SpringsExampleState();
}

class _SpringsExampleState extends State<SpringsExample>
    with TickerProviderStateMixin {
  /// Moves the box with the selected spatial spring.
  ///
  /// The controller is unbounded so that the spring can overshoot the target
  /// and bounce back into place.
  late final AnimationController _position = AnimationController.unbounded(
    vsync: this,
  );

  /// Changes the color of the box with the selected effects spring.
  late final AnimationController _color = AnimationController.unbounded(
    vsync: this,
  );

  _MotionScheme _scheme = _MotionScheme.standard;
  _Speed _speed = _Speed.normal;
  bool _atEnd = false;

  SpringDescription get _spatialSpring => switch ((_scheme, _speed)) {
    (_MotionScheme.standard, _Speed.fast) => Springs.standardFastSpatial,
    (_MotionScheme.standard, _Speed.normal) => Springs.standardDefaultSpatial,
    (_MotionScheme.standard, _Speed.slow) => Springs.standardSlowSpatial,
    (_MotionScheme.expressive, _Speed.fast) => Springs.expressiveFastSpatial,
    (_MotionScheme.expressive, _Speed.normal) =>
      Springs.expressiveDefaultSpatial,
    (_MotionScheme.expressive, _Speed.slow) => Springs.expressiveSlowSpatial,
  };

  SpringDescription get _effectsSpring => switch ((_scheme, _speed)) {
    (_MotionScheme.standard, _Speed.fast) => Springs.standardFastEffects,
    (_MotionScheme.standard, _Speed.normal) => Springs.standardDefaultEffects,
    (_MotionScheme.standard, _Speed.slow) => Springs.standardSlowEffects,
    (_MotionScheme.expressive, _Speed.fast) => Springs.expressiveFastEffects,
    (_MotionScheme.expressive, _Speed.normal) =>
      Springs.expressiveDefaultEffects,
    (_MotionScheme.expressive, _Speed.slow) => Springs.expressiveSlowEffects,
  };

  void _toggle() {
    setState(() {
      _atEnd = !_atEnd;
    });
    final double target = _atEnd ? 1.0 : 0.0;
    // Starting each simulation from the current value and velocity lets an
    // interrupted animation head to its new target without a jump.
    _position.animateWith(
      SpringSimulation(
        _spatialSpring,
        _position.value,
        target,
        _position.velocity,
        snapToEnd: true,
      ),
    );
    _color.animateWith(
      SpringSimulation(
        _effectsSpring,
        _color.value,
        target,
        _color.velocity,
        snapToEnd: true,
      ),
    );
  }

  @override
  void dispose() {
    _position.dispose();
    _color.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Material 3 Expressive Springs Sample')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            SegmentedButton<_MotionScheme>(
              segments: const <ButtonSegment<_MotionScheme>>[
                ButtonSegment<_MotionScheme>(
                  value: _MotionScheme.standard,
                  label: Text('Standard'),
                ),
                ButtonSegment<_MotionScheme>(
                  value: _MotionScheme.expressive,
                  label: Text('Expressive'),
                ),
              ],
              selected: <_MotionScheme>{_scheme},
              onSelectionChanged: (Set<_MotionScheme> selection) {
                setState(() {
                  _scheme = selection.single;
                });
              },
            ),
            const SizedBox(height: 8.0),
            SegmentedButton<_Speed>(
              segments: const <ButtonSegment<_Speed>>[
                ButtonSegment<_Speed>(value: _Speed.fast, label: Text('Fast')),
                ButtonSegment<_Speed>(
                  value: _Speed.normal,
                  label: Text('Default'),
                ),
                ButtonSegment<_Speed>(value: _Speed.slow, label: Text('Slow')),
              ],
              selected: <_Speed>{_speed},
              onSelectionChanged: (Set<_Speed> selection) {
                setState(() {
                  _speed = selection.single;
                });
              },
            ),
            const SizedBox(height: 16.0),
            Text('Spatial spring: ${_describe(_spatialSpring)}'),
            Text('Effects spring: ${_describe(_effectsSpring)}'),
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  const double size = 80.0;
                  final double travel = constraints.maxWidth - size;
                  return AnimatedBuilder(
                    animation: Listenable.merge(<Listenable>[
                      _position,
                      _color,
                    ]),
                    builder: (BuildContext context, Widget? child) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          Positioned(
                            left: _position.value * travel,
                            top: (constraints.maxHeight - size) / 2,
                            width: size,
                            height: size,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Color.lerp(
                                  colors.secondaryContainer,
                                  colors.primary,
                                  math.min(math.max(_color.value, 0.0), 1.0),
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(16.0),
                                ),
                              ),
                              child: child,
                            ),
                          ),
                        ],
                      );
                    },
                    child: Icon(Icons.star, color: colors.onSecondaryContainer),
                  );
                },
              ),
            ),
            FilledButton(
              onPressed: _toggle,
              child: Text(_atEnd ? 'Move back' : 'Move'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Describes [spring] with the stiffness and damping ratio of its Material
/// spring token.
String _describe(SpringDescription spring) {
  final double dampingRatio =
      spring.damping / (2.0 * math.sqrt(spring.mass * spring.stiffness));
  return 'stiffness ${spring.stiffness.toStringAsFixed(0)}, '
      'damping ratio ${dampingRatio.toStringAsFixed(2)}';
}

// #endregion body
