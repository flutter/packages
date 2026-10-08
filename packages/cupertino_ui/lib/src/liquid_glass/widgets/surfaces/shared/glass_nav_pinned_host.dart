import 'dart:math' as math;
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/cupertino.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';

import '../../../src/renderer/liquid_glass_renderer.dart';
import '../../../src/widgets/surfaces/vertical_bar_title_row.dart';
import '../../../theme/glass_theme_helpers.dart';
import '../../../types/glass_quality.dart';
import '../../../utils/glass_spring.dart';
import '../../effects/glass_materialize.dart';
import '../../effects/shared/glass_materialize_effect.dart';
import '../../interactive/glass_button.dart';
import '../../overlays/glass_menu.dart';
import '../../overlays/glass_menu_item.dart';
import '../../overlays/glass_modal_sheet.dart';
import '../../shared/adaptive_liquid_glass_layer.dart';
import '../../shared/glass_accessibility_scope.dart';
import '../../shared/glass_isolation_scope.dart';
import '../glass_app_bar.dart';
import '../glass_bar_item.dart';
import '../glass_navigation_shell.dart';
import '../glass_vertical_bar.dart';

/// Geometry and timing constants for the pinned chrome.
///
/// Grouped here so the choreography can be tuned in one place.
///
/// The geometry members are exported so a bar that is not a [GlassAppBar] can
/// draw its in-route chrome to the same numbers; without that, the chrome
/// resizes at the moment the shell takes it over. The timing members
/// ([crossFadeStart], [crossFadeEnd], [swapAt], [capsuleStretch]) and the
/// helpers that read them describe the shell's own choreography and may be
/// retuned — align to the geometry, not to these.
abstract final class GlassNavPinnedMetrics {
  /// Width and height of one icon slot inside the actions capsule.
  ///
  /// Matches `GlassButtonGroup.icons`: 22pt icon + `EdgeInsets.all(12)`.
  static const double slot = 46.0;

  /// Corner radius of the actions capsule, matching `GlassButtonGroup.icons`.
  static const double capsuleRadius = 22.0;

  /// Diameter of the circular back button.
  static const double backDiameter = 44.0;

  /// Icon size inside both clusters.
  static const double iconSize = 22.0;

  /// Height of the toolbar row, matching [GlassAppBar.toolbarHeight].
  static const double toolbarHeight = 44.0;

  /// Horizontal inset, matching [GlassAppBar.padding].
  static const double horizontalPadding = 8.0;

  /// Stretch factor of the capsule shell, matching `GlassButtonGroup.icons`.
  static const double capsuleStretch = 0.15;

  /// Stretch factor of a shell that shares with nothing, matching the
  /// [GlassButton] default a lone circular button has always used.
  static const double buttonStretch = 0.5;

  /// Gap between two shells within one cluster.
  ///
  /// Matches the gap the bar itself leaves between its leading and actions
  /// slots, so a split cluster reads the same in-route and pinned.
  static const double groupGap = 8.0;

  /// Start of the cluster morph, as a fraction of the route transition.
  ///
  /// The cluster rides the whole transition: natively its spring settles in
  /// the same breath the page lands, which is what keeps the bounce in sync
  /// with the slide — the bar and the page are on the same clock. The tiny
  /// lead-in keeps the first moving frame from reading as a jump.
  static const double morphStart = 0.03;

  /// End of the cluster morph, as a fraction of the route transition.
  static const double morphEnd = 1.0;

  /// Progress through the [morphStart]..[morphEnd] window at route [progress].
  static double morphProgressAt(double progress) =>
      ((progress - morphStart) / (morphEnd - morphStart)).clamp(0.0, 1.0);

  /// Window during which a matched item's icon cross-fades, as a fraction of
  /// the [morphStart]..[morphEnd] morph window.
  static const double crossFadeStart = 0.25;

  /// End of the icon cross-fade window.
  static const double crossFadeEnd = 0.6;

  /// Peak of the gel swell, as a fraction of the shell's size.
  ///
  /// The swell is not a width effect: natively the entire capsule — height,
  /// radius, glyphs — puffs up together while the cluster is already
  /// travelling toward its new width, then relaxes. It scales the shell about
  /// its own centre, so both edges move outward.
  static const double swellAmount = 0.22;

  /// Portion of the morph over which the swell rises and falls.
  static const double swellWindow = 0.6;

  /// How much of the spring's overshoot squeezes the whole shell.
  ///
  /// The spring lands through its overshoot; coupling that excursion into
  /// the same uniform scale the swell uses is what makes the bounce read on
  /// the whole shell — height included — rather than in width alone.
  static const double squeezeScale = 0.35;

  /// The gel swell at [morphT] through the morph window.
  static double swellPulseAt(double morphT) {
    final x = (morphT / swellWindow).clamp(0.0, 1.0);
    return swellAmount * math.sin(math.pi * x);
  }

  /// Peak gaussian blur applied to a glyph on its way out.
  ///
  /// The native morph never shows a glyph plainly fading: an outgoing glyph
  /// smears away under heavy blur as the cluster reshapes under it, which
  /// reads as motion blur on the whole cluster.
  static const double morphBlurSigma = 6.0;

  /// Blur at which an incoming glyph arrives.
  ///
  /// Softer than the outgoing smear: natively the arriving glyph is soft but
  /// its silhouette stays readable the whole way in.
  static const double glyphArriveSigma = 3.5;

  /// Window over which an incoming glyph sharpens, as a fraction of the
  /// [morphStart]..[morphEnd] morph window like [crossFadeStart].
  ///
  /// Sharpening starts while the cluster is still bouncing and finishes just
  /// ahead of the landing — natively the blur is the last thing to clear.
  static const double glyphSharpenStart = 0.48;

  /// End of the incoming glyph's sharpening window.
  static const double glyphSharpenEnd = 0.9;

  /// Blur of an outgoing glyph at [morphT] through the morph window.
  ///
  /// Ramps to full strength ahead of the fade, so a glyph is already soft
  /// before its opacity starts moving — the native smear.
  static double outgoingSigmaAt(double morphT) =>
      morphBlurSigma * (morphT * 3.0).clamp(0.0, 1.0);

  /// Blur of an incoming glyph at [morphT] through the morph window.
  static double incomingSigmaAt(double morphT) =>
      glyphArriveSigma *
      (1.0 -
          ((morphT - glyphSharpenStart) / (glyphSharpenEnd - glyphSharpenStart))
              .clamp(0.0, 1.0));

  /// Point in the transition at which the chrome switches from showing the
  /// outgoing route's configuration to the incoming one.
  static const double swapAt = 0.5;

  /// Start of the window over which an appearing cluster materializes, in
  /// route progress. The window ends at 1.0.
  ///
  /// It straddles [swapAt] deliberately: the configuration must swap while
  /// the cluster is still partially dissolved, never while it is fully solid.
  static const double materializeStart = 0.45;

  /// Scale a cluster swells to while dematerialized, from the native
  /// capture. Gentler than the standalone default: the bar's clusters are
  /// anchored to an edge, where a deep scale reads as a slide.
  static const double materializeScaleFrom = 1.1;

  /// End of the window over which a disappearing cluster dematerializes, in
  /// route progress. The window starts at 0.0.
  static const double dematerializeEnd = 0.55;

  /// The materialize phase of a cluster at transition [progress]:
  /// 0.0 = fully dematerialized (not built), 1.0 = settled glass.
  ///
  /// A cluster only the incoming route has materializes over the tail of the
  /// transition; one only the outgoing route has dematerializes over the
  /// head. Both are pure functions of [progress], so a pop — which runs the
  /// same value backwards — plays each window in reverse and the exit still
  /// leads the entrance in both directions, with no direction to get wrong.
  ///
  /// [progress] is not raw route progress during an interactive back-swipe:
  /// the shell holds it still until the gesture commits and then re-times it
  /// over the remaining travel, so the chrome never dissolves under a finger
  /// that may yet be lifted. See `GlassNavigationShellState._holdForGesture`.
  ///
  /// The windows are symmetric on purpose. The native asymmetry — an exit
  /// that lingers past its entrance — lives in the effect's own sub-curves,
  /// where it survives a reversed transition; encoding it here as
  /// direction-aware windows would snap when a swipe reverses mid-flight,
  /// for the same reason the capsule's geometry curve is symmetric.
  static double clusterPhaseAt({
    required bool inFrom,
    required bool inTo,
    required double progress,
  }) {
    if (inFrom && inTo) return 1.0;
    if (!inFrom && !inTo) return 0.0;
    if (inTo) {
      return ((progress - materializeStart) / (1.0 - materializeStart))
          .clamp(0.0, 1.0);
    }
    return 1.0 - (progress / dematerializeEnd).clamp(0.0, 1.0);
  }

  /// Which side's configuration is showing at transition [progress].
  static bool showsIncomingAt(double progress) => progress >= swapAt;
}

/// The motion of a morphing cluster: the package's bouncy spring as a curve.
///
/// The cluster's width and item positions travel on this from the first
/// frame of the transition to the last, overshooting the target and settling
/// back exactly as the page lands — cluster and page share one clock. It
/// samples [GlassSpring.bouncy] — the same profile the liquid morphs
/// elsewhere in the package ride — as a curve rather than as a live
/// simulation, because the pinned chrome is a pure interpolation of the
/// route clock: a time-driven spring would detach the morph from back-swipe
/// scrubbing.
///
/// Public for testing; held back from the barrel's `show` clause.
@visibleForTesting
class GlassNavMorphCurve extends Curve {
  const GlassNavMorphCurve._();

  /// The shared instance; the underlying simulation is stateless.
  static const GlassNavMorphCurve instance = GlassNavMorphCurve._();

  /// The perceptual settle duration [GlassSpring.bouncy] is specified with.
  static const double _settleSeconds = 0.5;

  static final SpringSimulation _simulation =
      SpringSimulation(GlassSpring.bouncy(extraBounce: 0.1), 0.0, 1.0, 0.0);

  /// The residual at the end of the sample window, divided out so the curve
  /// honours the Curve contract of ending exactly at 1.
  static final double _terminal = _simulation.x(_settleSeconds);

  @override
  double transformInternal(double t) =>
      _simulation.x(t * _settleSeconds) / _terminal;
}

/// The chrome to render for the current frame.
///
/// [progress] is the top route's own entrance animation: 1 at rest, running
/// 0 to 1 on a push and scrubbing 1 to 0 during a pop or back-swipe. The host
/// renders a straight interpolation from [from] to [to] over it, which makes
/// every case — push, pop, cancelled swipe, interrupted transition — fall out
/// of one formula.
@immutable
class GlassNavPinnedState {
  /// Creates a description of the chrome for one frame.
  const GlassNavPinnedState({
    required this.from,
    required this.to,
    required this.progress,
    required this.coverage,
    required this.settled,
    this.popping = false,
    required this.topRoute,
    this.transition = GlassEffectTransition.materialize,
    this.crossFade = false,
    this.presenting,
    this.holdForSheet,
  });

  /// Chrome of the route beneath the top one.
  final GlassNavBarRegistration from;

  /// Chrome of the topmost registered route.
  final GlassNavBarRegistration to;

  /// The top route's entrance progress, 0 to 1.
  final double progress;

  /// How much the top route is covered by an unregistered route, 0 to 1.
  ///
  /// Drives the chrome out of the way when a plain route or a modal sheet is
  /// presented above the pinned bar.
  final double coverage;

  /// Whether the chrome is at rest and may be tapped.
  ///
  /// False for the whole of a push, pop or back-swipe. Taps are swallowed
  /// while a transition runs because the chrome is showing a blend of two
  /// routes' items, so acting on one of them would fire an action the user
  /// can no longer see. [progress] cannot answer this on its own — a pop
  /// begins at 1.0 — so the shell derives it from the route instead.
  final bool settled;

