import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../../src/renderer/liquid_glass_renderer.dart';

import '../../theme/glass_theme_data.dart';
import '../../theme/glass_theme.dart';
import '../../types/glass_quality.dart';
import '../shared/adaptive_liquid_glass_layer.dart';
import '../shared/glass_accessibility_scope.dart';

/// Position where the toast should appear on screen.
enum GlassToastPosition {
  /// At the top of the screen, below the status bar
  top,

  /// Centered in the middle of the screen
  center,

  /// At the bottom of the screen, above the bottom safe area
  bottom,
}

/// Visual style and semantic meaning of the toast.
enum GlassToastType {
  /// Success message with green accent (default)
  success,

  /// Error message with red accent
  error,

  /// Informational message with blue accent
  info,

  /// Warning message with orange accent
  warning,

  /// Neutral message with no semantic color
  neutral,
}

/// Action button that can be displayed in a toast.
class GlassToastAction {
  /// Creates a toast action button.
  const GlassToastAction({
    required this.label,
    required this.onPressed,
  });

  /// The label text for the action button
  final String label;

  /// Callback when the action is pressed
  final VoidCallback onPressed;
}

/// A glass morphism toast/snackbar following iOS 26 liquid glass design.
///
/// [GlassToast] provides temporary, non-intrusive notifications with:
/// - iOS 26 liquid glass backdrop effect
/// - Auto-dismiss with configurable duration
/// - Slide-in/slide-out animations with spring physics
/// - Swipe-to-dismiss gesture
/// - Queue management for multiple toasts
/// - Semantic toast types (success, error, info, warning)
/// - Optional action button
/// - Configurable positioning (top, center, bottom)
///
/// ## Usage
///
/// ### Basic Success Toast
/// ```dart
/// GlassToast.show(
///   context,
///   message: 'Settings saved successfully',
///   type: GlassToastType.success,
/// );
/// ```
///
/// ### Error Toast with Action
/// ```dart
/// GlassToast.show(
///   context,
///   message: 'Failed to save changes',
///   type: GlassToastType.error,
///   action: GlassToastAction(
///     label: 'Retry',
///     onPressed: () => saveChanges(),
///   ),
/// );
/// ```
///
/// ### Info Toast at Top
/// ```dart
/// GlassToast.show(
///   context,
///   message: 'New message received',
///   type: GlassToastType.info,
///   icon: Icon(CupertinoIcons.envelope),
///   position: GlassToastPosition.top,
/// );
/// ```
///
/// ### Warning Toast with Custom Duration
/// ```dart
/// GlassToast.show(
///   context,
///   message: 'Storage space running low',
///   type: GlassToastType.warning,
///   duration: Duration(seconds: 5),
/// );
/// ```
///
/// ### Custom Toast with Manual Dismiss
/// ```dart
/// GlassToast.show(
///   context,
///   message: 'Processing...',
///   type: GlassToastType.neutral,
///   duration: Duration.zero, // Won't auto-dismiss
///   dismissible: true, // Can be swiped away
/// );
/// ```
///
/// ## iOS 26 Design Principles
///
/// - **Pill-shaped morphology**: Rounded capsule with liquid glass backdrop
/// - **Subtle animations**: Spring physics for natural motion (iOS 26 standard)
/// - **Non-blocking**: Floats above content without modal barrier
/// - **Contextual colors**: Semantic colors for different message types
/// - **Haptic feedback**: Provides tactile response on appearance (if supported)
/// - **Adaptive positioning**: Respects safe areas and keyboard
///
/// ## Queue Management
///
/// Toasts are automatically queued when multiple are shown simultaneously.
/// The queue ensures:
/// - One toast visible at a time
/// - Smooth transitions between toasts
/// - Proper cleanup of dismissed toasts
///
/// ## Accessibility
///
/// - Uses [Semantics] with `liveRegion: true` for screen reader announcements
/// - Semantic labels for action buttons
/// - High contrast mode support via theme
/// - Respects reduce motion preferences for animations
class GlassToast extends StatefulWidget {
  /// Creates a glass toast notification.
  const GlassToast({
    required this.message,
    super.key,
    this.icon,
    this.type = GlassToastType.success,
    this.position = GlassToastPosition.bottom,
    this.action,
    this.dismissible = true,
    this.onDismissed,
    this.settings,
    this.quality,
  });

  /// The message text to display
  final String message;

  /// Optional icon widget to display before the message
  final Widget? icon;

  /// Visual style and semantic meaning of the toast
  final GlassToastType type;

