// ignore_for_file: public_member_api_docs
// Shared internal widget for GlassSegmentedControl — scrollable mode.
//
// NOT part of the public API — do not export from liquid_glass_widgets.dart.
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart' show RenderPositionedBox;
import '../../../constants/glass_defaults.dart';
import '../../renderer/liquid_glass_renderer.dart';
import '../../../types/glass_quality.dart';
import '../../../utils/draggable_indicator_physics.dart';
import '../../../utils/glass_spring.dart';
import '../../../widgets/shared/animated_glass_indicator.dart';
import '../../../widgets/surfaces/shared/tab_bar_types.dart'
    show MaskingQuality;
import '../../../widgets/shared/glass_accessibility_scope.dart'
    show GlassAccessibilityData;
import '../../../widgets/surfaces/glass_tab_bar.dart'
    show
        GlassSegment,
        DividerSettings,
        SegmentDragBehavior,
        SegmentSelectionAlignment;

// =============================================================================
// ScrollableSegmentContent — draggable indicator + segment layout
// =============================================================================

/// Internal stateful widget managing the scrollable pill indicator and segment
/// items for [GlassSegmentedControl.scrollable].
///
/// Extracted from [GlassSegmentedControl] to keep the public widget focused on
/// configuration and glass-layer wrapping, while this widget owns all gesture,
/// spring, and rendering logic for the scrollable layout mode.
class ScrollableSegmentContent extends StatefulWidget {
  const ScrollableSegmentContent({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.isScrollable,
    required this.scrollController,
    required this.indicatorColor,
    required this.selectedLabelStyle,
    required this.unselectedLabelStyle,
    required this.selectedIconColor,
    required this.unselectedIconColor,
    required this.iconSize,
    required this.labelPadding,
    required this.quality,
    this.indicatorBorderRadius,
    this.indicatorSettings,
    this.indicatorPinchStrength = 0.4,
    this.indicatorExpansion =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.backgroundKey,
    this.maskingQuality = MaskingQuality.high,
    this.dividerSettings,
    this.indicatorShadow,
    this.tabBarBorderRadius,
    this.selectionAlignment = SegmentSelectionAlignment.minimal,
    this.regridDuration = Duration.zero,
    this.dragBehavior = SegmentDragBehavior.selectIndicator,
    super.key,
  });

  final List<GlassSegment> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final bool isScrollable;
  final ScrollController scrollController;
  final Color? indicatorColor;
  final TextStyle? selectedLabelStyle;
  final TextStyle? unselectedLabelStyle;
  final Color? selectedIconColor;
  final Color? unselectedIconColor;
  final double iconSize;
  final EdgeInsetsGeometry labelPadding;
  final GlassQuality quality;
  final double? indicatorBorderRadius;
  final LiquidGlassSettings? indicatorSettings;

  /// Maximum concave lens pinch strength. Forwarded to [AnimatedGlassIndicator].
  final double indicatorPinchStrength;

  /// Expansion padding applied to the pill during drag — mirrors [GlassTabBar.bottom].
  final EdgeInsetsGeometry indicatorExpansion;
  final GlobalKey? backgroundKey;
  final MaskingQuality maskingQuality;
  final DividerSettings? dividerSettings;

  /// Optional shadows for the active indicator pill. Passed through to
  /// [AnimatedGlassIndicator] but suppressed while a drag is in progress so
  /// the shadow does not interact with the live BackdropFilter blur.
  final List<BoxShadow>? indicatorShadow;

  /// Border radius of the outer tab bar container — used to clip Layer 1
  /// (tab labels + background pill) to the same rounded shape.
  final BorderRadius? tabBarBorderRadius;

  /// See [GlassSegmentedControl.selectionAlignment].
  final SegmentSelectionAlignment selectionAlignment;

  /// See [GlassSegmentedControl.regridDuration].
  final Duration regridDuration;

  /// See [GlassSegmentedControl.dragBehavior].
  final SegmentDragBehavior dragBehavior;

  @override
  State<ScrollableSegmentContent> createState() =>
      ScrollableSegmentContentState();
}