  /// Whether the transition is a pop — an animated pop, a back-swipe, or the
  /// exit a committed swipe plays out.
  ///
  /// A pop plays the same forward choreography as a push, toward the other
  /// target: [flowProgress] mirrors the clock and [flowFrom]/[flowTo] swap
  /// the roles, so the swell leads and the bounce lands with the page in
  /// both directions. Rendering the push in reverse instead put all the
  /// motion at the wrong end of a pop.
  final bool popping;

  /// [progress] along the forward choreography — mirrored on a pop.
  double get flowProgress => popping ? 1.0 - progress : progress;

  /// The chrome the forward choreography leaves, honouring [popping].
  GlassNavBarRegistration get flowFrom => popping ? to : from;

  /// The chrome the forward choreography arrives at, honouring [popping].
  GlassNavBarRegistration get flowTo => popping ? from : to;

  /// The topmost registered route, used for the default back action.
  final ModalRoute<dynamic> topRoute;

  /// How clusters that appear or disappear outright transition.
  ///
  /// Set from [GlassNavigationShell.effectTransition]; the host downgrades
  /// it to [GlassEffectTransition.identity] under reduce motion.
  final GlassEffectTransition transition;

  /// Whether this frame belongs to [GlassSwipeCommitTransition.crossFade].
  final bool crossFade;

  /// The [GlassBarItem.sheet] whose sheet is up out of the hoisted chrome, or
  /// null.
  ///
  /// Set while a presentation has handed the rest of the chrome back to the
  /// route: only the group holding this item is drawn, and the morph has
  /// emptied its capsule. See [GlassNavigationShellState.holdForSheet].
  final GlassBarSheetItem? presenting;

  /// Keeps a tapped sheet item's capsule hoisted through its presentation.
  ///
  /// Called with the item and its group's anchor before the item presents.
  /// Null leaves the tap to present without the hold, which hands the capsule
  /// back with the rest of the chrome.
  final void Function(GlassBarSheetItem item, GlassMorphAnchor anchor)?
      holdForSheet;
}

/// Renders the pinned leading and trailing clusters above the [Navigator].
///
/// A surviving cluster keeps one persistent glass shell whose geometry
/// animates; its element is never remounted mid-morph, because a glass
/// surface's backdrop pass renders fully or not at all and a shell that
/// remounts pops. Clusters that appear or disappear outright materialize
/// instead, over the windows in [GlassNavPinnedMetrics.clusterPhaseAt] — the
/// effect dissolves the cluster's *composited own layer* through the shader's
/// own visibility uniform, which is a fade the backdrop pass does honour.
class GlassNavPinnedHost extends StatelessWidget {
  /// Creates the pinned host for the given frame [state].
  const GlassNavPinnedHost({super.key, required this.state});

  /// The chrome to render.
  final GlassNavPinnedState state;

  /// The phase an appearing or disappearing cluster is at, honouring the
  /// shell's [GlassEffectTransition] and the user's reduce-motion setting.
  ///
  /// [GlassEffectTransition.identity] collapses the window back to the single
  /// switch at [GlassNavPinnedMetrics.swapAt] this chrome used before the
  /// effect existed, which is also what reduce motion selects — the effect's
  /// own reduce-motion path drops the scale and blur but still cross-fades,
  /// and a bar that dissolves on every push is the motion being asked about.
  static double phaseFor(
    BuildContext context,
    GlassNavPinnedState state, {
    required bool inFrom,
    required bool inTo,
  }) {
    final identity = state.transition == GlassEffectTransition.identity ||
        GlassAccessibilityData.of(context).reduceMotion;
    if (identity) {
      if (inFrom && inTo) return 1.0;
      if (!inFrom && !inTo) return 0.0;
      final showsIncoming =
          GlassNavPinnedMetrics.showsIncomingAt(state.flowProgress);
      return (inTo ? showsIncoming : !showsIncoming) ? 1.0 : 0.0;
    }
    return GlassNavPinnedMetrics.clusterPhaseAt(
      inFrom: inFrom,
      inTo: inTo,
      progress: state.flowProgress,
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    final settings =
        state.flowTo.buttonSettings ?? state.flowFrom.buttonSettings;
    final textDirection = Directionality.of(context);

    // Everything retreats together when an unregistered route covers the bar.
    // Each cluster scales about its own anchored edge: scaling the full-width
    // Stack instead would drag both clusters toward the centre.
    final coverageScale = 1.0 - Curves.easeIn.transform(state.coverage);
    if (coverageScale <= 0.01) return const SizedBox.shrink();

    final verticalBar = GlassVerticalBar.maybeOf(context);
    if (verticalBar != null) {
      return _buildVertical(context, verticalBar, coverageScale, settings);
    }

    Widget chrome = Stack(
      clipBehavior: Clip.none,
      children: [
        for (final side in _BarSide.values)
          Positioned.directional(
            textDirection: textDirection,
            start: side == _BarSide.leading ? 0 : null,
            end: side == _BarSide.trailing ? 0 : null,
            top: 0,
            child: _PinnedSide(
              state: state,
              groupsFor: (context, registration) => groupGlassNavBarItems(
                _itemsFor(context, state, registration, side),
              ),
              anchoredAtStart: (side == _BarSide.leading) ==
                  (textDirection == TextDirection.ltr),
              scaleAlignment: side == _BarSide.leading
                  ? AlignmentDirectional.centerStart
                  : AlignmentDirectional.centerEnd,
              coverageScale: coverageScale,
            ),
          ),
      ],
    );

    if (settings != null) {
      chrome = DefaultButtonSettings(settings: settings, child: chrome);
    }

    // The incoming route's guide, as `buttonSettings` above resolves the
    // material: a transition between two bars that disagree lands on the one
    // being entered rather than sliding the chrome between them.
    final inset = state.flowTo.horizontalInset ??
        state.flowFrom.horizontalInset ??
        GlassNavPinnedMetrics.horizontalPadding;

    return Positioned(
      top: topPad,
      left: inset,
      right: inset,
      height: GlassNavPinnedMetrics.toolbarHeight,
      child: GlassIsolationScope(
        isolated: true,
        defaultQuality: GlassQuality.premium,
        child: chrome,
      ),
    );
  }

  /// The chrome laid out for iPhone Duo's vertical bar strip.
  ///
  /// Everything that goes vertical stacks down the strip from its first
  /// control: the back button, then the leading groups, then the trailing
  /// ones, each keeping its grouping — the order the native strip reads in.
  /// Whatever stays horizontal ([GlassBarActionItem.goesVertical]) gathers in
  /// one row at the top-trailing corner of the content, beside the title the
  /// route keeps drawing.
  Widget _buildVertical(
    BuildContext context,
    GlassVerticalBarData bar,
    double coverageScale,
    LiquidGlassSettings? settings,
  ) {
    final textDirection = Directionality.of(context);
    final trailingStrip = bar.edge == GlassVerticalBarEdge.trailing;

    // The strip runs from its first control down to whatever the bars at its
    // bottom have reserved, less the gap between the two.
    final reserved =
        GlassNavigationShell.maybeOf(context)?.verticalBarBottom ?? 0.0;
    final available = MediaQuery.sizeOf(context).height -
        bar.top -
        (reserved > 0
            ? reserved + GlassVerticalBarMetrics.spacing
            : bar.bottom);

    List<GlassNavBarGroup> stripGroups(
      BuildContext context,
      GlassNavBarRegistration registration,
    ) =>
        fitGlassNavStripGroups(
          [
            for (final side in _BarSide.values)
              ...groupGlassNavBarItems(
                _itemsFor(context, state, registration, side)
                    .where((item) => _goesInStrip(item, vertical: true))
                    .toList(),
                axis: Axis.vertical,
              ),
          ],
          available,
        );

    List<GlassNavBarGroup> rowGroups(
      BuildContext context,
      GlassNavBarRegistration registration,
    ) =>
        [
          for (final side in _BarSide.values)
            ...groupGlassNavBarItems(
              _itemsFor(context, state, registration, side)
                  .where((item) => _goesInStrip(item, vertical: false))
                  .toList(),
            ),
        ];

    // The strip's controls sit [GlassVerticalBarMetrics.inset] from its inner
    // edge. The column is centred in a box that inset wide on both sides of a
    // control, so a group swelling through a morph grows about its own centre
    // and never meets the clamp of a narrower box.
    const columnWidth = GlassVerticalBarMetrics.controlExtent +
        2 * GlassVerticalBarMetrics.inset;
    final columnOffset = bar.width - columnWidth;

    Widget chrome = Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.directional(
          textDirection: textDirection,
          top: bar.top,
          start: trailingStrip ? null : columnOffset,
          end: trailingStrip ? columnOffset : null,
          width: columnWidth,
          child: VerticalBarTitleRow(
            controller: state.to.largeTitleController,
            collapses: false,
            child: _PinnedSide(
              state: state,
              groupsFor: stripGroups,
              anchoredAtStart: true,
              axis: Axis.vertical,
              scaleAlignment: Alignment.topCenter,
              coverageScale: coverageScale,
            ),
          ),
        ),
        Positioned.directional(
          textDirection: textDirection,
          top: GlassVerticalBarMetrics.edgeMargin,
          height: GlassVerticalBarMetrics.rowHeight,
          // The row's end: against the strip where the strip is trailing, and
          // across the content from it where it is leading.
          end: trailingStrip
              ? bar.width + GlassVerticalBarMetrics.rowInset
              : GlassVerticalBarMetrics.titleInset,
          // The row the title shares, so a large title takes it along as it
          // scrolls away.
          child: VerticalBarTitleRow(
            controller: state.to.largeTitleController,
            child: Center(
              child: _PinnedSide(
                state: state,
                groupsFor: rowGroups,
                anchoredAtStart: textDirection == TextDirection.rtl,
                scaleAlignment: AlignmentDirectional.centerEnd,
                coverageScale: coverageScale,
              ),
            ),
          ),
        ),
      ],
    );

    if (settings != null) {
      chrome = DefaultButtonSettings(settings: settings, child: chrome);
    }

    return Positioned.fill(
      child: GlassIsolationScope(
        isolated: true,
        defaultQuality: GlassQuality.premium,
        child: chrome,
      ),
    );
  }
}

// =============================================================================
// Clusters
// =============================================================================

/// Which edge of the bar a cluster is anchored to.
///
/// Direction-relative, not absolute: the leading cluster sits on the left in
/// LTR and on the right in RTL, matching the bar's own leading slot.
enum _BarSide { leading, trailing }

/// One glass shell's worth of items within a cluster.
///
/// Mirrors the grouping iOS 26 derives from `UIBarButtonItem.sharesBackground`
/// and `hidesSharedBackground`: consecutive shared items form one capsule, and
/// anything else stands alone.
///
/// Shared with [GlassAppBar]'s in-route fallback so the two paths group and
/// size items identically; this library is not exported from the package
/// barrel.
@immutable
class GlassNavBarGroup {
  /// Creates a group of items sharing one background.
  const GlassNavBarGroup({
    required this.items,
    required this.background,
    this.axis = Axis.horizontal,
  });

  /// The items sharing this group's background, leading to trailing.
  final List<GlassBarActionItem> items;

  /// How this group's background is drawn, taken from its items.
  final GlassBarItemBackground background;

  /// The direction the group's items run in: along a horizontal bar, or down
  /// iPhone Duo's vertical strip.
  final Axis axis;

  /// Whether a glass shell is drawn behind [items].
  bool get glass =>
      background != GlassBarItemBackground.none &&
      background != GlassBarItemBackground.own;

  /// Thickness of the shell across the bar: its height in a horizontal bar,
  /// its width in the vertical strip.
  ///
  /// A group that shares with nothing is the 44pt circular button iOS 26 draws
  /// for a lone bar item — at that height the capsule's 22pt radius is clamped
  /// to exactly half the box, so the rounded rectangle *is* a circle. A shared
  /// capsule keeps the taller icon-slot height it has always had. In the strip
  /// every control is [GlassVerticalBarMetrics.controlExtent] wide.
  double get crossExtent {
    if (axis == Axis.vertical) return GlassVerticalBarMetrics.controlExtent;
    return background == GlassBarItemBackground.shared
        ? GlassNavPinnedMetrics.slot
        : GlassNavPinnedMetrics.backDiameter;
  }

