// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FlutterMacOS
import XCTest

@testable import url_launcher_macos

// Tests whether NSURL parsing is strict. When linking against the macOS 14 SDK or later,
// NSURL uses a more lenient parser which will not return nil.
private func urlParsingIsStrict() -> Bool {
  return URL(string: "b a d U R L") == nil
}

/// A stub to simulate the system Url handler.
class StubWorkspace: SystemURLHandler {

  var isSuccessful = true

  func open(_ url: URL) -> Bool {
    return isSuccessful
  }

  func urlForApplication(toOpen: URL) -> URL? {
    return toOpen
  }
}

class RunnerTests: XCTestCase {

  func testCanLaunchSuccessReturnsTrue() throws {
    let plugin = UrlLauncherPlugin()

    let result = try plugin.canLaunch(url: "https://flutter.dev")
    XCTAssertNil(result.error)
    XCTAssertTrue(result.value)
  }

  func testCanLaunchNoAppIsAbleToOpenUrlReturnsFalse() throws {
    let plugin = UrlLauncherPlugin()

    let result = try plugin.canLaunch(url: "example://flutter.dev")
    XCTAssertNil(result.error)
    XCTAssertFalse(result.value)
  }

  func testCanLaunchInvalidUrlReturnsError() throws {
    let plugin = UrlLauncherPlugin()

    let result = try plugin.canLaunch(url: "invalid url")
    if urlParsingIsStrict() {
      XCTAssertEqual(result.error, .invalidUrl)
    } else {
      XCTAssertFalse(result.value)
    }
  }

  func testLaunchSuccessReturnsTrue() throws {
    let workspace = StubWorkspace()
    let plugin = UrlLauncherPlugin(workspace)

    let result = try plugin.launch(url: "https://flutter.dev")
    XCTAssertNil(result.error)
    XCTAssertTrue(result.value)
  }

  func testLaunchNoAppIsAbleToOpenUrlReturnsFalse() throws {
    let workspace = StubWorkspace()
    workspace.isSuccessful = false
    let plugin = UrlLauncherPlugin(workspace)

    let result = try plugin.launch(url: "schemethatdoesnotexist://flutter.dev")
    XCTAssertNil(result.error)
    XCTAssertFalse(result.value)
  }

  func testLaunchInvalidUrlReturnsError() throws {
    let plugin = UrlLauncherPlugin()

    let result = try plugin.launch(url: "invalid url")
    if urlParsingIsStrict() {
      XCTAssertEqual(result.error, .invalidUrl)
    } else {
      XCTAssertFalse(result.value)
    }
  }
}
