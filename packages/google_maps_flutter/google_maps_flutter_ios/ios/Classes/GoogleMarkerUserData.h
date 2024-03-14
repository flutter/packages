// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

// Defines user data object for markers.
@interface GoogleMarkerUserData : NSObject

@property(nonatomic, strong) NSString *markerIdentifier;
@property(nonatomic, strong) NSString *clusterManagerIdentifier;

@end
