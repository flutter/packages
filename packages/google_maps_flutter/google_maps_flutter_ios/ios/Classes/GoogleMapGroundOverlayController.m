// // Copyright 2019 The Chromium Authors. All rights reserved.
// // Use of this source code is governed by a BSD-style license that can be
// // found in the LICENSE file.

#import "GoogleMapGroundOverlayController.h"
#import "FLTGoogleMapJSONConversions.h"

static UIImage *ExtractBitmapDescriptor(NSObject<FlutterPluginRegistrar> *registrar,
                                        NSArray *bitmap);

@interface FLTGoogleMapGroundOverlayController ()

@property(strong, nonatomic) GMSGroundOverlay *groundOverlay;
@property(weak, nonatomic) GMSMapView *mapView;
@property(assign, nonatomic) BOOL consumeTapEvents;

@end

@implementation FLTGoogleMapGroundOverlayController

- (instancetype)initGroundOverlayWithPosition:(CLLocationCoordinate2D)position
                                         icon:(UIImage *)icon
                              groundOverlayId:(NSString *)groundOverlayId
                                      mapView:(GMSMapView *)mapView {
  self = [super init];
  if (self) {
    float zoomLevel = mapView.camera.zoom;
    _groundOverlay = [GMSGroundOverlay groundOverlayWithPosition:position
                                                            icon:icon
                                                       zoomLevel:zoomLevel];
    _mapView = mapView;
    _groundOverlayId = groundOverlayId;
    _groundOverlay.userData = @[ _groundOverlayId ];
    self.consumeTapEvents = NO;
  }
  return self;
}

- (instancetype)initGroundOverlayWithBounds:(GMSCoordinateBounds *)bounds
                                       icon:(UIImage *)icon
                            groundOverlayId:(NSString *)groundOverlayId
                                    mapView:(GMSMapView *)mapView {
  self = [super init];
  if (self) {
    _groundOverlay = [GMSGroundOverlay groundOverlayWithBounds:bounds icon:icon];
    _mapView = mapView;
    _groundOverlayId = groundOverlayId;
    _groundOverlay.userData = @[ _groundOverlayId ];
    self.consumeTapEvents = NO;
  }
  return self;
}

- (BOOL)consumeTapEvents {
  return self.consumeTapEvents;
}

- (void)removeGroundOverlay {
  self.groundOverlay.map = nil;
}

#pragma mark - FLTGoogleMapGroundOverlayOptionsSink methods

- (void)setConsumeTapEvents:(BOOL)consumes {
  self.groundOverlay.tappable = consumes;
}

- (void)setVisible:(BOOL)visible {
  self.groundOverlay.map = visible ? _mapView : nil;
}

- (void)setZIndex:(int)zIndex {
  self.groundOverlay.zIndex = zIndex;
}

- (void)setBounds:(GMSCoordinateBounds *)bounds {
  self.groundOverlay.bounds = bounds;
}

- (void)setLocation:(CLLocationCoordinate2D)location width:(CGFloat)width height:(CGFloat)height {
  self.groundOverlay.position = location;
}

- (void)setBitmapDescriptor:(UIImage *)bd {
  self.groundOverlay.icon = bd;
}

- (void)setBearing:(CLLocationDirection)bearing {
  self.groundOverlay.bearing = bearing;
}

- (void)setOpacity:(float)opacity {
  self.groundOverlay.opacity = opacity;
}

@end

