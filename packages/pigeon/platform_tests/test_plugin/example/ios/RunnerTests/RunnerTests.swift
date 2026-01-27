// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Foundation
import Testing

@testable import test_plugin

@MainActor
struct RunnerTests {

  @Test
  func toListAndBack() throws {
    let reply = MessageSearchReply(result: "foobar")
    let dict = reply.toList()
    let copy = MessageSearchReply.fromList(dict)
    #expect(reply.result == copy?.result)
  }

  @Test
  func handlesNull() throws {
    let reply = MessageSearchReply()
    let dict = reply.toList()
    let copy = MessageSearchReply.fromList(dict)
    #expect(copy?.result == nil)
  }

  @Test
  func handlesNullFirst() throws {
    let reply = MessageSearchReply(error: "foobar")
    let dict = reply.toList()
    let copy = MessageSearchReply.fromList(dict)
    #expect(reply.error == copy?.error)
  }

  /// This validates that pigeon clients can easily write tests that mock out Flutter API
  /// calls using a pigeon-generated protocol.
  @Test
  func echoStringFromProtocol() async throws {
    let api: FlutterApiFromProtocol = FlutterApiFromProtocol()
    let aString = "aString"
    await confirmation { confirmed in
      api.echo(string: aString) { response in
        switch response {
        case .success(let res):
          #expect(aString == res)
        case .failure(let error):
          Issue.record(error)
        }
        confirmed()
      }
    }
  }
}

class FlutterApiFromProtocol: FlutterSmallApiProtocol {
  func echo(
    string aStringArg: String,
    completion: @escaping (Result<String, test_plugin.PigeonError>) -> Void
  ) {
    completion(.success(aStringArg))
  }

  func echo(
    _ msgArg: test_plugin.TestMessage,
    completion: @escaping (Result<test_plugin.TestMessage, test_plugin.PigeonError>) -> Void
  ) {
    completion(.success(msgArg))
  }
}
