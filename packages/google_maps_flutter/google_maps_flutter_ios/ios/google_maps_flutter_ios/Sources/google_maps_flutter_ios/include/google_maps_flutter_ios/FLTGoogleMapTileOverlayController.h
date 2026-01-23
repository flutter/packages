// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import GoogleMaps;

#import "google_maps_flutter_pigeon_messages.g.h"

NS_ASSUME_NONNULL_BEGIN

/// Protocol for requesting tiles from the Dart side.
@protocol FGMTileProviderDelegate <NSObject>
- (void)tileWithOverlayIdentifier:(NSString *)tileOverlayId
                         location:(FGMPlatformPoint *)location
                             zoom:(NSInteger)zoom
                       completion:(void (^)(FGMPlatformTile *_Nullable,
                                            FlutterError *_Nullable))completion;
@end

#pragma mark -

@interface FLTGoogleMapTileOverlayController : NSObject
/// The layer managed by this controller instance.
@property(readonly, nonatomic) GMSTileLayer *layer;

- (instancetype)initWithTileOverlay:(FGMPlatformTileOverlay *)tileOverlay
                          tileLayer:(GMSTileLayer *)tileLayer
                            mapView:(GMSMapView *)mapView;
- (void)removeTileOverlay;
- (void)clearTileCache;
@end

@interface FLTTileProviderController : GMSTileLayer
@property(copy, nonatomic, readonly) NSString *tileOverlayIdentifier;
- (instancetype)initWithTileOverlayIdentifier:(NSString *)identifier
                                 tileProvider:(NSObject<FGMTileProviderDelegate> *)tileProvider;
@end

@interface FLTTileOverlaysController : NSObject
- (instancetype)initWithMapView:(GMSMapView *)mapView
                   tileProvider:(NSObject<FGMTileProviderDelegate> *)tileProvider;
- (void)addTileOverlays:(NSArray<FGMPlatformTileOverlay *> *)tileOverlaysToAdd;
- (void)changeTileOverlays:(NSArray<FGMPlatformTileOverlay *> *)tileOverlaysToChange;
- (void)removeTileOverlayWithIdentifiers:(NSArray<NSString *> *)identifiers;
- (void)clearTileCacheWithIdentifier:(NSString *)identifier;
- (nullable FLTGoogleMapTileOverlayController *)tileOverlayWithIdentifier:(NSString *)identifier;
@end

NS_ASSUME_NONNULL_END
