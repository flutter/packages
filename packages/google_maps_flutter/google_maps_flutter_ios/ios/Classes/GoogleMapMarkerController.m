// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapMarkerController.h"
#import "FLTGoogleMapJSONConversions.h"
#import "GoogleMapMarkerIconCache.h"
#import "Timer.h"

@interface FLTGoogleMapMarkerController ()

@property(strong, nonatomic) GMSMarker *marker;
@property(weak, nonatomic) GMSMapView *mapView;
@property(assign, nonatomic, readwrite) BOOL consumeTapEvents;

@end

@implementation FLTGoogleMapMarkerController

- (instancetype)initWithPosition:(CLLocationCoordinate2D)position
                      identifier:(NSString *)identifier
                         mapView:(GMSMapView *)mapView {
  self = [super init];
  if (self) {
    _marker = [GMSMarker markerWithPosition:position];
    _mapView = mapView;
    _marker.userData = @[ identifier ];
  }
  return self;
}

- (void)showInfoWindow {
  self.mapView.selectedMarker = self.marker;
}

- (void)hideInfoWindow {
  if (self.mapView.selectedMarker == self.marker) {
    self.mapView.selectedMarker = nil;
  }
}

- (BOOL)isInfoWindowShown {
  return self.mapView.selectedMarker == self.marker;
}

- (void)removeMarker {
  self.marker.map = nil;
}

- (void)setAlpha:(float)alpha {
  if (self.marker.opacity != alpha) {
    self.marker.opacity = alpha;
  }
}

- (void)setAnchor:(CGPoint)anchor {
  if (self.marker.groundAnchor.x != anchor.x
      || self.marker.groundAnchor.y != anchor.y) {
    self.marker.groundAnchor = anchor;
  }
}

- (void)setDraggable:(BOOL)draggable {
  if (self.marker.draggable != draggable) {
    self.marker.draggable = draggable;
  }
}

- (void)setFlat:(BOOL)flat {
  if (self.marker.flat != flat) {
    self.marker.flat = flat;
  }
}

- (void)setIcon:(UIImage *)icon {
  self.marker.icon = icon;
}

- (void)setInfoWindowAnchor:(CGPoint)anchor {
  if (self.marker.infoWindowAnchor.x != anchor.x
      || self.marker.infoWindowAnchor.y != anchor.y) {
    self.marker.infoWindowAnchor = anchor;
  }
}

- (void)setInfoWindowTitle:(NSString *)title snippet:(NSString *)snippet {
  if (self.marker.title != title) {
    self.marker.title = title;
  }
  if (self.marker.snippet != snippet) {
     self.marker.snippet = snippet;
  }
}

- (void)setPosition:(CLLocationCoordinate2D)position {
  if (self.marker.position.latitude != position.latitude
      || self.marker.position.longitude != position.longitude) {
     self.marker.position = position;
  }
}

- (void)setRotation:(CLLocationDegrees)rotation {
  if (self.marker.rotation != rotation) {
    self.marker.rotation = rotation;
  }
}

- (void)setVisibleOption:(NSDictionary *)data {
  NSNumber *visible = data[@"visible"];
  if (visible && visible != (id)[NSNull null]) {
    BOOL visibleBool = [visible boolValue];
    if ((self.marker.map != nil) != visibleBool) {
      self.marker.map = visibleBool ? self.mapView : nil;
    }
  }
}

- (void)setZIndex:(int)zIndex {
  if (self.marker.zIndex != zIndex) {
    self.marker.zIndex = zIndex;
  }
}

