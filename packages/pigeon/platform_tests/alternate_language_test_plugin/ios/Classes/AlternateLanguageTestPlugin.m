// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "AlternateLanguageTestPlugin.h"

#import "AllDatatypes.gen.h"
#import "AllVoid.gen.h"

/**
 * This plugin is currently a no-op since only unit tests have been set up.
 * In the future, this will register Pigeon APIs used in integration tests.
 */
@implementation AlternateLanguageTestPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  AlternateLanguageTestPlugin *plugin = [[AlternateLanguageTestPlugin alloc] init];
  AllVoidHostApiSetup(registrar.messenger, plugin);
  HostEverythingSetup(registrar.messenger, plugin);
}

#pragma mark AllVoidHostApi implementation

- (void)doitWithError:(FlutterError *_Nullable *_Nonnull)error {
  // No-op.
}

#pragma mark HostEverything implementation

- (nullable Everything *)giveMeEverythingWithError:(FlutterError *_Nullable *_Nonnull)error {
  // Currently unused in integration tests, so just return an empty object.
  return [[Everything alloc] init];
}

- (nullable Everything *)echoEverything:(Everything *)everything
                                  error:(FlutterError *_Nullable *_Nonnull)error {
  return everything;
}

@end
