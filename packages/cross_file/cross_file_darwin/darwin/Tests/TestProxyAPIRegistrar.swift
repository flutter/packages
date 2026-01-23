// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@testable import cross_file_darwin

class TestProxyAPIRegistrar: ProxyAPIRegistrar {
  init() {
    super.init(binaryMessenger: TestBinaryMessenger())
  }
}