- (void)interpretMarkerOptions:(NSDictionary *)data
                     iconCache:(GoogleMapMarkerIconCache *) iconCache {
  NSNumber *alpha = FGMGetValueOrNilFromDict(data, @"alpha");
  if (alpha) {
    [self setAlpha:[alpha floatValue]];
  }
  NSArray *anchor = FGMGetValueOrNilFromDict(data, @"anchor");
  if (anchor) {
    [self setAnchor:[FLTGoogleMapJSONConversions pointFromArray:anchor]];
  }
  NSNumber *draggable = FGMGetValueOrNilFromDict(data, @"draggable");
  if (draggable) {
    [self setDraggable:[draggable boolValue]];
  }
   
  NSArray *icon = FGMGetValueOrNilFromDict(data, @"icon");
  if (icon) {
    UIImage *image = [iconCache getImage:icon];
    [self setIcon:image];
  }
  
  NSNumber *flat = FGMGetValueOrNilFromDict(data, @"flat");
  if (flat) {
    [self setFlat:[flat boolValue]];
  }
  NSNumber *consumeTapEvents = FGMGetValueOrNilFromDict(data, @"consumeTapEvents");
  if (consumeTapEvents) {
    [self setConsumeTapEvents:[consumeTapEvents boolValue]];
  }
  [self interpretInfoWindow:data];
  NSArray *position = FGMGetValueOrNilFromDict(data, @"position");
  if (position) {
    [self setPosition:[FLTGoogleMapJSONConversions locationFromLatLong:position]];
  }
  NSNumber *rotation = FGMGetValueOrNilFromDict(data, @"rotation");
  if (rotation) {
    [self setRotation:[rotation doubleValue]];
  }
  NSNumber *zIndex = FGMGetValueOrNilFromDict(data, @"zIndex");
  if (zIndex) {
    [self setZIndex:[zIndex intValue]];
  }
}

- (void)interpretInfoWindow:(NSDictionary *)data {
  NSDictionary *infoWindow = FGMGetValueOrNilFromDict(data, @"infoWindow");
  if (infoWindow) {
    NSString *title = FGMGetValueOrNilFromDict(infoWindow, @"title");
    NSString *snippet = FGMGetValueOrNilFromDict(infoWindow, @"snippet");
    if (title) {
      [self setInfoWindowTitle:title snippet:snippet];
    }
    NSArray *infoWindowAnchor = infoWindow[@"infoWindowAnchor"];
    if (infoWindowAnchor) {
      [self setInfoWindowAnchor:[FLTGoogleMapJSONConversions pointFromArray:infoWindowAnchor]];
    }
  }
}

@end

@interface FLTMarkersController ()

@property(strong, nonatomic) NSMutableDictionary *markerIdentifierToController;
@property(strong, nonatomic) FGMMapsCallbackApi *callbackHandler;
@property(weak, nonatomic) NSObject<FlutterPluginRegistrar> *registrar;
@property(weak, nonatomic) GMSMapView *mapView;

@property(strong, nonatomic) dispatch_queue_t markersDispatchQueue;
@property(assign, nonatomic) dispatch_once_t onceToken;
@end

@implementation FLTMarkersController

- (instancetype)initWithMapView:(GMSMapView *)mapView
                callbackHandler:(FGMMapsCallbackApi *)callbackHandler
                      registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _callbackHandler = callbackHandler;
    _mapView = mapView;
    _markerIdentifierToController = [[NSMutableDictionary alloc] init];
    _registrar = registrar;

    dispatch_once(&_onceToken, ^{
      _markersDispatchQueue = dispatch_queue_create("com.GoogleMapsFlutterIOS.MarkersDispatchQueue", DISPATCH_QUEUE_SERIAL);
    });
  }
  return self;
}