static void InterpretGroundOverlayOptions(NSDictionary *data,
                                          id<FLTGoogleMapGroundOverlayOptionsSink> sink,
                                          NSObject<FlutterPluginRegistrar> *registrar) {
  NSNumber *consumeTapEvents = data[@"consumeTapEvents"];
  if (consumeTapEvents != nil) {
    [sink setConsumeTapEvents:consumeTapEvents.boolValue];
  }

  NSNumber *visible = data[@"visible"];
  if (visible != nil) {
    [sink setVisible:visible.boolValue];
  }

  NSNumber *zIndex = data[@"zIndex"];
  if (zIndex != nil && zIndex != (id)[NSNull null]) {
    [sink setZIndex:zIndex.intValue];
  }

  NSNumber *transparency = data[@"transparency"];
  if (transparency != nil && transparency != (id)[NSNull null]) {
    float transparencyFloat = [transparency floatValue];
    float opacity = 1 - transparencyFloat;
    [sink setOpacity:opacity];
  }

  NSNumber *width = data[@"width"];
  NSNumber *height = data[@"height"];
  NSArray *location = data[@"location"];
  if (location) {
    if (height != nil) {
      [sink setLocation:[FLTGoogleMapJSONConversions locationFromLatLong:location]
                  width:width.doubleValue
                 height:height.doubleValue];
    } else {
      if (width != nil) {
        [sink setLocation:[FLTGoogleMapJSONConversions locationFromLatLong:location]
                    width:width.doubleValue
                   height:150];
      }
    }
  }

  NSArray *bounds = data[@"bounds"];
  if (bounds) {
    [sink setBounds:[FLTGoogleMapJSONConversions coordinateBoundsFromLatLongs:bounds]];
  }

  NSNumber *bearing = data[@"bearing"];
  if (bearing != nil) {
    [sink setBearing:bearing.floatValue];
  }

  NSArray *bitmap = data[@"bitmap"];
  if (bitmap) {
    UIImage *image = ExtractBitmapDescriptor(registrar, bitmap);
    [sink setBitmapDescriptor:image];
  }
}

static UIImage *scaleImage(UIImage *image, NSNumber *scaleParam) {
  double scale = 1.0;
  if ([scaleParam isKindOfClass:[NSNumber class]]) {
    scale = scaleParam.doubleValue;
  }
  if (fabs(scale - 1) > 1e-3) {
    return [UIImage imageWithCGImage:[image CGImage]
                               scale:(image.scale * scale)
                         orientation:(image.imageOrientation)];
  }
  return image;
}

static UIImage *ExtractBitmapDescriptor(NSObject<FlutterPluginRegistrar> *registrar,
                                        NSArray *bitmapData) {
  UIImage *image;
  if ([bitmapData.firstObject isEqualToString:@"fromAsset"]) {
    if (bitmapData.count == 2) {
      image = [UIImage imageNamed:[registrar lookupKeyForAsset:bitmapData[1]]];
    } else {
      image = [UIImage imageNamed:[registrar lookupKeyForAsset:bitmapData[1]
                                                   fromPackage:bitmapData[2]]];
    }
  } else if ([bitmapData.firstObject isEqualToString:@"fromAssetImage"]) {
    if (bitmapData.count == 3) {
      image = [UIImage imageNamed:[registrar lookupKeyForAsset:bitmapData[1]]];
      NSNumber *scaleParam = bitmapData[2];
      image = scaleImage(image, scaleParam);
    } else {
      NSString *error =
          [NSString stringWithFormat:@"'fromAssetImage' should have exactly 3 arguments. Got: %lu",
                                     (unsigned long)bitmapData.count];
      NSException *exception = [NSException exceptionWithName:@"InvalidBitmapDescriptor"
                                                       reason:error
                                                     userInfo:nil];
      @throw exception;
    }
  } else if ([bitmapData[0] isEqualToString:@"fromBytes"]) {
    if (bitmapData.count == 2) {
      @try {
        FlutterStandardTypedData *byteData = bitmapData[1];
        CGFloat screenScale = [[UIScreen mainScreen] scale];
        image = [UIImage imageWithData:[byteData data] scale:screenScale];
      } @catch (NSException *exception) {
        @throw [NSException exceptionWithName:@"InvalidByteDescriptor"
                                       reason:@"Unable to interpret bytes as a valid image."
                                     userInfo:nil];
      }
    } else {
      NSString *error = [NSString
          stringWithFormat:@"fromBytes should have exactly one argument, the bytes. Got: %lu",
                           (unsigned long)bitmapData.count];
      NSException *exception = [NSException exceptionWithName:@"InvalidByteDescriptor"
                                                       reason:error
                                                     userInfo:nil];
      @throw exception;
    }
  }

  return image;
}

@interface FLTGroundOverlaysController ()

@property(strong, nonatomic) NSMutableDictionary *groundOverlayIdToController;
@property(strong, nonatomic) FlutterMethodChannel *methodChannel;
@property(weak, nonatomic) NSObject<FlutterPluginRegistrar> *registrar;
@property(weak, nonatomic) GMSMapView *mapView;

