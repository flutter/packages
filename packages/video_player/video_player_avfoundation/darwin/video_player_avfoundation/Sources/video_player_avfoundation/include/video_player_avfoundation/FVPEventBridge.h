// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

#import "FVPVideoEventListener.h"

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

/// An implementation of FVPVideoEventListener that forwards messages to Dart via an event channel.
@interface FVPEventBridge : NSObject <FVPVideoEventListener>

/// Initializes the the bridge to use an event channel with the given name.
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
                      channelName:(NSString *)channelName;

@end