- (void)addJSONMarkers:(NSArray<NSDictionary<NSString *, id> *> *)markersToAdd {
  NSLog(@"addJSONMarkers");
  __block CGFloat screenScale = [self getScreenScale];

  dispatch_async(self.markersDispatchQueue, ^{
    GoogleMapMarkerIconCache* iconCache =
          [[GoogleMapMarkerIconCache alloc] initWithRegistrar:self.registrar
                                                  screenScale:screenScale];
    for (NSDictionary<NSString *, id> *marker in markersToAdd) {
      CLLocationCoordinate2D position = [FLTMarkersController getPosition:marker];
      NSString *identifier = marker[@"markerId"];
      FLTGoogleMapMarkerController *controller =
          [[FLTGoogleMapMarkerController alloc] initWithPosition:position
                                                            identifier:identifier
                                                               mapView:self.mapView];

      [controller interpretMarkerOptions:marker iconCache:iconCache];

      self.markerIdentifierToController[identifier] = controller;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      for (NSDictionary<NSString *, id> *marker in markersToAdd) {
        NSString *identifier = marker[@"markerId"];

        FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
        if (!controller) {
          continue;
        }
        [controller setVisibleOption:marker];
      }
    });
  });
}

- (void)addMarkers:(NSArray<FGMPlatformMarker *> *)markersToAdd {
  __block CGFloat screenScale = [self getScreenScale];

  dispatch_async(self.markersDispatchQueue, ^{
    Timer* timer = [[Timer alloc] init];
    [timer startTimer];
    
    GoogleMapMarkerIconCache* iconCache =
          [[GoogleMapMarkerIconCache alloc] initWithRegistrar:self.registrar
                                                  screenScale:screenScale];
    double cache = [timer timeElapsedInMilliseconds];
    NSLog(@"addCache: %f", cache);
    
    double last = 0;
    double next = 0;
    double add0 = 0;
    double add1 = 0;
    double add2 = 0;
    double add3 = 0;
    for (FGMPlatformMarker *marker in markersToAdd) {
      last = [timer timeElapsedInMilliseconds];
      
      CLLocationCoordinate2D position = [FLTMarkersController getPosition:marker.json];
      NSString *identifier = marker.json[@"markerId"];
      next = [timer timeElapsedInMilliseconds];
      add0 += next - last;
      last = next;
    
      FLTGoogleMapMarkerController *controller =
          [[FLTGoogleMapMarkerController alloc] initWithPosition:position
                                                            identifier:identifier
                                                               mapView:self.mapView];
      next = [timer timeElapsedInMilliseconds];
      add1 += next - last;
      last = next;

      [controller interpretMarkerOptions:marker.json iconCache:iconCache];
      next = [timer timeElapsedInMilliseconds];
      add2 += next - last;
      last = next;

      self.markerIdentifierToController[identifier] = controller;
      next = [timer timeElapsedInMilliseconds];
      add3 += next - last;
      last = next;
    }
    
    double total = [timer timeElapsedInMilliseconds];
    NSLog(@"add0: %f", add0);
    NSLog(@"add1: %f", add1);
    NSLog(@"add2: %f", add2);
    NSLog(@"add3: %f", add3);
    NSLog(@"addTotal: %f", total);

    dispatch_async(dispatch_get_main_queue(), ^{
      Timer* timer = [[Timer alloc] init];
      [timer startTimer];
      
      for (FGMPlatformMarker *marker in markersToAdd) {
        NSString *identifier = marker.json[@"markerId"];
        
        FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
        
        if (!controller) {
          return;
        }
        [controller setVisibleOption:marker.json];
      }
      /*
      NSUInteger batchSize = 200;
      NSUInteger start = 0;
      NSUInteger total = [markersToAdd count];
      while (start < total) {
        NSUInteger count = batchSize;
        if (start + count >= total) {
          count = total - start;
        }
        
        Timer* timer = [[Timer alloc] init];
        [timer startTimer];
        
        NSArray<FGMPlatformMarker *>* batch = [markersToAdd subarrayWithRange:NSMakeRange(start, count)];
        
        double slice = [timer timeElapsedInMilliseconds];
        NSLog(@"addSlice: %f", slice);
        
        double last = 0;
        double next = 0;
        double add0 = 0;
        double add1 = 0;
        NSUInteger numIter = 0;
        for (FGMPlatformMarker *marker in batch) {
          last = [timer timeElapsedInMilliseconds];
          NSString *identifier = marker.json[@"markerId"];
          
          FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
          
          next = [timer timeElapsedInMilliseconds];
          add0 += next - last;
          last = next;
          
          if (!controller) {
            return;
          }
          [controller setVisibleOption:marker.json];
          
          next = [timer timeElapsedInMilliseconds];
          add1 += next - last;
          last = next;
          
          numIter += 1;
        }
        
        double total = [timer timeElapsedInMilliseconds];
        NSLog(@"batch0: %f", add0);
        NSLog(@"batch1: %f", add1);
        NSLog(@"batchTotal: %f", total);
        NSLog(@"batchCount: %lu", [batch count]);
        NSLog(@"numIter: %lu", numIter);
        start += count;
      }
      */
      
      double elapsed = [timer timeElapsedInMilliseconds];
      NSLog(@"addUI: %f", elapsed);
    });
  });
}

