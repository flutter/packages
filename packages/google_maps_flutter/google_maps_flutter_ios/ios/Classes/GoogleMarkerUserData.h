// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

/// Defines user data object for markers.
@interface GoogleMarkerUserData : NSObject

/// The identifier of the marker.
@property(nonatomic, copy) NSString *markerIdentifier;

/// The identifier of the cluster manager.
/// This property is set only if the marker is managed by a cluster manager.
@property(nonatomic, copy) NSString *clusterManagerIdentifier;

@end
