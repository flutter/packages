// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import GoogleMaps;

/**
 * Defines a marker used for testing the call order of setters.
 */
@interface PartiallyMockedTileLayer : GMSTileLayer

@property(nonatomic, assign, readonly) BOOL didSetOpacity;
@property(nonatomic, assign, readonly) BOOL didSetZIndex;
@property(nonatomic, assign, readonly) BOOL didSetFadeIn;
@property(nonatomic, assign, readonly) BOOL didSetTileSize;
@property(nonatomic, assign, readonly) BOOL didSetMap;

/**
 * Defines a property that represents whether the call order was correct.
 */
@property(nonatomic, assign, readonly) BOOL isOrderCorrect;

@end
