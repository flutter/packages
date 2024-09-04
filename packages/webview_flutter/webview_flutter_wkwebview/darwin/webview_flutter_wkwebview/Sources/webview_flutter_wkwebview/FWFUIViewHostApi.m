// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Using directory structure to remove platform-specific files doesn't work
// well with umbrella headers and module maps, so just no-op the file for
// other platforms instead.
#if TARGET_OS_IOS

#import "./include/webview_flutter_wkwebview/FWFUIViewHostApi.h"

@interface FWFUIViewHostApiImpl ()
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) FWFInstanceManager *instanceManager;
@end

@implementation FWFUIViewHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (UIView *)viewForIdentifier:(NSInteger)identifier {
  return (UIView *)[self.instanceManager instanceForIdentifier:identifier];
}

- (void)setBackgroundColorForViewWithIdentifier:(NSInteger)identifier
                                        toValue:(nullable NSNumber *)color
                                          error:(FlutterError *_Nullable *_Nonnull)error {
  if (color == nil) {
    [[self viewForIdentifier:identifier] setBackgroundColor:nil];
  }
  int colorInt = color.intValue;
  UIColor *colorObject = [UIColor colorWithRed:(colorInt >> 16 & 0xff) / 255.0
                                         green:(colorInt >> 8 & 0xff) / 255.0
                                          blue:(colorInt & 0xff) / 255.0
                                         alpha:(colorInt >> 24 & 0xff) / 255.0];
  [[self viewForIdentifier:identifier] setBackgroundColor:colorObject];
}

- (void)setOpaqueForViewWithIdentifier:(NSInteger)identifier
                              isOpaque:(BOOL)opaque
                                 error:(FlutterError *_Nullable *_Nonnull)error {
  [[self viewForIdentifier:identifier] setOpaque:opaque];
}
@end

#endif
