// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/webview_flutter_wkwebview/FLTWebViewFlutterPlugin.h"
#import "./include/webview_flutter_wkwebview/FWFGeneratedWebKitApis.h"
#import "./include/webview_flutter_wkwebview/FWFHTTPCookieStoreHostApi.h"
#import "./include/webview_flutter_wkwebview/FWFInstanceManager.h"
#import "./include/webview_flutter_wkwebview/FWFNavigationDelegateHostApi.h"
#import "./include/webview_flutter_wkwebview/FWFObjectHostApi.h"
#import "./include/webview_flutter_wkwebview/FWFPreferencesHostApi.h"
#import "./include/webview_flutter_wkwebview/FWFScriptMessageHandlerHostApi.h"
#import "./include/webview_flutter_wkwebview/FWFScrollViewDelegateHostApi.h"
#import "./include/webview_flutter_wkwebview/FWFScrollViewHostApi.h"
#import "./include/webview_flutter_wkwebview/FWFUIDelegateHostApi.h"
#import "./include/webview_flutter_wkwebview/FWFUIViewHostApi.h"
#import "./include/webview_flutter_wkwebview/FWFURLCredentialHostApi.h"
#import "./include/webview_flutter_wkwebview/FWFURLHostApi.h"
#import "./include/webview_flutter_wkwebview/FWFUserContentControllerHostApi.h"
#import "./include/webview_flutter_wkwebview/FWFWebViewConfigurationHostApi.h"
#import "./include/webview_flutter_wkwebview/FWFWebViewHostApi.h"
#import "./include/webview_flutter_wkwebview/FWFWebsiteDataStoreHostApi.h"

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

// The FlutterPlatformViewFactory protocol is slightly different on iOS and
// macOS.
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
  NSNumber *identifier = (NSNumber *)args;
  FWFWebView *webView =
      (FWFWebView *)[self.instanceManager instanceForIdentifier:identifier.longValue];
  return webView;
}

#endif

@end

@implementation FLTWebViewFlutterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FWFInstanceManager *instanceManager =
      [[FWFInstanceManager alloc] initWithDeallocCallback:^(long identifier) {
        FWFObjectFlutterApiImpl *objectApi = [[FWFObjectFlutterApiImpl alloc]
            initWithBinaryMessenger:registrar.messenger
                    instanceManager:[[FWFInstanceManager alloc] init]];

        dispatch_async(dispatch_get_main_queue(), ^{
          [objectApi disposeObjectWithIdentifier:identifier
                                      completion:^(FlutterError *error) {
                                        NSAssert(!error, @"%@", error);
                                      }];
        });
      }];
  SetUpFWFWKHttpCookieStoreHostApi(
      registrar.messenger,
      [[FWFHTTPCookieStoreHostApiImpl alloc] initWithInstanceManager:instanceManager]);
  SetUpFWFWKNavigationDelegateHostApi(
      registrar.messenger,
      [[FWFNavigationDelegateHostApiImpl alloc] initWithBinaryMessenger:registrar.messenger
                                                        instanceManager:instanceManager]);
  SetUpFWFNSObjectHostApi(registrar.messenger,
                          [[FWFObjectHostApiImpl alloc] initWithInstanceManager:instanceManager]);
  SetUpFWFWKPreferencesHostApi(registrar.messenger, [[FWFPreferencesHostApiImpl alloc]
                                                        initWithInstanceManager:instanceManager]);
  SetUpFWFWKScriptMessageHandlerHostApi(
      registrar.messenger,
      [[FWFScriptMessageHandlerHostApiImpl alloc] initWithBinaryMessenger:registrar.messenger
                                                          instanceManager:instanceManager]);
  SetUpFWFUIScrollViewHostApi(registrar.messenger, [[FWFScrollViewHostApiImpl alloc]
                                                       initWithInstanceManager:instanceManager]);
  SetUpFWFWKUIDelegateHostApi(registrar.messenger, [[FWFUIDelegateHostApiImpl alloc]
                                                       initWithBinaryMessenger:registrar.messenger
                                                               instanceManager:instanceManager]);
#if TARGET_OS_IOS
  SetUpFWFUIViewHostApi(registrar.messenger,
                        [[FWFUIViewHostApiImpl alloc] initWithInstanceManager:instanceManager]);
#endif
  SetUpFWFWKUserContentControllerHostApi(
      registrar.messenger,
      [[FWFUserContentControllerHostApiImpl alloc] initWithInstanceManager:instanceManager]);
  SetUpFWFWKWebsiteDataStoreHostApi(
      registrar.messenger,
      [[FWFWebsiteDataStoreHostApiImpl alloc] initWithInstanceManager:instanceManager]);
  SetUpFWFWKWebViewConfigurationHostApi(
      registrar.messenger,
      [[FWFWebViewConfigurationHostApiImpl alloc] initWithBinaryMessenger:registrar.messenger
                                                          instanceManager:instanceManager]);
  SetUpFWFWKWebViewHostApi(registrar.messenger, [[FWFWebViewHostApiImpl alloc]
                                                    initWithBinaryMessenger:registrar.messenger
                                                            instanceManager:instanceManager]);
  SetUpFWFNSUrlHostApi(registrar.messenger,
                       [[FWFURLHostApiImpl alloc] initWithBinaryMessenger:registrar.messenger
                                                          instanceManager:instanceManager]);
#if TARGET_OS_IOS
  SetUpFWFUIScrollViewDelegateHostApi(
      registrar.messenger,
      [[FWFScrollViewDelegateHostApiImpl alloc] initWithBinaryMessenger:registrar.messenger
                                                        instanceManager:instanceManager]);
#endif
  SetUpFWFNSUrlCredentialHostApi(
      registrar.messenger,
      [[FWFURLCredentialHostApiImpl alloc] initWithBinaryMessenger:registrar.messenger
                                                   instanceManager:instanceManager]);

  FWFWebViewFactory *webviewFactory = [[FWFWebViewFactory alloc] initWithManager:instanceManager];
  [registrar registerViewFactory:webviewFactory withId:@"plugins.flutter.io/webview"];

  // InstanceManager is published so that a strong reference is maintained.
  [registrar publish:instanceManager];
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [registrar publish:[NSNull null]];
}
@end
