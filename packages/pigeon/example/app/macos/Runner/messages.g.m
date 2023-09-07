// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon, do not edit directly.
// See also: https://pub.dev/packages/pigeon

#import "messages.g.h"

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

#if !__has_feature(objc_arc)
#error File requires ARC to be enabled.
#endif

@implementation PGNCodeBox
- (instancetype)initWithValue:(PGNCode)value {
  self = [super init];
  if (self) {
    _value = value;
  }
  return self;
}
@end

static NSArray *wrapResult(id result, FlutterError *error) {
  if (error) {
    return @[
      error.code ?: [NSNull null], error.message ?: [NSNull null], error.details ?: [NSNull null]
    ];
  }
  return @[ result ?: [NSNull null] ];
}
static id GetNullableObjectAtIndex(NSArray *array, NSInteger key) {
  id result = array[key];
  return (result == [NSNull null]) ? nil : result;
}

@interface PGNMessageData ()
+ (PGNMessageData *)fromList:(NSArray *)list;
+ (nullable PGNMessageData *)nullableFromList:(NSArray *)list;
- (NSArray *)toList;
@end

@implementation PGNMessageData
+ (instancetype)makeWithName:(nullable NSString *)name
                 description:(nullable NSString *)description
                        code:(PGNCode)code
                        data:(NSDictionary<NSString *, NSString *> *)data {
  PGNMessageData *pigeonResult = [[PGNMessageData alloc] init];
  pigeonResult.name = name;
  pigeonResult.description = description;
  pigeonResult.code = code;
  pigeonResult.data = data;
  return pigeonResult;
}
+ (PGNMessageData *)fromList:(NSArray *)list {
  PGNMessageData *pigeonResult = [[PGNMessageData alloc] init];
  pigeonResult.name = GetNullableObjectAtIndex(list, 0);
  pigeonResult.description = GetNullableObjectAtIndex(list, 1);
  pigeonResult.code = [GetNullableObjectAtIndex(list, 2) integerValue];
  pigeonResult.data = GetNullableObjectAtIndex(list, 3);
  NSAssert(pigeonResult.data != nil, @"");
  return pigeonResult;
}
+ (nullable PGNMessageData *)nullableFromList:(NSArray *)list {
  return (list) ? [PGNMessageData fromList:list] : nil;
}
- (NSArray *)toList {
  return @[
    (self.name ?: [NSNull null]),
    (self.description ?: [NSNull null]),
    @(self.code),
    (self.data ?: [NSNull null]),
  ];
}
@end

@interface PGNExampleHostApiCodecReader : FlutterStandardReader
@end
@implementation PGNExampleHostApiCodecReader
- (nullable id)readValueOfType:(UInt8)type {
  switch (type) {
    case 128:
      return [PGNMessageData fromList:[self readValue]];
    default:
      return [super readValueOfType:type];
  }
}
@end

@interface PGNExampleHostApiCodecWriter : FlutterStandardWriter
@end
@implementation PGNExampleHostApiCodecWriter
- (void)writeValue:(id)value {
  if ([value isKindOfClass:[PGNMessageData class]]) {
    [self writeByte:128];
    [self writeValue:[value toList]];
  } else {
    [super writeValue:value];
  }
}
@end

@interface PGNExampleHostApiCodecReaderWriter : FlutterStandardReaderWriter
@end
@implementation PGNExampleHostApiCodecReaderWriter
- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data {
  return [[PGNExampleHostApiCodecWriter alloc] initWithData:data];
}
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[PGNExampleHostApiCodecReader alloc] initWithData:data];
}
@end

NSObject<FlutterMessageCodec> *PGNExampleHostApiGetCodec(void) {
  static FlutterStandardMessageCodec *sSharedObject = nil;
  static dispatch_once_t sPred = 0;
  dispatch_once(&sPred, ^{
    PGNExampleHostApiCodecReaderWriter *readerWriter =
        [[PGNExampleHostApiCodecReaderWriter alloc] init];
    sSharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];
  });
  return sSharedObject;
}

