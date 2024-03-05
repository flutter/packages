// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFNavigationDelegateHostApi.h"
#import "FWFDataConverters.h"
#import "FWFURLAuthenticationChallengeHostApi.h"
#import "FWFWebViewConfigurationHostApi.h"

@interface FWFNavigationDelegateFlutterApiImpl ()
// BinaryMessenger must be weak to prevent a circular reference with the host API it
// references.
@property(nonatomic, weak) id<FlutterBinaryMessenger> binaryMessenger;
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) FWFInstanceManager *instanceManager;
@end

@implementation FWFNavigationDelegateFlutterApiImpl
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [self initWithBinaryMessenger:binaryMessenger];
  if (self) {
    _binaryMessenger = binaryMessenger;
    _instanceManager = instanceManager;
  }
  return self;
}

- (long)identifierForDelegate:(FWFNavigationDelegate *)instance {
  return [self.instanceManager identifierWithStrongReferenceForInstance:instance];
}

- (void)didFinishNavigationForDelegate:(FWFNavigationDelegate *)instance
                               webView:(WKWebView *)webView
                                   URL:(NSString *)URL
                            completion:(void (^)(FlutterError *_Nullable))completion {
  NSInteger webViewIdentifier =
      [self.instanceManager identifierWithStrongReferenceForInstance:webView];
  [self didFinishNavigationForDelegateWithIdentifier:[self identifierForDelegate:instance]
                                   webViewIdentifier:webViewIdentifier
                                                 URL:URL
                                          completion:completion];
}

- (void)didStartProvisionalNavigationForDelegate:(FWFNavigationDelegate *)instance
                                         webView:(WKWebView *)webView
                                             URL:(NSString *)URL
                                      completion:(void (^)(FlutterError *_Nullable))completion {
  NSInteger webViewIdentifier =
      [self.instanceManager identifierWithStrongReferenceForInstance:webView];
  [self didStartProvisionalNavigationForDelegateWithIdentifier:[self identifierForDelegate:instance]
                                             webViewIdentifier:webViewIdentifier
                                                           URL:URL
                                                    completion:completion];
}

- (void)
    decidePolicyForNavigationActionForDelegate:(FWFNavigationDelegate *)instance
                                       webView:(WKWebView *)webView
                              navigationAction:(WKNavigationAction *)navigationAction
                                    completion:
                                        (void (^)(FWFWKNavigationActionPolicyEnumData *_Nullable,
                                                  FlutterError *_Nullable))completion {
  NSInteger webViewIdentifier =
      [self.instanceManager identifierWithStrongReferenceForInstance:webView];
  FWFWKNavigationActionData *navigationActionData =
      FWFWKNavigationActionDataFromNativeWKNavigationAction(navigationAction);
  [self
      decidePolicyForNavigationActionForDelegateWithIdentifier:[self identifierForDelegate:instance]
                                             webViewIdentifier:webViewIdentifier
                                              navigationAction:navigationActionData
                                                    completion:completion];
}

- (void)decidePolicyForNavigationResponseForDelegate:(FWFNavigationDelegate *)instance
                                             webView:(WKWebView *)webView
                                  navigationResponse:(WKNavigationResponse *)navigationResponse
                                          completion:
                                              (void (^)(FWFWKNavigationResponsePolicyEnumBox *,
                                                        FlutterError *_Nullable))completion {
  NSInteger webViewIdentifier =
      [self.instanceManager identifierWithStrongReferenceForInstance:webView];
  FWFWKNavigationResponseData *navigationResponseData =
      FWFWKNavigationResponseDataFromNativeNavigationResponse(navigationResponse);
  [self
      decidePolicyForNavigationResponseForDelegateWithIdentifier:[self
                                                                     identifierForDelegate:instance]
                                               webViewIdentifier:webViewIdentifier
                                              navigationResponse:navigationResponseData
                                                      completion:completion];
}

