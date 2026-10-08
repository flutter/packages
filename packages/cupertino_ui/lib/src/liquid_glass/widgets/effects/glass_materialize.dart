import 'package:flutter/widgets.dart';

import '../../constants/glass_defaults.dart';
import '../shared/glass_accessibility_scope.dart';
import 'shared/glass_materialize_effect.dart';

// =============================================================================
// GlassEffectTransition
// =============================================================================

/// How glass chrome transitions when it appears or disappears, mirroring
/// SwiftUI's `GlassEffectTransition` on iOS 26.
///
/// Consumed by [GlassNavigationShell] for the pinned navigation chrome; the
/// standalone [GlassMaterialize] and [GlassMaterializeTransition] widgets
/// always play the materialize effect and need no selection.
enum GlassEffectTransition {
  /// Fade + gaussian blur + subtle scale — SwiftUI's `.materialize`.
  ///
  /// The glass fades up out of nothing, settling inward from slightly
  /// oversized, and its content sharpens last; on the way out the content
  /// blurs away first and the glass swells and dissolves after it.
  materialize,

  /// No transition — SwiftUI's `.identity`. The chrome switches once at the
  /// transition midpoint, exactly as it did before materialize existed.
  identity,
}

/// How pinned chrome transitions once an interactive back-swipe commits.
enum GlassSwipeCommitTransition {
  /// The shell's [GlassEffectTransition], as for any other pop.
  effect,

  /// A short plain cross-fade without blur, scale or swell — what iOS 26
  /// does after a swipe.
  crossFade,
}

// =============================================================================
// GlassMaterializeTransition
// =============================================================================

/// Materializes a glass subtree in or out, driven by an explicit [animation]
/// — the [FadeTransition] idiom, for wiring into a route transition, an
/// [AnimationController], or an [AnimatedSwitcher].
///
/// This is SwiftUI's `glassEffectTransition(.materialize)` from iOS 26: the
/// glass fades up as it settles inward from slightly oversized, and its
/// content sharpens only after the shape has resolved. In reverse the order
/// flips — content first, glass after — which this widget selects from
/// [animation]'s status, so a reversed controller plays a true exit rather
/// than a rewound entrance.
///
/// An ancestor [FadeTransition] or [ImageFiltered] cannot produce this: a
/// glass backdrop pass renders fully or not at all, so fading the layer pops.
/// The effect instead drives the shader's own visibility uniforms, which is
/// the one fade the backdrop pass honours — any glass surface in [child]
/// participates automatically, whichever rendering tier it is on.
///
/// ```dart
/// AnimatedSwitcher(
///   duration: GlassDefaults.materializeDuration,
///   reverseDuration: GlassDefaults.dematerializeDuration,
///   transitionBuilder: GlassMaterializeTransition.switcherBuilder,
///   child: chip,
/// )
/// ```
///
/// For the common show/hide case driven by a boolean, use [GlassMaterialize].
class GlassMaterializeTransition extends StatelessWidget {
  /// Creates a materialize transition driven by [animation].
  const GlassMaterializeTransition({
    required this.animation,
    required this.child,
    this.alignment = Alignment.center,
    this.scaleFrom = 1.15,
    this.contentSigma = 8.0,
    super.key,
  });

  /// Drives the transition: 0.0 = fully dematerialized, 1.0 = at rest.
  ///
  /// While the status is [AnimationStatus.reverse] the exit choreography
  /// plays (content leaves first, glass after); otherwise the entrance.
  final Animation<double> animation;

  /// The subtree containing the glass to materialize.
  final Widget child;

  /// Where the scale converges, matching [Transform.scale]'s alignment.
  ///
  /// Defaults to [Alignment.center]; a nav-bar button pinned to an edge
  /// reads better converging toward that edge.
  final Alignment alignment;

  /// Scale at full dematerialization, from the native capture (~1.15).
  ///
  /// Greater than one: the surface swells as it leaves and settles inward as
  /// it arrives, which is the direction iOS moves. Pass 1.0 to disable the
  /// scale entirely.
  final double scaleFrom;

  /// Peak gaussian sigma on the glass content, in logical pixels.
  final double contentSigma;