void PGNExampleHostApiSetup(id<FlutterBinaryMessenger> binaryMessenger,
                            NSObject<PGNExampleHostApi> *api) {
  {
    FlutterBasicMessageChannel *channel = [[FlutterBasicMessageChannel alloc]
           initWithName:@"dev.flutter.pigeon.pigeon_example_package.ExampleHostApi.getHostLanguage"
        binaryMessenger:binaryMessenger
                  codec:PGNExampleHostApiGetCodec()];
    if (api) {
      NSCAssert(
          [api respondsToSelector:@selector(getHostLanguageWithError:)],
          @"PGNExampleHostApi api (%@) doesn't respond to @selector(getHostLanguageWithError:)",
          api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FlutterError *error;
        NSString *output = [api getHostLanguageWithError:&error];
        callback(wrapResult(output, error));
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel = [[FlutterBasicMessageChannel alloc]
           initWithName:@"dev.flutter.pigeon.pigeon_example_package.ExampleHostApi.add"
        binaryMessenger:binaryMessenger
                  codec:PGNExampleHostApiGetCodec()];
    if (api) {
      NSCAssert(
          [api respondsToSelector:@selector(addNumber:toNumber:error:)],
          @"PGNExampleHostApi api (%@) doesn't respond to @selector(addNumber:toNumber:error:)",
          api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        NSNumber *arg_a = GetNullableObjectAtIndex(args, 0);
        NSNumber *arg_b = GetNullableObjectAtIndex(args, 1);
        FlutterError *error;
        NSNumber *output = [api addNumber:arg_a toNumber:arg_b error:&error];
        callback(wrapResult(output, error));
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel = [[FlutterBasicMessageChannel alloc]
           initWithName:@"dev.flutter.pigeon.pigeon_example_package.ExampleHostApi.sendMessage"
        binaryMessenger:binaryMessenger
                  codec:PGNExampleHostApiGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(sendMessageMessage:completion:)],
                @"PGNExampleHostApi api (%@) doesn't respond to "
                @"@selector(sendMessageMessage:completion:)",
                api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        PGNMessageData *arg_message = GetNullableObjectAtIndex(args, 0);
        [api sendMessageMessage:arg_message
                     completion:^(NSNumber *_Nullable output, FlutterError *_Nullable error) {
                       callback(wrapResult(output, error));
                     }];
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
}
NSObject<FlutterMessageCodec> *PGNMessageFlutterApiGetCodec(void) {
  static FlutterStandardMessageCodec *sSharedObject = nil;
  sSharedObject = [FlutterStandardMessageCodec sharedInstance];
  return sSharedObject;
}

@interface PGNMessageFlutterApi ()
@property(nonatomic, strong) NSObject<FlutterBinaryMessenger> *binaryMessenger;
@end

@implementation PGNMessageFlutterApi

- (instancetype)initWithBinaryMessenger:(NSObject<FlutterBinaryMessenger> *)binaryMessenger {
  self = [super init];
  if (self) {
    _binaryMessenger = binaryMessenger;
  }
  return self;
}
- (void)flutterMethodAString:(nullable NSString *)arg_aString
                  completion:(void (^)(NSString *_Nullable, FlutterError *_Nullable))completion {
  FlutterBasicMessageChannel *channel = [FlutterBasicMessageChannel
      messageChannelWithName:
          @"dev.flutter.pigeon.pigeon_example_package.MessageFlutterApi.flutterMethod"
             binaryMessenger:self.binaryMessenger
                       codec:PGNMessageFlutterApiGetCodec()];
  [channel sendMessage:@[ arg_aString ?: [NSNull null] ]
                 reply:^(id reply) {
                   NSString *output = reply;
                   completion(output, nil);
                 }];
}
@end
