// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import XCTest;
@import webview_flutter_wkwebview;
#if __has_include(<webview_flutter_wkwebview/webview-umbrella.h>)
@import webview_flutter_wkwebview.Test;
#endif

#if TARGET_OS_OSX
@import FlutterMacOS;
#else
@import Flutter;
#endif

#import <OCMock/OCMock.h>

@interface FWFUIDelegateHostApiTests : XCTestCase
@end

@implementation FWFUIDelegateHostApiTests
/**
 * Creates a partially mocked FWFUIDelegate and adds it to instanceManager.
 *
 * @param instanceManager Instance manager to add the delegate to.
 * @param identifier Identifier for the delegate added to the instanceManager.
 *
 * @return A mock FWFUIDelegate.
 */
- (id)mockDelegateWithManager:(FWFInstanceManager *)instanceManager identifier:(long)identifier {
  FWFUIDelegate *delegate = [[FWFUIDelegate alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];

  [instanceManager addDartCreatedInstance:delegate withIdentifier:0];
  return OCMPartialMock(delegate);
}

/**
 * Creates a  mock FWFUIDelegateFlutterApiImpl with instanceManager.
 *
 * @param instanceManager Instance manager passed to the Flutter API.
 *
 * @return A mock FWFUIDelegateFlutterApiImpl.
 */
- (id)mockFlutterApiWithManager:(FWFInstanceManager *)instanceManager {
  FWFUIDelegateFlutterApiImpl *flutterAPI = [[FWFUIDelegateFlutterApiImpl alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];
  return OCMPartialMock(flutterAPI);
}

- (void)testCreateWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  FWFUIDelegateHostApiImpl *hostAPI = [[FWFUIDelegateHostApiImpl alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];

  FlutterError *error;
  [hostAPI createWithIdentifier:0 error:&error];
  FWFUIDelegate *delegate = (FWFUIDelegate *)[instanceManager instanceForIdentifier:0];

  XCTAssertTrue([delegate conformsToProtocol:@protocol(WKUIDelegate)]);
  XCTAssertNil(error);
}

- (void)testOnCreateWebViewForDelegateWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];

  FWFUIDelegate *mockDelegate = [self mockDelegateWithManager:instanceManager identifier:0];
  FWFUIDelegateFlutterApiImpl *mockFlutterAPI = [self mockFlutterApiWithManager:instanceManager];

  OCMStub([mockDelegate UIDelegateAPI]).andReturn(mockFlutterAPI);

  WKWebView *mockWebView = OCMClassMock([WKWebView class]);
  [instanceManager addDartCreatedInstance:mockWebView withIdentifier:1];

  WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
  id mockConfigurationFlutterApi = OCMPartialMock(mockFlutterAPI.webViewConfigurationFlutterApi);
  OCMStub([mockConfigurationFlutterApi createWithIdentifier:0 completion:OCMOCK_ANY])
      .ignoringNonObjectArgs();

  WKNavigationAction *mockNavigationAction = OCMClassMock([WKNavigationAction class]);
  NSURL *testURL = [NSURL URLWithString:@"https://www.flutter.dev"];
  OCMStub([mockNavigationAction request]).andReturn([NSURLRequest requestWithURL:testURL]);

  WKFrameInfo *mockFrameInfo = OCMClassMock([WKFrameInfo class]);
  OCMStub([mockFrameInfo isMainFrame]).andReturn(YES);
  OCMStub([mockNavigationAction targetFrame]).andReturn(mockFrameInfo);

  // Creating the webview will create a configuration on the host side, using the next available
  // identifier, so save that for checking against later.
  NSInteger configurationIdentifier = instanceManager.nextIdentifier;
  [mockDelegate webView:mockWebView
      createWebViewWithConfiguration:configuration
                 forNavigationAction:mockNavigationAction
                      windowFeatures:OCMClassMock([WKWindowFeatures class])];
  OCMVerify([mockFlutterAPI
      onCreateWebViewForDelegateWithIdentifier:0
                             webViewIdentifier:1
                       configurationIdentifier:configurationIdentifier
                              navigationAction:[OCMArg
                                                   isKindOfClass:[FWFWKNavigationActionData class]]
                                    completion:OCMOCK_ANY]);
}

- (void)testRequestMediaCapturePermissionForOrigin API_AVAILABLE(ios(15.0), macos(12)) {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];

  FWFUIDelegate *mockDelegate = [self mockDelegateWithManager:instanceManager identifier:0];
  FWFUIDelegateFlutterApiImpl *mockFlutterAPI = [self mockFlutterApiWithManager:instanceManager];

  OCMStub([mockDelegate UIDelegateAPI]).andReturn(mockFlutterAPI);

  WKWebView *mockWebView = OCMClassMock([WKWebView class]);
  [instanceManager addDartCreatedInstance:mockWebView withIdentifier:1];

  WKSecurityOrigin *mockSecurityOrigin = OCMClassMock([WKSecurityOrigin class]);
  OCMStub([mockSecurityOrigin host]).andReturn(@"");
  OCMStub([mockSecurityOrigin port]).andReturn(0);
  OCMStub([mockSecurityOrigin protocol]).andReturn(@"");

  WKFrameInfo *mockFrameInfo = OCMClassMock([WKFrameInfo class]);
  OCMStub([mockFrameInfo isMainFrame]).andReturn(YES);

  [mockDelegate webView:mockWebView
      requestMediaCapturePermissionForOrigin:mockSecurityOrigin
                            initiatedByFrame:mockFrameInfo
                                        type:WKMediaCaptureTypeMicrophone
                             decisionHandler:^(WKPermissionDecision decision){
                             }];

  OCMVerify([mockFlutterAPI
      requestMediaCapturePermissionForDelegateWithIdentifier:0
                                           webViewIdentifier:1
                                                      origin:[OCMArg isKindOfClass:
                                                                         [FWFWKSecurityOriginData
                                                                             class]]
                                                       frame:[OCMArg
                                                                 isKindOfClass:[FWFWKFrameInfoData
                                                                                   class]]
                                                        type:[OCMArg isKindOfClass:
                                                                         [FWFWKMediaCaptureTypeData
                                                                             class]]
                                                  completion:OCMOCK_ANY]);
}
@end