  /// Length of an icon slot along the bar.
  ///
  /// Square with [crossExtent] in a horizontal bar. In the strip a lone item
  /// is a circle too, while a capsule of several gives each item
  /// [GlassVerticalBarMetrics.itemExtent].
  double get slotExtent => axis == Axis.vertical &&
          background == GlassBarItemBackground.shared &&
          items.length > 1
      ? GlassVerticalBarMetrics.itemExtent
      : crossExtent;

  /// Press-stretch factor for the shell.
  double get stretch => background == GlassBarItemBackground.shared
      ? GlassNavPinnedMetrics.capsuleStretch
      : GlassNavPinnedMetrics.buttonStretch;

  /// Whether [item] is one of [items] — by identity, or by `id` where it has
  /// one, as items are matched across routes.
  bool contains(GlassBarActionItem item) => items.any((candidate) =>
      identical(candidate, item) ||
      (item.id != null && candidate.id == item.id));
}

/// Splits a cluster's items into the shells that will actually be drawn.
///
/// Runs of [GlassBarItemBackground.shared] items collapse into one group;
/// every other item stands alone, so it can be given its own shell or none.
/// A [GlassBarItem.spacer] ends a run, so the items either side of it draw
/// separate shells.
///
/// Shared with [GlassAppBar]'s in-route fallback; this library is not exported
/// from the package barrel.
List<GlassNavBarGroup> groupGlassNavBarItems(
  List<GlassBarItem> items, {
  Axis axis = Axis.horizontal,
}) {
  final groups = <GlassNavBarGroup>[];
  var run = <GlassBarActionItem>[];

  void flushRun() {
    if (run.isEmpty) return;
    groups.add(GlassNavBarGroup(
      items: run,
      background: GlassBarItemBackground.shared,
      axis: axis,
    ));
    run = <GlassBarActionItem>[];
  }

  for (final item in items) {
    // A spacer: the only item that is not an action.
    if (item is! GlassBarActionItem) {
      flushRun();
      continue;
    }
    assert(
      item.tintColor == null ||
          item.background != GlassBarItemBackground.shared,
      'GlassBarItem.tintColor is only supported for '
      'GlassBarItemBackground.separate items. A shared capsule is a single '
      'glass mesh and cannot tint individual slots. Set background: '
      'GlassBarItemBackground.separate to use tintColor.',
    );
    if (item.background == GlassBarItemBackground.shared) {
      run.add(item);
      continue;
    }
    flushRun();
    groups.add(GlassNavBarGroup(
      items: [item],
      background: item.background,
      axis: axis,
    ));
  }
  flushRun();
  return groups;
}

/// The two sides a group interpolates between at [progress].
///
/// A glass shell and a bare item cannot morph into one another, because that
/// would mean fading glass in or out. Dropping the side that is not showing
/// turns the pair into an exit followed by an entrance, which the single
/// switch at [GlassNavPinnedMetrics.swapAt] already handles.
({GlassNavBarGroup? from, GlassNavBarGroup? to}) _resolveGroupSides(
  GlassNavBarGroup? from,
  GlassNavBarGroup? to,
  double progress,
) {
  if (from != null && to != null && from.glass != to.glass) {
    return GlassNavPinnedMetrics.showsIncomingAt(progress)
        ? (from: null, to: to)
        : (from: from, to: null);
  }
  return (from: from, to: to);
}

/// Identity carried by the ••• item a crowded strip overflows into, so it
/// holds its place across routes like any item with an `id`.
const Object _overflowItemId = #glassNavOverflowItem;

/// Fits a strip's groups into [available] points of height.
///
/// Natively, a strip that runs out of room keeps what fits from the top and
/// collapses the rest into a ••• menu at the end: whole groups while they fit,
/// then as many items of the next as still do — split off into a group of
/// their own, a lone one standing as a circle — and everything after that
/// becomes an entry in the menu. A [GlassBarItem.menu] among them contributes
/// its own entries.
///
/// Shared with [GlassPinnedBarChrome]'s in-route strip; this library is not
/// exported from the package barrel.
List<GlassNavBarGroup> fitGlassNavStripGroups(
  List<GlassNavBarGroup> groups,
  double available,
) {
  double extentOf(int count, GlassBarItemBackground background) =>
      count == 1 || background != GlassBarItemBackground.shared
          ? count * GlassVerticalBarMetrics.controlExtent
          : count * GlassVerticalBarMetrics.itemExtent;

  var total = 0.0;
  for (final group in groups) {
    if (total > 0) total += GlassVerticalBarMetrics.spacing;
    total += extentOf(group.items.length, group.background);
  }
  if (total <= available) return groups;

  // Room for everything that stays, with the ••• circle held back at the end.
  final budget = available -
      GlassVerticalBarMetrics.controlExtent -
      GlassVerticalBarMetrics.spacing;
  final kept = <GlassNavBarGroup>[];
  final overflow = <GlassBarActionItem>[];
  var used = 0.0;
  for (final group in groups) {
    if (overflow.isNotEmpty) {
      overflow.addAll(group.items);
      continue;
    }
    final gap = kept.isEmpty ? 0.0 : GlassVerticalBarMetrics.spacing;
    final extent = extentOf(group.items.length, group.background);
    if (used + gap + extent <= budget) {
      kept.add(group);
      used += gap + extent;
      continue;
    }
    var fits = 0;
    while (fits < group.items.length &&
        used + gap + extentOf(fits + 1, group.background) <= budget) {
      fits++;
    }
    if (fits > 0) {
      kept.add(GlassNavBarGroup(
        items: group.items.sublist(0, fits),
        background:
            fits == 1 ? GlassBarItemBackground.separate : group.background,
        axis: Axis.vertical,
      ));
      used += gap + extentOf(fits, group.background);
    }
    overflow.addAll(group.items.sublist(fits));
  }

  final entries = <Widget>[];
  for (final item in overflow) {
    if (item is GlassBarMenuItem) {
      if (entries.isNotEmpty) entries.add(const GlassMenuDivider());
      entries.addAll(item.menuItems);
      continue;
    }
    entries.add(GlassMenuItem(
      title: item.label ?? '',
      icon: switch (item) {
        GlassBarIconItem(:final icon) => icon,
        GlassBarSheetItem(:final icon) => icon,
        _ => null,
      },
      enabled: item.enabled,
      onTap:
          item is GlassBarSheetItem ? () => item.onPresent(null) : item.onTap,
    ));
  }
  return [
    ...kept,
    GlassNavBarGroup(
      items: [
        GlassBarMenuItem(
          icon: const Icon(CupertinoIcons.ellipsis),
          menuItems: entries,
          id: _overflowItemId,
          background: GlassBarItemBackground.separate,
        ),
      ],
      background: GlassBarItemBackground.separate,
      axis: Axis.vertical,
    ),
  ];
}

/// How much of a group is drawn at [state]'s progress: its materialize phase,
/// or 1.0 for a group both routes have.
///
/// The run asks before laying out, and a group at zero is not built at all.
/// Asked of the materialize phase rather than of a hard switch: a group
/// part-way through its window is still drawing, and dropping it there would
/// pop the very transition the window exists to play.
double _groupPhaseAt(
  BuildContext context,
  GlassNavPinnedState state,
  GlassNavBarGroup? from,
  GlassNavBarGroup? to,
) {
  final sides = _resolveGroupSides(from, to, state.flowProgress);
  if (sides.from == null && sides.to == null) return 0.0;
  return GlassNavPinnedHost.phaseFor(
    context,
    state,
    inFrom: sides.from != null,
    inTo: sides.to != null,
  );
}

/// Identity carried by the automatic back button.
///
/// Gives it the same standing as an item with an explicit `id`, so a back
/// button that survives a transition holds its place instead of being matched
/// positionally against whatever the destination happens to put first.
const Object _backItemId = #glassNavBackItem;

/// The automatic back button, as an ordinary item.
///
/// Built here rather than stored on the registration because its label is
/// localised, and that needs a context. It shares with nothing, which is what
/// makes a back-only cluster the circle it has always been.
GlassBarIconItem _backItem(
  BuildContext context,
  GlassNavPinnedState state,
  GlassNavBarRegistration registration,
) {
  return GlassBarIconItem(
    icon: const Icon(CupertinoIcons.back),
    id: _backItemId,
    label: Localizations.of<CupertinoLocalizations>(
          context,
          CupertinoLocalizations,
        )?.backButtonLabel ??
        // The same string DefaultCupertinoLocalizations returns, for apps
        // that ship no localizations delegates at all.
        'Back',
    background: GlassBarItemBackground.separate,
    onTap: () {
      final onBack = registration.onBack;
      if (onBack != null) {
        onBack();
      } else {
        state.topRoute.navigator?.maybePop();
      }
    },
  );
}

/// Everything one edge of the bar renders for [registration], back button
/// included, with its spacers still in place to split it into groups.
List<GlassBarItem> _itemsFor(
  BuildContext context,
  GlassNavPinnedState state,
  GlassNavBarRegistration registration,
  _BarSide side,
) {
  if (side == _BarSide.trailing) return registration.actions;
  final leading = registration.leading;
  if (!registration.showsBackButton) return leading;
  return [_backItem(context, state, registration), ...leading];
}

/// Whether [item] belongs in iPhone Duo's strip, or in the row beside the
/// title when [vertical] is false.
///
/// A spacer belongs in both, so it still splits whichever items it sits
/// between.
bool _goesInStrip(GlassBarItem item, {required bool vertical}) =>
    item is! GlassBarActionItem || item.goesVertical == vertical;

/// One run of pinned chrome: an edge of the bar, or iPhone Duo's strip.
///
/// Resolves each route's groups through [groupsFor] and renders one
/// [_PinnedGroup] per pair [matchGlassNavGroups] makes of them, so a shell
/// follows its items when a spacer changes how many groups a route has.
class _PinnedSide extends StatelessWidget {
  const _PinnedSide({
    required this.state,
    required this.groupsFor,
    required this.anchoredAtStart,
    required this.scaleAlignment,
    required this.coverageScale,
    this.axis = Axis.horizontal,
  });

  final GlassNavPinnedState state;

  /// The groups this run draws for one route, in reading order.
  final List<GlassNavBarGroup> Function(
    BuildContext context,
    GlassNavBarRegistration registration,
  ) groupsFor;

  /// Whether groups are matched and placed from the box's left edge — its top
  /// edge in the strip — so each cluster grows away from the edge it is
  /// pinned to.
  final bool anchoredAtStart;

  /// The point the run retreats towards when an unregistered route covers it.
  final AlignmentGeometry scaleAlignment;

  /// Retreat factor applied when an unregistered route covers the bar.
  final double coverageScale;

  /// The direction groups run in.
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    if (coverageScale <= 0.01) return const SizedBox.shrink();

    // Groups follow the forward choreography: on a pop the roles swap, so
    // the same forward morph plays toward the destination's clusters.
    final fromGroups = groupsFor(context, state.flowFrom);
    final toGroups = groupsFor(context, state.flowTo);
    if (fromGroups.isEmpty && toGroups.isEmpty) return const SizedBox.shrink();

    // The groups are laid out in reading order, so which end of the list sits
    // against the edge the run is pinned to depends on the text direction.
    final fromStart = axis == Axis.vertical ||
        anchoredAtStart == (Directionality.of(context) == TextDirection.ltr);

    // A group's place, counted from the pinned edge.
    int? placeIn(List<GlassNavBarGroup> list, GlassNavBarGroup? group) {
      if (group == null) return null;
      final index = list.indexOf(group);
      return fromStart ? index : list.length - 1 - index;
    }

