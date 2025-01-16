// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import FlutterMacOS
import XCTest

@testable import image_picker_macos

/// The specified amount of time for waiting to check if an element exists.
let kElementWaitingTime: TimeInterval = 30

final class RunnerUITests: XCTestCase {

  var app: XCUIApplication!

  override func setUp() {
    continueAfterFailure = false
    app = XCUIApplication()
    app.launch()
  }

  override func tearDown() {
    app.terminate()
  }

  @MainActor
  func testImagePicker() throws {
    // TODO(EchoEllet): Lacks native UI tests https://discord.com/channels/608014603317936148/1300517990957056080/1300518056690188361
    //  https://github.com/flutter/flutter/issues/70234
  }
}
