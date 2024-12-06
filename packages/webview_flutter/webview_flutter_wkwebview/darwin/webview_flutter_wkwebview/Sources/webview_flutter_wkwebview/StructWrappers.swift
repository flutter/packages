// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

class URLRequestWrapper {
  var value: URLRequest

  init(_ value: URLRequest) {
    self.value = value
  }
}

class URLWrapper {
  let value: URL

  init(value: URL) {
    self.value = value
  }
}
