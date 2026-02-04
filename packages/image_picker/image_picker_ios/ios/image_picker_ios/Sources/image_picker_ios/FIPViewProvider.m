// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/image_picker_ios/FIPViewProvider.h"

@import UIKit;

@interface FIPDefaultViewProvider ()
/// The backing registrar.
@property(nonatomic) NSObject<FlutterPluginRegistrar> *registrar;
@end

@implementation FIPDefaultViewProvider
- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _registrar = registrar;
  }
  return self;
}

- (UIViewController *)viewController {
  return self.registrar.viewController;
}
@end
