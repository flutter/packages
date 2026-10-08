// Using deprecated Colors.withOpacity for backwards compatibility with
// existing code patterns in the codebase.
// ignore_for_file: deprecated_member_use

// Physics calculations adapted from example code in the liquid_glass_renderer
// package by whynotmake-it team (https://github.com/whynotmake-it/flutter_liquid_glass).
// Used under MIT License.

import 'package:flutter/widgets.dart';

/// Shared physics and animation utilities for draggable indicators.
///
/// This utility class contains common physics calculations used by widgets
/// with draggable indicators.
///
/// Key features:
/// - Rubber band resistance for iOS-style overdrag
/// - Jelly physics for organic squash and stretch animations
/// - Alignment calculations for indicator positioning
/// - Velocity-based snapping for natural gesture handling
class DraggableIndicatorPhysics {
  DraggableIndicatorPhysics._();

  // ===========================================================================
  // Rubber Band Physics
  // ===========================================================================

  /// Applies iOS-style rubber band resistance when dragging beyond edges.
  ///
  /// Values outside the 0-1 range are compressed with decreasing resistance,
  /// creating a "pulling against rubber band" feel.
  ///
  /// Parameters:
  /// - [value]: The normalized drag position (typically 0-1, but can exceed)
  /// - [resistance]: Lower values = more resistance (default: 0.4)
  /// - [maxOverdrag]: Maximum overdrag as fraction of range (default: 0.3)
  ///
  /// Returns: Adjusted value with rubber band resistance applied.
  ///
  /// Example:
  /// ```dart
  /// final adjusted = DraggableIndicatorPhysics.applyRubberBandResistance(1.5);
  /// // Returns approximately 1.2 instead of 1.5
  /// ```
  static double applyRubberBandResistance(
    double value, {
    double resistance = 0.4,
    double maxOverdrag = 0.3,
  }) {
    if (value < 0) {
      // Overdrag to the left
      final overdrag = -value;
      final resistedOverdrag = overdrag * resistance;
      return -resistedOverdrag.clamp(0.0, maxOverdrag);
    } else if (value > 1) {
      // Overdrag to the right
      final overdrag = value - 1;
      final resistedOverdrag = overdrag * resistance;
      return 1 + resistedOverdrag.clamp(0.0, maxOverdrag);
    }

    // Normal range, no resistance
    return value;
  }

  // ===========================================================================
  // Jelly Physics Transform
  // ===========================================================================

  /// Creates a jelly transform matrix based on velocity.
  ///
  /// Applies organic squash and stretch effects that create a satisfying
  /// "jelly" animation:
  /// - Squashes in the direction of movement
  /// - Stretches perpendicular to movement
  /// - Intensity scales with velocity magnitude
  ///
  /// This creates the iOS-style elastic effect seen when dragging indicators.
  ///
  /// Parameters:
  /// - [velocity]: Direction and speed of movement as an Offset
  /// - [maxDistortion]: Maximum distortion factor 0-1 (default: 0.7)
  /// - [velocityScale]: Scale factor for velocity; higher = less
  ///   distortion (default: 1000.0)
  ///
  /// Returns: A [Matrix4] transform that can be applied to a widget.
  ///
  /// Example:
  /// ```dart
  /// Transform(
  ///   alignment: Alignment.center,
  ///   transform: DraggableIndicatorPhysics.buildJellyTransform(
  ///     velocity: Offset(velocityX, 0),
  ///     maxDistortion: 0.8,
  ///     velocityScale: 10,
  ///   ),
  ///   child: indicator,
  /// )
  /// ```
  static Matrix4 buildJellyTransform({
    required Offset velocity,
    double maxDistortion = 0.7,
    double velocityScale = 1000.0,
  }) {
    final speed = velocity.distance;
    if (speed == 0 || !speed.isFinite) {
      // speed == 0: no movement, avoid division by zero.
      // !isFinite: NaN or Infinity from synthetic/custom velocity — fall back
      // to a neutral transform. Keep a sub-pixel translation so the
      // TransformLayer stays mounted and avoids edge-snapping artifacts.
      return Matrix4.identity()..translate(0.0001, 0.0);
    }

    // Normalize velocity direction
    final direction = velocity / speed;

    // Calculate distortion intensity based on speed
    final distortionFactor =
        (speed / velocityScale).clamp(0.0, 1.0) * maxDistortion;

    // Squash in direction of movement
    final squashX = 1.0 - (direction.dx.abs() * distortionFactor * 0.5);
    final squashY = 1.0 - (direction.dy.abs() * distortionFactor * 0.5);

    // Stretch perpendicular to movement
    final stretchX = 1.0 + (direction.dy.abs() * distortionFactor * 0.3);
    final stretchY = 1.0 + (direction.dx.abs() * distortionFactor * 0.3);

    // Combine effects
    final scaleX = squashX * stretchX;
    final scaleY = squashY * stretchY;

    final matrix = Matrix4.identity()..scale(scaleX, scaleY);
    if (matrix.isIdentity()) {
      // Catch floating-point rounding rendering drops when speed is > 0 but microscopic
      matrix.translate(0.0001, 0.0);
    }
    return matrix;
  }