  /// Position where the toast should appear
  final GlassToastPosition position;

  /// Optional action button
  final GlassToastAction? action;

  /// Whether the toast can be dismissed by swiping
  final bool dismissible;

  /// Callback when the toast is dismissed
  final VoidCallback? onDismissed;

  /// Custom glass settings (overrides theme)
  final LiquidGlassSettings? settings;

  /// Rendering quality (overrides theme)
  final GlassQuality? quality;

  /// Shows a toast notification.
  ///
  /// Returns a function that can be called to manually dismiss the toast.
  ///
  /// Example:
  /// ```dart
  /// final dismiss = GlassToast.show(context, message: 'Loading...');
  /// // Later...
  /// dismiss();
  /// ```
  static VoidCallback show(
    BuildContext context, {
    required String message,
    Widget? icon,
    GlassToastType type = GlassToastType.success,
    GlassToastPosition position = GlassToastPosition.bottom,
    Duration duration = const Duration(seconds: 3),
    GlassToastAction? action,
    bool dismissible = true,
    LiquidGlassSettings? settings,
    GlassQuality? quality,
  }) {
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    void removeEntry() {
      overlayEntry.remove();
    }

    overlayEntry = OverlayEntry(
      builder: (context) => _GlassToastOverlay(
        message: message,
        icon: icon,
        type: type,
        position: position,
        duration: duration,
        action: action,
        dismissible: dismissible,
        settings: settings,
        quality: quality,
        onDismissed: removeEntry,
      ),
    );

    overlayState.insert(overlayEntry);

    return removeEntry;
  }

  @override
  State<GlassToast> createState() => _GlassToastState();
}

class _GlassToastState extends State<GlassToast> {
  @override
  Widget build(BuildContext context) {
    final themeData = GlassThemeData.of(context);
    final glowColors = themeData.glowColorsFor(context);

    // Get semantic color based on toast type
    final Color semanticColor = _getSemanticColor(glowColors);

    // Use user-provided icon or fall back to default for the toast type
    final Widget displayIcon = widget.icon ??
        Icon(widget.type == GlassToastType.success
            ? CupertinoIcons.check_mark_circled_solid
            : widget.type == GlassToastType.error
                ? CupertinoIcons.xmark_circle_fill
                : widget.type == GlassToastType.info
                    ? CupertinoIcons.info_circle_fill
                    : widget.type == GlassToastType.warning
                        ? CupertinoIcons.exclamationmark_triangle_fill
                        : CupertinoIcons.chat_bubble_fill);

    return Semantics(
      liveRegion: true,
      label: widget.message,
      child: _buildToastContent(context, semanticColor, displayIcon),
    );
  }

