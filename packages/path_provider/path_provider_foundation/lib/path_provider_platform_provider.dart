import 'dart:io';

/// Helper class for returning information about the current platform.
class PathProviderPlatformProvider {
  /// Specifies whether the current platform is iOS.
  bool get isIOS => Platform.isIOS;
}
