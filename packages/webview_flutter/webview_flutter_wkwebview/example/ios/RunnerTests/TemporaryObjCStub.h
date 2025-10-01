// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(stuartmorgan): This file is temporarily iOS workaround for changes in
// FlutterPluginRegistrar. See the TestFlutterPluginRegistrar TODO in
// FWFWebViewFlutterWKWebViewExternalAPITests.swift.
#if TARGET_OS_IOS

@import Foundation;
@import Flutter;

NS_ASSUME_NONNULL_BEGIN

@interface TestFlutterPluginRegistrar : NSObject <FlutterPluginRegistrar>

@property(nonatomic, nullable) NSObject *plugin;
@property(nonatomic, weak, nullable) UIViewController *viewController;

@end
#endif

NS_ASSUME_NONNULL_END
