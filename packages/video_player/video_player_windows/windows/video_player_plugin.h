// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <flutter/event_channel.h>
#include <flutter/event_stream_handler.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_codec_serializer.h>
#include <flutter/standard_method_codec.h>
#include <shobjidl.h>
#include <wil/stl.h>
#include <wil/win32_helpers.h>
#include <wincodec.h>
#include <windows.h>

#include <map>
#include <memory>
#include <sstream>
#include <string>

#include "include/video_player_windows/video_player_windows.h"
#include "messages.h"
#include "video_player.h"

#undef GetCurrentTime

namespace video_player_windows {

class VideoPlayerPlugin : public flutter::Plugin, public WindowsVideoPlayerApi {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  VideoPlayerPlugin(flutter::BinaryMessenger* messenger, HWND window,
                    IDXGIAdapter* adapter,
                    flutter::TextureRegistrar* textureRegistry);

  std::optional<FlutterError> Initialize() override;
  ErrorOr<int64_t> Create(const std::string* asset, const std::string* uri,
                          const std::string* package_name,
                          const std::string* format_hint,
                          const flutter::EncodableMap& http_headers) override;
  std::optional<FlutterError> Dispose(int64_t texture_id) override;
  std::optional<FlutterError> SetLooping(int64_t texture_id,
                                         bool is_looping) override;
  std::optional<FlutterError> SetVolume(int64_t texture_id,
                                        double volume) override;
  std::optional<FlutterError> SetPlaybackSpeed(int64_t texture_id,
                                               double speed) override;
  std::optional<FlutterError> Play(int64_t texture_id) override;
  ErrorOr<int64_t> Position(int64_t texture_id) override;
  std::optional<FlutterError> SeekTo(int64_t texture_id,
                                     int64_t position) override;
  std::optional<FlutterError> Pause(int64_t texture_id) override;
  std::optional<FlutterError> SetMixWithOthers(bool mix_with_others) override;

  virtual ~VideoPlayerPlugin();

 private:
  std::map<int64_t, std::unique_ptr<VideoPlayer>> videoPlayers;
  bool mixWithOthers;

  flutter::TextureRegistrar* m_textureRegistry;
  flutter::BinaryMessenger* m_messenger;
  HWND m_window;
  IDXGIAdapter* m_adapter;
};

}  // namespace video_player_windows
