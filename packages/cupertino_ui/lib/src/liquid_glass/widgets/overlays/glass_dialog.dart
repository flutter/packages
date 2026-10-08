import 'package:flutter/cupertino.dart';

import '../../src/renderer/liquid_glass_renderer.dart';

import '../../types/glass_quality.dart';
import '../containers/glass_card.dart';
import '../interactive/glass_button.dart';
import '../shared/adaptive_liquid_glass_layer.dart';
import '../../theme/glass_theme_helpers.dart';

/// A glass morphism alert dialog following Apple's iOS design patterns.
///
/// [GlassDialog] provides a modal dialog with liquid glass effect,
/// composing [GlassCard] and [GlassButton] as building blocks.
///
/// ## Key Features
///
/// - Liquid glass backdrop with blur effect
/// - Composable design using GlassCard + GlassButton
/// - iOS-style alert layout
/// - 1-3 action buttons with smart layout
/// - Customizable glass settings
/// - Optional custom content
///
/// ## Usage
///
/// ### Basic Alert
/// ```dart
/// GlassDialog.show(
///   context: context,
///   title: 'Delete Item?',
///   message: 'This action cannot be undone.',
///   actions: [
///     GlassDialogAction(
///       label: 'Cancel',
///       onPressed: () => Navigator.pop(context),
///     ),
///     GlassDialogAction(
///       label: 'Delete',
///       isDestructive: true,
///       onPressed: () {
///         // Delete logic
///         Navigator.pop(context);
///       },
///     ),
///   ],
/// );
/// ```
///
/// ### Single Action
/// ```dart
/// GlassDialog.show(
///   context: context,
///   title: 'Success',
///   message: 'Your changes have been saved.',
///   actions: [
///     GlassDialogAction(
///       label: 'OK',
///       onPressed: () => Navigator.pop(context),
///     ),
///   ],
/// );
/// ```
///
/// ### Three Actions
/// ```dart
/// GlassDialog.show(
///   context: context,
///   title: 'Save Changes?',
///   message: 'You have unsaved changes.',
///   actions: [
///     GlassDialogAction(
///       label: 'Don\'t Save',
///       onPressed: () => Navigator.pop(context, false),
///     ),
///     GlassDialogAction(
///       label: 'Cancel',
///       onPressed: () => Navigator.pop(context),
///     ),
///     GlassDialogAction(
///       label: 'Save',
///       isPrimary: true,
///       onPressed: () => Navigator.pop(context, true),
///     ),
///   ],
/// );
/// ```
///
/// ### Custom Content
/// ```dart
/// GlassDialog.show(
///   context: context,
///   title: 'Enter Name',
///   content: Padding(
///     padding: EdgeInsets.symmetric(vertical: 16),
///     child: TextField(
///       decoration: InputDecoration(
///         hintText: 'Name',
///       ),
///     ),
///   ),
///   actions: [
///     GlassDialogAction(
///       label: 'Cancel',
///       onPressed: () => Navigator.pop(context),
///     ),
///     GlassDialogAction(
///       label: 'OK',
///       isPrimary: true,
///       onPressed: () => Navigator.pop(context),
///     ),
///   ],
/// );
/// ```
///
/// ### Custom Glass Settings
/// ```dart
/// GlassDialog.show(
///   context: context,
///   title: 'Custom Dialog',
///   message: 'With custom glass effect',
///   settings: LiquidGlassSettings(
///     thickness: 40,
///     blur: 15,
///     glassColor: Colors.purple,
///   ),
///   actions: [
///     GlassDialogAction(
///       label: 'OK',
///       onPressed: () => Navigator.pop(context),
///     ),
///   ],
/// );
/// ```
class GlassDialog extends StatelessWidget {
  /// Creates a glass dialog widget.
  ///
  /// Typically not instantiated directly - use [GlassDialog.show] instead.
  const GlassDialog({
    required this.actions,
    super.key,
    this.title,
    this.message,
    this.content,
    this.settings,
    this.quality,
    this.maxWidth = 280,
  }) : assert(
          actions.length > 0 && actions.length <= 3,
          'GlassDialog must have 1-3 actions',
        );

  static const _actionButtonShape = LiquidRoundedSuperellipse(borderRadius: 12);

  // Cache default colors to avoid allocations
  static const _defaultGlowColor =
      Color(0x4DFFFFFF); // white.withValues(alpha: 0.3)
  static const _destructiveGlowColor =
      Color(0x4DFF0000); // red.withValues(alpha: 0.3)
  static const _primaryGlowColor =
      Color(0x4D0000FF); // blue.withValues(alpha: 0.3)

  // ===========================================================================
  // Content Properties
  // ===========================================================================

  /// Title of the dialog.
  ///
  /// Displayed in bold at the top of the dialog. If null, no title is shown.
  final String? title;

  /// Message text of the dialog.
  ///
  /// Displayed below the title in a lighter color. If null, no message is
  /// shown.
  final String? message;

  /// Custom content widget.
  ///
  /// Displayed between the message and actions. Use this for custom content
  /// like text fields, pickers, or other interactive widgets.
  ///
  /// If both [message] and [content] are provided, content is shown below
  /// the message.
  final Widget? content;

  /// Maximum width of the dialog in logical pixels.
  ///
  /// Defaults to 280 (iOS standard alert width).
  final double maxWidth;

  // ===========================================================================
  // Action Properties
  // ===========================================================================

