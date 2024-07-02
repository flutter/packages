// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import GoogleMaps;

/**
 * Defines a marker used for testing the call order of setters.
 */
@interface PartiallyMockedMarker : GMSMarker

@property(nonatomic, assign) BOOL didSetAlpha;
@property(nonatomic, assign) BOOL didSetAnchor;
@property(nonatomic, assign) BOOL didSetDraggable;
@property(nonatomic, assign) BOOL didSetFlat;
@property(nonatomic, assign) BOOL didSetIcon;
@property(nonatomic, assign) BOOL didSetPosition;
@property(nonatomic, assign) BOOL didSetRotation;
@property(nonatomic, assign) BOOL didSetDraggable;
@property(nonatomic, assign) BOOL didSetZIndex;
@property(nonatomic, assign) BOOL didSetVisible;

/**
 * Defines a property that represents whether the call order was correct.
 */
@property(nonatomic, assign) BOOL isOrderCorrect;

@end