    final shells = <_Shell>[
      for (final pair in matchGlassNavGroups(
        fromGroups,
        toGroups,
        anchoredAtStart: fromStart,
      ))
        (
          from: pair.from,
          to: pair.to,
          fromPlace: placeIn(fromGroups, pair.from),
          toPlace: placeIn(toGroups, pair.to),
        ),
    ];

    // Keyed by the place a shell holds on the route it leaves, which is where
    // it was drawn the frame before, at rest or mid-morph alike: a glass
    // surface that remounts pops its backdrop. A group only the incoming route
    // has takes its own place, which is where the next transition will find
    // it — unless a shell that followed its items still holds that place.
    final leaving = {
      for (final shell in shells)
        if (shell.fromPlace != null) shell.fromPlace,
    };
    Key keyOf(_Shell shell) {
      final place = shell.fromPlace ?? shell.toPlace!;
      if (shell.fromPlace != null || !leaving.contains(place)) {
        return ValueKey<int>(place);
      }
      return ValueKey<({int entering})>((entering: place));
    }

    // Under a presentation only the group the sheet came out of is still the
    // shell's; the route has the rest. See [GlassNavPinnedState.presenting].
    final presenting = state.presenting;

    bool holdsPresenting(GlassNavBarGroup? group) =>
        presenting == null || (group != null && group.contains(presenting));

    // Shells move between their places on the clock their contents morph on.
    final positionT = GlassNavMorphCurve.instance
        .transform(GlassNavPinnedMetrics.morphProgressAt(state.flowProgress))
        .clamp(0.0, 1.0);

    // A group only one route has buds out of a neighbour both routes have,
    // as iOS 27 grows it out of the shell beside it, and merges back into it
    // on the way out. Both shells draw into the run's layer for the length of
    // the transition, so their glass joins while they overlap and parts as
    // they separate. Not under the plain cross-fade or reduce motion, where
    // the group materializes on its own, and only between shells drawing the
    // run's own material: grouped glass takes the layer's settings.
    final budding = !state.settled &&
        !state.crossFade &&
        presenting == null &&
        state.transition != GlassEffectTransition.identity &&
        !GlassAccessibilityData.of(context).reduceMotion;
    bool buds(GlassNavBarGroup group) =>
        group.glass && group.items.every((item) => item.tintColor == null);

    // The neighbour a group buds from: the one beyond it, which it pushes
    // away, or else the one nearer the edge.
    _Shell? partnerOf(_Shell shell) {
      if (!budding || (shell.from != null) == (shell.to != null)) return null;
      final entering = shell.from == null;
      if (!buds(entering ? shell.to! : shell.from!)) return null;
      final place = entering ? shell.toPlace! : shell.fromPlace!;
      for (final offset in const [1, -1]) {
        for (final other in shells) {
          final from = other.from;
          final to = other.to;
          if (from == null || to == null || !buds(from) || !buds(to)) continue;
          if ((entering ? other.toPlace : other.fromPlace) == place + offset) {
            return other;
          }
        }
      }
      return null;
    }

    final partners = {for (final shell in shells) shell: partnerOf(shell)};

    // A shell's thickness across a horizontal run at rest, interpolated as
    // its group's is. See [_RunParentData.restCross].
    double? restCrossOf(_Shell shell) => axis == Axis.vertical
        ? null
        : lerpDouble(
            (shell.from ?? shell.to)!.crossExtent,
            (shell.to ?? shell.from)!.crossExtent,
            positionT,
          );
    final reshaping = partners.values.whereType<_Shell>().toSet();

    final children = <Widget>[];
    for (final shell in shells) {
      if (!holdsPresenting(shell.to)) continue;
      final partner = partners[shell];
      final Widget group;
      if (partner == null) {
        final phase = _groupPhaseAt(context, state, shell.from, shell.to);
        if (phase <= 0.0) continue;
        // The room leads the glass: a shell has made most of its room while
        // it is still faint, so it is never drawn over a neighbour at any
        // strength that shows.
        final room = Curves.easeOutQuint.transform(phase);
        group = _RunChild(
          key: keyOf(shell),
          fromPlace: shell.fromPlace,
          toPlace: shell.toPlace,
          fromRoom: room,
          toRoom: room,
          restCross: restCrossOf(shell),
          child: _PinnedGroup(
            state: state,
            from: shell.from,
            to: shell.to,
            anchoredAtStart: anchoredAtStart,
            reshapes: reshaping.contains(shell),
            grouped: reshaping.contains(shell),
          ),
        );
      } else {
        // A bud starts inside its partner, flush with the end it leaves
        // from, and takes its full room on the route that has it, so the
        // partner moves aside from the first frame; a merge runs the other
        // way.
        final entering = shell.from == null;
        group = _RunChild(
          key: keyOf(shell),
          fromPlace: entering ? partner.fromPlace : shell.fromPlace,
          toPlace: entering ? shell.toPlace : partner.toPlace,
          fromRoom: entering ? 0.0 : 1.0,
          toRoom: entering ? 1.0 : 0.0,
          flushFar: entering
              ? shell.toPlace! > partner.toPlace!
              : shell.fromPlace! > partner.fromPlace!,
          restCross: restCrossOf(shell),
          child: _PinnedGroup(
            state: state,
            from: shell.from,
            to: shell.to,
            anchoredAtStart: anchoredAtStart,
            buds: true,
            grouped: true,
          ),
        );
      }
      children.add(group);
    }

    Widget run = _PinnedRun(
      axis: axis,
      anchoredAtStart: anchoredAtStart,
      spacing: axis == Axis.vertical
          ? GlassVerticalBarMetrics.spacing
          : GlassNavPinnedMetrics.groupGap,
      positionT: positionT,
      children: children,
    );

    // Unconditional, so no shell remounts when a bud starts: with no grouped
    // shell in it the layer has nothing to draw and paints straight through.
    // The blend rises and falls with the parting: none while the bud is still
    // inside its partner, where it would swell the partner's end, the most as
    // a bridge between them, and none again by the time they reach their
    // places.
    run = AdaptiveLiquidGlassLayer(
      settings: GlassThemeHelpers.resolveSettings(
        context,
        explicit: DefaultButtonSettings.of(context),
      ),
      quality: GlassThemeHelpers.resolveQuality(context),
      blendAmount: _budBlend * math.sin(math.pi * positionT),
      platformViewBackdrop: state.flowTo.platformViewBackdrop,
      child: run,
    );

    return Transform.scale(
      scale: coverageScale,
      alignment: scaleAlignment,
      child: IgnorePointer(ignoring: !state.settled, child: run),
    );
  }
}

/// How far apart, in logical pixels, a bud and its partner blend at the height
/// of their parting.
const double _budBlend = 20.0;

/// One shell [_PinnedSide] draws: a group on either route or both, and where
/// each sits counted from the pinned edge.
typedef _Shell = ({
  GlassNavBarGroup? from,
  GlassNavBarGroup? to,
  int? fromPlace,
  int? toPlace,
});

/// Where a shell sits in each route's run, and how much of it is drawn.
class _RunParentData extends ContainerBoxParentData<RenderBox> {
  /// Place on the outgoing route, counted from the pinned edge.
  int? fromPlace;

  /// Place on the incoming route, counted from the pinned edge.
  int? toPlace;

  /// How much of its room the shell takes in the outgoing run, from 0 to 1.
  double fromRoom = 1.0;

  /// How much of its room the shell takes in the incoming run, from 0 to 1.
  double toRoom = 1.0;

  /// Whether, sharing a place with the shell it buds from or merges into, the
  /// shell sits flush with that shell's far end rather than its near one.
  bool flushFar = false;

  /// The shell's thickness across the run at rest, without its gel swell.
  ///
  /// A shell in a horizontal bar walks back half of its swell itself, so it
  /// is placed across the run by this rather than by its swollen size;
  /// placed by that, the shells beside a swelling one would sink. Null in the
  /// strip, where groups centre across their column as they are.
  double? restCross;
}

/// Lays a run's shells out at the places [_RunChild] gives them, interpolated
/// from the outgoing route's run to the incoming one's.
///
/// A [Flex] would drop a shell from its layout the frame it stops drawing, and
/// jump everything beyond it by its width. Here a shell's room grows and
/// shrinks with its materialize phase instead, so its neighbours open or close
/// the gap as it materializes or dissolves; and a shell whose items moved to
/// another place travels there rather than swapping with its neighbours at the
/// configuration swap.
class _PinnedRun extends MultiChildRenderObjectWidget {
  const _PinnedRun({
    required this.axis,
    required this.anchoredAtStart,
    required this.spacing,
    required this.positionT,
    required super.children,
  });

  /// The direction shells run in.
  final Axis axis;

  /// Whether places count from the box's left edge — its top edge in the
  /// strip — rather than its right.
  final bool anchoredAtStart;

  /// Gap between two shells.
  final double spacing;

  /// Interpolation from the outgoing run to the incoming one.
  final double positionT;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderPinnedRun(
        axis: axis,
        anchoredAtStart: anchoredAtStart,
        spacing: spacing,
        positionT: positionT,
      );

  @override
  void updateRenderObject(BuildContext context, _RenderPinnedRun renderObject) {
    renderObject
      ..axis = axis
      ..anchoredAtStart = anchoredAtStart
      ..spacing = spacing
      ..positionT = positionT;
  }
}

class _RenderPinnedRun extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _RunParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _RunParentData> {
  _RenderPinnedRun({
    required Axis axis,
    required bool anchoredAtStart,
    required double spacing,
    required double positionT,
  })  : _axis = axis,
        _anchoredAtStart = anchoredAtStart,
        _spacing = spacing,
        _positionT = positionT;

  Axis _axis;
  set axis(Axis value) {
    if (_axis == value) return;
    _axis = value;
    markNeedsLayout();
  }

  bool _anchoredAtStart;
  set anchoredAtStart(bool value) {
    if (_anchoredAtStart == value) return;
    _anchoredAtStart = value;
    markNeedsLayout();
  }

  double _spacing;
  set spacing(double value) {
    if (_spacing == value) return;
    _spacing = value;
    markNeedsLayout();
  }

  double _positionT;
  set positionT(double value) {
    if (_positionT == value) return;
    _positionT = value;
    markNeedsLayout();
  }

  bool get _vertical => _axis == Axis.vertical;

  double _mainOf(Size size) => _vertical ? size.height : size.width;

  double _crossOf(Size size) => _vertical ? size.width : size.height;

