// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#include <flutter/method_call.h>
#include <flutter/method_result_functions.h>
#include <flutter/standard_method_codec.h>
#include <gmock/gmock.h>
#include <gtest/gtest.h>

#include <memory>
#include <string>

#include "windows_unit_tests_plugin.h"

namespace windows_unit_tests {
namespace test {

namespace {

using flutter::EncodableMap;
using flutter::EncodableValue;
using ::testing::DoAll;
using ::testing::Pointee;
using ::testing::Return;
using ::testing::SetArgPointee;

class MockMethodResult : public flutter::MethodResult<> {
 public:
  MOCK_METHOD(void, SuccessInternal, (const EncodableValue* result),
              (override));
  MOCK_METHOD(void, ErrorInternal,
              (const std::string& error_code, const std::string& error_message,
               const EncodableValue* details),
              (override));
  MOCK_METHOD(void, NotImplementedInternal, (), (override));
};

}  // namespace

TEST(PigeonTests, Placeholder) {
  std::unique_ptr<MockMethodResult> result =
      std::make_unique<MockMethodResult>();

  // Expect a success response.
  EXPECT_CALL(*result, SuccessInternal(Pointee(EncodableValue(true))));

  WindowsUnitTestsPlugin plugin;
  plugin.HandleMethodCall(flutter::MethodCall<>("placeholder", nullptr),
                          std::move(result));
}

}  // namespace test
}  // namespace windows_unit_tests
