// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Testing

@testable import test_plugin

/// Tests NSNull is correctly handled by `nilOrValue` helper, by manually setting nullable fields to NSNull.
struct NSNullFieldTests {

  @Test
  func nullListToCustomStructField() throws {
    let reply = NullFieldsSearchReply(
      result: nil,
      error: nil,
      indices: nil,
      request: nil,
      type: nil)
    var list = reply.toList()
    // request field
    list[3] = NSNull()
    let copy = NullFieldsSearchReply.fromList(list)
    #expect(copy != nil)
    #expect(copy!.request == nil)
  }

  @Test
  func nullListField() {
    let reply = NullFieldsSearchReply(
      result: nil,
      error: nil,
      indices: nil,
      request: nil,
      type: nil)
    var list = reply.toList()
    // indices field
    list[2] = NSNull()
    let copy = NullFieldsSearchReply.fromList(list)
    #expect(copy != nil)
    #expect(copy!.indices == nil)
  }

  @Test
  func nullBasicFields() throws {
    let reply = NullFieldsSearchReply(
      result: nil,
      error: nil,
      indices: nil,
      request: nil,
      type: nil)
    var list = reply.toList()
    // result field
    list[0] = NSNull()
    // error field
    list[1] = NSNull()
    // type field
    list[4] = NSNull()
    let copy = NullFieldsSearchReply.fromList(list)
    #expect(copy != nil)
    #expect(copy!.result == nil)
    #expect(copy!.error == nil)
    #expect(copy!.type == nil)
  }
}
