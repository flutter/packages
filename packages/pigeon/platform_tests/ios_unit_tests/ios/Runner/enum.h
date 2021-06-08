// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Autogenerated from Pigeon (v0.2.1), do not edit directly.
// See also: https://pub.dev/packages/pigeon
#import <Foundation/Foundation.h>
@protocol FlutterBinaryMessenger;
@class FlutterError;
@class FlutterStandardTypedData;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ACState) {
  ACStatePending = 0,
  ACStateSuccess = 1,
  ACStateError = 2,
};

@class ACData;

@interface ACData : NSObject
@property(nonatomic, assign) ACState state;
@end

@protocol ACEnumApi2Host
- (nullable ACData *)echo:(ACData *)input error:(FlutterError *_Nullable *_Nonnull)error;
@end

extern void ACEnumApi2HostSetup(id<FlutterBinaryMessenger> binaryMessenger,
                                id<ACEnumApi2Host> _Nullable api);

@interface ACEnumApi2Flutter : NSObject
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger;
- (void)echo:(ACData *)input completion:(void (^)(ACData *, NSError *_Nullable))completion;
@end
NS_ASSUME_NONNULL_END