- (void)changeMarkers:(NSArray<FGMPlatformMarker *> *)markersToChange {
  NSLog(@"changeMarkers");
  __block CGFloat screenScale = [self getScreenScale];

  dispatch_async(self.markersDispatchQueue, ^{
    Timer* timer = [[Timer alloc] init];
    [timer startTimer];
    
    GoogleMapMarkerIconCache* iconCache =
          [[GoogleMapMarkerIconCache alloc] initWithRegistrar:self.registrar
                                                  screenScale:screenScale];

    for (FGMPlatformMarker *marker in markersToChange) {
      NSString *identifier = marker.json[@"markerId"];
      FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
      if (!controller) {
        return;
      }
      [controller interpretMarkerOptions:marker.json iconCache:iconCache];
    }
    
    double elapsed = [timer timeElapsedInMilliseconds];
    NSLog(@"changeLogic: %f", elapsed);

    dispatch_async(dispatch_get_main_queue(), ^{
      Timer* timer = [[Timer alloc] init];
      [timer startTimer];
      
      for (FGMPlatformMarker *marker in markersToChange) {
        NSString *identifier = marker.json[@"markerId"];

        FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
        if (!controller) {
          continue;
        }
        [controller setVisibleOption:marker.json];
      }
      
      double elapsed = [timer timeElapsedInMilliseconds];
      NSLog(@"changeUI: %f", elapsed);
    });
  });
}

- (void)removeMarkersWithIdentifiers:(NSArray<NSString *> *)identifiers {
  dispatch_async(self.markersDispatchQueue, ^{
    dispatch_sync(dispatch_get_main_queue(), ^{
      Timer* timer = [[Timer alloc] init];
      [timer startTimer];
      for (NSString *identifier in identifiers) {
        FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
        if (!controller) {
          return;
        }
        [controller removeMarker];
        [self.markerIdentifierToController removeObjectForKey:identifier];
      }
      double elapsed = [timer timeElapsedInMilliseconds];
      NSLog(@"removeUI: %f", elapsed);
    });
  });
}

- (BOOL)didTapMarkerWithIdentifier:(NSString *)identifier {
  __block BOOL result = nil;

  dispatch_sync(self.markersDispatchQueue, ^{
    dispatch_sync(dispatch_get_main_queue(), ^{
      if (!identifier) {
        result = NO;
        return;
      }
      FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
      if (!controller) {
        result = NO;
        return;
      }
      [self.callbackHandler didTapMarkerWithIdentifier:identifier
                                              completion:^(FlutterError *_Nullable _){
                                              }];
      result = controller.consumeTapEvents;
    });
  });

  return result;
}

