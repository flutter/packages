// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FGMGroundOverlayController.h"
#import "FGMGroundOverlayController_Test.h"

#import "FGMConversionUtils.h"
#import "FGMImageUtils.h"

@interface FGMGroundOverlayController ()

/// The GMSMapView to which the ground overlays are added.
@property(weak, nonatomic) GMSMapView *mapView;

@end

@implementation FGMGroundOverlayController

- (instancetype)initWithGroundOverlay:(GMSGroundOverlay *)groundOverlay
                           identifier:(NSString *)identifier
                              mapView:(GMSMapView *)mapView
                  isCreatedWithBounds:(BOOL)isCreatedWithBounds {
  self = [super init];
  if (self) {
    _groundOverlay = groundOverlay;
    _mapView = mapView;
    _groundOverlay.userData = @[ identifier ];
    _createdWithBounds = isCreatedWithBounds;
  }
  return self;
}

- (void)removeGroundOverlay {
  self.groundOverlay.map = nil;
}

- (void)updateFromPlatformGroundOverlay:(FGMPlatformGroundOverlay *)groundOverlay
                              registrar:(NSObject<FlutterPluginRegistrar> *)registrar
                            screenScale:(CGFloat)screenScale {
  [FGMGroundOverlayController updateGroundOverlay:self.groundOverlay
                        fromPlatformGroundOverlay:groundOverlay
                                      withMapView:self.mapView
                                        registrar:registrar
                                      screenScale:screenScale
                                      usingBounds:self.createdWithBounds];
}

+ (void)updateGroundOverlay:(GMSGroundOverlay *)groundOverlay
    fromPlatformGroundOverlay:(FGMPlatformGroundOverlay *)platformGroundOverlay
                  withMapView:(GMSMapView *)mapView
                    registrar:(NSObject<FlutterPluginRegistrar> *)registrar
                  screenScale:(CGFloat)screenScale
                  usingBounds:(BOOL)useBounds {
  groundOverlay.tappable = platformGroundOverlay.clickable;
  groundOverlay.zIndex = (int)platformGroundOverlay.zIndex;
  groundOverlay.anchor =
      CGPointMake(platformGroundOverlay.anchor.x, platformGroundOverlay.anchor.y);
  UIImage *image = FGMIconFromBitmap(platformGroundOverlay.image, registrar, screenScale);
  groundOverlay.icon = image;
  groundOverlay.bearing = platformGroundOverlay.bearing;
  groundOverlay.opacity = 1.0 - platformGroundOverlay.transparency;
  if (useBounds) {
    groundOverlay.bounds = [[GMSCoordinateBounds alloc]
        initWithCoordinate:CLLocationCoordinate2DMake(
                               platformGroundOverlay.bounds.northeast.latitude,
                               platformGroundOverlay.bounds.northeast.longitude)
                coordinate:CLLocationCoordinate2DMake(
                               platformGroundOverlay.bounds.southwest.latitude,
                               platformGroundOverlay.bounds.southwest.longitude)];
  } else {
    groundOverlay.position = CLLocationCoordinate2DMake(platformGroundOverlay.position.latitude,
                                                        platformGroundOverlay.position.longitude);
  }

  // This must be done last, to avoid visual flickers of default property values.
  groundOverlay.map = platformGroundOverlay.visible ? mapView : nil;
}

@end

@interface FLTGroundOverlaysController ()

/// A map from ground overlay id to the controller that manages it.
@property(strong, nonatomic) NSMutableDictionary<NSString *, FGMGroundOverlayController *>
    *groundOverlayControllerByIdentifier;

/// A callback api for the map interactions.
@property(strong, nonatomic) FGMMapsCallbackApi *callbackHandler;

/// Flutter Plugin Registrar used to load images.
@property(weak, nonatomic) NSObject<FlutterPluginRegistrar> *registrar;

/// The map view used to generate the controllers.
@property(weak, nonatomic) GMSMapView *mapView;

@end

@implementation FLTGroundOverlaysController

- (instancetype)initWithMapView:(GMSMapView *)mapView
                callbackHandler:(FGMMapsCallbackApi *)callbackHandler
                      registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _callbackHandler = callbackHandler;
    _mapView = mapView;
    _groundOverlayControllerByIdentifier = [[NSMutableDictionary alloc] init];
    _registrar = registrar;
  }
  return self;
}

