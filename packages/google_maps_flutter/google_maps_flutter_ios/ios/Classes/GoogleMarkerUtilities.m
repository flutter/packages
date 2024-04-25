// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMarkerUtilities.h"
#import "GoogleMarkerUserData.h"

@implementation GoogleMarkerUtilities

+ (void)setMarkerIdentifier:(NSString *)markerIdentifier for:(GMSMarker*)marker {
  GoogleMarkerUserData *userData = [[GoogleMarkerUserData alloc] init];
  userData.markerIdentifier = markerIdentifier;
  marker.userData = userData;
}

+ (void)setMarkerIdentifier:(NSString *)markerIdentifier andClusterManagerIdentifier:(NSString *)clusterManagerIdentifier for:(GMSMarker*)marker {
  GoogleMarkerUserData *userData = [[GoogleMarkerUserData alloc] init];
  userData.markerIdentifier = markerIdentifier;
  userData.clusterManagerIdentifier = clusterManagerIdentifier;
  marker.userData = userData;
}

+ (nullable NSString *)getMarkerIdentifierFrom:(GMSMarker *)marker {
  if ([marker.userData isKindOfClass:[GoogleMarkerUserData class]]) {
    GoogleMarkerUserData *userData = (GoogleMarkerUserData *)marker.userData;
    return userData.markerIdentifier;
  }
  return nil;
}

+ (nullable NSString *)getClusterManagerIdentifierFrom:(GMSMarker *)marker {
  if ([marker.userData isKindOfClass:[GoogleMarkerUserData class]]) {
    GoogleMarkerUserData *userData = (GoogleMarkerUserData *)marker.userData;
    return userData.clusterManagerIdentifier;
  }
  return nil;
}
@end
