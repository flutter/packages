import 'package:flutter/foundation.dart';

/// Defines the parameters of the content offset change callback.
class ContentOffsetChange {
  /// Creates a [ContentOffsetChange].
  const ContentOffsetChange(this.x, this.y);
  
  /// The value of horizontal offset with the origin begin at the leftmost of the [WebView]
  final int x;
  
  /// The value of vertical offset with the origin begin at the topmost of the [WebView]
  final int y;
}