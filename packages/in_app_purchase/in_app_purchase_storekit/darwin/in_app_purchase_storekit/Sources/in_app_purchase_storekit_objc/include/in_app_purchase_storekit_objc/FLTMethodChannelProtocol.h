// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

NS_ASSUME_NONNULL_BEGIN
/// A protocol that wraps FlutterMethodChannel.
@protocol FLTMethodChannelProtocol <NSObject>

/// Invokes the specified Flutter method with the specified arguments, expecting
/// an asynchronous result.
- (void)invokeMethod:(NSString *)method arguments:(id _Nullable)arguments;

/// Invokes the specified Flutter method with the specified arguments and specified callback
- (void)invokeMethod:(NSString *)method
           arguments:(id _Nullable)arguments
              result:(FlutterResult _Nullable)callback;

@end

/// The default method channel that wraps FlutterMethodChannel
@interface DefaultMethodChannel : NSObject <FLTMethodChannelProtocol>

/// Initialize this wrapper with a FlutterMethodChannel
- (instancetype)initWithChannel:(FlutterMethodChannel *)channel;
@end

NS_ASSUME_NONNULL_END
