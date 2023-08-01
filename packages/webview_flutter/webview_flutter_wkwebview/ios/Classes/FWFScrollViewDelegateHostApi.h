// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <WebKit/WebKit.h>
#import "FWFObjectHostApi.h"

#import "FWFGeneratedWebKitApis.h"
#import "FWFInstanceManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Flutter api implementation for UIScrollViewDelegate.
 *
 * Handles making callbacks to Dart for a UIScrollViewDelegate.
 */
@interface FWFScrollViewDelegateFlutterApiImpl : FWFUIScrollViewDelegateFlutterApi

- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager;
@end

/**
 * Implementation of WKUIScrollViewDelegate for FWFUIScrollViewDelegateHostApiImpl.
 */
@interface FWFScrollViewDelegate : FWFObject <UIScrollViewDelegate>
@property(readonly, nonnull, nonatomic) FWFScrollViewDelegateFlutterApiImpl *ScrollViewDelegateAPI;

- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager;

@end

/**
 * Host api implementation for UIScrollViewDelegate.
 *
 * Handles creating UIScrollView that intercommunicate with a paired Dart object.
 */
@interface FWFScrollViewDelegateHostApiImpl : NSObject <FWFUIScrollViewDelegateHostApi>
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager;
@end

NS_ASSUME_NONNULL_END
