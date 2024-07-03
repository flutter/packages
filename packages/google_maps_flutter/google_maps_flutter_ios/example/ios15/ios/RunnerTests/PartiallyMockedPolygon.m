// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "PartiallyMockedPolygon.h"

@interface PartiallyMockedPolygon ()

@property(nonatomic, assign) BOOL didSetTappable;
@property(nonatomic, assign) BOOL didSetZIndex;
@property(nonatomic, assign) BOOL didSetPath;
@property(nonatomic, assign) BOOL didSetHoles;
@property(nonatomic, assign) BOOL didSetFillColor;
@property(nonatomic, assign) BOOL didSetStrokeColor;
@property(nonatomic, assign) BOOL didSetStrokeWidth;
@property(nonatomic, assign) BOOL didSetMap;

@property(nonatomic, assign) BOOL isOrderCorrect;

@end

@implementation PartiallyMockedPolygon

- (void)setTappable:(BOOL)tappable {
  super.tappable = tappable;
  self.didSetTappable = true;
}

- (void)setZIndex:(int)zIndex {
  super.zIndex = zIndex;
  self.didSetZIndex = true;
}

- (void)setPath:(GMSPath *)path {
  super.path = path;
  self.didSetPath = true;
}

- (void)setHoles:(NSArray<GMSPath *> *)holes {
  super.holes = holes;
  self.didSetHoles = true;
}

- (void)setFillColor:(UIColor *)fillColor {
  super.fillColor = fillColor;
  self.didSetFillColor = true;
}

- (void)setStrokeColor:(UIColor *)strokeColor {
  super.strokeColor = strokeColor;
  self.didSetStrokeColor = strokeColor;
}

- (void)setStrokeWidth:(CGFloat)strokeWidth {
  super.strokeWidth = strokeWidth;
  self.didSetStrokeWidth = true;
}

- (void)setMap:(GMSMapView *)map {
  super.map = map;

  if (self.didSetMap || map == nil || map == (id)[NSNull null]) {
    return;
  }

  self.didSetMap = true;

  self.isOrderCorrect = self.didSetTappable && self.didSetZIndex && self.didSetPath &&
                        self.didSetHoles && self.didSetFillColor && self.didSetStrokeColor &&
                        self.didSetStrokeWidth;
}

@end