  // ===========================================================================
  // Alignment Calculations
  // ===========================================================================

  /// Converts an item index to horizontal alignment (-1 to 1).
  ///
  /// Used to position the indicator at the correct location for a given item.
  ///
  /// Parameters:
  /// - [index]: The item index (0-based)
  /// - [itemCount]: Total number of items
  ///
  /// Returns: Alignment value from -1 (leftmost) to 1 (rightmost).
  ///
  /// Example:
  /// ```dart
  /// // For 3 items (indices 0, 1, 2):
  /// computeAlignment(0, 3) // Returns -1.0 (left)
  /// computeAlignment(1, 3) // Returns  0.0 (center)
  /// computeAlignment(2, 3) // Returns  1.0 (right)
  /// ```
  static double computeAlignment(int index, int itemCount) {
    final relativeIndex = (index / (itemCount - 1)).clamp(0.0, 1.0);
    return (relativeIndex * 2) - 1;
  }

  /// Converts a global drag position to alignment (-1 to 1) along [direction].
  ///
  /// Applies rubber band resistance when dragging beyond edges.
  ///
  /// Parameters:
  /// - [globalPosition]: The global position from drag details
  /// - [context]: Build context to find the render box
  /// - [itemCount]: Total number of items
  /// - [direction]: Axis whose coordinate and extent drive the mapping
  /// - [mirrorForRtl]: Whether to mirror the horizontal fraction under an RTL
  ///   [Directionality]. Leave `true` for consumers that position the indicator
  ///   with [AlignmentDirectional] (the segmented controls), where the
  ///   framework does not re-apply the flip. Pass `false` for consumers working
  ///   in physical alignment space: the bottom and searchable tab bars paint
  ///   with [Alignment] and carry RTL in their tab data, so mirroring here
  ///   flips a second time and runs the drag backwards. It would also disagree
  ///   with [tabIndexFromGlobalPosition], which never mirrors — which is why a
  ///   press landed on the right tab and the slide then ran the wrong way.
  ///
  /// Returns: Alignment value with rubber band resistance applied.
  static double getAlignmentFromGlobalPosition(
    Offset globalPosition,
    BuildContext context,
    int itemCount, {
    Axis direction = Axis.horizontal,
    bool mirrorForRtl = true,
  }) {
    final box = context.findRenderObject()! as RenderBox;
    final localPosition = box.globalToLocal(globalPosition);

    // Calculate the effective draggable range
    final indicatorWidth = 1.0 / itemCount;
    final draggableRange = 1.0 - indicatorWidth;
    final padding = indicatorWidth / 2;

    // Map drag position to 0-1 range
    final mainPosition =
        direction == Axis.horizontal ? localPosition.dx : localPosition.dy;
    final mainExtent =
        direction == Axis.horizontal ? box.size.width : box.size.height;
    var rawRelativeX = (mainPosition / mainExtent).clamp(0.0, 1.0);

    if (mirrorForRtl &&
        direction == Axis.horizontal &&
        Directionality.of(context) == TextDirection.rtl) {
      rawRelativeX = 1.0 - rawRelativeX;
    }

    final normalizedX = (rawRelativeX - padding) / draggableRange;

    // Apply rubber band resistance for overdrag
    final adjustedRelativeX = applyRubberBandResistance(normalizedX);

    // Convert to -1 to 1 range
    return (adjustedRelativeX * 2) - 1;
  }

