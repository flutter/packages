// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Testing

@testable import test_plugin

@MainActor
struct ListTests {

  @Test
  func listInList() async throws {
    let inside = TestMessage(testList: [1, 2, 3])
    let top = TestMessage(testList: [inside])
    let binaryMessenger = EchoBinaryMessenger(codec: CoreTestsPigeonCodec.shared)
    let api = FlutterSmallApi(binaryMessenger: binaryMessenger)

    await confirmation { confirmed in
      api.echo(top) { result in
        switch result {
        case .success(let res):
          #expect(res.testList?.count == 1)
          #expect(res.testList?[0] is TestMessage)
          #expect(equalsList(inside.testList, (res.testList?[0] as! TestMessage).testList))
          confirmed()
        case .failure(let error):
          Issue.record("Failed with error: \(error)")
        }
      }
    }
  }

}
