// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PLATFORM_TESTS_TEST_PLUGIN_WINDOWS_TEST_UTILS_FAKE_HOST_MESSENGER_H_
#define PLATFORM_TESTS_TEST_PLUGIN_WINDOWS_TEST_UTILS_FAKE_HOST_MESSENGER_H_

#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/message_codec.h>

#include <map>

namespace testing {

typedef std::function<void(const flutter::EncodableValue& reply)>
    HostMessageReply;

// A BinaryMessenger that allows tests to act as the engine to call host APIs.
class FakeHostMessenger : public flutter::BinaryMessenger {
 public:
  // Creates an messenger that can send and receive responses with the given
  // codec.
  FakeHostMessenger(
      const flutter::MessageCodec<flutter::EncodableValue>* codec);
  virtual ~FakeHostMessenger();

  // Calls the registered handler for the given channel, and calls reply_handler
  // with the response.
  //
  // This allows a test to simulate a message from the Dart side, exercising the
  // encoding and decoding logic generated for a host API.
  void SendHostMessage(const std::string& channel,
                       const flutter::EncodableValue& message,
                       HostMessageReply reply_handler);

  // flutter::BinaryMessenger:
  void Send(const std::string& channel, const uint8_t* message,
            size_t message_size,
            flutter::BinaryReply reply = nullptr) const override;
  void SetMessageHandler(const std::string& channel,
                         flutter::BinaryMessageHandler handler) override;

 private:
  const flutter::MessageCodec<flutter::EncodableValue>* codec_;
  std::map<std::string, flutter::BinaryMessageHandler> handlers_;
};

}  // namespace testing

#endif  // PLATFORM_TESTS_TEST_PLUGIN_WINDOWS_TEST_UTILS_FAKE_HOST_MESSENGER_H_