@end

@implementation FLTGroundOverlaysController

- (instancetype)init:(FlutterMethodChannel *)methodChannel
             mapView:(GMSMapView *)mapView
           registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _methodChannel = methodChannel;
    _mapView = mapView;
    _groundOverlayIdToController = [NSMutableDictionary dictionaryWithCapacity:1];
    _registrar = registrar;
  }
  return self;
}

- (void)addGroundOverlays:(NSArray *)groundOverlaysToAdd {
  for (NSDictionary *groundOverlay in groundOverlaysToAdd) {
    GMSCoordinateBounds *bounds = [FLTGroundOverlaysController getBounds:groundOverlay];
    UIImage *icon = [FLTGroundOverlaysController getImage:groundOverlay registrar:_registrar];
    NSString *groundOverlayId = [FLTGroundOverlaysController getGroundOverlayId:groundOverlay];

    if (bounds) {
      CLLocationCoordinate2D location =
          [FLTGoogleMapJSONConversions locationFromLatLong:groundOverlay[@"location"]];
      FLTGoogleMapGroundOverlayController *controller =
          [[FLTGoogleMapGroundOverlayController alloc] initGroundOverlayWithPosition:location
                                                                                icon:icon
                                                                     groundOverlayId:groundOverlayId
                                                                             mapView:_mapView];
      InterpretGroundOverlayOptions(groundOverlay, controller, _registrar);
      _groundOverlayIdToController[groundOverlayId] = controller;
    } else {
      FLTGoogleMapGroundOverlayController *controller =
          [[FLTGoogleMapGroundOverlayController alloc] initGroundOverlayWithBounds:bounds
                                                                              icon:icon
                                                                   groundOverlayId:groundOverlayId
                                                                           mapView:_mapView];
      InterpretGroundOverlayOptions(groundOverlay, controller, _registrar);
      _groundOverlayIdToController[groundOverlayId] = controller;
    }
  }
}

- (void)changeGroundOverlays:(NSArray *)groundOverlaysToChange {
  for (NSDictionary *groundOverlay in groundOverlaysToChange) {
    NSString *groundOverlayId = [FLTGroundOverlaysController getGroundOverlayId:groundOverlay];
    FLTGoogleMapGroundOverlayController *controller = _groundOverlayIdToController[groundOverlayId];
    if (!controller) {
      continue;
    }
    InterpretGroundOverlayOptions(groundOverlay, controller, _registrar);
  }
}

- (void)removeGroundOverlayWithIdentifiers:(NSArray *)groundOverlayIdsToRemove {
  for (NSString *groundOverlayId in groundOverlayIdsToRemove) {
    if (!groundOverlayId) {
      continue;
    }
    FLTGoogleMapGroundOverlayController *controller = _groundOverlayIdToController[groundOverlayId];
    if (!controller) {
      continue;
    }
    [controller removeGroundOverlay];
    [_groundOverlayIdToController removeObjectForKey:groundOverlayId];
  }
}

- (bool)hasGroundOverlayWithIdentifier:(NSString *)groundOverlayId {
  if (!groundOverlayId) {
    return false;
  }
  return _groundOverlayIdToController[groundOverlayId] != nil;
}

- (void)didTapGroundOverlayWithIdentifier:(NSString *)identifier {
  if (!identifier) {
    return;
  }
  FLTGoogleMapGroundOverlayController *controller = _groundOverlayIdToController[identifier];
  if (!controller) {
    return;
  }
  [_methodChannel invokeMethod:@"groundOverlay#onTap" arguments:@{@"groundOverlayId" : identifier}];
}

+ (GMSCoordinateBounds *)getBounds:(NSDictionary *)groundOverlay {
  NSArray *bounds = groundOverlay[@"bounds"];
  return [FLTGoogleMapJSONConversions coordinateBoundsFromLatLongs:bounds];
}

+ (UIImage *)getImage:(NSDictionary *)groundOverlay
            registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  NSArray *image = groundOverlay[@"bitmap"];
  return ExtractBitmapDescriptor(registrar, image);
}

+ (NSString *)getGroundOverlayId:(NSDictionary *)groundOverlay {
  return groundOverlay[@"groundOverlayId"];
}

@end
