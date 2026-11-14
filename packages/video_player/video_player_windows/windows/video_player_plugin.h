// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_VIDEO_PLAYER_WINDOWS_VIDEO_PLAYER_PLUGIN_H_
#define PACKAGES_VIDEO_PLAYER_WINDOWS_VIDEO_PLAYER_PLUGIN_H_

#include <flutter/plugin_registrar_windows.h>

#include <cstdint>
#include <functional>
#include <map>
#include <memory>
#include <optional>
#include <string>

#include "media_player.h"
#include "messages.g.h"

namespace video_player_windows {

struct EventDispatcher;
struct PlayerEntry;

class VideoPlayerPlugin : public flutter::Plugin, public WindowsVideoPlayerApi {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);
  explicit VideoPlayerPlugin(flutter::PluginRegistrarWindows* registrar);
  ~VideoPlayerPlugin() override;

  std::optional<FlutterError> Initialize() override;
  ErrorOr<int64_t> Create(const std::string& source,
                          const std::string* network_source,
                          const std::string* network_relay) override;
  std::optional<FlutterError> Dispose(int64_t player_id) override;
  std::optional<FlutterError> Play(int64_t player_id) override;
  std::optional<FlutterError> Pause(int64_t player_id) override;
  std::optional<FlutterError> SetLooping(int64_t player_id,
                                         bool looping) override;
  std::optional<FlutterError> SetVolume(int64_t player_id,
                                        double volume) override;
  std::optional<FlutterError> SetPlaybackSpeed(int64_t player_id,
                                               double speed) override;
  std::optional<FlutterError> SeekTo(int64_t player_id,
                                     int64_t milliseconds) override;
  ErrorOr<int64_t> GetPosition(int64_t player_id) override;
  ErrorOr<flutter::EncodableList> GetTracks(int64_t player_id,
                                            bool audio) override;
  std::optional<FlutterError> SelectTrack(int64_t player_id, bool audio,
                                          const int64_t* track_id) override;
  std::optional<FlutterError> SetPreventsDisplaySleep(int64_t player_id,
                                                      bool prevents) override;

 private:
  static LRESULT CALLBACK WindowProc(HWND window, UINT message, WPARAM wparam,
                                     LPARAM lparam);
  void DrainEvents();
  std::optional<FlutterError> WithPlayer(
      int64_t id, std::function<HRESULT(MediaPlayer&)> operation);
  flutter::PluginRegistrarWindows* registrar_;
  std::shared_ptr<EventDispatcher> dispatcher_;
  std::map<int64_t, std::shared_ptr<PlayerEntry>> players_;
  HWND window_ = nullptr;
};

}  // namespace video_player_windows

#endif
