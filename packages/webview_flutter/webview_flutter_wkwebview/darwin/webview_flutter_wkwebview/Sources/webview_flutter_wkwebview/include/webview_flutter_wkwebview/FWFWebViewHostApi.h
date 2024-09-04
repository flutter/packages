// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <WebKit/WebKit.h>

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

#import "FWFGeneratedWebKitApis.h"
#import "FWFInstanceManager.h"
#import "FWFObjectHostApi.h"

NS_ASSUME_NONNULL_BEGIN

/// A set of Flutter and Dart assets used by a `FlutterEngine` to initialize execution.
///
/// Default implementation delegates methods to FlutterDartProject.
@interface FWFAssetManager : NSObject
- (NSString *)lookupKeyForAsset:(NSString *)asset;
@end

/// Implementation of WKWebView that can be used as a FlutterPlatformView.
@interface FWFWebView : WKWebView
// The macOS platform view API doesn't have a FlutterPlatformView abstraction,
// and uses NSView directly.
#if TARGET_OS_IOS
                        <FlutterPlatformView>
#endif
@property(readonly, nonnull, nonatomic) FWFObjectFlutterApiImpl *objectApi;

- (instancetype)initWithFrame:(CGRect)frame
                configuration:(nonnull WKWebViewConfiguration *)configuration
              binaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
              instanceManager:(FWFInstanceManager *)instanceManager;
@end

/// Host api implementation for WKWebView.
///
/// Handles creating WKWebViews that intercommunicate with a paired Dart object.
@interface FWFWebViewHostApiImpl : NSObject <FWFWKWebViewHostApi>
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager;

- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager
                                 bundle:(NSBundle *)bundle
                           assetManager:(FWFAssetManager *)assetManager;
@end

NS_ASSUME_NONNULL_END
