// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit

/// ProxyApi implementation for `WKWebpagePreferences`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class WebpagePreferencesProxyAPIDelegate: PigeonApiDelegateWKWebpagePreferences {
  @available(iOS 13.0, macOS 10.15, *)
  func setAllowsContentJavaScript(
    pigeonApi: PigeonApiWKWebpagePreferences, pigeonInstance: WKWebpagePreferences, allow: Bool
  ) throws {
    if #available(iOS 14.0, macOS 11.0, *) {
      pigeonInstance.allowsContentJavaScript = allow
    } else {
      throw (pigeonApi.pigeonRegistrar as! ProxyAPIRegistrar)
        .createUnsupportedVersionError(
          method: "WKWebpagePreferences.allowsContentJavaScript",
          versionRequirements: "iOS 14.0, macOS 11.0")
    }
  }
}
