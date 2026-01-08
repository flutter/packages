// Copyright 2013 The Flutter Authors
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
- (UIViewController *)viewController {
  return self.registrar.viewController;
}
#endif
@end
