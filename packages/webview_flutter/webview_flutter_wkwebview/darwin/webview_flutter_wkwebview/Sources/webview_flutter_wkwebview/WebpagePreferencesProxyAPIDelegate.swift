// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit

/// ProxyApi implementation for `WKWebpagePreferences`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class WebpagePreferencesProxyAPIDelegate: PigeonApiDelegateWKWebpagePreferences {
  func setAllowsContentJavaScript(
    pigeonApi: PigeonApiWKWebpagePreferences, pigeonInstance: WKWebpagePreferences, allow: Bool
  ) throws {
    pigeonInstance.allowsContentJavaScript = allow
  }
}
