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
  bool _slowMotion = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final double target = _atEnd ? 1.0 : 0.0;
    final double timeScale = _slowMotion ? 0.25 : 1.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Material 3 Expressive Springs Sample')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640.0),
                  child: Column(
                    spacing: 12.0,
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
                      if (_type == _SpringType.spatial)
                        SegmentedButton<_Speed>(
                          segments: const <ButtonSegment<_Speed>>[
                            ButtonSegment<_Speed>(
                              value: _Speed.fast,
                              label: Text('Fast'),
                            ),
                            ButtonSegment<_Speed>(
                              value: _Speed.normal,
                              label: Text('Default'),
                            ),
                            ButtonSegment<_Speed>(
                              value: _Speed.slow,
                              label: Text('Slow'),
                            ),
                          ],
                          selected: <_Speed>{_speed},
                          onSelectionChanged: (Set<_Speed> selection) {
                            setState(() {
                              _speed = selection.single;
                            });
                          },
                        ),
                      Text(
                        switch (_type) {
                          _SpringType.spatial =>
                            'Spatial springs animate movement and can '
                                'overshoot their target.',
                          _SpringType.effects =>
                            'Standard and expressive schemes share the same '
                                'effects springs. Compare all three speeds '
                                'side by side.',
                        },
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Column(
                        key: ValueKey<_SpringType>(_type),
                        spacing: 12.0,
                        children: switch (_type) {
                          _SpringType.spatial => <Widget>[
                            _SpringCard(
                              label: 'Standard',
                              spring: switch (_speed) {
                                _Speed.fast => Springs.standardFastSpatial,
                                _Speed.normal => Springs.standardDefaultSpatial,
                                _Speed.slow => Springs.standardSlowSpatial,
                              },
                              target: target,
                              timeScale: timeScale,
                              builder: _buildSpatialTrack,
                            ),
                            _SpringCard(
                              label: 'Expressive',
                              spring: switch (_speed) {
                                _Speed.fast => Springs.expressiveFastSpatial,
                                _Speed.normal =>
                                  Springs.expressiveDefaultSpatial,
                                _Speed.slow => Springs.expressiveSlowSpatial,
                              },
                              target: target,
                              timeScale: timeScale,
                              builder: _buildSpatialTrack,
                            ),
                          ],
                          // Standard and expressive schemes share identical
                          // effects springs (for example,
                          // Springs.expressiveFastEffects matches
                          // Springs.standardFastEffects).
                          _SpringType.effects => <Widget>[
                            _SpringCard(
                              label: 'Fast',
                              spring: Springs.standardFastEffects,
                              target: target,
                              timeScale: timeScale,
                              builder: _buildEffectsSwatch,
                            ),
                            _SpringCard(
                              label: 'Default',
                              spring: Springs.standardDefaultEffects,
                              target: target,
                              timeScale: timeScale,
                              builder: _buildEffectsSwatch,
                            ),
                            _SpringCard(
                              label: 'Slow',
                              spring: Springs.standardSlowEffects,
                              target: target,
                              timeScale: timeScale,
                              builder: _buildEffectsSwatch,
                            ),
                          ],
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12.0,
                runSpacing: 8.0,
                children: <Widget>[
                  FilledButton(
                    onPressed: () {
                      setState(() {
                        _atEnd = !_atEnd;
                      });
                    },
                    child: const Text('Animate'),
                  ),
                  FilterChip(
                    label: const Text('0.25x speed'),
                    selected: _slowMotion,
                    onSelected: (bool selected) {
                      setState(() {
                        _slowMotion = selected;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpatialTrack(BuildContext context, double value) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    // Leave room on both sides so underdamped springs can overshoot without
    // leaving the card.
    return FractionallySizedBox(
      widthFactor: 0.8,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Align(
            heightFactor: 1.0,
            alignment: Alignment.lerp(
              Alignment.centerLeft,
              Alignment.centerRight,
              value,
            )!,
            child: SizedBox.square(
              dimension: 44.0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: const BorderRadius.all(Radius.circular(14.0)),
                ),
                child: Icon(Icons.star_rounded, color: colors.onPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEffectsSwatch(BuildContext context, double value) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Card.filled(
      margin: EdgeInsets.zero,
      color: Color.lerp(
        colors.surfaceContainerHighest,
        colors.primary,
        value.clamp(0.0, 1.0),
      ),
      child: const SizedBox(height: 56.0),
    );
  }
}

/// A card that drives a child animation with a [SpringSimulation].
class _SpringCard extends StatefulWidget {
  const _SpringCard({
    required this.label,
    required this.spring,
    required this.target,
    required this.timeScale,
    required this.builder,
  });

  final String label;
  final SpringDescription spring;
  final double target;
  final double timeScale;
  final Widget Function(BuildContext context, double value) builder;

  @override
  State<_SpringCard> createState() => _SpringCardState();
}

class _SpringCardState extends State<_SpringCard>
    with SingleTickerProviderStateMixin {
  // Unbounded so an underdamped spatial spring can overshoot its target and
  // bounce back into place.
  late final AnimationController _controller = AnimationController.unbounded(
    vsync: this,
    value: widget.target,
  );

  @override
  void didUpdateWidget(_SpringCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.target != oldWidget.target ||
        (widget.timeScale != oldWidget.timeScale && _controller.isAnimating)) {
      final SpringSimulation simulation = SpringSimulation(
        widget.spring,
        _controller.value,
        widget.target,
        _controller.velocity / oldWidget.timeScale,
        snapToEnd: true,
      );
      _controller.animateWith(
        widget.timeScale == 1.0
            ? simulation
            : _ScaledSimulation(simulation, widget.timeScale),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12.0,
          children: <Widget>[
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12.0,
              runSpacing: 4.0,
              children: <Widget>[
                Text(widget.label, style: theme.textTheme.titleMedium),
                Text(
                  _describe(widget.spring),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? child) {
                return widget.builder(context, _controller.value);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Wraps a [Simulation] so it plays back at [timeScale] times its normal speed.
class _ScaledSimulation extends Simulation {
  _ScaledSimulation(this.simulation, this.timeScale)
    : assert(timeScale > 0.0),
      super(tolerance: simulation.tolerance);

  final Simulation simulation;
  final double timeScale;

  @override
  double x(double time) => simulation.x(time * timeScale);

  @override
  double dx(double time) => simulation.dx(time * timeScale) * timeScale;

  @override
  bool isDone(double time) => simulation.isDone(time * timeScale);
}

/// Describes [spring] with the stiffness and damping ratio of its Material
/// spring token.
String _describe(SpringDescription spring) {
  final double dampingRatio =
      spring.damping / (2.0 * math.sqrt(spring.mass * spring.stiffness));
  return 'stiffness ${spring.stiffness.toStringAsFixed(0)} · '
      'damping ratio ${dampingRatio.toStringAsFixed(2)}';
}

// #endregion body
