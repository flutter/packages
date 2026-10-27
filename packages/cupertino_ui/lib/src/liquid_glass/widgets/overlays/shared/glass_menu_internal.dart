// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../glass_menu.dart';

class _GlassMenuState extends State<GlassMenu> with TickerProviderStateMixin {
  final OverlayPortalController _overlayController = OverlayPortalController();

  late final GlassMorphController _morphController;

  late final ScrollController _scrollController;
  Size? _triggerSize;
  double? _triggerBorderRadius;
  Offset _triggerGlobalPosition = Offset.zero; // captured in _openMenu
  Offset _triggerOverlayPosition =
      Offset.zero; // captured in _openMenu (overlay-relative)
  int? _hoveredIndex;
  bool _isDragging = false;
  bool _hasStretched =
      false; // Prevents closing if we moved into stretch territory
  double _initialScrollOffset = 0.0;
  double _horizontalOffset = 0.0;
  double _verticalOffset = 0.0;

  /// Live screen-space nudge added to the captured trigger position while the
  /// menu is OPEN, so an external owner can keep the floating menu glued to a
  /// moving anchor (e.g. a canvas tile trailing under a rubberband) WITHOUT
  /// re-opening. Reset to zero on each [_openMenu]. Applied to both morph blobs
  /// in [_buildMorphingOverlay]. It deliberately does NOT recompute the
  /// screen-edge clamping ([_horizontalOffset]/[_verticalOffset]) — trails are
  /// small and bounded, and recomputing per-frame is not worth the cost. Driven
  /// via [GlassMenuController.setFollowOffset] / [setFollowOffset].
  Offset _followOffset = Offset.zero;

  int? _swipePointerId;
  Offset _swipeStartPosition = Offset.zero;
  bool _swipeArmed = false;
  bool _openedOnPointerDown = false;
  final GlobalKey _menuContentKey = GlobalKey();

  // --- Granular Update System (Performance + No flicker) ---
  // We cache the outer list but use notifiers to update selection state
  // without rebuilding the entire menu tree.
  late final ValueNotifier<int?> _hoveredIndexNotifier;
  late final ValueNotifier<bool> _isDraggingNotifier;
  List<Widget>? _cachedWrappedItems;

  // --- Layered submenus (GlassMenuItem.submenu) ---
  // Every pushed level opens a second glass card OVER the menu body (the way
  // native iOS context menus open submenus): the body below stays where it is,
  // recedes slightly, and its rows dim. Each entry keeps the parent row (for
  // the card's header) and the item list shown in the card. Cleared on every
  // open.
  final List<_SubmenuLevel> _submenuStack = [];

  /// True while a level morph runs BACKWARD (a header pop): the top card then
  /// travels back toward its source row while the body un-recedes.
  bool _levelMorphPopping = false;

  /// Drives the layered morph: the body's recede/dim, and each card's flight
  /// from (or back to) its source row. Value 1.0 means no level is open or the
  /// morph has settled (0 = start).
  late final AnimationController _contentMorph;
  double _contentMorphFromHOffset = 0.0;
  double _contentMorphFromVOffset = 0.0;
  double _contentMorphToHOffset = 0.0;
  double _contentMorphToVOffset = 0.0;

  /// True while a pointer-up on the menu body is being dispatched, so a row's
  /// tap recogniser can tell a touch (already handled by the body Listener)
  /// from a keyboard / assistive-technology activation.
  bool _bodyPointerUpHandled = false;
  bool _glideOverParent = false;

  /// The list of the TOP level: the root items, or the items of the newest
  /// submenu card (the only interactive list while a card is open).
  List<Widget> get _items =>
      _submenuStack.isEmpty ? widget.items : _submenuStack.last.list;

