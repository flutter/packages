// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

/// Protocol for obtaining the view controller containing the Flutter content.
@protocol FIPViewProvider <NSObject>
@required
/// The view controller containing the Flutter content.
@property(nonatomic, readonly, nullable) UIViewController *viewController;
@end

/// A default implementation of the FIPViewProvider protocol.
@interface FIPDefaultViewProvider : NSObject <FIPViewProvider>
/// Returns a provider backed by the given registrar.
- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar
    NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
