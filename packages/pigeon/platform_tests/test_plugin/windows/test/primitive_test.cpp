// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <gtest/gtest.h>

#include "pigeon/primitive.gen.h"
#include "test/utils/fake_host_messenger.h"

namespace primitive_pigeontest {

namespace {
using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;
using testing::FakeHostMessenger;

class TestHostApi : public PrimitiveHostApi {
 public:
  TestHostApi() {}
  virtual ~TestHostApi() {}

 protected:
  ErrorOr<int64_t> AnInt(int64_t value) override { return value; }
  ErrorOr<bool> ABool(bool value) override { return value; }
  ErrorOr<std::string> AString(const std::string& value) override {
    return std::string(value);
  }
  ErrorOr<double> ADouble(double value) override { return value; }
  ErrorOr<flutter::EncodableMap> AMap(
      const flutter::EncodableMap& value) override {
    return value;
  }
  ErrorOr<flutter::EncodableList> AList(
      const flutter::EncodableList& value) override {
    return value;
  }
  ErrorOr<std::vector<int32_t>> AnInt32List(
      const std::vector<int32_t>& value) override {
    return value;
  }
  ErrorOr<flutter::EncodableList> ABoolList(
      const flutter::EncodableList& value) override {
    return value;
  }
  ErrorOr<flutter::EncodableMap> AStringIntMap(
      const flutter::EncodableMap& value) override {
    return value;
  }
};

const EncodableValue& GetResult(const EncodableValue& pigeon_response) {
  return std::get<EncodableMap>(pigeon_response).at(EncodableValue("result"));
}
}  // namespace

TEST(Primitive, HostInt) {
  FakeHostMessenger messenger(&PrimitiveHostApi::GetCodec());
  TestHostApi api;
  PrimitiveHostApi::SetUp(&messenger, &api);

  int64_t result = 0;
  messenger.SendHostMessage("dev.flutter.pigeon.PrimitiveHostApi.anInt",
                            EncodableValue(EncodableList({EncodableValue(7)})),
                            [&result](const EncodableValue& reply) {
                              result = GetResult(reply).LongValue();
                            });

  EXPECT_EQ(result, 7);
}

TEST(Primitive, HostBool) {
  FakeHostMessenger messenger(&PrimitiveHostApi::GetCodec());
  TestHostApi api;
  PrimitiveHostApi::SetUp(&messenger, &api);

  bool result = false;
  messenger.SendHostMessage(
      "dev.flutter.pigeon.PrimitiveHostApi.aBool",
      EncodableValue(EncodableList({EncodableValue(true)})),
      [&result](const EncodableValue& reply) {
        result = std::get<bool>(GetResult(reply));
      });

  EXPECT_EQ(result, true);
}

TEST(Primitive, HostDouble) {
  FakeHostMessenger messenger(&PrimitiveHostApi::GetCodec());
  TestHostApi api;
  PrimitiveHostApi::SetUp(&messenger, &api);

  double result = 0.0;
  messenger.SendHostMessage(
      "dev.flutter.pigeon.PrimitiveHostApi.aDouble",
      EncodableValue(EncodableList({EncodableValue(3.0)})),
      [&result](const EncodableValue& reply) {
        result = std::get<double>(GetResult(reply));
      });

  EXPECT_EQ(result, 3.0);
}

TEST(Primitive, HostString) {
  FakeHostMessenger messenger(&PrimitiveHostApi::GetCodec());
  TestHostApi api;
  PrimitiveHostApi::SetUp(&messenger, &api);

  std::string result;
  messenger.SendHostMessage(
      "dev.flutter.pigeon.PrimitiveHostApi.aString",
      EncodableValue(EncodableList({EncodableValue("hello")})),
      [&result](const EncodableValue& reply) {
        result = std::get<std::string>(GetResult(reply));
      });

  EXPECT_EQ(result, "hello");
}

TEST(Primitive, HostList) {
  FakeHostMessenger messenger(&PrimitiveHostApi::GetCodec());
  TestHostApi api;
  PrimitiveHostApi::SetUp(&messenger, &api);

  EncodableList result;
  messenger.SendHostMessage(
      "dev.flutter.pigeon.PrimitiveHostApi.aList",
      EncodableValue(EncodableList({EncodableValue(EncodableList({1, 2, 3}))})),
      [&result](const EncodableValue& reply) {
        result = std::get<EncodableList>(GetResult(reply));
      });

  EXPECT_EQ(result.size(), 3);
  EXPECT_EQ(result[2].LongValue(), 3);
}

TEST(Primitive, HostMap) {
  FakeHostMessenger messenger(&PrimitiveHostApi::GetCodec());
  TestHostApi api;
  PrimitiveHostApi::SetUp(&messenger, &api);

  EncodableMap result;
  messenger.SendHostMessage(
      "dev.flutter.pigeon.PrimitiveHostApi.aMap",
      EncodableValue(EncodableList({EncodableValue(EncodableMap({
          {EncodableValue("foo"), EncodableValue("bar")},
      }))})),
      [&result](const EncodableValue& reply) {
        result = std::get<EncodableMap>(GetResult(reply));
      });

  EXPECT_EQ(result.size(), 1);
  EXPECT_EQ(result[EncodableValue("foo")], EncodableValue("bar"));
}

// TODO(stuartmorgan): Add FlutterApi versions of the tests.

}  // namespace primitive_pigeontest
