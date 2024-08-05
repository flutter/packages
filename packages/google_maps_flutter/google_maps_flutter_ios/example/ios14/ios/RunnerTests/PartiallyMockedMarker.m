// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "PartiallyMockedMarker.h"

@interface PartiallyMockedMarker ()

@property(nonatomic, assign) BOOL didSetOpacity;
@property(nonatomic, assign) BOOL didSetGroundAnchor;
@property(nonatomic, assign) BOOL didSetDraggable;
@property(nonatomic, assign) BOOL didSetIcon;
@property(nonatomic, assign) BOOL didSetFlat;
@property(nonatomic, assign) BOOL didSetInfoWindowAnchor;
@property(nonatomic, assign) BOOL didSetTitle;
@property(nonatomic, assign) BOOL didSetSnippet;
@property(nonatomic, assign) BOOL didSetPosition;
@property(nonatomic, assign) BOOL didSetRotation;
@property(nonatomic, assign) BOOL didSetZIndex;
@property(nonatomic, assign) BOOL didSetMap;

@property(nonatomic, assign) BOOL isOrderCorrect;

@end

@implementation PartiallyMockedMarker

- (void)setOpacity:(float)opacity {
  super.opacity = opacity;
  self.didSetOpacity = true;
}

- (void)setGroundAnchor:(CGPoint)groundAnchor {
  super.groundAnchor = groundAnchor;
  self.didSetGroundAnchor = true;
}

- (void)setDraggable:(BOOL)draggable {
  super.draggable = draggable;
  self.didSetDraggable = true;
}

- (void)setIcon:(UIImage *)icon {
  super.icon = icon;
  self.didSetIcon = true;
}

- (void)setFlat:(BOOL)flat {
  super.flat = flat;
  self.didSetFlat = true;
}

- (void)setInfoWindowAnchor:(CGPoint)infoWindowAnchor {
  super.infoWindowAnchor = infoWindowAnchor;
  self.didSetInfoWindowAnchor = true;
}

- (void)setTitle:(NSString *)title {
  super.title = title;
  self.didSetTitle = true;
}

- (void)setSnippet:(NSString *)snippet {
  super.snippet = snippet;
  self.didSetSnippet = true;
}

- (void)setPosition:(CLLocationCoordinate2D)position {
  super.position = position;
  self.didSetPosition = true;
}

- (void)setRotation:(CLLocationDegrees)rotation {
  super.rotation = rotation;
  self.didSetRotation = true;
}

- (void)setZIndex:(int)zIndex {
  super.zIndex = zIndex;
  self.didSetZIndex = true;
}

- (void)setMap:(GMSMapView *)map {
  super.map = map;

  if (self.didSetMap || map == nil || map == (id)[NSNull null]) {
    return;
  }

  self.didSetMap = true;

  self.isOrderCorrect = self.didSetOpacity && self.didSetGroundAnchor && self.didSetDraggable &&
                        self.didSetIcon && self.didSetFlat && self.didSetInfoWindowAnchor &&
                        self.didSetTitle && self.didSetSnippet && self.didSetPosition &&
                        self.didSetRotation && self.didSetZIndex;
}

@end
