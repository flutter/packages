// Scroll-driven minimize state machine for GlassTabBar.minimizable.
//
// The decision function ([GlassTabBarMinimizeController.handleSample]) takes a
// plain value object rather than a ScrollPosition, so every branch of the
// behaviour can be unit tested without a widget tree — the same constraint
// SearchableBottomBarController is written under.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/widgets.dart'
    show
        Axis,
        ScrollController,
        ScrollNotification,
        ScrollPosition,
        ScrollUpdateNotification,
        UserScrollNotification;

import 'glass_bar_minimize_behavior.dart';

// =============================================================================
// GlassTabBarScrollSample — one observation of a scroll view
// =============================================================================

/// A single sample of a scroll view's state, fed to
/// [GlassTabBarMinimizeController.handleSample].
///
/// Exists so the minimize decision can be driven from synthetic values in
/// tests, without a live [ScrollPosition].
@immutable
class GlassTabBarScrollSample {
  /// Creates a scroll sample.
  const GlassTabBarScrollSample({
    required this.pixels,
    required this.minScrollExtent,
    required this.maxScrollExtent,
    required this.viewportDimension,
    required this.direction,
    required this.outOfRange,
  });

  /// Reads the sample from a live scroll position.
  GlassTabBarScrollSample.fromPosition(ScrollPosition position)
      : pixels = position.pixels,
        minScrollExtent = position.minScrollExtent,
        maxScrollExtent = position.maxScrollExtent,
        viewportDimension = position.viewportDimension,
        direction = position.userScrollDirection,
        outOfRange = position.outOfRange;

  /// Current scroll offset.
  final double pixels;

  /// Offset of the start of the content.
  final double minScrollExtent;

  /// Offset of the end of the content.
  final double maxScrollExtent;

  /// Height of the viewport, used to recognise teleports.
  final double viewportDimension;

  /// The direction the user is scrolling in.
  ///
  /// [ScrollDirection.idle] means the offset changed without a scrolling
  /// activity behind it — a `jumpTo`, a `PageStorage` restore, a keyboard
  /// viewport inset, or a layout correction. See
  /// [GlassTabBarMinimizeController.handleSample].
  final ScrollDirection direction;

  /// Whether the offset is currently outside the content range (rubber-band).
  final bool outOfRange;
}

// =============================================================================
// GlassTabBarMinimizeController
// =============================================================================

/// Drives [GlassTabBar.minimizable]'s minimize state from scrolling — the
/// equivalent of SwiftUI's `.tabBarMinimizeBehavior(_:)`.
///
/// Create one per screen, give the bar both this controller and the scroll
/// view's [ScrollController], and dispose it in `State.dispose()`. The bar
/// reads its minimized state through the controller, so [GlassScaffold] stays
/// in sync with the bar's real height — including the bottom edge fade and,
/// with `extendBody: false`, the body inset.
///
/// ```dart
/// class _HomeState extends State<Home> {
///   final _scroll = ScrollController();
///   final _minimize = GlassTabBarMinimizeController(
///     behavior: GlassBarMinimizeBehavior.onScrollDown,
///   );
///
///   @override
///   void dispose() {
///     _minimize.dispose();
///     _scroll.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) => GlassScaffold(
///         body: ListView.builder(controller: _scroll, ...),
///         bottomBar: GlassTabBar.minimizable(
///           tabs: _tabs,
///           selectedIndex: _index,
///           onTabSelected: (i) => setState(() => _index = i),
///           minimizeController: _minimize,
///           scrollController: _scroll,
///           onMinimizedTabTap: _minimize.expand,
///         ),
///       );
/// }
/// ```
///
/// This controller **borrows** the [ScrollController] it observes and never
/// disposes it — that belongs to the scroll view.
class GlassTabBarMinimizeController extends ChangeNotifier {
  /// Creates a minimize controller.
  ///
  /// [behavior] defaults to [GlassBarMinimizeBehavior.automatic], which
  /// resolves to [GlassBarMinimizeBehavior.never] — opt in explicitly with
  /// [GlassBarMinimizeBehavior.onScrollDown].
  GlassTabBarMinimizeController({
    GlassBarMinimizeBehavior behavior = GlassBarMinimizeBehavior.automatic,
  }) : _behavior = behavior;

