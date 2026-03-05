// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <gtest/gtest.h>

#include <cmath>

#include "pigeon/core_tests.gen.h"

namespace test_plugin {
namespace test {

using namespace core_tests_pigeontest;

TEST(EqualityTests, NaNEquality) {
  AllNullableTypes all1;
  all1.set_a_nullable_double(NAN);

  AllNullableTypes all2;
  all2.set_a_nullable_double(NAN);

  EXPECT_EQ(all1, all2);

  AllNullableTypes all3;
  all3.set_a_nullable_double(1.0);

  EXPECT_NE(all1, all3);
}

TEST(EqualityTests, OptionalNaNEquality) {
  AllNullableTypes all1;
  // std::optional<double> handled via set_a_nullable_double
  all1.set_a_nullable_double(NAN);

  AllNullableTypes all2;
  all2.set_a_nullable_double(NAN);

  EXPECT_EQ(all1, all2);
}

TEST(EqualityTests, NestedNaNEquality) {
  std::vector<double> list = {NAN};
  AllNullableTypes all1;
  all1.set_double_list(list);

  AllNullableTypes all2;
  all2.set_double_list(list);

  EXPECT_EQ(all1, all2);
}

TEST(EqualityTests, SignedZeroEquality) {
  AllNullableTypes all1;
  all1.set_a_nullable_double(0.0);

  AllNullableTypes all2;
  all2.set_a_nullable_double(-0.0);

  EXPECT_EQ(all1, all2);
}

}  // namespace test
}  // namespace test_plugin
