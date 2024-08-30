// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "AlternateLanguageTestPlugin.h"

#import "CoreTests.gen.h"

@interface AlternateLanguageTestPlugin ()
@property(nonatomic) FLTFlutterSmallApi *flutterSmallApiOne;
@property(nonatomic) FLTFlutterSmallApi *flutterSmallApiTwo;
@property(nonatomic) FLTFlutterIntegrationCoreApi *flutterAPI;
@end

/// This plugin handles the native side of the integration tests in example/integration_test/.
@implementation AlternateLanguageTestPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  AlternateLanguageTestPlugin *plugin = [[AlternateLanguageTestPlugin alloc] init];
  SetUpFLTHostIntegrationCoreApi([registrar messenger], plugin);
  [AlternateLanguageTestAPIWithSuffix registerWithRegistrar:registrar suffix:@"suffixOne"];
  [AlternateLanguageTestAPIWithSuffix registerWithRegistrar:registrar suffix:@"suffixTwo"];
  plugin.flutterAPI =
      [[FLTFlutterIntegrationCoreApi alloc] initWithBinaryMessenger:[registrar messenger]];
  plugin.flutterSmallApiOne =
      [[FLTFlutterSmallApi alloc] initWithBinaryMessenger:[registrar messenger]
                                     messageChannelSuffix:@"suffixOne"];
  plugin.flutterSmallApiTwo =
      [[FLTFlutterSmallApi alloc] initWithBinaryMessenger:[registrar messenger]
                                     messageChannelSuffix:@"suffixTwo"];
}

#pragma mark HostIntegrationCoreApi implementation

- (void)noopWithError:(FlutterError *_Nullable *_Nonnull)error {
}

- (nullable FLTAllTypes *)echoAllTypes:(FLTAllTypes *)everything
                                 error:(FlutterError *_Nullable *_Nonnull)error {
  return everything;
}

- (nullable FLTAllNullableTypes *)echoAllNullableTypes:(nullable FLTAllNullableTypes *)everything
                                                 error:(FlutterError *_Nullable *_Nonnull)error {
  return everything;
}

- (nullable FLTAllNullableTypesWithoutRecursion *)
    echoAllNullableTypesWithoutRecursion:(nullable FLTAllNullableTypesWithoutRecursion *)everything
                                   error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return everything;
}

- (nullable id)throwErrorWithError:(FlutterError *_Nullable *_Nonnull)error {
  *error = [FlutterError errorWithCode:@"An error" message:nil details:nil];
  return nil;
}

- (void)throwErrorFromVoidWithError:(FlutterError *_Nullable *_Nonnull)error {
  *error = [FlutterError errorWithCode:@"An error" message:nil details:nil];
}

- (nullable id)throwFlutterErrorWithError:(FlutterError *_Nullable *_Nonnull)error {
  *error = [FlutterError errorWithCode:@"code" message:@"message" details:@"details"];
  return nil;
}

- (nullable NSNumber *)echoInt:(NSInteger)anInt error:(FlutterError *_Nullable *_Nonnull)error {
  return @(anInt);
}

- (nullable NSNumber *)echoDouble:(double)aDouble error:(FlutterError *_Nullable *_Nonnull)error {
  return @(aDouble);
}

- (nullable NSNumber *)echoBool:(BOOL)aBool error:(FlutterError *_Nullable *_Nonnull)error {
  return @(aBool);
}

- (nullable NSString *)echoString:(NSString *)aString
                            error:(FlutterError *_Nullable *_Nonnull)error {
  return aString;
}

- (nullable FlutterStandardTypedData *)echoUint8List:(FlutterStandardTypedData *)aUint8List
                                               error:(FlutterError *_Nullable *_Nonnull)error {
  return aUint8List;
}

- (nullable id)echoObject:(id)anObject error:(FlutterError *_Nullable *_Nonnull)error {
  return anObject;
}

