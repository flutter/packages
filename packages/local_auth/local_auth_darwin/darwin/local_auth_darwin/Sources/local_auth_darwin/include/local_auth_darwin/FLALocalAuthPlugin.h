// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#import <TargetConditionals.h>

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#elif TARGET_OS_IOS
#import <Flutter/Flutter.h>
#endif

#import "messages.g.h"

@interface FLALocalAuthPlugin : NSObject <FlutterPlugin, FLADLocalAuthApi>

- (instancetype)init NS_UNAVAILABLE;

@end
