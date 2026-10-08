/// How a bar minimizes in response to scrolling.
///
/// Mirrors SwiftUI's `TabBarMinimizeBehavior` and UIKit's
/// `UITabBarController.MinimizeBehavior`, one case for one case.
///
/// Pass to a [GlassTabBarMinimizeController] and drive
/// [GlassTabBar.minimizable] from it:
///
/// ```dart
/// final _minimize = GlassTabBarMinimizeController(
///   behavior: GlassBarMinimizeBehavior.onScrollDown,
/// );
/// ```
///
/// On iOS, minimizing is an **iPhone-only** behaviour — the iPad tab bar is a
/// top bar and never minimizes. This package does not gate on platform or
/// screen size: [GlassTabBar.minimizable] is a bottom bar by construction, and
/// a behaviour that silently switches itself off on a large screen is far
/// harder to debug than one that always does what it says. If you want iPad
/// parity, choose a different surface for the regular size class rather than
/// relying on the minimize disabling itself.
enum GlassBarMinimizeBehavior {
  /// Resolves to the system default minimize behaviour.
  ///
  /// Apple documents `.automatic` only as "the system default" and does not
  /// say what it resolves to, nor guarantee it stays fixed. On iOS 26 it is
  /// *observed* to mean no minimization on iPhone, so this package resolves
  /// [automatic] to [never] — matching what a user sees on device today, and
  /// keeping the default non-breaking for bars that never opted in.
  ///
  /// Because that resolution is an observation rather than a documented
  /// contract, opt in explicitly with [onScrollDown] rather than relying on
  /// it.
  automatic,

  /// The bar does not minimize.
  never,

  /// The bar minimizes when scrolling down, and expands when scrolling back
  /// up.
  onScrollDown,

  /// The bar minimizes when scrolling up, and expands when scrolling back
  /// down.
  ///
  /// Recommended when the scroll view's content is aligned to the bottom — a
  /// chat transcript, a log — where the resting position is the end of the
  /// content rather than the start.
  onScrollUp,
}
