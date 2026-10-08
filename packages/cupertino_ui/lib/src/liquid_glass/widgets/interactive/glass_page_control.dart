import 'package:flutter/cupertino.dart' show CupertinoColors;
import 'package:flutter/widgets.dart';

import '../../src/renderer/liquid_glass_renderer.dart';
import '../../types/glass_quality.dart';
import '../shared/glass_accessibility_scope.dart';
import 'glass_button.dart';

/// A glass morphism page control following iOS 26's `UIPageControl` design.
///
/// [GlassPageControl] renders a **glass capsule** (same height as
/// [GlassButton]) with dot indicators inside — matching the iOS 26 Weather,
/// Home, and Lock Screen page controls. Tapping the capsule triggers the same
/// glow-and-grow interaction as [GlassButton], with no drag/anchor-stretch.
///
/// ## Usage
///
/// ### Basic Page Control
/// ```dart
/// GlassPageControl(
///   count: 5,
///   currentPage: _currentPage,
///   onPageChanged: (page) => setState(() => _currentPage = page),
/// )
/// ```
///
/// ### With PageView
/// ```dart
/// Column(
///   children: [
///     Expanded(
///       child: PageView(
///         controller: _pageController,
///         onPageChanged: (page) => setState(() => _currentPage = page),
///         children: pages,
///       ),
///     ),
///     GlassPageControl(
///       count: pages.length,
///       currentPage: _currentPage,
///       onPageChanged: (page) {
///         _pageController.animateToPage(page,
///           duration: Duration(milliseconds: 300),
///           curve: Curves.easeInOut,
///         );
///       },
///     ),
///   ],
/// )
/// ```
///
/// ### With Leading Icon (like iOS Weather location arrow)
/// ```dart
/// GlassPageControl(
///   count: 5,
///   currentPage: _currentPage,
///   leadingIcon: Icon(CupertinoIcons.location_fill, size: 12),
/// )
/// ```
class GlassPageControl extends StatefulWidget {
  /// Creates a glass page control.
  const GlassPageControl({
    required this.count,
    required this.currentPage,
    super.key,
    this.onPageChanged,
    this.dotSize = 7.0,
    this.spacing = 7.0,
    this.activeColor,
    this.inactiveColor,
    this.leadingIcon,
    this.settings,
    this.quality,
    this.useOwnLayer = false,
    this.height = 56,
    this.animationDuration = const Duration(milliseconds: 250),
    this.animationCurve = Curves.easeOutCubic,
    this.semanticLabel,
  });

  // ===========================================================================
  // Data Properties
  // ===========================================================================

  /// Total number of pages.
  final int count;

  /// The currently active page (0-indexed).
  final int currentPage;

  /// Called when a dot is tapped.
  ///
  /// If null, the capsule still responds to press (glow + scale) but
  /// does not navigate.
  final ValueChanged<int>? onPageChanged;

  // ===========================================================================
  // Appearance Properties
  // ===========================================================================

  /// Diameter of each dot.
  ///
  /// Defaults to 7.0 (matching iOS 26).
  final double dotSize;

  /// Spacing between dots.
  ///
  /// Defaults to 7.0.
  final double spacing;

  /// Color of the active dot.
  ///
  /// If null, defaults to white.
  final Color? activeColor;

  /// Color of inactive dots.
  ///
  /// If null, defaults to white at 35% opacity.
  final Color? inactiveColor;

  /// Optional leading icon displayed before the dots.
  ///
  /// iOS Weather uses a location arrow icon to indicate the current
  /// location page. The icon is sized to match [dotSize].
  final Widget? leadingIcon;

  /// Height of the glass capsule.
  ///
  /// Defaults to 56 to match [GlassButton] height.
  final double height;

  // ===========================================================================
  // Glass Properties
  // ===========================================================================

  /// Glass effect settings for the capsule.
  ///
  /// If null, uses the same defaults as [GlassButton].
  final LiquidGlassSettings? settings;

  /// Rendering quality for the glass effect.
  ///
  /// If null, inherits from parent or defaults to [GlassQuality.standard].
  final GlassQuality? quality;

  /// Whether the glass capsule creates its own layer.
  ///
  /// Defaults to false (grouped mode — same as [GlassButton]).
  final bool useOwnLayer;

  // ===========================================================================
  // Animation Properties
  // ===========================================================================

  /// Duration of the dot transition animation.
  ///
  /// Defaults to 250ms.
  final Duration animationDuration;

  /// Curve for the dot transition animation.
  ///
  /// Defaults to [Curves.easeOutCubic].
  final Curve animationCurve;

