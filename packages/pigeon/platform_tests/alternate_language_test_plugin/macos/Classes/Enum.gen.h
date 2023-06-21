// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Autogenerated from Pigeon, do not edit directly.
// See also: https://pub.dev/packages/pigeon

#import <Foundation/Foundation.h>

@protocol FlutterBinaryMessenger;
@protocol FlutterMessageCodec;
@class FlutterError;
@class FlutterStandardTypedData;

NS_ASSUME_NONNULL_BEGIN

/// This comment is to test enum documentation comments.
typedef NS_ENUM(NSUInteger, EnumState) {
  /// This comment is to test enum member (Pending) documentation comments.
  EnumStatePending = 0,
  /// This comment is to test enum member (Success) documentation comments.
  EnumStateSuccess = 1,
  /// This comment is to test enum member (Error) documentation comments.
  EnumStateError = 2,
};

@class DataWithEnum;

/// This comment is to test class documentation comments.
@interface DataWithEnum : NSObject
+ (instancetype)makeWithState:(EnumState)state;
/// This comment is to test field documentation comments.
@property(nonatomic, assign) EnumState state;
@end

/// The codec used by EnumApi2Host.
NSObject<FlutterMessageCodec> *EnumApi2HostGetCodec(void);

/// This comment is to test api documentation comments.
@protocol EnumApi2Host
/// This comment is to test method documentation comments.
///
/// @return `nil` only when `error != nil`.
- (nullable DataWithEnum *)echoData:(DataWithEnum *)data
                              error:(FlutterError *_Nullable *_Nonnull)error;
@end

extern void EnumApi2HostSetup(id<FlutterBinaryMessenger> binaryMessenger,
                              NSObject<EnumApi2Host> *_Nullable api);

/// The codec used by EnumApi2Flutter.
NSObject<FlutterMessageCodec> *EnumApi2FlutterGetCodec(void);

/// This comment is to test api documentation comments.
@interface EnumApi2Flutter : NSObject
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger;
/// This comment is to test method documentation comments.
- (void)echoData:(DataWithEnum *)data
      completion:(void (^)(DataWithEnum *_Nullable, FlutterError *_Nullable))completion;
@end

NS_ASSUME_NONNULL_END
