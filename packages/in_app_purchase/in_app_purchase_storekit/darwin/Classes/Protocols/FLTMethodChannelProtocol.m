// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTMethodChannelProtocol.h"

@interface DefaultMethodChannel ()
/// The wrapped FlutterMethodChannel
@property(nonatomic, strong) FlutterMethodChannel *channel;
@end

@implementation DefaultMethodChannel

- (instancetype)initWithChannel:(nonnull FlutterMethodChannel *)channel {
  self = [super init];
  if (self) {
    _channel = channel;
  }
  return self;
}

- (void)invokeMethod:(nonnull NSString *)method arguments:(id _Nullable)arguments {
  [self.channel invokeMethod:method arguments:arguments];
}

- (void)invokeMethod:(nonnull NSString *)method
           arguments:(id _Nullable)arguments
              result:(FlutterResult _Nullable)callback {
  [self.channel invokeMethod:method arguments:arguments result:callback];
}

@end
