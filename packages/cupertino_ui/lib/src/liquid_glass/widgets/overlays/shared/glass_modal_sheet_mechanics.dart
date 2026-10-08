part of '../glass_modal_sheet.dart';

// ===========================================================================
// Sheet States & Modes
// ===========================================================================

/// Progress toward the topmost detent past which the sheet counts as being at
/// it. The content's physics unlock here, and the gesture handover uses the
/// same line so the two can never disagree about who owns a drag.
const double _kTopDetentThreshold = 0.95;

/// The discrete snap positions a [GlassModalSheet] can occupy.
enum GlassSheetState {
  /// Sheet is fully offscreen — invisible and not interactable.
  hidden,

  /// Sheet shows only a small peek strip at the bottom of the screen.
  ///
  /// Acts as the resting floor for [GlassSheetMode.persistent] sheets.
  peek,

  /// Sheet is at its medium-height glass stop (roughly half the screen).
  half,

  /// Sheet covers the full screen and transitions to an opaque solid color.
  full,
}

/// The resting heights a sheet may stop at, chosen via
/// [GlassModalSheet.detents]. Mirrors UIKit's sheet detents:
///
///   • [medium] — the content-height, translucent-glass stop (Apple Pay /
///     Sign in with Apple). Maps to [GlassSheetState.half] internally.
///   • [large]  — the screen-height, opaque stop (Maps / Music). Maps to
///     [GlassSheetState.full].
///
/// A sheet declares any non-empty subset: `{medium}` is half-only glass,
/// `{large}` is full-only opaque, `{medium, large}` is the default two-stop
/// sheet, and adding [small] puts a peek floor underneath.
///
/// [small] is the maps-style resting floor — the state a persistent sheet
/// returns to instead of dismissing. Its styling lives in the top-level
/// `peek*` params ([GlassModalSheet.peekSettings], `peekWidth`, …) rather
/// than on the detent itself, deliberately: a `Set` whose members carried
/// per-instance payload would need equality that IGNORES that payload, or
/// `detents.contains(small)` stops working and two smalls with different
/// settings could sit in one set at once. Keeping the detent a plain enum
/// keeps set membership meaning exactly one thing.
enum GlassSheetDetent {
  /// The peek-floor detent — a small strip at the bottom edge, maps to [GlassSheetState.peek].
  small,

  /// The medium-height glass detent — typically 45% of screen height, maps to [GlassSheetState.half].
  medium,

  /// The full-screen detent — covers the screen and uses a solid fill, maps to [GlassSheetState.full].
  large,
}

/// Controls whether the sheet can be swiped to dismiss or must stay docked.
enum GlassSheetMode {
  /// Scenario 1: hidden ↔ half ↔ full
  /// Can swipe down from half to hidden. From full → half → hidden.
  dismissible,

  /// Scenario 2: peek ↔ half ↔ full
  /// peek is the minimum state, cannot be hidden.
  /// Swiping down from half returns to peek, not hidden.
  persistent,
}

/// Where a sheet sits across a screen with room on either side of it.
///
/// Mirrors SwiftUI's `presentationPlacement(_:)`. Only iPhone Duo's inner
/// display has that room today: in its vertical bar strip layout
/// ([GlassVerticalBar]) a sheet in a regular width is a card as wide as the
/// display's shorter side less its margins — 653pt on the inner display in
/// landscape — and this decides where the card sits. Everywhere else a sheet
/// spans the width, the outer display in landscape included, and this is not
/// read.
enum GlassSheetPlacement {
  /// The system decides: the card is centred, as natively.
  automatic,

  /// The card is centred on the screen.
  center,

  /// The card sits against the leading edge.
  leading,

  /// The card sits against the trailing edge.
  ///
  /// Where the strip is on that side the card covers it, and the sheet's own
  /// bar moves into the strip — the one placement on the inner display whose
  /// toolbar goes vertical, as natively.
  trailing,
}

