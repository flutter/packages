// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "fake_host_messenger.h"

#include <flutter/encodable_value.h>
#include <flutter/message_codec.h>

#include <memory>
#include <vector>

namespace testing {

FakeHostMessenger::FakeHostMessenger(
    const flutter::MessageCodec<flutter::EncodableValue>* codec)
    : codec_(codec) {}
FakeHostMessenger::~FakeHostMessenger() {}

void FakeHostMessenger::SendHostMessage(const std::string& channel,

                                        const flutter::EncodableValue& message,
                                        HostMessageReply reply_handler) {
  const auto* codec = codec_;
  flutter::BinaryReply binary_handler = [reply_handler, codec, channel](
                                            const uint8_t* reply_data,
                                            size_t reply_size) {
    std::unique_ptr<flutter::EncodableValue> reply =
        codec->DecodeMessage(reply_data, reply_size);
    reply_handler(*reply);
  };

  std::unique_ptr<std::vector<uint8_t>> data = codec_->EncodeMessage(message);
  handlers_[channel](data->data(), data->size(), std::move(binary_handler));
}

void FakeHostMessenger::Send(const std::string& channel, const uint8_t* message,
                             size_t message_size,
                             flutter::BinaryReply reply) const {}

void FakeHostMessenger::SetMessageHandler(
    const std::string& channel, flutter::BinaryMessageHandler handler) {
  handlers_[channel] = std::move(handler);
}

}  // namespace testing
