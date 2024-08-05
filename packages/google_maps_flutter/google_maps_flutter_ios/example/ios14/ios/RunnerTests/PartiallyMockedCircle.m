// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "PartiallyMockedCircle.h"

@interface PartiallyMockedCircle ()

@property(nonatomic, assign) BOOL didSetTappable;
@property(nonatomic, assign) BOOL didSetZIndex;
@property(nonatomic, assign) BOOL didSetPosition;
@property(nonatomic, assign) BOOL didSetRadius;
@property(nonatomic, assign) BOOL didSetStrokeColor;
@property(nonatomic, assign) BOOL didSetStrokeWidth;
@property(nonatomic, assign) BOOL didSetFillColor;
@property(nonatomic, assign) BOOL didSetMap;

@property(nonatomic, assign) BOOL isOrderCorrect;

@end

@implementation PartiallyMockedCircle

- (void)setTappable:(BOOL)tappable {
  super.tappable = tappable;
  self.didSetTappable = true;
}

- (void)setZIndex:(int)zIndex {
  super.zIndex = zIndex;
  self.didSetZIndex = true;
}

- (void)setPosition:(CLLocationCoordinate2D)position {
  super.position = position;
  self.didSetPosition = true;
}

- (void)setRadius:(CLLocationDistance)radius {
  super.radius = radius;
  self.didSetRadius = true;
}

- (void)setStrokeColor:(UIColor *)strokeColor {
  super.strokeColor = strokeColor;
  self.didSetStrokeColor = strokeColor;
}

- (void)setStrokeWidth:(CGFloat)strokeWidth {
  super.strokeWidth = strokeWidth;
  self.didSetStrokeWidth = true;
}

- (void)setFillColor:(UIColor *)fillColor {
  super.fillColor = fillColor;
  self.didSetFillColor = true;
}

- (void)setMap:(GMSMapView *)map {
  super.map = map;

  if (self.didSetMap || map == nil || map == (id)[NSNull null]) {
    return;
  }

  self.didSetMap = true;

  self.isOrderCorrect = self.didSetTappable && self.didSetZIndex && self.didSetPosition &&
                        self.didSetRadius && self.didSetStrokeColor && self.didSetStrokeWidth &&
                        self.didSetFillColor;
}

@end
