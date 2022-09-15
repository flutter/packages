// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Cocoa
import FlutterMacOS

public class MyApi: Api {
  public init() {}
  func getPlatform() -> String {
    return "macOS " + ProcessInfo.processInfo.operatingSystemVersionString
  }
}

public class MacosSwiftUnitTestsPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    ApiSetup.setUp(binaryMessenger: registrar.messenger, api: MyApi())
  }
}
