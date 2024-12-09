// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;

#import "FLTEventChannelProtocol.h"

@interface FLTDefaultEventChannel ()
@property(nonatomic, strong) FlutterEventChannel *channel;
@end

@implementation FLTDefaultEventChannel

- (instancetype)initWithEventChannel:(FlutterEventChannel *)channel {
  self = [super init];
  if (self) {
    _channel = channel;
  }
  return self;
}

- (void)setStreamHandler:(NSObject<FlutterStreamHandler> *)handler {
  [self.channel setStreamHandler:handler];
}

@end