  /// Only the cross axis is bounded, as a [Flex] bounds its children.
  BoxConstraints _childConstraints(BoxConstraints constraints) => _vertical
      ? BoxConstraints(maxWidth: constraints.maxWidth)
      : BoxConstraints(maxHeight: constraints.maxHeight);

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _RunParentData) {
      child.parentData = _RunParentData();
    }
  }

  /// The run's size, and each child's distance from the anchored edge and
  /// offset across the run, in child order, given each child's size.
  (Size, List<double>, List<double>) _arrange(
    BoxConstraints constraints,
    Size Function(RenderBox child) sizeOf,
  ) {
    final datas = <_RunParentData>[];
    final sizes = <Size>[];
    var child = firstChild;
    while (child != null) {
      final data = child.parentData! as _RunParentData;
      datas.add(data);
      sizes.add(sizeOf(child));
      child = data.nextSibling;
    }

    // How far a shell sits from the anchored edge on one route: the room
    // taken by every shell nearer the edge there, each scaled by how much of
    // it that shell takes. A shell that takes none there is budding from, or
    // merging into, the shell whose place it shares, and sits inside it.
    double? distanceOn(int index, {required bool from}) {
      int? placeOf(_RunParentData data) => from ? data.fromPlace : data.toPlace;
      double roomOf(_RunParentData data) => from ? data.fromRoom : data.toRoom;
      final place = placeOf(datas[index]);
      if (place == null) return null;
      var distance = 0.0;
      for (var j = 0; j < datas.length; j++) {
        final other = placeOf(datas[j]);
        if (other == null || other >= place) continue;
        distance += (_mainOf(sizes[j]) + _spacing) * roomOf(datas[j]);
      }
      if (roomOf(datas[index]) == 0.0 && datas[index].flushFar) {
        for (var j = 0; j < datas.length; j++) {
          if (j == index || placeOf(datas[j]) != place) continue;
          if (roomOf(datas[j]) == 0.0) continue;
          distance += _mainOf(sizes[j]) - _mainOf(sizes[index]);
          break;
        }
      }
      return distance;
    }

    // Across the run every shell centres on the thickest one at rest, so a
    // swelling shell and its neighbours share a centre line.
    var rest = 0.0;
    for (var i = 0; i < datas.length; i++) {
      rest = math.max(rest, datas[i].restCross ?? _crossOf(sizes[i]));
    }

    final distances = <double>[];
    final offsets = <double>[];
    var main = 0.0;
    var cross = 0.0;
    for (var i = 0; i < datas.length; i++) {
      final from = distanceOn(i, from: true);
      final to = distanceOn(i, from: false);
      final distance = lerpDouble(from ?? to, to ?? from, _positionT)!;
      distances.add(distance);
      main = math.max(main, distance + _mainOf(sizes[i]));
      final offset = (rest - (datas[i].restCross ?? _crossOf(sizes[i]))) / 2.0;
      offsets.add(offset);
      cross = math.max(cross, offset + _crossOf(sizes[i]));
    }
    return (
      constraints.constrain(_vertical ? Size(cross, main) : Size(main, cross)),
      distances,
      offsets,
    );
  }

  @override
  void performLayout() {
    final childConstraints = _childConstraints(constraints);
    var child = firstChild;
    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);
      child = childAfter(child);
    }

    final (runSize, distances, offsets) =
        _arrange(constraints, (child) => child.size);
    size = runSize;

    var i = 0;
    child = firstChild;
    while (child != null) {
      final data = child.parentData! as _RunParentData;
      final distance = distances[i];
      final main = _anchoredAtStart
          ? distance
          : _mainOf(size) - distance - _mainOf(child.size);
      final cross = data.restCross == null
          ? (_crossOf(size) - _crossOf(child.size)) / 2.0
          : offsets[i];
      i++;
      data.offset = _vertical ? Offset(cross, main) : Offset(main, cross);
      child = data.nextSibling;
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final childConstraints = _childConstraints(constraints);
    return _arrange(
      constraints,
      (child) => child.getDryLayout(childConstraints),
    ).$1;
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}

/// Gives one shell its places in a [_PinnedRun].
class _RunChild extends ParentDataWidget<_RunParentData> {
  const _RunChild({
    super.key,
    required this.fromPlace,
    required this.toPlace,
    required this.fromRoom,
    required this.toRoom,
    this.flushFar = false,
    this.restCross,
    required super.child,
  });

  final int? fromPlace;
  final int? toPlace;
  final double fromRoom;
  final double toRoom;
  final bool flushFar;
  final double? restCross;

  @override
  void applyParentData(RenderObject renderObject) {
    final data = renderObject.parentData! as _RunParentData;
    if (data.fromPlace == fromPlace &&
        data.toPlace == toPlace &&
        data.fromRoom == fromRoom &&
        data.toRoom == toRoom &&
        data.flushFar == flushFar &&
        data.restCross == restCross) {
      return;
    }
    data
      ..fromPlace = fromPlace
      ..toPlace = toPlace
      ..fromRoom = fromRoom
      ..toRoom = toRoom
      ..flushFar = flushFar
      ..restCross = restCross;
    final parent = renderObject.parent;
    if (parent is RenderObject) parent.markNeedsLayout();
  }

  @override
  Type get debugTypicalAncestorWidgetClass => _PinnedRun;
}

// =============================================================================
// Item matching
// =============================================================================

/// Pairs two routes' groups so a shell that survives the transition morphs in
/// place.
///
/// [matchGlassNavActions] one level up. A group pairs first with the group
/// holding any of its items — by identity, or by `id` where the item has one —
/// so a shell follows its items when a spacer adds or removes a group beside
/// it. Groups left over pair by position, counted from the anchored edge as
/// [anchoredAtStart] describes, and anything still unpaired enters or exits
/// on its own.
///
/// Returned with the incoming groups first, in order, and the groups only the
/// outgoing route has after them.
///
/// Public for testing; held back from the barrel's `show` clause.
@visibleForTesting
List<({GlassNavBarGroup? from, GlassNavBarGroup? to})> matchGlassNavGroups(
  List<GlassNavBarGroup> from,
  List<GlassNavBarGroup> to, {
  bool anchoredAtStart = false,
}) {
  int slotOf(int index, int length) =>
      anchoredAtStart ? index : length - 1 - index;

  final matches = List<int?>.filled(to.length, null);
  final usedFrom = <int>{};

  // Shared items first, for every group, so no group's positional fallback
  // can take a partner another group's items have already claimed.
  for (var t = 0; t < to.length; t++) {
    for (var f = 0; f < from.length; f++) {
      if (usedFrom.contains(f) || !to[t].items.any(from[f].contains)) continue;
      matches[t] = f;
      usedFrom.add(f);
      break;
    }
  }
  for (var t = 0; t < to.length; t++) {
    if (matches[t] != null) continue;
    final wanted = slotOf(t, to.length);
    for (var f = 0; f < from.length; f++) {
      if (usedFrom.contains(f) || slotOf(f, from.length) != wanted) continue;
      matches[t] = f;
      usedFrom.add(f);
      break;
    }
  }

  return [
    for (var t = 0; t < to.length; t++)
      (from: matches[t] == null ? null : from[matches[t]!], to: to[t]),
    for (var f = 0; f < from.length; f++)
      if (!usedFrom.contains(f)) (from: from[f], to: null),
  ];
}

/// One item's place in the morph between two routes' action clusters.
///
/// Public for testing; held back from the barrel's `show` clause.
@immutable
@visibleForTesting
class GlassNavActionSlot {
  /// Creates a slot pairing an outgoing item with an incoming one.
  const GlassNavActionSlot({this.fromItem, this.toItem});

  /// The item on the outgoing route, if any.
  final GlassBarActionItem? fromItem;

  /// The item on the incoming route, if any.
  final GlassBarActionItem? toItem;

  /// Whether this item exists only on the incoming route.
  bool get isEnter => fromItem == null;

  /// Whether this item exists only on the outgoing route.
  bool get isExit => toItem == null;

  /// Whether both sides exist but render different content.
  bool get crossFades {
    final from = fromItem;
    final to = toItem;
    return from != null &&
        to != null &&
        !_sameContent(from.content, to.content);
  }

  /// Whether two content widgets draw the same thing.
  ///
  /// Reference identity first — but identical `const Icon(...)` expressions
  /// are not reliably canonicalised into one instance, so the overwhelmingly
  /// common case of an icon is compared by value: two icons drawing the same
  /// glyph are the same content. Anything else stays conservative on
  /// identity; a spurious cross-fade of identical pixels is invisible, but
  /// the morph gel keying off it is not.
  static bool _sameContent(Widget a, Widget b) {
    if (identical(a, b)) return true;
    return a is Icon &&
        b is Icon &&
        a.icon == b.icon &&
        a.size == b.size &&
        a.color == b.color &&
        a.key == b.key;
  }
}

/// Pairs two routes' action items so matched ones morph in place.
///
/// Mirrors UIKit, which matches bar button items by identifier when one is
/// set and otherwise falls back to position and content heuristics.
///
/// Returned slots are ordered leading-to-trailing in the incoming cluster,
/// with items that only exist on the outgoing route appended.
///
/// [anchoredAtStart] follows the cluster it is matching: a trailing cluster
/// counts positions from its trailing edge, a leading one from its leading
/// edge. Either way an item keeps its place when items are added on the far
/// side of the cluster from the bar edge it is pinned to.
///
/// Public for testing; held back from the barrel's `show` clause.
@visibleForTesting
List<GlassNavActionSlot> matchGlassNavActions(
  List<GlassBarActionItem> from,
  List<GlassBarActionItem> to, {
  bool anchoredAtStart = false,
}) {
  // Slot index counts from the anchored edge, because that is the edge the
  // cluster grows away from.
  int slotOf(int index, int length) =>
      anchoredAtStart ? index : length - 1 - index;

  final slots = <GlassNavActionSlot>[];
  final usedFrom = <int>{};

  int? takeMatch(GlassBarActionItem toItem, int toIndex) {
    // 1. Explicit identifier match, mirroring UIBarButtonItem.identifier.
    if (toItem.id != null) {
      for (var i = 0; i < from.length; i++) {
        if (usedFrom.contains(i)) continue;
        if (from[i].id == toItem.id) return i;
      }
    }
    // 2. Positional fallback, counting from the anchored edge. An item
    //    carrying a different explicit id is never matched positionally.
    final wanted = slotOf(toIndex, to.length);
    for (var i = 0; i < from.length; i++) {
      if (usedFrom.contains(i)) continue;
      if (from[i].id != null && from[i].id != toItem.id) continue;
      if (slotOf(i, from.length) == wanted) return i;
    }
    return null;
  }

  for (var i = 0; i < to.length; i++) {
    final match = takeMatch(to[i], i);
    if (match != null) usedFrom.add(match);
    slots.add(GlassNavActionSlot(
      fromItem: match != null ? from[match] : null,
      toItem: to[i],
    ));
  }

  // Anything left on the outgoing route exits in place.
  for (var i = 0; i < from.length; i++) {
    if (usedFrom.contains(i)) continue;
    slots.add(GlassNavActionSlot(fromItem: from[i]));
  }

  return slots;
}

// -----------------------------------------------------------------------------
// Measuring cluster layout
// -----------------------------------------------------------------------------

/// Where a slot sits within each of the two clusters being interpolated.
@immutable
class _SlotOrder {
  const _SlotOrder({this.fromOrder, this.toOrder});

  /// Index within the outgoing cluster, leading to trailing.
  final int? fromOrder;

  /// Index within the incoming cluster, leading to trailing.
  final int? toOrder;
}

/// Identifies which slot and which side a child belongs to.
class _ClusterParentData extends ContainerBoxParentData<RenderBox> {
  int slot = 0;
  bool isFrom = false;
  double opacity = 1.0;
  double blurSigma = 0.0;

  /// Reused across frames so a blurring glyph does not allocate a fresh
  /// layer per paint. A [LayerHandle] keeps it alive between frames.
  final LayerHandle<ImageFilterLayer> blurLayer =
      LayerHandle<ImageFilterLayer>();

  @override
  void detach() {
    blurLayer.layer = null;
    super.detach();
  }
}

/// Lays out both routes' clusters and interpolates between them.
///
/// Item widths are **measured**, not assumed, which is what lets custom
/// content sit in the bar: the cluster sizes itself around whatever the item
/// turns out to be, exactly as UIKit measures a `customView` during layout.
/// Icons simply measure to the standard slot width.
class _PinnedCluster extends MultiChildRenderObjectWidget {
  const _PinnedCluster({
    required this.orders,
    required this.widthT,
    required this.positionT,
    required this.morphScale,
    required this.crossExtent,
    required this.anchoredAtStart,
    this.axis = Axis.horizontal,
    required super.children,
  });

  /// Per-slot placement in each cluster, indexed by slot.
  final List<_SlotOrder> orders;

  /// Interpolation for the overall width.
  final double widthT;

  /// Interpolation for per-item positions and widths.
  final double positionT;

  /// Uniform gel scale applied to the cluster's real geometry.
  final double morphScale;

  /// Fixed thickness across the cluster, before the gel scale.
  final double crossExtent;

  /// Whether items are placed relative to the box's left edge — its top edge
  /// in the vertical strip.
  ///
  /// The cluster's length changes across a morph, so only the anchored edge
  /// holds still — items measured from the other one would drift as the shell
  /// resized around them.
  final bool anchoredAtStart;

