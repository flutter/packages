// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
@testable import Runner

class EnumTests: XCTestCase {

    func testEcho() throws {
        let data = DataWithEnum(state: .error)
        let binaryMessenger = EchoBinaryMessenger(codec: EnumApi2HostCodec.shared)
        let api = EnumApi2Flutter(binaryMessenger: binaryMessenger)
        
        let expectation = XCTestExpectation(description: "callback")
        api.echo(data: data) { result in
            XCTAssertEqual(data.state, result.state)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

}