/// The sheet's insets from the left and right edges of the screen in iPhone
/// Duo's vertical bar strip layout.
///
/// Natively a sheet there keeps [margin] from each side, 8pt. In a
/// [regularWidth] it is no wider than the display's shorter side less those
/// margins, and [placement] positions it across whatever width is left; in a
/// compact one it spans the width.
EdgeInsets _stripSheetInsets({
  required Size screenSize,
  required bool regularWidth,
  required double margin,
  required GlassSheetPlacement placement,
  required TextDirection textDirection,
}) {
  final spare = regularWidth
      ? math.max(0.0, screenSize.width - screenSize.shortestSide)
      : 0.0;
  final leadingShare = switch (placement) {
    GlassSheetPlacement.automatic || GlassSheetPlacement.center => 0.5,
    GlassSheetPlacement.leading => 0.0,
    GlassSheetPlacement.trailing => 1.0,
  };
  final left = spare *
      (textDirection == TextDirection.ltr ? leadingShare : 1.0 - leadingShare);
  return EdgeInsets.only(left: margin + left, right: margin + spare - left);
}

/// Distance from the top of the screen to a sheet's top edge at its large
/// detent in iPhone Duo's vertical bar strip layout.
///
/// The status bar is in the strip there, so natively the sheet rises to 8pt
/// from the top rather than stopping below the status bar.
const double _kStripSheetTop = 8.0;

/// Distance from a sheet's top and leading edges to the title row of its own
/// bar in iPhone Duo's vertical bar strip layout, as natively.
const double _kStripSheetRowInset = 16.0;

/// The strip a sheet's own bar lays out in, or null where its bar stays
/// horizontal.
///
/// Natively a sheet takes the strip's place when it covers the strip: on the
/// outer display always, and on the inner display at
/// [GlassSheetPlacement.trailing]. Its bar then stacks down the sheet's own
/// strip, which lies over the screen's, and keeps its title in a row at the
/// sheet's top-leading corner. The first control stays clear of the status
/// cluster at the top of the screen's strip, and otherwise starts level with
/// the title row — at a medium detent, say. A centred or leading card keeps a
/// horizontal bar.
///
/// [frame] is the sheet at rest, in screen coordinates.
GlassVerticalBarData? _sheetVerticalBar({
  required GlassVerticalBarData? bar,
  required Rect frame,
  required Size screenSize,
  required TextDirection textDirection,
}) {
  if (bar == null) return null;
  final stripOnRight = (bar.edge == GlassVerticalBarEdge.trailing) ==
      (textDirection == TextDirection.ltr);
  // The sheet's edge on the strip's side, as a distance from the strip's
  // inner edge.
  final reach = stripOnRight
      ? frame.right - (screenSize.width - bar.width)
      : bar.width - frame.left;
  if (reach <
      GlassVerticalBarMetrics.inset + GlassVerticalBarMetrics.controlExtent) {
    return null;
  }
  return GlassVerticalBarData(
    edge: bar.edge,
    width: reach,
    top: math.max(bar.top - frame.top, _kStripSheetRowInset),
    bottom: bar.bottom,
    collapsesTabBar: bar.collapsesTabBar,
    rowTop: _kStripSheetRowInset,
    titleInset: _kStripSheetRowInset,
  );
}

/// Controls how the sheet transitions from its glass look to a solid color
/// as it expands toward [GlassSheetState.full].
enum GlassFillTransition {
  /// Gradual transition through gradient (current behavior)
  gradual,

  /// Instant color change after reaching threshold
  instant,
}

// ===========================================================================
// SheetStateMachine — isolated state machine
// ===========================================================================

/// Immutable snapshot of the sheet's physical state at a single moment in time.
///
/// Passed to the sheet's gesture resolver and state machine to determine
/// target snap positions and resistance.
class SheetSnapshot {
  /// The current logical snap state (which detent the sheet was last snapped to).
  final GlassSheetState state;

  /// Sheet height as a fraction of screen height (0.0 = hidden, 1.0 = full screen).
  final double position;

  /// Current drag velocity in logical pixels per second.
  /// Positive values mean the sheet is moving upward (expanding).
  final double velocity;

  /// The screen dimensions at the time this snapshot was captured.
  final Size screenSize;

  /// Creates an immutable sheet state snapshot.
  const SheetSnapshot({
    required this.state,
    required this.position,
    this.velocity = 0.0,
    required this.screenSize,
  });

  /// Returns a copy of this snapshot with the given fields replaced.
  SheetSnapshot copyWith({
    GlassSheetState? state,
    double? position,
    double? velocity,
    Size? screenSize,
  }) =>
      SheetSnapshot(
        state: state ?? this.state,
        position: position ?? this.position,
        velocity: velocity ?? this.velocity,
        screenSize: screenSize ?? this.screenSize,
      );

