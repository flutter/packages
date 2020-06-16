// Autogenerated from Pigeon (v0.1.2), do not edit directly.
// See also: https://pub.dev/packages/pigeon
#import <Foundation/Foundation.h>
@protocol FlutterBinaryMessenger;
@class FlutterError;
@class FlutterStandardTypedData;

NS_ASSUME_NONNULL_BEGIN

@class ACSearchReply;
@class ACSearchRequest;
@class ACNested;

@interface ACSearchReply : NSObject
@property(nonatomic, copy, nullable) NSString *result;
@property(nonatomic, copy, nullable) NSString *error;
@end

@interface ACSearchRequest : NSObject
@property(nonatomic, copy, nullable) NSString *query;
@property(nonatomic, strong, nullable) NSNumber *anInt;
@property(nonatomic, strong, nullable) NSNumber *aBool;
@end

@interface ACNested : NSObject
@property(nonatomic, strong, nullable) ACSearchRequest *request;
@end

@interface ACFlutterSearchApi : NSObject
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger;
- (void)search:(ACSearchRequest *)input completion:(void (^)(ACSearchReply *, NSError *))completion;
@end
@protocol ACNestedApi
- (nullable ACSearchReply *)search:(ACNested *)input error:(FlutterError *_Nullable *_Nonnull)error;
@end

extern void ACNestedApiSetup(id<FlutterBinaryMessenger> binaryMessenger,
                             id<ACNestedApi> _Nullable api);

@protocol ACApi
- (nullable ACSearchReply *)search:(ACSearchRequest *)input
                             error:(FlutterError *_Nullable *_Nonnull)error;
@end

extern void ACApiSetup(id<FlutterBinaryMessenger> binaryMessenger, id<ACApi> _Nullable api);

NS_ASSUME_NONNULL_END
