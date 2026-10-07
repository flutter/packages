// Copyright 2024-2025 Tim Lehmann for whynotmake.it
//
// SPDX-License-Identifier: MIT
//
// Originally from liquid_glass_renderer (whynotmake.it).
// Maintained and evolved in-tree for liquid_glass_widgets.
// See lib/src/engine/ATTRIBUTION.md for provenance and modification history.

// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import '../../types/interaction_notification.dart';

class GlassDragBuilder extends StatefulWidget {
  const GlassDragBuilder({
    required this.builder,
    this.behavior = HitTestBehavior.opaque,
    this.suppressInteractionOnChildren = true,
    this.child,
    super.key,
  });

  final HitTestBehavior behavior;
  final bool suppressInteractionOnChildren;
  final ValueWidgetBuilder<Offset?> builder;
  final Widget? child;

  @override
  State<GlassDragBuilder> createState() => _GlassDragBuilderState();
}

class _GlassDragBuilderState extends State<GlassDragBuilder> {
  // ─── Touch-noise & drag architecture ──────────────────────────────────────
  //
  // 1. LATCHED DEADBAND (_kTouchSlopPx)
  //    Capacitive digitizers emit small sub-pixel deltas (~0.3–1.5 px) even
  //    when a finger is held stationary. While within the 3.0 px threshold,
  //    we accumulate deltas silently without calling setState. This guarantees
  //    ZERO rebuilds and ZERO matrix recalibration during a hold press,
  //    eliminating all raster crawl on crisp hairline borders (_VibrancyFill).
  //
  // 2. CONTINUOUS SLOP SUBTRACTION (C⁰ Position Continuity)
  //    Once |_rawOffset| >= _kTouchSlopPx, the drag state is latched
  //    (_dragEngaged = true). Rather than jumping by 3.0 px (which would impart
  //    an impulse kick into the spring simulation), the exposed offset is
  //    slop-subtracted along the drag vector:
  //
  //      exposed = raw * (1.0 - slop / dist)
  //
  //    At the engagement threshold (dist == slop), exposed == Offset.zero.
  //    The drag begins with zero jump and zero velocity discontinuity.
  //
  // 3. ZERO QUANTIZATION (No Stairstep Stutter)
  //    We do NOT drop or quantize movement updates to coarse steps (e.g. 0.5px).
  //    Discrete quantization injects high-frequency noise that excites the
  //    spring's resonance frequency. Instead, continuous deltas are fed
  //    directly to the spring controller, allowing Flutter's physics engine to
  //    act as a natural 2nd-order analog low-pass filter at full display refresh.

  static const double _kTouchSlopPx = 3.0;

  // Cumulative raw offset since pointer down. Null when no pointer is down.
  Offset? _rawOffset;

  // Latched flag indicating whether the deadband has been broken.
  bool _dragEngaged = false;

  // Last offset exposed to widget.builder via setState.
  Offset? _lastExposedOffset;

  bool _shouldIgnoreCurrentPointer = false;

  bool get isDragging => _rawOffset != null;

  /// Computes the exposed offset with continuous slop subtraction.
  ///
  /// Returns:
  /// - `null`: Pointer is up/cancelled (spring settles to rest).
  /// - `Offset.zero`: Pointer is down but deadband has not been broken.
  /// - `raw * (1 - slop / dist)`: Continuous tracking once engaged.
  Offset? get _exposedOffset {
    final raw = _rawOffset;
    if (raw == null) return null;
    if (!_dragEngaged) return Offset.zero;

    final dist = raw.distance;
    if (dist <= _kTouchSlopPx) {
      return Offset.zero;
    }
    final factor = 1.0 - (_kTouchSlopPx / dist);
    return raw * factor;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<InteractionNotification>(
      onNotification: (notification) {
        if (widget.suppressInteractionOnChildren) {
          _shouldIgnoreCurrentPointer = true;
        }
        return false; // Let it bubble
      },
      child: Listener(
        behavior: widget.behavior,
        onPointerDown: (event) {
          if (widget.suppressInteractionOnChildren &&
              _shouldIgnoreCurrentPointer) {
            _shouldIgnoreCurrentPointer = false;
            return;
          }
          if (!mounted) return;
          setState(() {
            _dragEngaged = false;
            _rawOffset = Offset.zero;
            _lastExposedOffset = Offset.zero;
          });
        },
        onPointerMove: (event) {
          if (_rawOffset == null) return;
          if (!mounted) return;

          final newRaw = _rawOffset! + event.delta;
          _rawOffset = newRaw;

          if (!_dragEngaged) {
            if (newRaw.distanceSquared >= _kTouchSlopPx * _kTouchSlopPx) {
              _dragEngaged = true;
            } else {
              // Within deadband: exposed value remains Offset.zero.
              // Bypass setState to avoid any redundant rebuilds or raster crawl.
              return;
            }
          }

          final exposed = _exposedOffset;
          if (exposed == _lastExposedOffset) return;

          setState(() {
            _lastExposedOffset = exposed;
          });
        },
        onPointerUp: (event) {
          _shouldIgnoreCurrentPointer = false;
          if (!mounted) return;
          setState(() {
            _dragEngaged = false;
            _rawOffset = null;
            _lastExposedOffset = null;
          });
        },
        onPointerCancel: (event) {
          _shouldIgnoreCurrentPointer = false;
          if (!mounted) return;
          setState(() {
            _dragEngaged = false;
            _rawOffset = null;
            _lastExposedOffset = null;
          });
        },
        child: widget.builder(context, _exposedOffset, widget.child),
      ),
    );
  }
}
