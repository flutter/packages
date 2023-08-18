// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import XCTest

@testable import url_launcher_ios

class URLLauncherTests: XCTestCase {
    var plugin: URLLauncherPlugin!

    override func setUp() {
        let launcher = FakeLauncher()
        plugin = URLLauncherPlugin(launcher: launcher)
    }

    func testCanLaunchSuccess() {
        let result = try? plugin.canLaunchUrl(url: "good://url")

        XCTAssertTrue(result!)
    }

    func testCanLaunchFailure() {
        let result = try? plugin.canLaunchUrl(url: "bad://url")

        XCTAssertFalse(result!)
    }

    func testCanLaunchFailureWithInvalidURL() {
        XCTAssertThrowsError(try plugin.canLaunchUrl(url: "not a url"))
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
