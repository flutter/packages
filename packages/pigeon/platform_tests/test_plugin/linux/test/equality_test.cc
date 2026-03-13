// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <gtest/gtest.h>

#include <cmath>

#include "pigeon/core_tests.gen.h"

static CoreTestsPigeonTestAllNullableTypes* create_empty_all_nullable_types() {
  return core_tests_pigeon_test_all_nullable_types_new(
      nullptr, nullptr, nullptr, nullptr, nullptr, 0, nullptr, 0, nullptr, 0,
      nullptr, 0, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
      nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
      nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr);
}

TEST(Equality, AllNullableTypesNaN) {
  double nan_val = NAN;
  g_autoptr(CoreTestsPigeonTestAllNullableTypes) all1 =
      core_tests_pigeon_test_all_nullable_types_new(
          nullptr, nullptr, nullptr, &nan_val, nullptr, 0, nullptr, 0, nullptr,
          0, nullptr, 0, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr);
  g_autoptr(CoreTestsPigeonTestAllNullableTypes) all2 =
      core_tests_pigeon_test_all_nullable_types_new(
          nullptr, nullptr, nullptr, &nan_val, nullptr, 0, nullptr, 0, nullptr,
          0, nullptr, 0, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr);

  EXPECT_TRUE(core_tests_pigeon_test_all_nullable_types_equals(all1, all2));
  EXPECT_EQ(core_tests_pigeon_test_all_nullable_types_hash(all1),
            core_tests_pigeon_test_all_nullable_types_hash(all2));
}

TEST(Equality, AllNullableTypesCollectionNaN) {
  g_autoptr(FlValue) list1 = fl_value_new_list();
  fl_value_append_take(list1, fl_value_new_float(NAN));

  g_autoptr(FlValue) list2 = fl_value_new_list();
  fl_value_append_take(list2, fl_value_new_float(NAN));

  g_autoptr(CoreTestsPigeonTestAllNullableTypes) all1 =
      core_tests_pigeon_test_all_nullable_types_new(
          nullptr, nullptr, nullptr, nullptr, nullptr, 0, nullptr, 0, nullptr,
          0, nullptr, 0, nullptr, nullptr, nullptr, nullptr, nullptr, list1,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr);
  g_autoptr(CoreTestsPigeonTestAllNullableTypes) all2 =
      core_tests_pigeon_test_all_nullable_types_new(
          nullptr, nullptr, nullptr, nullptr, nullptr, 0, nullptr, 0, nullptr,
          0, nullptr, 0, nullptr, nullptr, nullptr, nullptr, nullptr, list2,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr);

  EXPECT_TRUE(core_tests_pigeon_test_all_nullable_types_equals(all1, all2));
  EXPECT_EQ(core_tests_pigeon_test_all_nullable_types_hash(all1),
            core_tests_pigeon_test_all_nullable_types_hash(all2));
}

TEST(Equality, AllNullableTypesRecursive) {
  g_autoptr(CoreTestsPigeonTestAllNullableTypes) nested1 =
      create_empty_all_nullable_types();
  g_autoptr(CoreTestsPigeonTestAllNullableTypes) all1 =
      core_tests_pigeon_test_all_nullable_types_new(
          nullptr, nullptr, nullptr, nullptr, nullptr, 0, nullptr, 0, nullptr,
          0, nullptr, 0, nullptr, nullptr, nullptr, nullptr, nested1, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr);

  g_autoptr(CoreTestsPigeonTestAllNullableTypes) nested2 =
      create_empty_all_nullable_types();
  g_autoptr(CoreTestsPigeonTestAllNullableTypes) all2 =
      core_tests_pigeon_test_all_nullable_types_new(
          nullptr, nullptr, nullptr, nullptr, nullptr, 0, nullptr, 0, nullptr,
          0, nullptr, 0, nullptr, nullptr, nullptr, nullptr, nested2, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr);

  EXPECT_TRUE(core_tests_pigeon_test_all_nullable_types_equals(all1, all2));
  EXPECT_EQ(core_tests_pigeon_test_all_nullable_types_hash(all1),
            core_tests_pigeon_test_all_nullable_types_hash(all2));
}

TEST(Equality, AllTypesNumericLists) {
  uint8_t bytes[] = {1, 2, 3};
  int32_t ints32[] = {4, 5};
  double doubles[] = {1.1, 2.2};

  g_autoptr(CoreTestsPigeonTestAllTypes) all1 =
      core_tests_pigeon_test_all_types_new(
          TRUE, 1, 2, 3.3, bytes, 3, ints32, 2, nullptr, 0, doubles, 2,
          PIGEON_INTEGRATION_TESTS_AN_ENUM_ONE,
          PIGEON_INTEGRATION_TESTS_ANOTHER_ENUM_JUST_IN_CASE, "hello", nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr);

  g_autoptr(CoreTestsPigeonTestAllTypes) all2 =
      core_tests_pigeon_test_all_types_new(
          TRUE, 1, 2, 3.3, bytes, 3, ints32, 2, nullptr, 0, doubles, 2,
          PIGEON_INTEGRATION_TESTS_AN_ENUM_ONE,
          PIGEON_INTEGRATION_TESTS_ANOTHER_ENUM_JUST_IN_CASE, "hello", nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr);

  EXPECT_TRUE(core_tests_pigeon_test_all_types_equals(all1, all2));
  EXPECT_EQ(core_tests_pigeon_test_all_types_hash(all1),
            core_tests_pigeon_test_all_types_hash(all2));

  // Change one element in a numeric list
  doubles[1] = 2.3;
  g_autoptr(CoreTestsPigeonTestAllTypes) all3 =
      core_tests_pigeon_test_all_types_new(
          TRUE, 1, 2, 3.3, bytes, 3, ints32, 2, nullptr, 0, doubles, 2,
          PIGEON_INTEGRATION_TESTS_AN_ENUM_ONE,
          PIGEON_INTEGRATION_TESTS_ANOTHER_ENUM_JUST_IN_CASE, "hello", nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr);

  EXPECT_FALSE(core_tests_pigeon_test_all_types_equals(all1, all3));
  EXPECT_NE(core_tests_pigeon_test_all_types_hash(all1),
            core_tests_pigeon_test_all_types_hash(all3));
}

