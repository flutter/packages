// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "EchoMessenger.h"

@interface EchoBinaryMessenger ()
@property(nonatomic, strong) NSObject<FlutterMessageCodec> *codec;
@end

@implementation EchoBinaryMessenger {
  int _count;
}

- (instancetype)initWithCodec:(NSObject<FlutterMessageCodec> *)codec {
  self = [super init];
  if (self) {
    _codec = codec;
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
  id firstArg = args[0];
  callback([self.codec encode:firstArg]);
}

- (FlutterBinaryMessengerConnection)setMessageHandlerOnChannel:(nonnull NSString *)channel
                                          binaryMessageHandler:
                                              (FlutterBinaryMessageHandler _Nullable)handler {
  return ++_count;
}

@end
