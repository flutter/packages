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
  HostIntegrationCoreApiSetup([registrar messenger], plugin);
  plugin.flutterAPI =
      [[FlutterIntegrationCoreApi alloc] initWithBinaryMessenger:[registrar messenger]];
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

- (void)throwErrorWithError:(FlutterError *_Nullable *_Nonnull)error {
  *error = [FlutterError errorWithCode:@"An error" message:nil details:nil];
}

- (nullable NSNumber *)echoInt:(NSNumber *)anInt error:(FlutterError *_Nullable *_Nonnull)error {
  return anInt;
}

- (nullable NSNumber *)echoDouble:(NSNumber *)aDouble
                            error:(FlutterError *_Nullable *_Nonnull)error {
  return aDouble;
}

- (nullable NSNumber *)echoBool:(NSNumber *)aBool error:(FlutterError *_Nullable *_Nonnull)error {
  return aBool;
}

- (nullable NSString *)echoString:(NSString *)aString
                            error:(FlutterError *_Nullable *_Nonnull)error {
  return aString;
}

- (nullable FlutterStandardTypedData *)echoUint8List:(FlutterStandardTypedData *)aUint8List
                                               error:(FlutterError *_Nullable *_Nonnull)error {
  return aUint8List;
}

- (nullable NSString *)extractNestedNullableStringFrom:(AllNullableTypesWrapper *)wrapper
                                                 error:(FlutterError *_Nullable *_Nonnull)error {
  return wrapper.values.aNullableString;
}

- (nullable AllNullableTypesWrapper *)
    createNestedObjectWithNullableString:(nullable NSString *)nullableString
                                   error:(FlutterError *_Nullable *_Nonnull)error {
  AllNullableTypes *innerObject = [[AllNullableTypes alloc] init];
  innerObject.aNullableString = nullableString;
  return [AllNullableTypesWrapper makeWithValues:innerObject];
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

- (void)noopAsyncWithCompletion:(void (^)(FlutterError *_Nullable))completion {
  completion(nil);
}

- (void)echoAsyncString:(NSString *)aString
             completion:(void (^)(NSString *_Nullable, FlutterError *_Nullable))completion {
  completion(aString, nil);
}

- (void)callFlutterNoopWithCompletion:(void (^)(FlutterError *_Nullable))completion {
  [self.flutterAPI noopWithCompletion:^(NSError *error) {
    completion(error);
  }];
}

- (void)callFlutterEchoString:(NSString *)aString
                   completion:(void (^)(NSString *_Nullable, FlutterError *_Nullable))completion {
  [self.flutterAPI echoString:aString
                   completion:^(NSString *value, NSError *error) {
                     completion(value, error);
                   }];
}

@end