  /// Normalized progress between the half and full snap positions.
  ///
  /// Returns 0.0 when at or below the half detent, and 1.0 when at the full
  /// detent. Used to drive the glass-to-solid color crossfade.
  double get expandProgress {
    final halfPos =
        SheetGeometry.positionFor(GlassSheetState.half, screenSize.height);
    final fullPos =
        SheetGeometry.positionFor(GlassSheetState.full, screenSize.height);
    if (fullPos <= halfPos) return 0.0;
    return ((position - halfPos) / (fullPos - halfPos)).clamp(0.0, 1.0);
  }

  @override
  String toString() =>
      'SheetSnapshot(state: $state, pos: ${position.toStringAsFixed(4)}, vel: ${velocity.toStringAsFixed(1)})';
}

/// Pure geometry calculations for sheet snap positions — no [BuildContext], no side effects.
///
/// Encapsulates which detents are active, their physical positions, and the
/// logic for resolving snap targets and rubber-band resistance. Fully testable
/// without a widget tree.
class SheetGeometry {
  /// The dismissal mode (dismissible vs persistent floor).
  final GlassSheetMode mode;

  /// Height of the [GlassSheetState.half] detent in logical pixels (> 1.0)
  /// or as a screen-height fraction (≤ 1.0).
  final double halfSize;

  /// Optional explicit height for the [GlassSheetState.full] detent.
  /// When null, defaults to `screenHeight - 90.0`.
  final double? fullSize;

  /// Height of the [GlassSheetState.peek] floor detent.
  final double peekSize;

  /// Whether the peek floor detent is active.
  final bool enablePeek;

  /// Whether the half-height detent is active.
  final bool enableHalf;

  /// Whether the full-screen detent is active.
  final bool enableFull;

  /// Whether the sheet can be dragged below its lowest detent to dismiss.
  final bool dismissible;

  /// Creates a sheet geometry configuration.
  const SheetGeometry({
    required this.mode,
    required this.halfSize,
    this.fullSize,
    required this.peekSize,
    this.enablePeek = true,
    this.enableHalf = true,
    this.enableFull = true,
    this.dismissible = true,
  });

  /// Resolve whether the peek floor is active, from the public API's detents
  /// and mode.
  ///
  /// The peek floor is active when:
  ///   1. [GlassSheetDetent.small] is in [detents].
  ///   2. [GlassSheetMode.persistent] is active (a persistent sheet is DEFINED
  ///      by resting on a floor instead of dismissing).
  static bool resolvePeek({
    required Set<GlassSheetDetent> detents,
    required GlassSheetMode mode,
  }) =>
      detents.contains(GlassSheetDetent.small) ||
      mode == GlassSheetMode.persistent;

  /// The rest states this sheet can occupy, ordered low → high. This is the
  /// single source of truth for the state machine — snapping, min/max bounds,
  /// and resistance all derive from it, so a sheet can omit any of peek / half
  /// / full and the machine simply routes around the missing detent.
  List<GlassSheetState> get orderedStates {
    final states = <GlassSheetState>[];
    // Hidden is a drag target (swipe-to-dismiss) only when the sheet is
    // dismissible, has no peek floor, and isn't a persistent sheet. A
    // non-dismissible sheet rubber-bands at its lowest detent instead (the
    // Apple Pay / Sign in with Apple pattern — no accidental swipe-away).
    if (dismissible && !enablePeek && mode == GlassSheetMode.dismissible) {
      states.add(GlassSheetState.hidden);
    }
    if (enablePeek) states.add(GlassSheetState.peek);
    if (enableHalf && halfSize > 0) states.add(GlassSheetState.half);
    if (enableFull) states.add(GlassSheetState.full);
    // Guardrail for the invalid all-disabled config (asserted against in the
    // widget in debug): a sheet must have at least one primary detent, so fall
    // back to half in release rather than render an un-openable sheet.
    if (!states.contains(GlassSheetState.half) &&
        !states.contains(GlassSheetState.full)) {
      states.add(GlassSheetState.half);
    }
    return states;
  }

