// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "echo_messenger.h"

#include <flutter/encodable_value.h>
#include <flutter/message_codec.h>

namespace testing {

EchoMessenger::EchoMessenger(
    const flutter::MessageCodec<flutter::EncodableValue>* codec)
    : codec_(codec) {}
EchoMessenger::~EchoMessenger() {}

// flutter::BinaryMessenger:
void EchoMessenger::Send(const std::string& channel, const uint8_t* message,
                         size_t message_size,
                         flutter::BinaryReply reply) const {
  std::unique_ptr<flutter::EncodableValue> arg_value =
      codec_->DecodeMessage(message, message_size);
  const auto& args = std::get<flutter::EncodableList>(*arg_value);
  std::unique_ptr<std::vector<uint8_t>> reply_data =
      codec_->EncodeMessage(args[0]);
  reply(reply_data->data(), reply_data->size());
}

void EchoMessenger::SetMessageHandler(const std::string& channel,
                                      flutter::BinaryMessageHandler handler) {}

}  // namespace testing
