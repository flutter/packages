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

- (void)throwErrorWithError:(FlutterError *_Nullable *_Nonnull)error {
  *error = [FlutterError errorWithCode:@"An error" message:nil details:nil];
}

- (nullable NSString *)extractNestedStringFrom:(AllTypesWrapper *)wrapper
                                         error:(FlutterError *_Nullable *_Nonnull)error {
  return wrapper.values.aString;
}

- (nullable AllTypesWrapper *)createNestedObjectWithString:(NSString *)string
                                                     error:
                                                         (FlutterError *_Nullable *_Nonnull)error {
  AllTypes *innerObject = [[AllTypes alloc] init];
  innerObject.aString = string;
  return [AllTypesWrapper makeWithValues:innerObject];
}

- (nullable AllTypes *)sendMultipleTypesABool:(NSNumber *)aBool
                                        anInt:(NSNumber *)anInt
                                      aString:(NSString *)aString
                                        error:(FlutterError *_Nullable *_Nonnull)error {
  AllTypes *someTypes = [[AllTypes alloc] init];
  someTypes.aBool = aBool;
  someTypes.anInt = anInt;
  someTypes.aString = aString;
  return someTypes;
}

- (nullable NSNumber *)echoInt:(NSNumber *)anInt error:(FlutterError *_Nullable *_Nonnull)error {
  return anInt;
}

- (nullable NSNumber *)echoDouble:(NSNumber *)aDouble
                            error:(FlutterError *_Nullable *_Nonnull)error {
  return aDouble
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