  /// Returns the normalized position (0.0–1.0) for [state] given [screenHeight].
  ///
  /// Values > 1.0 passed as size parameters are treated as absolute pixel
  /// heights and divided by [screenHeight]; values ≤ 1.0 are used as-is.
  static double positionFor(
    GlassSheetState state,
    double screenHeight, {
    GlassSheetMode? mode,
    double? halfSize,
    double? fullSize,
    double? peekSize,
  }) {
    switch (state) {
      case GlassSheetState.hidden:
        return 0.0;
      case GlassSheetState.peek:
        double pos = peekSize ?? 5.0;
        return pos > 1.0 ? pos / screenHeight : pos;
      case GlassSheetState.half:
        double pos = halfSize ?? 0.45;
        return pos > 1.0 ? pos / screenHeight : pos;
      case GlassSheetState.full:
        double? target = fullSize;
        if (target != null) {
          return target > 1.0 ? target / screenHeight : target;
        }
        // Strictly use the specified inset (default 90.0) for accurate top positioning
        final topInset = 90.0;
        return (screenHeight - topInset) / screenHeight;
    }
  }

  /// Like [positionFor] but applies cascade constraints so snap positions are
  /// always ordered: `hidden ≤ peek ≤ half ≤ full`.
  double positionForState(GlassSheetState state, double screenHeight) {
    final hiddenPos = positionFor(GlassSheetState.hidden, screenHeight,
        mode: mode, halfSize: halfSize, fullSize: fullSize, peekSize: peekSize);
    final peekPos = positionFor(GlassSheetState.peek, screenHeight,
        mode: mode, halfSize: halfSize, fullSize: fullSize, peekSize: peekSize);
    final halfPos = positionFor(GlassSheetState.half, screenHeight,
        mode: mode, halfSize: halfSize, fullSize: fullSize, peekSize: peekSize);
    final fullPos = positionFor(GlassSheetState.full, screenHeight,
        mode: mode, halfSize: halfSize, fullSize: fullSize, peekSize: peekSize);

    // Cascade constraint: ensure order hidden <= peek <= half <= full
    final safePeek = peekPos.clamp(hiddenPos, 1.0);
    final safeHalf = halfPos.clamp(safePeek, 1.0);
    final safeFull = fullPos.clamp(safeHalf, 1.0);

    switch (state) {
      case GlassSheetState.hidden:
        return hiddenPos;
      case GlassSheetState.peek:
        return safePeek;
      case GlassSheetState.half:
        return safeHalf;
      case GlassSheetState.full:
        return safeFull;
    }
  }

  /// The lowest detent in the active configuration.
  GlassSheetState get minState => orderedStates.first;

  /// The highest detent in the active configuration.
  GlassSheetState get maxState => orderedStates.last;

  /// Computes target state based on current position and velocity.
  GlassSheetState resolveTarget(
    SheetSnapshot current, {
    required double snapThreshold,
    required double velocityThreshold,
  }) {
    // The ordered rest states for this sheet's config (peek / half / full are
    // each optional; hidden appears only for a dismissible, peek-less sheet).
    final states = orderedStates;

    final positions = states
        .map((s) => positionForState(s, current.screenSize.height))
        .toList();
    final velocity = current.velocity;

    // Fast flick handling
    if (velocity > velocityThreshold) {
      // Find the next state above current
      for (int i = 0; i < states.length - 1; i++) {
        if (current.position < positions[i + 1] - 0.001) return states[i + 1];
      }
      return states.last;
    }
    if (velocity < -velocityThreshold) {
      // Find the next state below current
      for (int i = states.length - 1; i > 0; i--) {
        if (current.position > positions[i - 1] + 0.001) return states[i - 1];
      }
      return states.first;
    }

    // Boundary safety: if outside the range of segments, snap to extremes
    if (current.position <= positions.first) return states.first;
    if (current.position >= positions.last) return states.last;

    // Static snap handling: find which segment we are in
    for (int i = 0; i < states.length - 1; i++) {
      final s1 = states[i];
      final s2 = states[i + 1];
      final p1 = positions[i];
      final p2 = positions[i + 1];

      if (current.position >= p1 && current.position <= p2) {
        final range = p2 - p1;
        if (range <= 0.0001) continue;

        final progress = (current.position - p1) / range;

        // If we were moving towards s2, check if we crossed threshold
        if (current.state == s1) {
          return progress >= snapThreshold ? s2 : s1;
        }
        // If we were moving towards s1, check if we crossed threshold
        if (current.state == s2) {
          return (1.0 - progress) >= snapThreshold ? s1 : s2;
        }

        // Default: snap to nearest
        return progress >= 0.5 ? s2 : s1;
      }
    }

    // Final fallback: return the closest state overall
    double minDistance = double.infinity;
    GlassSheetState closest = current.state;
    for (int i = 0; i < states.length; i++) {
      final dist = (current.position - positions[i]).abs();
      if (dist < minDistance) {
        minDistance = dist;
        closest = states[i];
      }
    }
    return closest;
  }

