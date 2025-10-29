// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import url_launcher_ios

// Tests whether NSURL parsing is strict. When linking against the iOS 17 SDK or later,
// NSURL uses a more lenient parser which will not return nil.
private func urlParsingIsStrict() -> Bool {
  return URL(string: "b a d U R L") == nil
}

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
    XCTAssertEqual(result, .success)
  }

  func testCanLaunchFailure() {
    let result = createPlugin().canLaunchUrl(url: "bad://url")
    XCTAssertEqual(result, .failure)
  }

  func testCanLaunchFailureWithInvalidURL() {
    let result = createPlugin().canLaunchUrl(url: "urls can't have spaces")

    if urlParsingIsStrict() {
      XCTAssertEqual(result, .invalidUrl)
    } else {
      XCTAssertEqual(result, .failure)
    }
  }

  func testLaunchSuccess() {
    let expectation = XCTestExpectation(description: "completion called")
    createPlugin().launchUrl(url: "good://url", universalLinksOnly: false) { result in
      switch result {
      case .success(let details):
        XCTAssertEqual(details, .success)
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
      case .success(let details):
        XCTAssertEqual(details, .failure)
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
      case .success(let details):
        if urlParsingIsStrict() {
          XCTAssertEqual(details, .invalidUrl)
        } else {
          XCTAssertEqual(details, .failure)
        }
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
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
      case .success(let details):
        XCTAssertEqual(details, .success)
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
      case .success(let details):
        XCTAssertEqual(details, .success)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(launcher.passedOptions?[.universalLinksOnly] as? Bool, true)
  }

  func testLaunchSafariViewControllerWithClose() {
    let launcher = FakeLauncher()
    let plugin = createPlugin(launcher: launcher)

    let expectation = XCTestExpectation(description: "completion called")
    plugin.openUrlInSafariViewController(url: "https://flutter.dev") { result in
      switch result {
      case .success(let details):
        XCTAssertEqual(details, .dismissed)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }
    plugin.closeSafariViewController()
    wait(for: [expectation], timeout: 30)
  }

}

final private class FakeLauncher: NSObject, Launcher {
  var passedOptions: [UIApplication.OpenExternalURLOptionsKey: Any]?

  func canOpenURL(_ url: URL) -> Bool {
    url.scheme == "good"
  }

  func open(
    _ url: URL,
    options: [UIApplication.OpenExternalURLOptionsKey: Any],
    completionHandler completion: ((Bool) -> Void)?
  ) {
    self.passedOptions = options
    completion?(url.scheme == "good")
  }
}
