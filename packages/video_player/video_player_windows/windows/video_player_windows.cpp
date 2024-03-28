// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#include "include/video_player_windows/video_player_windows.h"

#include <flutter/plugin_registrar_windows.h>

#include "video_player_plugin.h"

void VideoPlayerWindowsRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  video_player_windows::VideoPlayerPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
