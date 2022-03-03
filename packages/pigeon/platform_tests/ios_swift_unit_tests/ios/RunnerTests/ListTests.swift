// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
@testable import Runner

class ListTests: XCTestCase {

    func testListInList() throws {
        let inside = TestMessage(testList: [1, 2, 3])
        let top = TestMessage(testList: [inside])
        let binaryMessenger = EchoBinaryMessenger(codec: EchoApiCodec.shared)
        let api = EchoApi(binaryMessenger: binaryMessenger)
        
        let expectation = XCTestExpectation(description: "callback")
        api.echo(msg: top) { result in
            XCTAssertEqual(1, result.testList?.count)
            XCTAssertTrue(result.testList?[0] is TestMessage)
            XCTAssert(equalsList(inside.testList, (result.testList?[0] as! TestMessage).testList))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

}
