// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if TARGET_OS_OSX
@import Cocoa;
@import FlutterMacOS;
#else
@import Flutter;
@import UIKit;
#endif

NS_ASSUME_NONNULL_BEGIN

/// Protocol for obtaining the view containing the Flutter content.
@protocol FVPViewProvider <NSObject>
@required
#if TARGET_OS_OSX
/// The view containing the Flutter content.
@property(nonatomic, readonly, nullable) NSView *view;
#else
/// The view containing the Flutter content.
@property(nonatomic, readonly, nullable) UIView *view;
#endif
@end

/// A default implementation of the FVPAVFactory protocol.
@interface FVPDefaultViewProvider : NSObject <FVPViewProvider>
/// Returns a provider backed by the given registrar.
- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar
    NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
