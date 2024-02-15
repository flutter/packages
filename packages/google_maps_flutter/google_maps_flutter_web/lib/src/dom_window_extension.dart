import 'dart:js_interop';

import 'package:web/web.dart';

/// This extension exists to handle unsupported features by certain browsers.
extension DomWindowExtension on Window {
  /// Get the `trustedTypes` object from the window, if it is supported.
  @JS('trustedTypes')
  external TrustedTypePolicyFactory? get trustedTypesNullable;
}