  /// Converts a global tap position to a tab index using the raw (un-remapped)
  /// position fraction.
  ///
  /// Unlike [getAlignmentFromGlobalPosition], this method does **not** apply
  /// the indicator-center padding/draggable-range remap. It divides the bar
  /// into [itemCount] equal slices and returns which slice contains the tap.
  ///
  /// Use this for **discrete tap-to-index conversions** (e.g. `onTapDown`).
  /// Use [getAlignmentFromGlobalPosition] for **continuous drag tracking**
  /// where the indicator center must stay within its physical travel range.
  ///
  /// Parameters:
  /// - [globalPosition]: The global position from tap/pointer details
  /// - [context]: Build context used to find the render box
  /// - [itemCount]: Total number of items (tabs)
  /// - [direction]: Axis along which the bar is laid out (default: horizontal)
  ///
  /// Returns: The item index (0-based, clamped to `0 – itemCount-1`).
  ///
  /// Example:
  /// ```dart
  /// // 400-px wide bar with 4 tabs (each 100 px):
  /// // tap at x=310 → rawRelativeX=0.775 → (0.775 * 4).floor() = 3
  /// final index = DraggableIndicatorPhysics.tabIndexFromGlobalPosition(
  ///   globalPosition, context, 4,
  /// );
  /// ```
  static int tabIndexFromGlobalPosition(
    Offset globalPosition,
    BuildContext context,
    int itemCount, {
    Axis direction = Axis.horizontal,
  }) {
    final box = context.findRenderObject()! as RenderBox;
    final localPosition = box.globalToLocal(globalPosition);
    final width =
        direction == Axis.horizontal ? box.size.width : box.size.height;
    double fraction =
        (direction == Axis.horizontal ? localPosition.dx : localPosition.dy) /
            width;

    return (fraction * itemCount).floor().clamp(0, itemCount - 1);
  }

  // ===========================================================================
  // Velocity-Based Snapping
  // ===========================================================================

  /// Computes the target item index based on drag position and velocity.
  ///
  /// Uses velocity-based snapping for iOS-style flick gestures:
  /// - High velocity: Project forward and snap to the projected item
  /// - Low velocity: Snap to nearest item
  ///
  /// This creates the satisfying "flick to jump" behavior seen in iOS.
  ///
  /// Parameters:
  /// - [currentRelativeX]: Current position in 0-1 range
  /// - [velocityX]: Horizontal velocity in relative units
  /// - [itemWidth]: Width of each item as a fraction (1 / itemCount)
  /// - [itemCount]: Total number of items
  /// - [velocityThreshold]: Velocity threshold for flick detection
  ///   (default: 0.5)
  /// - [projectionTime]: Time to project velocity forward in seconds
  ///   (default: 0.3)
  ///
  /// Returns: The target item index (0-based).
  ///
  /// Example:
  /// ```dart
  /// final targetIndex = DraggableIndicatorPhysics.computeTargetIndex(
  ///   currentRelativeX: 0.4,
  ///   velocityX: 2.0, // Fast swipe right
  ///   itemWidth: 1.0 / 3,
  ///   itemCount: 3,
  /// );
  /// // Returns 2 (jumped to last item due to high velocity)
  /// ```
  static int computeTargetIndex({
    required double currentRelativeX,
    required double velocityX,
    required double itemWidth,
    required int itemCount,
    double velocityThreshold = 0.5,
    double projectionTime = 0.3,
  }) {
    // Handle overdrag scenarios
    if (currentRelativeX < 0) return 0;
    if (currentRelativeX > 1) return itemCount - 1;

    // Guard against NaN / Infinity from synthetic or injected velocity values.
    // Fall through to nearest-item snap rather than projecting an invalid position.
    final safeVelocityX = velocityX.isFinite ? velocityX : 0.0;

    if (safeVelocityX.abs() > velocityThreshold) {
      // High velocity - project where we would end up
      final projectedX =
          (currentRelativeX + safeVelocityX * projectionTime).clamp(0.0, 1.0);
      var targetIndex =
          (projectedX / itemWidth).round().clamp(0, itemCount - 1);

      // Ensure we move at least one item with strong velocity
      final currentIndex =
          (currentRelativeX / itemWidth).round().clamp(0, itemCount - 1);

      if (safeVelocityX > velocityThreshold &&
          targetIndex <= currentIndex &&
          currentIndex < itemCount - 1) {
        targetIndex = currentIndex + 1;
      } else if (safeVelocityX < -velocityThreshold &&
          targetIndex >= currentIndex &&
          currentIndex > 0) {
        targetIndex = currentIndex - 1;
      }

      return targetIndex;
    }

    // Low velocity - snap to nearest
    return (currentRelativeX / itemWidth).round().clamp(0, itemCount - 1);
  }
}
