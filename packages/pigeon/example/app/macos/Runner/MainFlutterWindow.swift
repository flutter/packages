// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Cocoa
import FlutterMacOS

private class PigeonApiImplementation: ExampleHostApi {
  func getHostLanguage() throws -> String {
    return "Swift"
  }

  func add(_ a: Int64, to b: Int64) throws -> Int64 {
    if a < 0 || b < 0 {
      throw PigeonError(code: "code", message: "message", details: "details")
    }
    return a + b
  }

  func sendMessage(message: MessageData, completion: @escaping (Result<Bool, Error>) -> Void) {
    if message.code == Code.one {
      completion(.failure(PigeonError(code: "code", message: "message", details: "details")))
      return
    }
    completion(.success(true))
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
