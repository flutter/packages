// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "AlternateLanguageTestPlugin.h"

#import "CoreTests.gen.h"

@interface AlternateLanguageTestPlugin ()
@property(nonatomic) FlutterIntegrationCoreApi *flutterAPI;
@end

/**
 * This plugin handles the native side of the integration tests in example/integration_test/.
 */
@implementation AlternateLanguageTestPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  AlternateLanguageTestPlugin *plugin = [[AlternateLanguageTestPlugin alloc] init];
  SetUpHostIntegrationCoreApi(registrar.messenger, plugin);
  plugin.flutterAPI =
      [[FlutterIntegrationCoreApi alloc] initWithBinaryMessenger:registrar.messenger];
}

#pragma mark HostIntegrationCoreApi implementation

- (void)noopWithError:(FlutterError *_Nullable *_Nonnull)error {
}

- (nullable AllTypes *)echoAllTypes:(AllTypes *)everything
                              error:(FlutterError *_Nullable *_Nonnull)error {
  return everything;
}

- (nullable AllNullableTypes *)echoAllNullableTypes:(nullable AllNullableTypes *)everything
                                              error:(FlutterError *_Nullable *_Nonnull)error {
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

- (nullable NSArray<id> *)echoList:(NSArray<id> *)aList
                             error:(FlutterError *_Nullable *_Nonnull)error {
  return aList;
}

- (nullable NSDictionary<NSString *, id> *)echoMap:(NSDictionary<NSString *, id> *)aMap
                                             error:(FlutterError *_Nullable *_Nonnull)error {
  return aMap;
}

- (nullable AllClassesWrapper *)echoClassWrapper:(AllClassesWrapper *)wrapper
                                           error:(FlutterError *_Nullable *_Nonnull)error {
  return wrapper;
}

- (AnEnumBox *_Nullable)echoEnum:(AnEnum)anEnum error:(FlutterError *_Nullable *_Nonnull)error {
  return [[AnEnumBox alloc] initWithValue:anEnum];
}

- (nullable NSString *)extractNestedNullableStringFrom:(AllClassesWrapper *)wrapper
                                                 error:(FlutterError *_Nullable *_Nonnull)error {
  return wrapper.allNullableTypes.aNullableString;
}

- (nullable AllClassesWrapper *)
    createNestedObjectWithNullableString:(nullable NSString *)nullableString
                                   error:(FlutterError *_Nullable *_Nonnull)error {
  AllNullableTypes *innerObject = [[AllNullableTypes alloc] init];
  innerObject.aNullableString = nullableString;
  return [AllClassesWrapper makeWithAllNullableTypes:innerObject allTypes:nil];
}

- (nullable AllNullableTypes *)sendMultipleNullableTypesABool:(nullable NSNumber *)aNullableBool
                                                        anInt:(nullable NSNumber *)aNullableInt
                                                      aString:(nullable NSString *)aNullableString
                                                        error:(FlutterError *_Nullable *_Nonnull)
                                                                  error {
  AllNullableTypes *someTypes = [[AllNullableTypes alloc] init];
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

- (nullable NSDictionary<NSString *, id> *)
    echoNullableMap:(nullable NSDictionary<NSString *, id> *)aNullableMap
              error:(FlutterError *_Nullable *_Nonnull)error {
  return aNullableMap;
}

- (AnEnumBox *_Nullable)echoNullableEnum:(nullable AnEnumBox *)AnEnumBoxed
                                   error:(FlutterError *_Nullable *_Nonnull)error {
  return AnEnumBoxed;
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

- (void)echoAsyncAllTypes:(AllTypes *)everything
               completion:(void (^)(AllTypes *_Nullable, FlutterError *_Nullable))completion {
  completion(everything, nil);
}

- (void)echoAsyncNullableAllNullableTypes:(nullable AllNullableTypes *)everything
                               completion:(void (^)(AllNullableTypes *_Nullable,
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

- (void)echoAsyncList:(NSArray<id> *)aList
           completion:(void (^)(NSArray<id> *_Nullable, FlutterError *_Nullable))completion {
  completion(aList, nil);
}

- (void)echoAsyncMap:(NSDictionary<NSString *, id> *)aMap
          completion:(void (^)(NSDictionary<NSString *, id> *_Nullable,
                               FlutterError *_Nullable))completion {
  completion(aMap, nil);
}

- (void)echoAsyncEnum:(AnEnum)anEnum
           completion:(void (^)(AnEnumBox *_Nullable, FlutterError *_Nullable))completion {
  completion([[AnEnumBox alloc] initWithValue:anEnum], nil);
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

- (void)echoAsyncNullableList:(nullable NSArray<id> *)aList
                   completion:
                       (void (^)(NSArray<id> *_Nullable, FlutterError *_Nullable))completion {
  completion(aList, nil);
}

- (void)echoAsyncNullableMap:(nullable NSDictionary<NSString *, id> *)aMap
                  completion:(void (^)(NSDictionary<NSString *, id> *_Nullable,
                                       FlutterError *_Nullable))completion {
  completion(aMap, nil);
}

- (void)echoAsyncNullableEnum:(nullable AnEnumBox *)AnEnumBoxed
                   completion:(void (^)(AnEnumBox *_Nullable, FlutterError *_Nullable))completion {
  completion(AnEnumBoxed, nil);
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

- (void)callFlutterEchoAllTypes:(AllTypes *)everything
                     completion:(void (^)(AllTypes *_Nullable, FlutterError *_Nullable))completion {
  [self.flutterAPI echoAllTypes:everything
                     completion:^(AllTypes *value, FlutterError *error) {
                       completion(value, error);
                     }];
}

- (void)callFlutterSendMultipleNullableTypesABool:(nullable NSNumber *)aNullableBool
                                            anInt:(nullable NSNumber *)aNullableInt
                                          aString:(nullable NSString *)aNullableString
                                       completion:(void (^)(AllNullableTypes *_Nullable,
                                                            FlutterError *_Nullable))completion {
  [self.flutterAPI sendMultipleNullableTypesABool:aNullableBool
                                            anInt:aNullableInt
                                          aString:aNullableString
                                       completion:^(AllNullableTypes *value, FlutterError *error) {
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

- (void)callFlutterEchoUint8List:(FlutterStandardTypedData *)aList
                      completion:(void (^)(FlutterStandardTypedData *_Nullable,
                                           FlutterError *_Nullable))completion {
  [self.flutterAPI echoUint8List:aList
                      completion:^(FlutterStandardTypedData *value, FlutterError *error) {
                        completion(value, error);
                      }];
}

- (void)callFlutterEchoList:(NSArray<id> *)aList
                 completion:(void (^)(NSArray<id> *_Nullable, FlutterError *_Nullable))completion {
  [self.flutterAPI echoList:aList
                 completion:^(NSArray<id> *value, FlutterError *error) {
                   completion(value, error);
                 }];
}

- (void)callFlutterEchoMap:(NSDictionary<NSString *, id> *)aMap
                completion:(void (^)(NSDictionary<NSString *, id> *_Nullable,
                                     FlutterError *_Nullable))completion {
  [self.flutterAPI echoMap:aMap
                completion:^(NSDictionary<NSString *, id> *value, FlutterError *error) {
                  completion(value, error);
                }];
}

- (void)callFlutterEchoEnum:(AnEnum)anEnum
                 completion:(void (^)(AnEnumBox *_Nullable, FlutterError *_Nullable))completion {
  [self.flutterAPI echoEnum:anEnum
                 completion:^(AnEnumBox *value, FlutterError *error) {
                   completion(value, error);
                 }];
}

- (void)callFlutterEchoAllNullableTypes:(nullable AllNullableTypes *)everything
                             completion:(void (^)(AllNullableTypes *_Nullable,
                                                  FlutterError *_Nullable))completion {
  [self.flutterAPI echoAllNullableTypes:everything
                             completion:^(AllNullableTypes *value, FlutterError *error) {
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

- (void)callFlutterEchoNullableUint8List:(nullable FlutterStandardTypedData *)aList
                              completion:(void (^)(FlutterStandardTypedData *_Nullable,
                                                   FlutterError *_Nullable))completion {
  [self.flutterAPI echoNullableUint8List:aList
                              completion:^(FlutterStandardTypedData *value, FlutterError *error) {
                                completion(value, error);
                              }];
}

- (void)callFlutterEchoNullableList:(nullable NSArray<id> *)aList
                         completion:
                             (void (^)(NSArray<id> *_Nullable, FlutterError *_Nullable))completion {
  [self.flutterAPI echoNullableList:aList
                         completion:^(NSArray<id> *value, FlutterError *error) {
                           completion(value, error);
                         }];
}

- (void)callFlutterEchoNullableMap:(nullable NSDictionary<NSString *, id> *)aMap
                        completion:(void (^)(NSDictionary<NSString *, id> *_Nullable,
                                             FlutterError *_Nullable))completion {
  [self.flutterAPI echoNullableMap:aMap
                        completion:^(NSDictionary<NSString *, id> *value, FlutterError *error) {
                          completion(value, error);
                        }];
}

- (void)callFlutterEchoNullableEnum:(nullable AnEnumBox *)AnEnumBoxed
                         completion:
                             (void (^)(AnEnumBox *_Nullable, FlutterError *_Nullable))completion {
  [self.flutterAPI echoNullableEnum:AnEnumBoxed
                         completion:^(AnEnumBox *value, FlutterError *error) {
                           completion(value, error);
                         }];
}

@end
