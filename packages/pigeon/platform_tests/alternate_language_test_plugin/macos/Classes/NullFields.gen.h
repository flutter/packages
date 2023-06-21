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

typedef NS_ENUM(NSUInteger, NullFieldsSearchReplyType) {
  NullFieldsSearchReplyTypeSuccess = 0,
  NullFieldsSearchReplyTypeFailure = 1,
};

@class NullFieldsSearchRequest;
@class NullFieldsSearchReply;

@interface NullFieldsSearchRequest : NSObject
/// `init` unavailable to enforce nonnull fields, see the `make` class method.
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)makeWithQuery:(nullable NSString *)query identifier:(NSNumber *)identifier;
@property(nonatomic, copy, nullable) NSString *query;
@property(nonatomic, strong) NSNumber *identifier;
@end

@interface NullFieldsSearchReply : NSObject
+ (instancetype)makeWithResult:(nullable NSString *)result
                         error:(nullable NSString *)error
                       indices:(nullable NSArray<NSNumber *> *)indices
                       request:(nullable NullFieldsSearchRequest *)request
                          type:(NullFieldsSearchReplyType)type;
@property(nonatomic, copy, nullable) NSString *result;
@property(nonatomic, copy, nullable) NSString *error;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *indices;
@property(nonatomic, strong, nullable) NullFieldsSearchRequest *request;
@property(nonatomic, assign) NullFieldsSearchReplyType type;
@end

/// The codec used by NullFieldsHostApi.
NSObject<FlutterMessageCodec> *NullFieldsHostApiGetCodec(void);

@protocol NullFieldsHostApi
/// @return `nil` only when `error != nil`.
- (nullable NullFieldsSearchReply *)searchNested:(NullFieldsSearchRequest *)nested
                                           error:(FlutterError *_Nullable *_Nonnull)error;
@end

extern void NullFieldsHostApiSetup(id<FlutterBinaryMessenger> binaryMessenger,
                                   NSObject<NullFieldsHostApi> *_Nullable api);

/// The codec used by NullFieldsFlutterApi.
NSObject<FlutterMessageCodec> *NullFieldsFlutterApiGetCodec(void);

@interface NullFieldsFlutterApi : NSObject
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger;
- (void)searchRequest:(NullFieldsSearchRequest *)request
           completion:
               (void (^)(NullFieldsSearchReply *_Nullable, FlutterError *_Nullable))completion;
@end

NS_ASSUME_NONNULL_END
