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
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final double target = _atEnd ? 1.0 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Material 3 Expressive Springs Sample'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640.0, maxHeight: 620.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
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
                if (_type == _SpringType.spatial) ...<Widget>[
                  const SizedBox(height: 10.0),
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
                ],
                const SizedBox(height: 12.0),
                Text(
                  switch (_type) {
                    _SpringType.spatial =>
                      'Spatial springs animate movement and can overshoot '
                          'their target.',
                    _SpringType.effects =>
                      'Standard and expressive schemes share the same '
                          'effects springs. Compare all three speeds side by '
                          'side.',
                  },
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
                Expanded(
                  child: switch (_type) {
                    _SpringType.spatial => Column(
                      children: <Widget>[
                        Expanded(
                          child: _SpatialSpringCard(
                            label: 'Standard',
                            spring: switch (_speed) {
                              _Speed.fast => Springs.standardFastSpatial,
                              _Speed.normal => Springs.standardDefaultSpatial,
                              _Speed.slow => Springs.standardSlowSpatial,
                            },
                            target: target,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Expanded(
                          child: _SpatialSpringCard(
                            label: 'Expressive',
                            spring: switch (_speed) {
                              _Speed.fast => Springs.expressiveFastSpatial,
                              _Speed.normal => Springs.expressiveDefaultSpatial,
                              _Speed.slow => Springs.expressiveSlowSpatial,
                            },
                            target: target,
                          ),
                        ),
                      ],
                    ),
                    // Standard and expressive schemes share identical effects
                    // springs (for example, Springs.expressiveFastEffects
                    // matches Springs.standardFastEffects).
                    _SpringType.effects => Column(
                      children: <Widget>[
                        Expanded(
                          child: _EffectsSpringCard(
                            label: 'Fast',
                            spring: Springs.standardFastEffects,
                            target: target,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Expanded(
                          child: _EffectsSpringCard(
                            label: 'Default',
                            spring: Springs.standardDefaultEffects,
                            target: target,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Expanded(
                          child: _EffectsSpringCard(
                            label: 'Slow',
                            spring: Springs.standardSlowEffects,
                            target: target,
                          ),
                        ),
                      ],
                    ),
                  },
                ),
                const SizedBox(height: 16.0),
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
        ),
      ),
    );
  }
}

/// A card that animates a box along a horizontal track using a spatial
/// [spring].
class _SpatialSpringCard extends StatefulWidget {
  const _SpatialSpringCard({
    required this.label,
    required this.spring,
    required this.target,
  });

  final String label;
  final SpringDescription spring;
  final double target;

  @override
  State<_SpatialSpringCard> createState() => _SpatialSpringCardState();
}

class _SpatialSpringCardState extends State<_SpatialSpringCard>
    with SingleTickerProviderStateMixin {
  // Unbounded so an underdamped spatial spring can overshoot the target slot
  // and bounce back into place.
  late final AnimationController _controller = AnimationController.unbounded(
    vsync: this,
    value: widget.target,
  );

  @override
  void didUpdateWidget(_SpatialSpringCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.target != oldWidget.target) {
      _controller.animateWith(
        SpringSimulation(
          widget.spring,
          _controller.value,
          widget.target,
          _controller.velocity,
          snapToEnd: true,
        ),
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
    final ColorScheme colors = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        child: Column(
          children: <Widget>[
            _CardHeader(label: widget.label, spring: widget.spring),
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  const double puckSize = 44.0;
                  const double trackInset = 32.0;
                  final double travel = math.max(
                    0.0,
                    constraints.maxWidth - puckSize - trackInset * 2,
                  );
                  final double top = (constraints.maxHeight - puckSize) / 2;
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (BuildContext context, Widget? child) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          Positioned(
                            left: trackInset - 6.0,
                            right: trackInset - 6.0,
                            top: top - 6.0,
                            height: puckSize + 12.0,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: trackInset,
                            top: top,
                            width: puckSize,
                            height: puckSize,
                            child: _TargetSlot(color: colors.outlineVariant),
                          ),
                          Positioned(
                            left: trackInset + travel,
                            top: top,
                            width: puckSize,
                            height: puckSize,
                            child: _TargetSlot(color: colors.outlineVariant),
                          ),
                          Positioned(
                            left: trackInset + _controller.value * travel,
                            top: top,
                            width: puckSize,
                            height: puckSize,
                            child: child!,
                          ),
                        ],
                      );
                    },
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(14.0),
                        ),
                      ),
                      child: Icon(Icons.star_rounded, color: colors.onPrimary),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetSlot extends StatelessWidget {
  const _TargetSlot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(14.0)),
        border: Border.all(color: color),
      ),
    );
  }
}

/// A card that animates the color of a stationary swatch using an effects
/// [spring].
class _EffectsSpringCard extends StatefulWidget {
  const _EffectsSpringCard({
    required this.label,
    required this.spring,
    required this.target,
  });

  final String label;
  final SpringDescription spring;
  final double target;

  @override
  State<_EffectsSpringCard> createState() => _EffectsSpringCardState();
}

class _EffectsSpringCardState extends State<_EffectsSpringCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController.unbounded(
    vsync: this,
    value: widget.target,
  );

  @override
  void didUpdateWidget(_EffectsSpringCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.target != oldWidget.target) {
      _controller.animateWith(
        SpringSimulation(
          widget.spring,
          _controller.value,
          widget.target,
          _controller.velocity,
          snapToEnd: true,
        ),
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
    final ColorScheme colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          children: <Widget>[
            _CardHeader(label: widget.label, spring: widget.spring),
            const SizedBox(height: 8.0),
            Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget? child) {
                  final double t = _controller.value.clamp(0.0, 1.0);
                  return SizedBox.expand(
                    child: DecoratedBox(
                      key: ValueKey<String>('effects-swatch-${widget.label}'),
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          colors.surfaceContainerHighest,
                          colors.primary,
                          t,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(14.0),
                        ),
                        border: Border.all(
                          color: Color.lerp(
                            colors.outlineVariant,
                            colors.primary,
                            t,
                          )!,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: Color.lerp(
                            colors.onSurfaceVariant.withValues(alpha: 0.45),
                            colors.onPrimary,
                            t,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.label, required this.spring});

  final String label;
  final SpringDescription spring;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12.0,
        runSpacing: 4.0,
        children: <Widget>[
          Text(label, style: theme.textTheme.titleMedium),
          Text(
            _describe(spring),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
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
