// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_VIDEO_PLAYER_VIDEO_PLAYER_WINDOWS_WINDOWS_TEST_MOCKS_H_
#define PACKAGES_VIDEO_PLAYER_VIDEO_PLAYER_WINDOWS_WINDOWS_TEST_MOCKS_H_

#include <flutter/method_call.h>
#include <flutter/method_result_functions.h>
#include <flutter/standard_method_codec.h>
#include <flutter/texture_registrar.h>
#include <gmock/gmock.h>
#include <gtest/gtest.h>
#include <mfcaptureengine.h>

#include "video_player.h"

namespace video_player_windows {
namespace test {

namespace {

using flutter::EncodableMap;
using flutter::EncodableValue;
using ::testing::_;

class MockBinaryMessenger : public flutter::BinaryMessenger {
 public:
  ~MockBinaryMessenger() = default;

  MOCK_METHOD(void, Send,
              (const std::string& channel, const uint8_t* message,
               size_t message_size, flutter::BinaryReply reply),
              (const));

  MOCK_METHOD(void, SetMessageHandler,
              (const std::string& channel,
               flutter::BinaryMessageHandler handler),
              ());
};

class MockTextureRegistrar : public flutter::TextureRegistrar {
 public:
  MockTextureRegistrar() {
    ON_CALL(*this, RegisterTexture)
        .WillByDefault([this](flutter::TextureVariant* texture) -> int64_t {
          EXPECT_TRUE(texture);
          this->texture_ = texture;
          this->texture_id_ = 1000;
          return this->texture_id_;
        });

    // Deprecated pre-Flutter-3.4 version.
    ON_CALL(*this, UnregisterTexture(_))
        .WillByDefault([this](int64_t tid) -> bool {
          if (tid == this->texture_id_) {
            texture_ = nullptr;
            this->texture_id_ = -1;
            return true;
          }
          return false;
        });

    // Flutter 3.4+ version.
    ON_CALL(*this, UnregisterTexture(_, _))
        .WillByDefault(
            [this](int64_t tid, std::function<void()> callback) -> void {
              // Forward to the pre-3.4 implementation so that expectations can
              // be the same for all versions.
              this->UnregisterTexture(tid);
              if (callback) {
                callback();
              }
            });

    ON_CALL(*this, MarkTextureFrameAvailable)
        .WillByDefault([this](int64_t tid) -> bool {
          if (tid == this->texture_id_) {
            return true;
          }
          return false;
        });
  }

  ~MockTextureRegistrar() { texture_ = nullptr; }

  MOCK_METHOD(int64_t, RegisterTexture, (flutter::TextureVariant * texture),
              (override));

  // Pre-Flutter-3.4 version.
  MOCK_METHOD(bool, UnregisterTexture, (int64_t), (override));
  // Flutter 3.4+ version.
  // TODO(cbracken): Add an override annotation to this once 3.4+ is the
  // minimum version tested in CI.
  MOCK_METHOD(void, UnregisterTexture,
              (int64_t, std::function<void()> callback), ());
  MOCK_METHOD(bool, MarkTextureFrameAvailable, (int64_t), (override));

  int64_t texture_id_ = -1;
  flutter::TextureVariant* texture_ = nullptr;
};

}  // namespace
}  // namespace test
}  // namespace video_player_windows

#endif  // PACKAGES_VIDEO_PLAYER_VIDEO_PLAYER_WINDOWS_WINDOWS_TEST_MOCKS_H_
