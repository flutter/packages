// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#ifndef PACKAGES_VIDEO_PLAYER_VIDEO_PLAYER_WINDOWS_WINDOWS_VIDEO_PLAYER_PLUGIN_H_
#define PACKAGES_VIDEO_PLAYER_VIDEO_PLAYER_WINDOWS_WINDOWS_VIDEO_PLAYER_PLUGIN_H_

#include <flutter/plugin_registrar_windows.h>
#include <shobjidl.h>
#include <wil/stl.h>
#include <wil/win32_helpers.h>
#include <wincodec.h>
#include <windows.h>

#include <map>
#include <memory>
#include <queue>
#include <sstream>
#include <string>

#include "messages.h"
#include "video_player.h"

#undef GetCurrentTime

#define WM_RUN_DELEGATE (WM_USER + 101)

namespace video_player_windows {

using FlutterRootWindowProvider = std::function<HWND()>;
using WindowProcDelegate = std::function<std::optional<LRESULT>(
    HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam)>;
using WindowProcDelegateRegistrator =
    std::function<int(WindowProcDelegate delegate)>;
using WindowProcDelegateUnregistrator = std::function<void(int proc_id)>;

class VideoPlayerPlugin : public flutter::Plugin, public WindowsVideoPlayerApi {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  // The function to call to get the root window.
  static FlutterRootWindowProvider get_root_window_;

  // A queue of callbacks to run on the main thread.
  static std::queue<std::function<void()>> callbacks;

  // Runs the given callback on the main thread.
  static void RunOnMainThread(std::function<void()> callback);

  VideoPlayerPlugin(WindowProcDelegateRegistrator registrator,
                    WindowProcDelegateUnregistrator unregistrator,
                    FlutterRootWindowProvider window_provider,
                    flutter::BinaryMessenger* messenger, IDXGIAdapter* adapter,
                    flutter::TextureRegistrar* texture_registry);

  virtual ~VideoPlayerPlugin();

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

  // The registrar for this plugin, for registering top-level WindowProc
  // delegates.
  WindowProcDelegateRegistrator win_proc_delegate_registrator_;
  WindowProcDelegateUnregistrator win_proc_delegate_unregistrator_;

  // The ID of the WindowProc delegate registration.
  int window_proc_id_ = -1;

  // The texture registrar for this plugin, for registering textures.
  flutter::TextureRegistrar* texture_registry_;

  // The messenger for communicating with the Flutter engine.
  flutter::BinaryMessenger* messenger_;

  // A reference to Flutter's IDXGIAdapter, used to create the internal
  // ID3D11Device.
  IDXGIAdapter* adapter_;

  // Called for top-level WindowProc delegation.
  std::optional<LRESULT> HandleWindowProc(HWND hwnd, UINT message,
                                          WPARAM wparam, LPARAM lparam);
};

}  // namespace video_player_windows

#endif  // PACKAGES_VIDEO_PLAYER_VIDEO_PLAYER_WINDOWS_WINDOWS_VIDEO_PLAYER_PLUGIN_H_