// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import url_launcher_ios

final class URLLauncherTests: XCTestCase {

  private func createPlugin() -> URLLauncherPlugin {
    let launcher = FakeLauncher()
    return URLLauncherPlugin(launcher: launcher)
  }

  private func createPlugin(launcher: FakeLauncher) -> URLLauncherPlugin {
    return URLLauncherPlugin(launcher: launcher)
  }

  func testCanLaunchSuccess() {
    let result = createPlugin().canLaunchUrl(url: "good://url")

    XCTAssertTrue(result)
  }

  func testCanLaunchFailure() {
    let result = createPlugin().canLaunchUrl(url: "bad://url")

    XCTAssertFalse(result)
  }

  func testCanLaunchFailureWithInvalidURL() {
    let result = createPlugin().canLaunchUrl(url: "urls can't have spaces")

    XCTAssertFalse(result)
  }

  func testLaunchSuccess() {
    let expectation = XCTestExpectation(description: "completion called")
    createPlugin().launchUrl(url: "good://url", universalLinksOnly: false) { result in
      switch result {
      case .success(let success):
        XCTAssertTrue(success)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }

  func testLaunchFailure() {
    let expectation = XCTestExpectation(description: "completion called")
    createPlugin().launchUrl(url: "bad://url", universalLinksOnly: false) { result in
      switch result {
      case .success(let success):
        XCTAssertFalse(success)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }

  func testLaunchFailureWithInvalidURL() {
    let expectation = XCTestExpectation(description: "completion called")
    createPlugin().launchUrl(url: "urls can't have spaces", universalLinksOnly: false) { result in
      switch result {
      case .success(_):
        XCTFail("Expected an error")
      case .failure(let error):
        let generalError = error as! GeneralError
        XCTAssertEqual(generalError.code, "argument_error")
        XCTAssertEqual(generalError.message, "Unable to parse URL")
        XCTAssertEqual(generalError.details, "Provided URL: urls can't have spaces")
      }
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }

  func testLaunchWithoutUniversalLinks() {
    let launcher = FakeLauncher()
    let plugin = createPlugin(launcher: launcher)

    let expectation = XCTestExpectation(description: "completion called")
    plugin.launchUrl(url: "good://url", universalLinksOnly: false) { result in
      switch result {
      case .success(let success):
        XCTAssertTrue(success)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(launcher.passedOptions?[.universalLinksOnly] as? Bool, false)
  }

  func testLaunchWithUniversalLinks() {
    let launcher = FakeLauncher()
    let plugin = createPlugin(launcher: launcher)

    let expectation = XCTestExpectation(description: "completion called")
    plugin.launchUrl(url: "good://url", universalLinksOnly: true) { result in
      switch result {
      case .success(let success):
        XCTAssertTrue(success)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(launcher.passedOptions?[.universalLinksOnly] as? Bool, true)
  }

}

final private class FakeLauncher: NSObject, Launcher {
  var passedOptions: [UIApplication.OpenExternalURLOptionsKey: Any]?

  func canOpenURL(_ url: URL) -> Bool {
    url.scheme == "good"
  }

  func openURL(
    _ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any],
    completionHandler completion: ((Bool) -> Void)?
  ) {
    self.passedOptions = options
    completion?(url.scheme == "good")
  }
}
