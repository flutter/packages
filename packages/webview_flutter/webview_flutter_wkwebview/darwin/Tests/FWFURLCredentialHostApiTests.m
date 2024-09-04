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

@interface FWFURLCredentialHostApiTests : XCTestCase
@end

@implementation FWFURLCredentialHostApiTests
- (void)testHostApiCreate {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];

  FWFURLCredentialHostApiImpl *hostApi = [[FWFURLCredentialHostApiImpl alloc]
      initWithBinaryMessenger:OCMProtocolMock(@protocol(FlutterBinaryMessenger))
              instanceManager:instanceManager];

  FlutterError *error;
  [hostApi createWithUserWithIdentifier:0
                                   user:@"user"
                               password:@"password"
                            persistence:FWFNSUrlCredentialPersistencePermanent
                                  error:&error];
  XCTAssertNil(error);

  NSURLCredential *credential = (NSURLCredential *)[instanceManager instanceForIdentifier:0];
  XCTAssertEqualObjects(credential.user, @"user");
  XCTAssertEqualObjects(credential.password, @"password");
  XCTAssertEqual(credential.persistence, NSURLCredentialPersistencePermanent);
}
@end
