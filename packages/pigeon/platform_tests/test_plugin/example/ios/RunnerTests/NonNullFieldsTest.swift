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

  @Test
  func testEquality() {
    let request1 = NonNullFieldSearchRequest(query: "hello")
    let request2 = NonNullFieldSearchRequest(query: "hello")
    let request3 = NonNullFieldSearchRequest(query: "world")

    #expect(request1 == request2)
    #expect(request1 != request3)
    #expect(request1.hashValue == request2.hashValue)
  }
}
