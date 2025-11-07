// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "MockBinaryMessenger.h"

@implementation MockBinaryMessenger

- (instancetype)initWithCodec:(NSObject<FlutterMessageCodec> *)codec {
  self = [super init];
  if (self) {
    _codec = codec;
    _handlers = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)cleanupConnection:(FlutterBinaryMessengerConnection)connection {
}

- (void)sendOnChannel:(nonnull NSString *)channel message:(NSData *_Nullable)message {
}

- (void)sendOnChannel:(nonnull NSString *)channel
              message:(NSData *_Nullable)message
          binaryReply:(FlutterBinaryReply _Nullable)callback {
  if (self.result) {
    callback([_codec encode:@[ self.result ]]);
  }
}

- (FlutterBinaryMessengerConnection)setMessageHandlerOnChannel:(nonnull NSString *)channel
                                          binaryMessageHandler:
                                              (FlutterBinaryMessageHandler _Nullable)handler {
  _handlers[channel] = [handler copy];
  return _handlers.count;
}

- (void)cleanUpConnection:(FlutterBinaryMessengerConnection)connection {
}

@end
