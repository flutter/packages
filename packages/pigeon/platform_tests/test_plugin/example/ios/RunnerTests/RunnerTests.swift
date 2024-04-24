// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Foundation
import XCTest

@testable import test_plugin

class RunnerTests: XCTestCase {

  func testToListAndBack() throws {
    let reply = MessageSearchReply(result: "foobar")
    let dict = reply.toList()
    let copy = MessageSearchReply.fromList(dict)
    XCTAssertEqual(reply.result, copy?.result)
  }

  func testHandlesNull() throws {
    let reply = MessageSearchReply()
    let dict = reply.toList()
    let copy = MessageSearchReply.fromList(dict)
    XCTAssertNil(copy?.result)
  }

  func testHandlesNullFirst() throws {
    let reply = MessageSearchReply(error: "foobar")
    let dict = reply.toList()
    let copy = MessageSearchReply.fromList(dict)
    XCTAssertEqual(reply.error, copy?.error)
  }

  /// This validates that pigeon clients can easily write tests that mock out Flutter API
  /// calls using a pigeon-generated protocol.
  func testEchoStringFromProtocol() throws {
    let api: FlutterApiFromProtocol = FlutterApiFromProtocol()
    let aString = "aString"
    api.echo(string: aString) { response in
      switch response {
      case .success(let res):
        XCTAssertEqual(aString, res)
      case .failure(let error):
        XCTFail(error.code)
      }
    }
  }
}

class FlutterApiFromProtocol: FlutterSmallApiProtocol {
  func echo(string aStringArg: String, completion: @escaping (Result<String, FlutterError>) -> Void)
  {
    completion(.success(aStringArg))
  }

  func echo(
    _ msgArg: test_plugin.TestMessage,
    completion: @escaping (Result<test_plugin.TestMessage, FlutterError>) -> Void
  ) {
    completion(.success(msgArg))
  }
}