  /// The direction items run in.
  final Axis axis;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderPinnedCluster(
        orders: orders,
        widthT: widthT,
        positionT: positionT,
        morphScale: morphScale,
        crossExtent: crossExtent,
        anchoredAtStart: anchoredAtStart,
        axis: axis,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderPinnedCluster renderObject,
  ) {
    renderObject
      ..orders = orders
      ..widthT = widthT
      ..positionT = positionT
      ..morphScale = morphScale
      ..crossExtent = crossExtent
      ..anchoredAtStart = anchoredAtStart
      ..axis = axis;
  }
}

class _RenderPinnedCluster extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ClusterParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ClusterParentData> {
  _RenderPinnedCluster({
    required List<_SlotOrder> orders,
    required double widthT,
    required double positionT,
    required double morphScale,
    required double crossExtent,
    required bool anchoredAtStart,
    required Axis axis,
  })  : _orders = orders,
        _widthT = widthT,
        _positionT = positionT,
        _morphScale = morphScale,
        _crossExtent = crossExtent,
        _anchoredAtStart = anchoredAtStart,
        _axis = axis;

  List<_SlotOrder> _orders;
  set orders(List<_SlotOrder> value) {
    if (_orders == value) return;
    _orders = value;
    markNeedsLayout();
  }

  double _widthT;
  set widthT(double value) {
    if (_widthT == value) return;
    _widthT = value;
    markNeedsLayout();
  }

  double _positionT;
  set positionT(double value) {
    if (_positionT == value) return;
    _positionT = value;
    markNeedsLayout();
  }

  double _morphScale;
  set morphScale(double value) {
    if (_morphScale == value) return;
    final wasScaled = _morphScale != 1.0;
    _morphScale = value;
    if (wasScaled != (value != 1.0)) markNeedsCompositingBitsUpdate();
    markNeedsLayout();
  }

  /// Compositing is required while the gel scales: the blurring glyphs paint
  /// into their own layers, and only a transform *layer* carries those with
  /// the scale — a canvas transform leaves them pinned at their unscaled
  /// positions while the shell inflates around them. At rest this is false
  /// and the cluster paints directly.
  @override
  bool get alwaysNeedsCompositing => _morphScale != 1.0;

  double _crossExtent;
  set crossExtent(double value) {
    if (_crossExtent == value) return;
    _crossExtent = value;
    markNeedsLayout();
  }

  bool _anchoredAtStart;
  set anchoredAtStart(bool value) {
    if (_anchoredAtStart == value) return;
    _anchoredAtStart = value;
    markNeedsLayout();
  }

  Axis _axis;
  set axis(Axis value) {
    if (_axis == value) return;
    _axis = value;
    markNeedsLayout();
  }

  bool get _vertical => _axis == Axis.vertical;

  /// Only the cross axis is imposed; children size themselves along the main
  /// one.
  BoxConstraints get _childConstraints => _vertical
      ? BoxConstraints.tightFor(width: _crossExtent)
      : BoxConstraints.tightFor(height: _crossExtent);

  double _mainOf(Size size) => _vertical ? size.height : size.width;

  Size _sized(double main, double cross) =>
      _vertical ? Size(cross, main) : Size(main, cross);

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ClusterParentData) {
      child.parentData = _ClusterParentData();
    }
  }

  @override
  void performLayout() {
    final slotCount = _orders.length;
    // Measured natural length of each slot on each side, along the main axis.
    final fromWidths = List<double?>.filled(slotCount, null);
    final toWidths = List<double?>.filled(slotCount, null);

    var child = firstChild;
    while (child != null) {
      final data = child.parentData! as _ClusterParentData;
      child.layout(_childConstraints, parentUsesSize: true);
      if (data.isFrom) {
        fromWidths[data.slot] = _mainOf(child.size);
      } else {
        toWidths[data.slot] = _mainOf(child.size);
      }
      child = data.nextSibling;
    }

    // A slot missing one side keeps the width it does have, so an entering or
    // exiting item scales in place rather than resizing.
    double widthOf(int slot, {required bool from}) =>
        (from ? fromWidths[slot] : toWidths[slot]) ??
        (from ? toWidths[slot] : fromWidths[slot]) ??
        0.0;

    // Distance from the cluster's anchored edge for each slot, per side.
    final fromEdge = List<double?>.filled(slotCount, null);
    final toEdge = List<double?>.filled(slotCount, null);

    double layoutSide({required bool from}) {
      final ordered = <int>[];
      for (var slot = 0; slot < slotCount; slot++) {
        final order = from ? _orders[slot].fromOrder : _orders[slot].toOrder;
        if (order != null) ordered.add(slot);
      }
      ordered.sort((a, b) {
        final oa = (from ? _orders[a].fromOrder : _orders[a].toOrder)!;
        final ob = (from ? _orders[b].fromOrder : _orders[b].toOrder)!;
        return oa.compareTo(ob);
      });

      var total = 0.0;
      for (final slot in ordered) {
        total += widthOf(slot, from: from);
      }
      // Walk leading to trailing, recording how far each slot sits from the
      // anchored edge — which is what it consumed on the way there, or what is
      // left beyond it when the far edge is the anchor.
      var consumed = 0.0;
      for (final slot in ordered) {
        final w = widthOf(slot, from: from);
        final edge = _anchoredAtStart ? consumed : total - consumed - w;
        if (from) {
          fromEdge[slot] = edge;
        } else {
          toEdge[slot] = edge;
        }
        consumed += w;
      }
      return total;
    }

    final fromTotal = layoutSide(from: true);
    final toTotal = layoutSide(from: false);

    // The gel scales the box itself: the glass shell wrapping this cluster
    // re-renders at the true inflated size, and paint scales the children to
    // fill it, so shell and glyphs stretch as one body.
    final width = lerpDouble(fromTotal, toTotal, _widthT)!;
    final scaled = _sized(width * _morphScale, _crossExtent * _morphScale);
    size = constraints.constrain(scaled);
    // The bar hosts this cluster in an unbounded row or column, so the
    // constraint never bites there; anywhere it did, paint would scale past
    // the box (the shell's ClipRect contains it, but the layout would be
    // lying).
    assert(
      _mainOf(scaled) <=
          (_vertical ? constraints.maxHeight : constraints.maxWidth) + 0.001,
      'The gel scale needs an unbounded main axis: a clamped box would paint '
      'outside itself.',
    );

    // Position every child by its interpolated distance from the anchored
    // edge — in the pre-scale space, because paint scales the lot into the
    // inflated box.
    child = firstChild;
    while (child != null) {
      final data = child.parentData! as _ClusterParentData;
      final slot = data.slot;
      final edge = lerpDouble(
        fromEdge[slot] ?? toEdge[slot] ?? 0.0,
        toEdge[slot] ?? fromEdge[slot] ?? 0.0,
        _positionT,
      )!;
      final slotWidth = lerpDouble(
        widthOf(slot, from: true),
        widthOf(slot, from: false),
        _positionT,
      )!;
      final main = (_anchoredAtStart ? edge : width - edge - slotWidth) +
          (slotWidth - _mainOf(child.size)) / 2.0;
      if (_vertical) {
        data.offset = Offset((_crossExtent - child.size.width) / 2.0, main);
      } else {
        data.offset = Offset(main, (_crossExtent - child.size.height) / 2.0);
      }
      child = data.nextSibling;
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    // Mirrors performLayout's sizing: measure both sides' totals from the
    // children's dry sizes and interpolate.
    final slotCount = _orders.length;
    final fromWidths = List<double?>.filled(slotCount, null);
    final toWidths = List<double?>.filled(slotCount, null);

    var child = firstChild;
    while (child != null) {
      final data = child.parentData! as _ClusterParentData;
      final width = _mainOf(child.getDryLayout(_childConstraints));
      if (data.isFrom) {
        fromWidths[data.slot] = width;
      } else {
        toWidths[data.slot] = width;
      }
      child = data.nextSibling;
    }

    double totalFor({required bool from}) {
      var total = 0.0;
      for (var slot = 0; slot < slotCount; slot++) {
        final order = from ? _orders[slot].fromOrder : _orders[slot].toOrder;
        if (order == null) continue;
        total += (from ? fromWidths[slot] : toWidths[slot]) ??
            (from ? toWidths[slot] : fromWidths[slot]) ??
            0.0;
      }
      return total;
    }

    final width = lerpDouble(
      totalFor(from: true),
      totalFor(from: false),
      _widthT,
    )!;
    return constraints
        .constrain(_sized(width * _morphScale, _crossExtent * _morphScale));
  }

  /// The paint transform of the gel: a uniform scale about the box origin.
  Matrix4 get _gelTransform =>
      Matrix4.diagonal3Values(_morphScale, _morphScale, 1.0);

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_morphScale != 1.0) {
      // Children are laid out at their natural size and scaled into the
      // inflated box, glyphs and all — the stretch carries the contents.
      // See [alwaysNeedsCompositing] for why this is a layer, and
      // [applyPaintTransform] for the matching hit-test/semantics mirror.
      layer = context.pushTransform(
        true,
        offset,
        _gelTransform,
        _paintChildren,
        oldLayer: layer as TransformLayer?,
      );
      return;
    }
    layer = null;
    _paintChildren(context, offset);
  }

  void _paintChildren(PaintingContext context, Offset offset) {
    var child = firstChild;
    while (child != null) {
      final data = child.parentData! as _ClusterParentData;
      final childOffset = offset + data.offset;
      final current = child;

      // Item contents are not glass, so fading and filtering them here is
      // safe — the shell's own glass dissolves through the shader instead.
      // The blur sits inside the opacity so a glyph fades as one soft image;
      // the layer is kept on the parent data and reused across frames.
      void paintContent(PaintingContext ctx, Offset off) {
        if (data.blurSigma > 0.01) {
          final blurLayer = data.blurLayer.layer ??= ImageFilterLayer();
          blurLayer.imageFilter = ImageFilter.blur(
            sigmaX: data.blurSigma,
            sigmaY: data.blurSigma,
            tileMode: TileMode.decal,
          );
          ctx.pushLayer(blurLayer, (c, o) => c.paintChild(current, o), off);
        } else {
          data.blurLayer.layer = null;
          ctx.paintChild(current, off);
        }
      }

      if (data.opacity >= 1.0) {
        paintContent(context, childOffset);
      } else if (data.opacity > 0.0) {
        context.pushOpacity(
          childOffset,
          (data.opacity * 255).round(),
          paintContent,
        );
      }
      child = data.nextSibling;
    }
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    // Mirror paint exactly: the gel scale about the box origin, then the
    // child's offset inside the scaled space — so semantics rects,
    // localToGlobal and hit-testing agree with what is painted mid-gel.
    if (_morphScale != 1.0) transform.multiply(_gelTransform);
    super.applyPaintTransform(child, transform);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (_morphScale == 1.0) {
      return defaultHitTestChildren(result, position: position);
    }
    return result.addWithPaintTransform(
      transform: _gelTransform,
      position: position,
      hitTest: (result, position) =>
          defaultHitTestChildren(result, position: position),
    );
  }
}

/// Applies a per-child opacity and blur through the cluster's parent data.
class _ClusterChild extends ParentDataWidget<_ClusterParentData> {
  const _ClusterChild({
    required this.slot,
    required this.isFrom,
    required this.opacity,
    required this.blurSigma,
    required super.child,
  });

  final int slot;
  final bool isFrom;
  final double opacity;
  final double blurSigma;

