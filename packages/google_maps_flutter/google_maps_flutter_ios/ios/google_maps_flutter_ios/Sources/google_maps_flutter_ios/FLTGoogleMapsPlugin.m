// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/google_maps_flutter_ios/FLTGoogleMapsPlugin.h"

#pragma mark - GoogleMaps plugin implementation

@implementation FLTGoogleMapsPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FLTGoogleMapFactory *googleMapFactory = [[FLTGoogleMapFactory alloc] initWithRegistrar:registrar];
  [registrar registerViewFactory:googleMapFactory
                                withId:@"plugins.flutter.dev/google_maps_ios"
      gestureRecognizersBlockingPolicy:
          FlutterPlatformViewGestureRecognizersBlockingPolicyWaitUntilTouchesEnded];
}

@end
