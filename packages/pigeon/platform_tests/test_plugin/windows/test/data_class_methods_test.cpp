// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <gtest/gtest.h>

#include <cmath>
#include <sstream>

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
  flutter::EncodableList list = {flutter::EncodableValue(NAN)};
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

TEST(EqualityTests, NestedZeroListEquality) {
  flutter::EncodableList list1 = {flutter::EncodableValue(0.0)};
  AllNullableTypes all1;
  all1.set_double_list(list1);

  flutter::EncodableList list2 = {flutter::EncodableValue(-0.0)};
  AllNullableTypes all2;
  all2.set_double_list(list2);

  EXPECT_EQ(all1, all2);
}

TEST(EqualityTests, ZeroMapKeyEquality) {
  std::map<flutter::EncodableValue, flutter::EncodableValue> map1;
  map1[flutter::EncodableValue(0.0)] = flutter::EncodableValue("a");
  AllNullableTypes all1;
  all1.set_map(map1);

  std::map<flutter::EncodableValue, flutter::EncodableValue> map2;
  map2[flutter::EncodableValue(-0.0)] = flutter::EncodableValue("a");
  AllNullableTypes all2;
  all2.set_map(map2);

  EXPECT_EQ(all1, all2);
}

TEST(EqualityTests, ZeroMapValueEquality) {
  std::map<flutter::EncodableValue, flutter::EncodableValue> map1;
  map1[flutter::EncodableValue("a")] = flutter::EncodableValue(0.0);
  AllNullableTypes all1;
  all1.set_map(map1);

  std::map<flutter::EncodableValue, flutter::EncodableValue> map2;
  map2[flutter::EncodableValue("a")] = flutter::EncodableValue(-0.0);
  AllNullableTypes all2;
  all2.set_map(map2);

  EXPECT_EQ(all1, all2);
}

TEST(SerializationTests, StreamOutputSnapshot) {
  flutter::EncodableList list;
  list.push_back(flutter::EncodableValue("hello"));
  list.push_back(flutter::EncodableValue(42));

  TestMessage msg;
  msg.set_test_list(list);

  std::stringstream ss;
  ss << msg;

  EXPECT_EQ(ss.str(), "TestMessage(test_list: [\"hello\", 42])");
}

// On Windows, C++ stream serialization and std::map key traversal are
// completely deterministic and stable, allowing us to validate the entire
// output with a single exact string.
TEST(SerializationTests, StreamOutputFullSnapshot) {
  AllNullableTypes everything;
  everything.set_a_nullable_bool(true);
  everything.set_a_nullable_int(1);
  everything.set_a_nullable_double(2.0);
  everything.set_a_nullable_string("123");

  flutter::EncodableList list;
  list.push_back(flutter::EncodableValue("string"));
  list.push_back(flutter::EncodableValue(1));
  everything.set_list(list);

  flutter::EncodableMap map;
  map[flutter::EncodableValue("hello")] = flutter::EncodableValue("you");
  everything.set_string_map(map);

  std::stringstream ss;
  ss << everything;

  EXPECT_EQ(
      ss.str(),
      "AllNullableTypes(a_nullable_bool: true, a_nullable_int: 1, "
      "a_nullable_int64: null, a_nullable_double: 2, a_nullable_byte_array: "
      "null, a_nullable4_byte_array: null, a_nullable8_byte_array: null, "
      "a_nullable_float_array: null, a_nullable_enum: null, "
      "another_nullable_enum: null, a_nullable_string: 123, a_nullable_object: "
      "null, all_nullable_types: null, list: [\"string\", 1], string_list: "
      "null, int_list: null, double_list: null, bool_list: null, enum_list: "
      "null, object_list: null, list_list: null, map_list: null, "
      "recursive_class_list: null, map: null, string_map: {\"hello\": "
      "\"you\"}, "
      "int_map: null, enum_map: null, object_map: null, list_map: null, "
      "map_map: null, recursive_class_map: null)");
}

TEST(ConstantTests, VerifyConstants) {
  EXPECT_EQ(std::string(aStringConstant), "stringConstantValue");
  EXPECT_EQ(std::string(aStringConstantWithEscapes),
            "string\\\\$ConstantValue");
  EXPECT_EQ(anIntConstant, 42);
  EXPECT_DOUBLE_EQ(aDoubleConstant, 3.14);
  EXPECT_EQ(aBoolConstant, true);
}

}  // namespace test
}  // namespace test_plugin
