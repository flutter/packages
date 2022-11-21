// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Flutter

class EchoBinaryMessenger: NSObject, FlutterBinaryMessenger {
  let codec: FlutterMessageCodec
  private(set) var count = 0
  var defaultReturn: Any?
  
  init(codec: FlutterMessageCodec) {
    self.codec = codec
    super.init()
  }
  
  func send(onChannel channel: String, message: Data?) {
    // Method not implemented because this messenger is just for echoing
  }
  
  func send(
    onChannel channel: String,
    message: Data?,
    binaryReply callback: FlutterBinaryReply? = nil
  ) {
    guard let callback = callback else { return }
    
    guard
      let args = self.codec.decode(message) as? [Any?],
      let firstArg = args.first,
      !(firstArg is NSNull)
    else {
      callback(self.defaultReturn.flatMap { self.codec.encode($0) })
      return
    }
    
    callback(self.codec.encode(firstArg))
  }
  
  func setMessageHandlerOnChannel(
    _ channel: String, binaryMessageHandler handler:
    FlutterBinaryMessageHandler? = nil
  ) -> FlutterBinaryMessengerConnection {
    self.count += 1
    return FlutterBinaryMessengerConnection(self.count)
  }
  
  func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) {
    // Method not implemented because this messenger is just for echoing    
  }
}
