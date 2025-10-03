// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Foundation;

// TODO(stuartmorgan): This file is temporarily iOS workaround for changes in
// FlutterPluginRegistrar. See the TestFlutterPluginRegistrar TODO in
// FWFWebViewFlutterWKWebViewExternalAPITests.swift.
#if TARGET_OS_IOS

#import "TemporaryObjCStub.h"
@import Flutter;

#import "RunnerTests-Swift.h"

// This FlutterPluginRegistrar is a protocol, so to make a stub it has to be implemented.
@implementation TestFlutterPluginRegistrar

- (void)addApplicationDelegate:(nonnull NSObject<FlutterPlugin> *)delegate {
}

- (void)addMethodCallDelegate:(nonnull NSObject<FlutterPlugin> *)delegate
                      channel:(nonnull FlutterMethodChannel *)channel {
}

- (nonnull NSString *)lookupKeyForAsset:(nonnull NSString *)asset {
  return @"";
}

- (nonnull NSString *)lookupKeyForAsset:(nonnull NSString *)asset
                            fromPackage:(nonnull NSString *)package {
  return @"";
}

- (nonnull NSObject<FlutterBinaryMessenger> *)messenger {
  return [[TestBinaryMessenger alloc] init];
}

- (void)publish:(nonnull NSObject *)value {
  self.plugin = value;
}

- (void)registerViewFactory:(nonnull NSObject<FlutterPlatformViewFactory> *)factory
                     withId:(nonnull NSString *)factoryId {
}

- (void)registerViewFactory:(nonnull NSObject<FlutterPlatformViewFactory> *)factory
                              withId:(nonnull NSString *)factoryId
    gestureRecognizersBlockingPolicy:
        (FlutterPlatformViewGestureRecognizersBlockingPolicy)gestureRecognizersBlockingPolicy {
}

- (nonnull NSObject<FlutterTextureRegistry> *)textures {
  return [[TestFlutterTextureRegistry alloc] init];
}

// This would be NSObject<FlutterSceneLifeCycleDelegate>, but
// FlutterSceneLifeCycleDelegate is not available on stable.
- (void)addSceneDelegate:(nonnull NSObject *)delegate {
}

@end

#endif
