// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing

@testable import test_plugin

struct IsNullishTests {

  @Test
  func testNil() {
    let value: Any? = nil
    #expect(CoreTestsPigeonInternal.isNullish(value) == true)
  }

  @Test
  func testNSNull() {
    let value: Any? = NSNull()
    #expect(CoreTestsPigeonInternal.isNullish(value) == true)
  }

  @Test
  func testNestedNil() {
    let inner: Any? = nil
    let value: Any? = inner
    #expect(CoreTestsPigeonInternal.isNullish(value) == true)
  }

  @Test
  func testDoubleNestedNil() {
    let innerMost: Any? = nil
    let inner: Any?? = innerMost
    let value: Any? = inner
    #expect(CoreTestsPigeonInternal.isNullish(value) == true)
  }

  @Test
  func testTypedNil() {
    let typedNil: String? = nil
    let value: Any? = typedNil
    #expect(CoreTestsPigeonInternal.isNullish(value) == true)
  }

  @Test
  func testNestedNSNull() {
    let inner: Any? = NSNull()
    let value: Any? = inner
    #expect(CoreTestsPigeonInternal.isNullish(value) == true)
  }

  @Test
  func testNonNullValue() {
    let value: Any? = "Hello"
    #expect(CoreTestsPigeonInternal.isNullish(value) == false)
  }
}
