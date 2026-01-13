// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <gtest/gtest.h>

#include "pigeon/non_null_fields.gen.h"

TEST(NonNullFields, Build) {
  g_autoptr(NonNullFieldsPigeonTestNonNullFieldSearchRequest) request =
      non_null_fields_pigeon_test_non_null_field_search_request_new("hello");

  EXPECT_STREQ(
      non_null_fields_pigeon_test_non_null_field_search_request_get_query(
          request),
      "hello");
}
