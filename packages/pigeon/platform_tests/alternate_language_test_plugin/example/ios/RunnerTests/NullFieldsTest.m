// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;

@import alternate_language_test_plugin;

#import "EchoMessenger.h"

///////////////////////////////////////////////////////////////////////////////////////////
@interface NullFieldsSearchRequest ()
+ (NullFieldsSearchRequest *)fromList:(NSArray<id> *)list;
- (NSArray<id> *)toList;
@end

///////////////////////////////////////////////////////////////////////////////////////////
@interface NullFieldsSearchReply ()
+ (NullFieldsSearchReply *)fromList:(NSArray<id> *)list;
- (NSArray<id> *)toList;
@end

///////////////////////////////////////////////////////////////////////////////////////////
@interface NullFieldsTest : XCTestCase
@end

///////////////////////////////////////////////////////////////////////////////////////////
@implementation NullFieldsTest

- (void)testMakeWithValues {
  NullFieldsSearchRequest *request = [NullFieldsSearchRequest makeWithQuery:@"hello" identifier:1];

  NullFieldsSearchReplyTypeBox *typeWrapper =
      [[NullFieldsSearchReplyTypeBox alloc] initWithValue:NullFieldsSearchReplyTypeSuccess];
  NullFieldsSearchReply *reply = [NullFieldsSearchReply makeWithResult:@"result"
                                                                 error:@"error"
                                                               indices:@[ @1, @2, @3 ]
                                                               request:request
                                                                  type:typeWrapper];

  NSArray<id> *indices = @[ @1, @2, @3 ];
  XCTAssertEqualObjects(@"result", reply.result);
  XCTAssertEqualObjects(@"error", reply.error);
  XCTAssertEqualObjects(indices, reply.indices);
  XCTAssertEqualObjects(@"hello", reply.request.query);
  XCTAssertEqual(typeWrapper.value, reply.type.value);
}

- (void)testMakeRequestWithNulls {
  NullFieldsSearchRequest *request = [NullFieldsSearchRequest makeWithQuery:nil identifier:1];
  XCTAssertNil(request.query);
}

- (void)testMakeReplyWithNulls {
  NullFieldsSearchReply *reply = [NullFieldsSearchReply makeWithResult:nil
                                                                 error:nil
                                                               indices:nil
                                                               request:nil
                                                                  type:nil];
  XCTAssertNil(reply.result);
  XCTAssertNil(reply.error);
  XCTAssertNil(reply.indices);
  XCTAssertNil(reply.request);
  XCTAssertNil(reply.type);
}

- (void)testRequestFromListWithValues {
  NSArray<id> *list = @[
    @"hello",
    @1,
  ];
  NullFieldsSearchRequest *request = [NullFieldsSearchRequest fromList:list];
  XCTAssertEqualObjects(@"hello", request.query);
}

- (void)testRequestFromListWithNulls {
  NSArray<id> *list = @[
    [NSNull null],
    @1,
  ];
  NullFieldsSearchRequest *request = [NullFieldsSearchRequest fromList:list];
  XCTAssertNil(request.query);
}

- (void)testReplyFromListWithValues {
  NullFieldsSearchReplyTypeBox *typeWrapper =
      [[NullFieldsSearchReplyTypeBox alloc] initWithValue:NullFieldsSearchReplyTypeSuccess];

  NSArray<id> *listRequest = @[
    @"hello",
    @1,
  ];
  NSArray<id> *listReply = @[
    @"result",
    @"error",
    @[ @1, @2, @3 ],
    [NullFieldsSearchRequest fromList:listRequest],
    typeWrapper,
  ];

  NSArray<id> *indices = @[ @1, @2, @3 ];
  NullFieldsSearchReply *reply = [NullFieldsSearchReply fromList:listReply];

  XCTAssertEqualObjects(@"result", reply.result);
  XCTAssertEqualObjects(@"error", reply.error);
  XCTAssertEqualObjects(indices, reply.indices);
  XCTAssertEqualObjects(@"hello", reply.request.query);
  XCTAssertEqual(NullFieldsSearchReplyTypeSuccess, reply.type.value);
}

- (void)testReplyFromListWithNulls {
  NSArray<id> *list = @[
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
  XCTAssertNil(reply.type);
}

- (void)testRequestToListWithValuess {
  NullFieldsSearchRequest *request = [NullFieldsSearchRequest makeWithQuery:@"hello" identifier:1];
  NSArray<id> *list = [request toList];
  XCTAssertEqual(@"hello", list[0]);
}

- (void)testRequestToListWithNulls {
  NullFieldsSearchRequest *request = [NullFieldsSearchRequest makeWithQuery:nil identifier:1];
  NSArray<id> *list = [request toList];
  XCTAssertEqual([NSNull null], list[0]);
}

- (void)testReplyToListWithValuess {
  NullFieldsSearchReplyTypeBox *typeWrapper =
      [[NullFieldsSearchReplyTypeBox alloc] initWithValue:NullFieldsSearchReplyTypeSuccess];
  NullFieldsSearchReply *reply = [NullFieldsSearchReply
      makeWithResult:@"result"
               error:@"error"
             indices:@[ @1, @2, @3 ]
             request:[NullFieldsSearchRequest makeWithQuery:@"hello" identifier:1]
                type:typeWrapper];
  NSArray<id> *list = [reply toList];
  NSArray<id> *indices = @[ @1, @2, @3 ];
  XCTAssertEqualObjects(@"result", list[0]);
  XCTAssertEqualObjects(@"error", list[1]);
  XCTAssertEqualObjects(indices, list[2]);
  XCTAssertEqualObjects(@"hello", ((NullFieldsSearchRequest *)list[3]).query);
  NullFieldsSearchReplyTypeBox *output = list[4];

  XCTAssertEqual(typeWrapper.value, output.value);
}

- (void)testReplyToListWithNulls {
  NullFieldsSearchReply *reply = [NullFieldsSearchReply makeWithResult:nil
                                                                 error:nil
                                                               indices:nil
                                                               request:nil
                                                                  type:nil];
  NSArray<id> *list = [reply toList];
  XCTAssertEqual([NSNull null], list[0]);
  XCTAssertEqual([NSNull null], list[1]);
  XCTAssertEqual([NSNull null], list[2]);
  XCTAssertEqual([NSNull null], list[3]);
  XCTAssertEqual([NSNull null], list[4]);
}

@end