  @override
  void didUpdateWidget(GlassMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.controller, oldWidget.controller)) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
    if (!identical(widget.items, oldWidget.items)) {
      _cachedWrappedItems = null;
      // BUG 12 FIX: Clear hover state if items shrink while menu is open
      // to prevent RangeError when the selection pill tries to measure
      // a now-deleted index.
      if (widget.items.length < oldWidget.items.length) {
        _hoveredIndex = null;
        _hoveredIndexNotifier.value = null;
      }
    }
    if (widget.morphSpeed != oldWidget.morphSpeed) {
      _morphController.setSpeed(widget.morphSpeed);
    }
  }

  Alignment _morphAlignment = Alignment.topLeft;

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

  @override
  void initState() {
    super.initState();
    _morphController =
        GlassMorphController(vsync: this, speed: widget.morphSpeed);
    _morphController.addListener(() {
      if (mounted) setState(() {});

      // Hide overlay only when the spring has FULLY SETTLED near 0.
      // Velocity guard prevents premature hiding on first zero-crossing
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
              _horizontalOffset = 0.0;
              _verticalOffset = 0.0;
            }
          });
        } else {
          _overlayController.hide();
          // Reset screen-edge clamping offsets so stale values from a previous
          // open position don't bleed into the next open cycle.
          _horizontalOffset = 0.0;
          _verticalOffset = 0.0;
        }
      }
    });
    _scrollController = ScrollController();
    _hoveredIndexNotifier = ValueNotifier(null);
    _isDraggingNotifier = ValueNotifier(false);
    _contentMorph = AnimationController(
      vsync: this,
      duration: _kSubmenuMorphDuration,
      value: 1.0,
    )..addListener(_onContentMorphTick);
    widget.controller?._attach(this);
  }

  List<ModalRoute<dynamic>> _routes = const <ModalRoute<dynamic>>[];

  @override
  void dispose() {
    _removeRouteListeners();
    _routes = const [];
    widget.controller?._detach(this);
    _morphController.dispose();
    _contentMorph.dispose();
    _scrollController.dispose();
    _hoveredIndexNotifier.dispose();
    _isDraggingNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync the reduced-motion accessibility flag to the morph controller.
    // This fires on first build and again whenever MediaQuery changes
    // (e.g. user toggles Reduce Motion in Settings while the app is running).
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
    _horizontalOffset = 0.0;
    _verticalOffset = 0.0;
    _hoveredIndex = null;
    _hoveredIndexNotifier.value = null;
    _isDragging = false;
    _isDraggingNotifier.value = false;
    _hasStretched = false;
    _followOffset = Offset.zero;
    _swipePointerId = null;
    _swipeArmed = false;
    _openedOnPointerDown = false;
    _resetSubmenus();
    if (!wasClosing) {
      widget.onClose?.call();
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _morphController.animation,
      builder: (context, child) {
        final rawValue = _morphController.value;

        // Block trigger taps while menu is significantly open.
        final isMenuBlocking = _overlayController.isShowing && rawValue > 0.8;

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

        // Calculate the momentum push vector based on the exact same logic as Blob B
        // so the real trigger precisely inherits the menu's momentum trajectory.
        final tw = _triggerSize?.width ?? 44.0;
        final th = _triggerSize?.height ?? 44.0;
        final menuWidth = widget.menuWidth;
        final menuHeight = _calculateMenuHeight();
        final dxMag = (menuWidth - tw) / 2.0;
        final dyMag = (menuHeight - th) / 2.0;
        final finalDx = -_morphAlignment.x * dxMag;
        final finalDy = -_morphAlignment.y * dyMag;

        // Apply the push momentum to the real trigger during the underdamped bounce
        // Include the offsets so the trajectory is mathematically perfect.
        final double pushDx =
            isHandoff ? (finalDx + _horizontalOffset) * rawValue : 0.0;
        final double pushDy =
            isHandoff ? (finalDy + _verticalOffset) * rawValue : 0.0;

        // Underdamped bounce impact squash: as the droplet slams into the trigger,
        // the button compresses slightly and rebounds to rest, giving a visceral
        // tactile sensation of liquid absorption.
        final double impactScale =
            isHandoff ? (1.0 + rawValue * 0.35).clamp(0.88, 1.0) : 1.0;

        final Widget triggerChild = widget.triggerBuilder != null
            ? widget.triggerBuilder!(context, _toggleMenu)
            // A plain trigger (an icon, a text) gets the button role here;
            // its text, if any, merges into this node as the name.
            : Semantics(
                container: true,
                button: true,
                label: widget.semanticLabel,
                child: GestureDetector(
                  onTap: _toggleMenu,
                  child: widget.trigger,
                ),
              );

        // Composed with any enclosing scope rather than replacing it. The
        // scope is unconditional so the trigger's element survives a menu
        // open, but on its own it shadowed a materialize running above —
        // a pinned cluster dissolving across a route transition sits inside
        // this wrapper and never saw its fade.
        final outer = GlassMaterializeScope.maybeOf(context);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Trigger — physically bounces and absorbs impact when slammed by the closing menu!
            Transform.translate(
              offset: Offset(pushDx, pushDy),
              child: Transform.scale(
                scale: impactScale,
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: _handleTriggerPointerDown,
                  onPointerMove: _handleTriggerPointerMove,
                  onPointerUp: _handleTriggerPointerUp,
                  onPointerCancel: _handleTriggerPointerCancel,
                  child: Opacity(
                    opacity: triggerOpacity,
                    child: GlassMaterializeScope(
                      glassProgress:
                          triggerOpacity * (outer?.glassProgress ?? 1.0),
                      contentOpacity:
                          triggerOpacity * (outer?.contentOpacity ?? 1.0),
                      contentSigma: outer?.contentSigma ?? 0.0,
                      child: IgnorePointer(
                        ignoring: isMenuBlocking,
                        child: triggerChild,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Overlay portal for morphing animation.
            // The overlay contents fade out during the handoff so the real button shows instead.
            //
            // Target the NEAREST overlay so the menu stays confined to the page/route
            // where it was opened (#274). When a new route is pushed onto this or an
            // ancestor Navigator, the destination route renders above this overlay,
            // so the closing animation naturally remains on the outgoing page behind
            // the transition. The trigger position is mapped into the nearest overlay's
            // coordinate space in _openMenu to avoid drift in nested embeddings.
            OverlayPortal(
              controller: _overlayController,
              overlayChildBuilder: _buildMorphingOverlay,
              overlayLocation: OverlayChildLocation.nearestOverlay,
            ),
          ],
        );
      },
    );
  }

  void _toggleMenu() {
    if (_openedOnPointerDown) {
      // Tap-up from the same press that opened the menu on pointer down.
      // Consume it so we don't immediately re-toggle the menu closed.
      _openedOnPointerDown = false;
      return;
    }
    if (_overlayController.isShowing && _morphController.value > 0.1) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _handleTriggerPointerDown(PointerDownEvent event) {
    if (!widget.enableContinuousSwipe) return;

    if (_overlayController.isShowing && _morphController.value > 0.1) {
      _closeMenu();
      return;
    }

    _swipePointerId = event.pointer;
    _swipeStartPosition = event.position;
    _swipeArmed = false;
    _openedOnPointerDown = true;

    _openMenu();
  }

  void _handleTriggerPointerMove(PointerMoveEvent event) {
    // Flutter retains the pointer hit-test path until the gesture ends.
    if (!mounted) return;
    if (!widget.enableContinuousSwipe) return;
    if (event.pointer != _swipePointerId) return;
    // Continuous swipe has no meaning on scrollable menus: arming would block
    // scroll and always dismiss on release without selecting anything.
    if (_isScrollable) return;

    final distance = (event.position - _swipeStartPosition).distance;
    if (!_swipeArmed) {
      if (distance >= widget.continuousSwipeSlop) {
        _swipeArmed = true;
        _openedOnPointerDown = false;
        _isDragging = true;
        _isDraggingNotifier.value = true;
      }
    }

    if (_swipeArmed) {
      _updateHoverFromGlobalPosition(event.position);
    }
  }

  void _updateHoverFromGlobalPosition(Offset globalPosition) {
    Offset localPosition;
    final renderBox =
        _menuContentKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.attached && renderBox.hasSize) {
      localPosition = renderBox.globalToLocal(globalPosition);
    } else {
      localPosition = globalPosition - _restingMenuGlobalRect().topLeft;
    }

    final previousIndex = _hoveredIndex;
    _updateHoveredIndex(localPosition);

    // Haptic feedback on item boundary crossing (iOS HIG)
    if (_hoveredIndex != null && _hoveredIndex != previousIndex) {
      HapticFeedback.selectionClick();
    }

    // Feed touch position to GlassGlow if interaction glow is enabled
    if (widget.enableInteractionGlow) {
      final glowLayerState = _menuContentKey.currentContext
          ?.findAncestorStateOfType<GlassGlowLayerState>();
      if (glowLayerState != null) {
        final layerBox =
            glowLayerState.context.findRenderObject() as RenderBox?;
        if (layerBox != null && layerBox.attached && layerBox.hasSize) {
          final isDark = GlassTheme.brightnessOf(context) == Brightness.dark;
          final glowColor = widget.glowColor ??
              (isDark
                  ? CupertinoColors.white
                      .withValues(alpha: GlassDefaults.specularLightAlpha)
                  : CupertinoColors.black
                      .withValues(alpha: GlassDefaults.specularDarkAlpha));
          glowLayerState.updateTouch(
            layerBox.globalToLocal(globalPosition),
            radius: widget.glowRadius,
            color: glowColor,
            blurRadius: 40,
          );
        }
      }
    }
  }

  void _handleTriggerPointerUp(PointerUpEvent event) {
    if (!mounted) return;
    if (!widget.enableContinuousSwipe) return;
    if (event.pointer != _swipePointerId) return;

    if (widget.enableInteractionGlow) {
      final glowLayerState = _menuContentKey.currentContext
          ?.findAncestorStateOfType<GlassGlowLayerState>();
      glowLayerState?.removeTouch();
    }

    if (_swipeArmed) {
      final indexToTap = _hoveredIndex;
      if (indexToTap != null && indexToTap >= 0 && indexToTap < _items.length) {
        final item = _items[indexToTap];
        if (item is GlassMenuItem && item.enabled) {
          _activateItem(item);
        } else {
          _closeMenu();
        }
      } else {
        _closeMenu();
      }
    }

    _isDragging = false;
    _isDraggingNotifier.value = false;
    _hoveredIndex = null;
    _hoveredIndexNotifier.value = null;
    _hasStretched = false;
    _swipePointerId = null;
    _swipeArmed = false;
  }

  void _handleTriggerPointerCancel(PointerCancelEvent event) {
    if (!mounted) return;
    if (!widget.enableContinuousSwipe) return;
    if (event.pointer != _swipePointerId) return;

    if (widget.enableInteractionGlow) {
      final glowLayerState = _menuContentKey.currentContext
          ?.findAncestorStateOfType<GlassGlowLayerState>();
      glowLayerState?.removeTouch();
    }

    if (_swipeArmed) {
      _closeMenu();
    }

    _isDragging = false;
    _isDraggingNotifier.value = false;
    _hoveredIndex = null;
    _hoveredIndexNotifier.value = null;
    _hasStretched = false;
    _swipePointerId = null;
    _swipeArmed = false;
    _openedOnPointerDown = false;
  }

  /// Nudges the OPEN menu by [offset] (screen px) on top of its captured trigger
  /// position, so an external owner can track a moving anchor live. A no-op
  /// delta is skipped to avoid needless rebuilds. Has no visible effect while
  /// closed; the next [_openMenu] resets it to zero.
  void setFollowOffset(Offset offset) {
    if (_followOffset == offset) return;
    setState(() => _followOffset = offset);
  }

  void _openMenu() {
    _updateRouteListener();
    // Capture geometry and screen position for morphing
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      // Safety: Cannot open menu if render box is not ready.
      // Also clear the pointer ID so stray move/up events from the same
      // finger don't try to hit-test against a menu that never opened.
      _openedOnPointerDown = false;
      _swipePointerId = null;
      return;
    }

    _triggerSize = renderBox.size;
    _triggerBorderRadius = _triggerSize!.height / 2;
    _triggerGlobalPosition =
        renderBox.localToGlobal(Offset.zero); // store for screen bounds
    final overlay = Overlay.maybeOf(context);
    final overlayBox = overlay?.context.findRenderObject() as RenderBox?;
    _triggerOverlayPosition = overlayBox != null
        ? renderBox.localToGlobal(Offset.zero, ancestor: overlayBox)
        : _triggerGlobalPosition;
    // A fresh open must never inherit a previous open's live anchor nudge.
    _followOffset = Offset.zero;
    // ...nor a previous open's submenu level.
    _resetSubmenus();
    final position = _triggerGlobalPosition;
    final mediaQuery = MediaQuery.maybeOf(context);
    final screenWidth = mediaQuery?.size.width ?? double.infinity;
    final screenHeight = mediaQuery?.size.height ?? double.infinity;

    // Calculate menu height for vertical boundary check
    final menuHeight = _calculateMenuHeight();

    // 1. Determine base alignment (Auto vs Manual)
    final stripAlignment = verticalBarPresentationAlignment(
      context,
      position & _triggerSize!,
    );
    if ((widget.menuAlignment == null ||
            widget.menuAlignment == GlassMenuAlignment.none) &&
        stripAlignment != null) {
      // From iPhone Duo's vertical bar strip: towards the content. Natively a
      // menu, unlike a popover, is not centred on its item: it covers it
      // edge to edge and grows away from the nearer of the top and bottom.
      final upperHalf = !screenHeight.isFinite ||
          position.dy + _triggerSize!.height / 2 <= screenHeight / 2;
      _morphAlignment = Alignment(stripAlignment.x, upperHalf ? -1.0 : 1.0);
    } else if (widget.menuAlignment == null ||
        widget.menuAlignment == GlassMenuAlignment.none) {
      // Horizontal alignment: left vs right half
      final isRightHalf = screenWidth.isFinite && position.dx > screenWidth / 2;

      // Vertical alignment: check if menu would overflow bottom
      final spaceBelow = screenHeight.isFinite
          ? screenHeight - (position.dy + _triggerSize!.height)
          : double.infinity;
      final spaceAbove = screenHeight.isFinite ? position.dy : double.infinity;

      // Prefer downward opening unless insufficient space
      final shouldFlipVertical =
          spaceBelow < menuHeight && spaceAbove > menuHeight;

      if (shouldFlipVertical) {
        _morphAlignment =
            isRightHalf ? Alignment.bottomRight : Alignment.bottomLeft;
      } else {
        _morphAlignment = isRightHalf ? Alignment.topRight : Alignment.topLeft;
      }
    } else {
      // MANUAL: Use the provided alignment directly.
      // Note: autoAdjustToScreen clamping will still compensate for overflow.
      _morphAlignment =
          _getAlignment(widget.menuAlignment!) ?? Alignment.center;
    }

    // 2. Clamping: calculate offsets to keep menu within screen bounds
    final clamp = _computeClampOffsets(menuHeight);

    setState(() {
      _horizontalOffset = clamp.dx;
      _verticalOffset = clamp.dy;
    });

    _overlayController.show();
    // GlassMorphController.open() uses 0.0 velocity — spring starts from rest
    // for a clean, smooth teardrop expansion with no artificial kick.
    _morphController.open();
    widget.onLevelChanged?.call(0, _targetBodyHeight());
  }

  /// Offsets that keep a menu of [menuHeight] inside the screen's safe area
  /// (only when [GlassMenu.autoAdjustToScreen] is set), for the trigger
  /// geometry and alignment captured by the last [_openMenu].
  Offset _computeClampOffsets(double menuHeight) {
    if (!widget.autoAdjustToScreen || _triggerSize == null) return Offset.zero;
    final position = _triggerGlobalPosition;
    final mediaQuery = MediaQuery.maybeOf(context);
    final screenWidth = mediaQuery?.size.width ?? double.infinity;
    final screenHeight = mediaQuery?.size.height ?? double.infinity;
    final flutterView = View.of(context);
    final mqPadding = EdgeInsets.fromViewPadding(
      flutterView.padding,
      flutterView.devicePixelRatio,
    );

    // The strip's inset is no bar to a menu opened out of the strip, which
    // natively lies over the item it came from; its status cluster is.
    final stripAlignment = verticalBarPresentationAlignment(
      context,
      position & _triggerSize!,
    );
    final double safeTop = math.max(
      widget.menuPadding.top + mqPadding.top,
      verticalBarPresentationTop(context, position & _triggerSize!) ?? 0.0,
    );
    final double safeBottom = widget.menuPadding.bottom + mqPadding.bottom;
    final double safeLeft = widget.menuPadding.left +
        (stripAlignment == null ? mqPadding.left : 0.0);
    final double safeRight = widget.menuPadding.right +
        (stripAlignment == null ? mqPadding.right : 0.0);

    // Calculate global menu position
    final double targetX =
        position.dx + (1 + _morphAlignment.x) * _triggerSize!.width / 2;
    final double targetY =
        position.dy + (1 + _morphAlignment.y) * _triggerSize!.height / 2;
    final double menuLeft =
        targetX - (1 + _morphAlignment.x) * widget.menuWidth / 2;
    final double menuTop = targetY - (1 + _morphAlignment.y) * menuHeight / 2;

    double hOffset = 0.0;
    double vOffset = 0.0;

    // Horizontal adjustment
    if (menuLeft < safeLeft) {
      hOffset = safeLeft - menuLeft;
    } else if (screenWidth.isFinite &&
        menuLeft + widget.menuWidth > screenWidth - safeRight) {
      hOffset = (screenWidth - safeRight) - (menuLeft + widget.menuWidth);
    }

    // Vertical adjustment
    if (menuTop < safeTop) {
      vOffset = safeTop - menuTop;
    } else if (screenHeight.isFinite &&
        menuTop + menuHeight > screenHeight - safeBottom) {
      vOffset = (screenHeight - safeBottom) - (menuTop + menuHeight);
    }
    return Offset(hOffset, vOffset);
  }

  // ─── Layered submenus ──────────────────────────────────────────────────────

  /// Activates [item] the way a tap does: a card's header row pops the card,
  /// a submenu item opens a new card, and any other item runs and closes the
  /// whole menu.
  void _activateItem(GlassMenuItem item) {
    if (item is _GlassMenuHeaderItem) {
      _popSubmenu();
    } else if (item.submenu != null) {
      _pushSubmenu(item);
    } else {
      _fireItemTap(item);
    }
  }

  /// Opens a card over the menu (or the card below it) for [parent]'s
  /// submenu. The card's header sits on the row that was activated, the body
  /// below recedes and dims, and the whole stack is re-clamped for the card's
  /// extent (see [_stackExtent]).
  void _pushSubmenu(GlassMenuItem parent) {
    if (_contentMorph.isAnimating || _morphController.isClosing) return;
    final sourceList = _items;
    final sourceIndex = sourceList.indexOf(parent);
    if (sourceIndex < 0) return;
    final sourceOffset = _listRowTop(sourceIndex, sourceList) -
        (_scrollController.hasClients ? _scrollController.offset : 0.0);
    final list = <Widget>[
      _GlassMenuHeaderItem(
        key: ValueKey<String>('glass-menu-header-${_submenuStack.length + 1}'),
        title: parent.title,
        icon: parent.icon,
        titleStyle: (parent.titleStyle ??
                TextStyle(
                  fontSize: 17,
                  color: parent.iconColor ??
                      CupertinoTheme.of(context)
                          .textTheme
                          .textStyle
                          .color
                          ?.withValues(alpha: 0.9),
                ))
            .copyWith(fontWeight: FontWeight.w600),
        height: parent.height,
        iconColor: parent.isDestructive ? null : parent.iconColor,
        iconSize: parent.iconSize,
        enablePressScale: parent.enablePressScale,
      ),
      const GlassMenuDivider(),
      ...parent.submenu!,
    ];
    setState(() {
      _submenuStack.add(_SubmenuLevel(
        list: list,
        sourceRowTop: sourceOffset,
        sourceScrollOffset:
            _scrollController.hasClients ? _scrollController.offset : 0.0,
        sourceRowHeight: _getScaledItemHeight(parent, context),
      ));
      _cachedWrappedItems = null;
      _hoveredIndex = null;
      _isDragging = false;
      _hasStretched = false;
      _levelMorphPopping = false;
    });
    _hoveredIndexNotifier.value = null;
    _isDraggingNotifier.value = false;
    if (_scrollController.hasClients) _scrollController.jumpTo(0.0);
    _reclampStack();
    _startLevelMorph();
    widget.onLevelChanged?.call(_submenuStack.length, _stackExtent());
  }

  /// Closes the top card: it flies back to its source row while the level
  /// below un-recedes.
  void _popSubmenu() {
    if (_submenuStack.isEmpty || _contentMorph.isAnimating) return;
    _clearGlide();
    setState(() {
      _cachedWrappedItems = null;
      _levelMorphPopping = true;
    });
    _reclampStack();
    _startLevelMorph();
    widget.onLevelChanged?.call(
      _submenuStack.length - 1,
      _stackExtentAfterPop(),
    );
  }

  /// Drives the stack through a level morph: the clamp offsets lerp from the
  /// level's old placement to its new one, and a finished pop removes its
  /// card's level.
  void _onContentMorphTick() {
    if (!mounted) return;
    final t = _kSubmenuMorphCurve.transform(_contentMorph.value);
    setState(() {
      _horizontalOffset = lerpDouble(
        _contentMorphFromHOffset,
        _contentMorphToHOffset,
        t,
      )!;
      _verticalOffset = lerpDouble(
        _contentMorphFromVOffset,
        _contentMorphToVOffset,
        t,
      )!;
    });
    _finishPopIfNeeded();
  }

  void _startLevelMorph() {
    final reduceMotion = GlassAccessibilityData.of(context).reduceMotion;
    _contentMorph.duration =
        reduceMotion ? Duration.zero : _kSubmenuMorphDuration;
    _contentMorph.forward(from: 0.0);
  }

  /// Removes the popped level once its card has flown back to its source row.
  /// Level state is kept until then so the morph can render the returning card.
  void _finishPopIfNeeded() {
    if (_levelMorphPopping && _contentMorph.value >= 1.0) {
      final removed = _submenuStack.last;
      setState(() {
        _submenuStack.removeLast();
        _cachedWrappedItems = null;
        _levelMorphPopping = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.jumpTo(removed.sourceScrollOffset
              .clamp(0.0, _scrollController.position.maxScrollExtent));
        }
      });
      _hoveredIndex = null;
      _hoveredIndexNotifier.value = null;
    }
  }

  // ── Level geometry ───────────────────────────────────────────────────────
  //
  // All rects are in the OVERLAY's coordinate space (the space the morphing
  // blob stack is laid out in), derived from the body's resting rect: the
  // body plus every card shifts together with the live follow offset and the
  // screen clamp.

  /// Whether the menu grows DOWN (anchored at its top edge).
  bool get _growsDown => _morphAlignment.y <= 0.0;

  /// The scale the body recedes to while a submenu card is open, measured from
  /// native iOS captures (416 → 404 px wide).
  static const double _kRecedeScale = 0.971;

  /// The opacity the rows of a level covered by a card dim to (native iOS:
  /// text drops from 9/236 to 122/236 grey ≈ 0.5).
  static const double _kDimmedOpacity = 0.5;

  /// The morph progress of the current layered morph: 1.0 when settled.
  double get _levelT {
    if (!_contentMorph.isAnimating && _contentMorph.value == 1.0) return 1.0;
    return _kSubmenuMorphCurve.transform(_contentMorph.value);
  }

  /// How far the level below the top card is receded/dimmed right now (0–1).
  double get _recedeT {
    if (_submenuStack.isEmpty) return 0.0;
    final raw = _levelMorphPopping ? 1.0 - _levelT : _levelT;
    return raw.clamp(0.0, 1.0);
  }

  /// The body's resting rect in overlay space at the CURRENT frame: the
  /// settled blob-B rect (anchored edge fixed, centred on the trigger axis),
  /// shifted by the screen clamp and the live follow offset.
  Rect _restingBodyOverlayRect() {
    final tw = _triggerSize!.width;
    final th = _triggerSize!.height;
    final menuWidth = widget.menuWidth.toDouble();
    final menuHeight = _targetBodyHeight();
    final dxMag = (menuWidth - tw) / 2.0;
    final dyMag = (menuHeight - th) / 2.0;
    final centre = _triggerOverlayPosition +
        _followOffset +
        Offset(
          tw / 2.0 - _morphAlignment.x * dxMag + _horizontalOffset,
          th / 2.0 - _morphAlignment.y * dyMag + _verticalOffset,
        );
    return Rect.fromCenter(
      center: centre,
      width: menuWidth,
      height: menuHeight,
    );
  }

  /// The resting rect of the card for [levelIndex], at full morph progress, in
  /// overlay space. The header row sits on the source row's centre in the
  /// receded level below (clamped to the body's top padding); a card on an
  /// upward-growing menu is shifted up so it never grows toward the trigger
  /// past the receded body's bottom edge.
  Rect _cardRect(int levelIndex) {
    final level = _submenuStack[levelIndex];
    final parentRect =
        levelIndex == 0 ? _restingBodyOverlayRect() : _cardRect(levelIndex - 1);
    final recededParent = _scaleLevelRect(parentRect, _kRecedeScale);
    final rowCentreY = recededParent.top +
        (level.sourceRowTop + level.sourceRowHeight / 2) * _kRecedeScale;
    final headerHeight = _getScaledItemHeight(level.list.first, context);
    var height = _visibleListHeight(level.list);
    var top = rowCentreY - _kBodyVerticalPadding - headerHeight / 2;
    final root = _restingBodyOverlayRect();
    final budget = _maximumStackHeight;
    if (_growsDown) {
      // Keep a header and the first child reachable even if the source row
      // is at the very bottom of a tall/scrolled ancestor.
      final minimumViewport =
          math.min(height, _listHeight(level.list.take(3).toList()));
      top = math.max(parentRect.top, top);
      top = math.min(top, root.top + budget - minimumViewport);
      height = math.min(height, root.top + budget - top);
    } else {
      top = math.min(parentRect.bottom - height, top);
      top = math.max(top, root.bottom - budget);
      height = math.min(height, parentRect.bottom - top);
    }
    return Rect.fromLTWH(parentRect.left, top, parentRect.width, height);
  }

  /// The body's recede progress (0 = full size, 1 = receded) — the level
  /// directly below the top card recedes with the current morph; with no card
  /// open it is 0.
  double get _bodyRecede => _coverProgress(0);

  /// Earlier ancestors stay receded while a deeper card opens or closes.
  double _coverProgress(int depth) {
    if (depth >= _submenuStack.length) return 0.0;
    return depth == _submenuStack.length - 1 ? _recedeT : 1.0;
  }

  Rect _scaleLevelRect(Rect rect, double scale) => Rect.fromLTWH(
        rect.center.dx - rect.width * scale / 2,
        _growsDown ? rect.top : rect.bottom - rect.height * scale,
        rect.width * scale,
        rect.height * scale,
      );

  /// The card's rect at the CURRENT morph progress: flying from its source
  /// row toward [_cardRect] on push, and back on pop.
  Rect _cardFlightRect(int levelIndex) {
    final target = _cardRect(levelIndex);
    if (levelIndex < _submenuStack.length - 1) return target;
    final level = _submenuStack[levelIndex];
    final parentRect =
        levelIndex == 0 ? _restingBodyOverlayRect() : _cardRect(levelIndex - 1);
    final source = Rect.fromLTWH(
      parentRect.left,
      parentRect.top + level.sourceRowTop - _kBodyVerticalPadding,
      parentRect.width,
      level.sourceRowHeight + 2 * _kBodyVerticalPadding,
    );
    return Rect.lerp(source, target, _recedeT)!;
  }

  /// Builds the glass card for [levelIndex]: its header row (the parent row
  /// repeated, bold, with a downward chevron), a divider, and its rows —
  /// interactive when it is the top level, dimmed and inert otherwise.
  Widget _buildSubmenuCard(
    int levelIndex,
    LiquidGlassSettings settings,
    GlassQuality quality,
  ) {
    final level = _submenuStack[levelIndex];
    final isTop = levelIndex == _submenuStack.length - 1;
    final dimmed = !isTop;
    final shape = LiquidRoundedRectangle(
      borderRadius: widget.menuBorderRadius,
    );
    final cardContent = _buildListContent(
      level.list,
      interactive: isTop,
      dimmed: dimmed,
      coveredDepth: dimmed ? levelIndex + 1 : null,
      coverProgress: _coverProgress(levelIndex + 1),
      viewportHeight: _cardRect(levelIndex).height,
      passiveScrollOffset:
          isTop ? 0.0 : _submenuStack[levelIndex + 1].sourceScrollOffset,
    );
    // Fade the arriving/departing card through the glass visibility channel,
    // never layer opacity: an Opacity ancestor stops the backdrop blur, so the
    // parent's rows would show crisply through the card. Native iOS shows the
    // card's rows from the start of its growth while the parent rows it
    // covers cross-fade away ([_coveredRowOpacity]); there is no blank,
    // frosted card stage. Lower cards stay at rest.
    final fade = isTop ? _cardFade() : (glass: 1.0, text: 1.0);
    final isDark = GlassTheme.brightnessOf(context) == Brightness.dark;
    final glowColor = widget.glowColor ??
        (isDark
            ? CupertinoColors.white
                .withValues(alpha: GlassDefaults.specularLightAlpha)
            : CupertinoColors.black
                .withValues(alpha: GlassDefaults.specularDarkAlpha));

    return GlassMaterializeScope(
      glassProgress: fade.glass,
      contentOpacity: fade.text,
      contentSigma: 0.0,
      child: Transform.scale(
        scale: lerpDouble(1.0, _kRecedeScale, _coverProgress(levelIndex + 1))!,
        alignment: Alignment(0, _growsDown ? -1 : 1),
        child: GlassContainer(
          // A card samples the backdrop on its own (it sits OVER the menu body,
          // outside the body's blend group) — never a shared layer.
          useOwnLayer: true,
          settings: settings,
          quality: quality,
          platformViewBackdrop: widget.platformViewBackdrop,
          width: widget.menuWidth.toDouble(),
          height: _cardFlightRect(levelIndex).height,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          glowIntensity: widget.glowIntensity,
          // Same material as the root. Any apparent brightening comes from
          // compositing over the parent, not a separate white/black tint veil.
          child: GlassGlow(
            enabled: widget.enableInteractionGlow && isTop,
            glowOnTapOnly: widget.glowOnTapOnly,
            glowColor: glowColor,
            glowRadius: widget.glowRadius,
            glowBlurRadius: 40,
            clipper: ShapeBorderClipper(shape: shape),
            child: OverflowBox(
              alignment: Alignment.topCenter,
              minHeight: _cardRect(levelIndex).height,
              maxHeight: _cardRect(levelIndex).height,
              child: cardContent,
            ),
          ),
        ),
      ),
    );
  }

  /// Eased progress of the current level morph between [from] and [to].
  double _morphStage(double from, double to) => Curves.easeOut
      .transform(((_contentMorph.value - from) / (to - from)).clamp(0.0, 1.0));

  /// Fade of the top card. On push its rows arrive with the material (and
  /// lead it, so the card never shows as an empty frosted panel); on pop the
  /// material dissolves together with the rows (just behind them), so no
  /// frame shows an empty frosted card blurring the returning parent rows.
  ({double glass, double text}) _cardFade() {
    if (_levelMorphPopping) {
      return (
        glass: 1.0 - _morphStage(0.0, 0.32),
        text: 1.0 - _morphStage(0.0, 0.3),
      );
    }
    return (glass: _morphStage(0.0, 0.45), text: _morphStage(0.0, 0.3));
  }

  /// Opacity of the rows at [depth] that the card above it covers once
  /// settled: they cross-fade out faster than the card's rows arrive, and
  /// return as those clear on pop, so the two sets of labels never compete
  /// and no frame shows an empty frosted card over hidden rows. Rows the card does not cover keep the usual dimming.
  double _coveredRowOpacity(int depth) {
    if (depth >= _submenuStack.length) return 1.0;
    if (depth < _submenuStack.length - 1) return 0.0;
    return _levelMorphPopping
        ? _morphStage(0.1, 0.35)
        : 1.0 - _morphStage(0.0, 0.15);
  }

  /// Whether row [index] of the level at [depth] lies under the settled card
  /// that level's submenu opens (its centre inside the card's rect).
  bool _isCoveredRow(int depth, int index, List<Widget> items) {
    final parentRect =
        depth == 0 ? _restingBodyOverlayRect() : _cardRect(depth - 1);
    final receded = _scaleLevelRect(parentRect, _kRecedeScale);
    final card = _cardRect(depth);
    final centre = _listRowTop(index, items) +
        _getScaledItemHeight(items[index], context) / 2 -
        _submenuStack[depth].sourceScrollOffset;
    final y = receded.top + centre * _kRecedeScale;
    return y > card.top && y < card.bottom;
  }

  /// Vertical offset of row [index] from its list's top (body padding included).
  double _listRowTop(int index, List<Widget> list) {
    var offset = _kBodyVerticalPadding;
    for (var i = 0; i < index && i < list.length; i++) {
      offset += _getScaledItemHeight(list[i], context) + _kRowGap;
    }
    return offset;
  }

  double _listHeight(List<Widget> list) {
    var height = 2.0 * _kBodyVerticalPadding;
    for (var i = 0; i < list.length; i++) {
      height += _getScaledItemHeight(list[i], context);
      if (i < list.length - 1) height += _kRowGap;
    }
    return height;
  }

  /// The resting height of the whole visible stack, measured from the body's
  /// anchored edge the way the menu grows: the body's own receded extent, plus
  /// how far the cards reach past it. This is what `onLevelChanged` reports so
  /// an external owner can make room for the card.
  double _stackExtent() => _extentAtDepth(_submenuStack.length);

  Rect _boundsAtDepth(int depth) {
    final root = _restingBodyOverlayRect();
    var bounds = depth == 0 ? root : _scaleLevelRect(root, _kRecedeScale);
    for (var i = 0; i < depth; i++) {
      final card = _cardRect(i);
      bounds = bounds.expandToInclude(
          i == depth - 1 ? card : _scaleLevelRect(card, _kRecedeScale));
    }
    return bounds;
  }

  double _extentAtDepth(int depth) {
    final root = _restingBodyOverlayRect();
    final bounds = _boundsAtDepth(depth);
    return _growsDown ? bounds.bottom - root.top : root.bottom - bounds.top;
  }

  /// The stack extent once the popping card is gone (what `onLevelChanged`
  /// reports on pop, before the level is removed).
  double _stackExtentAfterPop() => _extentAtDepth(_submenuStack.length - 1);

  /// Re-clamps the whole stack (body + cards) for its current extent, the way
  /// the body alone was clamped before submenus existed. Only active when the
  /// owner asked for screen clamping at all.
  void _reclampStack() {
    final depth = _submenuStack.length - (_levelMorphPopping ? 1 : 0);
    var to = Offset.zero;
    if (widget.autoAdjustToScreen) {
      // Clamp the union without changing the root's anchor equation.
      final origin = _triggerGlobalPosition - _triggerOverlayPosition;
      final bounds = _boundsAtDepth(depth)
          .shift(origin - Offset(_horizontalOffset, _verticalOffset));
      final mq = MediaQuery.of(context);
      final padding = mq.padding + widget.menuPadding;
      double fit(double lo, double hi, double min, double max) =>
          lo < min ? min - lo : (hi > max ? max - hi : 0.0);
      to = Offset(
        fit(bounds.left, bounds.right, padding.left,
            mq.size.width - padding.right),
        fit(bounds.top, bounds.bottom, padding.top,
            mq.size.height - padding.bottom),
      );
    }
    _contentMorphFromHOffset = _horizontalOffset;
    _contentMorphFromVOffset = _verticalOffset;
    _contentMorphToHOffset = to.dx;
    _contentMorphToVOffset = to.dy;
  }

  void _resetSubmenus() {
    _submenuStack.clear();
    _levelMorphPopping = false;
    _cachedWrappedItems = null;
    _contentMorph.value = 1.0;
  }

  // ─── External glide (GlassMenuController.glideTo / endGlide) ────────────────

  bool _glideTo(Offset globalPosition) {
    if (!_overlayController.isShowing || _morphController.isClosing) {
      return false;
    }
    if (_contentMorph.isAnimating) {
      _clearGlide();
      return _restingMenuGlobalRect().contains(globalPosition);
    }
    _glideOverParent = false;
    if (_submenuStack.isNotEmpty) {
      final origin = _triggerGlobalPosition - _triggerOverlayPosition;
      final point = globalPosition - origin;
      if (!_cardRect(_submenuStack.length - 1).contains(point)) {
        _clearGlide();
        _glideOverParent = _restingBodyOverlayRect().contains(point) ||
            List.generate(_submenuStack.length - 1, _cardRect)
                .any((rect) => rect.contains(point));
        return _restingMenuGlobalRect().contains(globalPosition);
      }
    }
    if (!_isDragging) {
      _isDragging = true;
      _isDraggingNotifier.value = true;
    }
    _updateHoverFromGlobalPosition(globalPosition);
    return _restingMenuGlobalRect().contains(globalPosition);
  }

  bool _endGlide() {
    if (!_overlayController.isShowing) return false;
    final index = _hoveredIndex;
    final pop = _glideOverParent;
    _clearGlide();
    if (_morphController.isClosing || _contentMorph.isAnimating) return false;
    if (pop) {
      _popSubmenu();
      return true;
    }
    if (index != null && index >= 0 && index < _items.length) {
      final item = _items[index];
      if (item is GlassMenuItem && item.enabled) {
        _activateItem(item);
        return true;
      }
    }
    return false;
  }

  void _cancelGlide() {
    if (!_overlayController.isShowing) return;
    _clearGlide();
  }

  void _clearGlide() {
    _glideOverParent = false;
    if (widget.enableInteractionGlow) {
      final glowLayerState = _menuContentKey.currentContext
          ?.findAncestorStateOfType<GlassGlowLayerState>();
      glowLayerState?.removeTouch();
    }
    _isDragging = false;
    _isDraggingNotifier.value = false;
    _hoveredIndex = null;
    _hoveredIndexNotifier.value = null;
    if (_hasStretched) setState(() => _hasStretched = false);
  }

  /// The open stack's global rect at rest: the body plus every open card,
  /// including the screen clamping and the live follow offset. This is the
  /// region a glide counts as "over the menu".
  Rect _restingMenuGlobalRect() {
    // Overlay coords → global coords: the trigger's position is known in both
    // (captured by _openMenu), so their difference is the overlay's origin.
    final origin = _triggerGlobalPosition - _triggerOverlayPosition;
    Rect toGlobal(Rect r) => r.shift(origin);
    var rect = toGlobal(_restingBodyOverlayRect());
    for (var i = 0; i < _submenuStack.length; i++) {
      rect = rect.expandToInclude(toGlobal(_cardRect(i)));
    }
    return rect;
  }

  void _closeMenu() {
    if (!_overlayController.isShowing) return;
    setState(() {
      _hoveredIndex = null;
      _isDragging = false;
    });
    _hoveredIndexNotifier.value = null;
    _isDraggingNotifier.value = false;
    _swipePointerId = null;
    _swipeArmed = false;
    _openedOnPointerDown = false;
    // GlassMorphController.close() injects the -2.5 velocity hint internally,
    // maximising the rubber-band bounce amplitude at close.
    _morphController.close();
    widget.onClose?.call();
  }

  /// Fires [item.onTap] then closes the menu, honouring [GlassMenuItem.closeDelay].
  ///
  /// When [closeDelay] is null the close is synchronous (default behaviour).
  /// When set, the item action fires immediately but the menu morph is deferred
  /// so that animated [trailing] widgets (e.g. a [GlassSwitch]) can complete
  /// their state transition while the menu is still visible.
  void _fireItemTap(GlassMenuItem item) {
    item.onTap();
    final delay = item.closeDelay;
    if (delay == null || delay == Duration.zero) {
      _closeMenu();
    } else {
      Future.delayed(delay, () {
        if (mounted) _closeMenu();
      });
    }
  }

  Widget _buildMorphingOverlay(BuildContext context) {
    if (_triggerSize == null) return const SizedBox.shrink();

    // Raw value can legitimately exceed [0, 1]: the underdamped spring
    // overshoots on close (goes negative) to create the J-curve bounce.
    final rawValue = _morphController.value;
    final clampedValue = rawValue.clamp(0.0, 1.0);

    final tw = _triggerSize!.width;
    final th = _triggerSize!.height;
    final menuWidth = widget.menuWidth.toDouble();
    final menuHeight = _calculateMenuHeight();

    // The destination of the menu center relative to the trigger center.
    // By setting dyMag to exactly (menuHeight - th) / 2.0, the final menu
    // will perfectly align its top edge with the trigger's top edge, effectively
    // "covering" the faded out menu button.
    final dxMag = (menuWidth - tw) / 2.0;
    final dyMag = (menuHeight - th) / 2.0;
    final finalDx = -_morphAlignment.x * dxMag;
    final finalDy = -_morphAlignment.y * dyMag;

    // ─── Delegate physics to GlassMorphController ────────────────────────────
    //
    // All J-curve, size, push, anchor-scale, blend, and containerScale math
    // is encapsulated in LiquidMorphPhysics.compute() via the controller.
    // Large menus engage adaptive damping so vertical overshoot and push
    // remain within tight iOS-native bounds, while sizeT follows linearToEaseOut.
    final state = _morphController.computeState(
      finalDx: finalDx,
      finalDy: finalDy,
      horizontalOffset: _horizontalOffset,
      verticalOffset: _verticalOffset,
      adaptiveDamping: finalDy.abs() > 100.0,
    );

    final targetHeight = widget.menuHeight ?? menuHeight;
    // Under morphFromZero the body lerps from a zero-size point at the trigger
    // center (collapse-to-point) rather than from the trigger's own size; the
    // false path keeps tw/th so the spawn-blob behavior is byte-identical.
    final double sizeStartW = widget.morphFromZero ? 0.0 : tw;
    final double sizeStartH = widget.morphFromZero ? 0.0 : th;

    // During close undershoot (sizeT < 0), squeeze relative to trigger size.
    // NEVER lerp against the distant targetHeight — for a tall menu (e.g. 340 px),
    // a negative lerp would subtract 45+ px from a 44 px trigger and collapse
    // the container to 0 px, causing a visible flash on the close bounce.
    final currentHeight = state.sizeT < 0.0
        ? (sizeStartH * (1.0 + state.sizeT * 0.25)).clamp(1.0, double.infinity)
        : lerpDouble(sizeStartH, targetHeight, state.sizeT)!
            .clamp(0.0, double.infinity);
    final currentWidth = state.sizeT < 0.0
        ? (sizeStartW * (1.0 + state.sizeT * 0.25)).clamp(1.0, double.infinity)
        : lerpDouble(sizeStartW, widget.menuWidth, state.sizeT)!
            .clamp(0.0, double.infinity);

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

    final bool useBlendGroup = effectiveQuality != GlassQuality.minimal &&
        !widget.platformViewBackdrop;

    final bool isPremium = effectiveQuality == GlassQuality.premium &&
        ImageFilter.isShaderFilterSupported &&
        !widget.platformViewBackdrop;

    final maxRadius = math.min(currentWidth, currentHeight) / 2.0;
    final double radiusT =
        Curves.easeInExpo.transform(state.sizeT.clamp(0.0, 1.0));
    final currentRadius = _morphController.isClosing
        ? (isPremium
            ? maxRadius
            : lerpDouble(
                _triggerBorderRadius ?? (_triggerSize!.shortestSide / 2.0),
                widget.menuBorderRadius,
                radiusT,
              )!)
        : lerpDouble(maxRadius, widget.menuBorderRadius, radiusT)!;

    final double effectiveDx;
    final double effectiveDy;
    if (_morphController.isClosing) {
      if (isPremium) {
        // On close (premium): the droplet separates from the open bounds and travels along
        // the centroid trajectory directly to the trigger center, creating a visible
        // in-flight gap that allows the SDF metaball bridge to form on approach.
        effectiveDx = finalDx * state.pathT;
        effectiveDy = finalDy * state.pathT;
      } else {
        // On close (standard/minimal): single-blob geometric collapse directly
        // into the trigger button bounds with no ghost button underneath.
        effectiveDx = finalDx * state.sizeT;
        effectiveDy = finalDy * state.sizeT;
      }
    } else {
      // On open: for large menus, clamp the anchor edge displacement so the menu's
      // pinned corner never drifts more than 8 px from the trigger button during flight.
      // Small menus have <= 5 px natural displacement and are completely unaffected.
      const double maxAnchorDrift = 8.0;
      final double rawAnchorDriftX = finalDx * (state.pathT - state.sizeT);
      final double anchorDriftX =
          rawAnchorDriftX.clamp(-maxAnchorDrift, maxAnchorDrift);
      effectiveDx = finalDx * state.sizeT + anchorDriftX;

      final double rawAnchorDriftY = finalDy * (state.pathT - state.sizeT);
      final double anchorDriftY =
          rawAnchorDriftY.clamp(-maxAnchorDrift, maxAnchorDrift);
      effectiveDy = finalDy * state.sizeT + anchorDriftY;
    }

    final blobBLeft = _triggerOverlayPosition.dx +
        _followOffset.dx +
        tw / 2.0 +
        effectiveDx -
        currentWidth / 2.0 +
        (_horizontalOffset * clampedValue);

    final blobBTop = _triggerOverlayPosition.dy +
        _followOffset.dy +
        th / 2.0 +
        effectiveDy -
        currentHeight / 2.0 +
        (_verticalOffset * clampedValue);

    // Solid overlay during flight and metaball fusion.
    // Handoff to the real trigger button occurs cleanly when hasHandedOff fires (rawValue <= 0.0).
    final double overlayOpacity =
        (_morphController.isClosing && _morphController.hasHandedOff)
            ? 0.0
            : 1.0;

    return Stack(
      children: [
        // Invisible full-screen tap-to-close barrier
        if (clampedValue > 0.3 && widget.showDismissBarrier)
          Positioned.fill(
            // Named like Flutter's own menu barrier so a screen reader can
            // close the menu as well as a pointer can.
            child: Semantics(
              container: true,
              label: glassCupertinoLocalizationsOf(context).menuDismissLabel,
              onDismiss: _closeMenu,
              onTap: _closeMenu,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                excludeFromSemantics: true,
                onTap: _closeMenu,
                child: Container(color: const Color(0x00000000)),
              ),
            ),
          ),

        // ── Two-Blob Metaball Morphing ───────────────────────────────────────
        //
        // We use LiquidGlassLayer at the root to create the transparent blend group.
        // Inside it, we use two CompositedTransformFollowers, BOTH anchored to the
        // trigger's center. This avoids manual coordinate math and prevents pixel drift.
        Positioned.fill(
          child: Opacity(
            opacity: overlayOpacity,
            child: AdaptiveLiquidGlassLayer(
              settings: effectiveSettings,
              quality: effectiveQuality,
              blendAmount: state.blend,
              platformViewBackdrop: widget.platformViewBackdrop,
              child: Builder(
                builder: (context) {
                  final blobs = Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // ─── Blob A: Trigger Ghost ─────────────────────────────
                      // Stays perfectly centered on the trigger, BUT absorbs the
                      // closing momentum (pushDx/pushDy) to bounce when slammed.
                      // Shrinks to 0 scale over the first 40% of the animation to
                      // smoothly break the liquid bridge.
                      // Blob A is the spawn blob; under morphFromZero there is no trigger to ghost.
                      // For standard/minimal quality, Blob A is suppressed during close so only
                      // the single collapsing menu container is visible (preventing double-button overlap).
                      if (!widget.morphFromZero &&
                          (!_morphController.isClosing || isPremium))
                        Positioned(
                          left: _triggerOverlayPosition.dx +
                              _followOffset.dx +
                              state.pushDx,
                          top: _triggerOverlayPosition.dy +
                              _followOffset.dy +
                              state.pushDy,
                          child: Transform.scale(
                            scale: state.anchorScale,
                            child: GlassContainer(
                              useOwnLayer: false,
                              settings: effectiveSettings,
                              quality: effectiveQuality,
                              platformViewBackdrop: widget.platformViewBackdrop,
                              width: tw,
                              height: th,
                              shape: LiquidRoundedRectangle(
                                borderRadius: _triggerBorderRadius ??
                                    _triggerSize!.shortestSide / 2.0,
                              ),
                            ),
                          ),
                        ),

                      // ── Blob B: Menu Body ───────────────────────────────────
                      // Its center travels diagonally relative to the trigger.
                      // By scaling the x/y offsets with the width/height curves,
                      // its edges stay perfectly pinned while it grows!
                      Positioned(
                        left: blobBLeft,
                        top: blobBTop,
                        child: IgnorePointer(
                          ignoring: clampedValue < 0.8,
                          child: _buildMorphingContainer(
                            state,
                            clampedValue,
                            currentWidth,
                            currentHeight,
                            currentRadius,
                          ),
                        ),
                      ),
                    ],
                  );

                  // Only wrap in LiquidGlassBlendGroup when the parent
                  // AdaptiveLiquidGlassLayer has provided an
                  // InheritedGeometryRenderLink (i.e. a full LiquidGlassLayer
                  // is in the tree). In minimal / platformViewBackdrop mode
                  // that layer is skipped, so the blend group must be too
                  //.
                  final Widget blobsGrouped = useBlendGroup
                      ? LiquidGlassBlendGroup(
                          blend: state.blend,
                          child: blobs,
                        )
                      : blobs;

                  // ── Submenu cards ─────────────────────────────────────────
                  // Each open level draws a second glass card OVER the menu
                  // body, outside the blend group so it never fuses with the
                  // body's metaball shape: the body recedes and dims below it
                  // (native iOS context menus). They fade out over the first
                  // part of a root close so the droplet collapses cleanly.
                  final cardsOpacity = _morphController.isClosing
                      ? ((clampedValue - 0.85) / 0.15).clamp(0.0, 1.0)
                      : 1.0;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      blobsGrouped,
                      if (_submenuStack.isNotEmpty && cardsOpacity > 0.0)
                        for (var i = 0; i < _submenuStack.length; i++)
                          Positioned(
                            left: _cardFlightRect(i).left,
                            top: _cardFlightRect(i).top,
                            child: IgnorePointer(
                              ignoring: clampedValue < 0.8 ||
                                  _contentMorph.isAnimating,
                              child: Opacity(
                                opacity: cardsOpacity,
                                child: _buildSubmenuCard(
                                  i,
                                  effectiveSettings,
                                  effectiveQuality,
                                ),
                              ),
                            ),
                          ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// The body height used for layout this frame. The body always shows the
  /// ROOT list: a submenu opens a card over it (see [_pushSubmenu]) rather
  /// than changing the body's height.
  double _calculateMenuHeight() => _targetBodyHeight();

  /// The resting height of the menu body: the ROOT list's natural height, or
  /// the fixed [GlassMenu.menuHeight] when set.
  double _targetBodyHeight() {
    if (widget.menuHeight != null) {
      return math.min(widget.menuHeight!, _maximumStackHeight);
    }

    // Account for system text scaling when calculating natural height.
    // Without this, increased text size causes items to render taller than
    // the height budget, triggering unwanted scrolling (GitHub issue).
    final mediaQuery = MediaQuery.maybeOf(context);

    // Sum all menu item heights, scaled by text scaler
    final itemHeights = widget.items.fold<double>(
      0.0,
      (sum, item) => sum + _getScaledItemHeight(item, context),
    );

    // Add vertical padding (12px top + 12px bottom = 24px total)
    // plus vertical gaps between items (2px each)
    final gaps = (widget.items.length - 1) * 2.0;
    final naturalHeight =
        math.min(itemHeights + 24.0 + gaps, _maximumStackHeight);

    if (widget.autoAdjustToScreen) {
      if (mediaQuery != null) {
        final flutterView = View.of(context);
        final mqPadding = EdgeInsets.fromViewPadding(
            flutterView.padding, flutterView.devicePixelRatio);

        // Clamp to screen height minus safe areas and a 20px safety buffer
        var maxHeight = mediaQuery.size.height -
            mqPadding.vertical -
            widget.menuPadding.vertical -
            20.0;
        // From the vertical bar strip, to the room below its status cluster.
        final stripTop = _triggerSize == null
            ? null
            : verticalBarPresentationTop(
                context,
                _triggerGlobalPosition & _triggerSize!,
              );
        if (stripTop != null) {
          maxHeight = math.min(
            maxHeight,
            mediaQuery.size.height -
                stripTop -
                mqPadding.bottom -
                widget.menuPadding.bottom,
          );
        }
        return math.min(naturalHeight, math.max(0.0, maxHeight));
      }
    }

    return naturalHeight;
  }

  Widget _buildMorphingContainer(LiquidMorphState state, double clampedValue,
      double currentWidth, double currentHeight, double currentRadius) {
    // Sub-pixel blob registers no blend-group shape: skip it so the premium
    // Impeller geometry never rasterizes a 0-area matte (Invalid image dimensions).
    // The 1.0 logical-px floor is provably safe at every devicePixelRatio: a
    // logical size in [0.5, 1.0) can still snap to a 0-area matte at dpr=1.0
    // (matteBounds = (bounds * dpr).snapToPixels(1); ceil() == 0), which would
    // reach the unclamped toImageSync in the geometry raster. Below 1.0 px is
    // invisible on any display, so flooring here costs nothing visually.
    if (currentWidth < 1.0 || currentHeight < 1.0) {
      return const SizedBox.shrink();
    }

    // Inherit quality from parent layer if not explicitly set
    final effectiveQuality = GlassThemeHelpers.resolveQuality(
      context,
      widgetQuality: widget.quality,
    );

    // ─── True Metaball Morphing ──────────────────────────────────────────────
    //
    // By using the pure spring value for both width and height, the menu container
    // expands uniformly while moving diagonally. This is the SECRET to the native
    // iOS liquid teardrop. The metaball shader naturally creates the bulbous bottom
    // and the pinched neck connecting back to the trigger.
    //
    // No more faking the shape with tall, thin rectangles! Let the shader do the work.

    // Build the shape
    final teardropShape = LiquidRoundedRectangle(
      borderRadius: currentRadius,
    );

    // containerScale is pre-computed by LiquidMorphPhysics inside GlassMorphController.
    final containerScale = state.containerScale;

    // ─── Item Stagger ─────────────────────────────────────────────────────────
    // Pre-compute per-item stagger offsets (used in _buildMorphingContainer
    // via the items list length).  Each item is offset by 20ms relative to
    // the previous one so they cascade in smoothly from top-to-bottom.

    // Inherit settings from context (like GlassCard/GlassContainer)
    // If user provides custom settings, use those. Otherwise, check for inherited
    // settings from parent layer. If none, use subtle overlay defaults.
    // This matches the pattern used by all other glass widgets.
    final inheritedSettings = InheritedLiquidGlass.of(context);
    final effectiveSettings = widget.settings ??
        inheritedSettings ??
        const LiquidGlassSettings(
          blur: 10,
          thickness: 10,
          glassColor: Color.fromRGBO(255, 255, 255, 0.12),
          lightAngle: GlassDefaults.lightAngle, // Apple iOS 26 standard
          lightIntensity: 0.7,
          ambientStrength: 0.4,
          saturation: 1.2,
          refractiveIndex: 0.7, // Thin rim - iOS 26 delicate aesthetic
          chromaticAberration: 0.0,
        );

    final glassContent = LiquidStretch(
      stretch: widget.stretch,
      interactionScale: widget.interactionScale,
      resistance: widget.stretchResistance,
      axis: widget.stretchAxis,
      suppressInteractionOnChildren: false,
      anchorStretch: false, // Menus use jelly-follow, not anchored
      // Constrain stretch to 'Down' and 'Away from screen edge' by default,
      // but allow explicit user overrides.
      allowPositiveX: widget.allowPositiveX ?? (_morphAlignment.x < 0),
      allowNegativeX: widget.allowNegativeX ?? (_morphAlignment.x > 0),
      allowPositiveY: widget.allowPositiveY ?? (_morphAlignment.y < 0),
      allowNegativeY: widget.allowNegativeY ?? (_morphAlignment.y > 0),
      child: GlassContainer(
        useOwnLayer: false, // blends with the trigger ghost
        settings: effectiveSettings,
        quality: effectiveQuality,
        platformViewBackdrop: widget.platformViewBackdrop,
        allowElevation:
            false, // Menu is overlay - don't darken when outside parent
        width: currentWidth,
        height: currentHeight, // Constrained during morph, natural when open
        shape: teardropShape,
        clipBehavior:
            Clip.antiAlias, // Clip items at the edges for edge-to-edge feel
        glowIntensity: widget.glowIntensity,
        child: _buildBodyContent(
          effectiveSettings,
          effectiveQuality,
          clampedValue,
          teardropShape,
          containerScale,
        ),
      ), // GlassContainer
    ); // LiquidStretch (glassContent)

    // The blob is always fully opaque — shape morph is the only animation.
    return Transform.scale(
      scale: lerpDouble(1.0, _kRecedeScale, _bodyRecede)!,
      alignment: Alignment(0, _growsDown ? -1 : 1),
      child: glassContent,
    );
  }

  /// The menu body's content: the interactive root list, or the same rows
  /// dimmed and inert while a submenu card covers them. Scales with the
  /// container morph like the old in-tree content did.
  Widget _buildBodyContent(
    LiquidGlassSettings settings,
    GlassQuality quality,
    double clampedValue,
    LiquidRoundedRectangle teardropShape,
    double containerScale,
  ) {
    final isDark = GlassTheme.brightnessOf(context) == Brightness.dark;
    final interactive = _submenuStack.isEmpty;
    return GlassGlow(
      enabled: widget.enableInteractionGlow && interactive,
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
        scale: containerScale,
        alignment: Alignment.center,
        child: Stack(
          alignment: _morphAlignment,
          clipBehavior: Clip.none,
          children: [
            // Menu content scales up with the container morph — items
            // enter the tree at 25% on open, and flush immediately on close
            // so the droplet is clean liquid glass throughout its flight.
            if (_morphController.isClosing
                ? clampedValue > 0.85
                : clampedValue > 0.25)
              OverflowBox(
                alignment: _morphAlignment,
                minWidth: widget.menuWidth,
                maxWidth: widget.menuWidth,
                minHeight: 0.0,
                maxHeight: double.infinity,
                child: _buildListContent(
                  widget.items,
                  interactive: interactive,
                  dimmed: !interactive,
                  coveredDepth: interactive ? null : 0,
                  coverProgress: _bodyRecede,
                  viewportHeight: _targetBodyHeight(),
                  morphValue: clampedValue,
                  passiveScrollOffset: interactive
                      ? 0.0
                      : _submenuStack.first.sourceScrollOffset,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// One menu list (the body's, or a card's): the sliding selection pill, the
  /// pointer [Listener] that drives slide-to-select, and the rows — wrapped
  /// and interactive, or plain and inert when [dimmed] (a covered level).
  ///
  /// The [_menuContentKey] lives on whatever list is INTERACTIVE: the body's
  /// at level 0, the top card's otherwise. It moves between them in the same
  /// build, so a glide maps into the list the finger is actually over.
  Widget _buildListContent(
    List<Widget> items, {
    required bool interactive,
    required bool dimmed,
    double coverProgress = 0.0,
    required double viewportHeight,
    double morphValue = 1.0,
    double passiveScrollOffset = 0.0,
    int? coveredDepth,
  }) {
    final coveredOpacity =
        coveredDepth == null ? 1.0 : _coveredRowOpacity(coveredDepth);
    final itemOpacity = _morphController.isClosing
        ? ((morphValue - 0.85) / 0.15).clamp(0.0, 1.0)
        : ((morphValue - 0.25) / 0.45).clamp(0.0, 1.0);
    final itemScale = lerpDouble(
        0.7,
        1.0,
        Curves.easeOut
            .transform(((morphValue - 0.25) / 0.75).clamp(0.0, 1.0)))!;
    final rows = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: _kBodyVerticalPadding),
        for (var i = 0; i < items.length; i++) ...[
          Opacity(
            opacity:
                coveredDepth != null && _isCoveredRow(coveredDepth, i, items)
                    ? itemOpacity * coveredOpacity
                    : itemOpacity,
            child: Transform.scale(
              scale: itemScale,
              child: interactive ? _buildWrappedItems()[i] : items[i],
            ),
          ),
          if (i < items.length - 1) const SizedBox(height: _kRowGap),
        ],
        const SizedBox(height: _kBodyVerticalPadding),
      ],
    );
    final listBody = SizedBox(
      width: widget.menuWidth,
      height: viewportHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: interactive
            ? SingleChildScrollView(
                controller: _scrollController,
                primary: false,
                physics: _isScrollable
                    ? const ClampingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                child: rows,
              )
            : ClipRect(
                child: OverflowBox(
                alignment: Alignment.topCenter,
                maxHeight: double.infinity,
                child: Transform.translate(
                    offset: Offset(0, -passiveScrollOffset), child: rows),
              )),
      ),
    );

    if (dimmed) {
      // A covered level: dimmed, inert, and tapping its visible part closes
      // the card over it (native iOS behavior) without running anything.
      return Opacity(
        opacity: lerpDouble(1.0, _kDimmedOpacity, coverProgress)!,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _popSubmenu,
          child: ExcludeSemantics(
            child: ExcludeFocus(child: IgnorePointer(child: listBody)),
          ),
        ),
      );
    }

    return AbsorbPointer(
        absorbing: _contentMorph.isAnimating,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Sliding selection pill (background)
            ValueListenableBuilder<int?>(
              valueListenable: _hoveredIndexNotifier,
              builder: (context, hoveredIndex, _) {
                if (hoveredIndex == null) {
                  return const SizedBox.shrink();
                }
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOutCubic,
                  left: 12,
                  right: 12,
                  top: _listRowTop(hoveredIndex, items) -
                      (_scrollController.hasClients
                          ? _scrollController.offset
                          : 0.0),
                  height: _getScaledItemHeight(items[hoveredIndex], context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.selectionColor,
                      borderRadius:
                          BorderRadius.circular(widget.itemBorderRadius),
                      border: Border.all(
                        color:
                            GlassTheme.brightnessOf(context) == Brightness.dark
                                ? const Color(0x0DFFFFFF)
                                : const Color(0x0D000000),
                        width: 0.5,
                      ),
                    ),
                  ),
                );
              },
            ),
            MouseRegion(
              // A mouse resting on a row moves the selection pill there, the
              // same highlight a press-and-slide shows. The rows' own hover
              // fill is a white wash meant for dark glass and disappears on
              // light glass, so without this a pointer gets no hover at all.
              onExit: (_) {
                if (!mounted || _isDragging) return;
                _hoveredIndex = null;
                _hoveredIndexNotifier.value = null;
              },
              child: Listener(
                onPointerHover: (event) {
                  if (!mounted || _isDragging) return;
                  final index =
                      _calculateIndexFromPosition(event.localPosition, context);
                  _hoveredIndex = index;
                  _hoveredIndexNotifier.value = index;
                },
                onPointerDown: (event) {
                  if (!mounted) return;
                  _isDragging = true;
                  _isDraggingNotifier.value = true;
                  _hasStretched = false;
                  _initialScrollOffset = _scrollController.hasClients
                      ? _scrollController.offset
                      : 0.0;
                  _updateHoveredIndex(event.localPosition);
                },
                onPointerMove: (event) {
                  if (!mounted) return;
                  if (_isDragging) {
                    _updateHoveredIndex(event.localPosition);
                  }
                },
                onPointerUp: (event) {
                  if (!mounted) return;
                  // The row's own tap recogniser fires later in this same dispatch;
                  // it must not activate the row a second time (see
                  // _buildWrappedItems).
                  _bodyPointerUpHandled = true;
                  scheduleMicrotask(() => _bodyPointerUpHandled = false);
                  if (_isDragging) {
                    final currentOffset = _scrollController.hasClients
                        ? _scrollController.offset
                        : 0.0;
                    final scrollDisplacement =
                        (currentOffset - _initialScrollOffset).abs();

                    // Slide-to-select logic (for non-scrollable menus, tap or
                    // slide-and-release).
                    if (scrollDisplacement < 10 && !_isScrollable) {
                      final indexToTap = _hoveredIndex ??
                          _calculateIndexFromPosition(
                              event.localPosition, context);
                      if (indexToTap != null) {
                        final item = _items[indexToTap];
                        if (item is GlassMenuItem && item.enabled) {
                          _activateItem(item);
                        }
                      }
                    }
                    _isDragging = false;
                    _isDraggingNotifier.value = false;
                    _hoveredIndex = null;
                    _hoveredIndexNotifier.value = null;
                    _hasStretched = false;
                  }
                },
                onPointerCancel: (_) {
                  if (!mounted) return;
                  _isDragging = false;
                  _isDraggingNotifier.value = false;
                  _hoveredIndex = null;
                  _hoveredIndexNotifier.value = null;
                },
                child: SizedBox(
                  key: interactive ? _menuContentKey : null,
                  width: widget.menuWidth,
                  height: viewportHeight,
                  child: listBody.child!,
                ),
              ),
            ),
          ],
        ));
  }

  List<Widget> _buildWrappedItems() {
    return _cachedWrappedItems ??= _items.asMap().entries.map((entry) {
      final item = entry.value;

      if (item is GlassMenuItem) {
        return _SelectionItemWrapper(
          index: entry.key,
          hoverNotifier: _hoveredIndexNotifier,
          dragNotifier: _isDraggingNotifier,
          builder: (context, isSelected, isPressed) {
            return GlassMenuItem(
              key: item.key ?? ValueKey(item.title),
              title: item.title,
              subtitle: item.subtitle,
              icon: item.icon,
              isDestructive: item.isDestructive,
              enabled: item.enabled,
              trailing: item.trailing,
              height: item.height,
              titleStyle: item.titleStyle,
              subtitleStyle: item.subtitleStyle,
              iconColor: item.iconColor,
              iconSize: item.iconSize,
              maxLines: item.maxLines,
              closeDelay: item.closeDelay,
              enablePressScale: item.enablePressScale,
              submenu: item.submenu,
              isSelected: isSelected,
              isPressed: isPressed,
              onTap: () {
                if (!item.enabled) return;
                // For scrollable menus, we delegate taps to the native GestureDetector
                // so it can properly participate in the gesture arena with the ScrollView.
                if (_isScrollable) {
                  _activateItem(item);
                  return;
                }
                // Non-scrollable menus activate touches from the body
                // Listener (slide-to-select), which runs first and marks the
                // pointer event as handled. An onTap with no pointer behind
                // it is a keyboard or assistive-technology activation
                // (VoiceOver / TalkBack), which must still work.
                if (_bodyPointerUpHandled) return;
                _activateItem(item);
              },
            );
          },
        );
      }
      return item;
    }).toList();
  }

  bool get _isScrollable {
    return (_submenuStack.isEmpty && widget.menuHeight != null) ||
        _activeHeight < _listHeight(_items) - 1.0;
  }

  double get _activeHeight => _submenuStack.isEmpty
      ? _targetBodyHeight()
      : _cardRect(_submenuStack.length - 1).height;

  double get _maximumStackHeight {
    final external = widget.maxStackHeight ?? double.infinity;
    if (!widget.autoAdjustToScreen) return external;
    final mq = MediaQuery.of(context);
    return math.min(
        external,
        math.max(
            0.0,
            mq.size.height -
                mq.padding.vertical -
                widget.menuPadding.vertical -
                20));
  }

  double _visibleListHeight(List<Widget> items) =>
      math.min(_listHeight(items), _maximumStackHeight);

  /// Accounts for system text scaling.
  ///
  /// When the user increases the system text size, GlassMenuItem renders
  /// with scaled text inside a ConstrainedBox (minHeight). The text content
  /// may push the actual height beyond the nominal [GlassMenuItem.height].
  /// This method estimates the rendered height to prevent the menu from
  /// becoming scrollable when it shouldn't be.
  double _getScaledItemHeight(Widget item, BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    final textScaler = mediaQuery?.textScaler ?? TextScaler.noScaling;

    if (item is GlassMenuItem) {
      // The item has 8px vertical padding top + bottom = 16px fixed chrome.
      // The remaining space is text content that scales with system text size.
      const fixedPadding = 16.0;
      final baseFontSize = item.titleStyle?.fontSize ?? 17.0;
      final scaledFontSize = textScaler.scale(baseFontSize);
      final lineHeight = scaledFontSize * 1.2; // Approximate line height
      final textHeight = lineHeight * item.maxLines;

      // Subtitle adds another scaled line
      double subtitleHeight = 0;
      if (item.subtitle != null) {
        final subFontSize = item.subtitleStyle?.fontSize ?? 13.0;
        subtitleHeight = textScaler.scale(subFontSize) * 1.2;
      }

      final contentHeight = textHeight + subtitleHeight + fixedPadding;
      // Use the larger of nominal height or scaled content height
      return math.max(item.height, contentHeight);
    }
    // Dividers and labels don't contain user-facing scaled text
    if (item is GlassMenuDivider) return item.height;
    if (item is GlassMenuLabel) return item.height;
    if (item is PreferredSizeWidget) return item.preferredSize.height;
    return 44.0;
  }

  int? _calculateIndexFromPosition(Offset localPosition, BuildContext context) {
    final visibleHeight = _activeHeight;
    final x = localPosition.dx;
    final dy = localPosition.dy;
    final y =
        dy + (_scrollController.hasClients ? _scrollController.offset : 0.0);

    final isWithinActiveZone = x > -20 &&
        x < widget.menuWidth + 20 &&
        dy > -20 &&
        dy < visibleHeight + 20;

    if (!isWithinActiveZone) return null;

    double currentOffset = 12.0;
    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      final itemHeight = _getScaledItemHeight(item, context);

      // Rows own half of each 2 px gap on either side, so the hit zones are
      // contiguous: a release between two rows activates the nearer row
      // instead of silently doing nothing.
      if (y >= currentOffset - 1.0 && y < currentOffset + itemHeight + 1.0) {
        if (item is GlassMenuItem && item.enabled) {
          return i;
        }
        break;
      }
      currentOffset += itemHeight + 2.0; // height + 2px gap
    }
    return null;
  }

  void _updateHoveredIndex(Offset localPosition) {
    // Detect if we've moved into "stretch territory" (outside visible menu bounds)
    final visibleHeight = _activeHeight;
    final x = localPosition.dx;
    final dy = localPosition.dy;

    // We add a 100px buffer to allow for intense liquid stretching without accidental closure.
    // We also allow cancelling the stretch if the user moves their finger back.
    final outsideBounds = dy < -100 ||
        dy > visibleHeight + 100 ||
        x < -100 ||
        x > widget.menuWidth + 100;

    if (_hasStretched != outsideBounds) {
      setState(() => _hasStretched = outsideBounds);
    }

    int? detectedIndex;

    // Only calculate hover selection for non-scrollable menus (slide-to-select).
    if (!_isScrollable) {
      detectedIndex = _calculateIndexFromPosition(localPosition, context);
    }

    _hoveredIndex = detectedIndex;
    _hoveredIndexNotifier.value = detectedIndex;
  }
}

/// Internal helper to update selection state for cached items.
class _SelectionItemWrapper extends StatelessWidget {
  final int index;
  final ValueNotifier<int?> hoverNotifier;
  final ValueNotifier<bool> dragNotifier;
  final Widget Function(BuildContext context, bool isSelected, bool isPressed)
      builder;

  const _SelectionItemWrapper({
    required this.index,
    required this.hoverNotifier,
    required this.dragNotifier,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: hoverNotifier,
      builder: (context, hoveredIndex, _) {
        final isSelected = hoveredIndex == index;
        return ValueListenableBuilder<bool>(
          valueListenable: dragNotifier,
          builder: (context, isDragging, _) {
            return builder(context, isSelected, isDragging && isSelected);
          },
        );
      },
    );
  }
}

const Duration _kSubmenuMorphDuration = Duration(milliseconds: 320);
const Curve _kSubmenuMorphCurve = Curves.easeOutCubic;
const double _kBodyVerticalPadding = 12.0;
const double _kRowGap = 2.0;

/// Geometry is captured before switching the active scroll viewport. Titles
/// are not identifiers: two rows may have the same label.
class _SubmenuLevel {
  const _SubmenuLevel({
    required this.list,
    required this.sourceRowTop,
    required this.sourceRowHeight,
    required this.sourceScrollOffset,
  });

  final List<Widget> list;
  final double sourceRowTop;
  final double sourceRowHeight;
  final double sourceScrollOffset;
}

/// The source row repeated as a collapsible header, not a generic Back action.
class _GlassMenuHeaderItem extends GlassMenuItem {
  const _GlassMenuHeaderItem({
    super.key,
    required super.title,
    super.icon,
    super.height,
    super.titleStyle,
    super.iconColor,
    super.iconSize,
    super.enablePressScale,
  }) : super(
            trailing: const Icon(CupertinoIcons.chevron_down, size: 16),
            onTap: _noop);

  static void _noop() {}
}