/// State for [ScrollableSegmentContent]. Public for testing via `@visibleForTesting`.
@visibleForTesting
class ScrollableSegmentContentState extends State<ScrollableSegmentContent>
    with TickerProviderStateMixin {
  // Cache default indicator color to avoid allocations
  static const _defaultIndicatorColor =
      Color(0x33FFFFFF); // white.withValues(alpha: 0.2)

  bool _isDown = false;
  bool _isDragging = false;
  late double _xAlign = _computeXAlignmentForTab(widget.selectedIndex);

  /// Specifically tracks if we are dragging the indicator in scrollable mode.
  bool _isDraggingIndicator = false;

  /// Bumped whenever the indicator springs are snapped
  /// ([SingleSpringController.setValue]) onto freshly measured geometry —
  /// initial mount and list-length remeasures. Rides into
  /// [VelocitySpringBuilder.teleportEpoch] so the rendered pill JUMPS with
  /// the springs; without it the follower animated across the
  /// discontinuity, which showed as the pill travelling in from the track
  /// edge on every mount and list change.
  int _indicatorEpoch = 0;

  // ── Re-grid morph (list-length changes, scrollable mode) ─────────────────
  //
  // When the segment list changes around a surviving selection, the old and
  // new lists are MERGED by identity and rendered together for
  // [ScrollableSegmentContent.regridDuration]: entering cells grow in
  // (width 0→natural via Align.widthFactor, with scale 0.8→1 and fade
  // riding the same curve), leaving cells shrink out, and the survivors
  // glide as the Row re-flows around them. The SELECTED cell is anchored:
  // a per-tick scroll correction holds it at the screen position it had
  // when the morph began, and the pill is drawn at that anchor directly.
  // Taps and indicator drags are ignored for the (sub-200 ms) morph; a
  // second list change mid-morph completes the current one instantly.
  List<GlassSegment>? _morphTabs; // merged render list, null = not morphing
  Set<int>? _morphEntering; // indices into _morphTabs
  Set<int>? _morphExiting;
  AnimationController? _morphCtrl;
  CurvedAnimation? _morphAnim;
  double? _morphAnchorLocalX; // anchor in the control's coordinates
  int _morphSelectedIndex = 0; // selected cell's index in _morphTabs

  /// Natural (unfactored) width of every merged cell — survivors and
  /// leavers from the old list's measurements, entrants measured from
  /// their INNER boxes at the t=0 frame (the Align sizes the outer box to
  /// zero, but the child inside it is laid out at full natural width).
  /// With these, the anchoring scroll offset is computed ANALYTICALLY per
  /// tick — a correction chasing last frame's boxes lags one frame, which
  /// is catastrophic when a debug build only paints a handful of morph
  /// frames.
  List<double>? _morphNaturalWidths;

  /// True from the morph's end until the post-morph measure has epoch-
  /// snapped the springs onto the final geometry. The pill keeps drawing
  /// at the anchor through this gap — without it, one frame rendered from
  /// the springs' STALE pre-morph coordinates before the snap landed,
  /// which read as the highlight blinking after the morph.
  bool _morphSettling = false;

  bool get _morphing => _morphTabs != null;

  /// Guards the two-beat centering against rapid re-selection.
  int _seatGen = 0;

  /// Delay between the pill's travel starting and the centering scroll.
  /// The pill's snappy spring covers most of its distance by ~150 ms, so
  /// starting the glide there keeps the select-then-settle ORDER legible
  /// while the two motions blend (250 ms read as too separated on device
  /// — Joe, 2026-08-29).
  static const Duration _kCenterAfterSelectDelay = Duration(milliseconds: 150);

  /// Seats a newly selected segment per the alignment policy.
  ///
  /// [SegmentSelectionAlignment.minimal] ensure-visibles immediately.
  /// [SegmentSelectionAlignment.center] plays TWO BEATS, picker-style:
  /// the pill travels to the chosen segment FIRST while the scroll holds
  /// (selection feedback happens where the finger is), then the strip
  /// glides the choice to center with the pill riding its cell. Centering
  /// simultaneously with the pill's travel made both land in the same
  /// instant — nothing ever visibly arrived at the tapped spot.
  void _seatSelection(int index) {
    if (widget.selectionAlignment != SegmentSelectionAlignment.center) {
      _scrollToEnsureVisible(index);
      return;
    }
    final gen = ++_seatGen;
    Future.delayed(_kCenterAfterSelectDelay, () {
      if (!mounted || gen != _seatGen || _morphing || _isDragging) return;
      if (widget.selectedIndex != index) return; // superseded
      _scrollToEnsureVisible(index);
    });
  }

  /// The list currently RENDERED — the merged morph list while morphing.
  List<GlassSegment> get _renderTabs => _morphTabs ?? widget.tabs;

  /// Shadows are suppressed while the indicator is being dragged so they
  /// do not interact with the live BackdropFilter blur, then restored
  /// when the pill is idle.
  List<BoxShadow>? get _effectiveShadow =>
      _isDraggingIndicator ? null : widget.indicatorShadow;

  // Scrollable-overlay indicator position, animated in content space.
  // Decoupled from the _xAlign spring so scroll never causes drift.
  late SingleSpringController _indOffsetSpring;
  late SingleSpringController _indWidthSpring;

  // D1: hoisted — avoids allocating a new _MergedListenable on every build.
  // Drives the ListenableBuilder that wraps VelocitySpringBuilder so spring
  // ticks rebuild only the indicator subtree, not the full State.build().
  late Listenable _springListenable;

  late List<GlobalKey> _tabKeys;
  final Map<Object, GlobalKey> _cellKeysById = {};
  List<double> _tabWidths = [];
  List<double> _tabOffsets = [];

  // Gesture recognizers for precision control.
  late HorizontalDragGestureRecognizer _drag;
  late TapGestureRecognizer _tap;

  @override
  void initState() {
    super.initState();
    _indOffsetSpring = SingleSpringController(
      vsync: this,
      spring: GlassSpring.snappy(duration: const Duration(milliseconds: 350)),
    );
    _indWidthSpring = SingleSpringController(
      vsync: this,
      spring: GlassSpring.snappy(duration: const Duration(milliseconds: 350)),
    );
    // D1: create once — controllers never change after initState.
    // ListenableBuilder in build() listens to this; no setState on spring ticks.
    _springListenable = Listenable.merge([_indOffsetSpring, _indWidthSpring]);
    _initKeys();
    if (widget.isScrollable) {
      widget.scrollController.addListener(_onScroll);
    }

    // Setup Gesture Arena Team to allow indicator drag to "steal" focus from ScrollView.
    final team = GestureArenaTeam();
    _drag = HorizontalDragGestureRecognizer()
      ..team = team
      ..onDown = _handleDragDown
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..onCancel = _handleDragCancel;

    team.captain = _drag;

    _tap = TapGestureRecognizer()..onTapUp = _handleTapUp;
  }

  void _onScroll() {
    // During a morph the pill is drawn at a fixed anchor and the per-tick
    // correction drives the scroll — rebuilding here would double the
    // per-frame cost for nothing.
    if (_morphing) return;
    // Rebuild to update the screen-relative indicator position during scroll.
    if (mounted) setState(() {});
  }

  void _initKeys() {
    // Cells keep their key across list changes when their segment carries
    // the same identity ([GlassSegment.id], falling back to label): a
    // surviving value keeps its element instead of remounting, so a
    // reconfigured list redraws only what actually changed. Segments with
    // no identity, or a duplicated one, get fresh cells.
    final tabs = _renderTabs;
    final seen = <Object>{};
    _tabKeys = List.generate(tabs.length, (i) {
      final Object? id = tabs[i].id ?? tabs[i].label;
      if (id == null || !seen.add(id)) return GlobalKey();
      return _cellKeysById.putIfAbsent(id, GlobalKey.new);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureTabs());
  }

  void _measureTabs() {
    if (!mounted || _morphing) return;
    double offset = 0;
    List<double> widths = [];
    List<double> offsets = [];
    bool allMeasured = true;
    final dividerWidth = widget.dividerSettings?.thickness ?? 0.0;
    for (int i = 0; i < _tabKeys.length; i++) {
      final box = _tabKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) {
        allMeasured = false;
        break;
      }
      final width = box.size.width;
      offsets.add(offset);
      widths.add(width);
      offset += width;
      if (widget.dividerSettings != null && i != _tabKeys.length - 1) {
        offset += dividerWidth;
      }
    }
    if (allMeasured) {
      final selIdx = widget.selectedIndex.clamp(0, widths.length - 1);
      setState(() {
        _tabWidths = widths;
        _tabOffsets = offsets;
        // Snap indicator to the selected tab after (re)measure; the epoch
        // makes the rendered pill jump with the springs instead of
        // animating in from stale geometry. This is also the handoff that
        // releases a morph's anchor — by now spring-position minus scroll
        // equals the anchor, so the switch is pixel-invisible.
        _indicatorEpoch++;
        _morphSettling = false;
        _indOffsetSpring.setValue(offsets[selIdx]);
        _indWidthSpring.setValue(widths[selIdx]);
      });
      // A selection outside the viewport comes into view without animation:
      // at first measure there is no prior state the user has seen, and
      // after a list change the host may have positioned the scroll itself
      // (with [SegmentSelectionAlignment.minimal] this no-ops when the
      // selection is already on screen; [SegmentSelectionAlignment.center]
      // seats it centered).
      _scrollToEnsureVisible(selIdx, animated: false);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureTabs());
    }
  }

  @override
  void dispose() {
    _morphAnim?.dispose();
    _morphCtrl?.dispose();
    _indOffsetSpring.dispose();
    _indWidthSpring.dispose();
    _drag.dispose();
    _tap.dispose();
    if (widget.isScrollable) {
      widget.scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(ScrollableSegmentContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle scrollController swap (e.g., parent provides a new controller).
    if (widget.isScrollable &&
        oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_onScroll);
      widget.scrollController.addListener(_onScroll);
    }

    // Handle isScrollable toggling (unlikely in practice, but safe).
    if (!oldWidget.isScrollable && widget.isScrollable) {
      widget.scrollController.addListener(_onScroll);
      // Re-measure in scrollable mode — tab widths may differ.
      setState(() {
        _tabWidths = [];
        _tabOffsets = [];
      });
      _indOffsetSpring.setValue(0);
      _indWidthSpring.setValue(0);
      _initKeys();
    } else if (oldWidget.isScrollable && !widget.isScrollable) {
      oldWidget.scrollController.removeListener(_onScroll);
      // Re-measure in non-scrollable mode (expanded layout).
      setState(() {
        _tabWidths = [];
        _tabOffsets = [];
      });
      _indOffsetSpring.setValue(0);
      _indWidthSpring.setValue(0);
      _initKeys();
    }

    // A length change owns the whole transition (morph or snap): its
    // measure pass seats both the pill and the scroll. Letting this branch
    // also run would spring the pill and ensure-visible against STALE
    // offsets from the outgoing list — the two visibly fight (verified
    // frame-by-frame: the scroll lunged toward the stale target while the
    // morph anchor dragged it back).
    final lengthChanged = oldWidget.tabs.length != widget.tabs.length;
    if (!lengthChanged &&
        oldWidget.selectedIndex != widget.selectedIndex &&
        !_isDragging) {
      setState(() {
        _xAlign = _computeXAlignmentForTab(widget.selectedIndex);
      });
      // Animate overlay indicator to new tab (scrollable mode).
      if (widget.isScrollable &&
          widget.selectedIndex < _tabOffsets.length &&
          widget.selectedIndex < _tabWidths.length) {
        _indOffsetSpring.setValue(_tabOffsets[widget.selectedIndex]);
        _indWidthSpring.animateTo(_tabWidths[widget.selectedIndex]);
      }
      // Programmatic selection change — seat the new tab (immediately, or
      // in the centering second beat).
      if (widget.isScrollable) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _seatSelection(widget.selectedIndex),
        );
      }
    }
    if (lengthChanged) {
      if (_morphing) _finishMorph(jumpToEnd: true);
      final reduceMotion = GlassAccessibilityData.of(context).reduceMotion;
      if (widget.isScrollable &&
          !reduceMotion &&
          widget.regridDuration > Duration.zero &&
          _tryStartMorph(oldWidget.tabs)) {
        return;
      }
      setState(() {
        _xAlign = _computeXAlignmentForTab(widget.selectedIndex);
        _tabWidths = [];
        _tabOffsets = [];
      });
      // The springs deliberately KEEP their last geometry: zeroing them
      // hid the pill for the remeasure gap and then made it travel in
      // from the track edge. The pill holds its stale position for the
      // remeasure frame and the epoch-snap in [_measureTabs] lands it on
      // the new geometry with no travel.
      _initKeys();
    }
  }

  static Object? _identityOf(GlassSegment t) => t.id ?? t.label;

  /// Begins the re-grid morph from [oldTabs] to `widget.tabs`. Returns
  /// false (caller falls back to the snap path) when there is nothing to
  /// anchor: no measured geometry yet, or the selected segment's identity
  /// does not survive the change.
  bool _tryStartMorph(List<GlassSegment> oldTabs) {
    if (_tabWidths.length != oldTabs.length) return false;
    if (!widget.scrollController.hasClients) return false;
    final selId = _identityOf(widget.tabs[widget.selectedIndex]);
    if (selId == null) return false;
    final oldIds = [for (final t in oldTabs) _identityOf(t)];
    final oldSel = oldIds.indexOf(selId);
    if (oldSel < 0) return false;

    // Merge: walk the NEW list, interleaving each exiting old segment
    // after the surviving predecessor it followed in the old order.
    final newIds = {
      for (final t in widget.tabs)
        if (_identityOf(t) != null) _identityOf(t)!,
    };
    final exitingAfter = <Object?, List<GlassSegment>>{};
    Object? lastSurvivor;
    for (var i = 0; i < oldTabs.length; i++) {
      final id = oldIds[i];
      if (id != null && newIds.contains(id)) {
        lastSurvivor = id;
      } else {
        (exitingAfter[lastSurvivor] ??= []).add(oldTabs[i]);
      }
    }
    final merged = <GlassSegment>[];
    final entering = <int>{};
    final exiting = <int>{};
    void addExiting(Object? afterId) {
      for (final t in exitingAfter[afterId] ?? const <GlassSegment>[]) {
        exiting.add(merged.length);
        merged.add(t);
      }
    }

    addExiting(null); // old leaders with no surviving predecessor
    for (final t in widget.tabs) {
      final id = _identityOf(t);
      final survives = id != null && oldIds.contains(id);
      if (!survives) entering.add(merged.length);
      merged.add(t);
      if (survives) addExiting(id);
    }
    if (entering.isEmpty && exiting.isEmpty) return false;

    // Anchor: where the selected cell sits RIGHT NOW.
    final anchorLocal = _tabOffsets[oldSel] - widget.scrollController.offset;

    // Natural widths: old-list cells are already measured; entrants are
    // filled in from their inner boxes once the t=0 frame has laid out.
    final oldWidthById = <Object, double>{
      for (var i = 0; i < oldTabs.length; i++)
        if (oldIds[i] != null) oldIds[i]!: _tabWidths[i],
    };
    final naturals = <double>[
      for (var i = 0; i < merged.length; i++)
        entering.contains(i)
            ? 0.0
            : oldWidthById[_identityOf(merged[i])] ?? 0.0,
    ];

    _morphTabs = merged;
    _morphEntering = entering;
    _morphExiting = exiting;
    _morphSelectedIndex = merged.indexWhere((t) => _identityOf(t) == selId);
    _morphAnchorLocalX = anchorLocal;
    _morphNaturalWidths = naturals;
    _morphCtrl?.dispose();
    _morphAnim?.dispose();
    final ctrl =
        AnimationController(vsync: this, duration: widget.regridDuration)
          ..addListener(_onMorphTick)
          ..addStatusListener((st) {
            if (st == AnimationStatus.completed) _finishMorph();
          });
    _morphCtrl = ctrl;
    _morphAnim = CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic);
    setState(_initKeys); // keys for the merged list; survivors keep theirs
    // The clock starts only after the merged list's FIRST frame has been
    // built and laid out. At t=0 that frame is pixel-identical to the old
    // list (entrants at width 0, leavers at full), and it carries the whole
    // re-parenting cost — on a debug build it can take longer than the
    // entire morph, which previously let the clock expire inside it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _morphCtrl != ctrl) return;
      if (!_measureEnteringNaturals()) {
        // Can't anchor without real widths — degrade to the snap path.
        _finishMorph();
        return;
      }
      ctrl.forward();
    });
    return true;
  }

  /// Fills [_morphNaturalWidths] for entering cells from the t=0 frame.
  bool _measureEnteringNaturals() {
    final naturals = _morphNaturalWidths;
    if (naturals == null) return false;
    for (final i in _morphEntering!) {
      if (i >= _tabKeys.length) return false;
      var box = _tabKeys[i].currentContext?.findRenderObject();
      // Descend to the Align's child — the naturally-sized inner cell.
      RenderBox? inner;
      void visit(RenderObject o) {
        if (o is RenderPositionedBox) {
          final c = o.child;
          if (c is RenderBox && c.hasSize) inner = c;
          return;
        }
        o.visitChildren(visit);
      }

      if (box is RenderBox) visit(box);
      if (inner == null) return false;
      naturals[i] = inner!.size.width;
    }
    return true;
  }

  /// Per-tick, BEFORE this frame builds: seat the scroll ANALYTICALLY so
  /// the selected cell's left edge sits exactly on the anchor at this
  /// frame's t. Computed from the known natural widths — never from boxes,
  /// which describe last frame's t and lag catastrophically when a slow
  /// build paints only a handful of morph frames.
  void _onMorphTick() {
    if (!mounted || !_morphing) return;
    final naturals = _morphNaturalWidths;
    final ctl = widget.scrollController;
    if (naturals == null || !ctl.hasClients) return;
    final t = _morphAnim!.value;
    final dividerW = widget.dividerSettings?.thickness ?? 0.0;
    double x = 0;
    for (var i = 0; i < _morphSelectedIndex; i++) {
      final w = naturals[i];
      x += _morphEntering!.contains(i)
          ? w * t
          : _morphExiting!.contains(i)
              ? w * (1 - t)
              : w;
      if (dividerW > 0) x += dividerW;
    }
    ctl.jumpTo((x - _morphAnchorLocalX!)
        .clamp(ctl.position.minScrollExtent, ctl.position.maxScrollExtent));
  }

  /// Ends the morph: drops the exiting cells, remeasures the final list,
  /// epoch-snaps the pill onto it, and re-asserts the selection alignment.
  void _finishMorph({bool jumpToEnd = false}) {
    final ctrl = _morphCtrl;
    _morphCtrl = null;
    _morphAnim?.dispose();
    _morphAnim = null;
    ctrl?.dispose();
    if (!mounted) {
      _morphTabs = null;
      return;
    }
    setState(() {
      _morphTabs = null;
      _morphEntering = null;
      _morphExiting = null;
      _morphNaturalWidths = null;
      _morphSettling = true; // anchor holds until the final measure snaps
      _xAlign = _computeXAlignmentForTab(widget.selectedIndex);
      _tabWidths = [];
      _tabOffsets = [];
    });
    _initKeys(); // final list; _measureTabs epoch-snaps + aligns
  }

  double _computeXAlignmentForTab(int tabIndex) {
    return DraggableIndicatorPhysics.computeAlignment(
      tabIndex,
      widget.tabs.length,
    );
  }

  // ===========================================================================
  // GESTURE HANDLERS
  // ===========================================================================

  void _handleTapUp(TapUpDetails details) {
    if (_morphing) return; // sub-200ms; geometry is in flux
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final localX = details.localPosition.dx;

    int targetIndex = -1;
    if (widget.isScrollable) {
      final scrollOffset = widget.scrollController.hasClients
          ? widget.scrollController.offset
          : 0.0;
      final absoluteX = localX + scrollOffset;
      for (int i = 0; i < _tabOffsets.length; i++) {
        if (absoluteX >= _tabOffsets[i] &&
            absoluteX <= _tabOffsets[i] + _tabWidths[i]) {
          targetIndex = i;
          break;
        }
      }
    } else {
      targetIndex = (localX / box.size.width * widget.tabs.length).floor();
    }

    if (targetIndex != -1 && targetIndex < widget.tabs.length) {
      _onTabTap(targetIndex);
    }
  }

  void _handleDragDown(DragDownDetails details) {
    if (_morphing) return;
    if (!widget.isScrollable) {
      setState(() => _isDown = true);
      return;
    }
    // Picker strips: a drag NAVIGATES — never claim it for the indicator,
    // so it falls through to the scroll view like any off-pill drag.
    if (widget.dragBehavior == SegmentDragBehavior.scroll) return;

    final scrollOffset = widget.scrollController.hasClients
        ? widget.scrollController.offset
        : 0.0;
    final absoluteX = details.localPosition.dx + scrollOffset;

    final selIdx = widget.selectedIndex;
    if (selIdx < _tabOffsets.length) {
      final left = _tabOffsets[selIdx];
      final right = left + _tabWidths[selIdx];

      // If the press is within the active indicator's bounds, start indicator drag.
      if (absoluteX >= left && absoluteX <= right) {
        setState(() {
          _isDraggingIndicator = true;
          _isDown = true;
        });
      }
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || box.size.width <= 0) return;
    const double rubberBandFactor = 0.5;
    const double overstepRatio = 0.085;
    const double fixedModeOverstep = 0.17;

    // --- FIXED MODE ---
    if (!widget.isScrollable) {
      setState(() {
        _isDragging = true;

        // Use absolute pointer position to prevent drift
        double raw = DraggableIndicatorPhysics.getAlignmentFromGlobalPosition(
          details.globalPosition,
          context,
          widget.tabs.length,
        );
        if (raw < -1.0) {
          raw = -1.0 + (raw + 1.0) * rubberBandFactor;
        } else if (raw > 1.0) {
          raw = 1.0 + (raw - 1.0) * rubberBandFactor;
        }
        _xAlign = raw.clamp(-1.0 - fixedModeOverstep, 1.0 + fixedModeOverstep);
      });
      return;
    }

    // --- SCROLLABLE MODE ---
    if (!_isDraggingIndicator || _tabOffsets.isEmpty) return;
    setState(() {
      _isDragging = true;
      final double screenWidth = box.size.width;
      final double viewMin = widget.scrollController.offset;
      final double viewMax = viewMin + screenWidth;
      double delta = details.delta.dx;
      final double curOffset = _indOffsetSpring.value;

      // Calculate dynamic width based on current position to avoid jumps
      double targetWidth = _tabWidths[0];
      if (_tabWidths.length == widget.tabs.length) {
        int index = 0;
        for (int i = 0; i < _tabOffsets.length - 1; i++) {
          if (curOffset >= _tabOffsets[i]) index = i;
        }
        final int nextIndex = (index + 1).clamp(0, widget.tabs.length - 1);
        final double diff = _tabOffsets[nextIndex] - _tabOffsets[index];
        final double t =
            (diff != 0 ? (curOffset - _tabOffsets[index]) / diff : 0.0)
                .clamp(0.0, 1.0);
        targetWidth =
            _tabWidths[index] + (_tabWidths[nextIndex] - _tabWidths[index]) * t;
      }

      // Define physical boundaries
      final double leftWall = viewMin;
      final double rightWall = viewMax - targetWidth;

      // Apply rubber-band resistance when hitting boundaries
      if ((curOffset < leftWall && delta < 0) ||
          (curOffset > rightWall && delta > 0)) {
        delta *= rubberBandFactor;
      }

      // Clamp final position with allowed overstep
      final double maxOverstep = screenWidth * overstepRatio;
      final double finalOffset = (curOffset + delta).clamp(
        leftWall - maxOverstep,
        rightWall + maxOverstep,
      );

      // Update springs
      _indOffsetSpring.setValue(finalOffset);
      _indWidthSpring.setValue(targetWidth);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isDragging) {
      _handleDragCancel();
      return;
    }
    final box = context.findRenderObject() as RenderBox?;
    final double width = box?.size.width ?? 1.0;
    final double velocityX = details.velocity.pixelsPerSecond.dx;
    int targetTabIndex;

    if (widget.isScrollable) {
      // Scrollable mode: find closest tab by raw pixel offset, then
      // apply a velocity override if the user flicked hard enough.
      // (computeTargetIndex works in normalised 0–1 space; pixel-space
      // nearest-tab search is intentionally kept here.)
      targetTabIndex = widget.selectedIndex;
      double minDistance = double.infinity;
      for (int i = 0; i < _tabOffsets.length; i++) {
        final double dist = (_indOffsetSpring.value - _tabOffsets[i]).abs();
        if (dist < minDistance) {
          minDistance = dist;
          targetTabIndex = i;
        }
      }
      // Fling override: normalise velocity to 0–1 relative units and
      // delegate to the shared utility so both branches share the same
      // at-least-one-tab guarantee.
      final double relativeVelocity = width > 0 ? velocityX / width : 0.0;
      if (relativeVelocity.abs() > 0.5) {
        targetTabIndex =
            (relativeVelocity > 0 ? targetTabIndex + 1 : targetTabIndex - 1)
                .clamp(0, widget.tabs.length - 1);
      }
    } else {
      // Fixed mode: delegate entirely to DraggableIndicatorPhysics so this
      // widget no longer duplicates the snapping math used by the rest of
      // the package. Velocity is normalised from px/s → 0–1 relative units
      // to match computeTargetIndex's coordinate contract.
      final double currentRelativeX = (_xAlign + 1) / 2;
      final double relativeVelocity = width > 0 ? velocityX / width : 0.0;
      final double itemWidth = 1.0 / widget.tabs.length;
      targetTabIndex = DraggableIndicatorPhysics.computeTargetIndex(
        currentRelativeX: currentRelativeX,
        velocityX: relativeVelocity,
        itemWidth: itemWidth,
        itemCount: widget.tabs.length,
      );
    }

    setState(() {
      _isDragging = false;
      _isDraggingIndicator = false;
      _isDown = false;
      if (!widget.isScrollable) {
        _xAlign = _computeXAlignmentForTab(targetTabIndex);
      }
    });

    if (targetTabIndex != widget.selectedIndex) {
      widget.onTabSelected(targetTabIndex);
    } else if (widget.isScrollable) {
      // Snap scrollable indicator to the precise tab position.
      _indOffsetSpring.setValue(_tabOffsets[targetTabIndex]);
      _indWidthSpring.animateTo(_tabWidths[targetTabIndex]);
    }
  }

  void _handleDragCancel() {
    setState(() {
      _isDragging = false;
      _isDraggingIndicator = false;
      _isDown = false;
      if (!widget.isScrollable) {
        _xAlign = _computeXAlignmentForTab(widget.selectedIndex);
      }
    });
  }

  void _onTabTap(int index) {
    if (!widget.tabs[index].enabled) return;
    if (index != widget.selectedIndex) {
      widget.onTabSelected(index);
    }
    // Seat the tapped tab (immediately, or in the centering second beat).
    if (widget.isScrollable) {
      _seatSelection(index);
    }
  }

  /// Smoothly scrolls the [SingleChildScrollView] so that [tabIndex] is
  /// fully visible, with a small breathing-room edge padding.
  ///
  /// Called on tap and on programmatic selection changes. Only fires when
  /// measurements are ready and the controller has an attached position.
  void _scrollToEnsureVisible(int tabIndex, {bool animated = true}) {
    if (!widget.scrollController.hasClients) return;
    if (tabIndex >= _tabOffsets.length || tabIndex >= _tabWidths.length) return;

    final position = widget.scrollController.position;
    final viewportWidth = position.viewportDimension;
    final currentOffset = position.pixels;
    const edgePadding = 12.0; // breathing room from the left/right edge

    final tabLeft = _tabOffsets[tabIndex];
    final tabRight = tabLeft + _tabWidths[tabIndex];

    double targetOffset = currentOffset;

    if (widget.selectionAlignment == SegmentSelectionAlignment.center) {
      // Picker behavior: the selection lives at the center, clamped at the
      // ends of the list.
      targetOffset = tabLeft - (viewportWidth - _tabWidths[tabIndex]) / 2;
    } else if (tabLeft - currentOffset < edgePadding) {
      // Tab is partially or fully off-screen to the left.
      targetOffset = tabLeft - edgePadding;
    } else if (tabRight - currentOffset > viewportWidth - edgePadding) {
      // Tab is partially or fully off-screen to the right.
      targetOffset = tabRight - viewportWidth + edgePadding;
    }

    targetOffset = targetOffset.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    if ((targetOffset - currentOffset).abs() > 0.5) {
      if (animated) {
        widget.scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      } else {
        widget.scrollController.jumpTo(targetOffset);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final indicatorColor = widget.indicatorColor ?? _defaultIndicatorColor;

    // Resolve label and icon colors from CupertinoTheme — brightness-aware.
    // Matches the pattern used by GlassTabBar.bottom (tab_bar_bottom_layout.dart).
    final dynamicLabelColor =
        CupertinoTheme.of(context).textTheme.textStyle.color ??
            CupertinoColors.label.resolveFrom(context);
    final dynamicSecondaryColor =
        CupertinoColors.secondaryLabel.resolveFrom(context);

    final selectedLabelStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: dynamicLabelColor,
    ).merge(widget.selectedLabelStyle);

    final unselectedLabelStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: dynamicSecondaryColor,
    ).merge(widget.unselectedLabelStyle);

    final selectedIconColor = widget.selectedIconColor ?? dynamicLabelColor;
    final unselectedIconColor =
        widget.unselectedIconColor ?? dynamicSecondaryColor;

    final Widget tabLabels = _buildTabLabels(
      selectedLabelStyle,
      unselectedLabelStyle,
      selectedIconColor,
      unselectedIconColor,
    );

    return RawGestureDetector(
      gestures: {
        HorizontalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<
            HorizontalDragGestureRecognizer>(
          () => _drag,
          (instance) {},
        ),
        TapGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
          () => _tap,
          (instance) {},
        ),
      },
      // D1: ListenableBuilder scoped to the indicator subtree.
      // Spring ticks rebuild only VelocitySpringBuilder and its children;
      // theme resolution and tabLabels construction happen once per full
      // setState (discrete: tab change, drag end, isDown toggle).
      // tabLabels is passed as child so it is built once and reused as a
      // stable widget reference across all spring ticks.
      child: ListenableBuilder(
        listenable: _springListenable,
        child: tabLabels,
        builder: (context, stableTabLabels) {
          // stableTabLabels is always non-null — we always pass tabLabels as child.
          final safeTabLabels = stableTabLabels!;
          return VelocitySpringBuilder(
            value: widget.isScrollable ? _indOffsetSpring.value : _xAlign,
            teleportEpoch: _indicatorEpoch,
            springWhenActive: GlassSpring.interactive(),
            springWhenReleased: GlassSpring.snappy(
              duration: const Duration(milliseconds: 350),
            ),
            active: widget.isScrollable ? _isDraggingIndicator : _isDragging,
            builder: (context, currentValue, velocity, _) {
              // Normalizing velocity: pixels-per-frame to a manageable 0.0-2.0 scale for the shader
              // in scrollable mode. Prevents over-stretching into a vertical line during drag.
              final double normalizedVelocity =
                  widget.isScrollable ? velocity / 150.0 : velocity;

              final Alignment alignment = widget.isScrollable
                  ? Alignment.center
                  : Alignment(currentValue, 0);
              final double screenLeft = (_morphing || _morphSettling) &&
                      _morphAnchorLocalX != null
                  ? _morphAnchorLocalX!
                  : widget.isScrollable && widget.scrollController.hasClients
                      ? currentValue - widget.scrollController.offset
                      : 0.0;

              // Bloom while the position spring is still in transit — deactivates
              // naturally as the spring settles (mirrors GlassSegmentedControl).
              final bool isMoving;
              final bool canShowIndicator;

              if (widget.isScrollable) {
                final bool measuredReady =
                    _tabWidths.length == widget.tabs.length;
                final double targetOffset =
                    measuredReady && widget.selectedIndex < _tabOffsets.length
                        ? _tabOffsets[widget.selectedIndex]
                        : 0.0;
                // Only a measured target can say the pill is moving: during
                // a remeasure gap the stale comparison read as motion and
                // fired the bloom pulse on every list change.
                isMoving = !_morphing &&
                    !_morphSettling &&
                    measuredReady &&
                    (currentValue - targetOffset).abs() > 2.0;
                // Width alone: zero only before the very first measure. A
                // list-length remeasure keeps the previous geometry live,
                // so the pill stays visible through it instead of blinking.
                canShowIndicator = _indWidthSpring.value > 0;
              } else {
                final double targetAlignment =
                    _computeXAlignmentForTab(widget.selectedIndex);
                isMoving = (alignment.x - targetAlignment).abs() > 0.05;
                canShowIndicator = true;
              }

              return SpringBuilder(
                spring: GlassSpring.snappy(
                  duration: const Duration(milliseconds: 300),
                ),
                value: _isDown || isMoving ? 1.0 : 0.0,
                builder: (context, thickness, _) {
                  // Helper to prevent indicator parameter duplication
                  Widget buildIndicator(
                      {required bool paintBackground,
                      required bool paintGlass}) {
                    return AnimatedGlassIndicator(
                      velocity: normalizedVelocity,
                      itemCount: widget.tabs.length,
                      alignment: alignment,
                      thickness: thickness,
                      quality: widget.quality,
                      indicatorColor: indicatorColor,
                      isBackgroundIndicator: false,
                      settings: widget.indicatorSettings,
                      pinchStrength: widget.indicatorPinchStrength,
                      backgroundKey: widget.backgroundKey,
                      expansion: widget.maskingQuality == MaskingQuality.off
                          ? EdgeInsets.zero
                          : widget.indicatorExpansion,
                      paintBackground: paintBackground,
                      paintGlass: paintGlass,
                      shadows: paintBackground ? _effectiveShadow : null,
                      exactWidth:
                          widget.isScrollable ? _indWidthSpring.value : null,
                      exactOffset: widget.isScrollable ? screenLeft : null,
                      // Nested-arc default: if the outer bar is a capsule sentinel
                      // (>= GlassDefaults.capsuleRadius), pass capsuleRadius directly so
                      // the glass shader clamps to a true capsule even during
                      // jelly-bloom expansion.
                      // For custom radii, subtract the indicator inset (2 px) to
                      // produce concentric nested arcs.
                      // An explicit indicatorBorderRadius always takes priority.
                      borderRadius: widget.indicatorBorderRadius ??
                          ((widget.tabBarBorderRadius?.topLeft.x ??
                                      GlassDefaults.capsuleRadius) >=
                                  GlassDefaults.capsuleRadius
                              ? GlassDefaults.capsuleRadius
                              : ((widget.tabBarBorderRadius!.topLeft.x) - 2.0)
                                  .clamp(0.0, GlassDefaults.capsuleRadius)),
                    );
                  }

                  if (widget.isScrollable) {
                    // Three-layer architecture:
                    //  1. ClipRect layer: tab labels + solid background pill — both clip
                    //     cleanly at the viewport boundary as the user scrolls.
                    //  2. Glass bloom layer (above ClipRect): only the glass effect renders
                    //     here, so the jelly bloom can expand freely past the bar edges.
                    final physics = _isDraggingIndicator
                        ? const NeverScrollableScrollPhysics()
                        : const ClampingScrollPhysics();

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // ── Layer 1: clipped content ────────────────────────────────────
                        // ClipRRect clips to the tab bar's rounded corners so the solid
                        // background pill and tab labels don't overflow the corner radius.
                        ClipRRect(
                          borderRadius:
                              widget.tabBarBorderRadius ?? BorderRadius.zero,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Background solid pill — clips with the bar (rendered before
                              // labels so labels paint above the pill — correct z-order).
                              if (canShowIndicator)
                                buildIndicator(
                                    paintBackground: true, paintGlass: false),

                              // Tab labels (scrollable) — stableTabLabels is the ListenableBuilder
                              // child: built once per full setState, reused across spring ticks.
                              NotificationListener<ScrollStartNotification>(
                                onNotification: (_) {
                                  if (_isDown) setState(() => _isDown = false);
                                  return false;
                                },
                                child: SingleChildScrollView(
                                  controller: widget.scrollController,
                                  scrollDirection: Axis.horizontal,
                                  physics: physics,
                                  child: safeTabLabels,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── Layer 2: glass bloom (above all clips) ──────────────────────
                        if (canShowIndicator)
                          buildIndicator(
                              paintBackground: false, paintGlass: true),
                      ],
                    );
                  } else {
                    // Non-scrollable mode: stacking background, labels, glass without clipping.
                    //
                    // Premium: glass renders ABOVE labels — Impeller's physical refraction
                    // wraps the icon correctly (it refracts around it, not covers it).
                    //
                    // Standard/Minimal: glass renders BELOW labels — the 2D shader is an
                    // opaque paint pass that would obscure the icon if placed on top.
                    final bool isPremiumQuality =
                        widget.quality == GlassQuality.premium;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        if (canShowIndicator)
                          buildIndicator(
                              paintBackground: true,
                              paintGlass: !isPremiumQuality),
                        safeTabLabels,
                        if (canShowIndicator && isPremiumQuality)
                          buildIndicator(
                              paintBackground: false, paintGlass: true),
                      ],
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTabLabels(
    TextStyle selectedStyle,
    TextStyle unselectedStyle,
    Color selectedIconColor,
    Color unselectedIconColor,
  ) {
    final tabs = _renderTabs;
    final selectedRenderIndex =
        _morphing ? _morphSelectedIndex : widget.selectedIndex;
    final List<Widget> tabWidgets = List.generate(
      tabs.length,
      (index) {
        final tab = tabs[index];
        final isSelected = index == selectedRenderIndex;
        Widget cell = RepaintBoundary(
          child: TabBarItem(
            tab: tab,
            isSelected: isSelected,
            onTap: () => _onTabTap(index),
            onTapDown: () {},
            labelStyle: isSelected ? selectedStyle : unselectedStyle,
            iconColor: isSelected ? selectedIconColor : unselectedIconColor,
            iconSize: widget.iconSize,
            padding: widget.labelPadding,
          ),
        );
        if (_morphing &&
            (_morphEntering!.contains(index) ||
                _morphExiting!.contains(index))) {
          final entering = _morphEntering!.contains(index);
          cell = AnimatedBuilder(
            animation: _morphAnim!,
            child: cell,
            builder: (context, child) {
              final t = entering ? _morphAnim!.value : 1.0 - _morphAnim!.value;
              // Width 0→natural glides the survivors apart as the Row
              // re-flows; the scale and fade ride the same curve.
              return ClipRect(
                child: Align(
                  widthFactor: t,
                  child: Transform.scale(
                    scale: 0.8 + 0.2 * t,
                    child: Opacity(opacity: t, child: child),
                  ),
                ),
              );
            },
          );
        }
        return KeyedSubtree(key: _tabKeys[index], child: cell);
      },
    );

    if (widget.dividerSettings != null) {
      final d = widget.dividerSettings!;
      for (int i = tabs.length - 1; i > 0; i--) {
        final isVisible = !d.isHideAutomatically ||
            (i - 1 != widget.selectedIndex && i != widget.selectedIndex);

        tabWidgets.insert(
          i,
          AnimatedOpacity(
            opacity: isVisible ? 1.0 : 0.0,
            duration: d.duration ?? const Duration(milliseconds: 200),
            curve: d.curve ?? Curves.easeInOut,
            child: Container(
              width: d.thickness,
              margin: EdgeInsets.only(top: d.indent, bottom: d.endIndent),
              decoration: d.decoration ??
                  BoxDecoration(
                    color: CupertinoColors.separator.resolveFrom(context),
                  ),
            ),
          ),
        );
      }
    }

    if (widget.isScrollable) {
      return Row(children: tabWidgets);
    }

    return Row(
      children: tabWidgets
          .map((tab) => tab is KeyedSubtree ? Expanded(child: tab) : tab)
          .toList(),
    );
  }
}

// =============================================================================
// TabBarItem — single tab label/icon widget
// =============================================================================

/// Renders a single tab label and/or icon for [GlassTabBar].
///
/// Handles tap gestures, semantics, and animated text style transitions.
class TabBarItem extends StatelessWidget {
  const TabBarItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
    required this.onTapDown,
    required this.labelStyle,
    required this.iconColor,
    required this.iconSize,
    required this.padding,
    super.key,
  });

  final GlassSegment tab;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onTapDown;
  final TextStyle labelStyle;
  final Color iconColor;
  final double iconSize;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    Widget? iconWidget;
    if (tab.icon != null) {
      iconWidget = IconTheme(
        data: IconThemeData(color: iconColor, size: iconSize),
        child: tab.icon!,
      );
    }

    Widget? labelWidget;
    if (tab.label != null) {
      labelWidget = Text(
        tab.label!,
        style: labelStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    Widget content;
    if (iconWidget != null && labelWidget != null) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(height: 4),
          labelWidget,
        ],
      );
    } else if (iconWidget != null) {
      content = iconWidget;
    } else if (labelWidget != null) {
      content = labelWidget;
    } else {
      content = const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      onTapDown: (_) => onTapDown(),
      behavior: HitTestBehavior.opaque,
      child: Semantics(
        button: true,
        selected: isSelected,
        label: tab.semanticLabel ?? tab.label,
        child: Container(
          padding: padding,
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: labelStyle,
            child: content,
          ),
        ),
      ),
    );
  }
}
