// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <gtest/gtest.h>

#include "pigeon/null_fields.gen.h"

TEST(NullFields, BuildWithValues) {
  g_autoptr(NullFieldsPigeonTestNullFieldsSearchRequest) request =
      null_fields_pigeon_test_null_fields_search_request_new("hello", 0);

  int64_t indicies_values[] = {1, 2, 3};
  g_autoptr(FlValue) indicies = fl_value_new_int64_list(indicies_values, 3);
  NullFieldsPigeonTestNullFieldsSearchReplyType type =
      PIGEON_INTEGRATION_TESTS_NULL_FIELDS_SEARCH_REPLY_TYPE_SUCCESS;
  g_autoptr(NullFieldsPigeonTestNullFieldsSearchReply) reply =
      null_fields_pigeon_test_null_fields_search_reply_new(
          "result", "error", indicies, request, &type);

  EXPECT_STREQ(
      null_fields_pigeon_test_null_fields_search_reply_get_result(reply),
      "result");
  EXPECT_STREQ(
      null_fields_pigeon_test_null_fields_search_reply_get_error(reply),
      "error");
  EXPECT_EQ(
      fl_value_get_length(
          null_fields_pigeon_test_null_fields_search_reply_get_indices(reply)),
      3);
  EXPECT_STREQ(
      null_fields_pigeon_test_null_fields_search_request_get_query(
          null_fields_pigeon_test_null_fields_search_reply_get_request(reply)),
      "hello");
  EXPECT_EQ(*null_fields_pigeon_test_null_fields_search_reply_get_type_(reply),
            PIGEON_INTEGRATION_TESTS_NULL_FIELDS_SEARCH_REPLY_TYPE_SUCCESS);
}

TEST(NullFields, BuildRequestWithNulls) {
  g_autoptr(NullFieldsPigeonTestNullFieldsSearchRequest) request =
      null_fields_pigeon_test_null_fields_search_request_new(nullptr, 0);

  EXPECT_EQ(
      null_fields_pigeon_test_null_fields_search_request_get_query(request),
      nullptr);
}

TEST(NullFields, BuildReplyWithNulls) {
  g_autoptr(NullFieldsPigeonTestNullFieldsSearchReply) reply =
      null_fields_pigeon_test_null_fields_search_reply_new(
          nullptr, nullptr, nullptr, nullptr, nullptr);

  EXPECT_EQ(null_fields_pigeon_test_null_fields_search_reply_get_result(reply),
            nullptr);
  EXPECT_EQ(null_fields_pigeon_test_null_fields_search_reply_get_error(reply),
            nullptr);
  EXPECT_EQ(null_fields_pigeon_test_null_fields_search_reply_get_indices(reply),
            nullptr);
  EXPECT_EQ(null_fields_pigeon_test_null_fields_search_reply_get_request(reply),
            nullptr);
  EXPECT_EQ(null_fields_pigeon_test_null_fields_search_reply_get_type_(reply),
            nullptr);
}
