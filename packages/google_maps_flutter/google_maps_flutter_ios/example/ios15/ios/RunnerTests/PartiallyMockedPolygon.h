// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import GoogleMaps;

/**
 * Defines a marker used for testing the call order of setters.
 */
@interface PartiallyMockedPolygon : GMSPolygon

@property(nonatomic, assign, readonly) BOOL didSetTappable;
@property(nonatomic, assign, readonly) BOOL didSetZIndex;
@property(nonatomic, assign, readonly) BOOL didSetPath;
@property(nonatomic, assign, readonly) BOOL didSetHoles;
@property(nonatomic, assign, readonly) BOOL didSetFillColor;
@property(nonatomic, assign, readonly) BOOL didSetStrokeColor;
@property(nonatomic, assign, readonly) BOOL didSetStrokeWidth;
@property(nonatomic, assign, readonly) BOOL didSetMap;

/**
 * Defines a property that represents whether the call order was correct.
 */
@property(nonatomic, assign, readonly) BOOL isOrderCorrect;

@end
