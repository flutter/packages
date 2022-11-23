// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <gtest/gtest.h>

#include "non_null_fields.gen.h"

namespace non_null_fields_pigeontest {

TEST(NonNullFields, Build) {
  NonNullFieldSearchRequest request;
  request.set_query("hello");

  EXPECT_EQ(request.query(), "hello");
}

}  // namespace non_null_fields_pigeontest