  /// Applies rubber-band resistance when dragging beyond bounds.
  double applyResistance(
    double rawPosition,
    double screenHeight, {
    required double resistance,
  }) {
    final minPos = positionForState(minState, screenHeight);
    final maxPos = positionForState(maxState, screenHeight);

    if (rawPosition < minPos) {
      final overflow = minPos - rawPosition;
      return minPos - overflow * resistance;
    }
    if (rawPosition > maxPos) {
      final overflow = rawPosition - maxPos;
      return maxPos + overflow * resistance;
    }
    return rawPosition;
  }
}

// ===========================================================================
// Controllers
// ===========================================================================

/// Programmatic controller for a [GlassModalSheet].
///
/// Pass to [GlassModalSheet.controller] or [GlassModalSheetScaffold.controller]
/// to snap the sheet between states without user interaction.
///
/// One controller drives one mounted sheet at a time. The controller is
/// safe to reuse across widget rebuilds — it guards against stale attachment
/// during hot-swap (key changes) the same way Flutter's own [ScrollController]
/// does.
class GlassModalSheetController {
  _GlassModalSheetState? _state;

  void _attach(_GlassModalSheetState state) => _state = state;

  // Guarded: only clear if [state] is still the attached one. During a
  // widget swap under a shared controller (e.g. a key change), the new
  // instance's initState → _attach runs BEFORE the old instance's
  // dispose → _detach; an unguarded clear would then null out the live
  // attachment and silently break the controller. Mirrors how Flutter's
  // own ScrollController/RestorableProperty guard reattachment.
  void _detach(_GlassModalSheetState state) {
    if (_state == state) _state = null;
  }

  /// Snaps the sheet to [state], optionally animating the transition.
  ///
  /// When [animate] is `false` the sheet jumps instantly. [velocity] seeds the
  /// spring simulation's initial velocity (pixels/second, upward positive).
  void snapToState(GlassSheetState state,
      {bool animate = true, double velocity = 0}) {
    _state?._snapToState(state, animate: animate, velocity: velocity);
  }

  /// The snap state the sheet is currently resting at (or animating toward).
  GlassSheetState get currentState =>
      _state?._currentState ?? GlassSheetState.hidden;

  /// Raw sheet position as a screen-height fraction (0.0–1.0).
  ///
  /// Reading during an animation gives the instantaneous value. Setting this
  /// property jumps the sheet without animation — useful for syncing to a
  /// drag gesture's direct-manipulation offset.
  double get value => _state?._currentPosition ?? 0.0;
  set value(double newValue) {
    _state?._jumpTo(newValue);
  }

  /// Live progress between the half and full snaps: 0.0 at (or below) the half
  /// snap, 1.0 at full. Use with [progressListenable] to react during a drag.
  double get progress => _state?._expandProgress ?? 0.0;

  /// Notifies on every sheet position change — drag and snap animation alike.
  /// Null until the sheet is mounted; read [progress] from inside the listener.
  Listenable? get progressListenable => _state?._progressNotifier;

  /// The sheet's live position, straight off its animation controller, or null
  /// while no sheet is attached.
  ///
  /// [value] reads the same position (it is refreshed on every controller
  /// tick, before [progressListenable] fires, so a listener sees where the
  /// sheet is, not where it was a frame ago); the null case distinguishes
  /// "not mounted yet" from a sheet genuinely sitting at 0.0.
  double? get _livePosition => _state?._animationController.value;
}

// ===========================================================================
// GestureArena — unified gesture handling
// ===========================================================================

/// Tracks which gesture mode the [GestureArena] is currently in.
enum GesturePhase {
  /// No active gesture — waiting for the next pointer down.
  idle,

  /// User is dragging the sheet via its handle zone.
  handleDrag,

