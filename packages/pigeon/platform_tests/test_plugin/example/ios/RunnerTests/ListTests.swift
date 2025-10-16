// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import test_plugin

class ListTests: XCTestCase {

  func testListInList() throws {
    let inside = TestMessage(testList: [1, 2, 3])
    let top = TestMessage(testList: [inside])
    let binaryMessenger = EchoBinaryMessenger(codec: CoreTestsPigeonCodec.shared)
    let api = FlutterSmallApi(binaryMessenger: binaryMessenger)

    let expectation = XCTestExpectation(description: "callback")
    api.echo(top) { result in
      switch result {
      case .success(let res):
        XCTAssertEqual(1, res.testList?.count)
        XCTAssertTrue(res.testList?[0] is TestMessage)
        XCTAssert(equalsList(inside.testList, (res.testList?[0] as! TestMessage).testList))
        expectation.fulfill()
      case .failure(_):
        return
      }
    }
    wait(for: [expectation], timeout: 1.0)
  }

}
