// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>

#import "messages.g.h"

NS_ASSUME_NONNULL_BEGIN

@interface FLTGoogleMapTileOverlayController : NSObject
/// The layer managed by this controller instance.
@property(readonly, nonatomic) GMSTileLayer *layer;

- (instancetype)initWithTileLayer:(GMSTileLayer *)tileLayer
                          mapView:(GMSMapView *)mapView
                          options:(NSDictionary *)optionsData;
- (void)removeTileOverlay;
- (void)clearTileCache;
@end

@interface FLTTileProviderController : GMSTileLayer
@property(copy, nonatomic, readonly) NSString *tileOverlayIdentifier;
- (instancetype)initWithTileOverlayIdentifier:(NSString *)identifier
                              callbackHandler:(FGMMapsCallbackApi *)callbackHandler;
@end

@interface FLTTileOverlaysController : NSObject
- (instancetype)initWithMapView:(GMSMapView *)mapView
                callbackHandler:(FGMMapsCallbackApi *)callbackHandler
                      registrar:(NSObject<FlutterPluginRegistrar> *)registrar;
- (void)addTileOverlays:(NSArray<FGMPlatformTileOverlay *> *)tileOverlaysToAdd;
- (void)changeTileOverlays:(NSArray<FGMPlatformTileOverlay *> *)tileOverlaysToChange;
- (void)removeTileOverlayWithIdentifiers:(NSArray<NSString *> *)identifiers;
- (void)clearTileCacheWithIdentifier:(NSString *)identifier;
- (nullable FLTGoogleMapTileOverlayController *)tileOverlayWithIdentifier:(NSString *)identifier;
@end

NS_ASSUME_NONNULL_END
