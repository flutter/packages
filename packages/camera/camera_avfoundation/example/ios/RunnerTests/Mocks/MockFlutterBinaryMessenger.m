// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "MockFlutterBinaryMessenger.h"

@implementation MockFlutterBinaryMessenger

- (void)cleanUpConnection:(FlutterBinaryMessengerConnection)connection {
}

- (void)sendOnChannel:(nonnull NSString *)channel message:(NSData *_Nullable)message {
}

- (void)sendOnChannel:(nonnull NSString *)channel
              message:(NSData *_Nullable)message
          binaryReply:(FlutterBinaryReply _Nullable)callback {
}

- (FlutterBinaryMessengerConnection)setMessageHandlerOnChannel:(nonnull NSString *)channel
                                          binaryMessageHandler:
                                              (FlutterBinaryMessageHandler _Nullable)handler {
  return 0;
}

@end
