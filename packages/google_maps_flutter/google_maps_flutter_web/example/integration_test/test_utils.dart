import 'package:flutter/foundation.dart';
import 'package:web/web.dart';

/// Convenience method to create a new [HTMLDivElement] element.
@visibleForTesting
HTMLDivElement createDivElement() {
  return document.createElement('div') as HTMLDivElement;
}
