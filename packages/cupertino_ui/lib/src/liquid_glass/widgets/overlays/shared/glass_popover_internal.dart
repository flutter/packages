part of '../glass_popover.dart';

class _GlassPopoverState extends State<GlassPopover>
    with TickerProviderStateMixin {
  final OverlayPortalController _overlayController = OverlayPortalController();

  late final GlassMorphController _morphController;

  /// Ramps the backdrop blur from `0` → [GlassPopover.settings]'s blur over the
  /// opening morph, so the expensive full-strength [BackdropFilter] is not paid
  /// on the cheap early frames (see [GlassPopover.blurRampDuration]).
  ///
  /// Driven independently of [_morphController] so the blur follows a clean,
  /// monotonic ease to full strength instead of wobbling with the morph
  /// spring's underdamped overshoot. Held at `1.0` (full blur, no animation)
  /// when the ramp is disabled or reduced-motion is active.
  late final AnimationController _blurRamp;

  Size? _triggerSize;
  double? _triggerBorderRadius;
  Offset _triggerGlobalPosition = Offset.zero;
  Offset _triggerOverlayPosition = Offset.zero;
  double _horizontalOffset = 0.0;
  double _verticalOffset = 0.0;

  Alignment _morphAlignment = Alignment.topLeft;

  /// Measured intrinsic height of the popover content.
  /// Only used when [widget.popoverHeight] is null.
  double? _measuredContentHeight;

  /// True once the first measurement pass has fired for the current open cycle,
  /// so we never queue a second [postFrameCallback] while the first is still
  /// pending or after measurement has settled.
  bool _contentMeasured = false;

  /// Cached widget subtree from [widget.contentBuilder].
  ///
  /// Set exactly once in [_openPopover] and again in [didUpdateWidget] when the
  /// widget configuration changes while the popover is showing. It is NEVER
  /// mutated inside [build] — that would violate Flutter's purity contract.
  Widget? _cachedContent;

  /// Key used to measure the intrinsic height of the content subtree.
  final GlobalKey _contentKey = GlobalKey();

  /// Guards against stacking multiple post-frame re-measure callbacks when the
  /// live content reports several size changes within one frame.
  bool _remeasureScheduled = false;

  /// Re-measures the live content after it changed size while the popover is
  /// open (e.g. a row growing taller after a state toggle) and grows/shrinks
  /// the popover to match, instead of overflowing the frozen initial height.
  void _scheduleRemeasure() {
    if (_remeasureScheduled || !_contentMeasured) return;
    _remeasureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _remeasureScheduled = false;
      if (!mounted || !_contentMeasured) return;
      final renderBox =
          _contentKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) return;
      final newHeight = renderBox.size.height;
      if (_measuredContentHeight != newHeight) {
        setState(() {
          _measuredContentHeight = newHeight;
          _updatePositionAndClamping();
        });
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Alignment helper
  // ---------------------------------------------------------------------------

  Alignment? _getAlignment(GlassMenuAlignment align) {
    switch (align) {
      case GlassMenuAlignment.none:
        return null;
      case GlassMenuAlignment.topLeft:
        return Alignment.topLeft;
      case GlassMenuAlignment.topCenter:
        return Alignment.topCenter;
      case GlassMenuAlignment.topRight:
        return Alignment.topRight;
      case GlassMenuAlignment.centerLeft:
        return Alignment.centerLeft;
      case GlassMenuAlignment.center:
        return Alignment.center;
      case GlassMenuAlignment.centerRight:
        return Alignment.centerRight;
      case GlassMenuAlignment.bottomLeft:
        return Alignment.bottomLeft;
      case GlassMenuAlignment.bottomCenter:
        return Alignment.bottomCenter;
      case GlassMenuAlignment.bottomRight:
        return Alignment.bottomRight;
    }
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _blurRamp = AnimationController(
      vsync: this,
      // A valid non-zero duration for the controller even when the ramp is
      // disabled (Duration.zero) — in that case it is never driven, just held
      // at full. The real duration is (re)applied in [_startMorphOpen].
      duration: widget.blurRampDuration > Duration.zero
          ? widget.blurRampDuration
          : const Duration(milliseconds: 260),
      // Start full so any paint before the first open (or a disabled ramp) is
      // never under-blurred; [_startMorphOpen] forces it back to 0 on open.
      value: 1.0,
    );
    _morphController = GlassMorphController(vsync: this);
    _morphController.addListener(() {
      // Hide the overlay only when the spring has FULLY SETTLED near zero.
      // The velocity guard prevents premature hiding on the first zero-crossing
      // during the underdamped close bounce.
      if (_overlayController.isShowing &&
          _morphController.value <= 0.001 &&
          _morphController.velocity.abs() < 0.5 &&
          _morphController.status != AnimationStatus.forward) {
        if (SchedulerBinding.instance.schedulerPhase ==
            SchedulerPhase.persistentCallbacks) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (mounted && _overlayController.isShowing) {
              _overlayController.hide();
              _blurRamp.value = 0.0;
              setState(() {
                _horizontalOffset = 0.0;
                _verticalOffset = 0.0;
                _measuredContentHeight = null;
                _contentMeasured = false;
                _cachedContent = null;
              });
            }
          });
        } else {
          _overlayController.hide();
          // Reset per-open-cycle state so stale values from a previous position
          // never bleed into the next open cycle.
          // Reset the blur ramp to sharp so the next open blooms in from 0 again
          // (it was frozen mid-value by _closePopover, not wound back).
          _blurRamp.value = 0.0;
          setState(() {
            _horizontalOffset = 0.0;
            _verticalOffset = 0.0;
            _measuredContentHeight = null;
            _contentMeasured = false;
            _cachedContent = null;
          });
        }
      }
    });
  }

  List<ModalRoute<dynamic>> _routes = const <ModalRoute<dynamic>>[];

  @override
  void dispose() {
    _removeRouteListeners();
    _routes = const [];
    _blurRamp.dispose();
    _morphController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync the reduced-motion accessibility flag to the morph controller.
    _morphController.setDisableAnimations(
      GlassAccessibilityData.of(context).reduceMotion,
    );
    _updateRouteListener();
  }

  List<ModalRoute<dynamic>> _findAncestorRoutes() {
    final routes = <ModalRoute<dynamic>>[];
    final visited = <ModalRoute<dynamic>>{};
    ModalRoute<dynamic>? route = ModalRoute.of(context);
    while (route != null && visited.add(route)) {
      routes.add(route);
      final nav = route.navigator;
      if (nav == null || !nav.mounted) break;
      route = ModalRoute.of(nav.context);
    }
    return routes;
  }

  void _updateRouteListener() {
    final currentRoutes = _findAncestorRoutes();
    if (!_routesEqual(_routes, currentRoutes)) {
      _removeRouteListeners();
      _routes = currentRoutes;
      _addRouteListeners();
    }
  }

  static bool _routesEqual(
    List<ModalRoute<dynamic>> a,
    List<ModalRoute<dynamic>> b,
  ) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _addRouteListeners() {
    for (final route in _routes) {
      route.secondaryAnimation
          ?.addStatusListener(_handleSecondaryAnimationStatus);
      route.animation?.addStatusListener(_handlePrimaryAnimationStatus);
    }
  }

  void _removeRouteListeners() {
    for (final route in _routes) {
      route.secondaryAnimation
          ?.removeStatusListener(_handleSecondaryAnimationStatus);
      route.animation?.removeStatusListener(_handlePrimaryAnimationStatus);
    }
  }

  void _handleSecondaryAnimationStatus(AnimationStatus status) {
    if (!_overlayController.isShowing) return;
    if (status == AnimationStatus.forward) {
      _dismissImmediately();
    }
  }

  void _handlePrimaryAnimationStatus(AnimationStatus status) {
    if (!_overlayController.isShowing) return;
    if (status == AnimationStatus.reverse) {
      _dismissImmediately();
    }
  }

  void _dismissImmediately() {
    if (!_overlayController.isShowing && _morphController.value == 0.0) {
      return;
    }
    // Never call hide(), reset(), or setState() synchronously during
    // persistent callbacks (e.g. declarative Navigator.pages / go_router updates).
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _dismissImmediately();
        }
      });
      return;
    }
    final wasClosing = _morphController.isClosing;
    if (_overlayController.isShowing) {
      _overlayController.hide();
    }
    _morphController.reset();
    _blurRamp.stop();
    _blurRamp.value = 0.0;
    _horizontalOffset = 0.0;
    _verticalOffset = 0.0;
    _measuredContentHeight = null;
    _contentMeasured = false;
    _cachedContent = null;
    if (!wasClosing) {
      widget.onClose?.call();
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(GlassPopover oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the popover is showing and the widget configuration changed, refresh
    // the cached content tree so the user sees up-to-date data. This is the
    // correct lifecycle hook — never do this inside build().
    if (_overlayController.isShowing &&
        (oldWidget.contentBuilder != widget.contentBuilder ||
            oldWidget.popoverWidth != widget.popoverWidth ||
            oldWidget.popoverHeight != widget.popoverHeight)) {
      setState(() {
        _cachedContent = widget.contentBuilder(context, _closePopover);
      });
    }
    // If the blur ramp params changed while a ramp is actively running, apply
    // the new duration immediately so the current cycle uses it. The new curve
    // is picked up automatically on the next _blurFactor read (it reads
    // widget.blurRampCurve directly). No restart needed — the controller
    // continues from its current value with the updated duration.
    if (oldWidget.blurRampDuration != widget.blurRampDuration ||
        oldWidget.blurRampCurve != widget.blurRampCurve) {
      if (_blurRamp.isAnimating) {
        _blurRamp.duration = widget.blurRampDuration > Duration.zero
            ? widget.blurRampDuration
            : const Duration(milliseconds: 260);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Mirror the GlassMenu structure exactly:
    //   AnimatedBuilder (top-level, no render object) →
    //     builder returns Stack([trigger, OverlayPortal])
    //
    // This matters for _openPopover(): context.findRenderObject() traverses
    // down from the GlassPopover element. Because AnimatedBuilder has NO render
    // object, it keeps descending into the builder's returned Stack. That Stack
    // is always sized to the trigger button, so localToGlobal(Offset.zero) gives
    // the correct global position of the trigger on screen.
    //
    // If we return an outer Stack from build() instead, findRenderObject() stops
    // at the outer Stack, whose origin can be corrupted by the OverlayPortal
    // sibling when the overlay is visible.
    //
    // The trigger is passed as AnimatedBuilder's `child` (not rebuilt inside
    // the builder closure) so it is stable across animation ticks.
    final Widget triggerContent = widget.triggerBuilder != null
        ? widget.triggerBuilder!(context, _togglePopover)
        // A plain trigger (an icon, a text) gets the button role here; its
        // text, if any, merges into this node as the name.
        : Semantics(
            container: true,
            button: true,
            label: widget.semanticLabel,
            child: GestureDetector(
              onTap: _togglePopover,
              child: widget.trigger,
            ),
          );

    return AnimatedBuilder(
      animation: _morphController.animation,
      builder: (context, child) {
        final rawValue = _morphController.value;

        // Block trigger taps while the popover is meaningfully open.
        final isPopoverBlocking =
            _overlayController.isShowing && rawValue > 0.8;

        // During the closing handoff the real trigger becomes visible again
        // and inherits the liquid momentum from the collapsing blob.
        final isHandoff =
            _morphController.isClosing && _morphController.hasHandedOff;

        // Tactile detach and re-merge trigger opacity.
        //
        // On open: The trigger smoothly dissolves (1.0 -> 0.0) over the first
        // 20% of travel as the droplet pulls away. Once detached, the trigger
        // is cleanly hidden (no ghosting artifacts while reading items).
        //
        // On close: As the droplet approaches home (clampedValue < 0.20),
        // the trigger smoothly cross-dissolves back in (0.0 -> 1.0) while the
        // overlay fades out, eliminating any 1-frame pop at handoff.
        // Once handoff fires, the trigger is fully opaque to absorb the bounce.
        final double triggerOpacity;
        final clampedValue = rawValue.clamp(0.0, 1.0);
        if (!_overlayController.isShowing || isHandoff) {
          triggerOpacity = 1.0;
        } else if (!_morphController.isClosing) {
          final detachT = (clampedValue / 0.20).clamp(0.0, 1.0);
          triggerOpacity = 1.0 - detachT;
        } else {
          // While closing, the real trigger stays hidden. Blob A inside the
          // overlay represents the trigger and fuses with the returning droplet.
          // When handoff fires at rawValue <= 0.0, triggerOpacity becomes 1.0.
          triggerOpacity = 0.0;
        }

        // Push vector: the trigger physically recoils as the popover snaps shut.
        // These values mirror _buildMorphingOverlay's finalDx/finalDy so the
        // trajectory is mathematically identical to the blob's path.
        final tw = _triggerSize?.width ?? 44.0;
        final th = _triggerSize?.height ?? 44.0;
        final dxMag = (widget.popoverWidth - tw) / 2.0;
        final dyMag = (_effectivePopoverHeight() - th) / 2.0;
        final double pushDx = isHandoff
            ? (-_morphAlignment.x * dxMag + _horizontalOffset) * rawValue
            : 0.0;
        final double pushDy = isHandoff
            ? (-_morphAlignment.y * dyMag + _verticalOffset) * rawValue
            : 0.0;

        // Underdamped bounce impact squash: as the droplet slams into the trigger,
        // the button compresses slightly and rebounds to rest, giving a visceral
        // tactile sensation of liquid absorption.
        final double impactScale =
            isHandoff ? (1.0 + rawValue * 0.35).clamp(0.88, 1.0) : 1.0;

        final outer = GlassMaterializeScope.maybeOf(context);

        final bool hasTransform =
            pushDx != 0.0 || pushDy != 0.0 || impactScale != 1.0;

        Widget triggerWidget = Opacity(
          opacity: triggerOpacity,
          child: GlassMaterializeScope(
            glassProgress: triggerOpacity * (outer?.glassProgress ?? 1.0),
            contentOpacity: triggerOpacity * (outer?.contentOpacity ?? 1.0),
            contentSigma: outer?.contentSigma ?? 0.0,
            child: IgnorePointer(
              ignoring: isPopoverBlocking,
              child: child, // triggerContent
            ),
          ),
        );

        if (impactScale != 1.0) {
          triggerWidget = Transform.scale(
            scale: impactScale,
            child: triggerWidget,
          );
        }

        if (pushDx != 0.0 || pushDy != 0.0) {
          triggerWidget = Transform.translate(
            offset: Offset(pushDx, pushDy),
            child: triggerWidget,
          );
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Trigger ────────────────────────────────────────────────────
            // Only apply Transform/Opacity/IgnorePointer layers when actually needed
            // to prevent unnecessary compositing layers that cause BackdropFilter
            // flickering (Premium quality) during scroll.
            hasTransform
                ? triggerWidget
                : triggerOpacity < 1.0
                    ? triggerWidget
                    : isPopoverBlocking
                        ? IgnorePointer(
                            ignoring: true,
                            child: child,
                          )
                        : child ??
                            const SizedBox
                                .shrink(), // Raw trigger when completely idle

            // ── Overlay portal ─────────────────────────────────────────────
            // OverlayPortal renders in the overlay layer, not in-tree, so it
            // is zero-sized here and does not affect the Stack's dimensions.
            //
            // Target the NEAREST overlay so the popover stays confined to the
            // page/route where it was opened (#274). When a new route is pushed
            // onto this or an ancestor Navigator, the destination route renders
            // above this overlay, so the closing animation naturally remains on
            // the outgoing page behind the transition. The trigger position is
            // mapped into the nearest overlay's coordinate space in _openPopover
            // to avoid drift in nested embeddings.
            OverlayPortal(
              controller: _overlayController,
              overlayLocation: OverlayChildLocation.nearestOverlay,
              overlayChildBuilder: _buildMorphingOverlay,
            ),
          ],
        );
      },
      child: triggerContent,
    );
  }

  // ---------------------------------------------------------------------------
  // Popover open / close
  // ---------------------------------------------------------------------------

  void _togglePopover() {
    if (_overlayController.isShowing && _morphController.value > 0.1) {
      _closePopover();
    } else {
      _openPopover();
    }
  }

  // ---------------------------------------------------------------------------
  // Blur ramp (see GlassPopover.blurRampDuration)
  // ---------------------------------------------------------------------------

  /// Whether the backdrop-blur ramp should run for this open cycle. Disabled
  /// when the caller opts out ([GlassPopover.blurRampDuration] == zero) or when
  /// reduced-motion is active — in both cases the blur is shown at full
  /// strength immediately.
  bool get _blurRampEnabled =>
      widget.blurRampDuration > Duration.zero &&
      !_morphController.disableAnimations;

  /// The current fraction (`0` → `1`) of [GlassPopover.settings]'s blur to
  /// apply this frame. `1.0` means full strength.
  double get _blurFactor {
    if (!_blurRampEnabled) return 1.0;
    return widget.blurRampCurve.transform(_blurRamp.value.clamp(0.0, 1.0));
  }

  /// Launches the morph and, in lock-step, the blur ramp. Called at every point
  /// the morph actually starts opening (immediately for fixed-height popovers,
  /// or after the intrinsic-height measurement pass).
  void _startMorphOpen() {
    _morphController.open();
    if (_blurRampEnabled) {
      _blurRamp
        ..duration = widget.blurRampDuration
        ..forward(from: 0.0);
    } else {
      // No ramp — show the blur at full strength from the first painted frame.
      _blurRamp.value = 1.0;
    }
  }

  void _closePopover() {
    if (!mounted || !_overlayController.isShowing) return;
    // Freeze the blur where it is for the collapse. Ramping it back down here
    // would race the morph and read as the blur "popping off" while the blob is
    // still visibly shrinking; holding it keeps the close visually coherent.
    // It is reset to 0 when the overlay finally hides (see the initState
    // listener), so the next open still ramps from sharp.
    _blurRamp.stop();
    // GlassMorphController.close() injects the −2.5 velocity hint internally,
    // maximising the rubber-band bounce amplitude on close.
    _morphController.close();
    widget.onClose?.call();
  }

  void _openPopover() {
    _updateRouteListener();
    // context.findRenderObject() works correctly here because build() returns
    // AnimatedBuilder at the top level. AnimatedBuilder has no render object of
    // its own, so the traversal descends into the builder's returned Stack,
    // which is always sized to the trigger button. localToGlobal therefore gives
    // the trigger's actual screen position.
    final renderBox = context.findRenderObject() as RenderBox?;

    if (renderBox == null || !renderBox.hasSize) return;

    _triggerSize = renderBox.size;
    _triggerBorderRadius = _triggerSize!.height / 2;
    _triggerGlobalPosition = renderBox.localToGlobal(Offset.zero);
    final overlay = Overlay.maybeOf(context);
    final overlayBox = overlay?.context.findRenderObject() as RenderBox?;
    _triggerOverlayPosition = overlayBox != null
        ? renderBox.localToGlobal(Offset.zero, ancestor: overlayBox)
        : _triggerGlobalPosition;

    // Build the content widget exactly once for this open cycle. All
    // subsequent frames read _cachedContent; didUpdateWidget refreshes it
    // if the parent rebuilds with changed props while the popover is open.
    _cachedContent = widget.contentBuilder(context, _closePopover);

    // If popoverHeight is explicitly provided, measurement is already known.
    // Mark it measured so the Offstage pass is skipped and we open immediately.
    _contentMeasured = widget.popoverHeight != null;

    // Compute alignment / clamping offsets and notify Flutter in a single
    // setState so the first overlay build sees fully consistent values.
    // If popoverHeight is null, we can't compute clamping yet — the first
    // frame will be an invisible Offstage measurement pass instead.
    setState(() {
      if (_contentMeasured) {
        _updatePositionAndClamping();
      }
      _overlayController.show();
    });

    if (_contentMeasured) {
      _startMorphOpen();
    }
    widget.onOpen?.call();
  }

  // ---------------------------------------------------------------------------
  // Layout helpers
  // ---------------------------------------------------------------------------

  /// Returns the maximum height the popover may occupy, bounded by the
  /// safe-area-inset screen height.
  ///
  /// Falls back to a finite sentinel (800 dp) instead of [double.infinity]
  /// so downstream lerp / arithmetic never yields NaN or Infinity when
  /// [MediaQuery] is unavailable (e.g. in some test environments).
  double _getMaxPopoverHeight([EdgeInsets? precomputedPadding]) {
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) return 800.0;

    final screenHeight = mediaQuery.size.height;
    final insets = precomputedPadding ?? _viewInsets();
    final double safeTop = widget.screenPadding.top + insets.top;
    final double safeBottom = widget.screenPadding.bottom + insets.bottom;
    return math.max(0.0, screenHeight - safeTop - safeBottom);
  }

  /// Computes [EdgeInsets] from the platform view padding once so callers
  /// that need both max-height and edge clamping share the same values.
  EdgeInsets _viewInsets() {
    final flutterView = View.of(context);
    return EdgeInsets.fromViewPadding(
        flutterView.padding, flutterView.devicePixelRatio);
  }

  double _effectivePopoverHeight([EdgeInsets? precomputedPadding]) {
    if (widget.popoverHeight != null) return widget.popoverHeight!;
    final maxH = _getMaxPopoverHeight(precomputedPadding);
    // By the time the morph animation uses this value, _measuredContentHeight
    // is guaranteed to be populated via the Offstage measurement pass.
    return math.min(_measuredContentHeight ?? 0.0, maxH);
  }

  /// Recomputes [_morphAlignment], [_horizontalOffset], and [_verticalOffset]
  /// from the current trigger geometry and screen metrics.
  ///
  /// Must only be called when [_triggerSize] is non-null.
  /// Safe to call inside a [setState] callback; it only mutates fields and
  /// never calls [setState] itself.
  void _updatePositionAndClamping() {
    if (_triggerSize == null) return;

    final position = _triggerGlobalPosition;
    final mediaQuery = MediaQuery.maybeOf(context);
    final screenWidth = mediaQuery?.size.width ?? double.infinity;
    final screenHeight = mediaQuery?.size.height ?? double.infinity;

    // Compute view insets once and share between max-height and clamping.
    final insets = _viewInsets();
    final popoverHeight = _effectivePopoverHeight(insets);

    // 1. Determine alignment (auto vs. manual)
    final stripAlignment = verticalBarPresentationAlignment(
      context,
      position & _triggerSize!,
    );
    if ((widget.alignment == null ||
            widget.alignment == GlassMenuAlignment.none) &&
        stripAlignment != null) {
      // From iPhone Duo's vertical bar strip: towards the content.
      _morphAlignment = stripAlignment;
    } else if (widget.alignment == null ||
        widget.alignment == GlassMenuAlignment.none) {
      final isRightHalf = screenWidth.isFinite && position.dx > screenWidth / 2;

      final spaceBelow = screenHeight.isFinite
          ? screenHeight - (position.dy + _triggerSize!.height)
          : double.infinity;
      final spaceAbove = screenHeight.isFinite ? position.dy : double.infinity;

      final shouldFlipVertical =
          spaceBelow < popoverHeight && spaceAbove > popoverHeight;

      _morphAlignment = shouldFlipVertical
          ? (isRightHalf ? Alignment.bottomRight : Alignment.bottomLeft)
          : (isRightHalf ? Alignment.topRight : Alignment.topLeft);
    } else {
      _morphAlignment = _getAlignment(widget.alignment!) ?? Alignment.center;
    }

    // 2. Edge clamping: compute offsets to keep the popover within the safe area
    double hOffset = 0.0;
    double vOffset = 0.0;

    if (widget.autoAdjustToScreen) {
      final double safeTop = widget.screenPadding.top + insets.top;
      final double safeBottom = widget.screenPadding.bottom + insets.bottom;
      // The strip's inset is no bar to a popover opened out of the strip,
      // which natively lies over the item it came from.
      final double safeLeft = widget.screenPadding.left +
          (stripAlignment == null ? insets.left : 0.0);
      final double safeRight = widget.screenPadding.right +
          (stripAlignment == null ? insets.right : 0.0);

      final double targetX =
          position.dx + (1 + _morphAlignment.x) * _triggerSize!.width / 2;
      final double targetY =
          position.dy + (1 + _morphAlignment.y) * _triggerSize!.height / 2;
      final double popoverLeft =
          targetX - (1 + _morphAlignment.x) * widget.popoverWidth / 2;
      final double popoverTop =
          targetY - (1 + _morphAlignment.y) * popoverHeight / 2;

      // Horizontal
      if (popoverLeft < safeLeft) {
        hOffset = safeLeft - popoverLeft;
      } else if (screenWidth.isFinite &&
          popoverLeft + widget.popoverWidth > screenWidth - safeRight) {
        hOffset =
            (screenWidth - safeRight) - (popoverLeft + widget.popoverWidth);
      }

      // Vertical
      if (popoverTop < safeTop) {
        vOffset = safeTop - popoverTop;
      } else if (screenHeight.isFinite &&
          popoverTop + popoverHeight > screenHeight - safeBottom) {
        vOffset = (screenHeight - safeBottom) - (popoverTop + popoverHeight);
      }
    }

    _horizontalOffset = hOffset;
    _verticalOffset = vOffset;
  }

  // ---------------------------------------------------------------------------
  // Overlay rendering
  // ---------------------------------------------------------------------------

  Widget _buildMorphingOverlay(BuildContext context) {
    if (_triggerSize == null) return const SizedBox.shrink();

    if (!_contentMeasured) {
      // Invisible measurement pass.
      // Renders the content offstage to allow Flutter's layout engine to
      // synchronously calculate its exact intrinsic height before we launch
      // the morph animation on the very next frame.
      return Offstage(
        child: OverflowBox(
          alignment: Alignment.center,
          minWidth: widget.popoverWidth,
          maxWidth: widget.popoverWidth,
          minHeight: 0,
          maxHeight: double.infinity,
          child: Builder(builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || _contentMeasured) return;
              final renderBox =
                  _contentKey.currentContext?.findRenderObject() as RenderBox?;
              if (renderBox != null && renderBox.hasSize) {
                setState(() {
                  _measuredContentHeight = renderBox.size.height;
                  _contentMeasured = true;
                  _updatePositionAndClamping();
                });
                _startMorphOpen();
              }
            });
            return SizedBox(
              key: _contentKey,
              width: widget.popoverWidth,
              child: _cachedContent ?? const SizedBox.shrink(),
            );
          }),
        ),
      );
    }

    // ── Values computed ONCE per overlay build ──────────────────────────────
    // These are hoisted outside AnimatedBuilder so they are never recomputed
    // on every animation tick (60 fps). They only change when the overlay is
    // rebuilt due to a setState (open, close-complete, or measurement update).

    final tw = _triggerSize!.width;
    final th = _triggerSize!.height;
    final popoverWidth = widget.popoverWidth;
    final popoverHeight = _effectivePopoverHeight();

    final dxMag = (popoverWidth - tw) / 2.0;
    final dyMag = (popoverHeight - th) / 2.0;
    final finalDx = -_morphAlignment.x * dxMag;
    final finalDy = -_morphAlignment.y * dyMag;

    // InheritedWidget lookups — traverses the element tree; must NOT be inside
    // the AnimatedBuilder's builder closure.
    final inheritedSettings = InheritedLiquidGlass.of(context);
    final effectiveSettings = widget.settings ??
        inheritedSettings ??
        const LiquidGlassSettings(
          blur: 10,
          thickness: 10,
          glassColor: Color.fromRGBO(255, 255, 255, 0.12),
          lightAngle: GlassDefaults.lightAngle,
          lightIntensity: 0.7,
          ambientStrength: 0.4,
          saturation: 1.2,
          refractiveIndex: 0.7,
          chromaticAberration: 0.0,
        );

    final effectiveQuality = GlassThemeHelpers.resolveQuality(
      context,
      widgetQuality: widget.quality,
    );

    // LiquidGlassBlendGroup requires an InheritedGeometryRenderLink from a
    // parent LiquidGlassLayer. In minimal quality mode we skip the layer
    // (and thus the blend group) to avoid the assert / null crash (issue #214).
    final bool useBlendGroup = effectiveQuality != GlassQuality.minimal;
    final bool isPremium = effectiveQuality == GlassQuality.premium &&
        ImageFilter.isShaderFilterSupported;

    final isDark = GlassTheme.brightnessOf(context) == Brightness.dark;

    // ── Per-frame AnimatedBuilder ────────────────────────────────────────────
    // Listens to BOTH the morph spring and the blur ramp so the backdrop blur
    // repaints as it eases in, independently of where the morph spring is.
    return AnimatedBuilder(
      animation: Listenable.merge([_morphController.animation, _blurRamp]),
      builder: (context, child) {
        final rawValue = _morphController.value;
        final clampedValue = rawValue.clamp(0.0, 1.0);

        // Ease the backdrop blur in over the opening morph instead of paying
        // its full raster cost from frame one. A factor of 1 (ramp complete or
        // disabled) reuses the hoisted settings unchanged — no per-frame alloc.
        final blurFactor = _blurFactor;
        final rampedSettings = blurFactor >= 1.0
            ? effectiveSettings
            : effectiveSettings.copyWith(
                blur: effectiveSettings.blur * blurFactor,
              );

        // Physics delegated to GlassMorphController — pure arithmetic, no
        // tree traversal, safe at 60 fps.
        final state = _morphController.computeState(
          finalDx: finalDx,
          finalDy: finalDy,
          horizontalOffset: _horizontalOffset,
          verticalOffset: _verticalOffset,
        );

        final currentHeight = lerpDouble(th, popoverHeight, state.sizeT)!;
        final currentWidth = lerpDouble(tw, popoverWidth, state.sizeT)!;

        final double effectiveDx;
        final double effectiveDy;
        if (_morphController.isClosing) {
          if (isPremium) {
            effectiveDx = finalDx * state.pathT;
            effectiveDy = finalDy * state.pathT;
          } else {
            effectiveDx = finalDx * state.sizeT;
            effectiveDy = finalDy * state.sizeT;
          }
        } else {
          effectiveDx = state.currentDx;
          effectiveDy = state.currentDy;
        }

        // Solid overlay during flight and metaball fusion.
        // Handoff to the real trigger button occurs cleanly when hasHandedOff fires (rawValue <= 0.0).
        final double overlayOpacity =
            (_morphController.isClosing && _morphController.hasHandedOff)
                ? 0.0
                : 1.0;

        return Stack(
          children: [
            // ── Tap-to-close barrier ─────────────────────────────────────────
            if (clampedValue > 0.3 && widget.barrierDismissible)
              Positioned.fill(
                // Named like Flutter's ModalBarrier so a screen reader can
                // close the popover as well as a pointer can.
                child: Semantics(
                  container: true,
                  label: glassCupertinoLocalizationsOf(context)
                      .modalBarrierDismissLabel,
                  onDismiss: _closePopover,
                  onTap: _closePopover,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    excludeFromSemantics: true,
                    onTap: _closePopover,
                    child: const ColoredBox(color: Color(0x00000000)),
                  ),
                ),
              ),

            // ── Non-dismissible barrier (absorbs taps without closing) ───────
            if (clampedValue > 0.3 && !widget.barrierDismissible)
              const Positioned.fill(
                child: AbsorbPointer(),
              ),

            // ── Two-blob metaball morphing ───────────────────────────────────
            Positioned.fill(
              child: Opacity(
                opacity: overlayOpacity,
                child: LiquidGlassLayer(
                  settings: rampedSettings,
                  child: InheritedLiquidGlass(
                    settings: rampedSettings,
                    quality: effectiveQuality,
                    isBlurProvidedByAncestor: false,
                    child: Builder(
                      builder: (context) {
                        final blobStack = Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // ── Blob A: Trigger ghost ────────────────────────
                            // Stays centred on the trigger and shrinks to 0
                            // over the first 40 % of the open animation,
                            // smoothly breaking the liquid bridge.
                            // Suppressed during close on standard/minimal quality
                            // to avoid duplicate button overlap.
                            if (!_morphController.isClosing || isPremium)
                              Positioned(
                                left: _triggerOverlayPosition.dx + state.pushDx,
                                top: _triggerOverlayPosition.dy + state.pushDy,
                                child: Transform.scale(
                                  scale: state.anchorScale,
                                  child: GlassContainer(
                                    useOwnLayer: false,
                                    settings: rampedSettings,
                                    quality: effectiveQuality,
                                    width: tw,
                                    height: th,
                                    shape: LiquidRoundedRectangle(
                                      borderRadius: _triggerBorderRadius ??
                                          _triggerSize!.shortestSide / 2.0,
                                    ),
                                  ),
                                ),
                              ),

                            // ── Blob B: Popover body ─────────────────────────
                            Positioned(
                              left: _triggerOverlayPosition.dx +
                                  tw / 2.0 +
                                  effectiveDx -
                                  currentWidth / 2.0 +
                                  (_horizontalOffset * clampedValue),
                              top: _triggerOverlayPosition.dy +
                                  th / 2.0 +
                                  effectiveDy -
                                  currentHeight / 2.0 +
                                  (_verticalOffset * clampedValue),
                              child: IgnorePointer(
                                ignoring: clampedValue < 0.8,
                                child: _buildPopoverContainer(
                                  state,
                                  clampedValue,
                                  currentWidth,
                                  currentHeight,
                                  rampedSettings,
                                  effectiveQuality,
                                  isDark,
                                  popoverHeight,
                                ),
                              ),
                            ),
                          ],
                        );

                        // Only wrap in LiquidGlassBlendGroup when the parent
                        // LiquidGlassLayer has provided an
                        // InheritedGeometryRenderLink. In minimal quality mode
                        // that layer should be skipped, so the blend group
                        // must be too (issue #214).
                        return useBlendGroup
                            ? LiquidGlassBlendGroup(
                                blend: state.blend,
                                child: blobStack,
                              )
                            : blobStack;
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPopoverContainer(
    LiquidMorphState state,
    double clampedValue,
    double currentWidth,
    double currentHeight,
    LiquidGlassSettings effectiveSettings,
    GlassQuality effectiveQuality,
    bool isDark,
    double targetHeight,
  ) {
    // Morph border radius from pill → target corner radius.
    final maxRadius = math.min(currentWidth, currentHeight) / 2.0;
    final double radiusT =
        Curves.easeInExpo.transform(state.sizeT.clamp(0.0, 1.0));
    final bool isPremium = effectiveQuality == GlassQuality.premium &&
        ImageFilter.isShaderFilterSupported;
    final currentRadius = _morphController.isClosing
        ? (isPremium
            ? maxRadius
            : lerpDouble(
                _triggerBorderRadius ?? (_triggerSize!.shortestSide / 2.0),
                widget.popoverBorderRadius,
                radiusT,
              )!)
        : lerpDouble(maxRadius, widget.popoverBorderRadius, radiusT)!;

    final teardropShape = LiquidRoundedRectangle(
      borderRadius: currentRadius,
    );

    return LiquidStretch(
      stretch: widget.stretch,
      interactionScale: widget.interactionScale,
      resistance: widget.stretchResistance,
      axis: widget.stretchAxis,
      suppressInteractionOnChildren: false,
      anchorStretch: false,
      allowPositiveX: widget.allowPositiveX ?? (_morphAlignment.x < 0),
      allowNegativeX: widget.allowNegativeX ?? (_morphAlignment.x > 0),
      allowPositiveY: widget.allowPositiveY ?? (_morphAlignment.y < 0),
      allowNegativeY: widget.allowNegativeY ?? (_morphAlignment.y > 0),
      child: GlassContainer(
        useOwnLayer: false,
        settings: effectiveSettings,
        quality: effectiveQuality,
        allowElevation: false,
        width: currentWidth,
        height: currentHeight,
        shape: teardropShape,
        clipBehavior: Clip.antiAlias,
        glowIntensity: widget.glowIntensity,
        child: GlassGlow(
          enabled: widget.enableInteractionGlow,
          glowOnTapOnly: widget.glowOnTapOnly,
          glowColor: widget.glowColor ??
              (isDark
                  ? CupertinoColors.white
                      .withValues(alpha: GlassDefaults.specularLightAlpha)
                  : CupertinoColors.black
                      .withValues(alpha: GlassDefaults.specularDarkAlpha)),
          glowRadius: widget.glowRadius,
          glowBlurRadius: 40,
          clipper: ShapeBorderClipper(shape: teardropShape),
          child: Transform.scale(
            scale: state.containerScale,
            alignment: Alignment.center,
            child: Stack(
              alignment: _morphAlignment,
              clipBehavior: Clip.none,
              children: [
                // Content enters at 30 % morph progress and scales 0.5 → 1.0.
                // On close the reverse plays, matching GlassMenu behaviour.
                if (_morphController.isClosing
                    ? clampedValue > 0.85
                    : clampedValue > 0.3)
                  _buildContentWithMeasurement(clampedValue, targetHeight),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentWithMeasurement(
      double clampedValue, double targetHeight) {
    // Fade in smoothly: fully opaque by 70 % morph progress.
    final contentOpacity = _morphController.isClosing
        ? ((clampedValue - 0.85) / 0.15).clamp(0.0, 1.0)
        : ((clampedValue - 0.3) / 0.4).clamp(0.0, 1.0);

    // Scale 0.5 → 1.0 with easeOut, in sync with the expanding container.
    final contentScale = lerpDouble(
      0.5,
      1.0,
      Curves.easeOut.transform(
        ((clampedValue - 0.3) / 0.7).clamp(0.0, 1.0),
      ),
    )!;

    // _cachedContent was set in _openPopover (or refreshed in didUpdateWidget).
    // The null-coalesce is a last-resort safety net only.
    final content =
        _cachedContent ?? widget.contentBuilder(context, _closePopover);

    Widget measuredContent;
    if (widget.popoverHeight == null) {
      // Intrinsic-height mode: track live size changes (content growing or
      // shrinking while open) and re-measure, so the popover follows instead
      // of overflowing the height frozen at open time.
      measuredContent = NotificationListener<SizeChangedLayoutNotification>(
        onNotification: (_) {
          _scheduleRemeasure();
          return true;
        },
        child: SizeChangedLayoutNotifier(
          child: SizedBox(
            key: _contentKey,
            width: widget.popoverWidth,
            child: content,
          ),
        ),
      );
    } else {
      measuredContent = SizedBox(
        width: widget.popoverWidth,
        height: widget.popoverHeight,
        child: content,
      );
    }

    // OverflowBox provides the full target size to the content during layout
    // while the container is still morphing. The visual illusion is maintained
    // by the Transform.scale above; GlassContainer's Clip.antiAlias clips
    // anything outside the current morph boundary.
    return OverflowBox(
      alignment: Alignment.center,
      minWidth: widget.popoverWidth,
      maxWidth: widget.popoverWidth,
      minHeight: 0,
      // Intrinsic mode is bounded by the screen (not the frozen measurement)
      // so the content can re-layout to a new natural height and the
      // SizeChangedLayoutNotifier above can report it for re-measurement.
      maxHeight: widget.popoverHeight ?? _getMaxPopoverHeight(),
      child: Opacity(
        opacity: contentOpacity,
        child: Transform.scale(
          scale: contentScale,
          child: measuredContent,
        ),
      ),
    );
  }
}