  /// Action buttons to display at the bottom of the dialog.
  ///
  /// Must have 1-3 actions. Layout automatically adjusts:
  /// - 1-2 actions: Horizontal layout
  /// - 3 actions: Vertical layout (iOS pattern)
  final List<GlassDialogAction> actions;

  // ===========================================================================
  // Glass Effect Properties
  // ===========================================================================

  /// Glass effect settings for the dialog.
  ///
  /// Controls the visual appearance of the glass effect including thickness,
  /// blur radius, color tint, lighting, and more.
  ///
  /// If null, uses [LiquidGlassSettings] defaults.
  final LiquidGlassSettings? settings;

  /// Rendering quality for the glass effect.
  ///
  /// Defaults to [GlassQuality.standard], which uses backdrop filter rendering.
  final GlassQuality? quality;

  // ===========================================================================
  // Static Show Method
  // ===========================================================================

  /// Shows a glass dialog.
  ///
  /// Returns a [Future] that resolves to the value (if any) passed to
  /// [Navigator.pop] when the dialog is dismissed.
  ///
  /// Parameters:
  /// - [context]: Build context for showing the dialog
  /// - [title]: Title text (optional)
  /// - [message]: Message text (optional)
  /// - [content]: Custom content widget (optional)
  /// - [actions]: Action buttons (required, 1-3 actions)
  /// - [settings]: Glass effect settings (null uses defaults)
  /// - [quality]: Rendering quality (defaults to standard)
  /// - [barrierDismissible]: Whether tapping outside dismisses (default: false)
  /// - [barrierColor]: Color of the modal barrier (defaults to black54)
  /// - [maxWidth]: Maximum width of dialog (default: 280)
  ///
  /// Example:
  /// ```dart
  /// final result = await GlassDialog.show<bool>(
  ///   context: context,
  ///   title: 'Confirm',
  ///   message: 'Are you sure?',
  ///   actions: [
  ///     GlassDialogAction(
  ///       label: 'Cancel',
  ///       onPressed: () => Navigator.pop(context, false),
  ///     ),
  ///     GlassDialogAction(
  ///       label: 'Confirm',
  ///       onPressed: () => Navigator.pop(context, true),
  ///     ),
  ///   ],
  /// );
  /// ```
  static Future<T?> show<T>({
    required BuildContext context,
    required List<GlassDialogAction> actions,
    String? title,
    String? message,
    Widget? content,
    LiquidGlassSettings? settings,
    GlassQuality quality = GlassQuality.standard,
    bool barrierDismissible = false,
    Color? barrierColor,
    double maxWidth = 280,
  }) {
    return showCupertinoDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => GlassDialog(
        title: title,
        message: message,
        content: content,
        actions: actions,
        settings: settings,
        quality: quality,
        maxWidth: maxWidth,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Inherit quality from parent layer if not explicitly set
    final effectiveQuality = GlassThemeHelpers.resolveQuality(
      context,
      widgetQuality: quality,
    );

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: GlassCard(
          useOwnLayer: true,
          settings: settings,
          quality: effectiveQuality,
          padding: const EdgeInsets.all(20),
          child: AdaptiveLiquidGlassLayer(
            settings: settings ?? const LiquidGlassSettings(),
            quality: effectiveQuality,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                if (title != null) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                ],

                // Message
                if (message != null) ...[
                  Text(
                    message!,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          CupertinoColors.secondaryLabel.resolveFrom(context),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                ],

                // Custom content
                if (content != null) ...[
                  content!,
                  const SizedBox(height: 8),
                ],

                const SizedBox(height: 12),

                // Actions
                _buildActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    // 1-2 actions: Horizontal layout
    if (actions.length <= 2) {
      return Row(
        children: actions.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: index > 0 ? 8 : 0,
              ),
              child: _buildActionButton(action, context),
            ),
          );
        }).toList(),
      );
    }

    // 3 actions: Vertical layout (iOS pattern)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: actions.asMap().entries.map((entry) {
        final index = entry.key;
        final action = entry.value;
        return Padding(
          padding: EdgeInsets.only(
            top: index > 0 ? 8 : 0,
          ),
          child: _buildActionButton(action, context),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton(GlassDialogAction action, BuildContext context) {
    // Determine button styling based on action type
    var glowColor = _defaultGlowColor;
    if (action.isDestructive) {
      glowColor = _destructiveGlowColor;
    } else if (action.isPrimary) {
      glowColor = _primaryGlowColor;
    }

    return GlassButton.custom(
      onTap: action.onPressed,
      height: 44,
      shape: _actionButtonShape,
      glowColor: glowColor,
      child: Text(
        action.label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: action.isPrimary ? FontWeight.bold : FontWeight.w600,
          color: action.isDestructive
              ? CupertinoColors.destructiveRed
              : CupertinoColors.label.resolveFrom(context),
        ),
      ),
    );
  }
}

/// Configuration for a dialog action button.
///
/// Used with [GlassDialog] to define action buttons.
class GlassDialogAction {
  /// Creates a dialog action configuration.
  const GlassDialogAction({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    this.isDestructive = false,
  });

  /// Label text for the button.
  final String label;

  /// Callback when the button is pressed.
  final VoidCallback onPressed;

  /// Whether this is the primary (recommended) action.
  ///
  /// Primary actions are displayed with bold text and blue glow.
  /// Typically used for the positive/affirmative action.
  ///
  /// Defaults to false.
  final bool isPrimary;

  /// Whether this is a destructive action.
  ///
  /// Destructive actions are displayed with red text and red glow.
  /// Typically used for delete, remove, or other dangerous actions.
  ///
  /// Defaults to false.
  final bool isDestructive;
}
