// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FlutterMacOS
import Testing

@testable import url_launcher_macos

// Tests whether NSURL parsing is strict. When linking against the macOS 14 SDK or later,
// NSURL uses a more lenient parser which will not return nil.
private func urlParsingIsStrict() -> Bool {
  return URL(string: "b a d U R L") == nil
}

/// A stub to simulate the system Url handler.
private class StubWorkspace: SystemURLHandler {

  var isSuccessful = true

  func open(_ url: URL) -> Bool {
    return isSuccessful
  }

  func urlForApplication(toOpen: URL) -> URL? {
    return isSuccessful ? toOpen : nil
  }
}

struct RunnerTests {

  @Test(arguments: [
    (url: "https://flutter.dev", isSuccessful: true),
    (url: "example://flutter.dev", isSuccessful: false),
  ])
  func canLaunch(url: String, isSuccessful: Bool) throws {
    let workspace = StubWorkspace()
    workspace.isSuccessful = isSuccessful
    let plugin = UrlLauncherPlugin(workspace)

    let result = try plugin.canLaunch(url: url)
    #expect(result.error == nil)
    #expect(result.value == isSuccessful)
  }

  @Test func canLaunchInvalidUrlReturnsError() throws {
    let workspace = StubWorkspace()
    workspace.isSuccessful = false
    let plugin = UrlLauncherPlugin(workspace)

    let result = try plugin.canLaunch(url: "invalid url")
    if urlParsingIsStrict() {
      #expect(result.error == .invalidUrl)
    } else {
      #expect(!result.value)
    }
  }

  @Test(arguments: [
    (url: "https://flutter.dev", isSuccessful: true),
    (url: "schemethatdoesnotexist://flutter.dev", isSuccessful: false),
  ])
  func launch(url: String, isSuccessful: Bool) throws {
    let workspace = StubWorkspace()
    workspace.isSuccessful = isSuccessful
    let plugin = UrlLauncherPlugin(workspace)

    let result = try plugin.launch(url: url)
    #expect(result.error == nil)
    #expect(result.value == isSuccessful)
  }

  @Test func launchInvalidUrlReturnsError() throws {
    let workspace = StubWorkspace()
    workspace.isSuccessful = false
    let plugin = UrlLauncherPlugin(workspace)

    let result = try plugin.launch(url: "invalid url")
    if urlParsingIsStrict() {
      #expect(result.error == .invalidUrl)
    } else {
      #expect(!result.value)
    }
  }
}
