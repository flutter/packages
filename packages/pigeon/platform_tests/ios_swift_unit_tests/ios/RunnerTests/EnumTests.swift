//
//  EnumTests.swift
//  RunnerTests
//
//  Created by Ailton Vieira on 01/03/22.
//  Copyright © 2022 The Flutter Authors. All rights reserved.
//

import XCTest
@testable import Runner

class EnumTests: XCTestCase {

    func testEcho() throws {
        let data = ACData(state: .Error)
        let binaryMessender = EchoBinaryMessenger(codec: ACEnumApi2HostCodec.shared)
        let api = ACEnumApi2Flutter(binaryMessenger: binaryMessender)
        
        let expectation = XCTestExpectation(description: "callback")
        api.echo(data: data) { result in
            XCTAssertEqual(data.state, result.state)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

}
