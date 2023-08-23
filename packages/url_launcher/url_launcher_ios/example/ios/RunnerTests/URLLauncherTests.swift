// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import url_launcher_ios

class URLLauncherTests: XCTestCase {
    var plugin: URLLauncherPlugin!
    var launcher: FakeLauncher!

    override func setUp() {
        launcher = FakeLauncher()
        plugin = URLLauncherPlugin(launcher: launcher, binaryMessenger: FakeFlutterBinaryMessenger())
    }

    func testCanLaunchSuccess() {
        let result = plugin.canLaunchUrl(url: "good://url")

        XCTAssertTrue(result)
    }

    func testCanLaunchFailure() {
        let result = plugin.canLaunchUrl(url: "bad://url")

        XCTAssertFalse(result)
    }

    func testCanLaunchFailureWithInvalidURL() {
        let result = plugin.canLaunchUrl(url: "urls can't have spaces")

        XCTAssertFalse(result)
    }

    func testLaunchSuccess() {
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
    }

    func testLaunchFailure() {
        let expectation = XCTestExpectation(description: "completion called")
        plugin.launchUrl(url: "bad://url", universalLinksOnly: false) { result in
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
        plugin.launchUrl(url: "urls can't have spaces", universalLinksOnly: false) { result in
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

class FakeLauncher: Launcher {
  var passedOptions: [UIApplication.OpenExternalURLOptionsKey: Any]?

  func canOpenURL(_ url: URL) -> Bool {
    return url.scheme == "good"
  }

  func openURL(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any] = [:], completionHandler: ((Bool) -> Void)? = nil) {
    self.passedOptions = options
    completionHandler?(url.scheme == "good")
  }
}

class FakeFlutterBinaryMessenger: NSObject, FlutterBinaryMessenger {
    func send(onChannel channel: String, message: Data?) { }

    func send(onChannel channel: String, message: Data?, binaryReply callback: FlutterBinaryReply? = nil) { }

    func setMessageHandlerOnChannel(_ channel: String, binaryMessageHandler handler: FlutterBinaryMessageHandler? = nil) -> FlutterBinaryMessengerConnection {
        123
    }

    func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) { }
}
