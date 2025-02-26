// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "MockGlobalEventApi.h"

@implementation MockGlobalEventApi
- (void)deviceOrientationChangedOrientation:(FCPPlatformDeviceOrientation)orientation
                                 completion:(void (^)(FlutterError *_Nullable))completion {
  self.deviceOrientationChangedCalled = YES;
  self.lastOrientation = orientation;
  completion(nil);
}

- (FlutterBinaryMessengerConnection)setMessageHandlerOnChannel:(nonnull NSString *)channel
                                          binaryMessageHandler:
                                              (nullable FlutterBinaryMessageHandler)handler {
  return 0;
}

@end
