// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Testing

@testable import test_plugin

struct NonNullFieldsTests {
  @Test
  func make() {
    let request = NonNullFieldSearchRequest(query: "hello")
    #expect(request.query == "hello")
  }
}
