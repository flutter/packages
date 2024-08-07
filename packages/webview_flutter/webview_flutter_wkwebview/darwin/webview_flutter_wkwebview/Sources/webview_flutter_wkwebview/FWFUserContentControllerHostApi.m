// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/webview_flutter_wkwebview/FWFUserContentControllerHostApi.h"
#import "./include/webview_flutter_wkwebview/FWFDataConverters.h"
#import "./include/webview_flutter_wkwebview/FWFWebViewConfigurationHostApi.h"

@interface FWFUserContentControllerHostApiImpl ()
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) FWFInstanceManager *instanceManager;
@end

@implementation FWFUserContentControllerHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (WKUserContentController *)userContentControllerForIdentifier:(NSInteger)identifier {
  return (WKUserContentController *)[self.instanceManager instanceForIdentifier:identifier];
}

- (void)createFromWebViewConfigurationWithIdentifier:(NSInteger)identifier
                             configurationIdentifier:(NSInteger)configurationIdentifier
                                               error:(FlutterError *_Nullable *_Nonnull)error {
  WKWebViewConfiguration *configuration = (WKWebViewConfiguration *)[self.instanceManager
      instanceForIdentifier:configurationIdentifier];
  [self.instanceManager addDartCreatedInstance:configuration.userContentController
                                withIdentifier:identifier];
}

- (void)addScriptMessageHandlerForControllerWithIdentifier:(NSInteger)identifier
                                         handlerIdentifier:(NSInteger)handler
                                                    ofName:(nonnull NSString *)name
                                                     error:
                                                         (FlutterError *_Nullable *_Nonnull)error {
  [[self userContentControllerForIdentifier:identifier]
      addScriptMessageHandler:(id<WKScriptMessageHandler>)[self.instanceManager
                                  instanceForIdentifier:handler]
                         name:name];
}

- (void)removeScriptMessageHandlerForControllerWithIdentifier:(NSInteger)identifier
                                                         name:(nonnull NSString *)name
                                                        error:(FlutterError *_Nullable *_Nonnull)
                                                                  error {
  [[self userContentControllerForIdentifier:identifier] removeScriptMessageHandlerForName:name];
}

- (void)removeAllScriptMessageHandlersForControllerWithIdentifier:(NSInteger)identifier
                                                            error:
                                                                (FlutterError *_Nullable *_Nonnull)
                                                                    error {
  if (@available(iOS 14.0, macOS 11, *)) {
    [[self userContentControllerForIdentifier:identifier] removeAllScriptMessageHandlers];
  } else {
    *error = [FlutterError
        errorWithCode:@"FWFUnsupportedVersionError"
              message:@"removeAllScriptMessageHandlers is only supported on iOS 14+ and macOS 11+."
              details:nil];
  }
}

- (void)addUserScriptForControllerWithIdentifier:(NSInteger)identifier
                                      userScript:(nonnull FWFWKUserScriptData *)userScript
                                           error:(FlutterError *_Nullable *_Nonnull)error {
  [[self userContentControllerForIdentifier:identifier]
      addUserScript:FWFNativeWKUserScriptFromScriptData(userScript)];
}

- (void)removeAllUserScriptsForControllerWithIdentifier:(NSInteger)identifier
                                                  error:(FlutterError *_Nullable *_Nonnull)error {
  [[self userContentControllerForIdentifier:identifier] removeAllUserScripts];
}

@end
