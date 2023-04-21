// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Cocoa
import FlutterMacOS

private class PigeonApiImplementation: ExampleHostApi {
  func getHostLanguage() throws -> String {
    return "Swift"
  }
}

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    let hostApi = PigeonApiImplementation()
    ExampleHostApiSetup.setUp(
      binaryMessenger: flutterViewController.engine.binaryMessenger, api: hostApi)

    super.awakeFromNib()
  }
}
