// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:web/web.dart' as web;

/// Injects a `<meta>` tag with the provided [attributes] into the [web.document].
void injectMetaTag(Map<String, String> attributes) {
  final web.HTMLMetaElement meta =
      web.document.createElement('meta') as web.HTMLMetaElement;
  for (final MapEntry<String, String> attribute in attributes.entries) {
    meta.setAttribute(attribute.key, attribute.value);
  }
  web.document.head!.appendChild(meta);
}
