// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import url_launcher_ios

final class URLLauncherTests: XCTestCase {

  private func createPlugin() -> FLTURLLauncherPlugin {
    let launcher = FakeLauncher()
    return FLTURLLauncherPlugin(launcher: launcher)
  }

  private func createPlugin(launcher: FakeLauncher) -> FLTURLLauncherPlugin {
    FLTURLLauncherPlugin(launcher: launcher)
  }

  func testCanLaunchSuccess() {
    var error: FlutterError?
    let result = createPlugin().canLaunchURL("good://url", error: &error)

    XCTAssertNotNil(result)
    XCTAssertTrue(result?.boolValue ?? false)
    XCTAssertNil(error)
  }

  func testCanLaunchFailure() {
    var error: FlutterError?
    let result = createPlugin().canLaunchURL("bad://url", error: &error)

    XCTAssertNotNil(result)
    XCTAssertFalse(result?.boolValue ?? true)
  }

  func testCanLaunchFailureWithInvalidURL() {
    var error: FlutterError?
    let result = createPlugin().canLaunchURL("urls can't have spaces", error: &error)

    if (error == nil) {
      // When linking against the iOS 17 SDK or later, NSURL uses a lenient parser, and won't
      // fail to parse URLs, so the test must allow for either outcome.
      XCTAssertNotNil(result)
      XCTAssertFalse(result?.boolValue ?? true)
      XCTAssertNil(error)
    } else {
      XCTAssertNil(result)
      XCTAssertNotNil(error)
      XCTAssertEqual(error?.code, "argument_error")
      XCTAssertEqual(error?.message, "Unable to parse URL")
      XCTAssertEqual(error?.details as? String, "Provided URL: urls can't have spaces")
    }
  }

  func testLaunchSuccess() {
    let expectation = XCTestExpectation(description: "completion called")
    createPlugin().launchURL("good://url", universalLinksOnly: false) { result, error in
      XCTAssertNotNil(result)
      XCTAssertTrue(result?.boolValue ?? false)
      XCTAssertNil(error)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }

  func testLaunchFailure() {
    let expectation = XCTestExpectation(description: "completion called")

    createPlugin().launchURL("bad://url", universalLinksOnly: false) { result, error in
      XCTAssertNotNil(result)
      XCTAssertFalse(result?.boolValue ?? true)
      XCTAssertNil(error)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }

  func testLaunchFailureWithInvalidURL() {
    let expectation = XCTestExpectation(description: "completion called")

    createPlugin().launchURL("urls can't have spaces", universalLinksOnly: false) { result, error in
      if (error == nil) {
        // When linking against the iOS 17 SDK or later, NSURL uses a lenient parser, and won't
        // fail to parse URLs, so the test must allow for either outcome.
        XCTAssertNotNil(result)
        XCTAssertFalse(result?.boolValue ?? true)
        XCTAssertNil(error)
      } else {
        XCTAssertNil(result)
        XCTAssertNotNil(error)
        XCTAssertEqual(error?.code, "argument_error")
        XCTAssertEqual(error?.message, "Unable to parse URL")
        XCTAssertEqual(error?.details as? String, "Provided URL: urls can't have spaces")
      }

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }

  func testLaunchWithoutUniversalLinks() {
    let launcher = FakeLauncher()
    let plugin = createPlugin(launcher: launcher)

    let expectation = XCTestExpectation(description: "completion called")
    plugin.launchURL("good://url", universalLinksOnly: false) { result, error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)

    XCTAssertEqual(launcher.passedOptions?[.universalLinksOnly] as? Bool, false)
  }

  func testLaunchWithUniversalLinks() {
    let launcher = FakeLauncher()
    let plugin = createPlugin(launcher: launcher)

    let expectation = XCTestExpectation(description: "completion called")

    plugin.launchURL("good://url", universalLinksOnly: true) { result, error in
      XCTAssertNil(error)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)

    XCTAssertEqual(launcher.passedOptions?[.universalLinksOnly] as? Bool, true)
  }

}

final private class FakeLauncher: NSObject, FULLauncher {
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
