// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <flutter/encodable_value.h>
#include <gtest/gtest.h>

#include "pigeon/null_fields.gen.h"

namespace null_fields_pigeontest {

namespace {

using flutter::CustomEncodableValue;
using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

/// EXPECTs that 'list' contains 'index', and then returns a pointer to its
/// value.
///
/// This gives useful test failure messages instead of silent crashes when the
/// value isn't present, or has the wrong type.
template <class T>
const T* ExpectAndGetIndex(const EncodableList& list, const int i) {
  EXPECT_LT(i, list.size())
      << "Index " << i << " is out of bounds; size is " << list.size();
  if (i >= list.size()) {
    return nullptr;
  }
  const T* value_ptr = std::get_if<T>(&(list[i]));
  EXPECT_NE(value_ptr, nullptr)
      << "Value for index " << i << " has incorrect type";
  return value_ptr;
}

}  // namespace

class NullFieldsTest : public ::testing::Test {
 protected:
  // Wrapper for access to private NullFieldsSearchRequest list constructor.
  NullFieldsSearchRequest RequestFromList(const EncodableList& list) {
    return NullFieldsSearchRequest::FromEncodableList(list);
  }

  // Wrapper for access to private NullFieldsSearchRequest list constructor.
  NullFieldsSearchReply ReplyFromList(const EncodableList& list) {
    return NullFieldsSearchReply::FromEncodableList(list);
  }
  // Wrapper for access to private NullFieldsSearchRequest::ToEncodableList.
  EncodableList ListFromRequest(const NullFieldsSearchRequest& request) {
    return request.ToEncodableList();
  }
  // Wrapper for access to private NullFieldsSearchRequest list constructor.
  EncodableList ListFromReply(const NullFieldsSearchReply& reply) {
    return reply.ToEncodableList();
  }
};

TEST(NullFields, BuildWithValues) {
  NullFieldsSearchRequest request(0);
  request.set_query("hello");

  NullFieldsSearchReply reply;
  reply.set_result("result");
  reply.set_error("error");
  reply.set_indices(EncodableList({1, 2, 3}));
  reply.set_request(request);
  reply.set_type(NullFieldsSearchReplyType::kSuccess);

  EXPECT_EQ(*reply.result(), "result");
  EXPECT_EQ(*reply.error(), "error");
  EXPECT_EQ(reply.indices()->size(), 3);
  EXPECT_EQ(*reply.request()->query(), "hello");
  EXPECT_EQ(*reply.type(), NullFieldsSearchReplyType::kSuccess);
}

TEST(NullFields, BuildRequestWithNulls) {
  NullFieldsSearchRequest request(0);

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

TEST_F(NullFieldsTest, RequestFromListWithValues) {
  EncodableList list{
      EncodableValue("hello"),
      EncodableValue(1),
  };
  NullFieldsSearchRequest request = RequestFromList(list);

  EXPECT_EQ(*request.query(), "hello");
  EXPECT_EQ(request.identifier(), 1);
}

TEST_F(NullFieldsTest, RequestFromListWithNulls) {
  EncodableList list{
      EncodableValue(),
      EncodableValue(1),
  };
  NullFieldsSearchRequest request = RequestFromList(list);

  EXPECT_EQ(request.query(), nullptr);
  EXPECT_EQ(request.identifier(), 1);
}

TEST_F(NullFieldsTest, ReplyFromListWithValues) {
  NullFieldsSearchRequest request(1);
  request.set_query("hello");
  EncodableList list{
      EncodableValue("result"),
      EncodableValue("error"),
      EncodableValue(EncodableList({1, 2, 3})),
      CustomEncodableValue(request),
      CustomEncodableValue(NullFieldsSearchReplyType::kSuccess),
  };
  NullFieldsSearchReply reply = ReplyFromList(list);

  EXPECT_EQ(*reply.result(), "result");
  EXPECT_EQ(*reply.error(), "error");
  EXPECT_EQ(reply.indices()->size(), 3);
  EXPECT_EQ(*reply.request()->query(), "hello");
  EXPECT_EQ(reply.request()->identifier(), 1);
  EXPECT_EQ(*reply.type(), NullFieldsSearchReplyType::kSuccess);
}

TEST_F(NullFieldsTest, ReplyFromListWithNulls) {
  EncodableList list{
      EncodableValue(), EncodableValue(), EncodableValue(),
      EncodableValue(), EncodableValue(),
  };
  NullFieldsSearchReply reply = ReplyFromList(list);

  EXPECT_EQ(reply.result(), nullptr);
  EXPECT_EQ(reply.error(), nullptr);
  EXPECT_EQ(reply.indices(), nullptr);
  EXPECT_EQ(reply.request(), nullptr);
  EXPECT_EQ(reply.type(), nullptr);
}

TEST_F(NullFieldsTest, RequestToListWithValues) {
  NullFieldsSearchRequest request(1);
  request.set_query("hello");

  EncodableList list = ListFromRequest(request);

  EXPECT_EQ(list.size(), 2);

  EXPECT_EQ(*ExpectAndGetIndex<std::string>(list, 0), "hello");
  EXPECT_EQ(*ExpectAndGetIndex<int64_t>(list, 1), 1);
}

TEST_F(NullFieldsTest, RequestToMapWithNulls) {
  NullFieldsSearchRequest request(1);

  EncodableList list = ListFromRequest(request);

  EXPECT_EQ(list.size(), 2);
  EXPECT_TRUE(list[0].IsNull());
  EXPECT_EQ(*ExpectAndGetIndex<int64_t>(list, 1), 1);
}

TEST_F(NullFieldsTest, ReplyToMapWithValues) {
  NullFieldsSearchRequest request(1);
  request.set_query("hello");

  NullFieldsSearchReply reply;
  reply.set_result("result");
  reply.set_error("error");
  reply.set_indices(EncodableList({1, 2, 3}));
  reply.set_request(request);
  reply.set_type(NullFieldsSearchReplyType::kSuccess);

  const EncodableList list = ListFromReply(reply);

  EXPECT_EQ(list.size(), 5);
  EXPECT_EQ(*ExpectAndGetIndex<std::string>(list, 0), "result");
  EXPECT_EQ(*ExpectAndGetIndex<std::string>(list, 1), "error");
  const EncodableList& indices = *ExpectAndGetIndex<EncodableList>(list, 2);
  EXPECT_EQ(indices.size(), 3);
  EXPECT_EQ(indices[0].LongValue(), 1L);
  EXPECT_EQ(indices[1].LongValue(), 2L);
  EXPECT_EQ(indices[2].LongValue(), 3L);
  const NullFieldsSearchRequest& request_from_list =
      std::any_cast<const NullFieldsSearchRequest&>(
          *ExpectAndGetIndex<CustomEncodableValue>(list, 3));
  EXPECT_EQ(*request_from_list.query(), "hello");
  EXPECT_EQ(request_from_list.identifier(), 1);
}

TEST_F(NullFieldsTest, ReplyToListWithNulls) {
  NullFieldsSearchReply reply;

  const EncodableList list = ListFromReply(reply);

  const int field_count = 5;
  EXPECT_EQ(list.size(), field_count);
  for (int i = 0; i < field_count; ++i) {
    EXPECT_TRUE(list[i].IsNull());
  }
}

}  // namespace null_fields_pigeontest
