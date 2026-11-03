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

/// The type of motion that a spring is for.
enum _SpringType {
  /// Movement, such as position, size, rotation, and corner radius.
  spatial,

  /// Properties that shouldn't overshoot, such as color and opacity.
  effects,
}

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

class _SpringsExampleState extends State<SpringsExample> {
  _SpringType _type = _SpringType.spatial;
  _Speed _speed = _Speed.normal;
  bool _atEnd = false;

  @override
  Widget build(BuildContext context) {
    final double target = _atEnd ? 1.0 : 0.0;
    return Scaffold(
      appBar: AppBar(title: const Text('Material 3 Expressive Springs Sample')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            SegmentedButton<_SpringType>(
              segments: const <ButtonSegment<_SpringType>>[
                ButtonSegment<_SpringType>(
                  value: _SpringType.spatial,
                  label: Text('Spatial'),
                ),
                ButtonSegment<_SpringType>(
                  value: _SpringType.effects,
                  label: Text('Effects'),
                ),
              ],
              selected: <_SpringType>{_type},
              onSelectionChanged: (Set<_SpringType> selection) {
                setState(() {
                  _type = selection.single;
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
            Text(switch (_type) {
              _SpringType.spatial => 'Spatial springs move the boxes.',
              _SpringType.effects =>
                'Effects springs change the color of the boxes. Both motion '
                    'schemes use the same effects springs.',
            }),
            Expanded(
              child: _SpringTrack(
                label: 'Standard',
                type: _type,
                spatialSpring: switch (_speed) {
                  _Speed.fast => Springs.standardFastSpatial,
                  _Speed.normal => Springs.standardDefaultSpatial,
                  _Speed.slow => Springs.standardSlowSpatial,
                },
                effectsSpring: switch (_speed) {
                  _Speed.fast => Springs.standardFastEffects,
                  _Speed.normal => Springs.standardDefaultEffects,
                  _Speed.slow => Springs.standardSlowEffects,
                },
                target: target,
              ),
            ),
            Expanded(
              child: _SpringTrack(
                label: 'Expressive',
                type: _type,
                spatialSpring: switch (_speed) {
                  _Speed.fast => Springs.expressiveFastSpatial,
                  _Speed.normal => Springs.expressiveDefaultSpatial,
                  _Speed.slow => Springs.expressiveSlowSpatial,
                },
                effectsSpring: switch (_speed) {
                  _Speed.fast => Springs.expressiveFastEffects,
                  _Speed.normal => Springs.expressiveDefaultEffects,
                  _Speed.slow => Springs.expressiveSlowEffects,
                },
                target: target,
              ),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _atEnd = !_atEnd;
                });
              },
              child: const Text('Animate'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A box that shows the springs of one motion scheme.
///
/// Whenever [target] changes, the box animates toward it. With the spatial
/// [type], it moves along the track with [spatialSpring]. With the effects
/// [type], it stays in place and changes its color with [effectsSpring].
class _SpringTrack extends StatefulWidget {
  const _SpringTrack({
    required this.label,
    required this.type,
    required this.spatialSpring,
    required this.effectsSpring,
    required this.target,
  });

  final String label;
  final _SpringType type;
  final SpringDescription spatialSpring;
  final SpringDescription effectsSpring;

  /// The end of the animation: 0.0 for the start of the track and the first
  /// color, and 1.0 for the end of the track and the second color.
  final double target;

  @override
  State<_SpringTrack> createState() => _SpringTrackState();
}

class _SpringTrackState extends State<_SpringTrack>
    with TickerProviderStateMixin {
  // The controllers are unbounded so that a spring can overshoot the target
  // and bounce back into place.
  late final AnimationController _position = AnimationController.unbounded(
    vsync: this,
    value: widget.target,
  );
  late final AnimationController _color = AnimationController.unbounded(
    vsync: this,
    value: widget.target,
  );

  @override
  void didUpdateWidget(_SpringTrack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.target != oldWidget.target) {
      // Both animations run so that the box is up to date when the type
      // changes. Starting each simulation from the current value and velocity
      // lets an interrupted animation head to its new target without a jump.
      _position.animateWith(
        SpringSimulation(
          widget.spatialSpring,
          _position.value,
          widget.target,
          _position.velocity,
          snapToEnd: true,
        ),
      );
      _color.animateWith(
        SpringSimulation(
          widget.effectsSpring,
          _color.value,
          widget.target,
          _color.velocity,
          snapToEnd: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _position.dispose();
    _color.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final String description = switch (widget.type) {
      _SpringType.spatial =>
        'Spatial spring: ${_describe(widget.spatialSpring)}',
      _SpringType.effects =>
        'Effects spring: ${_describe(widget.effectsSpring)}',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(widget.label, style: theme.textTheme.titleMedium),
        Text(description),
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              const double size = 56.0;
              final double travel = constraints.maxWidth - size;
              return AnimatedBuilder(
                animation: switch (widget.type) {
                  _SpringType.spatial => _position,
                  _SpringType.effects => _color,
                },
                builder: (BuildContext context, Widget? child) {
                  // Show one animation at a time: the spatial spring only
                  // moves the box, and the effects spring only changes its
                  // color.
                  final double left = switch (widget.type) {
                    _SpringType.spatial => _position.value * travel,
                    _SpringType.effects => travel / 2,
                  };
                  final double colorValue = switch (widget.type) {
                    _SpringType.spatial => 0.0,
                    _SpringType.effects => math.min(
                      math.max(_color.value, 0.0),
                      1.0,
                    ),
                  };
                  return Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Positioned(
                        left: left,
                        top: (constraints.maxHeight - size) / 2,
                        width: size,
                        height: size,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color.lerp(
                              colors.secondaryContainer,
                              colors.primary,
                              colorValue,
                            ),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(16.0),
                            ),
                          ),
                          child: Icon(
                            Icons.star,
                            color: Color.lerp(
                              colors.onSecondaryContainer,
                              colors.onPrimary,
                              colorValue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
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
