// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <gtest/gtest.h>

#include "pigeon/non_null_fields.gen.h"

namespace non_null_fields_pigeontest {

TEST(NonNullFields, Build) {
  NonNullFieldSearchRequest request("hello");

  EXPECT_EQ(request.query(), "hello");
}

}  // namespace non_null_fields_pigeontest