  // ── Thresholds ────────────────────────────────────────────────────────────
  //
  // The trigger is distance accumulated since the last direction reversal, NOT
  // a per-sample delta.
  //
  // A per-sample gate (`delta >= 12.0`, which the tab bar's since-removed
  // collapse-to-extra-button used) is really a test on v/f: a scroll listener
  // fires about once per frame, so the delta is velocity ÷ refresh rate. That
  // makes the activation velocity 720 px/s at 60 Hz but 1440 px/s on a 120 Hz
  // ProMotion display — and ProMotion switches rate adaptively, so it is not
  // even stable on one device. It also never fired at all on a slow deliberate
  // scroll, and fired spuriously on a dropped frame (one sample carrying three
  // frames of travel). That frame-rate coupling is why the pattern was pulled
  // in 1.0.0 as "unreliable on 120 Hz ProMotion displays".
  //
  // Accumulated distance has no such coupling: summing v/f over f·Δt samples
  // gives v·Δt. Same finger travel, same trigger, on every device and at every
  // refresh rate.
  //
  // Corollary, and the easy way to reintroduce the bug: never reset the
  // accumulator on a timer, and never derive a velocity from the samples.
  // Both put f back into the predicate.

  /// Downward travel, since the last direction reversal, that reads as intent
  /// to minimize.
  ///
  /// Roughly 1.5 lines of body text, or about 100 ms at a typical 200 px/s
  /// reading scroll: far enough that a thumb resting on a settling list cannot
  /// trip it, near enough that the bar is already shrinking before the first
  /// row leaves the viewport.
  static const double kMinimizeThreshold = 20.0;

  /// Upward travel that re-expands.
  ///
  /// Deliberately smaller than [kMinimizeThreshold]: getting your tabs back
  /// should be cheap, while losing them should take intent. The asymmetry also
  /// stops the two thresholds forming a symmetric dead-band, which makes a
  /// scrub up and down feel sticky.
  static const double kExpandThreshold = 12.0;

  /// Scrollable extent below which the content is treated as non-scrollable.
  ///
  /// Above [kMinimizeThreshold] on purpose — otherwise a page with 25 px of
  /// scroll could minimize and immediately hit the end, shrinking the bar to
  /// reveal nothing.
  static const double kMinScrollableExtent = 40.0;

  // ── State ─────────────────────────────────────────────────────────────────

  GlassBarMinimizeBehavior _behavior;
  bool _minimized = false;
  bool _disposed = false;

  /// Previous sampled offset. Null until the next sample establishes it.
  double? _baseline;

  /// Signed travel since the last direction reversal, in "minimizing is
  /// positive" space (see [_effectiveDelta]).
  double _accumulated = 0.0;

  ScrollController? _scrollController;

  /// Whether the bar is currently minimized.
  bool get minimized => _minimized;

  /// The scroll view currently being observed, if any.
  ScrollController? get scrollController => _scrollController;

  /// How scrolling maps to minimizing.
  GlassBarMinimizeBehavior get behavior => _behavior;

  /// Sets the behaviour. Switching to one that does not minimize expands the
  /// bar immediately, so it can never be left stranded.
  set behavior(GlassBarMinimizeBehavior value) {
    if (_behavior == value) return;
    _behavior = value;
    _accumulated = 0.0;
    if (!_minimizes) {
      _setMinimized(false);
    } else {
      notifyListeners();
    }
  }

  /// [behavior] with [GlassBarMinimizeBehavior.automatic] resolved.
  GlassBarMinimizeBehavior get resolvedBehavior =>
      _behavior == GlassBarMinimizeBehavior.automatic
          ? GlassBarMinimizeBehavior.never
          : _behavior;

  bool get _minimizes =>
      resolvedBehavior == GlassBarMinimizeBehavior.onScrollDown ||
      resolvedBehavior == GlassBarMinimizeBehavior.onScrollUp;

  // ── Imperative control ────────────────────────────────────────────────────

  /// Minimizes the bar.
  ///
  /// Does nothing when [resolvedBehavior] does not minimize.
  void minimize() {
    if (!_minimizes) return;
    _accumulated = 0.0;
    _setMinimized(true);
  }

  /// Expands the bar.
  ///
  /// Always allowed, whatever the behaviour — expanding can only restore the
  /// default state. Wire this to `onMinimizedTabTap` so the "bring my tabs
  /// back" tap and the scroll state machine agree; otherwise the tap would
  /// clear the app's flag while this controller still believed the bar was
  /// minimized, and the next downward scroll would appear to do nothing.
  void expand() {
    _accumulated = 0.0;
    _setMinimized(false);
  }

