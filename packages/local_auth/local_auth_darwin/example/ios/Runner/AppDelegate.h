// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>

// FlutterImplicitEngineDelegate is required for UIScene lifecycle.
// It provides a callback (didInitializeImplicitFlutterEngine:) that fires
// after the Flutter engine is ready, which is when plugins should be registered.
@interface AppDelegate : FlutterAppDelegate <FlutterImplicitEngineDelegate>

@end
