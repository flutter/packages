// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#include <flutter/method_call.h>
#include <flutter/method_result_functions.h>
#include <flutter/standard_method_codec.h>
#include <gmock/gmock.h>
#include <gtest/gtest.h>
#include <windows.h>

#include <memory>
#include <optional>
#include <string>

#include "messages.h"
#include "mocks.h"
#include "video_player_plugin.h"

namespace video_player_windows {
namespace test {

namespace {

using flutter::EncodableMap;
using flutter::EncodableValue;
using ::testing::DoAll;
using ::testing::Pointee;
using ::testing::Return;
using ::testing::SetArgPointee;

}  // namespace

TEST(VideoPlayerPlugin, CanInitializeSuccessTrue) {
  std::unique_ptr<MockTextureRegistrar> texture_registrar_ =
      std::make_unique<MockTextureRegistrar>();
  std::unique_ptr<MockBinaryMessenger> messenger_ =
      std::make_unique<MockBinaryMessenger>();

  IDXGIFactory* pFactory = NULL;
  CreateDXGIFactory(__uuidof(IDXGIFactory), (void**)&pFactory);

  IDXGIAdapter* adapter = nullptr;
  pFactory->EnumAdapters(0, &adapter);

  VideoPlayerPlugin plugin(messenger_.get(), adapter, texture_registrar_.get());
  plugin.Initialize();

  std::string url =
      "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4";

  EXPECT_CALL(*texture_registrar_, RegisterTexture(_)).Times(1);

  ErrorOr<int64_t> result = plugin.Create(nullptr, &url, EncodableMap());

  ASSERT_FALSE(result.has_error());
  EXPECT_EQ(result.value(), 1000);
}

}  // namespace test
}  // namespace video_player_windows
