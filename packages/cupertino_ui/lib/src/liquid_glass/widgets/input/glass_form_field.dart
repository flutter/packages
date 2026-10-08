import 'package:flutter/cupertino.dart';

/// A standard form field wrapper for glass inputs following iOS design patterns.
///
/// [GlassFormField] wraps input widgets (like [GlassTextField], [GlassPicker],
/// etc.) with a standard label, error text, and helper text layout. It ensures
/// consistent spacing and typography across all form inputs in an application.
///
/// ## Key Features
///
/// - **Consistent Typography**: Uses standard iOS-style weights and colors for labels
/// - **Validation Support**: Displays error text in red when provided
/// - **Helper Text**: Optional secondary text for hints or instructions
/// - **Flexible Layout**: Works with any child widget
///
/// ## Usage
///
/// ### Basic Usage
/// ```dart
/// GlassFormField(
///   label: 'Email Address',
///   child: GlassTextField(
///     placeholder: 'name@example.com',
///   ),
/// )
/// ```
///
/// ### With Validation Error
/// ```dart
/// GlassFormField(
///   label: 'Password',
///   errorText: isPasswordValid ? null : 'Password must be at least 8 chars',
///   child: GlassPasswordField(),
/// )
/// ```
///
/// ### With Helper Text
/// ```dart
/// GlassFormField(
///   label: 'Username',
///   helperText: 'This will be visible to other users',
///   child: GlassTextField(),
/// )
/// ```
class GlassFormField extends StatelessWidget {
  /// Creates a form field wrapper.
  const GlassFormField({
    required this.child,
    super.key,
    this.label,
    this.helperText,
    this.errorText,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  /// The input widget (e.g., GlassTextField).
  final Widget child;

  /// Label displayed above the input.
  final String? label;

  /// Helper text displayed below the input.
  final String? helperText;

  /// Error text displayed below the input (replaces helperText).
  final String? errorText;

  /// Cross alignment of the column.
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label.resolveFrom(context),
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Wrap child in Theme or similar if we wanted to cascade error state,
        // but for now we just render it.
        child,

        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemRed,
              fontWeight: FontWeight.w500,
            ),
          ),
        ] else if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            helperText!,
            style: TextStyle(
              fontSize: 12,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
        ],
      ],
    );
  }
}
