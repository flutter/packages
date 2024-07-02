// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "PartiallyMockedMarker.h"

@interface PartiallyMockedMarker ()

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

@property(nonatomic, assign) BOOL isOrderCorrect;

@end

@implementation PartiallyMockedMarker

- (void)setAlpha:(float)alpha {
  self.didSetAlpha = true;
}

- (void)setAnchor:(CGPoint)anchor {
  self.didSetAnchor = true;
}

- (void)setDraggable:(BOOL)draggable {
  self.didSetDraggable = true;
}

- (void)setFlat:(BOOL)flat {
  self.didSetFlat = true;
}

- (void)setIcon:(UIImage *)icon {
  self.didSetIcon = true;
}

- (void)setPosition:(CLLocationCoordinate2D)position {
  self.didSetPosition = true;
}

- (void)setRotation:(CLLocationDegrees)rotation {
  self.didSetRotation = true;
}

- (void)setZIndex:(int)zIndex {
  self.didSetZIndex = true;
}

- (void)setVisible:(BOOL)visible {
  if (self.isOrderCorrect != nil) {
    return;
  }

  self.isOrderCorrect = didSetAlpha && didSetAnchor && didSetDraggable && didSetFlat && didSetIcon && didSetPosition && didSetRotation && didSetDraggable && didSetZIndex;
}

@end
