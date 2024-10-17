// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import XCTest;
@import webview_flutter_wkwebview;

#if TARGET_OS_OSX
@import FlutterMacOS;
#else
@import Flutter;
#endif

#import <OCMock/OCMock.h>

@interface FWFURLAuthenticationChallengeHostApiTests : XCTestCase

@end

@implementation FWFURLAuthenticationChallengeHostApiTests
- (void)testFlutterApiCreate {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  FWFURLAuthenticationChallengeFlutterApiImpl *flutterApi =
      [[FWFURLAuthenticationChallengeFlutterApiImpl alloc]
          initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
                  instanceManager:instanceManager];

  flutterApi.api = OCMClassMock([FWFNSUrlAuthenticationChallengeFlutterApi class]);

  NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:@"host"
                                                                                port:0
                                                                            protocol:nil
                                                                               realm:@"realm"
                                                                authenticationMethod:nil];

  NSURLAuthenticationChallenge *mockChallenge = OCMClassMock([NSURLAuthenticationChallenge class]);
  OCMStub([mockChallenge protectionSpace]).andReturn(protectionSpace);

  [flutterApi createWithInstance:mockChallenge
                 protectionSpace:protectionSpace
                      completion:^(FlutterError *error){

                      }];

  long identifier = [instanceManager identifierWithStrongReferenceForInstance:mockChallenge];
  long protectionSpaceIdentifier =
      [instanceManager identifierWithStrongReferenceForInstance:protectionSpace];
  OCMVerify([flutterApi.api createWithIdentifier:identifier
                       protectionSpaceIdentifier:protectionSpaceIdentifier
                                      completion:OCMOCK_ANY]);
}
@end