  /// An [AnimatedSwitcher.transitionBuilder] that materializes each child.
  static Widget switcherBuilder(Widget child, Animation<double> animation) =>
      GlassMaterializeTransition(animation: animation, child: child);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) => GlassMaterializeEffect(
        progress: animation.value,
        profile: animation.status == AnimationStatus.reverse
            ? GlassMaterializeProfile.exit
            : GlassMaterializeProfile.entrance,
        alignment: alignment,
        scaleFrom: scaleFrom,
        contentSigma: contentSigma,
        child: child!,
      ),
    );
  }
}

// =============================================================================
// GlassMaterialize
// =============================================================================

/// Shows or hides a glass subtree with the materialize effect — the
/// [AnimatedOpacity] idiom: flip [visible] and the widget animates itself.
///
/// ```dart
/// GlassMaterialize(
///   visible: showSearch,
///   child: GlassButton.icon(icon: CupertinoIcons.search, onPressed: ...),
/// )
/// ```
///
/// The entrance and exit run at the asymmetric durations measured from the
/// native transition ([GlassDefaults.materializeDuration] /
/// [GlassDefaults.dematerializeDuration]). There is no `curve` parameter:
/// the choreography is a fixed set of staggered sub-curves (glass and
/// content resolve at different times), which a single caller-supplied curve
/// would scramble.
///
/// Under reduce motion the effect collapses to a quick cross-dissolve at
/// [GlassDefaults.animationDurationFast] — a fade is not motion.
///
/// See [GlassMaterializeTransition] for the explicit, animation-driven form
/// and the full description of the effect.
class GlassMaterialize extends StatefulWidget {
  /// Creates a widget that shows or hides its glass [child] with the
  /// materialize effect.
  const GlassMaterialize({
    required this.visible,
    required this.child,
    this.duration = GlassDefaults.materializeDuration,
    this.exitDuration = GlassDefaults.dematerializeDuration,
    this.alignment = Alignment.center,
    this.scaleFrom = 1.15,
    this.contentSigma = 8.0,
    this.maintainState = true,
    this.onEnd,
    super.key,
  });

  /// Whether the subtree is shown. Changing this starts the transition.
  final bool visible;

  /// The subtree containing the glass to materialize.
  final Widget child;

  /// Duration of the entrance.
  final Duration duration;

  /// Duration of the exit — the native dematerialize runs noticeably longer
  /// than its entrance, so the two are configured separately.
  final Duration exitDuration;

  /// Where the scale converges, matching [Transform.scale]'s alignment.
  final Alignment alignment;

  /// Scale at full dematerialization; 1.0 disables the scale entirely.
  final double scaleFrom;

  /// Peak gaussian sigma on the glass content, in logical pixels.
  final double contentSigma;

  /// Whether the subtree stays mounted while fully hidden.
  ///
  /// True (the default) is cheap — a fully dematerialized glass surface
  /// skips its render pass entirely — and keeps any state in [child] alive.
  /// Pass false to remove the subtree once the exit settles.
  final bool maintainState;

  /// Called when a transition settles, in either direction.
  final VoidCallback? onEnd;

  @override
  State<GlassMaterialize> createState() => _GlassMaterializeState();
}

class _GlassMaterializeState extends State<GlassMaterialize>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: widget.visible ? 1.0 : 0.0,
  );

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener(_handleStatusChange);
  }

  @override
  void didUpdateWidget(GlassMaterialize oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      // Reduce motion shortens the (now cross-dissolve) transition rather
      // than skipping it: an instant swap is exactly the pop this widget
      // exists to remove.
      final reduceMotion = GlassAccessibilityData.of(context).reduceMotion;
      if (widget.visible) {
        _controller.animateTo(
          1.0,
          duration: reduceMotion
              ? GlassDefaults.animationDurationFast
              : widget.duration,
        );
      } else {
        _controller.animateBack(
          0.0,
          duration: reduceMotion
              ? GlassDefaults.animationDurationFast
              : widget.exitDuration,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      widget.onEnd?.call();
      // Rebuild so a maintainState: false subtree is released now that the
      // exit has settled (and nothing pops: the glass is already invisible).
      if (!widget.maintainState) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.maintainState &&
        !widget.visible &&
        _controller.status == AnimationStatus.dismissed) {
      return const SizedBox.shrink();
    }
    return GlassMaterializeTransition(
      animation: _controller,
      alignment: widget.alignment,
      scaleFrom: widget.scaleFrom,
      contentSigma: widget.contentSigma,
      child: widget.child,
    );
  }
}