  // ── Attachment ────────────────────────────────────────────────────────────

  /// Observes [controller], replacing any previously attached one.
  ///
  /// Call this when the driving scroll view changes — on iOS each tab owns its
  /// own scroll view, and UIKit re-resolves `contentScrollView(for: .bottom)`
  /// on every tab change. Pass `null`, or use [detach], to stop observing.
  ///
  /// The minimized state is deliberately left alone: attaching happens during
  /// a build, so changing it here would have to notify listeners mid-build.
  /// Call [expand] from your `onTabSelected` if you want the bar to come back
  /// when the user switches tabs.
  void attach(ScrollController? controller) {
    if (_disposed || identical(controller, _scrollController)) return;
    // Safe even if the app disposed its ScrollController first —
    // ChangeNotifier.removeListener is documented to tolerate that.
    _scrollController?.removeListener(_onScroll);
    _scrollController = controller;
    // A delta measured across two different scroll views is meaningless, and
    // would read as one enormous jump.
    _baseline = null;
    _accumulated = 0.0;
    _scrollController?.addListener(_onScroll);
  }

  /// Stops observing the current scroll view. The bar keeps its current state.
  void detach() => attach(null);

  /// The attached position, or null when it cannot be read safely.
  ///
  /// [ScrollController.position] throws when the controller has more than one
  /// attached position, which happens for a few hundred milliseconds whenever
  /// two scroll views share a controller across an `AnimatedSwitcher`
  /// cross-fade or a `Navigator` transition. Not sampling during that window
  /// is the correct behaviour — `GlassScaffold` guards its header fade the
  /// same way.
  ScrollPosition? get _singlePosition {
    final controller = _scrollController;
    if (controller == null || !controller.hasClients) return null;
    if (controller.positions.length != 1) return null;
    return controller.positions.single;
  }

  void _onScroll() {
    if (_disposed) return;
    final position = _singlePosition;
    if (position == null) {
      _baseline = null;
      _accumulated = 0.0;
      return;
    }
    handleSample(GlassTabBarScrollSample.fromPosition(position));
  }

  // ── Notification driving ──────────────────────────────────────────────────

  /// Direction of the most recent [UserScrollNotification].
  ///
  /// [ScrollMetrics] carries no direction, and a [UserScrollNotification] is
  /// dispatched once per gesture rather than once per update, so the direction
  /// the state machine needs has to be remembered between the two.
  ScrollDirection _notificationDirection = ScrollDirection.idle;

  /// Feeds a [ScrollNotification] to the state machine, for hosts that observe
  /// scrolling with a [NotificationListener] rather than owning a
  /// [ScrollController].
  ///
  /// The alternative to [attach], for the shape [attach] cannot serve: an
  /// app-level scaffold wrapping arbitrary screen bodies has no way to reach
  /// whichever [ScrollController] the current screen happens to own, and on a
  /// tab bar each tab owns a different one. Use one source or the other —
  /// both at once counts every scroll twice.
  ///
  /// ```dart
  /// NotificationListener<ScrollNotification>(
  ///   onNotification: (notification) {
  ///     _minimize.handleNotification(notification);
  ///     return false; // let it keep bubbling
  ///   },
  ///   child: body,
  /// )
  /// ```
  ///
  /// Horizontal notifications are ignored, so a carousel in the body cannot
  /// minimize the bar. Every vertical scroll view under the listener does
  /// drive it, so scope the listener to the body you want followed.
  void handleNotification(ScrollNotification notification) {
    if (_disposed) return;
    final metrics = notification.metrics;
    if (metrics.axis != Axis.vertical) return;

    if (notification is UserScrollNotification) {
      _notificationDirection = notification.direction;
      return;
    }

    // Only an update carries an offset change. Start, end and overscroll
    // notifications would re-run the rules against an offset already sampled.
    if (notification is! ScrollUpdateNotification) return;

    handleSample(GlassTabBarScrollSample(
      pixels: metrics.pixels,
      minScrollExtent: metrics.minScrollExtent,
      maxScrollExtent: metrics.maxScrollExtent,
      viewportDimension: metrics.viewportDimension,
      direction: _notificationDirection,
      outOfRange: metrics.outOfRange,
    ));
  }

