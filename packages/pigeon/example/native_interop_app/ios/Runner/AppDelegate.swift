// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import UIKit

private class PigeonApiImplementation: ExampleHostApi {
  func determineHostLanguage() throws -> String {
    return "Swift"
  }

  func add(_ a: Int64, to b: Int64) throws -> Int64 {
    if a < 0 || b < 0 {
      throw PigeonError(code: "code", message: "message", details: "details")
    }
    return a + b
  }

  func sendMessage(message: MessageData) async throws -> Bool {
    if message.code == Code.one {
      throw PigeonError(code: "code", message: "message", details: "details")
    }
    return true
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
    ExampleHostApiSetup.register(api: api)

  }
}
