// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v11.0.1), do not edit directly.
// See also: https://pub.dev/packages/pigeon

#import <Foundation/Foundation.h>

@protocol FlutterBinaryMessenger;
@protocol FlutterMessageCodec;
@class FlutterError;
@class FlutterStandardTypedData;

NS_ASSUME_NONNULL_BEGIN

@class FPIPlatformImageData;

/// A serialization of a platform image's data.
@interface FPIPlatformImageData : NSObject
/// `init` unavailable to enforce nonnull fields, see the `make` class method.
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)makeWithData:(FlutterStandardTypedData *)data scale:(NSNumber *)scale;
/// The image data.
@property(nonatomic, strong) FlutterStandardTypedData *data;
/// The image's scale factor.
@property(nonatomic, strong) NSNumber *scale;
@end

/// The codec used by FPIPlatformImagesApi.
NSObject<FlutterMessageCodec> *FPIPlatformImagesApiGetCodec(void);

@protocol FPIPlatformImagesApi
/// Returns the URL for the given resource, or null if no such resource is
/// found.
- (nullable NSString *)resolveURLForResource:(NSString *)resourceName
                               withExtension:(nullable NSString *)extension
                                       error:(FlutterError *_Nullable *_Nonnull)error;
/// Returns the data for the image resource with the given name, or null if
/// no such resource is found.
- (nullable FPIPlatformImageData *)loadImageWithName:(NSString *)name
                                               error:(FlutterError *_Nullable *_Nonnull)error;
@end

extern void FPIPlatformImagesApiSetup(id<FlutterBinaryMessenger> binaryMessenger,
                                      NSObject<FPIPlatformImagesApi> *_Nullable api);

NS_ASSUME_NONNULL_END