- (nullable NSArray<id> *)echoList:(NSArray<id> *)list
                             error:(FlutterError *_Nullable *_Nonnull)error {
  return list;
}

- (nullable NSDictionary<id, id> *)echoMap:(NSDictionary<id, id> *)map
                                     error:(FlutterError *_Nullable *_Nonnull)error {
  return map;
}

- (nullable NSDictionary<NSString *, NSString *> *)
    echoStringMap:(NSDictionary<NSString *, NSString *> *)stringMap
            error:(FlutterError *_Nullable *_Nonnull)error {
  return stringMap;
}

- (nullable NSDictionary<NSNumber *, NSNumber *> *)
    echoIntMap:(NSDictionary<NSNumber *, NSNumber *> *)intMap
         error:(FlutterError *_Nullable *_Nonnull)error {
  return intMap;
}

- (nullable FLTAllClassesWrapper *)echoClassWrapper:(FLTAllClassesWrapper *)wrapper
                                              error:(FlutterError *_Nullable *_Nonnull)error {
  return wrapper;
}

- (FLTAnEnumBox *_Nullable)echoEnum:(FLTAnEnum)anEnum
                              error:(FlutterError *_Nullable *_Nonnull)error {
  return [[FLTAnEnumBox alloc] initWithValue:anEnum];
}

- (FLTAnotherEnumBox *_Nullable)echoAnotherEnum:(FLTAnotherEnum)anotherEnum
                                          error:(FlutterError *_Nullable *_Nonnull)error {
  return [[FLTAnotherEnumBox alloc] initWithValue:anotherEnum];
}

- (nullable NSString *)echoNamedDefaultString:(NSString *)aString
                                        error:(FlutterError *_Nullable *_Nonnull)error {
  return aString;
}

- (nullable NSNumber *)echoOptionalDefaultDouble:(double)aDouble
                                           error:(FlutterError *_Nullable *_Nonnull)error {
  return @(aDouble);
}

- (nullable NSNumber *)echoRequiredInt:(NSInteger)anInt
                                 error:(FlutterError *_Nullable *_Nonnull)error {
  return @(anInt);
}

- (nullable NSString *)extractNestedNullableStringFrom:(FLTAllClassesWrapper *)wrapper
                                                 error:(FlutterError *_Nullable *_Nonnull)error {
  return wrapper.allNullableTypes.aNullableString;
}

- (nullable FLTAllClassesWrapper *)
    createNestedObjectWithNullableString:(nullable NSString *)nullableString
                                   error:(FlutterError *_Nullable *_Nonnull)error {
  FLTAllNullableTypes *innerObject = [[FLTAllNullableTypes alloc] init];
  innerObject.aNullableString = nullableString;
  return [FLTAllClassesWrapper makeWithAllNullableTypes:innerObject
                       allNullableTypesWithoutRecursion:nil
                                               allTypes:nil];
}

- (nullable FLTAllNullableTypes *)
    sendMultipleNullableTypesABool:(nullable NSNumber *)aNullableBool
                             anInt:(nullable NSNumber *)aNullableInt
                           aString:(nullable NSString *)aNullableString
                             error:(FlutterError *_Nullable *_Nonnull)error {
  FLTAllNullableTypes *someTypes = [[FLTAllNullableTypes alloc] init];
  someTypes.aNullableBool = aNullableBool;
  someTypes.aNullableInt = aNullableInt;
  someTypes.aNullableString = aNullableString;
  return someTypes;
}

- (nullable FLTAllNullableTypesWithoutRecursion *)
    sendMultipleNullableTypesWithoutRecursionABool:(nullable NSNumber *)aNullableBool
                                             anInt:(nullable NSNumber *)aNullableInt
                                           aString:(nullable NSString *)aNullableString
                                             error:
                                                 (FlutterError *_Nullable __autoreleasing *_Nonnull)
                                                     error {
  FLTAllNullableTypesWithoutRecursion *someTypes =
      [[FLTAllNullableTypesWithoutRecursion alloc] init];
  someTypes.aNullableBool = aNullableBool;
  someTypes.aNullableInt = aNullableInt;
  someTypes.aNullableString = aNullableString;
  return someTypes;
}

