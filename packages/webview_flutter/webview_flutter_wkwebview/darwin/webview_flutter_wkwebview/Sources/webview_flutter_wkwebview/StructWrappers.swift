// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// Wrapper around `URLRequest`.
///
/// Since `URLRequest` is a struct, it is pass by value instead of pass by reference. This makes
/// it not possible to modify the properties of a struct with the typical ProxyAPI system.
class URLRequestWrapper {
  var value: URLRequest

  init(_ value: URLRequest) {
    self.value = value
  }
}