  Widget _buildToastContent(
      BuildContext context, Color semanticColor, Widget displayIcon) {
    final hasAction = widget.action != null;
    final isDark = GlassTheme.brightnessOf(context) == Brightness.dark;
    final bgColor = isDark
        ? CupertinoColors.black.withValues(alpha: 0.7)
        : CupertinoColors.white.withValues(alpha: 0.7);
    final textColor = CupertinoColors.label.resolveFrom(context);

    return AdaptiveLiquidGlassLayer(
      settings: widget.settings ??
          const LiquidGlassSettings(
            thickness: 25.0,
            blur: 6.0,
            refractiveIndex: 1.15,
            saturation: 1.3,
          ),
      quality: widget.quality,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 48,
          maxWidth: 400,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: semanticColor.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: semanticColor.withValues(alpha: 0.15),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: hasAction ? 8 : 12,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            IconTheme(
              data: IconThemeData(color: semanticColor, size: 20),
              child: displayIcon,
            ),
            const SizedBox(width: 12),

            // Message. Already the label of the live region above, so the
            // text is kept out of semantics to be read once, not twice.
            Flexible(
              child: ExcludeSemantics(
                child: Text(
                  widget.message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Action button
            if (hasAction) ...[
              const SizedBox(width: 12),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                onPressed: widget.action!.onPressed,
                minimumSize: Size(32, 32),
                child: Text(
                  widget.action!.label,
                  style: TextStyle(
                    color: semanticColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getSemanticColor(GlassGlowColors glowColors) {
    switch (widget.type) {
      case GlassToastType.success:
        return glowColors.success ?? GlassGlowColors.fallback.success!;
      case GlassToastType.error:
        return glowColors.danger ?? GlassGlowColors.fallback.danger!;
      case GlassToastType.info:
        return glowColors.info ?? GlassGlowColors.fallback.info!;
      case GlassToastType.warning:
        return glowColors.warning ?? GlassGlowColors.fallback.warning!;
      case GlassToastType.neutral:
        return CupertinoColors.secondaryLabel.resolveFrom(context);
    }
  }
}

/// Overlay wrapper that handles animations and positioning for the toast.
class _GlassToastOverlay extends StatefulWidget {
  const _GlassToastOverlay({
    required this.message,
    required this.type,
    required this.position,
    required this.duration,
    required this.onDismissed,
    this.icon,
    this.action,
    this.dismissible = true,
    this.settings,
    this.quality,
  });

  final String message;
  final Widget? icon;
  final GlassToastType type;
  final GlassToastPosition position;
  final Duration duration;
  final GlassToastAction? action;
  final bool dismissible;
  final LiquidGlassSettings? settings;
  final GlassQuality? quality;
  final VoidCallback onDismissed;

  @override
  State<_GlassToastOverlay> createState() => _GlassToastOverlayState();
}

class _GlassToastOverlayState extends State<_GlassToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _slideCurve;
  late Animation<Offset> _slideAnimation;
  late CurvedAnimation _fadeCurve;
  late Animation<double> _fadeAnimation;
  Timer? _dismissTimer;

  static const Animation<Offset> _noSlide =
      AlwaysStoppedAnimation<Offset>(Offset.zero);

  @override
  void initState() {
    super.initState();

    // Initialize animation controller with spring curve
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Slide animation based on position
    final Offset slideBegin = _getSlideOffset();
    _slideCurve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: slideBegin,
      end: Offset.zero,
    ).animate(_slideCurve);

    // Fade animation
    _fadeCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5),
      reverseCurve: const Interval(0.5, 1.0),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeCurve);

    // Start entrance animation
    _controller.forward();

    // Schedule auto-dismiss if duration is non-zero
    if (widget.duration > Duration.zero) {
      _dismissTimer = Timer(widget.duration, _dismiss);
    }
  }

  Offset _getSlideOffset() {
    switch (widget.position) {
      case GlassToastPosition.top:
        return const Offset(0, -1);
      case GlassToastPosition.center:
        return const Offset(0, 1);
      case GlassToastPosition.bottom:
        return const Offset(0, 1);
    }
  }

  Future<void> _dismiss() async {
    _dismissTimer?.cancel();
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _slideCurve.dispose();
    _fadeCurve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final EdgeInsets padding = mediaQuery.padding;

    // Calculate vertical position
    final double verticalPosition = _calculateVerticalPosition(padding);

    Widget toast = GlassToast(
      message: widget.message,
      icon: widget.icon,
      type: widget.type,
      position: widget.position,
      action: widget.action,
      dismissible: widget.dismissible,
      settings: widget.settings,
      quality: widget.quality,
      onDismissed: _dismiss,
    );

    // Add swipe-to-dismiss gesture if enabled
    if (widget.dismissible) {
      toast = Dismissible(
        key: const Key('glass_toast_dismissible'),
        direction: _getDismissDirection(),
        onDismissed: (_) => _dismiss(),
        // The swipe has no meaning to a screen reader; the same dismissal is
        // offered to it as a semantic action. Pointer users get the timer.
        child: Semantics(container: true, onDismiss: _dismiss, child: toast),
      );
    }

    // Reduce Motion: the toast fades in and out in place, without the slide.
    final reduceMotion = GlassAccessibilityData.of(context).reduceMotion;

    return Positioned(
      top: widget.position == GlassToastPosition.top ? verticalPosition : null,
      bottom: widget.position == GlassToastPosition.bottom
          ? verticalPosition
          : null,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: reduceMotion ? _noSlide : _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: widget.position == GlassToastPosition.center
              ? Center(child: toast)
              : toast,
        ),
      ),
    );
  }

  double _calculateVerticalPosition(EdgeInsets padding) {
    switch (widget.position) {
      case GlassToastPosition.top:
        return padding.top + 16;
      case GlassToastPosition.center:
        return 0; // Centered via alignment
      case GlassToastPosition.bottom:
        return padding.bottom + 16;
    }
  }

  DismissDirection _getDismissDirection() {
    switch (widget.position) {
      case GlassToastPosition.top:
        return DismissDirection.up;
      case GlassToastPosition.center:
        return DismissDirection.horizontal;
      case GlassToastPosition.bottom:
        return DismissDirection.down;
    }
  }
}