- (void)didStartDraggingMarkerWithIdentifier:(NSString *)identifier
                                    location:(CLLocationCoordinate2D)location {
  dispatch_sync(self.markersDispatchQueue, ^{
    dispatch_sync(dispatch_get_main_queue(), ^{
      if (!identifier) {
        return;
      }
      FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
      if (!controller) {
        return;
      }
      [self.callbackHandler
          didStartDragForMarkerWithIdentifier:identifier
                                   atPosition:FGMGetPigeonLatLngForCoordinate(location)
                                   completion:^(FlutterError *_Nullable _){
                                   }];
    });
  });
}

- (void)didDragMarkerWithIdentifier:(NSString *)identifier
                           location:(CLLocationCoordinate2D)location {
  dispatch_sync(self.markersDispatchQueue, ^{
    dispatch_sync(dispatch_get_main_queue(), ^{
      if (!identifier) {
        return;
      }
      FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
      if (!controller) {
        return;
      }
      [self.callbackHandler didDragMarkerWithIdentifier:identifier
                                             atPosition:FGMGetPigeonLatLngForCoordinate(location)
                                             completion:^(FlutterError *_Nullable _){
                                             }];
    });
  });
}

- (void)didEndDraggingMarkerWithIdentifier:(NSString *)identifier
                                  location:(CLLocationCoordinate2D)location {
  dispatch_sync(self.markersDispatchQueue, ^{
    dispatch_sync(dispatch_get_main_queue(), ^{
      FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
      if (!controller) {
        return;
      }
      [self.callbackHandler didEndDragForMarkerWithIdentifier:identifier
                                                   atPosition:FGMGetPigeonLatLngForCoordinate(location)
                                                   completion:^(FlutterError *_Nullable _){
                                                   }];
    });
  });
}

- (void)didTapInfoWindowOfMarkerWithIdentifier:(NSString *)identifier {
  dispatch_sync(self.markersDispatchQueue, ^{
    dispatch_sync(dispatch_get_main_queue(), ^{
      if (identifier && self.markerIdentifierToController[identifier]) {
        [self.callbackHandler didTapInfoWindowOfMarkerWithIdentifier:identifier
                                                          completion:^(FlutterError *_Nullable _){
                                                          }];
      }
    });
  });
}

- (void)showMarkerInfoWindowWithIdentifier:(NSString *)identifier
                                     error:
                                         (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  dispatch_sync(self.markersDispatchQueue, ^{
    dispatch_sync(dispatch_get_main_queue(), ^{
      FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
      if (controller) {
        [controller showInfoWindow];
      } else {
        *error = [FlutterError errorWithCode:@"Invalid markerId"
                                     message:@"showInfoWindow called with invalid markerId"
                                     details:nil];
      }
    });
  });
}

- (void)hideMarkerInfoWindowWithIdentifier:(NSString *)identifier
                                     error:
                                         (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  dispatch_sync(self.markersDispatchQueue, ^{
    dispatch_sync(dispatch_get_main_queue(), ^{
      FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
        if (controller) {
          [controller hideInfoWindow];
        } else {
          *error = [FlutterError errorWithCode:@"Invalid markerId"
                                       message:@"hideInfoWindow called with invalid markerId"
                                       details:nil];
        }
    });
  });
}

- (nullable NSNumber *)
    isInfoWindowShownForMarkerWithIdentifier:(NSString *)identifier
                                       error:(FlutterError *_Nullable __autoreleasing *_Nonnull)
                                                 error {
  __block NSNumber* result = nil;
  
  dispatch_sync(self.markersDispatchQueue, ^{
    dispatch_sync(dispatch_get_main_queue(), ^{
      FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
      if (controller) {
        result = @([controller isInfoWindowShown]);
      } else {
        *error = [FlutterError errorWithCode:@"Invalid markerId"
                                     message:@"isInfoWindowShown called with invalid markerId"
                                     details:nil];
        result = nil;
      }
    });
  });
  
  return result;
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

+ (CLLocationCoordinate2D)getPosition:(NSDictionary *)marker {
  NSArray *position = marker[@"position"];
  return [FLTGoogleMapJSONConversions locationFromLatLong:position];
}

@end