  // ── The decision function ─────────────────────────────────────────────────

  /// Feeds one scroll sample to the state machine.
  ///
  /// Pure with respect to Flutter, which is what makes it safe to call from
  /// anywhere: a host that observes scrolling some other way than owning a
  /// [ScrollController] can build its own samples and drive the controller
  /// directly. [handleNotification] is the ready-made path for the common
  /// case of a [NotificationListener].
  ///
  /// The order of the rules matters, and each early return also decides
  /// whether the accumulator survives.
  void handleSample(GlassTabBarScrollSample sample) {
    if (!_minimizes) return;

    final previous = _baseline;
    _baseline = sample.pixels;

    // 1. Content that cannot scroll never minimizes — and content that shrinks
    //    below the threshold while minimized must expand, or the bar is
    //    stranded as a circle with nothing to scroll back.
    if (sample.maxScrollExtent - sample.minScrollExtent <
        kMinScrollableExtent) {
      _accumulated = 0.0;
      _setMinimized(false);
      return;
    }

    // 2. At the resting edge, always expand — no threshold, no accumulation.
    //    `<=` rather than `==` so top rubber-band counts as "at the top":
    //    outOfRange is strict, so pixels == 0.0 is not out of range and would
    //    otherwise fall through to the accumulator below.
    if (_atRestingEdge(sample)) {
      _accumulated = 0.0;
      _setMinimized(false);
      return;
    }

    // 3. First sample after attaching — establish the baseline, decide
    //    nothing. This is what stops a restored scroll offset from minimizing
    //    the bar before the user has touched anything.
    if (previous == null) return;

    final delta = sample.pixels - previous;

    // 4. Not a user scroll at all: jumpTo, a PageStorage restore, the keyboard
    //    changing the viewport inset, or a layout correction. None of these
    //    begin a scrolling activity, so the direction is still idle — whereas
    //    a real drag, and the entire momentum phase after it, is not.
    if (sample.direction == ScrollDirection.idle) {
      _accumulated = 0.0;
      return;
    }

    // 5. A teleport rather than a scroll. Covers animateTo, which keeps a
    //    stale non-idle direction, and single-frame content-dimension jumps.
    if (delta.abs() > sample.viewportDimension * 0.5) {
      _accumulated = 0.0;
      return;
    }

    // 6. Rubber-band at the far edge: the offset keeps moving with no intent
    //    behind it. This must sit after the idle check and before accumulation
    //    — during a bounce the delta reverses sign while the direction is
    //    still the direction of the fling, which would otherwise read as a
    //    scroll back the other way and expand the bar.
    if (sample.outOfRange) {
      _accumulated = 0.0;
      return;
    }

    // 7. Accumulate since the last reversal.
    final effective = _effectiveDelta(delta);
    if (effective == 0.0) return;
    if (effective.sign != _accumulated.sign) _accumulated = 0.0;
    _accumulated += effective;

    if (_accumulated >= kMinimizeThreshold) {
      _accumulated = 0.0;
      _setMinimized(true);
    } else if (_accumulated <= -kExpandThreshold) {
      _accumulated = 0.0;
      _setMinimized(false);
    }
  }

  /// Maps a raw offset delta into "minimizing is positive" space.
  ///
  /// [GlassBarMinimizeBehavior.onScrollUp] is the same state machine with the
  /// input sign flipped — never a second code path.
  double _effectiveDelta(double delta) =>
      resolvedBehavior == GlassBarMinimizeBehavior.onScrollUp ? -delta : delta;

  /// Whether the content is at the edge it rests at.
  ///
  /// For [GlassBarMinimizeBehavior.onScrollDown] that is the start of the
  /// content. For [GlassBarMinimizeBehavior.onScrollUp] — recommended for
  /// bottom-aligned content — it is the end.
  bool _atRestingEdge(GlassTabBarScrollSample sample) =>
      resolvedBehavior == GlassBarMinimizeBehavior.onScrollUp
          ? sample.pixels >= sample.maxScrollExtent
          : sample.pixels <= sample.minScrollExtent;

  void _setMinimized(bool value) {
    if (_minimized == value) return; // idempotent — no notify storm
    _minimized = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_onScroll);
    _scrollController = null;
    _disposed = true;
    super.dispose();
  }
}