  @override
  void applyParentData(RenderObject renderObject) {
    final data = renderObject.parentData! as _ClusterParentData;
    var needsPaint = false;
    var needsLayout = false;
    if (data.slot != slot) {
      data.slot = slot;
      needsLayout = true;
    }
    if (data.isFrom != isFrom) {
      data.isFrom = isFrom;
      needsLayout = true;
    }
    if (data.opacity != opacity) {
      data.opacity = opacity;
      needsPaint = true;
    }
    if (data.blurSigma != blurSigma) {
      data.blurSigma = blurSigma;
      needsPaint = true;
    }
    final parent = renderObject.parent;
    if (parent is RenderObject) {
      if (needsLayout) {
        parent.markNeedsLayout();
      } else if (needsPaint) {
        parent.markNeedsPaint();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => _PinnedCluster;
}

// -----------------------------------------------------------------------------
// One group's shell
// -----------------------------------------------------------------------------

/// One group of a cluster, on both routes, interpolated.
///
/// A group that survives a transition keeps one persistent glass shell whose
/// geometry animates; its element is never remounted mid-morph. While both
/// routes have the group the shell only animates geometry; when just one does
/// it materializes in or out around that geometry. The items inside it —
/// which are not glass — cross-fade freely either way.
class _PinnedGroup extends StatefulWidget {
  const _PinnedGroup({
    required this.state,
    required this.from,
    required this.to,
    required this.anchoredAtStart,
    this.buds = false,
    this.reshapes = false,
    this.grouped = false,
  });

  final GlassNavPinnedState state;

  /// This group on the outgoing route, or null if it only enters.
  final GlassNavBarGroup? from;

  /// This group on the incoming route, or null if it only exits.
  final GlassNavBarGroup? to;

  /// Whether items are placed relative to the box's left edge.
  final bool anchoredAtStart;

  /// Whether this group, which only one route has, buds out of a neighbour or
  /// merges back into it rather than materializing on its own.
  ///
  /// Its glass stays solid throughout, hidden inside the neighbour's until
  /// they part, and only its items fade.
  final bool buds;

  /// Whether a group is budding out of this one or merging into it.
  ///
  /// The shell reshapes around the bud, so its items blur through the morph
  /// as they would if they had changed.
  final bool reshapes;

  /// Whether the shell draws into the run's shared layer rather than one of
  /// its own, so its glass can join a neighbour's.
  final bool grouped;

  @override
  State<_PinnedGroup> createState() => _PinnedGroupState();
}

class _PinnedGroupState extends State<_PinnedGroup> {
  /// Drives the pull-down of whichever item is currently the menu trigger.
  final GlassMenuController _menu = GlassMenuController();

  /// The morph anchor of this group's shell.
  ///
  /// Written as the trigger builds and read at tap time, never captured: the
  /// anchor belongs to the trigger's element, and the cluster's items are
  /// built before it is.
  GlassMorphAnchor? _anchor;

  /// Presents [item]'s sheet out of this group's shell.
  ///
  /// The shell is asked to keep the group first: a presentation hands the
  /// chrome back to the route, and this capsule has to stay where the droplet
  /// left it. The anchor is null only before the trigger has built, which a
  /// tap cannot precede.
  void _presentSheet(GlassBarSheetItem item) {
    final anchor = _anchor;
    if (anchor != null) widget.state.holdForSheet?.call(item, anchor);
    item.onPresent(anchor);
  }

  @override
  void didUpdateWidget(covariant _PinnedGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Dismiss on the first unsettled frame. A route-owned menu goes away with
    // its route, but this shell outlives every route it serves, so an open
    // menu would otherwise hang over the bar while the page slid out from
    // under it.
    if (oldWidget.state.settled && !widget.state.settled && _menu.isOpen) {
      _menu.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    // The route being entered, in flow terms rather than stack terms. A
    // change of render path remounts the shell's surface, so it should flip
    // on the first frame of a transition and never at its end: on a pop back
    // over a platform view [GlassNavPinnedState.to] is still the route
    // leaving, and reading it would have the returning capsule materialize
    // through the shader and pop to the backdrop once settled.
    final platformViewBackdrop = state.flowTo.platformViewBackdrop;
    // The forward-choreography clock: mirrored on a pop, with the group's
    // sides already swapped to match by the side above.
    final p = state.flowProgress;
    final showsIncoming = GlassNavPinnedMetrics.showsIncomingAt(p);

    final sides = _resolveGroupSides(widget.from, widget.to, p);
    final from = sides.from;
    final to = sides.to;
    if (from == null && to == null) return const SizedBox.shrink();

    final fromItems = from?.items ?? const <GlassBarActionItem>[];
    final toItems = to?.items ?? const <GlassBarActionItem>[];

    // The cluster and the page share one clock: width and item positions ride
    // the morph spring for the full length of the route transition and settle
    // with it. The spring's excursions are not walked in width — the
    // overshoot becomes the gel squeeze below, so layout takes the clamp.
    final morphT = GlassNavPinnedMetrics.morphProgressAt(p);
    final springT = GlassNavMorphCurve.instance.transform(morphT);
    final clampedT = springT.clamp(0.0, 1.0);

    final slots = matchGlassNavActions(
      fromItems,
      toItems,
      anchoredAtStart: widget.anchoredAtStart,
    );

    // The gel: a swell pulse inflates the whole shell early — height, radius
    // and glyphs together, as real geometry, the way stretching any glass in
    // this package carries its contents with it — and the spring's landing
    // overshoot squeezes it back. Never a paint transform: the glass texture
    // has no headroom for one. Groups only one route has materialize instead,
    // and a group the two routes agree on — the usual lone back button — sits
    // perfectly still, exactly as the native bar keeps an unchanged cluster
    // frozen while its neighbours morph.
    final overshoot = (springT - 1.0).clamp(0.0, 1.0);
    final morphing = fromItems.isNotEmpty && toItems.isNotEmpty;
    final changes = widget.reshapes ||
        fromItems.length != toItems.length ||
        slots.any((s) => s.isEnter || s.isExit || s.crossFades);
    final morphScale = !morphing || !changes || state.settled || state.crossFade
        ? 1.0
        : 1.0 +
            GlassNavPinnedMetrics.swellPulseAt(morphT) -
            GlassNavPinnedMetrics.squeezeScale * overshoot;

    // With one side empty the shell holds the width it has: collapsing the
    // width would leave a degenerate glass shape on the way out.
    final widthT = fromItems.isEmpty
        ? 1.0
        : toItems.isEmpty
            ? 0.0
            : clampedT;

    // Drives the materialize window for a group that only one route has. The
    // side has already dropped groups whose phase is zero, so this is only
    // ever a partial phase or a full one.
    final phase = widget.buds
        ? 1.0
        : GlassNavPinnedHost.phaseFor(
            context,
            state,
            inFrom: fromItems.isNotEmpty,
            inTo: toItems.isNotEmpty,
          );

    // Geometry for a side that does not exist comes from the side that does,
    // so an entering or exiting group holds its shape rather than resizing.
    final fromGroup = from ?? to!;
    final toGroup = to ?? from!;

    // Whichever side is showing owns the menu. A menu can only be opened at
    // rest, where that is always the incoming side, but the trigger is rebuilt
    // every frame and must agree with the icons actually on screen. Only the
    // first menu item counts, matching GlassButtonGroup.
    GlassBarMenuItem? menuItem;
    for (final item in showsIncoming ? toItems : fromItems) {
      if (item is GlassBarMenuItem) {
        menuItem = item;
        break;
      }
    }

    // Where each slot sits within each group, leading to trailing.
    final orders = <_SlotOrder>[];
    var fromOrder = 0;
    var toOrder = 0;
    final fromOrders = <int, int>{};
    final toOrders = <int, int>{};
    for (var i = 0; i < slots.length; i++) {
      if (slots[i].toItem != null) toOrders[i] = toOrder++;
    }
    // Outgoing order follows the outgoing group, not the slot list.
    for (final item in fromItems) {
      final i = slots.indexWhere((s) => identical(s.fromItem, item));
      if (i >= 0) fromOrders[i] = fromOrder++;
    }
    for (var i = 0; i < slots.length; i++) {
      orders.add(_SlotOrder(fromOrder: fromOrders[i], toOrder: toOrders[i]));
    }

    // Cross-fade window for a matched item whose content changed, and
    // entering / exiting items during a morph.
    final q = state.crossFade
        ? p.clamp(0.0, 1.0)
        : ((morphT - GlassNavPinnedMetrics.crossFadeStart) /
                (GlassNavPinnedMetrics.crossFadeEnd -
                    GlassNavPinnedMetrics.crossFadeStart))
            .clamp(0.0, 1.0);

    // A bud's items fade on the item windows, as an item entering or leaving
    // a shell does, since its glass never dissolves.
    final noDestination = toItems.isEmpty && !morphing && !widget.buds;

    // Glyph blur, the other half of the native read. An outgoing glyph blurs
    // away as it fades; an incoming one arrives soft and sharpens last. Item
    // contents are not glass, so filtering them is safe — the shell itself
    // never animates opacity. Groups without a destination dissolve as a
    // unit instead, with no independent glyph blur.
    final outSigma = state.settled || state.crossFade || noDestination
        ? 0.0
        : GlassNavPinnedMetrics.outgoingSigmaAt(morphT);
    final inSigma = state.settled || state.crossFade || noDestination
        ? 0.0
        : GlassNavPinnedMetrics.incomingSigmaAt(morphT);

    // In the plain cross-fade or when dissolving without a destination,
    // glyphs fade with their group's glass.
    final fadesWithGroup = (state.crossFade || noDestination) && !morphing;

    // An item whose content is itself glass cannot be faded or blurred from
    // outside: painted under an opacity or image-filter layer it has no
    // backdrop to sample, and renders as its backer until the layer is gone.
    // Those items dissolve through GlassMaterializeScope instead, which every
    // package surface honours, and the cluster paints them plain. The scope
    // sits here, below the GlassMenu wrapper, so it is the nearest one; it
    // still composes with any enclosing scope, so a menu morph can fade the
    // trigger.
    Widget clusterChild({
      required int slot,
      required bool isFrom,
      required double opacity,
      required double blurSigma,
      required GlassBarActionItem item,
      required Widget child,
    }) {
      if (item.background != GlassBarItemBackground.own) {
        return _ClusterChild(
          slot: slot,
          isFrom: isFrom,
          opacity: opacity,
          blurSigma: blurSigma,
          child: child,
        );
      }
      return _ClusterChild(
        slot: slot,
        isFrom: isFrom,
        opacity: 1.0,
        blurSigma: 0.0,
        child: _OwnGlassDissolve(
          opacity: opacity,
          sigma: blurSigma,
          child: child,
        ),
      );
    }

    final children = <Widget>[];
    for (var i = 0; i < slots.length; i++) {
      final slot = slots[i];
      final crossFades = slot.crossFades;
      final fromItem = slot.fromItem;
      final toItem = slot.toItem;

      // Two surfaces of an item's own cannot cross-fade any more than a
      // shell and a bare item can: stacked, each samples the other, and the
      // overlap reads as a brighter pad inside the incoming capsule. They
      // take turns instead, on the same windows a group only one route has.
      final sequenced = crossFades &&
          fromItem?.background == GlassBarItemBackground.own &&
          toItem?.background == GlassBarItemBackground.own;
      double sequencedPhase({required bool inFrom}) => state.settled
          ? 1.0
          : showsIncoming == inFrom
              ? 0.0
              : GlassNavPinnedHost.phaseFor(
                  context,
                  state,
                  inFrom: inFrom,
                  inTo: !inFrom,
                );

      if (fromItem != null) {
        if (toItem == null) {
          // Exiting item: smoothly fade out with (1 - q) across the transition window.
          // While transition is in-flight, keep mounted in morphing groups so natural width is preserved.
          // A bud is the same: its partner makes room for it from the start.
          final visible = state.settled
              ? !showsIncoming
              : (morphing ||
                  widget.buds ||
                  (fadesWithGroup ? phase > 0.0 : q < 1.0));
          if (visible) {
            children.add(clusterChild(
              slot: i,
              isFrom: true,
              opacity: state.settled
                  ? 1.0
                  : fadesWithGroup
                      ? phase
                      : (1.0 - q),
              blurSigma: outSigma,
              item: fromItem,
              child: _ClusterItem(
                item: fromItem,
                enabled: false,
                slotExtent: fromGroup.slotExtent,
                axis: fromGroup.axis,
                tintColor: fromItem.tintColor,
              ),
            ));
          }
        } else if (crossFades && (!state.settled ? q < 1.0 : !showsIncoming)) {
          // Cross-fading outgoing side.
          children.add(clusterChild(
            slot: i,
            isFrom: true,
            opacity: sequenced
                ? sequencedPhase(inFrom: true)
                : state.settled
                    ? 1.0
                    : (1.0 - q),
            blurSigma: outSigma,
            item: fromItem,
            child: _ClusterItem(
              item: fromItem,
              enabled: false,
              slotExtent: fromGroup.slotExtent,
              axis: fromGroup.axis,
              tintColor: fromItem.tintColor,
            ),
          ));
        }
      }

      if (toItem != null) {
        if (fromItem == null) {
          // Entering item: smoothly fade in with q across the transition window.
          // While transition is in-flight, keep mounted in morphing groups so natural width is preserved.
          // A bud is the same: its partner makes room for it from the start.
          final visible = state.settled
              ? showsIncoming
              : (morphing ||
                  widget.buds ||
                  (fadesWithGroup ? phase > 0.0 : q > 0.0));
          if (visible) {
            children.add(clusterChild(
              slot: i,
              isFrom: false,
              opacity: state.settled
                  ? 1.0
                  : fadesWithGroup
                      ? phase
                      : q,
              blurSigma: inSigma,
              item: toItem,
              child: _ClusterItem(
                item: toItem,
                enabled: state.settled,
                slotExtent: toGroup.slotExtent,
                axis: toGroup.axis,
                tintColor: toItem.tintColor,
                onMenuTap: identical(toItem, menuItem) ? _menu.open : null,
                onSheetTap: _presentSheet,
              ),
            ));
          }
        } else if (!crossFades || (!state.settled ? q > 0.0 : showsIncoming)) {
          // Matched persistent item or cross-fading incoming side.
          children.add(clusterChild(
            slot: i,
            isFrom: false,
            opacity: sequenced
                ? sequencedPhase(inFrom: false)
                : crossFades
                    ? (state.settled ? 1.0 : q)
                    : 1.0,
            // Reshaping, the item blurs on the way into the morph and
            // sharpens on the way out, as the shell's do natively.
            blurSigma: crossFades
                ? inSigma
                : widget.reshapes
                    ? math.min(outSigma, inSigma)
                    : 0.0,
            item: toItem,
            child: _ClusterItem(
              item: toItem,
              enabled: state.settled,
              slotExtent: toGroup.slotExtent,
              axis: toGroup.axis,
              tintColor: toItem.tintColor,
              onMenuTap: identical(toItem, menuItem) ? _menu.open : null,
              onSheetTap: _presentSheet,
            ),
          ));
        }
      }
    }

    if (children.isEmpty) return const SizedBox.shrink();

    final cluster = _PinnedCluster(
      orders: orders,
      widthT: widthT,
      positionT: clampedT,
      morphScale: morphScale,
      crossExtent:
          lerpDouble(fromGroup.crossExtent, toGroup.crossExtent, clampedT)!,
      anchoredAtStart: widget.anchoredAtStart,
      axis: toGroup.axis,
      children: children,
    );

    // All three wrappers are unconditional, even at rest and even with no
    // menu or sheet item: inserting or removing any of them would remount the
    // group's element, and a glass shell that remounts mid-morph pops its
    // backdrop. At a phase of 1.0 the effect is paint-neutral, a closed
    // GlassMenu adds only inert wrappers and mounts no overlay, and a morph
    // trigger at rest paints through a zero translation and a full opacity,
    // so the resting case costs nothing.
    // The gel is real geometry — the cluster lays out at scale and the glass
    // re-renders its true shape — so all that remains is recentring: the
    // shell is anchored top-edge at its bar corner, and natively the swell
    // moves both edges outward, so half of any growth is walked back.
    final f = morphScale <= 0.01 ? 0.0 : (1.0 - 1.0 / morphScale) / 2.0;
    // The strip centres each group across its column, so there only the
    // main axis needs walking back.
    final vertical = toGroup.axis == Axis.vertical;
    return GlassMaterializeEffect(
      progress: phase,
      plain: state.crossFade,
      // The window this group traverses is the incoming one exactly when it is
      // the incoming route that has it; the profile follows from the same
      // fact, so a pop reverses both together.
      profile: toItems.isNotEmpty
          ? GlassMaterializeProfile.entrance
          : GlassMaterializeProfile.exit,
      // It swells from the bar edge its cluster is pinned to.
      alignment: vertical
          ? Alignment.topCenter
          : widget.anchoredAtStart
              ? Alignment.centerLeft
              : Alignment.centerRight,
      scaleFrom: GlassNavPinnedMetrics.materializeScaleFrom,
      child: FractionalTranslation(
        translation: vertical
            ? Offset(0, -f)
            : Offset(widget.anchoredAtStart ? -f : f, -f),
        // The sheet morphs the whole shell, as the menu does — see
        // [GlassBarItem.sheet] — so the trigger wraps the shell and not the
        // tapped item's slot.
        child: GlassMorphTrigger(
          builder: (context, anchor) {
            _anchor = anchor;
            return GlassMenu(
              controller: _menu,
              items: menuItem?.menuItems ?? const <Widget>[],
              menuAlignment: menuItem?.menuAlignment,
              // The fallback is never read: with no menu item there is no
              // trigger to open one. It matches GlassMenu's own default.
              menuWidth: menuItem?.menuWidth ?? 200,
              menuHeight: menuItem?.menuHeight,
              platformViewBackdrop: platformViewBackdrop,
              triggerBuilder: (context, _) => toGroup.glass
                  ? _buildShell(
                      cluster: cluster,
                      stretch: lerpDouble(
                        fromGroup.stretch,
                        toGroup.stretch,
                        clampedT,
                      )!,
                      morphScale: morphScale,
                      platformViewBackdrop: platformViewBackdrop,
                      // Forward tintColor from a single-item separate group.
                      // Multi-item shared groups never have tintColor
                      // (asserted in groupGlassNavBarItems), so items.first is
                      // always the only item.
                      tintColor: toGroup.items.length == 1
                          ? toGroup.items.first.tintColor
                          : null,
                    )
                  : cluster,
            );
          },
        ),
      ),
    );
  }

  /// The glass shell itself, sized by the measured cluster.
  ///
  /// Split out so it can be handed to [GlassMenu.triggerBuilder] — the menu
  /// morphs the whole shell, not the tapped item's slot, matching iOS 26's
  /// `GlassEffectContainer`.
  ///
  /// The radius is the capsule's in every case: clamped to half the box, it is
  /// a capsule at the shared-cluster height and exactly a circle at the height
  /// a group that shares with nothing uses.
  Widget _buildShell({
    required Widget cluster,
    required double stretch,
    required double morphScale,
    required bool platformViewBackdrop,
    Color? tintColor,
  }) {
    // Build LiquidGlassSettings only when a tint is requested.
    // GlassBodyMode.clear performs direct alpha-composite tinting, preserving
    // the exact design-token hex value while retaining specular and Fresnel
    // rim physics — matching iOS 26's Metal path for coloured bar buttons.
    // The tint replaces the body colour only: it starts from the bar's button
    // settings, so the capsule keeps the outline and rim its neighbours get.
    final settings = tintColor != null
        ? (DefaultButtonSettings.of(context) ?? const LiquidGlassSettings())
            .copyWith(glassColor: tintColor, bodyMode: GlassBodyMode.clear)
        : null;
    return GlassButton.custom(
      onTap: () {},
      platformViewBackdrop: platformViewBackdrop,
      // The radius scales with the gel so the shape stays a true scaled
      // capsule rather than squaring off as it inflates.
      shape: LiquidRoundedRectangle(
        borderRadius: GlassNavPinnedMetrics.capsuleRadius * morphScale,
      ),
      // Sized by the measured cluster, exactly as GlassButtonGroup.icons
      // sizes to its content.
      width: null,
      height: null,
      stretch: stretch,
      useOwnLayer: !widget.grouped,
      canRequestFocus: false,
      excludeFromSemantics: true,
      settings: settings,
      child: ClipRect(child: cluster),
    );
  }
}

/// Dissolves a [GlassBarItemBackground.own] item through its own glass.
///
/// The cluster's fade and blur are handed to the item's surface as a
/// [GlassMaterializeScope] — visibility for the glass, opacity and blur for
/// the content inside it — in place of the paint-time layers ordinary items
/// get. Composed with any enclosing scope rather than replacing it, so a
/// menu fading its trigger still reaches the surface.
class _OwnGlassDissolve extends StatelessWidget {
  const _OwnGlassDissolve({
    required this.opacity,
    required this.sigma,
    required this.child,
  });

  final double opacity;
  final double sigma;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final outer = GlassMaterializeScope.maybeOf(context);
    return GlassMaterializeScope(
      glassProgress: opacity * (outer?.glassProgress ?? 1.0),
      contentOpacity: opacity * (outer?.contentOpacity ?? 1.0),
      contentSigma: math.max(sigma, outer?.contentSigma ?? 0.0),
      child: child,
    );
  }
}

/// One item's content inside the cluster.
///
/// Icons are padded to the standard slot width; custom content is measured at
/// whatever width it wants, which is what lets it sit in the bar at all.
class _ClusterItem extends StatelessWidget {
  const _ClusterItem({
    required this.item,
    required this.enabled,
    required this.slotExtent,
    this.axis = Axis.horizontal,
    this.tintColor,
    this.onMenuTap,
    this.onSheetTap,
  });

  final GlassBarActionItem item;
  final bool enabled;

  /// Tint colour forwarded from [GlassBarActionItem.tintColor].
  ///
  /// When non-null, the icon/label foreground is set to high-contrast white
  /// or black so content remains readable over the coloured glass capsule.
  final Color? tintColor;

  /// Length an icon is padded to along the bar, matching the group it sits
  /// in.
  final double slotExtent;

  /// The direction the group runs in.
  final Axis axis;

  /// Opens the capsule's pull-down.
  ///
  /// Supplied only for the one item acting as the menu trigger, and only on
  /// the side that can be tapped, so an outgoing item never reopens a menu on
  /// its way out.
  final VoidCallback? onMenuTap;

  /// Presents a [GlassBarItem.sheet]'s sheet out of the shell this item sits
  /// in. Supplied on the same terms as [onMenuTap].
  final void Function(GlassBarSheetItem item)? onSheetTap;

  @override
  Widget build(BuildContext context) {
    // Promoted to a local so the switch below and the sheet branch further
    // down can both narrow it.
    final item = this.item;
    final interactive = enabled && item.enabled;

    Widget slot(Widget icon) => axis == Axis.vertical
        ? SizedBox(height: slotExtent, child: Center(child: icon))
        : SizedBox(width: slotExtent, child: Center(child: icon));

    Widget content = switch (item) {
      GlassBarIconItem(:final icon) => slot(icon),
      GlassBarMenuItem(:final icon) => slot(icon),
      GlassBarSheetItem(:final icon) => slot(icon),
      GlassBarCustomItem(:final child) => child,
    };

    content = IconTheme.merge(
      data: IconThemeData(
        size: GlassNavPinnedMetrics.iconSize,
        // When a tint colour is active, flip the foreground to high-contrast
        // white or black so it remains readable over the coloured capsule.
        // Falls back to the standard CupertinoColors.label when untinted.
        color: tintColor != null
            ? (tintColor!.computeLuminance() > 0.35
                ? const Color(0xFF000000)
                : const Color(0xFFFFFFFF))
            : CupertinoColors.label.resolveFrom(context),
      ),
      child: content,
    );

    if (!item.enabled) {
      content = Opacity(opacity: 0.5, child: content);
    }

    // A sheet item morphs the whole shell, so the group presents it.
    final present = onSheetTap;
    final onTap = item is GlassBarSheetItem
        ? () => present == null ? item.onPresent(null) : present(item)
        : (onMenuTap ?? item.onTap);

    return Semantics(
      button: true,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: interactive ? onTap : null,
        child: content,
      ),
    );
  }
}
