// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;

#ifdef LEGACY_HARNESS
#import "NullFields.gen.h"
#else
@import alternate_language_test_plugin;
#endif

#import "EchoMessenger.h"

///////////////////////////////////////////////////////////////////////////////////////////
@interface NullFieldsSearchRequest ()
+ (NullFieldsSearchRequest *)fromList:(NSArray *)list;
- (NSArray *)toList;
@end

///////////////////////////////////////////////////////////////////////////////////////////
@interface NullFieldsSearchReply ()
+ (NullFieldsSearchReply *)fromList:(NSArray *)list;
- (NSArray *)toList;
@end

///////////////////////////////////////////////////////////////////////////////////////////
@interface NullFieldsTest : XCTestCase
@end

///////////////////////////////////////////////////////////////////////////////////////////
@implementation NullFieldsTest

- (void)testMakeWithValues {
  NullFieldsSearchRequest *request = [NullFieldsSearchRequest makeWithQuery:@"hello" identifier:@1];

  NullFieldsSearchReply *reply =
      [NullFieldsSearchReply makeWithResult:@"result"
                                      error:@"error"
                                    indices:@[ @1, @2, @3 ]
                                    request:request
                                       type:NullFieldsSearchReplyTypeSuccess];

  NSArray *indices = @[ @1, @2, @3 ];
  XCTAssertEqualObjects(@"result", reply.result);
  XCTAssertEqualObjects(@"error", reply.error);
  XCTAssertEqualObjects(indices, reply.indices);
  XCTAssertEqualObjects(@"hello", reply.request.query);
  XCTAssertEqual(NullFieldsSearchReplyTypeSuccess, reply.type);
}

- (void)testMakeRequestWithNulls {
  NullFieldsSearchRequest *request = [NullFieldsSearchRequest makeWithQuery:nil identifier:@1];
  XCTAssertNil(request.query);
}

- (void)testMakeReplyWithNulls {
  NullFieldsSearchReply *reply =
      [NullFieldsSearchReply makeWithResult:nil
                                      error:nil
                                    indices:nil
                                    request:nil
                                       type:NullFieldsSearchReplyTypeSuccess];
  XCTAssertNil(reply.result);
  XCTAssertNil(reply.error);
  XCTAssertNil(reply.indices);
  XCTAssertNil(reply.request);
  XCTAssertEqual(NullFieldsSearchReplyTypeSuccess, reply.type);
}

- (void)testRequestFromListWithValues {
  NSArray *list = @[
    @"hello",
    @1,
  ];
  NullFieldsSearchRequest *request = [NullFieldsSearchRequest fromList:list];
  XCTAssertEqualObjects(@"hello", request.query);
}

- (void)testRequestFromListWithNulls {
  NSArray *list = @[
    [NSNull null],
    @1,
  ];
  NullFieldsSearchRequest *request = [NullFieldsSearchRequest fromList:list];
  XCTAssertNil(request.query);
}

- (void)testReplyFromListWithValues {
  NSArray *list = @[
    @"result",
    @"error",
    @[ @1, @2, @3 ],
    @[
      @"hello",
      @1,
    ],
    @0,
  ];

  NSArray *indices = @[ @1, @2, @3 ];
  NullFieldsSearchReply *reply = [NullFieldsSearchReply fromList:list];
  XCTAssertEqualObjects(@"result", reply.result);
  XCTAssertEqualObjects(@"error", reply.error);
  XCTAssertEqualObjects(indices, reply.indices);
  XCTAssertEqualObjects(@"hello", reply.request.query);
  XCTAssertEqual(NullFieldsSearchReplyTypeSuccess, reply.type);
}

- (void)testReplyFromListWithNulls {
  NSArray *list = @[
    [NSNull null],
    [NSNull null],
    [NSNull null],
    [NSNull null],
    [NSNull null],
  ];
  NullFieldsSearchReply *reply = [NullFieldsSearchReply fromList:list];
  XCTAssertNil(reply.result);
  XCTAssertNil(reply.error);
  XCTAssertNil(reply.indices);
  XCTAssertNil(reply.request.query);
  XCTAssertEqual(NullFieldsSearchReplyTypeSuccess, reply.type);
}

- (void)testRequestToListWithValuess {
  NullFieldsSearchRequest *request = [NullFieldsSearchRequest makeWithQuery:@"hello" identifier:@1];
  NSArray *list = [request toList];
  XCTAssertEqual(@"hello", list[0]);
}

- (void)testRequestToListWithNulls {
  NullFieldsSearchRequest *request = [NullFieldsSearchRequest makeWithQuery:nil identifier:@1];
  NSArray *list = [request toList];
  XCTAssertEqual([NSNull null], list[0]);
}

- (void)testReplyToListWithValuess {
  NullFieldsSearchReply *reply = [NullFieldsSearchReply
      makeWithResult:@"result"
               error:@"error"
             indices:@[ @1, @2, @3 ]
             request:[NullFieldsSearchRequest makeWithQuery:@"hello" identifier:@1]
                type:NullFieldsSearchReplyTypeSuccess];
  NSArray *list = [reply toList];
  NSArray *indices = @[ @1, @2, @3 ];
  XCTAssertEqualObjects(@"result", list[0]);
  XCTAssertEqualObjects(@"error", list[1]);
  XCTAssertEqualObjects(indices, list[2]);
  XCTAssertEqualObjects(@"hello", list[3][0]);
  XCTAssertEqualObjects(@0, list[4]);
}

- (void)testReplyToListWithNulls {
  NullFieldsSearchReply *reply =
      [NullFieldsSearchReply makeWithResult:nil
                                      error:nil
                                    indices:nil
                                    request:nil
                                       type:NullFieldsSearchReplyTypeSuccess];
  NSArray *list = [reply toList];
  XCTAssertEqual([NSNull null], list[0]);
  XCTAssertEqual([NSNull null], list[1]);
  XCTAssertEqual([NSNull null], list[2]);
  XCTAssertEqual([NSNull null], list[3]);
}

@end