- (nullable NSNumber *)echoNullableInt:(nullable NSNumber *)aNullableInt
                                 error:(FlutterError *_Nullable *_Nonnull)error {
  return aNullableInt;
}

- (nullable NSNumber *)echoNullableDouble:(nullable NSNumber *)aNullableDouble
                                    error:(FlutterError *_Nullable *_Nonnull)error {
  return aNullableDouble;
}

- (nullable NSNumber *)echoNullableBool:(nullable NSNumber *)aNullableBool
                                  error:(FlutterError *_Nullable *_Nonnull)error {
  return aNullableBool;
}

- (nullable NSString *)echoNullableString:(nullable NSString *)aNullableString
                                    error:(FlutterError *_Nullable *_Nonnull)error {
  return aNullableString;
}

- (nullable FlutterStandardTypedData *)
    echoNullableUint8List:(nullable FlutterStandardTypedData *)aNullableUint8List
                    error:(FlutterError *_Nullable *_Nonnull)error {
  return aNullableUint8List;
}

- (nullable id)echoNullableObject:(nullable id)aNullableObject
                            error:(FlutterError *_Nullable *_Nonnull)error {
  return aNullableObject;
}

- (nullable NSArray<id> *)echoNullableList:(nullable NSArray<id> *)aNullableList
                                     error:(FlutterError *_Nullable *_Nonnull)error {
  return aNullableList;
}

- (nullable NSDictionary<id, id> *)echoNullableMap:(nullable NSDictionary<id, id> *)map
                                             error:(FlutterError *_Nullable *_Nonnull)error {
  return map;
}

- (nullable NSDictionary<NSString *, NSString *> *)
    echoNullableStringMap:(nullable NSDictionary<NSString *, NSString *> *)stringMap
                    error:(FlutterError *_Nullable *_Nonnull)error {
  return stringMap;
}

- (nullable NSDictionary<NSNumber *, NSNumber *> *)
    echoNullableIntMap:(nullable NSDictionary<NSNumber *, NSNumber *> *)intMap
                 error:(FlutterError *_Nullable *_Nonnull)error {
  return intMap;
}

- (FLTAnEnumBox *_Nullable)echoNullableEnum:(nullable FLTAnEnumBox *)AnEnumBoxed
                                      error:(FlutterError *_Nullable *_Nonnull)error {
  return AnEnumBoxed;
}

- (FLTAnotherEnumBox *_Nullable)echoAnotherNullableEnum:
                                    (nullable FLTAnotherEnumBox *)AnotherEnumBoxed
                                                  error:(FlutterError *_Nullable *_Nonnull)error {
  return AnotherEnumBoxed;
}

- (nullable NSNumber *)echoOptionalNullableInt:(nullable NSNumber *)aNullableInt
                                         error:(FlutterError *_Nullable *_Nonnull)error {
  return aNullableInt;
}

- (nullable NSString *)echoNamedNullableString:(nullable NSString *)aNullableString
                                         error:(FlutterError *_Nullable *_Nonnull)error {
  return aNullableString;
}

- (void)noopAsyncWithCompletion:(void (^)(FlutterError *_Nullable))completion {
  completion(nil);
}

- (void)throwAsyncErrorWithCompletion:(void (^)(id _Nullable, FlutterError *_Nullable))completion {
  completion(nil, [FlutterError errorWithCode:@"An error" message:nil details:nil]);
}

- (void)throwAsyncErrorFromVoidWithCompletion:(void (^)(FlutterError *_Nullable))completion {
  completion([FlutterError errorWithCode:@"An error" message:nil details:nil]);
}

