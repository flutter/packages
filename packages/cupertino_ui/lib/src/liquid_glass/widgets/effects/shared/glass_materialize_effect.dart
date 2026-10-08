// NOT part of the public API — do not export from liquid_glass_widgets.dart.
//
// The progress-driven core of the materialize transition. The public widgets
// in glass_materialize.dart and the pinned navigation host both render
// through this; it exists separately because the host must drive it as a pure
// function of route progress (a controller could not scrub a back-swipe),
// while the public widgets own the [Animation] that produces that progress.
library;

import 'package:flutter/widgets.dart';

import '../../../src/renderer/liquid_glass_renderer.dart';
import '../../shared/glass_accessibility_scope.dart';

/// Which side of the materialize choreography a subtree is playing.
///
/// The two are not mirror images, matching the native transition: an
/// entrance resolves the glass early and lets the content sharpen last,
/// while an exit empties the content first and dissolves the glass after.
/// A single [GlassMaterializeEffect.progress] axis (0 = dematerialized,
/// 1 = at rest) is traversed in either direction, so a scrubbed or cancelled
/// transition rewinds the same choreography rather than snapping to the
/// other profile.
enum GlassMaterializeProfile {
  /// The subtree is appearing: glass resolves first, content sharpens last.
  entrance,

  /// The subtree is disappearing: content leaves first, glass dissolves
  /// after — the circle is briefly visibly empty, as on iOS 26.
  exit,
}

// =============================================================================
// Choreography
// =============================================================================

/// The sub-curves of the materialize choreography over one progress axis.
///
/// Tuned against a 120fps capture of iOS 26's
/// `glassEffectTransition(.materialize)` on the native navigation bar.
abstract final class GlassMaterializeChoreography {
  /// Glass channel of an entrance: resolved just short of the end, so the
  /// shape exists before the icon does.
  ///
  /// Linear, like every channel here — [Interval]'s own default. The native
  /// transition moves its glass at a near-constant rate, and both ways of
  /// departing from that were visible side by side: an ease-*out* starts at
  /// 3× and popped the surface in before drifting, while an ease-*in* is so
  /// flat off the line that the surface visibly started after the native
  /// one. A symmetric S-curve does both — it ran ahead through the middle
  /// and then idled at the top.
  static const Interval entranceGlass = Interval(0.0, 0.92);

  /// Content channel of an entrance: starts after the glass has begun to
  /// form and sharpens right up to the end.
  ///
  /// The late start is what makes the icon lag its shell — the native icon
  /// stays soft well after the glass has formed and only resolves at the
  /// very end. An eased curve on top of it cleared the blur through the
  /// middle and read as too brief.
  static const Interval entranceContent = Interval(0.35, 1.0);

  /// Glass channel of an exit: a steady dissolve across the whole axis.
  ///
  /// The full range, unlike [entranceGlass]: cutting it short finished the
  /// dissolve before the native one had.
  static const Interval exitGlass = Interval(0.0, 1.0);

  /// Content channel of an exit: gone by 0.45, while [exitGlass] is still
  /// well above zero — the visibly empty shell the native bar shows.
  ///
  /// This axis is walked from 1.0 downwards, so the interval's *upper* bound
  /// is where the exit begins: the icon starts softening on the very first
  /// frame and is out by 0.45, with the shell still above half.
  static const Interval exitContent = Interval(0.45, 1.0);
}

// =============================================================================
// Effect
// =============================================================================

/// Renders [child] at a point along the materialize choreography.
///
/// [progress] 0.0 is fully dematerialized, 1.0 is at rest. The widget builds
/// the same tree shape at every value — a self-scale scope, a scale
/// transform and a [GlassMaterializeScope], all at identity when resting —
/// so the glass shells below it never remount as a transition starts or
/// settles. What varies is only the scope's per-frame values, which the
/// glass surfaces resolve themselves (see [GlassMaterializeScope]).
///
/// Under reduce motion both channels collapse to a plain cross-dissolve of
/// [progress]: no scale, no gaussian blur, just the shader's visibility fade
/// — a fade is not motion, and matches how iOS treats the native transition.
class GlassMaterializeEffect extends StatelessWidget {
  /// Renders [child] at [progress] along the [profile] choreography.
  const GlassMaterializeEffect({
    required this.progress,
    required this.profile,
    required this.child,
    this.alignment = Alignment.center,
    this.scaleFrom = 1.0,
    this.contentSigma = 8.0,
    this.plain = false,
    super.key,
  });

  /// How materialized the subtree is: 0.0 = fully dematerialized, 1.0 = at
  /// rest.
  final double progress;

  /// Which side of the choreography [progress] traverses.
  final GlassMaterializeProfile profile;

  /// The subtree containing the glass to materialize.
  final Widget child;

  /// Where the scale converges, matching [Transform.scale]'s alignment.
  final Alignment alignment;

  /// Scale at full dematerialization; 1.0 disables the scale entirely.
  final double scaleFrom;

  /// Peak gaussian sigma on the glass content, in logical pixels.
  final double contentSigma;

  /// Plays [progress] as the plain cross-dissolve of reduce motion.
  final bool plain;

  @override
  Widget build(BuildContext context) {
    final t = progress.clamp(0.0, 1.0);
    final reduceMotion = GlassAccessibilityData.of(context).reduceMotion;

    final double glass;
    final double content;
    final double sigma;
    final double scale;
    if (reduceMotion || plain) {
      glass = t;
      content = t;
      sigma = 0.0;
      scale = 1.0;
    } else {
      switch (profile) {
        case GlassMaterializeProfile.entrance:
          glass = GlassMaterializeChoreography.entranceGlass.transform(t);
          content = GlassMaterializeChoreography.entranceContent.transform(t);
        case GlassMaterializeProfile.exit:
          glass = GlassMaterializeChoreography.exitGlass.transform(t);
          content = GlassMaterializeChoreography.exitContent.transform(t);
      }
      sigma = contentSigma * (1.0 - content);
      // The scale deliberately has no curve of its own: it rides whichever
      // glass channel is playing, so the surface arrives at its natural size
      // at the same moment it arrives at full strength. Given its own
      // symmetric curve it settled about three quarters of the way in and
      // then sat there while the glass was still fading up — the container
      // reached its normal state first, which reads as two animations.
      scale = scaleFrom + (1.0 - scaleFrom) * glass;
    }

    return LiquidGlassSelfScaleScope(
      // The backdrop holds still while the effect scales the glass, so the
      // shader must follow the live transform rather than freeze its UVs.
      // Only a scale-down triggers that freeze, so this is inert for the
      // default swell; it matters when a caller passes a scaleFrom below 1.
      selfScaled: scale < LiquidGlassSelfScaleScope.freezeScaleThreshold,
      child: Transform.scale(
        scale: scale,
        alignment: alignment,
        child: GlassMaterializeScope(
          glassProgress: glass,
          contentOpacity: content,
          contentSigma: sigma,
          child: child,
        ),
      ),
    );
  }
}
