// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "TargetConditionals.h"

// The scroll view delegate does not exist on macOS.
#if !TARGET_OS_OSX

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface FWFScrollViewDelegateHostApiTests : XCTestCase

@end

@implementation FWFScrollViewDelegateHostApiTests
/**
 * Creates a partially mocked FWFScrollViewDelegate and adds it to instanceManager.
 *
 * @param instanceManager Instance manager to add the delegate to.
 * @param identifier Identifier for the delegate added to the instanceManager.
 *
 * @return A mock FWFScrollViewDelegate.
 */
- (id)mockDelegateWithManager:(FWFInstanceManager *)instanceManager identifier:(long)identifier {
  FWFScrollViewDelegate *delegate = [[FWFScrollViewDelegate alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];

  [instanceManager addDartCreatedInstance:delegate withIdentifier:0];
  return OCMPartialMock(delegate);
}

/**
 * Creates a  mock FWFUIScrollViewDelegateFlutterApiImpl with instanceManager.
 *
 * @param instanceManager Instance manager passed to the Flutter API.
 *
 * @return A mock FWFUIScrollViewDelegateFlutterApiImpl.
 */
- (id)mockFlutterApiWithManager:(FWFInstanceManager *)instanceManager {
  FWFScrollViewDelegateFlutterApiImpl *flutterAPI = [[FWFScrollViewDelegateFlutterApiImpl alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];
  return OCMPartialMock(flutterAPI);
}

- (void)testCreateWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  FWFScrollViewDelegateHostApiImpl *hostAPI = [[FWFScrollViewDelegateHostApiImpl alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];

  FlutterError *error;
  [hostAPI createWithIdentifier:0 error:&error];
  FWFScrollViewDelegate *delegate =
      (FWFScrollViewDelegate *)[instanceManager instanceForIdentifier:0];

  XCTAssertTrue([delegate conformsToProtocol:@protocol(UIScrollViewDelegate)]);
  XCTAssertNil(error);
}

- (void)testOnScrollViewDidScrollForDelegateWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];

  FWFScrollViewDelegate *mockDelegate = [self mockDelegateWithManager:instanceManager identifier:0];
  FWFScrollViewDelegateFlutterApiImpl *mockFlutterAPI =
      [self mockFlutterApiWithManager:instanceManager];

  OCMStub([mockDelegate scrollViewDelegateAPI]).andReturn(mockFlutterAPI);
  UIScrollView *scrollView = [[UIScrollView alloc] init];
  scrollView.contentOffset = CGPointMake(1.0, 2.0);

  [instanceManager addDartCreatedInstance:scrollView withIdentifier:1];

  [mockDelegate scrollViewDidScroll:scrollView];
  OCMVerify([mockFlutterAPI scrollViewDidScrollWithIdentifier:0
                                       UIScrollViewIdentifier:1
                                                            x:1.0
                                                            y:2.0
                                                   completion:OCMOCK_ANY]);
}
@end

#endif  // !TARGET_OS_OSX
