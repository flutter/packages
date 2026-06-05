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

  EXPECT_EQ(ss.str(), "TestMessage(testList: [\"hello\", 42])");
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
      "AllNullableTypes(aNullableBool: true, aNullableInt: 1, aNullableInt64: "
      "null, "
      "aNullableDouble: 2, aNullableByteArray: null, aNullable4ByteArray: "
      "null, "
      "aNullable8ByteArray: null, aNullableFloatArray: null, aNullableEnum: "
      "null, "
      "anotherNullableEnum: null, aNullableString: 123, aNullableObject: null, "
      "allNullableTypes: null, list: [\"string\", 1], stringList: null, "
      "intList: null, "
      "doubleList: null, boolList: null, enumList: null, objectList: null, "
      "listList: null, "
      "mapList: null, recursiveClassList: null, map: null, stringMap: "
      "{\"hello\": \"you\"}, "
      "intMap: null, enumMap: null, objectMap: null, listMap: null, mapMap: "
      "null, "
      "recursiveClassMap: null)");
}

}  // namespace test
}  // namespace test_plugin
