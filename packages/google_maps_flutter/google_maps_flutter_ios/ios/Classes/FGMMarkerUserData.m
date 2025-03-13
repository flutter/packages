// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FGMMarkerUserData.h"

@implementation FGMMarkerUserData

@end

void FGMSetIdentifiersToMarkerUserData(NSString *markerIdentifier,
                                       NSString *_Nullable clusterManagerIdentifier,
                                       GMSMarker *marker) {
  FGMMarkerUserData *userData = [[FGMMarkerUserData alloc] init];
  userData.markerIdentifier = markerIdentifier;
  userData.clusterManagerIdentifier = clusterManagerIdentifier;
  marker.userData = userData;
};

NSString *_Nullable FGMGetMarkerIdentifierFromMarker(GMSMarker *marker) {
  if ([marker.userData isKindOfClass:[FGMMarkerUserData class]]) {
    FGMMarkerUserData *userData = (FGMMarkerUserData *)marker.userData;
    return userData.markerIdentifier;
  }
  return nil;
};

NSString *_Nullable FGMGetClusterManagerIdentifierFromMarker(GMSMarker *marker) {
  if ([marker.userData isKindOfClass:[FGMMarkerUserData class]]) {
    FGMMarkerUserData *userData = (FGMMarkerUserData *)marker.userData;
    return userData.clusterManagerIdentifier;
  }
  return nil;
};