  /// Overrides the VoiceOver / TalkBack announcement for the capsule.
  ///
  /// When null the default is `'Page N of M'` (1-indexed, e.g. `'Page 2 of 5'`).
  ///
  /// Set this for non-pagination domains:
  /// ```dart
  /// GlassPageControl(
  ///   count: slides.length,
  ///   currentPage: _current,
  ///   semanticLabel: 'Slide ${_current + 1} of ${slides.length}',
  ///   onPageChanged: _goTo,
  /// )
  /// ```
  final String? semanticLabel;

  @override
  State<GlassPageControl> createState() => _GlassPageControlState();
}

class _GlassPageControlState extends State<GlassPageControl>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _animation;
  int _previousPage = 0;

  // Active/inactive dot colors are resolved at build time from
  // CupertinoColors.label / .tertiaryLabel so they adapt to light/dark mode.

  @override
  void initState() {
    super.initState();
    _previousPage = widget.currentPage;
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    );
    _controller.value = 1.0; // Start fully settled
  }

  @override
  void didUpdateWidget(covariant GlassPageControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage) {
      _previousPage = oldWidget.currentPage;
      // Reduce Motion: the active dot moves at once.
      if (GlassAccessibilityData.of(context).reduceMotion) {
        _controller.value = 1.0;
      } else {
        _controller.forward(from: 0.0);
      }
    }
    if (oldWidget.animationDuration != widget.animationDuration) {
      _controller.duration = widget.animationDuration;
    }
    if (oldWidget.animationCurve != widget.animationCurve) {
      _animation.curve = widget.animationCurve;
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.count <= 0) return const SizedBox.shrink();

    final effectiveActiveColor =
        widget.activeColor ?? CupertinoColors.label.resolveFrom(context);
    final effectiveInactiveColor = widget.inactiveColor ??
        CupertinoColors.tertiaryLabel.resolveFrom(context);

    // Build the dot row content
    final dotsContent = AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Leading icon (e.g. location arrow)
            if (widget.leadingIcon != null) ...[
              SizedBox(
                width: widget.dotSize,
                height: widget.dotSize,
                child: FittedBox(child: widget.leadingIcon!),
              ),
              SizedBox(width: widget.spacing),
            ],
            // Dots
            ...List.generate(widget.count, (index) {
              final isActive = index == widget.currentPage;
              final wasPrevious = index == _previousPage;
              final t = _animation.value;

              // Animate dot scale
              double scale;
              if (isActive && wasPrevious) {
                scale = 1.0;
              } else if (isActive) {
                scale = _lerpDouble(0.7, 1.0, t);
              } else if (wasPrevious) {
                scale = _lerpDouble(1.0, 0.7, t);
              } else {
                scale = 0.7;
              }

              // Animate colour
              Color dotColor;
              if (isActive && wasPrevious) {
                dotColor = effectiveActiveColor;
              } else if (isActive) {
                dotColor = Color.lerp(
                      effectiveInactiveColor,
                      effectiveActiveColor,
                      t,
                    ) ??
                    effectiveActiveColor;
              } else if (wasPrevious) {
                dotColor = Color.lerp(
                      effectiveActiveColor,
                      effectiveInactiveColor,
                      t,
                    ) ??
                    effectiveInactiveColor;
              } else {
                dotColor = effectiveInactiveColor;
              }

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
                child: SizedBox(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  child: Center(
                    child: Container(
                      width: widget.dotSize * scale,
                      height: widget.dotSize * scale,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );

    // Use GlassButton.custom for the glass capsule — gives us the same
    // press glow + scale interaction as regular buttons, with no drag.
    final capsule = GlassButton.custom(
      onTap: () {
        // On tap, advance to next page (cycling)
        if (widget.onPageChanged != null) {
          final nextPage = (widget.currentPage + 1) % widget.count;
          widget.onPageChanged!(nextPage);
        }
      },
      height: widget.height,
      shape: const LiquidRoundedRectangle(borderRadius: 100),
      settings: widget.settings,
      quality: widget.quality,
      useOwnLayer: widget.useOwnLayer,
      // Same press effect as buttons, but no drag/anchor stretch
      interactionScale: 1.05,
      stretch: 0.0,
      anchorStretch: false,
      persistPressOnDrag: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: dotsContent,
      ),
    );

    // Wrap in a Semantics node so screen readers announce the current page.
    // The inner GlassButton has no label (custom child), so this outer node
    // is the sole announcement source — no double-reading occurs.
    final effectiveLabel = widget.semanticLabel ??
        'Page ${widget.currentPage + 1} of ${widget.count}';
    return Semantics(
      label: effectiveLabel,
      button: true,
      hint: widget.onPageChanged != null ? 'Tap to advance to next page' : null,
      child: capsule,
    );
  }

  static double _lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}
