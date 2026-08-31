// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// #region body
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';
import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [MaterialShapes].

void main() {
  runApp(const MaterialShapesExampleApp());
}

class MaterialShapesExampleApp extends StatelessWidget {
  const MaterialShapesExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorSchemeSeed: const Color(0xFF6750A4)),
      home: MaterialShapesExample(),
    );
  }
}

class MaterialShapesExample extends StatefulWidget {
  const MaterialShapesExample({super.key});

  @override
  State<MaterialShapesExample> createState() => _MaterialShapesExampleState();
}

class _MaterialShapesExampleState extends State<MaterialShapesExample>
    with SingleTickerProviderStateMixin {
  /// The shapes to morph through, in the order they are listed in
  /// [MaterialShapes.all].
  static final List<RoundedPolygon> _shapes = MaterialShapes.all;

  /// A [Morph] from each shape in [_shapes] to the next one, wrapping around
  /// from the last shape back to the first.
  ///
  /// These are built up front because a [Morph] computes the mapping between
  /// its two shapes when it is constructed.
  late final List<Morph> _morphs;

  /// The morph that is currently animating.
  late final ValueNotifier<Morph> _morph;

  /// Drives the progress of [_morph].
  ///
  /// The controller is unbounded so that the springs below can overshoot past a
  /// progress of 1, which carries the morph slightly beyond its end shape.
  late final AnimationController _controller;

  int _morphIndex = 0;

  Timer? _startTimer;

  final _bouncySimulation = SpringSimulation(
    SpringDescription.withDampingRatio(ratio: 0.5, stiffness: 400, mass: 1),
    0,
    1,
    5,
    snapToEnd: true,
  );

  // Overshooting past a progress of 1 extrapolates a morph beyond its end
  // shape, which distorts the heart into sharp spikes. The heart therefore
  // animates with a spring that starts at rest and barely overshoots.
  final _lessBouncySimulation = SpringSimulation(
    SpringDescription.withDampingRatio(ratio: 0.8, stiffness: 300, mass: 1),
    0,
    1,
    0,
    snapToEnd: true,
  );

  /// The shape that the currently animating morph ends on.
  RoundedPolygon get _targetShape =>
      _shapes[(_morphIndex + 1) % _shapes.length];

  @override
  void initState() {
    super.initState();

    _morphs = <Morph>[
      for (var i = 0; i < _shapes.length; i++)
        Morph(_shapes[i], _shapes[(i + 1) % _shapes.length]),
    ];
    _morph = ValueNotifier<Morph>(_morphs.first);
    _controller = AnimationController.unbounded(vsync: this);

    // Hold the first shape for a moment so that it can be seen before it starts
    // morphing.
    _startTimer = Timer(const Duration(seconds: 1), _morphThroughShapes);
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller.dispose();
    _morph.dispose();
    super.dispose();
  }

  /// Animates the morphs in [_morphs] one after another, looping back to the
  /// first one after the last, until this widget is disposed.
  ///
  /// Waiting for each spring to settle, rather than advancing on a fixed
  /// interval, keeps a morph from being cut short and popping to the next
  /// shape.
  Future<void> _morphThroughShapes() async {
    while (mounted) {
      _morph.value = _morphs[_morphIndex];
      _controller.value = 0;
      await _controller.animateWith(
        _targetShape == MaterialShapes.heart
            ? _lessBouncySimulation
            : _bouncySimulation,
      );
      _morphIndex = (_morphIndex + 1) % _morphs.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Material Shapes Sample')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300, maxHeight: 300),
          child: AspectRatio(
            aspectRatio: 1,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _MorphPainter(
                  morph: _morph,
                  progress: _controller,
                  color: Theme.of(context).colorScheme.primary,
                ),
                willChange: true,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MorphPainter extends CustomPainter {
  _MorphPainter({
    required this.morph,
    required this.progress,
    required this.color,
  }) : super(repaint: Listenable.merge(<Listenable>[morph, progress]));

  final ValueListenable<Morph> morph;

  final Animation<double> progress;

  final Color color;

  late final Paint _paint = Paint()
    ..style = .fill
    ..color = color;

  @override
  void paint(Canvas canvas, Size size) {
    // Every shape in MaterialShapes is normalized, so its path fits in a one by
    // one square that has to be scaled up to the size being painted.
    canvas
      ..save()
      ..scale(size.width)
      ..drawPath(morph.value.toPath(progress.value), _paint)
      ..restore();
  }

  @override
  bool shouldRepaint(_MorphPainter oldDelegate) {
    return oldDelegate.morph != morph ||
        oldDelegate.progress != progress ||
        oldDelegate.color != color;
  }
}
// #endregion body
