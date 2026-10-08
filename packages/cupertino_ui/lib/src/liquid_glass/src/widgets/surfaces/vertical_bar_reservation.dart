import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../widgets/surfaces/glass_navigation_shell.dart';
import '../../../widgets/surfaces/glass_vertical_bar.dart';

/// Reserves the bottom of iPhone Duo's vertical bar strip for [child].
///
/// A tab bar or toolbar in the strip stacks up from the bottom while the
/// pinned chrome stacks down from the top, and neither is laid out by the
/// other: the chrome is drawn by the [GlassNavigationShell], the bars by their
/// routes. Natively the chrome gives way — the groups that no longer fit
/// collapse into a ••• menu — so the bar reports how much of the strip it
/// takes, measured from the screen's bottom edge, and the shell lays the
/// chrome out in what is left.
///
/// Only a bar on the current route reserves anything: a route covered by a
/// push keeps its bar mounted, but the strip is no longer its to take.
class VerticalBarBottomReservation extends StatefulWidget {
  /// Reserves [child]'s height, plus the strip's
  /// [GlassVerticalBarData.bottom] below it.
  const VerticalBarBottomReservation({super.key, required this.child});

  /// The bar, laid out at the bottom of the strip.
  final Widget child;

  @override
  State<VerticalBarBottomReservation> createState() =>
      _VerticalBarBottomReservationState();
}

class _VerticalBarBottomReservationState
    extends State<VerticalBarBottomReservation> {
  GlassNavigationShellState? _shell;
  double? _height;
  bool _current = true;
  GlassVerticalBarData? _bar;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shell = GlassNavigationShell.maybeOf(context);
    if (!identical(shell, _shell)) {
      _shell?.releaseVerticalBarBottom(this);
      _shell = shell;
    }
    _current = ModalRoute.of(context)?.isCurrent ?? true;
    _bar = GlassVerticalBar.maybeOf(context);
    _sync();
  }

  void _onHeight(double height) {
    if (!mounted || height == _height) return;
    _height = height;
    _sync();
  }

  void _sync() {
    final shell = _shell;
    final height = _height;
    if (shell == null) return;
    final bar = _bar;
    if (height == null || bar == null || !_current) {
      shell.releaseVerticalBarBottom(this);
    } else {
      shell.reserveVerticalBarBottom(this, height + bar.bottom);
    }
  }

  @override
  void dispose() {
    _shell?.releaseVerticalBarBottom(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _HeightReporter(onHeight: _onHeight, child: widget.child);
}

/// Reports its child's laid-out height after each layout that changes it.
class _HeightReporter extends SingleChildRenderObjectWidget {
  const _HeightReporter({required this.onHeight, super.child});

  final ValueChanged<double> onHeight;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderHeightReporter(onHeight);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderHeightReporter renderObject,
  ) {
    renderObject.onHeight = onHeight;
  }
}

class _RenderHeightReporter extends RenderProxyBox {
  _RenderHeightReporter(this.onHeight);

  ValueChanged<double> onHeight;
  double? _reported;

  @override
  void performLayout() {
    super.performLayout();
    final height = size.height;
    if (height == _reported) return;
    _reported = height;
    // Reported after the frame: the shell rebuilds its chrome in response,
    // which cannot happen in the middle of this layout.
    SchedulerBinding.instance.addPostFrameCallback((_) => onHeight(height));
  }
}
