// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <flutter/encodable_value.h>
#include <gtest/gtest.h>

#include "null_fields.g.h"

namespace null_fields_pigeontest {

namespace {

using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

// EXPECTs that 'map' contains 'key', and then returns a pointer to its value.
//
// This gives useful test failure messages instead of silent crashes when the
// value isn't present, or has the wrong type.
template <class T>
const T *ExpectAndGet(const EncodableMap &map, const std::string &key) {
  auto it = map.find(EncodableValue(key));
  EXPECT_TRUE(it != map.end()) << "Could not find value for '" << key << '"';
  if (it == map.end()) {
    return nullptr;
  }
  const T *value_ptr = std::get_if<T>(&(it->second));
  EXPECT_NE(value_ptr, nullptr)
      << "Value for '" << key << "' has incorrect type";
  return value_ptr;
}

}  // namespace

class NullFieldsTest : public ::testing::Test {
 protected:
  // Wrapper for access to private NullFieldsSearchRequest map constructor.
  NullFieldsSearchRequest RequestFromMap(const EncodableMap &map) {
    return NullFieldsSearchRequest(map);
  }

  // Wrapper for access to private NullFieldsSearchRequest map constructor.
  NullFieldsSearchReply ReplyFromMap(const EncodableMap &map) {
    return NullFieldsSearchReply(map);
  }
  // Wrapper for access to private NullFieldsSearchRequest::ToEncodableMap.
  EncodableMap MapFromRequest(const NullFieldsSearchRequest &request) {
    return request.ToEncodableMap();
  }
  // Wrapper for access to private NullFieldsSearchRequest map constructor.
  EncodableMap MapFromReply(const NullFieldsSearchReply &reply) {
    return reply.ToEncodableMap();
  }
};

TEST(NullFields, BuildWithValues) {
  NullFieldsSearchRequest request;
  request.set_query("hello");

  NullFieldsSearchReply reply;
  reply.set_result("result");
  reply.set_error("error");
  reply.set_indices(EncodableList({1, 2, 3}));
  reply.set_request(request);
  reply.set_type(NullFieldsSearchReplyType::success);

  EXPECT_EQ(*reply.result(), "result");
  EXPECT_EQ(*reply.error(), "error");
  EXPECT_EQ(reply.indices()->size(), 3);
  EXPECT_EQ(*reply.request()->query(), "hello");
  EXPECT_EQ(*reply.type(), NullFieldsSearchReplyType::success);
}

TEST(NullFields, BuildRequestWithNulls) {
  NullFieldsSearchRequest request;

  EXPECT_EQ(request.query(), nullptr);
}

TEST(NullFields, BuildReplyWithNulls) {
  NullFieldsSearchReply reply;

  EXPECT_EQ(reply.result(), nullptr);
  EXPECT_EQ(reply.error(), nullptr);
  EXPECT_EQ(reply.indices(), nullptr);
  EXPECT_EQ(reply.request(), nullptr);
  EXPECT_EQ(reply.type(), nullptr);
}

TEST_F(NullFieldsTest, RequestFromMapWithValues) {
  EncodableMap map{
      {EncodableValue("query"), EncodableValue("hello")},
  };
  NullFieldsSearchRequest request = RequestFromMap(map);

  EXPECT_EQ(*request.query(), "hello");
}

TEST_F(NullFieldsTest, RequestFromMapWithNulls) {
  EncodableMap map{
      {EncodableValue("query"), EncodableValue()},
  };
  NullFieldsSearchRequest request = RequestFromMap(map);

  EXPECT_EQ(request.query(), nullptr);
}

TEST_F(NullFieldsTest, ReplyFromMapWithValues) {
  EncodableMap map{
      {EncodableValue("result"), EncodableValue("result")},
      {EncodableValue("error"), EncodableValue("error")},
      {EncodableValue("indices"), EncodableValue(EncodableList{
                                      EncodableValue(1),
                                      EncodableValue(2),
                                      EncodableValue(3),
                                  })},
      {EncodableValue("request"),
       EncodableValue(EncodableMap{
           {EncodableValue("query"), EncodableValue("hello")},
       })},
      {EncodableValue("type"), EncodableValue(0)},
  };
  NullFieldsSearchReply reply = ReplyFromMap(map);

  EXPECT_EQ(*reply.result(), "result");
  EXPECT_EQ(*reply.error(), "error");
  EXPECT_EQ(reply.indices()->size(), 3);
  EXPECT_EQ(*reply.request()->query(), "hello");
  EXPECT_EQ(*reply.type(), NullFieldsSearchReplyType::success);
}

TEST_F(NullFieldsTest, ReplyFromMapWithNulls) {
  EncodableMap map{
      {EncodableValue("result"), EncodableValue()},
      {EncodableValue("error"), EncodableValue()},
      {EncodableValue("indices"), EncodableValue()},
      {EncodableValue("request"), EncodableValue()},
      {EncodableValue("type"), EncodableValue()},
  };
  NullFieldsSearchReply reply = ReplyFromMap(map);

  EXPECT_EQ(reply.result(), nullptr);
  EXPECT_EQ(reply.error(), nullptr);
  EXPECT_EQ(reply.indices(), nullptr);
  EXPECT_EQ(reply.request(), nullptr);
  EXPECT_EQ(reply.type(), nullptr);
}

TEST_F(NullFieldsTest, RequestToMapWithValues) {
  NullFieldsSearchRequest request;
  request.set_query("hello");

  EncodableMap map = MapFromRequest(request);

  EXPECT_EQ(map.size(), 1);
  EXPECT_EQ(*ExpectAndGet<std::string>(map, "query"), "hello");
}

TEST_F(NullFieldsTest, RequestToMapWithNulls) {
  NullFieldsSearchRequest request;

  EncodableMap map = MapFromRequest(request);

  EXPECT_EQ(map.size(), 1);
  EXPECT_TRUE(map[EncodableValue("hello")].IsNull());
}

TEST_F(NullFieldsTest, ReplyToMapWithValues) {
  NullFieldsSearchRequest request;
  request.set_query("hello");

  NullFieldsSearchReply reply;
  reply.set_result("result");
  reply.set_error("error");
  reply.set_indices(EncodableList({1, 2, 3}));
  reply.set_request(request);
  reply.set_type(NullFieldsSearchReplyType::success);

  EncodableMap map = MapFromReply(reply);

  EXPECT_EQ(map.size(), 5);
  EXPECT_EQ(*ExpectAndGet<std::string>(map, "result"), "result");
  EXPECT_EQ(*ExpectAndGet<std::string>(map, "error"), "error");
  const EncodableList &indices = *ExpectAndGet<EncodableList>(map, "indices");
  EXPECT_EQ(indices.size(), 3);
  EXPECT_EQ(indices[0].LongValue(), 1L);
  EXPECT_EQ(indices[1].LongValue(), 2L);
  EXPECT_EQ(indices[2].LongValue(), 3L);
  const EncodableMap &request_map = *ExpectAndGet<EncodableMap>(map, "request");
  EXPECT_EQ(*ExpectAndGet<std::string>(request_map, "query"), "hello");
  EXPECT_EQ(*ExpectAndGet<int>(map, "type"), 0);
}

TEST_F(NullFieldsTest, ReplyToMapWithNulls) {
  NullFieldsSearchReply reply;

  EncodableMap map = MapFromReply(reply);

  EXPECT_EQ(map.size(), 5);
  EXPECT_TRUE(map[EncodableValue("result")].IsNull());
  EXPECT_TRUE(map[EncodableValue("error")].IsNull());
  EXPECT_TRUE(map[EncodableValue("indices")].IsNull());
  EXPECT_TRUE(map[EncodableValue("request")].IsNull());
  EXPECT_TRUE(map[EncodableValue("type")].IsNull());
}

}  // namespace null_fields_pigeontest
