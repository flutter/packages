import 'package:flutter/widgets.dart';

import 'glass_backdrop_group_boundary.dart';

/// Premium glass surfaces that read the backdrop together, in one pass.
///
/// On Impeller every [BackdropFilter] ends the render pass and copies the
/// whole screen before it runs, however small the glass. Premium glass has
/// two of these per surface (the blur, or the iOS 27 frost with its weight,
/// and the refraction shader), so six surfaces cost a dozen full-screen
/// copies a frame. Inside a [GlassBackdropGroup] the surfaces share one
/// backdrop read for the blur and the frost, and where their filters match
/// (the same settings) the engine runs that filter once for all of them.
/// Only the refraction pass stays per surface. This is the same idea as
/// SwiftUI's `GlassEffectContainer`, which renders its glass "together,
/// improving rendering performance".
///
/// `GlassTabBar` and `GlassAppBar` group their own glass already (see their
/// `groupBackdrop`), and join a group of yours when they sit inside one, so
/// a group around both bars makes them share one read. Around other glass
/// that sits side by side over content, like a toolbar of your own, add one
/// yourself:
///
/// ```dart
/// GlassBackdropGroup(
///   child: Row(children: [GlassButton(...), GlassButton(...)]),
/// )
/// ```
///
/// Two things change for the glass inside:
///
/// - **Glass doesn't see glass.** The shared read happens when the first
///   surface of the group paints. A surface that lies over another surface
///   of the same group shows the content behind both instead of the glass
///   below it, and so does anything painted between the two. Keep
///   overlapping glass out of the group, with `enabled: false` around it.
///   Glass inside the content of another glass surface, or under an
///   `Opacity`, `FadeTransition` or `AnimatedOpacity` (at any value, fully
///   opaque included), a shader mask or a save-layer clip, stays out of the
///   group on its own, since it is or may be drawn into a render pass of its
///   own.
/// - **The frost doesn't see what the glass paints inside itself.** The
///   frost's cloud is blurred from the shared read, so content a glass
///   surface draws into its own glass layer isn't part of it. The sharp
///   content itself is unaffected.
///
/// Wrap the glass of one screen, such as its bars, rather than a `Navigator`
/// or a tab stack: glass on routes or tabs that are kept alive offstage
/// still counts as a member, so a surface that is alone on screen may take
/// the shared path for nothing.
///
/// A group with a single surface in it changes nothing. Without Impeller
/// (web, Skia) the group has no effect.
class GlassBackdropGroup extends StatefulWidget {
  /// Lets the premium glass in [child] read the backdrop together, or, with
  /// [enabled] false, keeps it out of any group further up.
  const GlassBackdropGroup({
    required this.child,
    this.enabled = true,
    this.joinEnclosing = false,
    super.key,
  });

  /// The subtree whose premium glass shares the backdrop read.
  final Widget child;

  /// Whether [child] shares a backdrop read. False keeps the glass in [child]
  /// out of an enclosing group, e.g. an indicator that lies over the bar it
  /// belongs to.
  final bool enabled;

  /// Whether [child] joins an enabled group further up instead of starting
  /// a group of its own. Without one it starts its own, as usual. The bars
  /// set this, so a [GlassBackdropGroup] around several bars makes them one
  /// group.
  final bool joinEnclosing;

  /// The key the premium glass under [context] shares its backdrop read
  /// through, or null outside a [GlassBackdropGroup] or inside a disabled one.
  static BackdropKey? keyOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_GlassBackdropGroupScope>()
      ?.backdropKey;

  @override
  State<GlassBackdropGroup> createState() => _GlassBackdropGroupState();
}

class _GlassBackdropGroupState extends State<GlassBackdropGroup> {
  final BackdropKey _key = BackdropKey();

  @override
  Widget build(BuildContext context) {
    final enclosing = widget.enabled && widget.joinEnclosing
        ? GlassBackdropGroup.keyOf(context)
        : null;
    return _GlassBackdropGroupScope(
      backdropKey: widget.enabled ? enclosing ?? _key : null,
      // Always there, so switching [enabled] or joining keeps the subtree's
      // state. A boundary that joins lets its members walk on up.
      child: GlassBackdropGroupBoundary(
        startsGroup: enclosing == null,
        child: widget.child,
      ),
    );
  }
}

class _GlassBackdropGroupScope extends InheritedWidget {
  const _GlassBackdropGroupScope({
    required this.backdropKey,
    required super.child,
  });

  final BackdropKey? backdropKey;

  @override
  bool updateShouldNotify(_GlassBackdropGroupScope oldWidget) =>
      backdropKey != oldWidget.backdropKey;
}
