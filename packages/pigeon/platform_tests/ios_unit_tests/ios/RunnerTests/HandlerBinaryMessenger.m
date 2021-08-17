// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "HandlerBinaryMessenger.h"

@interface HandlerBinaryMessenger ()
@property(nonatomic, strong) NSObject<FlutterMessageCodec> *codec;
@property(nonatomic, copy) HandlerBinaryMessengerHandler handler;
@end

@implementation HandlerBinaryMessenger {
  int _count;
}

- (instancetype)initWithCodec:(NSObject<FlutterMessageCodec> *)codec
                      handler:(HandlerBinaryMessengerHandler)handler {
  self = [super init];
  if (self) {
    _codec = codec;
    _handler = [handler copy];
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
  NSArray *args = [self.codec decode:message];
  id result = self.handler(args);
  callback([self.codec encode:result]);
}

- (FlutterBinaryMessengerConnection)setMessageHandlerOnChannel:(nonnull NSString *)channel
                                          binaryMessageHandler:
                                              (FlutterBinaryMessageHandler _Nullable)handler {
  return ++_count;
}

@end
