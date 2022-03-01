//
//  ListTests.swift
//  RunnerTests
//
//  Created by Ailton Vieira on 01/03/22.
//  Copyright © 2022 The Flutter Authors. All rights reserved.
//

import XCTest
@testable import Runner

class ListTests: XCTestCase {

    func testListInList() throws {
        let inside = LSTTestMessage(testList: [1, 2, 3])
        let top = LSTTestMessage(testList: [inside])
        let binaryMessenger = EchoBinaryMessenger(codec: LSTEchoApiCodec.shared)
        let api = LSTEchoApi(binaryMessenger: binaryMessenger)
        
        let expectation = XCTestExpectation(description: "callback")
        api.echo(msg: top) { result in
            XCTAssertEqual(1, result.testList?.count)
            XCTAssertTrue(result.testList?[0] is LSTTestMessage)
            XCTAssert(equalsList(inside.testList, (result.testList?[0] as! LSTTestMessage).testList))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

}
