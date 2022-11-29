// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <XCTest/XCTest.h>
#import "EchoMessenger.h"
#import "NullFields.gen.h"

///////////////////////////////////////////////////////////////////////////////////////////
@interface NullFieldsSearchRequest ()
+ (NullFieldsSearchRequest *)fromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end

///////////////////////////////////////////////////////////////////////////////////////////
@interface NullFieldsSearchReply ()
+ (NullFieldsSearchReply *)fromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
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

- (void)testRequestFromMapWithValues {
  NSDictionary *map = @{
    @"query" : @"hello",
    @"identifier" : @1,
  };
  NullFieldsSearchRequest *request = [NullFieldsSearchRequest fromMap:map];
  XCTAssertEqualObjects(@"hello", request.query);
}

- (void)testRequestFromMapWithNulls {
  NSDictionary *map = @{
    @"query" : [NSNull null],
    @"identifier" : @1,
  };
  NullFieldsSearchRequest *request = [NullFieldsSearchRequest fromMap:map];
  XCTAssertNil(request.query);
}

- (void)testReplyFromMapWithValues {
  NSDictionary *map = @{
    @"result" : @"result",
    @"error" : @"error",
    @"indices" : @[ @1, @2, @3 ],
    @"request" : @{
      @"query" : @"hello",
      @"identifier" : @1,
    },
    @"type" : @0,
  };

  NSArray *indices = @[ @1, @2, @3 ];
  NullFieldsSearchReply *reply = [NullFieldsSearchReply fromMap:map];
  XCTAssertEqualObjects(@"result", reply.result);
  XCTAssertEqualObjects(@"error", reply.error);
  XCTAssertEqualObjects(indices, reply.indices);
  XCTAssertEqualObjects(@"hello", reply.request.query);
  XCTAssertEqual(NullFieldsSearchReplyTypeSuccess, reply.type);
}

- (void)testReplyFromMapWithNulls {
  NSDictionary *map = @{
    @"result" : [NSNull null],
    @"error" : [NSNull null],
    @"indices" : [NSNull null],
    @"request" : [NSNull null],
    @"type" : [NSNull null],
  };
  NullFieldsSearchReply *reply = [NullFieldsSearchReply fromMap:map];
  XCTAssertNil(reply.result);
  XCTAssertNil(reply.error);
  XCTAssertNil(reply.indices);
  XCTAssertNil(reply.request.query);
  XCTAssertEqual(NullFieldsSearchReplyTypeSuccess, reply.type);
}

- (void)testRequestToMapWithValuess {
  NullFieldsSearchRequest *request = [NullFieldsSearchRequest makeWithQuery:@"hello" identifier:@1];
  NSDictionary *dict = [request toMap];
  XCTAssertEqual(@"hello", dict[@"query"]);
}

- (void)testRequestToMapWithNulls {
  NullFieldsSearchRequest *request = [NullFieldsSearchRequest makeWithQuery:nil identifier:@1];
  NSDictionary *dict = [request toMap];
  XCTAssertEqual([NSNull null], dict[@"query"]);
}

- (void)testReplyToMapWithValuess {
  NullFieldsSearchReply *reply = [NullFieldsSearchReply
      makeWithResult:@"result"
               error:@"error"
             indices:@[ @1, @2, @3 ]
             request:[NullFieldsSearchRequest makeWithQuery:@"hello" identifier:@1]
                type:NullFieldsSearchReplyTypeSuccess];
  NSDictionary *dict = [reply toMap];
  NSArray *indices = @[ @1, @2, @3 ];
  XCTAssertEqualObjects(@"result", dict[@"result"]);
  XCTAssertEqualObjects(@"error", dict[@"error"]);
  XCTAssertEqualObjects(indices, dict[@"indices"]);
  XCTAssertEqualObjects(@"hello", dict[@"request"][@"query"]);
  XCTAssertEqualObjects(@0, dict[@"type"]);
}

- (void)testReplyToMapWithNulls {
  NullFieldsSearchReply *reply =
      [NullFieldsSearchReply makeWithResult:nil
                                      error:nil
                                    indices:nil
                                    request:nil
                                       type:NullFieldsSearchReplyTypeSuccess];
  NSDictionary *dict = [reply toMap];
  XCTAssertEqual([NSNull null], dict[@"result"]);
  XCTAssertEqual([NSNull null], dict[@"error"]);
  XCTAssertEqual([NSNull null], dict[@"indices"]);
  XCTAssertEqual([NSNull null], dict[@"request"]);
}

@end
