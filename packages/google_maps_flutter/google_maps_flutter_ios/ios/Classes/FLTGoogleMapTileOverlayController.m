// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTGoogleMapTileOverlayController.h"
#import "FLTGoogleMapJSONConversions.h"

@interface FLTGoogleMapTileOverlayController ()

@property(strong, nonatomic) GMSTileLayer *layer;
@property(weak, nonatomic) GMSMapView *mapView;

@end

@implementation FLTGoogleMapTileOverlayController

- (instancetype)initWithTileOverlay:(FGMPlatformTileOverlay *)tileOverlay
                          tileLayer:(GMSTileLayer *)tileLayer
                            mapView:(GMSMapView *)mapView {
  self = [super init];
  if (self) {
    _layer = tileLayer;
    _mapView = mapView;
    // TODO(stuartmorgan: Refactor to avoid this call to an instance method in init.
    [self updateFromPlatformTileOverlay:tileOverlay];
  }
  return self;
}

- (void)removeTileOverlay {
  self.layer.map = nil;
}

- (void)clearTileCache {
  [self.layer clearTileCache];
}

- (void)setFadeIn:(BOOL)fadeIn {
  self.layer.fadeIn = fadeIn;
}

- (void)setTransparency:(float)transparency {
  float opacity = 1.0 - transparency;
  self.layer.opacity = opacity;
}

- (void)setVisible:(BOOL)visible {
  self.layer.map = visible ? self.mapView : nil;
}

- (void)setZIndex:(int)zIndex {
  self.layer.zIndex = zIndex;
}

- (void)setTileSize:(NSInteger)tileSize {
  self.layer.tileSize = tileSize;
}

- (void)updateFromPlatformTileOverlay:(FGMPlatformTileOverlay *)overlay {
  [self setVisible:overlay.visible];
  [self setTransparency:overlay.transparency];
  [self setZIndex:(int)overlay.zIndex];
  [self setFadeIn:overlay.fadeIn];
  [self setTileSize:overlay.tileSize];
}

@end

@interface FLTTileProviderController ()

@property(strong, nonatomic) FGMMapsCallbackApi *callbackHandler;

@end

@implementation FLTTileProviderController

- (instancetype)initWithTileOverlayIdentifier:(NSString *)identifier
                              callbackHandler:(FGMMapsCallbackApi *)callbackHandler {
  self = [super init];
  if (self) {
    _callbackHandler = callbackHandler;
    _tileOverlayIdentifier = identifier;
  }
  return self;
}

#pragma mark - GMSTileLayer method

- (UIImage *)handleResultTile:(nullable UIImage *)tile {
  CGImageRef imageRef = tile.CGImage;
  CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
  BOOL isFloat = bitmapInfo && kCGBitmapFloatComponents;
  size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);

  // Engine use f16 pixel format for wide gamut images
  // If it is wide gamut, we want to downsample it
  if (isFloat & (bitsPerComponent == 16)) {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(nil, tile.size.width, tile.size.height, 8, 0,
                                                 colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, tile.size.width, tile.size.height), tile.CGImage);
    CGImageRef image = CGBitmapContextCreateImage(context);
    tile = [UIImage imageWithCGImage:image];

    CGImageRelease(image);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
  }
  return tile;
}

- (void)requestTileForX:(NSUInteger)x
                      y:(NSUInteger)y
                   zoom:(NSUInteger)zoom
               receiver:(id<GMSTileReceiver>)receiver {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.callbackHandler
        tileWithOverlayIdentifier:self.tileOverlayIdentifier
                         location:[FGMPlatformPoint makeWithX:x y:y]
                             zoom:zoom
                       completion:^(FGMPlatformTile *_Nullable tile,
                                    FlutterError *_Nullable error) {
                         FlutterStandardTypedData *typedData = tile.data;
                         UIImage *tileImage =
                             typedData
                                 ? [self handleResultTile:[UIImage imageWithData:typedData.data]]
                                 : kGMSTileLayerNoTile;
                         if (error) {
                           NSLog(@"Can't get tile: errorCode = %@, errorMessage = %@, details = %@",
                                 [error code], [error message], [error details]);
                         }
                         [receiver receiveTileWithX:x y:y zoom:zoom image:tileImage];
                       }];
  });
}

@end

@interface FLTTileOverlaysController ()

@property(strong, nonatomic) NSMutableDictionary<NSString *, FLTGoogleMapTileOverlayController *>
    *tileOverlayIdentifierToController;
@property(strong, nonatomic) FGMMapsCallbackApi *callbackHandler;
@property(weak, nonatomic) GMSMapView *mapView;

@end

@implementation FLTTileOverlaysController

- (instancetype)initWithMapView:(GMSMapView *)mapView
                callbackHandler:(FGMMapsCallbackApi *)callbackHandler
                      registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _callbackHandler = callbackHandler;
    _mapView = mapView;
    _tileOverlayIdentifierToController = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)addTileOverlays:(NSArray<FGMPlatformTileOverlay *> *)tileOverlaysToAdd {
  for (FGMPlatformTileOverlay *tileOverlay in tileOverlaysToAdd) {
    NSString *identifier = tileOverlay.tileOverlayId;
    FLTTileProviderController *tileProvider =
        [[FLTTileProviderController alloc] initWithTileOverlayIdentifier:identifier
                                                         callbackHandler:self.callbackHandler];
    FLTGoogleMapTileOverlayController *controller =
        [[FLTGoogleMapTileOverlayController alloc] initWithTileOverlay:tileOverlay
                                                             tileLayer:tileProvider
                                                               mapView:self.mapView];
    self.tileOverlayIdentifierToController[identifier] = controller;
  }
}

- (void)changeTileOverlays:(NSArray<FGMPlatformTileOverlay *> *)tileOverlaysToChange {
  for (FGMPlatformTileOverlay *tileOverlay in tileOverlaysToChange) {
    NSString *identifier = tileOverlay.tileOverlayId;
    FLTGoogleMapTileOverlayController *controller =
        self.tileOverlayIdentifierToController[identifier];
    [controller updateFromPlatformTileOverlay:tileOverlay];
  }
}
- (void)removeTileOverlayWithIdentifiers:(NSArray<NSString *> *)identifiers {
  for (NSString *identifier in identifiers) {
    FLTGoogleMapTileOverlayController *controller =
        self.tileOverlayIdentifierToController[identifier];
    if (!controller) {
      continue;
    }
    [controller removeTileOverlay];
    [self.tileOverlayIdentifierToController removeObjectForKey:identifier];
  }
}

- (void)clearTileCacheWithIdentifier:(NSString *)identifier {
  FLTGoogleMapTileOverlayController *controller =
      self.tileOverlayIdentifierToController[identifier];
  [controller clearTileCache];
}

- (nullable FLTGoogleMapTileOverlayController *)tileOverlayWithIdentifier:(NSString *)identifier {
  return self.tileOverlayIdentifierToController[identifier];
}

@end
