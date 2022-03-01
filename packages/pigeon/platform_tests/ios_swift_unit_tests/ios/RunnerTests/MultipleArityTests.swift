//
//  MultipleArityTests.swift
//  RunnerTests
//
//  Created by Ailton Vieira on 01/03/22.
//  Copyright © 2022 The Flutter Authors. All rights reserved.
//

import XCTest
@testable import Runner

class MultipleArityTests: XCTestCase {

    func testSimple() throws {
        let binaryMessenger = HandlerBinaryMessenger(codec: MAMultipleArityHostApiCodec.shared) { args in
            return (args[0] as! Int) - (args[1] as! Int)
        }
        let api = MAMultipleArityFlutterApi(binaryMessenger: binaryMessenger)
        
        let expectation = XCTestExpectation(description: "subtraction")
        api.subtract(x: 30, y: 10) { result in
            XCTAssertEqual(20, result)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

}
