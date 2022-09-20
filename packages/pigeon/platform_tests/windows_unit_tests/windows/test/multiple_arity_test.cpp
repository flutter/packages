// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <gtest/gtest.h>

#include "test/multiple_arity.g.h"
#include "test/utils/fake_host_messenger.h"

namespace multiple_arity_pigeontest {

namespace {
using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;
using testing::FakeHostMessenger;

class TestHostApi : public MultipleArityHostApi {
 public:
  TestHostApi() {}
  virtual ~TestHostApi() {}

 protected:
  ErrorOr<int64_t> Subtract(int64_t x, int64_t y) override { return x - y; }
};

const EncodableValue& GetResult(const EncodableValue& pigeon_response) {
  return std::get<EncodableMap>(pigeon_response).at(EncodableValue("result"));
}
}  // namespace

TEST(MultipleArity, HostSimple) {
  FakeHostMessenger messenger(&MultipleArityHostApi::GetCodec());
  TestHostApi api;
  MultipleArityHostApi::SetUp(&messenger, &api);

  int64_t result = 0;
  messenger.SendHostMessage("dev.flutter.pigeon.MultipleArityHostApi.subtract",
                            EncodableValue(EncodableList({
                                EncodableValue(30),
                                EncodableValue(10),
                            })),
                            [&result](const EncodableValue& reply) {
                              result = GetResult(reply).LongValue();
                            });

  EXPECT_EQ(result, 20);
}

// TODO(stuartmorgan): Add a FlutterApi version of the test.

}  // namespace multiple_arity_pigeontest
