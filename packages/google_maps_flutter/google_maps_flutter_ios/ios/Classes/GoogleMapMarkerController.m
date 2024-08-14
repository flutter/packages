// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMapMarkerController.h"

#import "FGMMarkerUserData.h"
#import "FLTGoogleMapJSONConversions.h"

@interface FLTGoogleMapMarkerController ()

@property(strong, nonatomic) GMSMarker *marker;
@property(weak, nonatomic) GMSMapView *mapView;
@property(assign, nonatomic, readwrite) BOOL consumeTapEvents;
/// The unique identifier for the cluster manager.
@property(copy, nonatomic, nullable) NSString *clusterManagerIdentifier;
/// The unique identifier for the marker.
@property(copy, nonatomic) NSString *markerIdentifier;

@end

@implementation FLTGoogleMapMarkerController

- (instancetype)initWithMarker:(GMSMarker *)marker
              markerIdentifier:(NSString *)markerIdentifier
      clusterManagerIdentifier:(nullable NSString *)clusterManagerIdentifier
                       mapView:(GMSMapView *)mapView {
  self = [super init];
  if (self) {
    _marker = marker;
    _markerIdentifier = [markerIdentifier copy];
    _clusterManagerIdentifier = [clusterManagerIdentifier copy];
    _mapView = mapView;
    FGMSetIdentifiersToMarkerUserData(_markerIdentifier, _clusterManagerIdentifier, _marker);
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
  self.marker.opacity = alpha;
}

- (void)setAnchor:(CGPoint)anchor {
  self.marker.groundAnchor = anchor;
}

- (void)setDraggable:(BOOL)draggable {
  self.marker.draggable = draggable;
}

- (void)setFlat:(BOOL)flat {
  self.marker.flat = flat;
}

- (void)setIcon:(UIImage *)icon {
  self.marker.icon = icon;
}

- (void)setInfoWindowAnchor:(CGPoint)anchor {
  self.marker.infoWindowAnchor = anchor;
}

- (void)setInfoWindowTitle:(NSString *)title snippet:(NSString *)snippet {
  self.marker.title = title;
  self.marker.snippet = snippet;
}

- (void)setPosition:(CLLocationCoordinate2D)position {
  self.marker.position = position;
}

- (void)setRotation:(CLLocationDegrees)rotation {
  self.marker.rotation = rotation;
}

- (void)setVisible:(BOOL)visible {
  // If marker belongs the cluster manager, visibility need to be controlled with the opacity
  // as the cluster manager controls when marker is on the map and when not.
  // Alpha value for marker must always be interpreted before visibility value.
  if (self.clusterManagerIdentifier) {
    self.marker.opacity = visible ? self.marker.opacity : 0.0f;
  } else {
    self.marker.map = visible ? self.mapView : nil;
  }
}

- (void)setZIndex:(int)zIndex {
  self.marker.zIndex = zIndex;
}

- (void)interpretMarkerOptions:(NSDictionary *)data
                     registrar:(NSObject<FlutterPluginRegistrar> *)registrar
                   screenScale:(CGFloat)screenScale {
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
    UIImage *image = [self extractIconFromData:icon registrar:registrar screenScale:screenScale];
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
  NSNumber *visible = FGMGetValueOrNilFromDict(data, @"visible");
  if (visible) {
    [self setVisible:[visible boolValue]];
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

- (UIImage *)extractIconFromData:(NSArray *)iconData
                       registrar:(NSObject<FlutterPluginRegistrar> *)registrar
                     screenScale:(CGFloat)screenScale {
  NSAssert(screenScale > 0, @"Screen scale must be greater than 0");
  UIImage *image;
  if ([iconData.firstObject isEqualToString:@"defaultMarker"]) {
    CGFloat hue = (iconData.count == 1) ? 0.0f : [iconData[1] doubleValue];
    image = [GMSMarker markerImageWithColor:[UIColor colorWithHue:hue / 360.0
                                                       saturation:1.0
                                                       brightness:0.7
                                                            alpha:1.0]];
  } else if ([iconData.firstObject isEqualToString:@"fromAsset"]) {
    // Deprecated: This message handling for 'fromAsset' has been replaced by 'asset'.
    // Refer to the flutter google_maps_flutter_platform_interface package for details.
    if (iconData.count == 2) {
      image = [UIImage imageNamed:[registrar lookupKeyForAsset:iconData[1]]];
    } else {
      image = [UIImage imageNamed:[registrar lookupKeyForAsset:iconData[1]
                                                   fromPackage:iconData[2]]];
    }
  } else if ([iconData.firstObject isEqualToString:@"fromAssetImage"]) {
    // Deprecated: This message handling for 'fromAssetImage' has been replaced by 'asset'.
    // Refer to the flutter google_maps_flutter_platform_interface package for details.
    if (iconData.count == 3) {
      image = [UIImage imageNamed:[registrar lookupKeyForAsset:iconData[1]]];
      id scaleParam = iconData[2];
      image = [self scaleImage:image by:scaleParam];
    } else {
      NSString *error =
          [NSString stringWithFormat:@"'fromAssetImage' should have exactly 3 arguments. Got: %lu",
                                     (unsigned long)iconData.count];
      NSException *exception = [NSException exceptionWithName:@"InvalidBitmapDescriptor"
                                                       reason:error
                                                     userInfo:nil];
      @throw exception;
    }
  } else if ([iconData[0] isEqualToString:@"fromBytes"]) {
    // Deprecated: This message handling for 'fromBytes' has been replaced by 'bytes'.
    // Refer to the flutter google_maps_flutter_platform_interface package for details.
    if (iconData.count == 2) {
      @try {
        FlutterStandardTypedData *byteData = iconData[1];
        CGFloat mainScreenScale = [[UIScreen mainScreen] scale];
        image = [UIImage imageWithData:[byteData data] scale:mainScreenScale];
      } @catch (NSException *exception) {
        @throw [NSException exceptionWithName:@"InvalidByteDescriptor"
                                       reason:@"Unable to interpret bytes as a valid image."
                                     userInfo:nil];
      }
    } else {
      NSString *error = [NSString
          stringWithFormat:@"fromBytes should have exactly one argument, the bytes. Got: %lu",
                           (unsigned long)iconData.count];
      NSException *exception = [NSException exceptionWithName:@"InvalidByteDescriptor"
                                                       reason:error
                                                     userInfo:nil];
      @throw exception;
    }
  } else if ([iconData.firstObject isEqualToString:@"asset"]) {
    NSDictionary *assetData = iconData[1];
    if (![assetData isKindOfClass:[NSDictionary class]]) {
      NSException *exception =
          [NSException exceptionWithName:@"InvalidByteDescriptor"
                                  reason:@"Unable to interpret asset, expected a dictionary as the "
                                         @"second parameter."
                                userInfo:nil];
      @throw exception;
    }

    NSString *assetName = FGMGetValueOrNilFromDict(assetData, @"assetName");
    NSString *scalingMode = FGMGetValueOrNilFromDict(assetData, @"bitmapScaling");

    image = [UIImage imageNamed:[registrar lookupKeyForAsset:assetName]];

    if ([scalingMode isEqualToString:@"auto"]) {
      NSNumber *width = FGMGetValueOrNilFromDict(assetData, @"width");
      NSNumber *height = FGMGetValueOrNilFromDict(assetData, @"height");
      CGFloat imagePixelRatio =
          [FGMGetValueOrNilFromDict(assetData, @"imagePixelRatio") doubleValue];

      if (width || height) {
        image = [FLTGoogleMapMarkerController scaledImage:image withScale:screenScale];
        image = [FLTGoogleMapMarkerController scaledImage:image
                                                withWidth:width
                                                   height:height
                                              screenScale:screenScale];
      } else {
        image = [FLTGoogleMapMarkerController scaledImage:image withScale:imagePixelRatio];
      }
    }
  } else if ([iconData[0] isEqualToString:@"bytes"]) {
    NSDictionary *byteData = iconData[1];
    if (![byteData isKindOfClass:[NSDictionary class]]) {
      NSException *exception =
          [NSException exceptionWithName:@"InvalidByteDescriptor"
                                  reason:@"Unable to interpret bytes, expected a dictionary as the "
                                         @"second parameter."
                                userInfo:nil];
      @throw exception;
    }

    FlutterStandardTypedData *bytes = FGMGetValueOrNilFromDict(byteData, @"byteData");
    NSString *scalingMode = FGMGetValueOrNilFromDict(byteData, @"bitmapScaling");

    @try {
      image = [UIImage imageWithData:[bytes data] scale:screenScale];
      if ([scalingMode isEqualToString:@"auto"]) {
        NSNumber *width = FGMGetValueOrNilFromDict(byteData, @"width");
        NSNumber *height = FGMGetValueOrNilFromDict(byteData, @"height");
        CGFloat imagePixelRatio =
            [FGMGetValueOrNilFromDict(byteData, @"imagePixelRatio") doubleValue];

        if (width || height) {
          // Before scaling the image, image must be in screenScale
          image = [FLTGoogleMapMarkerController scaledImage:image withScale:screenScale];
          image = [FLTGoogleMapMarkerController scaledImage:image
                                                  withWidth:width
                                                     height:height
                                                screenScale:screenScale];
        } else {
          image = [FLTGoogleMapMarkerController scaledImage:image withScale:imagePixelRatio];
        }
      } else {
        // No scaling, load image from bytes without scale parameter.
        image = [UIImage imageWithData:[bytes data]];
      }
    } @catch (NSException *exception) {
      @throw [NSException exceptionWithName:@"InvalidByteDescriptor"
                                     reason:@"Unable to interpret bytes as a valid image."
                                   userInfo:nil];
    }
  }

  return image;
}

/// This method is deprecated within the context of `BitmapDescriptor.fromBytes` handling in the
/// flutter google_maps_flutter_platform_interface package which has been replaced by 'bytes'
/// message handling. It will be removed when the deprecated image bitmap description type
/// 'fromBytes' is removed from the platform interface.
- (UIImage *)scaleImage:(UIImage *)image by:(id)scaleParam {
  double scale = 1.0;
  if ([scaleParam isKindOfClass:[NSNumber class]]) {
    scale = [scaleParam doubleValue];
  }
  if (fabs(scale - 1) > 1e-3) {
    return [UIImage imageWithCGImage:[image CGImage]
                               scale:(image.scale * scale)
                         orientation:(image.imageOrientation)];
  }
  return image;
}

/// Creates a scaled version of the provided UIImage based on a specified scale factor. If the
/// scale factor differs from the image's current scale by more than a small epsilon-delta (to
/// account for minor floating-point inaccuracies), a new UIImage object is created with the
/// specified scale. Otherwise, the original image is returned.
///
/// @param image The UIImage to scale.
/// @param scale The factor by which to scale the image.
/// @return UIImage Returns the scaled UIImage.
+ (UIImage *)scaledImage:(UIImage *)image withScale:(CGFloat)scale {
  if (fabs(scale - image.scale) > DBL_EPSILON) {
    return [UIImage imageWithCGImage:[image CGImage]
                               scale:scale
                         orientation:(image.imageOrientation)];
  }
  return image;
}

/// Scales an input UIImage to a specified size. If the aspect ratio of the input image
/// closely matches the target size, indicated by a small epsilon-delta, the image's scale
/// property is updated instead of resizing the image. If the aspect ratios differ beyond this
/// threshold, the method redraws the image at the target size.
///
/// @param image The UIImage to scale.
/// @param size The target CGSize to scale the image to.
/// @return UIImage Returns the scaled UIImage.
+ (UIImage *)scaledImage:(UIImage *)image withSize:(CGSize)size {
  CGFloat originalPixelWidth = image.size.width * image.scale;
  CGFloat originalPixelHeight = image.size.height * image.scale;

  // Return original image if either original image size or target size is so small that
  // image cannot be resized or displayed.
  if (originalPixelWidth <= 0 || originalPixelHeight <= 0 || size.width <= 0 || size.height <= 0) {
    return image;
  }

  // Check if the image's size, accounting for scale, matches the target size.
  if (fabs(originalPixelWidth - size.width) <= DBL_EPSILON &&
      fabs(originalPixelHeight - size.height) <= DBL_EPSILON) {
    // No need for resizing, return the original image
    return image;
  }

  // Check if the aspect ratios are approximately equal.
  CGSize originalPixelSize = CGSizeMake(originalPixelWidth, originalPixelHeight);
  if ([FLTGoogleMapMarkerController isScalableWithScaleFactorFromSize:originalPixelSize
                                                               toSize:size]) {
    // Scaled image has close to same aspect ratio,
    // updating image scale instead of resizing image.
    CGFloat factor = originalPixelWidth / size.width;
    return [FLTGoogleMapMarkerController scaledImage:image withScale:(image.scale * factor)];
  } else {
    // Aspect ratios differ significantly, resize the image.
    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
    format.scale = 1.0;
    format.opaque = NO;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size
                                                                               format:format];
    UIImage *newImage =
        [renderer imageWithActions:^(UIGraphicsImageRendererContext *_Nonnull context) {
          [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        }];

    // Return image with proper scaling.
    return [FLTGoogleMapMarkerController scaledImage:newImage withScale:image.scale];
  }
}

/// Scales an input UIImage to a specified width and height preserving aspect ratio if both
/// widht and height are not given..
///
/// @param image The UIImage to scale.
/// @param width The target width to scale the image to.
/// @param height The target height to scale the image to.
/// @param screenScale The current screen scale.
/// @return UIImage Returns the scaled UIImage.
+ (UIImage *)scaledImage:(UIImage *)image
               withWidth:(NSNumber *)width
                  height:(NSNumber *)height
             screenScale:(CGFloat)screenScale {
  if (!width && !height) {
    return image;
  }

  CGFloat targetWidth = width ? width.doubleValue : image.size.width;
  CGFloat targetHeight = height ? height.doubleValue : image.size.height;

  if (width && !height) {
    // Calculate height based on aspect ratio if only width is provided.
    double aspectRatio = image.size.height / image.size.width;
    targetHeight = round(targetWidth * aspectRatio);
  } else if (!width && height) {
    // Calculate width based on aspect ratio if only height is provided.
    double aspectRatio = image.size.width / image.size.height;
    targetWidth = round(targetHeight * aspectRatio);
  }

  CGSize targetSize =
      CGSizeMake(round(targetWidth * screenScale), round(targetHeight * screenScale));
  return [FLTGoogleMapMarkerController scaledImage:image withSize:targetSize];
}

+ (BOOL)isScalableWithScaleFactorFromSize:(CGSize)originalSize toSize:(CGSize)targetSize {
  // Select the scaling factor based on the longer side to have good precision.
  CGFloat scaleFactor = (originalSize.width > originalSize.height)
                            ? (targetSize.width / originalSize.width)
                            : (targetSize.height / originalSize.height);

  // Calculate the scaled dimensions.
  CGFloat scaledWidth = originalSize.width * scaleFactor;
  CGFloat scaledHeight = originalSize.height * scaleFactor;

  // Check if the scaled dimensions are within a one-pixel
  // threshold of the target dimensions.
  BOOL widthWithinThreshold = fabs(scaledWidth - targetSize.width) <= 1.0;
  BOOL heightWithinThreshold = fabs(scaledHeight - targetSize.height) <= 1.0;

  // The image is considered scalable with scale factor
  // if both dimensions are within the threshold.
  return widthWithinThreshold && heightWithinThreshold;
}

@end

@interface FLTMarkersController ()

@property(strong, nonatomic) NSMutableDictionary *markerIdentifierToController;
@property(strong, nonatomic) FGMMapsCallbackApi *callbackHandler;
/// Controller for adding/removing/fetching cluster managers
@property(weak, nonatomic, nullable) FGMClusterManagersController *clusterManagersController;
@property(weak, nonatomic) NSObject<FlutterPluginRegistrar> *registrar;
@property(weak, nonatomic) GMSMapView *mapView;

@end

@implementation FLTMarkersController

- (instancetype)initWithMapView:(GMSMapView *)mapView
                callbackHandler:(FGMMapsCallbackApi *)callbackHandler
      clusterManagersController:(nullable FGMClusterManagersController *)clusterManagersController
                      registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _callbackHandler = callbackHandler;
    _mapView = mapView;
    _clusterManagersController = clusterManagersController;
    _markerIdentifierToController = [[NSMutableDictionary alloc] init];
    _registrar = registrar;
  }
  return self;
}

- (void)addMarkers:(NSArray<FGMPlatformMarker *> *)markersToAdd {
  for (FGMPlatformMarker *marker in markersToAdd) {
    [self addJSONMarker:marker.json];
  }
}

- (void)addJSONMarker:(NSDictionary<NSString *, id> *)markerToAdd {
  CLLocationCoordinate2D position = [FLTMarkersController getPosition:markerToAdd];
  NSString *markerIdentifier = markerToAdd[@"markerId"];
  NSString *clusterManagerIdentifier = markerToAdd[@"clusterManagerId"];
  GMSMarker *marker = [GMSMarker markerWithPosition:position];
  FLTGoogleMapMarkerController *controller =
      [[FLTGoogleMapMarkerController alloc] initWithMarker:marker
                                          markerIdentifier:markerIdentifier
                                  clusterManagerIdentifier:clusterManagerIdentifier
                                                   mapView:self.mapView];
  [controller interpretMarkerOptions:markerToAdd
                           registrar:self.registrar
                         screenScale:[self getScreenScale]];
  if (clusterManagerIdentifier) {
    GMUClusterManager *clusterManager =
        [_clusterManagersController clusterManagerWithIdentifier:clusterManagerIdentifier];
    if ([marker conformsToProtocol:@protocol(GMUClusterItem)]) {
      [clusterManager addItem:(id<GMUClusterItem>)marker];
    }
  }
  self.markerIdentifierToController[markerIdentifier] = controller;
}

- (void)changeMarkers:(NSArray<FGMPlatformMarker *> *)markersToChange {
  for (FGMPlatformMarker *marker in markersToChange) {
    [self changeMarker:marker];
  }
}

- (void)changeMarker:(FGMPlatformMarker *)markerToChange {
  NSString *markerIdentifier = markerToChange.json[@"markerId"];
  NSString *clusterManagerIdentifier = markerToChange.json[@"clusterManagerId"];

  FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[markerIdentifier];
  if (!controller) {
    return;
  }
  NSString *previousClusterManagerIdentifier = [controller clusterManagerIdentifier];
  if (![previousClusterManagerIdentifier isEqualToString:clusterManagerIdentifier]) {
    [self removeMarker:markerIdentifier];
    [self addJSONMarker:markerToChange.json];
  } else {
    [controller interpretMarkerOptions:markerToChange.json
                             registrar:self.registrar
                           screenScale:[self getScreenScale]];
  }
}

- (void)removeMarkersWithIdentifiers:(NSArray<NSString *> *)identifiers {
  for (NSString *identifier in identifiers) {
    [self removeMarker:identifier];
  }
}

- (void)removeMarker:(NSString *)identifier {
  FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
  if (!controller) {
    return;
  }
  NSString *clusterManagerIdentifier = [controller clusterManagerIdentifier];
  if (clusterManagerIdentifier) {
    GMUClusterManager *clusterManager =
        [_clusterManagersController clusterManagerWithIdentifier:clusterManagerIdentifier];
    [clusterManager removeItem:(id<GMUClusterItem>)controller.marker];
  } else {
    [controller removeMarker];
  }
  [self.markerIdentifierToController removeObjectForKey:identifier];
}

- (BOOL)didTapMarkerWithIdentifier:(NSString *)identifier {
  if (!identifier) {
    return NO;
  }
  FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
  if (!controller) {
    return NO;
  }
  [self.callbackHandler didTapMarkerWithIdentifier:identifier
                                        completion:^(FlutterError *_Nullable _){
                                        }];
  return controller.consumeTapEvents;
}

- (void)didStartDraggingMarkerWithIdentifier:(NSString *)identifier
                                    location:(CLLocationCoordinate2D)location {
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
}

- (void)didDragMarkerWithIdentifier:(NSString *)identifier
                           location:(CLLocationCoordinate2D)location {
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
}

- (void)didEndDraggingMarkerWithIdentifier:(NSString *)identifier
                                  location:(CLLocationCoordinate2D)location {
  FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
  if (!controller) {
    return;
  }
  [self.callbackHandler didEndDragForMarkerWithIdentifier:identifier
                                               atPosition:FGMGetPigeonLatLngForCoordinate(location)
                                               completion:^(FlutterError *_Nullable _){
                                               }];
}

- (void)didTapInfoWindowOfMarkerWithIdentifier:(NSString *)identifier {
  if (identifier && self.markerIdentifierToController[identifier]) {
    [self.callbackHandler didTapInfoWindowOfMarkerWithIdentifier:identifier
                                                      completion:^(FlutterError *_Nullable _){
                                                      }];
  }
}

- (void)showMarkerInfoWindowWithIdentifier:(NSString *)identifier
                                     error:
                                         (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
  if (controller) {
    [controller showInfoWindow];
  } else {
    *error = [FlutterError errorWithCode:@"Invalid markerId"
                                 message:@"showInfoWindow called with invalid markerId"
                                 details:nil];
  }
}

- (void)hideMarkerInfoWindowWithIdentifier:(NSString *)identifier
                                     error:
                                         (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
  if (controller) {
    [controller hideInfoWindow];
  } else {
    *error = [FlutterError errorWithCode:@"Invalid markerId"
                                 message:@"hideInfoWindow called with invalid markerId"
                                 details:nil];
  }
}

- (nullable NSNumber *)
    isInfoWindowShownForMarkerWithIdentifier:(NSString *)identifier
                                       error:(FlutterError *_Nullable __autoreleasing *_Nonnull)
                                                 error {
  FLTGoogleMapMarkerController *controller = self.markerIdentifierToController[identifier];
  if (controller) {
    return @([controller isInfoWindowShown]);
  } else {
    *error = [FlutterError errorWithCode:@"Invalid markerId"
                                 message:@"isInfoWindowShown called with invalid markerId"
                                 details:nil];
    return nil;
  }
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
