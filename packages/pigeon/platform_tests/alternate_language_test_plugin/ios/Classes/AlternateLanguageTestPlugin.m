// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "AlternateLanguageTestPlugin.h"

#import "CoreTests.gen.h"

/**
 * This plugin is currently a no-op since only unit tests have been set up.
 * In the future, this will register Pigeon APIs used in integration tests.
 */
@implementation AlternateLanguageTestPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  AlternateLanguageTestPlugin *plugin = [[AlternateLanguageTestPlugin alloc] init];
  HostIntegrationCoreApiSetup(registrar.messenger, plugin);
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

@end
