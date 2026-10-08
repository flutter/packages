// Copyright 2024-2025 Tim Lehmann for whynotmake.it
//
// SPDX-License-Identifier: MIT
//
// Originally from liquid_glass_renderer (whynotmake.it).
// Maintained and evolved in-tree for liquid_glass_widgets.
// See lib/src/engine/ATTRIBUTION.md for provenance and modification history.

// ignore_for_file: public_member_api_docs

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

mixin TransformTrackingRepaintBoundaryMixin on RenderProxyBox {
  @override
  GeometryTransformTrackingLayer? get layer =>
      super.layer as GeometryTransformTrackingLayer?;

  @override
  bool get isRepaintBoundary => true;

  @override
  OffsetLayer updateCompositedLayer({
    covariant GeometryTransformTrackingLayer? oldLayer,
  }) {
    final layer = oldLayer ??= GeometryTransformTrackingLayer();

    // ignore: cascade_invocations
    layer
      ..renderObject = this
      ..onTransformChanged = () {
        if (attached) {
          onTransformChanged();
        }
      };

    return layer;
  }

  @mustCallSuper
  @override
  void paint(PaintingContext context, ui.Offset offset) {
    layer!.offset = offset;
    super.paint(context, offset);
  }

  void onTransformChanged();
}

mixin TransformTrackingRenderObjectMixin on RenderProxyBox {
  @override
  GeometryTransformTrackingLayer? get layer =>
      super.layer as GeometryTransformTrackingLayer?;

  @override
  @nonVirtual
  bool get isRepaintBoundary => false;

  @override
  bool get alwaysNeedsCompositing => true;

  @mustCallSuper
  @override
  void paint(PaintingContext context, ui.Offset offset) {
    setUpLayer(offset);
    context.pushLayer(layer!, (context, offset) {}, offset);
    super.paint(context, offset);
  }

  GeometryTransformTrackingLayer setUpLayer(Offset offset) {
    // ignore: unnecessary_this
    return (this.layer ??= GeometryTransformTrackingLayer())
      ..renderObject = this
      ..onTransformChanged = () {
        if (attached) {
          onTransformChanged();
        }
      };
  }

  void onTransformChanged();
}

class GeometryTransformTrackingLayer extends OffsetLayer {
  GeometryTransformTrackingLayer();

  RenderObject? renderObject;
  VoidCallback? onTransformChanged;
  Matrix4? _lastTransform;

  @override
  bool get alwaysNeedsAddToScene => true;

  @override
  void addToScene(ui.SceneBuilder builder) {
    if (renderObject == null || !renderObject!.attached) return;
    Matrix4? currentTransform;
    try {
      currentTransform = renderObject!.getTransformTo(null);
    } catch (_) {
      return;
    }
    if (!MatrixUtils.matrixEquals(currentTransform, _lastTransform)) {
      // Don't trigger onTransformChanged on the very first frame (when _lastTransform is null).
      // The render object just painted itself, so it is already up to date. Triggering it
      // here would needlessly dirty the render tree and force a second frame to render.
      if (_lastTransform != null) {
        _notifyTransformChanged();
      }
      _lastTransform = currentTransform;
    }
  }

  /// Runs [onTransformChanged] at a point where dirtying the render tree
  /// actually schedules a frame.
  ///
  /// [addToScene] is called while the current frame is being composited
  /// (`SchedulerPhase.persistentCallbacks`), and every [onTransformChanged]
  /// implementation ends in `markNeedsPaint`. From inside a frame that sets
  /// `_needsPaint` up to the nearest repaint boundary but
  /// `ensureVisualUpdate` schedules nothing; the next change in that subtree
  /// (a scroll step, say) then returns early from `markNeedsPaint` because
  /// the flag is already set, and no frame is requested until something
  /// unrelated asks for one. On a page whose scrolled content holds glass,
  /// a slow finger drag froze that way and jumped on release (flings were
  /// fine only because their ticker kept requesting frames; accessibility
  /// masks it too, since `markNeedsSemanticsUpdate` requests a frame of its
  /// own). A post-frame callback runs in `SchedulerPhase.postFrameCallbacks`,
  /// where `markNeedsPaint` does schedule the frame. Outside a frame (an
  /// `OffsetLayer.toImage` snapshot) the callback is safe to run directly.
  void _notifyTransformChanged() {
    final callback = onTransformChanged;
    if (callback == null) return;
    final binding = SchedulerBinding.instance;
    if (binding.schedulerPhase
        case SchedulerPhase.idle || SchedulerPhase.postFrameCallbacks) {
      callback();
    } else {
      binding.addPostFrameCallback((_) => onTransformChanged?.call());
    }
  }
}
