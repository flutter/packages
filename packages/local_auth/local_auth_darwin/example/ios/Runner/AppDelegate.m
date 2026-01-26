// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate

// With UIScene lifecycle, application:didFinishLaunchingWithOptions: is still called,
// but the Flutter engine may not be ready yet (scenes are created later).
// Plugin registration is now handled in didInitializeImplicitFlutterEngine: below.
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
  // Note: Do NOT access FlutterViewController here - it may cause a crash.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

// This callback fires after the Flutter engine is initialized.
// This is the correct place to register plugins when using UIScene lifecycle.
- (void)didInitializeImplicitFlutterEngine:(NSObject<FlutterImplicitEngineBridge> *)engineBridge {
  [GeneratedPluginRegistrant registerWithRegistry:engineBridge.pluginRegistry];
}

@end
