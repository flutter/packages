// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// ProxyApi implementation for `URL`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class URLProxyAPIDelegate : PigeonApiDelegateURL {
  func startAccessingSecurityScopedResource(pigeonApi: PigeonApiURL, url: String) throws -> Bool {
    return URL(string: url)!.startAccessingSecurityScopedResource()
  }

  func stopAccessingSecurityScopedResource(pigeonApi: PigeonApiURL, url: String) throws {
    URL(string: url)!.stopAccessingSecurityScopedResource()
  }

}