TEST(Equality, SignedZero) {
  double p_zero = 0.0;
  double n_zero = -0.0;
  g_autoptr(CoreTestsPigeonTestAllNullableTypes) all1 =
      core_tests_pigeon_test_all_nullable_types_new(
          nullptr, nullptr, nullptr, &p_zero, nullptr, 0, nullptr, 0, nullptr,
          0, nullptr, 0, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr);
  g_autoptr(CoreTestsPigeonTestAllNullableTypes) all2 =
      core_tests_pigeon_test_all_nullable_types_new(
          nullptr, nullptr, nullptr, &n_zero, nullptr, 0, nullptr, 0, nullptr,
          0, nullptr, 0, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr);

  EXPECT_TRUE(core_tests_pigeon_test_all_nullable_types_equals(all1, all2));
  EXPECT_EQ(core_tests_pigeon_test_all_nullable_types_hash(all1),
            core_tests_pigeon_test_all_nullable_types_hash(all2));
}

TEST(Equality, SignedZeroMapKey) {
  double p_zero = 0.0;
  double n_zero = -0.0;
  g_autoptr(FlValue) map1 = fl_value_new_map();
  fl_value_set_take(map1, fl_value_new_float(p_zero), fl_value_new_string("a"));
  g_autoptr(FlValue) map2 = fl_value_new_map();
  fl_value_set_take(map2, fl_value_new_float(n_zero), fl_value_new_string("a"));

  g_autoptr(CoreTestsPigeonTestAllNullableTypes) all1 =
      core_tests_pigeon_test_all_nullable_types_new(
          nullptr, nullptr, nullptr, nullptr, nullptr, 0, nullptr, 0, nullptr,
          0, nullptr, 0, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, map1, nullptr,
          nullptr, nullptr);
  g_autoptr(CoreTestsPigeonTestAllNullableTypes) all2 =
      core_tests_pigeon_test_all_nullable_types_new(
          nullptr, nullptr, nullptr, nullptr, nullptr, 0, nullptr, 0, nullptr,
          0, nullptr, 0, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, map2, nullptr,
          nullptr, nullptr);

  EXPECT_TRUE(core_tests_pigeon_test_all_nullable_types_equals(all1, all2));
  EXPECT_EQ(core_tests_pigeon_test_all_nullable_types_hash(all1),
            core_tests_pigeon_test_all_nullable_types_hash(all2));
}

TEST(Equality, SignedZeroList) {
  g_autoptr(FlValue) list1 = fl_value_new_list();
  fl_value_append_take(list1, fl_value_new_float(0.0));
  g_autoptr(FlValue) list2 = fl_value_new_list();
  fl_value_append_take(list2, fl_value_new_float(-0.0));

  g_autoptr(CoreTestsPigeonTestAllNullableTypes) all1 =
      core_tests_pigeon_test_all_nullable_types_new(
          nullptr, nullptr, nullptr, nullptr, nullptr, 0, nullptr, 0, nullptr,
          0, nullptr, 0, nullptr, nullptr, nullptr, nullptr, nullptr, list1,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr);
  g_autoptr(CoreTestsPigeonTestAllNullableTypes) all2 =
      core_tests_pigeon_test_all_nullable_types_new(
          nullptr, nullptr, nullptr, nullptr, nullptr, 0, nullptr, 0, nullptr,
          0, nullptr, 0, nullptr, nullptr, nullptr, nullptr, nullptr, list2,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr);

  EXPECT_TRUE(core_tests_pigeon_test_all_nullable_types_equals(all1, all2));
  EXPECT_EQ(core_tests_pigeon_test_all_nullable_types_hash(all1),
            core_tests_pigeon_test_all_nullable_types_hash(all2));
}

TEST(Equality, SignedZeroMapValue) {
  g_autoptr(FlValue) map1 = fl_value_new_map();
  fl_value_set_take(map1, fl_value_new_string("a"), fl_value_new_float(0.0));
  g_autoptr(FlValue) map2 = fl_value_new_map();
  fl_value_set_take(map2, fl_value_new_string("a"), fl_value_new_float(-0.0));

  g_autoptr(CoreTestsPigeonTestAllNullableTypes) all1 =
      core_tests_pigeon_test_all_nullable_types_new(
          nullptr, nullptr, nullptr, nullptr, nullptr, 0, nullptr, 0, nullptr,
          0, nullptr, 0, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, map1, nullptr,
          nullptr, nullptr);
  g_autoptr(CoreTestsPigeonTestAllNullableTypes) all2 =
      core_tests_pigeon_test_all_nullable_types_new(
          nullptr, nullptr, nullptr, nullptr, nullptr, 0, nullptr, 0, nullptr,
          0, nullptr, 0, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr,
          nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, map2, nullptr,
          nullptr, nullptr);

  EXPECT_TRUE(core_tests_pigeon_test_all_nullable_types_equals(all1, all2));
  EXPECT_EQ(core_tests_pigeon_test_all_nullable_types_hash(all1),
            core_tests_pigeon_test_all_nullable_types_hash(all2));
}