- (void)addGroundOverlays:(NSArray<FGMPlatformGroundOverlay *> *)groundOverlaysToAdd {
  for (FGMPlatformGroundOverlay *groundOverlay in groundOverlaysToAdd) {
    NSString *identifier = groundOverlay.groundOverlayId;
    GMSGroundOverlay *gmsOverlay;
    BOOL isCreatedWithBounds = NO;
    if (groundOverlay.position == nil) {
      isCreatedWithBounds = YES;
      NSAssert(groundOverlay.bounds != nil,
               @"If ground overlay is initialized without position, bounds are required");
      gmsOverlay = [GMSGroundOverlay
          groundOverlayWithBounds:
              [[GMSCoordinateBounds alloc]
                  initWithCoordinate:CLLocationCoordinate2DMake(
                                         groundOverlay.bounds.northeast.latitude,
                                         groundOverlay.bounds.northeast.longitude)
                          coordinate:CLLocationCoordinate2DMake(
                                         groundOverlay.bounds.southwest.latitude,
                                         groundOverlay.bounds.southwest.longitude)]
                             icon:FGMIconFromBitmap(groundOverlay.image, self.registrar,
                                                    [self getScreenScale])];
    } else {
      NSAssert(groundOverlay.zoomLevel != nil,
               @"If ground overlay is initialized with position, zoomLevel is required");
      gmsOverlay = [GMSGroundOverlay
          groundOverlayWithPosition:CLLocationCoordinate2DMake(groundOverlay.position.latitude,
                                                               groundOverlay.position.longitude)
                               icon:FGMIconFromBitmap(groundOverlay.image, self.registrar,
                                                      [self getScreenScale])
                          zoomLevel:[groundOverlay.zoomLevel doubleValue]];
    }
    FGMGroundOverlayController *controller =
        [[FGMGroundOverlayController alloc] initWithGroundOverlay:gmsOverlay
                                                       identifier:identifier
                                                          mapView:self.mapView
                                              isCreatedWithBounds:isCreatedWithBounds];
    controller.zoomLevel = groundOverlay.zoomLevel;
    [controller updateFromPlatformGroundOverlay:groundOverlay
                                      registrar:self.registrar
                                    screenScale:[self getScreenScale]];
    self.groundOverlayControllerByIdentifier[identifier] = controller;
  }
}

- (void)changeGroundOverlays:(NSArray<FGMPlatformGroundOverlay *> *)groundOverlaysToChange {
  for (FGMPlatformGroundOverlay *groundOverlay in groundOverlaysToChange) {
    NSString *identifier = groundOverlay.groundOverlayId;
    FGMGroundOverlayController *controller = self.groundOverlayControllerByIdentifier[identifier];
    [controller updateFromPlatformGroundOverlay:groundOverlay
                                      registrar:self.registrar
                                    screenScale:[self getScreenScale]];
  }
}

- (void)removeGroundOverlaysWithIdentifiers:(NSArray<NSString *> *)identifiers {
  for (NSString *identifier in identifiers) {
    FGMGroundOverlayController *controller = self.groundOverlayControllerByIdentifier[identifier];
    if (!controller) {
      continue;
    }
    [controller removeGroundOverlay];
    [self.groundOverlayControllerByIdentifier removeObjectForKey:identifier];
  }
}

- (void)didTapGroundOverlayWithIdentifier:(NSString *)identifier {
  FGMGroundOverlayController *controller = self.groundOverlayControllerByIdentifier[identifier];
  if (!controller) {
    return;
  }
  [self.callbackHandler didTapGroundOverlayWithIdentifier:identifier
                                               completion:^(FlutterError *_Nullable _){
                                               }];
}

- (bool)hasGroundOverlaysWithIdentifier:(NSString *)identifier {
  return self.groundOverlayControllerByIdentifier[identifier] != nil;
}

- (CGFloat)getScreenScale {
  // TODO(jokerttu): This method is called on marker creation, which, for initial markers, is done
  // before the view is added to the view hierarchy. This means that the traitCollection values may
  // not be matching the right display where the map is finally shown. The solution should be
  // revisited after the proper way to fetch the display scale is resolved for platform views. This
  // should be done under the context of the following issue:
  // https://github.com/flutter/flutter/issues/125496.
  return self.mapView.traitCollection.displayScale;
}

- (nullable FGMPlatformGroundOverlay *)groundOverlayWithIdentifier:(NSString *)identifier {
  FGMGroundOverlayController *controller = self.groundOverlayControllerByIdentifier[identifier];
  if (!controller) {
    return nil;
  }
  return FGMGetPigeonGroundOverlay(controller.groundOverlay, identifier,
                                   controller.isCreatedWithBounds, controller.zoomLevel);
}

@end
