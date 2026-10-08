// ignore_for_file: public_member_api_docs
// A PreferredSizeWidget whose preferred size can change without the widget
// instance being replaced.
//
// Do NOT import this file directly — it is an internal contract between
// [GlassScaffold] and the bars it hosts.

import 'package:flutter/widgets.dart';

/// A [PreferredSizeWidget] whose [PreferredSizeWidget.preferredSize] can change
/// while the widget instance stays the same.
///
/// [GlassScaffold] reads its bars' `preferredSize` during its own `build` to
/// derive the body inset and the edge-fade extents. A bar that changes height
/// from internal state — a tab bar minimizing on scroll, say — would otherwise
/// leave those values stale, because nothing marks the scaffold as needing a
/// rebuild.
///
/// A bar that implements this returns the [Listenable] it changes size in
/// response to; the scaffold subscribes and re-reads the size when it fires.
/// Returning `null` means the size is fixed for the lifetime of the widget,
/// and the scaffold does no extra work.
abstract mixin class GlassDynamicPreferredSize implements PreferredSizeWidget {
  /// Fires whenever [PreferredSizeWidget.preferredSize] may have changed, or
  /// `null` when the size cannot change on its own.
  Listenable? get preferredSizeListenable;
}
