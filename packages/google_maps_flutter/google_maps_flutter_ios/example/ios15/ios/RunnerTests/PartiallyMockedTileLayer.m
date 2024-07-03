// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "PartiallyMockedTileLayer.h"

@interface PartiallyMockedTileLayer ()

@property(nonatomic, assign) BOOL didSetOpacity;
@property(nonatomic, assign) BOOL didSetZIndex;
@property(nonatomic, assign) BOOL didSetFadeIn;
@property(nonatomic, assign) BOOL didSetTileSize;
@property(nonatomic, assign) BOOL didSetMap;

@property(nonatomic, assign) BOOL isOrderCorrect;

@end

@implementation PartiallyMockedTileLayer

- (void)setOpacity:(float)opacity {
  super.opacity = opacity;
  self.didSetOpacity = true;
}

- (void)setZIndex:(int)zIndex {
  super.zIndex = zIndex;
  self.didSetZIndex = true;
}

- (void)setFadeIn:(BOOL)fadeIn {
  super.fadeIn = fadeIn;
  self.didSetFadeIn = true;
}

- (void)setTileSize:(NSInteger)tileSize {
  super.tileSize = tileSize;
  self.didSetTileSize = true;
}

- (void)setMap:(GMSMapView *)map {
  super.map = map;

  if (self.didSetMap || map == nil || map == (id)[NSNull null]) {
    return;
  }

  self.didSetMap = true;

  self.isOrderCorrect =
      self.didSetOpacity && self.didSetZIndex && self.didSetFadeIn && self.didSetTileSize;
}

@end