- (void)throwAsyncFlutterErrorWithCompletion:(void (^)(id _Nullable,
                                                       FlutterError *_Nullable))completion {
  completion(nil, [FlutterError errorWithCode:@"code" message:@"message" details:@"details"]);
}

- (void)echoAsyncAllTypes:(FLTAllTypes *)everything
               completion:(void (^)(FLTAllTypes *_Nullable, FlutterError *_Nullable))completion {
  completion(everything, nil);
}

- (void)echoAsyncNullableAllNullableTypes:(nullable FLTAllNullableTypes *)everything
                               completion:(void (^)(FLTAllNullableTypes *_Nullable,
                                                    FlutterError *_Nullable))completion {
  completion(everything, nil);
}

- (void)
    echoAsyncNullableAllNullableTypesWithoutRecursion:
        (nullable FLTAllNullableTypesWithoutRecursion *)everything
                                           completion:
                                               (nonnull void (^)(
                                                   FLTAllNullableTypesWithoutRecursion *_Nullable,
                                                   FlutterError *_Nullable))completion {
  completion(everything, nil);
}

- (void)echoAsyncInt:(NSInteger)anInt
          completion:(void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion {
  completion(@(anInt), nil);
}

- (void)echoAsyncDouble:(double)aDouble
             completion:(void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion {
  completion(@(aDouble), nil);
}

- (void)echoAsyncBool:(BOOL)aBool
           completion:(void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion {
  completion(@(aBool), nil);
}

- (void)echoAsyncString:(NSString *)aString
             completion:(void (^)(NSString *_Nullable, FlutterError *_Nullable))completion {
  completion(aString, nil);
}

- (void)echoAsyncUint8List:(FlutterStandardTypedData *)aUint8List
                completion:(void (^)(FlutterStandardTypedData *_Nullable,
                                     FlutterError *_Nullable))completion {
  completion(aUint8List, nil);
}

- (void)echoAsyncObject:(id)anObject
             completion:(void (^)(id _Nullable, FlutterError *_Nullable))completion {
  completion(anObject, nil);
}

- (void)echoAsyncList:(NSArray<id> *)list
           completion:(void (^)(NSArray<id> *_Nullable, FlutterError *_Nullable))completion {
  completion(list, nil);
}

- (void)echoAsyncMap:(NSDictionary<id, id> *)map
          completion:
              (void (^)(NSDictionary<id, id> *_Nullable, FlutterError *_Nullable))completion {
  completion(map, nil);
}

- (void)echoAsyncStringMap:(NSDictionary<NSString *, NSString *> *)stringMap
                completion:(void (^)(NSDictionary<NSString *, NSString *> *_Nullable,
                                     FlutterError *_Nullable))completion {
  completion(stringMap, nil);
}

- (void)echoAsyncIntMap:(NSDictionary<NSNumber *, NSNumber *> *)intMap
             completion:(void (^)(NSDictionary<NSNumber *, NSNumber *> *_Nullable,
                                  FlutterError *_Nullable))completion {
  completion(intMap, nil);
}

- (void)echoAsyncEnum:(FLTAnEnum)anEnum
           completion:(void (^)(FLTAnEnumBox *_Nullable, FlutterError *_Nullable))completion {
  completion([[FLTAnEnumBox alloc] initWithValue:anEnum], nil);
}

- (void)echoAnotherAsyncEnum:(FLTAnotherEnum)anotherEnum
                  completion:
                      (void (^)(FLTAnotherEnumBox *_Nullable, FlutterError *_Nullable))completion {
  completion([[FLTAnotherEnumBox alloc] initWithValue:anotherEnum], nil);
}

- (void)echoAsyncNullableInt:(nullable NSNumber *)anInt
                  completion:(void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion {
  completion(anInt, nil);
}

- (void)echoAsyncNullableDouble:(nullable NSNumber *)aDouble
                     completion:(void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion {
  completion(aDouble, nil);
}

- (void)echoAsyncNullableBool:(nullable NSNumber *)aBool
                   completion:(void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion {
  completion(aBool, nil);
}

- (void)echoAsyncNullableString:(nullable NSString *)aString
                     completion:(void (^)(NSString *_Nullable, FlutterError *_Nullable))completion {
  completion(aString, nil);
}

- (void)echoAsyncNullableUint8List:(nullable FlutterStandardTypedData *)aUint8List
                        completion:(void (^)(FlutterStandardTypedData *_Nullable,
                                             FlutterError *_Nullable))completion {
  completion(aUint8List, nil);
}

- (void)echoAsyncNullableObject:(nullable id)anObject
                     completion:(void (^)(id _Nullable, FlutterError *_Nullable))completion {
  completion(anObject, nil);
}

- (void)echoAsyncNullableList:(nullable NSArray<id> *)list
                   completion:
                       (void (^)(NSArray<id> *_Nullable, FlutterError *_Nullable))completion {
  completion(list, nil);
}

- (void)echoAsyncNullableMap:(nullable NSDictionary<id, id> *)map
                  completion:(void (^)(NSDictionary<id, id> *_Nullable,
                                       FlutterError *_Nullable))completion {
  completion(map, nil);
}

- (void)echoAsyncNullableStringMap:(nullable NSDictionary<NSString *, NSString *> *)stringMap
                        completion:(void (^)(NSDictionary<NSString *, NSString *> *_Nullable,
                                             FlutterError *_Nullable))completion {
  completion(stringMap, nil);
}

- (void)echoAsyncNullableIntMap:(nullable NSDictionary<NSNumber *, NSNumber *> *)intMap
                     completion:(void (^)(NSDictionary<NSNumber *, NSNumber *> *_Nullable,
                                          FlutterError *_Nullable))completion {
  completion(intMap, nil);
}

- (void)echoAsyncNullableEnum:(nullable FLTAnEnumBox *)AnEnumBoxed
                   completion:
                       (void (^)(FLTAnEnumBox *_Nullable, FlutterError *_Nullable))completion {
  completion(AnEnumBoxed, nil);
}

- (void)echoAnotherAsyncNullableEnum:(nullable FLTAnotherEnumBox *)AnotherEnumBoxed
                          completion:(void (^)(FLTAnotherEnumBox *_Nullable,
                                               FlutterError *_Nullable))completion {
  completion(AnotherEnumBoxed, nil);
}

- (void)callFlutterNoopWithCompletion:(void (^)(FlutterError *_Nullable))completion {
  [self.flutterAPI noopWithCompletion:^(FlutterError *error) {
    completion(error);
  }];
}

- (void)callFlutterThrowErrorWithCompletion:(void (^)(id _Nullable,
                                                      FlutterError *_Nullable))completion {
  [self.flutterAPI throwErrorWithCompletion:^(id value, FlutterError *error) {
    completion(value, error);
  }];
}

- (void)callFlutterThrowErrorFromVoidWithCompletion:(void (^)(FlutterError *_Nullable))completion {
  [self.flutterAPI throwErrorFromVoidWithCompletion:^(FlutterError *error) {
    completion(error);
  }];
}

- (void)callFlutterEchoAllTypes:(FLTAllTypes *)everything
                     completion:
                         (void (^)(FLTAllTypes *_Nullable, FlutterError *_Nullable))completion {
  [self.flutterAPI echoAllTypes:everything
                     completion:^(FLTAllTypes *value, FlutterError *error) {
                       completion(value, error);
                     }];
}

- (void)callFlutterSendMultipleNullableTypesABool:(nullable NSNumber *)aNullableBool
                                            anInt:(nullable NSNumber *)aNullableInt
                                          aString:(nullable NSString *)aNullableString
                                       completion:(void (^)(FLTAllNullableTypes *_Nullable,
                                                            FlutterError *_Nullable))completion {
  [self.flutterAPI
      sendMultipleNullableTypesABool:aNullableBool
                               anInt:aNullableInt
                             aString:aNullableString
                          completion:^(FLTAllNullableTypes *value, FlutterError *error) {
                            completion(value, error);
                          }];
}

- (void)callFlutterSendMultipleNullableTypesWithoutRecursionABool:(nullable NSNumber *)aNullableBool
                                                            anInt:(nullable NSNumber *)aNullableInt
                                                          aString:
                                                              (nullable NSString *)aNullableString
                                                       completion:
                                                           (nonnull void (^)(
                                                               FLTAllNullableTypesWithoutRecursion
                                                                   *_Nullable,
                                                               FlutterError *_Nullable))completion {
  [self.flutterAPI
      sendMultipleNullableTypesWithoutRecursionABool:aNullableBool
                                               anInt:aNullableInt
                                             aString:aNullableString
                                          completion:^(FLTAllNullableTypesWithoutRecursion *value,
                                                       FlutterError *error) {
                                            completion(value, error);
                                          }];
}

- (void)callFlutterEchoBool:(BOOL)aBool
                 completion:(void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion {
  [self.flutterAPI echoBool:aBool
                 completion:^(NSNumber *value, FlutterError *error) {
                   completion(value, error);
                 }];
}

- (void)callFlutterEchoInt:(NSInteger)anInt
                completion:(void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion {
  [self.flutterAPI echoInt:anInt
                completion:^(NSNumber *value, FlutterError *error) {
                  completion(value, error);
                }];
}

- (void)callFlutterEchoDouble:(double)aDouble
                   completion:(void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion {
  [self.flutterAPI echoDouble:aDouble
                   completion:^(NSNumber *value, FlutterError *error) {
                     completion(value, error);
                   }];
}

- (void)callFlutterEchoString:(NSString *)aString
                   completion:(void (^)(NSString *_Nullable, FlutterError *_Nullable))completion {
  [self.flutterAPI echoString:aString
                   completion:^(NSString *value, FlutterError *error) {
                     completion(value, error);
                   }];
}

- (void)callFlutterEchoUint8List:(FlutterStandardTypedData *)list
                      completion:(void (^)(FlutterStandardTypedData *_Nullable,
                                           FlutterError *_Nullable))completion {
  [self.flutterAPI echoUint8List:list
                      completion:^(FlutterStandardTypedData *value, FlutterError *error) {
                        completion(value, error);
                      }];
}

- (void)callFlutterEchoList:(NSArray<id> *)list
                 completion:(void (^)(NSArray<id> *_Nullable, FlutterError *_Nullable))completion {
  [self.flutterAPI echoList:list
                 completion:^(NSArray<id> *value, FlutterError *error) {
                   completion(value, error);
                 }];
}

- (void)callFlutterEchoMap:(NSDictionary<id, id> *)map
                completion:
                    (void (^)(NSDictionary<id, id> *_Nullable, FlutterError *_Nullable))completion {
  [self.flutterAPI echoMap:map
                completion:^(NSDictionary<id, id> *value, FlutterError *error) {
                  completion(value, error);
                }];
}

- (void)callFlutterEchoStringMap:(NSDictionary<NSString *, NSString *> *)stringMap
                      completion:(void (^)(NSDictionary<NSString *, NSString *> *_Nullable,
                                           FlutterError *_Nullable))completion {
  [self.flutterAPI
      echoStringMap:stringMap
         completion:^(NSDictionary<NSString *, NSString *> *value, FlutterError *error) {
           completion(value, error);
         }];
}

- (void)callFlutterEchoIntMap:(NSDictionary<NSNumber *, NSNumber *> *)intMap
                   completion:(void (^)(NSDictionary<NSNumber *, NSNumber *> *_Nullable,
                                        FlutterError *_Nullable))completion {
  [self.flutterAPI echoIntMap:intMap
                   completion:^(NSDictionary<NSNumber *, NSNumber *> *value, FlutterError *error) {
                     completion(value, error);
                   }];
}

- (void)callFlutterEchoEnum:(FLTAnEnum)anEnum
                 completion:(void (^)(FLTAnEnumBox *_Nullable, FlutterError *_Nullable))completion {
  [self.flutterAPI echoEnum:anEnum
                 completion:^(FLTAnEnumBox *value, FlutterError *error) {
                   completion(value, error);
                 }];
}

- (void)callFlutterEchoAnotherEnum:(FLTAnotherEnum)anotherEnum
                        completion:(void (^)(FLTAnotherEnumBox *_Nullable,
                                             FlutterError *_Nullable))completion {
  [self.flutterAPI echoAnotherEnum:anotherEnum
                        completion:^(FLTAnotherEnumBox *value, FlutterError *error) {
                          completion(value, error);
                        }];
}

- (void)callFlutterEchoAllNullableTypes:(nullable FLTAllNullableTypes *)everything
                             completion:(void (^)(FLTAllNullableTypes *_Nullable,
                                                  FlutterError *_Nullable))completion {
  [self.flutterAPI echoAllNullableTypes:everything
                             completion:^(FLTAllNullableTypes *value, FlutterError *error) {
                               completion(value, error);
                             }];
}

- (void)callFlutterEchoAllNullableTypesWithoutRecursion:
            (nullable FLTAllNullableTypesWithoutRecursion *)everything
                                             completion:
                                                 (nonnull void (^)(
                                                     FLTAllNullableTypesWithoutRecursion *_Nullable,
                                                     FlutterError *_Nullable))completion {
  [self.flutterAPI
      echoAllNullableTypesWithoutRecursion:everything
                                completion:^(FLTAllNullableTypesWithoutRecursion *value,
                                             FlutterError *error) {
                                  completion(value, error);
                                }];
}

- (void)callFlutterEchoNullableBool:(nullable NSNumber *)aBool
                         completion:
                             (void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion {
  [self.flutterAPI echoNullableBool:aBool
                         completion:^(NSNumber *value, FlutterError *error) {
                           completion(value, error);
                         }];
}

- (void)callFlutterEchoNullableInt:(nullable NSNumber *)anInt
                        completion:
                            (void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion {
  [self.flutterAPI echoNullableInt:anInt
                        completion:^(NSNumber *value, FlutterError *error) {
                          completion(value, error);
                        }];
}

- (void)callFlutterEchoNullableDouble:(nullable NSNumber *)aDouble
                           completion:
                               (void (^)(NSNumber *_Nullable, FlutterError *_Nullable))completion {
  [self.flutterAPI echoNullableDouble:aDouble
                           completion:^(NSNumber *value, FlutterError *error) {
                             completion(value, error);
                           }];
}

- (void)callFlutterEchoNullableString:(nullable NSString *)aString
                           completion:
                               (void (^)(NSString *_Nullable, FlutterError *_Nullable))completion {
  [self.flutterAPI echoNullableString:aString
                           completion:^(NSString *value, FlutterError *error) {
                             completion(value, error);
                           }];
}

- (void)callFlutterEchoNullableUint8List:(nullable FlutterStandardTypedData *)list
                              completion:(void (^)(FlutterStandardTypedData *_Nullable,
                                                   FlutterError *_Nullable))completion {
  [self.flutterAPI echoNullableUint8List:list
                              completion:^(FlutterStandardTypedData *value, FlutterError *error) {
                                completion(value, error);
                              }];
}

- (void)callFlutterEchoNullableList:(nullable NSArray<id> *)list
                         completion:
                             (void (^)(NSArray<id> *_Nullable, FlutterError *_Nullable))completion {
  [self.flutterAPI echoNullableList:list
                         completion:^(NSArray<id> *value, FlutterError *error) {
                           completion(value, error);
                         }];
}

- (void)callFlutterEchoNullableMap:(nullable NSDictionary<id, id> *)map
                        completion:(void (^)(NSDictionary<id, id> *_Nullable,
                                             FlutterError *_Nullable))completion {
  [self.flutterAPI echoNullableMap:map
                        completion:^(NSDictionary<id, id> *value, FlutterError *error) {
                          completion(value, error);
                        }];
}

- (void)callFlutterEchoNullableStringMap:(nullable NSDictionary<NSString *, NSString *> *)stringMap
                              completion:(void (^)(NSDictionary<NSString *, NSString *> *_Nullable,
                                                   FlutterError *_Nullable))completion {
  [self.flutterAPI
      echoNullableStringMap:stringMap
                 completion:^(NSDictionary<NSString *, NSString *> *value, FlutterError *error) {
                   completion(value, error);
                 }];
}

- (void)callFlutterEchoNullableIntMap:(nullable NSDictionary<NSNumber *, NSNumber *> *)intMap
                           completion:(void (^)(NSDictionary<NSNumber *, NSNumber *> *_Nullable,
                                                FlutterError *_Nullable))completion {
  [self.flutterAPI
      echoNullableIntMap:intMap
              completion:^(NSDictionary<NSNumber *, NSNumber *> *value, FlutterError *error) {
                completion(value, error);
              }];
}

- (void)callFlutterEchoNullableEnum:(nullable FLTAnEnumBox *)AnEnumBoxed
                         completion:(void (^)(FLTAnEnumBox *_Nullable,
                                              FlutterError *_Nullable))completion {
  [self.flutterAPI echoNullableEnum:AnEnumBoxed
                         completion:^(FLTAnEnumBox *value, FlutterError *error) {
                           completion(value, error);
                         }];
}

- (void)callFlutterEchoAnotherNullableEnum:(nullable FLTAnotherEnumBox *)AnotherEnumBoxed
                                completion:(void (^)(FLTAnotherEnumBox *_Nullable,
                                                     FlutterError *_Nullable))completion {
  [self.flutterAPI echoAnotherNullableEnum:AnotherEnumBoxed
                                completion:^(FLTAnotherEnumBox *value, FlutterError *error) {
                                  completion(value, error);
                                }];
}

- (void)callFlutterSmallApiEchoString:(nonnull NSString *)aString
                           completion:(nonnull void (^)(NSString *_Nullable,
                                                        FlutterError *_Nullable))completion {
  [self.flutterSmallApiOne
      echoString:aString
      completion:^(NSString *valueOne, FlutterError *error) {
        [self.flutterSmallApiTwo
            echoString:aString
            completion:^(NSString *valueTwo, FlutterError *error) {
              if ([valueOne isEqualToString:valueTwo]) {
                completion(valueTwo, error);
              } else {
                completion(
                    nil,
                    [FlutterError
                        errorWithCode:@"Responses do not match"
                              message:[NSString stringWithFormat:
                                                    @"%@%@%@%@",
                                                    @"Multi-instance responses were not matching: ",
                                                    valueOne, @", ", valueTwo]
                              details:nil]);
              }
            }];
      }];
}

- (FLTUnusedClass *)checkIfUnusedClassGenerated {
  return [[FLTUnusedClass alloc] init];
}

@end

@interface AlternateLanguageTestAPIWithSuffix ()
@end

@implementation AlternateLanguageTestAPIWithSuffix
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar
                       suffix:(NSString *)suffix {
  AlternateLanguageTestAPIWithSuffix *api = [[AlternateLanguageTestAPIWithSuffix alloc] init];
  SetUpFLTHostSmallApiWithSuffix([registrar messenger], api, suffix);
}

#pragma mark HostSmallAPI implementation

- (void)echoString:(nonnull NSString *)aString
        completion:(nonnull void (^)(NSString *_Nullable, FlutterError *_Nullable))completion {
  completion(aString, nil);
}

- (void)voidVoidWithCompletion:(nonnull void (^)(FlutterError *_Nullable))completion {
  completion(nil);
}

@end
