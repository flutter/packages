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

#include "pigeon/message.gen.h"

namespace test_plugin {
namespace test {

namespace {

using flutter::EncodableMap;
using flutter::EncodableValue;
using ::testing::ByMove;
using ::testing::DoAll;
using ::testing::Pointee;
using ::testing::Return;
using ::testing::SetArgPointee;
using namespace message_pigeontest;

class MockMethodResult : public flutter::MethodResult<> {
 public:
  ~MockMethodResult() = default;

  MOCK_METHOD(void, SuccessInternal, (const EncodableValue* result),
              (override));
  MOCK_METHOD(void, ErrorInternal,
              (const std::string& error_code, const std::string& error_message,
               const EncodableValue* details),
              (override));
  MOCK_METHOD(void, NotImplementedInternal, (), (override));
};

class MockBinaryMessenger : public flutter::BinaryMessenger {
 public:
  ~MockBinaryMessenger() = default;

  MOCK_METHOD(void, Send,
              (const std::string& channel, const uint8_t* message,
               size_t message_size, flutter::BinaryReply reply),
              (override, const));
  MOCK_METHOD(void, SetMessageHandler,
              (const std::string& channel,
               flutter::BinaryMessageHandler handler),
              (override));
};

class MockApi : public MessageApi {
 public:
  ~MockApi() = default;

  MOCK_METHOD(std::optional<FlutterError>, Initialize, (), (override));
  MOCK_METHOD(ErrorOr<MessageSearchReply>, Search,
              (const MessageSearchRequest&), (override));
};

class Writer : public flutter::ByteStreamWriter {
 public:
  void WriteByte(uint8_t byte) override { data_.push_back(byte); }
  void WriteBytes(const uint8_t* bytes, size_t length) override {
    for (size_t i = 0; i < length; ++i) {
      data_.push_back(bytes[i]);
    }
  }
  void WriteAlignment(uint8_t alignment) override {
    while (data_.size() % alignment != 0) {
      data_.push_back(0);
    }
  }
  std::vector<uint8_t> data_;
};
}  // namespace

TEST(PigeonTests, CallInitialize) {
  MockBinaryMessenger mock_messenger;
  MockApi mock_api;
  flutter::BinaryMessageHandler handler;
  EXPECT_CALL(
      mock_messenger,
      SetMessageHandler(
          "dev.flutter.pigeon.pigeon_integration_tests.MessageApi.initialize",
          testing::_))
      .Times(1)
      .WillOnce(testing::SaveArg<1>(&handler));
  EXPECT_CALL(
      mock_messenger,
      SetMessageHandler(
          "dev.flutter.pigeon.pigeon_integration_tests.MessageApi.search",
          testing::_))
      .Times(1);
  EXPECT_CALL(mock_api, Initialize());
  MessageApi::SetUp(&mock_messenger, &mock_api);
  bool did_call_reply = false;
  flutter::BinaryReply reply = [&did_call_reply](const uint8_t* data,
                                                 size_t size) {
    did_call_reply = true;
  };
  handler(nullptr, 0, reply);
  EXPECT_TRUE(did_call_reply);
}

TEST(PigeonTests, CallSearch) {
  MockBinaryMessenger mock_messenger;
  MockApi mock_api;
  flutter::BinaryMessageHandler handler;
  EXPECT_CALL(
      mock_messenger,
      SetMessageHandler(
          "dev.flutter.pigeon.pigeon_integration_tests.MessageApi.initialize",
          testing::_))
      .Times(1);
  EXPECT_CALL(
      mock_messenger,
      SetMessageHandler(
          "dev.flutter.pigeon.pigeon_integration_tests.MessageApi.search",
          testing::_))
      .Times(1)
      .WillOnce(testing::SaveArg<1>(&handler));
  EXPECT_CALL(mock_api, Search(testing::_))
      .WillOnce(
          Return(ByMove(ErrorOr<MessageSearchReply>(MessageSearchReply()))));
  MessageApi::SetUp(&mock_messenger, &mock_api);
  bool did_call_reply = false;
  flutter::BinaryReply reply = [&did_call_reply](const uint8_t* data,
                                                 size_t size) {
    did_call_reply = true;
  };
  MessageSearchRequest request;
  Writer writer;
  flutter::EncodableList args;
  args.push_back(flutter::CustomEncodableValue(request));
  PigeonInternalCodecSerializer::GetInstance().WriteValue(args, &writer);
  handler(writer.data_.data(), writer.data_.size(), reply);
  EXPECT_TRUE(did_call_reply);
}

}  // namespace test
}  // namespace test_plugin
