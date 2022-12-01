// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <gtest/gtest.h>

#include <optional>

#include "pigeon/nullable_returns.gen.h"
#include "test/utils/fake_host_messenger.h"

namespace nullable_returns_pigeontest {

namespace {
using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;
using testing::FakeHostMessenger;

class TestNullableArgHostApi : public NullableArgHostApi {
 public:
  TestNullableArgHostApi() {}
  virtual ~TestNullableArgHostApi() {}

 protected:
  ErrorOr<int64_t> Doit(const int64_t* x) override {
    return x == nullptr ? 42 : *x;
  }
};

class TestNullableReturnHostApi : public NullableReturnHostApi {
 public:
  TestNullableReturnHostApi(std::optional<int64_t> return_value)
      : value_(return_value) {}
  virtual ~TestNullableReturnHostApi() {}

 protected:
  ErrorOr<std::optional<int64_t>> Doit() override { return value_; }

 private:
  std::optional<int64_t> value_;
};

const EncodableValue& GetResult(const EncodableValue& pigeon_response) {
  return std::get<EncodableMap>(pigeon_response).at(EncodableValue("result"));
}
}  // namespace

TEST(NullableReturns, HostNullableArgNull) {
  FakeHostMessenger messenger(&NullableArgHostApi::GetCodec());
  TestNullableArgHostApi api;
  NullableArgHostApi::SetUp(&messenger, &api);

  int64_t result = 0;
  messenger.SendHostMessage("dev.flutter.pigeon.NullableArgHostApi.doit",
                            EncodableValue(EncodableList({EncodableValue()})),
                            [&result](const EncodableValue& reply) {
                              result = GetResult(reply).LongValue();
                            });

  EXPECT_EQ(result, 42);
}

TEST(NullableReturns, HostNullableArgNonNull) {
  FakeHostMessenger messenger(&NullableArgHostApi::GetCodec());
  TestNullableArgHostApi api;
  NullableArgHostApi::SetUp(&messenger, &api);

  int64_t result = 0;
  messenger.SendHostMessage("dev.flutter.pigeon.NullableArgHostApi.doit",
                            EncodableValue(EncodableList({EncodableValue(7)})),
                            [&result](const EncodableValue& reply) {
                              result = GetResult(reply).LongValue();
                            });

  EXPECT_EQ(result, 7);
}

TEST(NullableReturns, HostNullableReturnNull) {
  FakeHostMessenger messenger(&NullableReturnHostApi::GetCodec());
  TestNullableReturnHostApi api(std::nullopt);
  NullableReturnHostApi::SetUp(&messenger, &api);

  // Initialize to a non-null value to ensure that it's actually set to null,
  // rather than just never set.
  EncodableValue result(true);
  messenger.SendHostMessage(
      "dev.flutter.pigeon.NullableReturnHostApi.doit",
      EncodableValue(EncodableList({})),
      [&result](const EncodableValue& reply) { result = GetResult(reply); });

  EXPECT_TRUE(result.IsNull());
}

TEST(NullableReturns, HostNullableReturnNonNull) {
  FakeHostMessenger messenger(&NullableReturnHostApi::GetCodec());
  TestNullableReturnHostApi api(42);
  NullableReturnHostApi::SetUp(&messenger, &api);

  EncodableValue result;
  messenger.SendHostMessage(
      "dev.flutter.pigeon.NullableReturnHostApi.doit",
      EncodableValue(EncodableList({})),
      [&result](const EncodableValue& reply) { result = GetResult(reply); });

  EXPECT_FALSE(result.IsNull());
  EXPECT_EQ(result.LongValue(), 42);
}

// TODO(stuartmorgan): Add FlutterApi versions of the tests.

}  // namespace nullable_returns_pigeontest
