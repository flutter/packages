// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FGMGroundOverlayController.h"

/// Internal APIs exposed for unit testing
@interface FGMGroundOverlayController (Test)

/// Ground Overlay instance the controller is attached to
@property(strong, nonatomic) GMSGroundOverlay *groundOverlay;

/// Function to update the gms ground overlay from platform ground overlay.
- (void)updateFromPlatformGroundOverlay:(FGMPlatformGroundOverlay *)groundOverlay
                              registrar:(NSObject<FlutterPluginRegistrar> *)registrar
                            screenScale:(CGFloat)screenScale;

@end
