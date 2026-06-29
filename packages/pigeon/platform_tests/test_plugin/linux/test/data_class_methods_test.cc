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

TEST(Equality, ToStringSnapshot) {
  g_autoptr(CoreTestsPigeonTestAllNullableTypes) empty_obj =
      create_empty_all_nullable_types();

  gchar* str = core_tests_pigeon_test_all_nullable_types_to_string(empty_obj);
  ASSERT_NE(str, nullptr);

  // Verify structural validation across all 31 serialized fields.
  const char* expected_fields[] = {"AllNullableTypes(",
                                   "a_nullable_bool: null",
                                   "a_nullable_int: null",
                                   "a_nullable_int64: null",
                                   "a_nullable_double: null",
                                   "a_nullable_byte_array: null",
                                   "a_nullable4_byte_array: null",
                                   "a_nullable8_byte_array: null",
                                   "a_nullable_float_array: null",
                                   "a_nullable_enum: null",
                                   "another_nullable_enum: null",
                                   "a_nullable_string: null",
                                   "a_nullable_object: null",
                                   "all_nullable_types: null",
                                   "list: null",
                                   "string_list: null",
                                   "int_list: null",
                                   "double_list: null",
                                   "bool_list: null",
                                   "enum_list: null",
                                   "object_list: null",
                                   "list_list: null",
                                   "map_list: null",
                                   "recursive_class_list: null",
                                   "map: null",
                                   "string_map: null",
                                   "int_map: null",
                                   "enum_map: null",
                                   "object_map: null",
                                   "list_map: null",
                                   "map_map: null",
                                   "recursive_class_map: null"};

  for (const char* field : expected_fields) {
    EXPECT_TRUE(strstr(str, field) != nullptr)
        << "Missing expected serialized field content: " << field;
  }

  // Also verify exact expected canonical string layout for empty
  // initialization.
  const char* exact_expected =
      "AllNullableTypes(a_nullable_bool: null, a_nullable_int: null, "
      "a_nullable_int64: null, a_nullable_double: null, a_nullable_byte_array: "
      "null, "
      "a_nullable4_byte_array: null, a_nullable8_byte_array: null, "
      "a_nullable_float_array: null, a_nullable_enum: null, "
      "another_nullable_enum: null, a_nullable_string: null, "
      "a_nullable_object: null, "
      "all_nullable_types: null, list: null, string_list: null, int_list: "
      "null, "
      "double_list: null, bool_list: null, enum_list: null, object_list: null, "
      "list_list: null, map_list: null, recursive_class_list: null, map: null, "
      "string_map: null, int_map: null, enum_map: null, object_map: null, "
      "list_map: null, map_map: null, recursive_class_map: null)";
  EXPECT_STREQ(str, exact_expected);

  g_free(str);
}

TEST(Constants, VerifyConstants) {
  EXPECT_STREQ(CORE_TESTS_PIGEON_TEST_A_STRING_CONSTANT, "stringConstantValue");
  EXPECT_STREQ(CORE_TESTS_PIGEON_TEST_A_STRING_CONSTANT_WITH_ESCAPES,
               "string\\\\$ConstantValue");
  EXPECT_EQ(CORE_TESTS_PIGEON_TEST_AN_INT_CONSTANT, 42);
  EXPECT_DOUBLE_EQ(CORE_TESTS_PIGEON_TEST_A_DOUBLE_CONSTANT, 3.14);
  EXPECT_TRUE(CORE_TESTS_PIGEON_TEST_A_BOOL_CONSTANT);
}
