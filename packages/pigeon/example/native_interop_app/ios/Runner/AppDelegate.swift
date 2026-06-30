// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import UIKit

private class PigeonApiImplementation: NativeInteropExampleApi {
  func doSomething() throws {
    // Do nothing
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// TODO(stuartmorgan): Once 3.33+ reaches stable, remove this subclass and move the setup to
// AppDelegate.register(...). This approach is only used because this example needs to support
// both stable and master, and 3.32 doesn't have FlutterPluginRegistrant, while 3.33+ can't use
// the older application(didFinishLaunchingWithOptions) approach.
@objc class ExampleViewController: FlutterViewController {
  override func awakeFromNib() {
    super.awakeFromNib()

    let api = PigeonApiImplementation()
    NativeInteropExampleApiSetup.register(api: api)

  }
}
