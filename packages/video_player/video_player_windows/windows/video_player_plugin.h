// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <flutter/plugin_registrar_windows.h>
#include <shobjidl.h>
#include <wil/stl.h>
#include <wil/win32_helpers.h>
#include <wincodec.h>
#include <windows.h>

#include <map>
#include <memory>
#include <sstream>
#include <string>

#include "messages.h"
#include "video_player.h"

#undef GetCurrentTime

namespace video_player_windows {

class VideoPlayerPlugin : public flutter::Plugin, public WindowsVideoPlayerApi {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  VideoPlayerPlugin(flutter::BinaryMessenger* messenger, IDXGIAdapter* adapter,
                    flutter::TextureRegistrar* texture_registry);

  virtual ~VideoPlayerPlugin() = default;

  // WindowsVideoPlayerApi implementation.
  std::optional<FlutterError> Initialize() override;
  ErrorOr<int64_t> Create(const std::string* asset, const std::string* uri,
                          const flutter::EncodableMap& http_headers) override;
  std::optional<FlutterError> Dispose(int64_t texture_id) override;
  std::optional<FlutterError> SetLooping(int64_t texture_id,
                                         bool is_looping) override;
  std::optional<FlutterError> SetVolume(int64_t texture_id,
                                        double volume) override;
  std::optional<FlutterError> SetPlaybackSpeed(int64_t texture_id,
                                               double speed) override;
  std::optional<FlutterError> Play(int64_t texture_id) override;
  ErrorOr<int64_t> GetPosition(int64_t texture_id) override;
  std::optional<FlutterError> SeekTo(int64_t texture_id,
                                     int64_t position) override;
  std::optional<FlutterError> Pause(int64_t texture_id) override;

 private:
  // A list of all the video players instantiated by this plugin.
  std::map<int64_t, std::unique_ptr<VideoPlayer>> video_players_;

  // The registrar for this plugin, for registering textures.
  flutter::TextureRegistrar* texture_registry_;

  // The messenger for communicating with the Flutter engine.
  flutter::BinaryMessenger* messenger_;

  // A reference to Flutter's IDXGIAdapter, used to create the internal
  // ID3D11Device.
  IDXGIAdapter* adapter_;
};

}  // namespace video_player_windows
