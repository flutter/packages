// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/video_player_avfoundation/FVPViewProvider.h"

#if TARGET_OS_OSX
@import Cocoa;
#else
@import UIKit;
#endif

@interface FVPDefaultViewProvider ()
/// The backing registrar.
@property(nonatomic) NSObject<FlutterPluginRegistrar> *registrar;
@end

@implementation FVPDefaultViewProvider
- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _registrar = registrar;
  }
  return self;
}

#if TARGET_OS_OSX
- (NSView *)view {
  return self.registrar.view;
}
#else
- (UIView *)view {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  // TODO(hellohuanlin): Provide a non-deprecated codepath. See
  // https://github.com/flutter/flutter/issues/104117
  UIViewController *root = UIApplication.sharedApplication.keyWindow.rootViewController;
#pragma clang diagnostic pop
  return root.view;
}
#endif
@end
