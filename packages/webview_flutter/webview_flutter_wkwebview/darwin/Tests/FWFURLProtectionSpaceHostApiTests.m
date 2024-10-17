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

@interface FWFURLProtectionSpaceHostApiTests : XCTestCase
@end

@implementation FWFURLProtectionSpaceHostApiTests
- (void)testFlutterApiCreate {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  FWFURLProtectionSpaceFlutterApiImpl *flutterApi = [[FWFURLProtectionSpaceFlutterApiImpl alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];

  flutterApi.api = OCMClassMock([FWFNSUrlProtectionSpaceFlutterApi class]);

  NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:@"host"
                                                                                port:0
                                                                            protocol:nil
                                                                               realm:@"realm"
                                                                authenticationMethod:nil];
  [flutterApi createWithInstance:protectionSpace
                            host:@"host"
                           realm:@"realm"
            authenticationMethod:@"method"
                      completion:^(FlutterError *error){

                      }];

  long identifier = [instanceManager identifierWithStrongReferenceForInstance:protectionSpace];
  OCMVerify([flutterApi.api createWithIdentifier:identifier
                                            host:@"host"
                                           realm:@"realm"
                            authenticationMethod:@"method"
                                      completion:OCMOCK_ANY]);
}
@end
