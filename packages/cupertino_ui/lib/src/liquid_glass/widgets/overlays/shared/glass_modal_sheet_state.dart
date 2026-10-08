part of '../glass_modal_sheet.dart';

class _GlassModalSheetState extends State<GlassModalSheet>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // ── Animation Controllers ─────────────────────────────────────────────────
  late AnimationController _animationController;
  late AnimationController _saturationController;
  late CurvedAnimation _saturationAnimation;
  final _progressNotifier = _ProgressNotifier();

  // ── State ─────────────────────────────────────────────────────────────────
  late final ValueNotifier<GlassSheetState> _currentStateNotifier;
  GlassSheetState get _currentState => _currentStateNotifier.value;
  set _currentState(GlassSheetState v) => _currentStateNotifier.value = v;

  /// The state most recently published to consumers via
  /// [GlassModalSheet.onStateChanged] (and from which haptics and
  /// scroll-to-top side effects fired).
  ///
  /// Distinct from [_currentState]: that value is mutated mid-gesture
  /// by [_applyDrag] and [_jumpTo] to drive in-flight visual
  /// interpolation (radii, expand-progress, glass settings) toward the
  /// resolved snap target. Comparing the snap target against
  /// [_currentState] in [_snapToState] therefore silently skips the
  /// side-effects branch whenever the drag itself had already crossed
  /// a snap threshold — by the time the user releases, [_currentState]
  /// already equals the target.
  ///
  /// [_settledState] is updated only inside the side-effects branch,
  /// so the equality check correctly answers "did the state change
  /// since the last time we told consumers about it".
  late GlassSheetState _settledState;

  double _currentPosition = 0.0;
  double _currentEffectiveHeight = 0.0;

  FrozenState? _frozenState;
  Size _lastPhysicalSize = Size.zero;

  bool _isInteractingWithChild = false;
  bool _suppressScalingForSession = false;

  // ── Unified Gesture & Scroll ──────────────────────────────────────────────
  final GestureArena _gestureArena = GestureArena();
  final ScrollController _scrollController = ScrollController();

  /// Latest vertical metrics seen from the content subtree, including content
  /// scrolling on a [ScrollController] of its own.
  ScrollMetrics? _contentMetrics;

  // ── Geometry & Metrics ────────────────────────────────────────────────────
  late SheetGeometry _geometry;

  /// The vertical bar strip the sheet is presented over, or null where bars
  /// are horizontal. See [GlassVerticalBar].
  GlassVerticalBarData? _verticalBar;

  /// The large detent's height in the strip layout, which the strip's
  /// absence leaves to the default. See [GlassModalSheet._stripFullSize].
  double? _stripFullSize;

  /// The view size the drag math divides by, cached because pointer moves
  /// arrive faster than an inherited lookup is worth. Read it through
  /// [_screenSize], which refreshes a cache still holding the zero it was
  /// born with: a sheet built before the window has a size — an app the
  /// system launched in the background for a push, a test on a zero-size
  /// view — would otherwise keep that zero for life and divide every drag
  /// by it.
  Size _cachedScreenSize = Size.zero;
  Size get _screenSize {
    if (_cachedScreenSize.isEmpty && mounted) _updateScreenSize();
    return _cachedScreenSize;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Mirror the coercion show() applies: if the caller passed an initialState
    // that isn't in the offered detents, snap to the nearest one that is.
    // Without this an embedded GlassModalSheet whose initialState doesn't match
    // its detents would wedge (no orderedStates entry → no rest position).
    final resolvedInitial = _resolveInitialState(
      widget.initialState,
      widget.detents,
    );

    _currentStateNotifier = ValueNotifier(resolvedInitial);
    _settledState = resolvedInitial;
    _geometry = _buildGeometry();

    _animationController = AnimationController.unbounded(vsync: this);
    _animationController.addListener(_onPositionTick);
    _saturationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _saturationAnimation =
        CurvedAnimation(parent: _saturationController, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateScreenSize();
        _lastPhysicalSize = View.of(context).physicalSize;
        _snapToState(_currentState, animate: false);
      }
    });

    widget.controller?._attach(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _verticalBar = GlassVerticalBar.maybeOf(context);
    final stripFullSize = GlassModalSheet._stripFullSize(context);
    if (stripFullSize != _stripFullSize) {
      _stripFullSize = stripFullSize;
      _geometry = _buildGeometry();
    }
  }

  @override
  void didUpdateWidget(GlassModalSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }

    // Metrics outlive the scrollable that sent them. New content may have no
    // scrollable at all, and stale metrics reporting it scrolled would hand
    // downward drags to something that no longer exists, leaving the sheet
    // unable to collapse.
    if (widget.child != oldWidget.child) {
      _contentMetrics = null;
    }

    final oldGeometry = _geometry;
    _geometry = _buildGeometry();

    // Hot Reload reaction: if dimensions changed, force position recalculation
    if (oldGeometry.halfSize != _geometry.halfSize ||
        oldGeometry.fullSize != _geometry.fullSize) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _gestureArena.phase == GesturePhase.idle) {
          _snapToState(_currentState, animate: true);
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller?._detach(this);
    _animationController.removeListener(_onPositionTick);
    _animationController.dispose();
    _progressNotifier.dispose();
    _saturationAnimation.dispose();
    _saturationController.dispose();
    _scrollController.dispose();
    _currentStateNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (!mounted) return;

    final view = View.of(context);
    // Filter system call spam: the spring only jitters if the window size
    // actually changes.
    if (_lastPhysicalSize != view.physicalSize) {
      _updateScreenSize();
      // A window that had no size is being sized for the first time (an app
      // launched in the background, coming to the foreground), not resized:
      // there is nothing to re-settle, and the size cache above is all that
      // first size has to update.
      if (_lastPhysicalSize != Size.zero) {
        _snapToState(_currentState, animate: true);
      }
      _lastPhysicalSize = view.physicalSize;
    }
  }

  SheetGeometry _buildGeometry() => SheetGeometry(
        mode: widget.mode,
        halfSize: widget.halfSize,
        fullSize: widget.fullSize ?? _stripFullSize,
        peekSize: widget.peekSize,
        enablePeek: SheetGeometry.resolvePeek(
          detents: widget.detents,
          mode: widget.mode,
        ),
        enableHalf: widget.detents.contains(GlassSheetDetent.medium),
        enableFull: widget.detents.contains(GlassSheetDetent.large),
        dismissible: widget.dismissible,
      );

  /// Coerce [requested] to the nearest detent the sheet actually offers.
  ///
  /// Mirrors the fallback [GlassModalSheet.show] performs before pushing the
  /// route, so that embedded [GlassModalSheet] widgets are consistent: without
  /// this an `initialState` that isn't in [detents] leaves the sheet with no
  /// matching rest position and it renders stuck.
  static GlassSheetState _resolveInitialState(
    GlassSheetState requested,
    Set<GlassSheetDetent> detents,
  ) {
    if (requested == GlassSheetState.half &&
        !detents.contains(GlassSheetDetent.medium)) {
      return GlassSheetState.full;
    }
    if (requested == GlassSheetState.full &&
        !detents.contains(GlassSheetDetent.large)) {
      return GlassSheetState.half;
    }
    return requested;
  }

  void _updateScreenSize() {
    final view = View.of(context);
    _cachedScreenSize = view.physicalSize / view.devicePixelRatio;
  }

  // ════════════════════════════════════════════════════════════════════════
  // Snap & State Management
  // ════════════════════════════════════════════════════════════════════════

  void _snapToState(GlassSheetState state,
      {bool animate = true, double velocity = 0}) {
    if (!mounted) return;

    if (widget.mode == GlassSheetMode.persistent &&
        state == GlassSheetState.hidden) {
      state = GlassSheetState.peek;
    }

    final screenHeight = MediaQuery.sizeOf(context).height;
    final targetPosition = _geometry.positionForState(state, screenHeight);

    if (animate) {
      final simulation = SpringSimulation(
        const SpringDescription(mass: 1.0, stiffness: 220.0, damping: 30.0),
        _currentPosition,
        targetPosition,
        velocity / screenHeight,
      );
      _animationController.animateWith(simulation);
    } else {
      _animationController.value = targetPosition;
    }

    // Compare against `_settledState`, not `_currentState` — see the
    // doc comment on `_settledState` for why. Briefly: `_currentState`
    // tracks the in-flight snap target during drag (mutated silently
    // by `_applyDrag` and `_jumpTo`), so checking it here would skip
    // side effects whenever the drag itself had already updated the
    // target mid-gesture. `_settledState` only updates inside this
    // branch, ensuring side effects fire on every consumer-visible
    // state transition.
    // Reconcile `_currentState` on EVERY snap, not just on consumer-visible
    // transitions. `_applyDrag` and `_jumpTo` mutate it silently to the
    // in-flight *predicted* target, so a drag that ends back at the state it
    // started from leaves that prediction behind: the sheet rests at `half`
    // while `_currentState` still reads `full`. `evaluateMove` then takes its
    // `currentState == maxState` branch and refuses every upward drag, so the
    // sheet appears stuck until a downward drag re-predicts and resyncs it.
    _currentState = state;

    if (state != _settledState) {
      if (state == GlassSheetState.peek || state == GlassSheetState.hidden) {
        HapticFeedback.lightImpact();
      } else {
        HapticFeedback.mediumImpact();
      }

      _settledState = state;
      widget.onStateChanged?.call(state);

      if (state != _geometry.maxState && _scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }
  }

  /// Every position change, drag and animation alike. Brings
  /// [_currentPosition] — what the controller's `value` and `progress`
  /// report — up to date BEFORE the progress listeners run. It used to be
  /// written only in build, so a listener always read the position of the
  /// previous frame, and the last tick of a drag never showed where the
  /// sheet actually stopped.
  void _onPositionTick() {
    _currentPosition = _animationController.value;
    _progressNotifier.notify();
  }

  void _jumpTo(double value) {
    if (!mounted) return;
    _animationController.value = value;
    _currentPosition = value;

    // Update current state based on position if needed
    final snapshot = SheetSnapshot(
      state: _currentState,
      position: value,
      screenSize: _screenSize,
    );
    final target = _geometry.resolveTarget(
      snapshot,
      snapThreshold: widget.snapThreshold,
      velocityThreshold: widget.velocityThreshold,
    );
    if (target != _currentState) {
      _currentState = target;
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // Gesture Handlers — Handle Drag & Scroll Notification
  // ════════════════════════════════════════════════════════════════════════

  bool _onScrollNotification(ScrollNotification notification) {
    // Vertical only. Scroll notifications bubble from ANY descendant, so a
    // horizontal list inside the sheet — a date strip, a carousel — emits
    // exactly this shape when it is pulled past its leading edge. Without the
    // axis guard the sheet claimed the gesture and re-anchored its vertical
    // drag origin to the finger's current y, so scrolling sideways dragged
    // the sheet, and the re-anchoring could hold `dy` under the threshold
    // indefinitely, leaving the sheet unable to expand.
    if (notification.metrics.axis != Axis.vertical) return false;
    if (notification is OverscrollNotification && notification.overscroll < 0) {
      if (_gestureArena.phase == GesturePhase.scrolling ||
          _gestureArena.phase == GesturePhase.idle) {
        _gestureArena.phase = GesturePhase.contentDrag;
        if (notification.dragDetails != null) {
          _gestureArena.dragStartY =
              notification.dragDetails!.globalPosition.dy;
        }
        _gestureArena.dragStartSheetPosition = _currentPosition;

        if (_animationController.isAnimating) {
          _animationController.stop();
        }
      }
    }
    return false;
  }

  // ════════════════════════════════════════════════════════════════════════
  // Gesture Handlers — Pointer Events (Content Zone)
  // ════════════════════════════════════════════════════════════════════════

  void _onPointerDown(PointerDownEvent event) {
    // ALWAYS initialize the gesture arena so swipes can start from anywhere,
    // even from buttons or interactive children.
    _gestureArena.beginPointer(
        event.position.dy, event.position.dx, _currentPosition, event.kind);

    // If the touch is in the handle zone (top 44 pixels), immediately set phase.
    if (event.localPosition.dy <= 44.0) {
      _gestureArena.phase = GesturePhase.handleDrag;
    }

    // Now, if we are interacting with a child (e.g. a button), we SUPPRESS
    // the visual feedback (scaling/glow) for the duration of this gesture,
    // BUT ONLY if the feature is enabled via suppressInteractionOnChildren.
    if (widget.suppressInteractionOnChildren && _isInteractingWithChild) {
      _suppressScalingForSession = true;
      _isInteractingWithChild = false;
      // Do NOT fire haptic or saturation — this touch is silenced.
      return;
    }

    // Always reset suppression state if we didn't return above
    _isInteractingWithChild = false;
    _suppressScalingForSession = false;

    // Haptic and saturation only fire for genuine sheet-level touches
    // (not for touches on child buttons that were suppressed above).
    final isFull = _currentState == GlassSheetState.full;

    if (widget.enableInteractionGlow && !isFull) {
      HapticFeedback.selectionClick();
    }

    if (widget.enableSaturationGlow && !isFull) {
      _saturationController.forward();
    }

    _frozenState = null;
  }

  void _recordContentMetrics(ScrollMetrics metrics) {
    if (axisDirectionToAxis(metrics.axisDirection) != Axis.vertical) return;
    _contentMetrics = metrics;
  }

  /// Whether anything inside the sheet can scroll.
  ///
  /// Content is free to keep a controller of its own, which the sheet's
  /// controller cannot see — without the observed metrics the sheet would read
  /// that as "no scrollable" and claim every drag.
  bool get _hasScrollClients =>
      _scrollController.hasClients || _contentCanScroll;

  /// Whether the observed content has somewhere to scroll to. Content that
  /// fits its viewport must leave the drag with the sheet, which still has its
  /// rubber-band to play.
  bool get _contentCanScroll {
    final ScrollMetrics? metrics = _contentMetrics;
    return metrics != null && metrics.maxScrollExtent > metrics.minScrollExtent;
  }

  /// Whether the content is scrolled away from its top, so a downward drag
  /// belongs to the content before it belongs to the sheet.
  bool get _canScrollListUp {
    if (_scrollController.hasClients && _scrollController.offset > 0) {
      return true;
    }
    final ScrollMetrics? metrics = _contentMetrics;
    return metrics != null && metrics.pixels > metrics.minScrollExtent;
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_isInteractingWithChild) {
      return;
    }

    _gestureArena.velocityTracker.addPosition(event.timeStamp, event.position);

    // If we're already dragging the handle, just apply the drag
    if (_gestureArena.phase == GesturePhase.handleDrag) {
      _applyDrag(event.position.dy);
      return;
    }

    final phaseBefore = _gestureArena.phase;
    final shouldClaim = _gestureArena.evaluateMove(
      event.position.dy,
      event.position.dx,
      _currentState,
      _geometry.maxState,
      10.0,
      hasScrollClients: _hasScrollClients,
      canScrollListUp: _canScrollListUp,
      atTopDetent: _contentScrollProgress > _kTopDetentThreshold,
    );

    if (!shouldClaim &&
        phaseBefore == GesturePhase.contentDrag &&
        _gestureArena.phase == GesturePhase.scrolling) {
      // The sheet just handed this drag to its content. That happens at the
      // top-detent THRESHOLD — up to (1 - _kTopDetentThreshold) of the
      // travel short of the detent itself — and this pointer's up will see
      // a scroll, not a drag, so nothing else would ever finish the trip.
      // Snap the remainder now: the sheet arrives as the content starts to
      // scroll, with the state callback and haptic an arrival deserves,
      // instead of parking a few points shy of the top with no callback.
      _snapToState(_geometry.maxState);
    }

    if (shouldClaim) {
      if (_animationController.isAnimating) {
        _animationController.stop();
        _gestureArena.dragStartY = event.position.dy;
        _gestureArena.dragStartSheetPosition = _currentPosition;
      }

      final dy = event.position.dy - _gestureArena.dragStartY;
      if ((_currentState == GlassSheetState.half ||
              _currentState == GlassSheetState.peek) &&
          dy < 0) {
        _frozenState = FrozenState(
          bottomScale: widget.interactionScale,
          heightAtFreeze: _currentEffectiveHeight,
        );
      }

      _applyDrag(event.position.dy);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _isInteractingWithChild = false;
    _suppressScalingForSession = false;
    _saturationController.reverse();

    final wasDragging = _gestureArena.phase == GesturePhase.contentDrag ||
        _gestureArena.phase == GesturePhase.handleDrag;
    _gestureArena.reset();
    _frozenState = null;

    if (!wasDragging) return;

    final estimate = _gestureArena.velocityTracker.getVelocityEstimate();
    final velocity = -(estimate?.pixelsPerSecond.dy ?? 0.0);

    final snapshot = SheetSnapshot(
      state: _currentState,
      position: _currentPosition,
      velocity: velocity,
      screenSize: _screenSize,
    );
    final target = _geometry.resolveTarget(
      snapshot,
      snapThreshold: widget.snapThreshold,
      velocityThreshold: widget.velocityThreshold,
    );

    _snapToState(target, velocity: velocity);
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _isInteractingWithChild = false;
    _suppressScalingForSession = false;
    _saturationController.reverse();
    _gestureArena.reset();
    _frozenState = null;
  }

  // ════════════════════════════════════════════════════════════════════════
  // Drag Application
  // ════════════════════════════════════════════════════════════════════════

  void _applyDrag(double currentY) {
    final screenHeight = _screenSize.height;
    // No sized window means nothing visible is being dragged; dividing by
    // zero here would park the sheet at infinity for good.
    if (screenHeight <= 0) return;
    final delta = currentY - _gestureArena.dragStartY;
    double newPosition =
        _gestureArena.dragStartSheetPosition - delta / screenHeight;

    newPosition = _geometry.applyResistance(newPosition, screenHeight,
        resistance: widget.resistance);
    _animationController.value = newPosition;

    final snapshot = SheetSnapshot(
      state: _currentState,
      position: newPosition,
      velocity: 0,
      screenSize: _screenSize,
    );
    final target = _geometry.resolveTarget(
      snapshot,
      snapThreshold: widget.snapThreshold,
      velocityThreshold: widget.velocityThreshold,
    );

    if (target != _currentState &&
        (widget.mode != GlassSheetMode.dismissible ||
            target != GlassSheetState.hidden)) {
      _currentState = target;
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // Metrics Calculation Helpers
  // ════════════════════════════════════════════════════════════════════════

  double get _expandProgress {
    // No full detent → never crossfade toward the opaque full state (an
    // over-drag above half just rubber-bands; it isn't an expansion).
    if (!_geometry.enableFull) return 0.0;
    final halfPos =
        _geometry.positionForState(GlassSheetState.half, _screenSize.height);
    final fullPos =
        _geometry.positionForState(GlassSheetState.full, _screenSize.height);
    if (fullPos <= halfPos) return 0.0;
    return ((_currentPosition - halfPos) / (fullPos - halfPos)).clamp(0.0, 1.0);
  }

  /// Progress (0→1) toward the topmost detent, measured from the detent just
  /// below it. Gates inner content scrolling — the content becomes scrollable
  /// only once the sheet is at the detent it can't grow past. For a normal
  /// sheet this tracks half→full (identical to [_expandProgress]); for a
  /// half-only sheet it tracks the approach to half so its content still
  /// scrolls, whereas [_expandProgress] stays 0 there to keep the glass look —
  /// which is exactly why the scroll gate needs its own signal.
  double get _contentScrollProgress {
    final states = _geometry.orderedStates;
    // A sheet with only one rest state (e.g. the release fallback that adds
    // `half` when all detents are disabled) is always at its max — treat its
    // content as immediately scrollable rather than gating on a transition
    // that can never happen.
    if (states.length < 2) return 1.0;
    final maxPos = _geometry.positionForState(states.last, _screenSize.height);
    final prevPos = _geometry.positionForState(
        states[states.length - 2], _screenSize.height);
    if (maxPos <= prevPos) return 0.0;
    return ((_currentPosition - prevPos) / (maxPos - prevPos)).clamp(0.0, 1.0);
  }

  _RenderMetrics _calculateMetrics({
    required double pos,
    required double t,
    required double halfPos,
    required double minPos,
    required double extraHeight,
    required double mqHeight,
    required LiquidGlassSettings baseSettings,
    required Color effectiveExpandedColor,
    required double topRadiusBase,
    required double bottomRadiusBase,
    required double topRadiusFull,
    required double bottomRadiusFull,
    required double fullPos,
  }) {
    // Without a peek detent, dismissal translates the lowest enabled frame.
    // Do not interpolate through disabled half/peek geometry on the way out:
    // peekWidth and peek margins may describe a completely different surface.
    double dismissOffset = 0.0;
    if (widget.mode == GlassSheetMode.dismissible && !_geometry.enablePeek) {
      final pivotPos = _geometry.positionForState(
          SheetMorphGeometry.dismissPivotState(_geometry), mqHeight);
      if (pos < pivotPos) {
        dismissOffset = (pivotPos - pos) * mqHeight;
        pos = pivotPos;
        final expansionRange = fullPos - halfPos;
        t = expansionRange > 0.0001
            ? ((pos - halfPos) / expansionRange).clamp(0.0, 1.0)
            : 1.0;
      }
    }

    late LiquidGlassSettings effectiveSettings;
    // Disable scaling in full state by lerping effective interactionScale to 1.0
    // Also disable scaling if we are interacting with a child (Smart Silence)
    final baseInteractionScale =
        _suppressScalingForSession ? 1.0 : widget.interactionScale;

    final effectiveInteractionScale = lerpDouble(baseInteractionScale, 1.0, t)!;
    final effectiveInteractionStretch =
        lerpDouble(_suppressScalingForSession ? 0.0 : widget.stretch, 0.0, t)!;

    double stretchT = 1.0;
    // Protection against division by zero if halfPos == minPos
    final range = halfPos - minPos;
    if (pos < halfPos && range > 0.0001) {
      stretchT = ((pos - minPos) / range).clamp(0.0, 1.0);
    }

    late double effectiveHeight;
    late double effectiveBottom;
    late double topRadius;
    late double bottomRadius;
    late double hPad;
    late double colorOpacity;
    late double glassOpacity;

    // Ideal target visual height of the window
    final targetVisualHeight = pos * mqHeight;

    // baseSettings is now passed from outside to avoid theme lookups every frame.

    // Calculate state-specific settings interpolation
    final peekPos = _geometry.positionForState(GlassSheetState.peek, mqHeight);

    final sPeek = widget.peekSettings ?? baseSettings;
    final sHalf = widget.halfSettings ?? baseSettings;
    final sFull = widget.fullSettings ?? baseSettings;

    // Determine target expanded colors for each state
    // If blur is 0, the state itself provides the solid color
    final cPeek = sPeek.blur == 0 ? sPeek.glassColor : effectiveExpandedColor;
    final cHalf = sHalf.blur == 0 ? sHalf.glassColor : effectiveExpandedColor;
    final cFull = sFull.blur == 0 ? sFull.glassColor : effectiveExpandedColor;

    Color currentExpandedColor;

    if (pos < halfPos) {
      final range = halfPos - peekPos;
      final tProgress =
          range > 0.0001 ? ((pos - peekPos) / range).clamp(0.0, 1.0) : 1.0;

      if (!_geometry.enablePeek) {
        // Peek-less: below half is the dismiss slide, not a peek morph. Hold
        // the half state's own surface so the sheet slides away solid (Apple
        // keeps the surface opaque and just translates it off — only the
        // background dim fades) rather than fading toward a peek that doesn't
        // exist. Solid glass stays glass; a solid-fill half stays filled.
        effectiveSettings = sHalf;
        currentExpandedColor = cHalf;
        colorOpacity = sHalf.blur == 0 ? 1.0 : 0.0;
      } else {
        effectiveSettings = LiquidGlassSettings.lerp(sPeek, sHalf, tProgress);
        currentExpandedColor = Color.lerp(cPeek, cHalf, tProgress)!;

        if (sPeek.blur > 0 && sHalf.blur == 0) {
          colorOpacity = tProgress;
        } else if (sPeek.blur == 0 && sHalf.blur > 0) {
          colorOpacity = 1.0 - tProgress;
        } else if (sPeek.blur == 0 && sHalf.blur == 0) {
          colorOpacity = 1.0;
        } else {
          colorOpacity = 0.0;
        }
      }
      glassOpacity = 1.0 - colorOpacity;
    } else {
      final range = fullPos - halfPos;
      final tProgress =
          range > 0.0001 ? ((pos - halfPos) / range).clamp(0.0, 1.0) : 1.0;

      effectiveSettings = LiquidGlassSettings.lerp(sHalf, sFull, tProgress);
      currentExpandedColor = Color.lerp(cHalf, cFull, tProgress)!;

      if (widget.fullSettings != null) {
        // Use explicit state settings for opacity transition
        if (sHalf.blur > 0 && sFull.blur == 0) {
          colorOpacity = tProgress;
        } else if (sHalf.blur == 0 && sFull.blur > 0) {
          colorOpacity = 1.0 - tProgress;
        } else if (sHalf.blur == 0 && sFull.blur == 0) {
          colorOpacity = 1.0;
        } else {
          colorOpacity = 0.0;
        }
      } else {
        // Fallback to classic threshold logic OR maintain solid if half was solid
        if (sHalf.blur == 0) {
          colorOpacity = 1.0;
        } else if (baseSettings.blur == 0) {
          colorOpacity = 1.0;
        } else {
          final fadeRange = (1.0 - widget.fillThreshold).clamp(0.01, 1.0);
          switch (widget.fillTransition) {
            case GlassFillTransition.gradual:
              const plateau = 0.04;
              final rawT =
                  ((tProgress - widget.fillThreshold) / (fadeRange - plateau))
                      .clamp(0.0, 1.0);
              colorOpacity = Curves.easeInOutCubic.transform(rawT);
              break;
            case GlassFillTransition.instant:
              colorOpacity = tProgress >= widget.fillThreshold ? 1.0 : 0.0;
              break;
          }
        }
      }
      glassOpacity = 1.0 - colorOpacity;
    }

    // Apply saturation glow pulse if enabled
    if (widget.enableSaturationGlow && _saturationAnimation.value > 0) {
      effectiveSettings = effectiveSettings.copyWith(
        saturation: effectiveSettings.saturation *
            (1.0 + _saturationAnimation.value * 0.25),
        lightIntensity: effectiveSettings.lightIntensity *
            (1.0 + _saturationAnimation.value * 0.35),
      );
    }

    // ════════════════════════════════════════════════════════════════════════
    // Peek to Half Morphing
    // ════════════════════════════════════════════════════════════════════════
    if (pos < halfPos) {
      final range = halfPos - peekPos;
      final tProgressRaw =
          range > 0.0001 ? ((pos - peekPos) / range).clamp(0.0, 1.0) : 1.0;

      // Calibrate for Apple Maps behavior:
      // Morphing should be almost instant (complete within first 15% of movement)
      final tMorph = (tProgressRaw / 0.15).clamp(0.0, 1.0);
      final tProgress = Curves.easeOut.transform(tMorph);

      // 1. Resolve Peek-specific geometry
      final peekHMargin =
          widget.peekHorizontalMargin ?? widget.horizontalMargin;
      final peekBMargin = widget.peekBottomMargin ?? widget.bottomMargin;
      final peekTRadius = widget.peekTopBorderRadius ?? topRadiusBase;
      final peekBRadius = widget.peekBottomRadius ?? bottomRadiusBase;

      // 2. Resolve Peek-specific width (hPad)
      double peekHPad = peekHMargin;
      if (widget.peekWidth != null && mqHeight > 0) {
        peekHPad = ((_screenSize.width - widget.peekWidth!) / 2.0)
            .clamp(0.0, _screenSize.width / 2.0);
      }

      if (widget.mode == GlassSheetMode.persistent) {
        // Morph from peek metrics to half metrics
        effectiveBottom =
            lerpDouble(peekBMargin, widget.bottomMargin, tProgress)!;
        hPad = lerpDouble(peekHPad, widget.horizontalMargin, tProgress)!;

        // Morph corner radii
        final targetTRadius =
            lerpDouble(peekTRadius, topRadiusBase, tProgress)!;
        final targetBRadius =
            lerpDouble(peekBRadius, bottomRadiusBase, tProgress)!;

        if (_frozenState != null) {
          final pivotScale = _frozenState!.bottomScale;
          topRadius = lerpDouble(targetTRadius, targetTRadius * pivotScale,
              _saturationAnimation.value)!;
          bottomRadius = lerpDouble(targetBRadius, targetBRadius * pivotScale,
              _saturationAnimation.value)!;
        } else {
          topRadius = lerpDouble(
              targetTRadius,
              targetTRadius * effectiveInteractionScale,
              _saturationAnimation.value)!;
          bottomRadius = lerpDouble(
              targetBRadius,
              targetBRadius * effectiveInteractionScale,
              _saturationAnimation.value)!;
        }

        // Window changes height visually
        effectiveHeight = targetVisualHeight - effectiveBottom;
      } else {
        // Dismissible mode: hiding downwards
        // Shared with the morph, so the droplet measures the swipe from the
        // same detent the sheet falls away from.
        final pivotPos = _geometry.positionForState(
          SheetMorphGeometry.dismissPivotState(_geometry),
          mqHeight,
        );

        final pivotVisualHeight = pivotPos * mqHeight;

        if (pos < pivotPos && pivotPos > 0.001) {
          // Swipe-to-dismiss, below the lowest detent: the sheet tracks the
          // finger 1:1. No overshoot is needed — at `pos == 0` a 1:1 frame
          // lands its top edge exactly on the screen's bottom edge, so the
          // sheet is fully gone, and it stays under the finger on the way.
          //
          // A morphed presentation layers its own scale and horizontal offset
          // over this frame (see `GlassSheetMorphPresenter`); deliberately not
          // applied here, so a sheet with no trigger to morph back into keeps
          // the plain slide-away.
          effectiveBottom = peekBMargin - (pivotPos - pos) * mqHeight;
          effectiveHeight = pivotVisualHeight - peekBMargin;
          hPad = peekHPad;
          topRadius = peekTRadius;
          bottomRadius = peekBRadius;
        } else {
          // Morphing between pivot (peek) and half
          effectiveBottom =
              lerpDouble(peekBMargin, widget.bottomMargin, tProgress)!;
          hPad = lerpDouble(peekHPad, widget.horizontalMargin, tProgress)!;
          effectiveHeight = targetVisualHeight - effectiveBottom;
          topRadius = lerpDouble(peekTRadius, topRadiusBase, tProgress)!;
          bottomRadius = lerpDouble(peekBRadius, bottomRadiusBase, tProgress)!;
        }
      }
    } else {
      // From half to full
      final halfVisualHeight = halfPos * mqHeight;
      final frozenScale = _frozenState?.bottomScale ?? 1.0;

      final halfPhysicalHeight = halfVisualHeight - widget.bottomMargin;
      final frozenBottomOffset =
          (_frozenState?.heightAtFreeze ?? halfPhysicalHeight) *
              (frozenScale - 1.0) /
              2.0;
      final frozenBottom = widget.bottomMargin - frozenBottomOffset;

      // Phase 1: Wrap corners (t: 0.0 -> 0.92) - movement is diagonal towards the screen corners.
      // Phase 2: Final sink (t: 0.92 -> 1.0) - the sheet submerges only when it's fully expanded.
      const transitionEnd = 0.92;
      final marginProgress = (t / transitionEnd).clamp(0.0, 1.0);
      final sinkProgress =
          ((t - transitionEnd) / (1.0 - transitionEnd)).clamp(0.0, 1.0);

      if (_frozenState != null) {
        final baseBottom = lerpDouble(frozenBottom, 0.0, marginProgress)!;
        effectiveBottom = lerpDouble(baseBottom, -extraHeight, sinkProgress)!;
      } else {
        final baseBottom =
            lerpDouble(widget.bottomMargin, 0.0, marginProgress)!;
        effectiveBottom = lerpDouble(baseBottom, -extraHeight, sinkProgress)!;
      }

      // Physical height adjusts so the top edge always stays at targetVisualHeight
      effectiveHeight = targetVisualHeight - effectiveBottom;

      // Edge to edge at the large detent, except in the strip layout, where
      // natively the sheet keeps its margins.
      hPad = lerpDouble(
        widget.horizontalMargin,
        _verticalBar == null ? 0.0 : widget.horizontalMargin,
        (t / 0.92).clamp(0.0, 1.0),
      )!;
      // Independent lerp for top and bottom radii
      final baseRadiusTop = lerpDouble(
          topRadiusBase,
          topRadiusBase * effectiveInteractionScale,
          _saturationAnimation.value)!;
      final baseRadiusBottom = lerpDouble(
          bottomRadiusBase,
          bottomRadiusBase * effectiveInteractionScale,
          _saturationAnimation.value)!;

      topRadius = lerpDouble(baseRadiusTop, topRadiusFull, t)!;
      bottomRadius = sinkProgress > 0
          ? lerpDouble(baseRadiusBottom, bottomRadiusFull, sinkProgress)!
          : baseRadiusBottom;
    }

    return _RenderMetrics(
      stretchT: stretchT,
      effectiveHeight: effectiveHeight,
      effectiveBottom: effectiveBottom - dismissOffset,
      topRadius: topRadius,
      bottomRadius: bottomRadius,
      hPad: hPad,
      colorOpacity: colorOpacity,
      glassOpacity: glassOpacity,
      effectiveSettings: effectiveSettings,
      interactionScale: effectiveInteractionScale,
      interactionStretch: effectiveInteractionStretch,
      effectiveExpandedColor: currentExpandedColor,
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // Build
  // ════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = GlassTheme.brightnessOf(context) == Brightness.dark;
    final effectiveExpandedColor = (isDark ? widget.expandedDarkColor : null) ??
        widget.expandedColor ??
        (isDark
            ? const Color(0xFF1C1C1E)
            : CupertinoColors.white); // 0xFF1C1C1E is systemGray6 in dark mode
    final effectiveQuality = GlassThemeHelpers.resolveQuality(
      context,
      widgetQuality: widget.quality,
      fallback: GlassQuality.premium,
    );
    final mqSize = MediaQuery.sizeOf(context);
    final mqHeight = mqSize.height;
    final mqPadding = MediaQuery.paddingOf(context);

    final adaptive = GlassThemeHelpers.resolveAdaptiveRadius(context);
    final topRadiusBase = widget.topBorderRadius ?? adaptive;
    final bottomRadiusBase = widget.bottomBorderRadius ?? adaptive;

    // Use explicit full radii if provided, otherwise default to a sensible constant
    // or fallback to the base radii.
    final topRadiusFull = widget.fullTopBorderRadius ?? topRadiusBase;
    final bottomRadiusFull = widget.fullBottomBorderRadius ?? bottomRadiusBase;

    final extraHeight = mqPadding.bottom + bottomRadiusBase;

    final baseSettings = GlassThemeHelpers.resolveSettings(
      context,
      explicit: widget.settings,
      fallback: kDefaultSheetSettings,
    );

    // Focus listener that snaps the sheet to full whenever a focusable
    // descendant gains focus (e.g. tapping a TextField inside the sheet).
    //
    // IMPORTANT: this Focus widget intentionally carries NO key.
    // Any key derived from `widget.child` (e.g. `GlobalObjectKey(widget.child)`)
    // changes every time the parent rebuilds — because the parent passes a
    // fresh `child` widget instance each frame — and Flutter responds to a
    // changed key by tearing down the entire child Element subtree and
    // rebuilding it. That destroys child State (calling `dispose` and
    // re-running `initState`) on every sheet expand/collapse, which surfaces
    // as scroll position resets, re-initialised controllers, re-fired fetches,
    // etc. The FocusNode is owned internally by the Focus widget's Element and
    // persists correctly without an external key.
    final focusBridge = Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus && _currentState != _geometry.maxState) {
          _snapToState(_geometry.maxState);
        }
      },
      child: widget.child,
    );

    return AnimatedBuilder(
      animation:
          Listenable.merge([_animationController, _saturationController]),
      builder: (context, _) {
        final fullPos =
            _geometry.positionForState(GlassSheetState.full, mqHeight);
        final halfPos =
            _geometry.positionForState(GlassSheetState.half, mqHeight);
        final minPos = _geometry.positionForState(_geometry.minState, mqHeight);

        double pos = _animationController.value;

        // Snap to exact positions when not dragging
        if (_gestureArena.phase == GesturePhase.idle) {
          if ((pos - halfPos).abs() < 0.002) pos = halfPos;
          if ((pos - fullPos).abs() < 0.002) pos = fullPos;
          if ((pos - minPos).abs() < 0.002) pos = minPos;
        }

        _currentPosition = pos;
        final t = _expandProgress;

        final metrics = _calculateMetrics(
          pos: pos,
          t: t,
          halfPos: halfPos,
          minPos: minPos,
          extraHeight: extraHeight,
          mqHeight: mqHeight,
          baseSettings: baseSettings,
          effectiveExpandedColor: effectiveExpandedColor,
          topRadiusBase: topRadiusBase,
          bottomRadiusBase: bottomRadiusBase,
          topRadiusFull: topRadiusFull,
          bottomRadiusFull: bottomRadiusFull,
          fullPos: fullPos,
        );

        _currentEffectiveHeight = metrics.effectiveHeight;

        // In the strip layout the sheet is a card no wider than the display's
        // shorter side, placed across the rest, and it takes the strip's
        // place where it covers it.
        final verticalBar = _verticalBar;
        final textDirection = Directionality.of(context);
        final frameInsets = verticalBar == null
            ? null
            : _stripSheetInsets(
                screenSize: mqSize,
                regularWidth: VerticalBarTitleRow.regularWidth(context),
                margin: metrics.hPad,
                placement: widget.placement,
                textDirection: textDirection,
              );
        // The content's safe area is the sheet's at rest — what is left of
        // the screen's lateral insets once the sheet's own are taken off —
        // and its bar follows the sheet's own strip, or stays horizontal.
        // Built the same way either side of a posture change, so the content
        // is never remounted.
        final restingInsets = verticalBar == null
            ? EdgeInsets.zero
            : _stripSheetInsets(
                screenSize: mqSize,
                regularWidth: VerticalBarTitleRow.regularWidth(context),
                margin: widget.horizontalMargin,
                placement: widget.placement,
                textDirection: textDirection,
              );
        final mediaQuery = MediaQuery.of(context);
        EdgeInsets inset(EdgeInsets padding) => padding.copyWith(
              left: math.max(0.0, padding.left - restingInsets.left),
              right: math.max(0.0, padding.right - restingInsets.right),
            );
        final content = GlassVerticalBar(
          data: _sheetVerticalBar(
            bar: verticalBar,
            frame: Rect.fromLTRB(
              restingInsets.left,
              (1.0 - _geometry.positionForState(_currentState, mqHeight)) *
                  mqHeight,
              mqSize.width - restingInsets.right,
              mqHeight,
            ),
            screenSize: mqSize,
            textDirection: textDirection,
          ),
          child: MediaQuery(
            data: mediaQuery.copyWith(
              padding: inset(mediaQuery.padding),
              viewPadding: inset(mediaQuery.viewPadding),
            ),
            child: focusBridge,
          ),
        );

        final fadedSettings = metrics.effectiveSettings.copyWith(
          glassColor: metrics.effectiveSettings.glassColor.withValues(
              alpha: metrics.effectiveSettings.glassColor.a *
                  metrics.glassOpacity),
          blur: metrics.effectiveSettings.blur * metrics.glassOpacity,
          lightIntensity:
              metrics.effectiveSettings.lightIntensity * metrics.glassOpacity,
          ambientStrength:
              metrics.effectiveSettings.ambientStrength * metrics.glassOpacity,
        );

        Widget result = _SheetLayout(
          interactionScale: metrics.interactionScale,
          enableInteractionGlow: widget.enableInteractionGlow,
          platformViewBackdrop: widget.platformViewBackdrop,
          glowColor: widget.glowColor,
          glowRadius: widget.glowRadius,
          stretch: widget.stretch,
          interactionStretch: metrics.interactionStretch,
          resistance: widget.resistance,
          left: frameInsets?.left ?? metrics.hPad,
          right: frameInsets?.right ?? metrics.hPad,
          effectiveBottom: metrics.effectiveBottom,
          effectiveHeight: metrics.effectiveHeight,
          topRadius: metrics.topRadius,
          bottomRadius: metrics.bottomRadius,
          showDragIndicator: widget.showDragIndicator,
          dragIndicatorColor: widget.dragIndicatorColor,
          dragIndicatorWidth: widget.dragIndicatorWidth,
          dragIndicatorHeight: widget.dragIndicatorHeight,
          dragIndicatorTopPadding: widget.dragIndicatorTopPadding,
          colorOpacity: metrics.colorOpacity,
          glassOpacity: metrics.glassOpacity,
          effectiveExpandedColor: metrics.effectiveExpandedColor,
          fadedSettings: fadedSettings,
          effectiveQuality: effectiveQuality,
          saturationAnimation: _saturationAnimation,
          expandProgress: t,
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerCancel,
          padding: widget.padding,
          scrollController: _scrollController,
          currentStateNotifier: _currentStateNotifier,
          expandProgressValue: t,
          contentScrollProgress: _contentScrollProgress,
          maintainContentGlass: widget.maintainContentGlass,
          fullStateContentSettings: widget.fullStateContentSettings,
          enableSaturationGlow: widget.enableSaturationGlow,
          enableTopFade: widget.enableTopFade,
          topFadeHeight: widget.topFadeHeight,
          onDismiss: () => _snapToState(GlassSheetState.hidden),
          suppressInteractionOnChildren: widget.suppressInteractionOnChildren,
          child: content,
        );

        // ScrollMetricsNotification covers content that has not been dragged
        // yet, so the first drag already knows whether the content can scroll.
        result = NotificationListener<ScrollMetricsNotification>(
          onNotification: (notification) {
            _recordContentMetrics(notification.metrics);
            return false;
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              _recordContentMetrics(notification.metrics);
              return false;
            },
            child: result,
          ),
        );

        if (widget.suppressInteractionOnChildren) {
          result = NotificationListener<InteractionNotification>(
            onNotification: (notification) {
              if (widget.suppressInteractionOnChildren) {
                _isInteractingWithChild = true;
              }
              return false;
            },
            child: result,
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: _onScrollNotification,
          child: result,
        );
      },
    );
  }
}

/// Minimal [ChangeNotifier] subclass that exposes [notifyListeners] publicly
/// via [notify], avoiding `invalid_use_of_protected_member` lint when the
/// controller is used as an animation listener target from outside the class.
class _ProgressNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
