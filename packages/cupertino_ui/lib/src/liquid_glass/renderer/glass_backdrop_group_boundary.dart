import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../engine/render_liquid_glass_geometry.dart';

/// Marks where a [GlassBackdropGroup] starts in the render tree, and counts
/// the glass layers that share its backdrop read.
///
/// Impeller copies a shared backdrop once per frame, from the render pass of
/// the first filter that uses the key (`Canvas::SaveLayer`, `canvas.cc`). A
/// member drawn inside a save layer the others are not in (a fade, a shader
/// mask, the content of another glass surface) would read the wrong pass, so
/// a member checks the path up to here before it joins (see
/// [opensRenderPassBelow]). And the group only pays off with two members: on
/// its own a member folds its frost weight into the frost filter for nothing,
/// which costs more than the separate pass.
class GlassBackdropGroupBoundary extends SingleChildRenderObjectWidget {
  /// Marks the start of a group around [child], or, with [startsGroup]
  /// false, a group that joins the one further up.
  const GlassBackdropGroupBoundary({
    this.startsGroup = true,
    super.key,
    super.child,
  });

  /// Whether the group starts here. False when it joins an enclosing group,
  /// whose boundary then counts the members.
  final bool startsGroup;

  @override
  RenderGlassBackdropGroupBoundary createRenderObject(BuildContext context) =>
      RenderGlassBackdropGroupBoundary(startsGroup: startsGroup);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderGlassBackdropGroupBoundary renderObject,
  ) {
    renderObject.startsGroup = startsGroup;
  }
}

/// The render object of a [GlassBackdropGroupBoundary].
class RenderGlassBackdropGroupBoundary extends RenderProxyBox {
  /// Creates the boundary of a group, see [startsGroup].
  RenderGlassBackdropGroupBoundary({bool startsGroup = true})
      : _startsGroup = startsGroup;

  final Set<RenderObject> _members = {};
  bool _repaintScheduled = false;

  /// Whether the group starts here, or joins the one further up.
  bool get startsGroup => _startsGroup;
  bool _startsGroup;
  set startsGroup(bool value) {
    if (_startsGroup == value) return;
    _startsGroup = value;
    // The members move to the other boundary when they next paint.
    _repaintMembers();
  }

  /// How many glass layers share the group's backdrop read right now.
  int get memberCount => _members.length;

  /// Whether [member] currently shares the group's backdrop read.
  bool contains(RenderObject member) => _members.contains(member);

  /// Adds [member]. The others repaint, since whether they share depends on
  /// how many there are.
  void join(RenderObject member) {
    if (_members.add(member)) _repaintMembers();
  }

  /// Removes [member], and repaints the others.
  void leave(RenderObject member) {
    if (_members.remove(member)) _repaintMembers();
  }

  // Joins and leaves happen while painting, where marking another render
  // object for paint is not allowed, so the repaint waits for the frame to end.
  void _repaintMembers() {
    if (_repaintScheduled) return;
    _repaintScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _repaintScheduled = false;
      for (final member in _members) {
        if (member.attached) member.markNeedsPaint();
      }
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  @override
  void detach() {
    _members.clear();
    super.detach();
  }
}

/// The group [member] belongs to, or null when there is none between it and
/// the root, or when a render pass of its own opens between the two (see
/// [opensRenderPassBelow]). Boundaries that join an enclosing group are
/// passed on the way up.
RenderGlassBackdropGroupBoundary? enclosingBackdropGroup(RenderObject member) {
  RenderObject? node = member.parent;
  while (node != null) {
    if (node is RenderGlassBackdropGroupBoundary && node.startsGroup) {
      return node;
    }
    if (opensRenderPassBelow(node)) return null;
    node = node.parent;
  }
  return null;
}

/// Whether [node] draws, or may start drawing, its subtree into a save layer
/// of its own, which on Impeller is a render pass of its own.
///
/// These are the framework's save layers that can stand between glass and
/// its group: an opacity, a shader mask, a backdrop filter, a clip with
/// [Clip.antiAliasWithSaveLayer], and the content of a glass surface, which
/// is drawn inside that surface's backdrop filters.
///
/// An opacity counts at any value, 1 included. A member only checks this
/// path when it paints, and glass paints below a repaint boundary: when a
/// fade starts after the first paint (1 → 0.99), the framework re-composites
/// the member's cached layer inside the new opacity layer without painting
/// it again, so a member that joined at 1 would keep the group's key in the
/// wrong pass.
bool opensRenderPassBelow(RenderObject node) {
  bool saves(Clip clip) => clip == Clip.antiAliasWithSaveLayer;
  return switch (node) {
    RenderOpacity() ||
    RenderAnimatedOpacityMixin() ||
    RenderSliverOpacity() ||
    RenderShaderMask() ||
    RenderBackdropFilter() =>
      true,
    RenderLiquidGlassGeometry() => true,
    RenderClipRect(:final clipBehavior) => saves(clipBehavior),
    RenderClipRRect(:final clipBehavior) => saves(clipBehavior),
    RenderClipRSuperellipse(:final clipBehavior) => saves(clipBehavior),
    RenderClipOval(:final clipBehavior) => saves(clipBehavior),
    RenderClipPath(:final clipBehavior) => saves(clipBehavior),
    RenderPhysicalModel(:final clipBehavior) => saves(clipBehavior),
    RenderPhysicalShape(:final clipBehavior) => saves(clipBehavior),
    _ => false,
  };
}
