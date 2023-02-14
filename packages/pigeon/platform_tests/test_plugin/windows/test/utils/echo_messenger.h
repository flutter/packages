// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PLATFORM_TESTS_TEST_PLUGIN_WINDOWS_TEST_UTILS_ECHO_MESSENGER_H_
#define PLATFORM_TESTS_TEST_PLUGIN_WINDOWS_TEST_UTILS_ECHO_MESSENGER_H_

#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/message_codec.h>

namespace testing {

// A BinaryMessenger that replies with the first argument sent to it.
class EchoMessenger : public flutter::BinaryMessenger {
 public:
  // Creates an echo messenger that expects MessageCalls encoded with the given
  // codec.
  EchoMessenger(const flutter::MessageCodec<flutter::EncodableValue>* codec);
  virtual ~EchoMessenger();

  // flutter::BinaryMessenger:
  void Send(const std::string& channel, const uint8_t* message,
            size_t message_size,
            flutter::BinaryReply reply = nullptr) const override;
  void SetMessageHandler(const std::string& channel,
                         flutter::BinaryMessageHandler handler) override;

 private:
  const flutter::MessageCodec<flutter::EncodableValue>* codec_;
};

}  // namespace testing

#endif  // PLATFORM_TESTS_TEST_PLUGIN_WINDOWS_TEST_UTILS_ECHO_MESSENGER_H_