  /// User is dragging the sheet via its content area.
  contentDrag,

  /// The inner scroll view has claimed the gesture.
  scrolling,
}

/// Unified gesture disambiguator for [GlassModalSheet].
///
/// Decides, on every pointer-move event, whether the sheet or an inner
/// [ScrollView] should own the current gesture. Mutable so it can be reset
/// between pointer sequences without allocating a new instance.
class GestureArena {
  /// Current gesture ownership phase.
  GesturePhase phase = GesturePhase.idle;

  /// Y-coordinate of the pointer when the current gesture began.
  double dragStartY = 0.0;

  /// X-coordinate of the pointer when the current gesture began.
  double dragStartX = 0.0;

  /// Sheet position (fraction of screen height) when the current gesture began.
  double dragStartSheetPosition = 0.0;

  /// Whether the disambiguated gesture direction is vertical.
  bool isVerticalGesture = false;

  /// Pointer y at the previous move, giving the instantaneous drag direction.
  ///
  /// Travel measured from [dragStartY] cannot serve the mid-gesture handovers:
  /// a drag that grew the sheet is still net-upward at the moment it turns
  /// around, so cumulative travel would report the wrong direction exactly when
  /// ownership needs to change.
  double lastMoveY = 0.0;

  /// Tracks pointer samples to compute a fling velocity at gesture end.
  VelocityTracker velocityTracker =
      VelocityTracker.withKind(PointerDeviceKind.touch);

  /// Resets the arena to [GesturePhase.idle] between pointer sequences.
  void reset() {
    phase = GesturePhase.idle;
    isVerticalGesture = false;
    lastMoveY = 0.0;
  }

  /// Called when a pointer-down event lands in the sheet's handle zone.
  void beginHandleDrag(double y, double sheetPosition) {
    phase = GesturePhase.handleDrag;
    dragStartY = y;
    lastMoveY = y;
    dragStartSheetPosition = sheetPosition;
  }

  /// Called when a pointer-down event lands in the sheet's content area.
  void beginPointer(
      double y, double x, double sheetPosition, PointerDeviceKind kind) {
    phase = GesturePhase.idle;
    dragStartY = y;
    lastMoveY = y;
    dragStartX = x;
    dragStartSheetPosition = sheetPosition;
    isVerticalGesture = false;
    velocityTracker = VelocityTracker.withKind(kind);
  }