- (void)didFailNavigationForDelegate:(FWFNavigationDelegate *)instance
                             webView:(WKWebView *)webView
                               error:(NSError *)error
                          completion:(void (^)(FlutterError *_Nullable))completion {
  NSInteger webViewIdentifier =
      [self.instanceManager identifierWithStrongReferenceForInstance:webView];
  [self didFailNavigationForDelegateWithIdentifier:[self identifierForDelegate:instance]
                                 webViewIdentifier:webViewIdentifier
                                             error:FWFNSErrorDataFromNativeNSError(error)
                                        completion:completion];
}

- (void)didFailProvisionalNavigationForDelegate:(FWFNavigationDelegate *)instance
                                        webView:(WKWebView *)webView
                                          error:(NSError *)error
                                     completion:(void (^)(FlutterError *_Nullable))completion {
  NSInteger webViewIdentifier =
      [self.instanceManager identifierWithStrongReferenceForInstance:webView];
  [self didFailProvisionalNavigationForDelegateWithIdentifier:[self identifierForDelegate:instance]
                                            webViewIdentifier:webViewIdentifier
                                                        error:FWFNSErrorDataFromNativeNSError(error)
                                                   completion:completion];
}

- (void)webViewWebContentProcessDidTerminateForDelegate:(FWFNavigationDelegate *)instance
                                                webView:(WKWebView *)webView
                                             completion:
                                                 (void (^)(FlutterError *_Nullable))completion {
  NSInteger webViewIdentifier =
      [self.instanceManager identifierWithStrongReferenceForInstance:webView];
  [self webViewWebContentProcessDidTerminateForDelegateWithIdentifier:
            [self identifierForDelegate:instance]
                                                    webViewIdentifier:webViewIdentifier
                                                           completion:completion];
}

- (void)
    didReceiveAuthenticationChallengeForDelegate:(FWFNavigationDelegate *)instance
                                         webView:(WKWebView *)webView
                                       challenge:(NSURLAuthenticationChallenge *)challenge
                                      completion:
                                          (void (^)(FWFAuthenticationChallengeResponse *_Nullable,
                                                    FlutterError *_Nullable))completion {
  NSInteger webViewIdentifier =
      [self.instanceManager identifierWithStrongReferenceForInstance:webView];

  FWFURLAuthenticationChallengeFlutterApiImpl *challengeApi =
      [[FWFURLAuthenticationChallengeFlutterApiImpl alloc]
          initWithBinaryMessenger:self.binaryMessenger
                  instanceManager:self.instanceManager];
  [challengeApi createWithInstance:challenge
                   protectionSpace:challenge.protectionSpace
                        completion:^(FlutterError *error) {
                          NSAssert(!error, @"%@", error);
                        }];

  [self
      didReceiveAuthenticationChallengeForDelegateWithIdentifier:[self
                                                                     identifierForDelegate:instance]
                                               webViewIdentifier:webViewIdentifier
                                             challengeIdentifier:
                                                 [self.instanceManager
                                                     identifierWithStrongReferenceForInstance:
                                                         challenge]
                                                      completion:completion];
}
@end

@implementation FWFNavigationDelegate
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [super initWithBinaryMessenger:binaryMessenger instanceManager:instanceManager];
  if (self) {
    _navigationDelegateAPI =
        [[FWFNavigationDelegateFlutterApiImpl alloc] initWithBinaryMessenger:binaryMessenger
                                                             instanceManager:instanceManager];
  }
  return self;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
  [self.navigationDelegateAPI didFinishNavigationForDelegate:self
                                                     webView:webView
                                                         URL:webView.URL.absoluteString
                                                  completion:^(FlutterError *error) {
                                                    NSAssert(!error, @"%@", error);
                                                  }];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
  [self.navigationDelegateAPI didStartProvisionalNavigationForDelegate:self
                                                               webView:webView
                                                                   URL:webView.URL.absoluteString
                                                            completion:^(FlutterError *error) {
                                                              NSAssert(!error, @"%@", error);
                                                            }];
}

- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
  [self.navigationDelegateAPI
      decidePolicyForNavigationActionForDelegate:self
                                         webView:webView
                                navigationAction:navigationAction
                                      completion:^(FWFWKNavigationActionPolicyEnumData *policy,
                                                   FlutterError *error) {
                                        NSAssert(!error, @"%@", error);
                                        if (!error) {
                                          decisionHandler(
                                              FWFNativeWKNavigationActionPolicyFromEnumData(
                                                  policy));
                                        } else {
                                          decisionHandler(WKNavigationActionPolicyCancel);
                                        }
                                      }];
}

- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
                      decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
  [self.navigationDelegateAPI
      decidePolicyForNavigationResponseForDelegate:self
                                           webView:webView
                                navigationResponse:navigationResponse
                                        completion:^(FWFWKNavigationResponsePolicyEnumBox *policy,
                                                     FlutterError *error) {
                                          NSAssert(!error, @"%@", error);
                                          if (!error) {
                                            decisionHandler(
                                                FWFNativeWKNavigationResponsePolicyFromEnum(
                                                    policy.value));
                                          } else {
                                            decisionHandler(WKNavigationResponsePolicyCancel);
                                          }
                                        }];
}

- (void)webView:(WKWebView *)webView
    didFailNavigation:(WKNavigation *)navigation
            withError:(NSError *)error {
  [self.navigationDelegateAPI didFailNavigationForDelegate:self
                                                   webView:webView
                                                     error:error
                                                completion:^(FlutterError *error) {
                                                  NSAssert(!error, @"%@", error);
                                                }];
}

- (void)webView:(WKWebView *)webView
    didFailProvisionalNavigation:(WKNavigation *)navigation
                       withError:(NSError *)error {
  [self.navigationDelegateAPI didFailProvisionalNavigationForDelegate:self
                                                              webView:webView
                                                                error:error
                                                           completion:^(FlutterError *error) {
                                                             NSAssert(!error, @"%@", error);
                                                           }];
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
  [self.navigationDelegateAPI
      webViewWebContentProcessDidTerminateForDelegate:self
                                              webView:webView
                                           completion:^(FlutterError *error) {
                                             NSAssert(!error, @"%@", error);
                                           }];
}

- (void)webView:(WKWebView *)webView
    didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
                    completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition,
                                                NSURLCredential *_Nullable))completionHandler {
  [self.navigationDelegateAPI
      didReceiveAuthenticationChallengeForDelegate:self
                                           webView:webView
                                         challenge:challenge
                                        completion:^(FWFAuthenticationChallengeResponse *response,
                                                     FlutterError *error) {
                                          NSAssert(!error, @"%@", error);
                                          if (!error) {
                                            NSURLSessionAuthChallengeDisposition disposition =
                                                FWFNativeNSURLSessionAuthChallengeDispositionFromFWFNSUrlSessionAuthChallengeDisposition(
                                                    response.disposition);

                                            NSURLCredential *credential =
                                                response.credentialIdentifier
                                                    ? (NSURLCredential *)[self.navigationDelegateAPI
                                                                              .instanceManager
                                                          instanceForIdentifier:
                                                              response.credentialIdentifier
                                                                  .longValue]
                                                    : nil;

                                            completionHandler(disposition, credential);
                                          } else {
                                            completionHandler(
                                                NSURLSessionAuthChallengeCancelAuthenticationChallenge,
                                                nil);
                                          }
                                        }];
}
@end

@interface FWFNavigationDelegateHostApiImpl ()
// BinaryMessenger must be weak to prevent a circular reference with the host API it
// references.
@property(nonatomic, weak) id<FlutterBinaryMessenger> binaryMessenger;
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) FWFInstanceManager *instanceManager;
@end

@implementation FWFNavigationDelegateHostApiImpl
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _binaryMessenger = binaryMessenger;
    _instanceManager = instanceManager;
  }
  return self;
}

- (FWFNavigationDelegate *)navigationDelegateForIdentifier:(NSInteger)identifier {
  return (FWFNavigationDelegate *)[self.instanceManager instanceForIdentifier:identifier];
}

- (void)createWithIdentifier:(NSInteger)identifier
                       error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  FWFNavigationDelegate *navigationDelegate =
      [[FWFNavigationDelegate alloc] initWithBinaryMessenger:self.binaryMessenger
                                             instanceManager:self.instanceManager];
  [self.instanceManager addDartCreatedInstance:navigationDelegate withIdentifier:identifier];
}
@end
