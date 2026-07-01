// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FGMGoogleMapsPlugin.h"

@import GoogleMaps;

#pragma mark - GoogleMaps plugin implementation

// Declares a GMSServices method that was added in SDK 9.2, so that it can be
// conditionally called. It is declared on NSObject to avoid duplicate
// declaration errors when compiling with newer SDKs.
// TODO(stuartmorgan): Remove this once all packages sharing this file require
// SDK 9.2 or later. See https://github.com/flutter/flutter/issues/187106
@interface NSObject (MapsSDK92Extensions)
+ (void)addInternalUsageAttributionID:(nonnull NSString *)internalUsageAttributionID;
@end

@implementation FGMGoogleMapsPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FGMGoogleMapFactory *googleMapFactory = [[FGMGoogleMapFactory alloc] initWithRegistrar:registrar];
  [registrar registerViewFactory:googleMapFactory
                                withId:@"plugins.flutter.dev/google_maps_ios"
      gestureRecognizersBlockingPolicy:
          FlutterPlatformViewGestureRecognizersBlockingPolicyWaitUntilTouchesEnded];
  if ([GMSServices respondsToSelector:@selector(addInternalUsageAttributionID:)]) {
    [GMSServices addInternalUsageAttributionID:@"gmp_flutter_googlemapsflutter_ios"];
  }
}

@end
