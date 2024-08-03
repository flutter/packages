// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTGoogleMarkerUserData.h"

@implementation FLTGoogleMarkerUserData

@end

void FLTSetIdentifiersToMarkerUserData(NSString *markerIdentifier,
                                       NSString *_Nullable clusterManagerIdentifier,
                                       GMSMarker *marker) {
  FLTGoogleMarkerUserData *userData = [[FLTGoogleMarkerUserData alloc] init];
  userData.markerIdentifier = markerIdentifier;
  userData.clusterManagerIdentifier = clusterManagerIdentifier;
  marker.userData = userData;
};

NSString *_Nullable FLTGetMarkerIdentifierFrom(GMSMarker *marker) {
  if ([marker.userData isKindOfClass:[FLTGoogleMarkerUserData class]]) {
    FLTGoogleMarkerUserData *userData = (FLTGoogleMarkerUserData *)marker.userData;
    return userData.markerIdentifier;
  }
  return nil;
};

NSString *_Nullable FLTGetClusterManagerIdentifierFrom(GMSMarker *marker) {
  if ([marker.userData isKindOfClass:[FLTGoogleMarkerUserData class]]) {
    FLTGoogleMarkerUserData *userData = (FLTGoogleMarkerUserData *)marker.userData;
    return userData.clusterManagerIdentifier;
  }
  return nil;
};
