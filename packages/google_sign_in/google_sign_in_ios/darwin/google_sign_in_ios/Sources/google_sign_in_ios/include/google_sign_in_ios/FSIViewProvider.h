// Copyright 2013 The Flutter Authors
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
@protocol FSIViewProvider <NSObject>
@required
#if TARGET_OS_OSX
/// The view containing the Flutter content.
@property(nonatomic, readonly, nullable) NSView *view;
#else
/// The view controller containing the Flutter content.
@property(nonatomic, readonly, nullable) UIViewController *viewController;
#endif
@end

NS_ASSUME_NONNULL_END
