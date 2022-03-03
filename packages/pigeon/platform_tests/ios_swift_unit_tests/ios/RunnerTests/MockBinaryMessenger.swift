// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
@testable import Runner

class MockBinaryMessenger: NSObject, FlutterBinaryMessenger {
    let codec: FlutterMessageCodec
    var result: Value?
    private(set) var handlers: [String: FlutterBinaryMessageHandler] = [:]
    
    init(codec: FlutterMessageCodec) {
        self.codec = codec
        super.init()
    }
    
    func send(onChannel channel: String, message: Data?) {}
    
    func send(onChannel channel: String, message: Data?, binaryReply callback: FlutterBinaryReply? = nil) {
        if let result = result {
            callback?(codec.encode(result))
        }
    }
    
    func setMessageHandlerOnChannel(_ channel: String, binaryMessageHandler handler: FlutterBinaryMessageHandler? = nil) -> FlutterBinaryMessengerConnection {
        handlers[channel] = handler
        return .init(handlers.count)
    }
    
    func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) {}
}
