// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Cocoa
import FlutterMacOS

private class PigeonApiImplementation: NativeInteropExampleApi {
  func doSomething() throws {
    // In a real application, native platform logic (e.g., accessing macOS system APIs,
    // hardware features, or third-party native frameworks) would be implemented here.
    print("NativeInteropExampleApi.doSomething called from Dart")
  }
}

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    let api = PigeonApiImplementation()
    NativeInteropExampleApiSetup.register(api: api)

    super.awakeFromNib()
  }
}
