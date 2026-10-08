// Shared drag gesture state and handlers for bottom bar tab indicators.
//
// Eliminates duplication between [TabIndicatorState] and
// [SearchableTabIndicatorState]. Both had identical state fields, coordinate
// helpers, and gesture handlers — causing the same bugs (issue #22, #23) to
// exist in two places.
//
// NOT part of the public API — do not export from liquid_glass_widgets.dart.

import 'package:flutter/scheduler.dart' show SchedulerBinding, SchedulerPhase;
import 'package:flutter/widgets.dart';

import '../../../utils/draggable_indicator_physics.dart';

/// Shared drag gesture state and handlers for bottom bar indicators.
///
/// Apply to a [State] subclass with `with TabDragGestureMixin<MyWidget>`.
/// Implement the three abstract getters to wire up the mixin.
///
/// Exposes handler methods that map directly to [GestureDetector] callbacks:
/// - [onBarDragDown] → `onHorizontalDragDown`
/// - [onBarDragStart] → `onHorizontalDragStart`
/// - [onBarDragUpdate] → `onHorizontalDragUpdate`
/// - [onBarDragEnd] → `onHorizontalDragEnd`
/// - [onBarDragCancel] → `onHorizontalDragCancel`
/// - [onBarTapDown] → `onTapDown`
///
/// And raw-Listener helpers (call from [Listener] in the concrete build method):
/// - [onBarPointerDown] → `onPointerDown`
/// - [onBarPointerUp] → `onPointerUp`
/// - [onBarPointerCancel] → `onPointerCancel`
mixin TabDragGestureMixin<T extends StatefulWidget> on State<T> {
  // ── Abstract interface ────────────────────────────────────────────────────

  /// Total number of tabs.
  int get tabCount;

  /// Index of the currently selected tab.
  int get tabIndex;

  /// Whether this tab bar is floating over a PlatformView (enables hybrid gesture mode).
  bool get isPlatformViewBackdrop;

  /// Called once per gesture lifecycle when the active tab should change.
  ///
  /// Always invoked unconditionally — callers may use repeat-tap to trigger
  /// scroll-to-top or refresh on the active tab (issue #22).
  void notifyTabChanged(int index);

  // ── Shared state ──────────────────────────────────────────────────────────

  /// Stores the target tab index during a hybrid tap (platform view backdrop).
  int? _pendingHybridTabIndex;

  /// True while the pointer is physically held down.
  ///
  /// Drives jelly thickness animation. Set by [onBarDragDown] and also by
  /// the raw [Listener] in the concrete class's build method.
  bool tabIsDown = false;

  /// True while a horizontal drag gesture is in progress.
  bool tabIsDragging = false;

  /// Bumped to force the interactive [GestureDetector] — and its underlying
  /// framework gesture recognizer — to be torn down and recreated. Used by
  /// [recoverIfGestureStuck] to clear a recognizer left wedged after a dropped
  /// terminal callback.
  int gestureEpoch = 0;

  /// True from [onBarPointerDown] until a terminal callback ([onBarDragEnd],
  /// [onBarDragCancel], [onBarPointerUp], or [onBarPointerCancel]) runs.
  ///
  /// If still set when a new pointer-down arrives, the previous gesture's
  /// terminal callback was dropped (PlatformView / system-gesture arena race).
  bool _gestureActive = false;

  /// Uniquely identifies the current gesture lifecycle.
  /// Incremented on every new pointer down to prevent deferred callbacks
  /// (from rapid clicking) from corrupting the state of a new gesture.
  int _gestureId = 0;

  /// Current horizontal alignment of the indicator in the range [-1, 1].
  double tabXAlign = 0.0;

  /// Lateral sway offset in logical pixels.
  ///
  /// Driven by horizontal drag velocity — gives the bar body a subtle
  /// physical response when the interactive pill is dragged left/right,
  /// mimicking iOS 26 bottom bar behaviour. Animated back to `0.0` via
  /// a spring when the drag ends or is cancelled.
  ///
  /// Maximum magnitude is clamped to [_maxSwayPx].
  double barSwayOffset = 0.0;

  /// Maximum lateral sway in logical pixels — keeps the effect subtle.
  static const double _maxSwayPx = 0.75;

  /// Scale factor mapping instantaneous drag delta to sway offset.
  static const double _swayScale = 0.08;

  /// Minimum drag delta magnitude (px/frame) required to trigger sway.
  /// Below this threshold the bar stays still — only fast flicks cause sway.
  static const double _swayVelocityThreshold = 4.0;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    tabXAlign = computeTabAlignment(tabIndex);
    WidgetsBinding.instance.pointerRouter.addGlobalRoute(_handleGlobalPointer);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.pointerRouter
        .removeGlobalRoute(_handleGlobalPointer);
    super.dispose();
  }

  /// Global pointer listener to catch dropped touches over PlatformViews.
  ///
  /// If the OS (e.g. iOS edge swipe) swallows a touch without dispatching a
  /// cancel event, the local Listener never sees it and the bar stays wedged.
  /// This global route listens to all touches in the app. If the user touches
  /// anywhere ELSE (e.g. the map), we forcefully flush the wedged state.
  void _handleGlobalPointer(PointerEvent event) {
    if (!mounted) return;
    if (event is PointerDownEvent) {
      final renderObject = context.findRenderObject();
      if (renderObject is RenderBox) {
        final positionInBox = renderObject.globalToLocal(event.position);
        if (renderObject.paintBounds.contains(positionInBox)) {
          // Touch is inside the tab bar. Let the local Listener handle it.
          // Doing cleanup here would instantly cancel legitimate click-and-holds.
          return;
        }
      }

      if (_gestureActive || tabIsDown || tabIsDragging) {
        setState(() {
          _gestureActive = false;
          tabIsDragging = false;
          tabIsDown = false;
          _pendingHybridTabIndex =
              null; // abort any in-flight hybrid tab switch
          _forceSnapToNearestTab();
          _gestureId++;
          gestureEpoch++; // The old gesture recognizer is hopelessly wedged, kill it.
        });
      }
    }
  }

  /// Instantly snaps the visual indicator to the nearest mathematically valid tab.
  /// Used during proactive cleanup when a previous gesture was forcefully aborted.
  void _forceSnapToNearestTab() {
    final relX = (tabXAlign + 1) / 2;
    final target = (relX * (tabCount - 1)).round().clamp(0, tabCount - 1);
    tabXAlign = computeTabAlignment(target);
    barSwayOffset = 0.0;
  }

  /// Settles the indicator back onto the host's tab when the host does not
  /// adopt a selection.
  ///
  /// A release commits the indicator's position locally and then reports the
  /// target through [notifyTabChanged]. A host is free to decline that: an
  /// action tab that opens a sheet, a guard that refuses navigation, a tab
  /// whose route fails to push. In those cases [tabIndex] never changes, so
  /// [updateTabAlignIfNeeded] has nothing to compare and the indicator is
  /// left parked on a tab that is not selected, with nothing to bring it
  /// back.
  ///
  /// Checked after the frame so the host has had its chance to adopt the
  /// index. When it did, this is a no-op.
  void reconcileWithHost(int target) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || tabIsDragging || tabIndex == target) return;
      setState(() => tabXAlign = computeTabAlignment(tabIndex));
    });
  }

  /// Call from [didUpdateWidget] when tabIndex or tabCount may have changed.
  void updateTabAlignIfNeeded(int oldTabIndex, int oldTabCount) {
    if (oldTabIndex != tabIndex || oldTabCount != tabCount) {
      if (mounted) setState(() => tabXAlign = computeTabAlignment(tabIndex));
    }
  }

  // ── Coordinate helpers ────────────────────────────────────────────────────

  /// Maps a tab index to horizontal alignment in [-1, 1].
  double computeTabAlignment(int index) =>
      DraggableIndicatorPhysics.computeAlignment(index, tabCount);

  /// Maps a global pointer position to alignment in [-1, 1] with rubber-band
  /// resistance applied at the edges.
  ///
  /// Use for **continuous drag tracking** where the indicator center must stay
  /// within its physical travel range (indicator-center physics).
  ///
  /// `mirrorForRtl: false` because [tabXAlign] is a physical coordinate
  /// (-1 is always the left edge) for every bar built on this mixin — the
  /// indicator is positioned with [Alignment], not [AlignmentDirectional], and
  /// RTL is carried by the reversed tab data. Mirroring the pointer here would
  /// flip a second time, so the pill travelled away from the finger and the
  /// release reported the mirror-image tab. It would also contradict
  /// [tabIndexFromGlobal], which never mirrors.
  double alignmentFromGlobal(Offset globalPosition) =>
      DraggableIndicatorPhysics.getAlignmentFromGlobalPosition(
        globalPosition,
        context,
        tabCount,
        mirrorForRtl: false,
      );

  /// Maps a global tap/pointer position to a tab index using the raw
  /// (un-remapped) position fraction.
  ///
  /// Unlike [alignmentFromGlobal], this does **not** apply the
  /// indicator-center padding/draggable-range remap — it divides the bar into
  /// [tabCount] equal slices and returns which slice contains the point.
  ///
  /// Use for **discrete tap-to-index conversions** (`onTapDown`, gesture
  /// recovery) where each tab's hit region should be an equal slice of the
  /// pill width. See issue #157.
  int tabIndexFromGlobal(Offset globalPosition) =>
      DraggableIndicatorPhysics.tabIndexFromGlobalPosition(
        globalPosition,
        context,
        tabCount,
      );

  // ── Gesture handlers ──────────────────────────────────────────────────────

  /// `onPointerDown` (raw Listener) — called before the gesture arena runs.
  ///
  /// Sets [_gestureActive] and [tabIsDown] immediately via the raw Listener
  /// (not waiting for [onBarDragDown]), so [recoverIfGestureStuck] has a valid
  /// signal even when the native recognizer intercepts before
  /// [onHorizontalDragDown] fires.
  ///
  /// If [_gestureActive] is already true, the previous gesture's terminal
  /// callback was dropped (PlatformView/system-gesture race). Visual state is
  /// cleared eagerly before accepting the new touch. [gestureEpoch] is NOT
  /// bumped here — disposing the [GestureDetector] mid-dispatch would lose the
  /// new pointer; the previous pointer's [onBarPointerUp]/[onBarPointerCancel]
  /// handles eviction.
  void onBarPointerDown(Offset position) {
    if (!mounted) return;
    setState(() {
      _gestureId++;
      _gestureActive = true;
      tabIsDown = true;
    });
  }

  /// `onPointerUp` (raw Listener) — called regardless of gesture arena result.
  ///
  /// Clears [tabIsDown] when not mid-drag, then calls [recoverIfGestureStuck]
  /// to handle the case where the [GestureDetector]'s terminal callback was
  /// dropped by a PlatformView arena race.
  void onBarPointerUp(Offset position) {
    if (!mounted) return;
    if (!tabIsDragging) setState(() => tabIsDown = false);
    recoverIfGestureStuck(position);
  }

  /// `onPointerCancel` (raw Listener) — called regardless of gesture arena result.
  ///
  /// Mirrors [onBarPointerUp]. The cancel event is delivered when the OS or a
  /// parent widget takes ownership of the pointer stream.
  void onBarPointerCancel(Offset position) {
    if (!mounted) return;
    if (!tabIsDragging) setState(() => tabIsDown = false);
    recoverIfGestureStuck(position);
  }

  /// `onHorizontalDragDown` — marks pointer as pressed for jelly activation.
  void onBarDragDown(DragDownDetails d) {
    if (!mounted) return;
    // _gestureActive and tabIsDown are set by the raw Listener in
    // onBarPointerDown, which reliably fires alongside this recognizer.
  }

  /// `onHorizontalDragStart` — drag confirmed; lock position to pointer.
  void onBarDragStart(DragStartDetails d) {
    if (!mounted) return;
    setState(() {
      tabIsDragging = true;
      tabXAlign = alignmentFromGlobal(d.globalPosition);
    });
  }

  /// `onHorizontalDragUpdate` — track pointer during drag.
  ///
  /// Also updates [barSwayOffset] based on instantaneous drag velocity,
  /// giving the bar a subtle lateral sway when the interactive pill is
  /// flicked quickly — mimicking iOS 26 bottom bar physics.
  ///
  /// Slow drags (below [_swayVelocityThreshold]) produce zero sway;
  /// only fast flicks cause the bar to shift.
  void onBarDragUpdate(DragUpdateDetails d) {
    if (!mounted) return;
    setState(() {
      tabIsDragging = true;
      tabXAlign = alignmentFromGlobal(d.globalPosition);
      // Velocity-gated lateral sway: only fast flicks cause movement.
      if (d.delta.dx.abs() > _swayVelocityThreshold) {
        barSwayOffset =
            (d.delta.dx * _swayScale).clamp(-_maxSwayPx, _maxSwayPx);
      } else {
        barSwayOffset = 0.0;
      }
    });
  }

  /// Applies a drag-resolution state change safely.
  ///
  /// [onBarDragEnd]/[onBarDragCancel] can be invoked synchronously while the
  /// element tree is locked — specifically when the indicator's
  /// [RawGestureDetector] is disposed mid-gesture as its subtree is torn down
  /// during a rebuild (the press-hold freeze observed at non-premium quality,
  /// where the fallback render path reparents the interactive subtree). In that
  /// window the [State] is still `mounted` but `setState()` is illegal, so
  /// calling it throws, the cancel cleanup aborts, and the drag state is left
  /// stuck (the bar freezes). Defer to the next frame when invoked during the
  /// build/finalize phase; a genuinely disposing State no-ops via `mounted`.
  void _applyDragResolution(VoidCallback body) {
    if (!mounted) return;
    final int capturedId = _gestureId;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted && _gestureId == capturedId) body();
      });
    } else {
      body();
    }
  }

  /// `onHorizontalDragEnd` — snap to target tab with velocity fling support.
  ///
  /// Uses the alignment-coordinate inverse formula (issue #23 fix):
  ///   `computeAlignment(i, n)` → `-1 + 2i/(n-1)`
  ///   inverse: `i = ((tabXAlign + 1) / 2) * (n - 1)`
  ///
  /// This corrects the coordinate-space mismatch that caused off-by-one
  /// snapping when the old `relX / (1/tabCount)` formula was used.
  /// Velocity fling is layered on top so a fast swipe carries the indicator
  /// past the nearest-position tab.
  void onBarDragEnd(DragEndDetails d) {
    final relX = (tabXAlign + 1) / 2;
    final positionIndex =
        (relX * (tabCount - 1)).round().clamp(0, tabCount - 1);

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) return;
    final box = renderObject;
    // Raw horizontal velocity as a fraction of bar width.
    var rawVelX = d.velocity.pixelsPerSecond.dx / box.size.width;

    const velocityThreshold = 0.5;
    int target = positionIndex;
    if (rawVelX > velocityThreshold && positionIndex < tabCount - 1) {
      target = positionIndex + 1;
    } else if (rawVelX < -velocityThreshold && positionIndex > 0) {
      target = positionIndex - 1;
    }

    _gestureActive = false;
    _applyDragResolution(() {
      setState(() {
        tabIsDragging = false;
        tabIsDown = false;
        tabXAlign = computeTabAlignment(target);
        barSwayOffset = 0.0; // spring back to center
      });
      notifyTabChanged(target);
      reconcileWithHost(target);
    });
  }

  /// `onHorizontalDragCancel` — snap to nearest tab without velocity.
  void onBarDragCancel() {
    _gestureActive = false;
    if (tabIsDragging) {
      final relX = (tabXAlign + 1) / 2;
      final target = (relX * (tabCount - 1)).round().clamp(0, tabCount - 1);
      _applyDragResolution(() {
        setState(() {
          tabIsDragging = false;
          tabIsDown = false;
          tabXAlign = computeTabAlignment(target);
          barSwayOffset = 0.0; // spring back to center
        });
        notifyTabChanged(target);
        reconcileWithHost(target);
      });
    } else {
      // Not dragging (e.g. same-tab tap): reset indicator to exact tab center.
      _applyDragResolution(() {
        setState(() {
          tabIsDown = false;
          tabXAlign = computeTabAlignment(tabIndex);
        });
      });
    }
  }

  /// `onTapDown` — selects tab instantly, or animates indicator in hybrid mode.
  ///
  /// DX1: [tabIsDown] is already set on the same frame as the touch by the
  /// raw Listener ([onBarPointerDown]), keeping jelly visible on desktop taps.
  ///
  /// Uses [tabIndexFromGlobal] (raw fraction, equal slices) rather than the
  /// drag-physics [alignmentFromGlobal] remap to ensure each tab's hit region
  /// matches its visual region exactly. See issue #157.
  void onBarTapDown(TapDownDetails d) {
    final index = tabIndexFromGlobal(d.globalPosition);

    if (isPlatformViewBackdrop) {
      // Hybrid mode: instantly slide the visual indicator for native responsiveness,
      // but delay the actual content swap (PlatformView unmount) until onTapUp
      // to prevent iOS mid-gesture touch drops.
      setState(() {
        tabXAlign = computeTabAlignment(index);
        _pendingHybridTabIndex = index;
      });
    } else {
      // Standard native behavior: swap everything instantly on down.
      notifyTabChanged(index);
    }
  }

  /// `onTapUp` — clears active state and resolves hybrid tab changes.
  void onBarTapUp(TapUpDetails d) {
    if (!mounted) return;
    setState(() {
      _gestureActive = false;
      tabIsDown = false;
    });

    if (isPlatformViewBackdrop && _pendingHybridTabIndex != null) {
      final target = _pendingHybridTabIndex!;
      notifyTabChanged(target);
      _pendingHybridTabIndex = null;
      reconcileWithHost(target);
    }
  }

  /// `onTapCancel` — clears visual press state if the tap loses the gesture arena.
  void onBarTapCancel() {
    if (!mounted) return;
    _pendingHybridTabIndex = null;
    if (!tabIsDragging) {
      _applyDragResolution(() {
        setState(() => tabIsDown = false);
      });
    }
  }

  /// Safety net for a dropped gesture terminal callback while the bar floats
  /// over an iOS PlatformView.
  ///
  /// Over a PlatformView (e.g. a map), an interactive Flutter widget's gesture
  /// recognizer can have its terminal callback dropped in a race with the
  /// platform view's native gesture handling — a long-standing iOS
  /// PlatformView gesture-arena limitation, reproducible with this indicator
  /// dragged/tapped over a Mapbox map. The recognizer is then left wedged with
  /// [_gestureActive] still set and the bar stops receiving touches until
  /// something disposes it. Two signatures: `down` with no `onCancel` (a tap)
  /// and `START` with no `onEnd` (a drag).
  ///
  /// Called from [onBarPointerUp] / [onBarPointerCancel]. If a gesture is
  /// still flagged active on the next frame (its real terminal callback never
  /// ran), disposes the wedged recognizer via [gestureEpoch] and selects the
  /// tab under the lift point.
  ///
  /// We resolve to [upPosition], never [tabXAlign]: a gesture that wedged
  /// mid-drag stops reporting finger movement, so [tabXAlign] is frozen at the
  /// press point and would snap the user back to where they started. The lift
  /// point is the only trustworthy signal for where they actually intended to
  /// go.
  ///
  /// After notifying the host, [reconcileWithHost] is called so that a host
  /// that declines the recovered selection (e.g. a navigation guard, an action
  /// tab) springs the indicator back to its actual tab rather than leaving it
  /// parked on the tab under the lift point.
  void recoverIfGestureStuck(Offset upPosition) {
    if (!_gestureActive) return;
    final int capturedId = _gestureId;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_gestureActive || _gestureId != capturedId) return;
      // Use raw-fraction index (not drag-physics remap) so the recovery
      // target matches the visual tab that was under the lift point. (#157)
      final target = tabIndexFromGlobal(upPosition);
      setState(() {
        _gestureActive = false;
        tabIsDragging = false;
        tabIsDown = false;
        tabXAlign = computeTabAlignment(target);
        barSwayOffset = 0.0;
        gestureEpoch++; // dispose the wedged recognizer
      });
      notifyTabChanged(target);
      reconcileWithHost(target);
    });
  }
}
