// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)didInitializeImplicitFlutterEngine:(NSObject<FlutterImplicitEngineBridge> *)engineBridge {
  // Plugin registration eventually starts listening to StoreKit transactions in the background,
  // which would run concurrently with the test cases during unit tests and auto-finish
  // transactions under test. Skip it when running unit tests.
  if (NSClassFromString(@"XCTestCase") != nil) {
    return;
  }
  [GeneratedPluginRegistrant registerWithRegistry:engineBridge.pluginRegistry];
}

@end