  /// Returns true if gesture should be claimed by sheet (not scroll).
  ///
  /// The decision is not final. A sheet that reaches its topmost detent part-way
  /// through an upward drag hands the rest of that pointer to the content, so
  /// growing the sheet and scrolling its content are one continuous gesture.
  ///
  /// [atTopDetent] reports measured travel, and the handovers use it rather than
  /// `currentState == maxState`: [currentState] carries the drag's *predicted*
  /// target mid-gesture, so keying off it would stand the sheet down while it
  /// was still travelling, stranding it short of the detent it was predicting.
  bool evaluateMove(
    double y,
    double x,
    GlassSheetState currentState,
    GlassSheetState maxState,
    double threshold, {
    required bool canScrollListUp,
    required bool hasScrollClients,
    required bool atTopDetent,
  }) {
    final double previousY = lastMoveY;
    lastMoveY = y;
    final bool draggingUp = y < previousY;
    final bool draggingDown = y > previousY;

    if (phase == GesturePhase.contentDrag) {
      // Re-evaluated on every move rather than only at the decision moment: a
      // drag that began below the top detent stops being the sheet's the
      // instant the sheet tops out. Standing down here lets the same finger
      // carry on as a content scroll, instead of rubber-banding a sheet that
      // cannot grow any further.
      if (atTopDetent && draggingUp && hasScrollClients) {
        phase = GesturePhase.scrolling;
        isVerticalGesture = true;
        return false;
      }
      return true;
    }

    if (phase == GesturePhase.scrolling) {
      // The reverse handover. Content pulled back to its top gives the rest of
      // a downward drag to the sheet, so returning to the top and collapsing
      // are one gesture rather than two. Gated on a vertical gesture: a
      // horizontal swipe also rests in this phase and must never wake the
      // sheet.
      if (isVerticalGesture &&
          atTopDetent &&
          draggingDown &&
          !canScrollListUp) {
        phase = GesturePhase.contentDrag;
        return true;
      }
      return false;
    }

    if (phase == GesturePhase.handleDrag) return true;

    final dy = (y - dragStartY).abs();
    final dx = (x - dragStartX).abs();

    // Decide the axis ONCE per touch, on the first movement past the
    // threshold, and hold that decision for the rest of the gesture.
    //
    // The comparison is still cumulative from the touch origin, but it is now
    // only ever read at the moment of decision, which fixes two things:
    //
    //  * A gesture that started horizontal stays horizontal. Previously the
    //    test was re-run on every move, so a sideways swipe would grab the
    //    sheet the instant total vertical travel happened to exceed total
    //    horizontal — and conversely, after a long sideways scroll the sheet
    //    could not be dragged at all without out-travelling that distance
    //    vertically, which on a wide swipe is most of the screen.
    //  * The reverse latch is gone. `contentDrag` was only ever set from a
    //    vertical-looking move and then never re-evaluated, so a horizontal
    //    swipe that began with a slight vertical wobble dragged the sheet for
    //    its whole duration.
    //
    // Below the threshold on both axes the gesture is still undecided; return
    // false and wait rather than guessing from a few pixels of noise.
    if (dy <= threshold && dx <= threshold) return false;

    if (dx >= dy) {
      // Horizontal. An inner scrollable owns this touch; the sheet stays out
      // of it until the finger lifts and `reset()` clears the phase.
      phase = GesturePhase.scrolling;
      return false;
    }

    if (dy > threshold) {
      // At the topmost detent the sheet can't expand further, so an inner
      // scroll view (if any) owns the gesture. maxState is `full` for a
      // normal sheet but `half` for a half-only sheet (enableFull: false),
      // which is why this compares against maxState rather than hardcoding
      // full — otherwise a half-only sheet would never scroll its content.
      if (currentState == maxState) {
        if ((y - dragStartY) < 0) {
          // Swiping UP
          if (hasScrollClients) {
            phase = GesturePhase.scrolling;
            isVerticalGesture = true;
            return false;
          } else {
            phase = GesturePhase.contentDrag;
            isVerticalGesture = true;
            return true;
          }
        } else {
          // Swiping DOWN
          if (canScrollListUp) {
            phase = GesturePhase.scrolling;
            isVerticalGesture = true;
            return false;
          } else {
            phase = GesturePhase.contentDrag;
            isVerticalGesture = true;
            return true;
          }
        }
      } else {
        phase = GesturePhase.contentDrag;
        isVerticalGesture = true;
        return true;
      }
    }
    return false;
  }
}

// ===========================================================================
// FrozenState — immutable freeze record
// ===========================================================================

/// Immutable record capturing the sheet's visual state at the moment it was
/// "frozen" for a spring-back animation.
///
/// Stored while the sheet is animating back from an over-drag, so the
/// spring can interpolate smoothly back to the correct detent geometry.
class FrozenState {
  /// The bottom scale factor applied to the sheet at the freeze instant.
  final double bottomScale;

  /// The sheet's render height (in logical pixels) at the freeze instant.
  final double heightAtFreeze;

  /// Creates an immutable frozen state record.
  const FrozenState({
    required this.bottomScale,
    required this.heightAtFreeze,
  });

  @override
  String toString() =>
      'FrozenState(scale: ${bottomScale.toStringAsFixed(3)}, height: ${heightAtFreeze.toStringAsFixed(1)})';
}

// ===========================================================================
// RenderMetrics — Internal record for build geometry calculations
// ===========================================================================

class _RenderMetrics {
  final double stretchT;
  final double effectiveHeight;
  final double effectiveBottom;
  final double topRadius;
  final double bottomRadius;
  final double hPad;
  final double colorOpacity;
  final double glassOpacity;
  final LiquidGlassSettings effectiveSettings;
  final double interactionScale;
  final double interactionStretch;
  final Color effectiveExpandedColor;

  const _RenderMetrics({
    required this.stretchT,
    required this.effectiveHeight,
    required this.effectiveBottom,
    required this.topRadius,
    required this.bottomRadius,
    required this.hPad,
    required this.colorOpacity,
    required this.glassOpacity,
    required this.effectiveSettings,
    required this.interactionScale,
    required this.interactionStretch,
    required this.effectiveExpandedColor,
  });
}
