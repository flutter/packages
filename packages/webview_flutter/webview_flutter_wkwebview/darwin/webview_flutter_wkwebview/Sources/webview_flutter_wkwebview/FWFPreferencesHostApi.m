// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/webview_flutter_wkwebview/FWFPreferencesHostApi.h"
#import "./include/webview_flutter_wkwebview/FWFWebViewConfigurationHostApi.h"

@interface FWFPreferencesHostApiImpl ()
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) FWFInstanceManager *instanceManager;
@end

@implementation FWFPreferencesHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (WKPreferences *)preferencesForIdentifier:(NSInteger)identifier {
  return (WKPreferences *)[self.instanceManager instanceForIdentifier:identifier];
}

- (void)createWithIdentifier:(NSInteger)identifier error:(FlutterError *_Nullable *_Nonnull)error {
  WKPreferences *preferences = [[WKPreferences alloc] init];
  [self.instanceManager addDartCreatedInstance:preferences withIdentifier:identifier];
}

- (void)createFromWebViewConfigurationWithIdentifier:(NSInteger)identifier
                             configurationIdentifier:(NSInteger)configurationIdentifier
                                               error:(FlutterError *_Nullable *_Nonnull)error {
  WKWebViewConfiguration *configuration = (WKWebViewConfiguration *)[self.instanceManager
      instanceForIdentifier:configurationIdentifier];
  [self.instanceManager addDartCreatedInstance:configuration.preferences withIdentifier:identifier];
}

- (void)setJavaScriptEnabledForPreferencesWithIdentifier:(NSInteger)identifier
                                               isEnabled:(BOOL)enabled
                                                   error:(FlutterError *_Nullable *_Nonnull)error {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  // TODO(stuartmorgan): Replace with new API. See https://github.com/flutter/flutter/issues/125901
  [[self preferencesForIdentifier:identifier] setJavaScriptEnabled:enabled];
#pragma clang diagnostic pop
}
@end
