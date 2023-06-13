// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTWebViewFlutterPlugin.h"
#import "FWFGeneratedWebKitApis.h"
#import "FWFHTTPCookieStoreHostApi.h"
#import "FWFInstanceManager.h"
#import "FWFNavigationDelegateHostApi.h"
#import "FWFObjectHostApi.h"
#import "FWFPreferencesHostApi.h"
#import "FWFScriptMessageHandlerHostApi.h"
#import "FWFScrollViewHostApi.h"
#import "FWFUIDelegateHostApi.h"
#import "FWFUIViewHostApi.h"
#import "FWFURLHostApi.h"
#import "FWFUserContentControllerHostApi.h"
#import "FWFWebViewConfigurationHostApi.h"
#import "FWFWebViewHostApi.h"
#import "FWFWebsiteDataStoreHostApi.h"

@interface FWFWebViewFactory : NSObject <FlutterPlatformViewFactory>
@property(nonatomic, weak) FWFInstanceManager *instanceManager;

- (instancetype)initWithManager:(FWFInstanceManager *)manager;
@end

@implementation FWFWebViewFactory
- (instancetype)initWithManager:(FWFInstanceManager *)manager {
  self = [self init];
  if (self) {
    _instanceManager = manager;
  }
  return self;
}

#pragma mark FlutterPlatformViewFactory

- (NSObject<FlutterMessageCodec> *)createArgsCodec {
  return [FlutterStandardMessageCodec sharedInstance];
}

#if TARGET_OS_IOS

- (NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame
                                    viewIdentifier:(int64_t)viewId
                                         arguments:(id _Nullable)args {
  NSNumber *identifier = (NSNumber *)args;
  FWFWebView *webView =
      (FWFWebView *)[self.instanceManager instanceForIdentifier:identifier.longValue];
  webView.frame = frame;
  return webView;
}

#else

- (nonnull NSView *)createWithViewIdentifier:(int64_t)viewId arguments:(nullable id)args {
  // TODO(stuartmorgan): Remove this awful hack once the engine isn't unconditionally passing
  // nil instead of the actual arguments: https://github.com/flutter/flutter/issues/124723
  // This allows single-instance display to work just to unblock the proof of concept, but is
  // absolutely not shippable.
  if (!args) {
    for (int i = 0; i < 100; i++) {
      NSObject *instance = [self.instanceManager instanceForIdentifier:i];
      if ([instance isKindOfClass:[FWFWebView class]]) {
        NSLog(@"WARNING: Returning the first FWFWebView we could find");
        return (FWFWebView *)instance;
      }
    }
  }
  NSNumber *identifier = (NSNumber *)args;
  FWFWebView *webView =
      (FWFWebView *)[self.instanceManager instanceForIdentifier:identifier.longValue];
  return webView;
}

#endif

@end

#if TARGET_OS_OSX
// TODO(stuartmorgan): Remove this and the ifdefs below once `publish` exists in the engine. See
// https://github.com/flutter/flutter/issues/124721.
FWFInstanceManager *sInstanceManager = nil;
#endif

@implementation FLTWebViewFlutterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FWFInstanceManager *instanceManager =
      [[FWFInstanceManager alloc] initWithDeallocCallback:^(long identifier) {
        FWFObjectFlutterApiImpl *objectApi = [[FWFObjectFlutterApiImpl alloc]
            initWithBinaryMessenger:registrar.messenger
                    instanceManager:[[FWFInstanceManager alloc] init]];

        dispatch_async(dispatch_get_main_queue(), ^{
          [objectApi disposeObjectWithIdentifier:@(identifier)
                                      completion:^(FlutterError *error) {
                                        NSAssert(!error, @"%@", error);
                                      }];
        });
      }];
  FWFWKHttpCookieStoreHostApiSetup(
      registrar.messenger,
      [[FWFHTTPCookieStoreHostApiImpl alloc] initWithInstanceManager:instanceManager]);
  FWFWKNavigationDelegateHostApiSetup(
      registrar.messenger,
      [[FWFNavigationDelegateHostApiImpl alloc] initWithBinaryMessenger:registrar.messenger
                                                        instanceManager:instanceManager]);
  FWFNSObjectHostApiSetup(registrar.messenger,
                          [[FWFObjectHostApiImpl alloc] initWithInstanceManager:instanceManager]);
  FWFWKPreferencesHostApiSetup(registrar.messenger, [[FWFPreferencesHostApiImpl alloc]
                                                        initWithInstanceManager:instanceManager]);
  FWFWKScriptMessageHandlerHostApiSetup(
      registrar.messenger,
      [[FWFScriptMessageHandlerHostApiImpl alloc] initWithBinaryMessenger:registrar.messenger
                                                          instanceManager:instanceManager]);
  FWFUIScrollViewHostApiSetup(registrar.messenger, [[FWFScrollViewHostApiImpl alloc]
                                                       initWithInstanceManager:instanceManager]);
  FWFWKUIDelegateHostApiSetup(registrar.messenger, [[FWFUIDelegateHostApiImpl alloc]
                                                       initWithBinaryMessenger:registrar.messenger
                                                               instanceManager:instanceManager]);
  FWFUIViewHostApiSetup(registrar.messenger,
                        [[FWFUIViewHostApiImpl alloc] initWithInstanceManager:instanceManager]);
  FWFWKUserContentControllerHostApiSetup(
      registrar.messenger,
      [[FWFUserContentControllerHostApiImpl alloc] initWithInstanceManager:instanceManager]);
  FWFWKWebsiteDataStoreHostApiSetup(
      registrar.messenger,
      [[FWFWebsiteDataStoreHostApiImpl alloc] initWithInstanceManager:instanceManager]);
  FWFWKWebViewConfigurationHostApiSetup(
      registrar.messenger,
      [[FWFWebViewConfigurationHostApiImpl alloc] initWithBinaryMessenger:registrar.messenger
                                                          instanceManager:instanceManager]);
  FWFWKWebViewHostApiSetup(registrar.messenger, [[FWFWebViewHostApiImpl alloc]
                                                    initWithBinaryMessenger:registrar.messenger
                                                            instanceManager:instanceManager]);
  FWFNSUrlHostApiSetup(registrar.messenger,
                       [[FWFURLHostApiImpl alloc] initWithBinaryMessenger:registrar.messenger
                                                          instanceManager:instanceManager]);

  FWFWebViewFactory *webviewFactory = [[FWFWebViewFactory alloc] initWithManager:instanceManager];
  [registrar registerViewFactory:webviewFactory withId:@"plugins.flutter.io/webview"];

#if TARGET_OS_IOS
  // InstanceManager is published so that a strong reference is maintained.
  [registrar publish:instanceManager];
#else
  // TODO(stuartmorgan): See comment above and https://github.com/flutter/flutter/issues/124721.
  sInstanceManager = instanceManager;
#endif
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
#if TARGET_OS_IOS
  [registrar publish:[NSNull null]];
#else
  // TODO(stuartmorgan): See comment above and https://github.com/flutter/flutter/issues/124721.
  sInstanceManager = nil;
#endif
}
@end
