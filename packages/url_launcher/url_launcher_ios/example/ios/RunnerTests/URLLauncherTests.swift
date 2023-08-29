// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import url_launcher_ios

final class URLLauncherTests: XCTestCase {
  private var plugin: FLTURLLauncherPlugin!
  private var launcher: FakeLauncher!

  override func setUp() {
    launcher = FakeLauncher()
    plugin = FLTURLLauncherPlugin(launcher: launcher)
  }

  func testCanLaunchSuccess() {
    var error: FlutterError?
    let result = plugin.canLaunchURL("good://url", error: &error)

    XCTAssertTrue(result!.boolValue)
    XCTAssertNil(error)
  }

  func testCanLaunchFailure() {
    var error: FlutterError?
    let result = plugin.canLaunchURL("bad://url", error: &error)

    XCTAssertFalse(result!.boolValue)
  }

  func testCanLaunchFailureWithInvalidURL() {
    var error: FlutterError?
    let result = plugin.canLaunchURL("urls can't have spaces", error: &error)

    XCTAssertNil(result)
    XCTAssertNotNil(error)
    XCTAssertEqual(error!.code, "argument_error")
    XCTAssertEqual(error!.message, "Unable to parse URL")
    XCTAssertEqual(error!.details as! String, "Provided URL: urls can't have spaces")
  }

  func testLaunchSuccess() {
    let expectation = XCTestExpectation(description: "completion called")
    plugin.launchURL("good://url", universalLinksOnly: false) { result, error in
      XCTAssertTrue(result!.boolValue)
      XCTAssertNil(error)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }

  func testLaunchFailure() {
    let expectation = XCTestExpectation(description: "completion called")

    plugin.launchURL("bad://url", universalLinksOnly: false) { result, error in
      XCTAssertFalse(result!.boolValue)
      XCTAssertNil(error)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }

  func testLaunchFailureWithInvalidURL() {
    let expectation = XCTestExpectation(description: "completion called")

    plugin.launchURL("urls can't have spaces", universalLinksOnly: false) { result, error in
      XCTAssertNil(result)
      XCTAssertNotNil(error)
      XCTAssertEqual(error!.code, "argument_error")
      XCTAssertEqual(error!.message, "Unable to parse URL")
      XCTAssertEqual(error!.details as! String, "Provided URL: urls can't have spaces")

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }

  func testLaunchWithoutUniversalLinks() {
    let expectation = XCTestExpectation(description: "completion called")
    plugin.launchURL("good://url", universalLinksOnly: false) { result, error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)

    XCTAssertEqual(launcher.passedOptions?[.universalLinksOnly] as? Bool, false)
  }

  func testLaunchWithUniversalLinks() {
    let expectation = XCTestExpectation(description: "completion called")

    plugin.launchURL("good://url", universalLinksOnly: true) { result, error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)

    XCTAssertEqual(launcher.passedOptions?[.universalLinksOnly] as? Bool, true)
  }

}

final fileprivate class FakeLauncher: NSObject, FULLauncher {
  var passedOptions: [UIApplication.OpenExternalURLOptionsKey: Any]?

  func canOpen(_ url: URL) -> Bool {
    return url.scheme == "good"
  }

  func open(
    _ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any] = [:],
    completionHandler: ((Bool) -> Void)? = nil
  ) {
    self.passedOptions = options
    completionHandler?(url.scheme == "good")
  }
}

final fileprivate class FakeFlutterBinaryMessenger: NSObject, FlutterBinaryMessenger {
  func send(onChannel channel: String, message: Data?) {}

  func send(
    onChannel channel: String, message: Data?, binaryReply callback: FlutterBinaryReply? = nil
  ) {}

  func setMessageHandlerOnChannel(
    _ channel: String, binaryMessageHandler handler: FlutterBinaryMessageHandler? = nil
  ) -> FlutterBinaryMessengerConnection {
    123
  }

  func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) {}
}
