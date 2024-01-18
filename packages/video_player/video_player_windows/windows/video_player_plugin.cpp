// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "video_player_plugin.h"

#include <flutter/plugin_registrar_windows.h>
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

// static
void VideoPlayerPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  flutter::BinaryMessenger* messenger = registrar->messenger();
  HWND window = registrar->GetView()->GetNativeWindow();
  IDXGIAdapter* adapter = registrar->GetView()->GetGraphicsAdapter();

  auto plugin = std::make_unique<VideoPlayerPlugin>(
      messenger, window, adapter, registrar->texture_registrar());
  WindowsVideoPlayerApi::SetUp(messenger, plugin.get());
  registrar->AddPlugin(std::move(plugin));
}

VideoPlayerPlugin::VideoPlayerPlugin(
    flutter::BinaryMessenger* messenger, HWND window, IDXGIAdapter* adapter,
    flutter::TextureRegistrar* texture_registry)
    : messenger_(messenger),
      window_(window),
      adapter_(adapter),
      texture_registry_(texture_registry) {}

std::optional<FlutterError> VideoPlayerPlugin::Initialize() {
  for (int i = 0; i < video_players_.size(); i++) {
    video_players_.at((int64_t)i)->Dispose();
  }
  video_players_.clear();

  return std::nullopt;
}

ErrorOr<int64_t> VideoPlayerPlugin::Create(
    const std::string* asset, const std::string* uri,
    const flutter::EncodableMap& http_headers) {
  std::unique_ptr<VideoPlayer> player{nullptr};
  if (asset && !asset->empty()) {
    std::string asset_path = *asset;

    try {
      auto module_path = wil::GetModuleFileNameW<std::wstring>(nullptr);

      size_t found = module_path.find_last_of(L"/\\");
      module_path = module_path.substr(0, found);

      std::wstring final_asset_path =
          module_path + L"/data/flutter_assets/" +
          std::wstring(asset_path.begin(), asset_path.end());

      player = std::make_unique<VideoPlayer>(
          adapter_, window_, final_asset_path, flutter::EncodableMap());
    } catch (std::exception& e) {
      return FlutterError("asset_load_failed", e.what());
    }
  } else if (uri && !uri->empty()) {
    try {
      std::string asset_path = *uri;
      player = std::make_unique<VideoPlayer>(
          adapter_, window_, std::wstring(asset_path.begin(), asset_path.end()),
          http_headers);
    } catch (std::exception& e) {
      return FlutterError("uri_load_failed", e.what());
    }
  } else {
    return FlutterError("not_implemented", "Set either an asset or a uri");
  }

  player->Init(
      messenger_,
      [this](int64_t texture_id) {
        texture_registry_->MarkTextureFrameAvailable(texture_id);
      },
      texture_registry_);

  auto texture_id = player->GetTextureId();

  video_players_.insert(
      std::make_pair(player->GetTextureId(), std::move(player)));

  return texture_id;
}

std::optional<FlutterError> VideoPlayerPlugin::Dispose(int64_t texture_id) {
  auto search_player = video_players_.find(texture_id);
  if (search_player == video_players_.end()) {
    return FlutterError("player_not_found", "This player ID was not found");
  }
  if (search_player->second->IsValid()) {
    search_player->second->Dispose();
    video_players_.erase(texture_id);
  }

  return std::nullopt;
}

std::optional<FlutterError> VideoPlayerPlugin::SetLooping(int64_t texture_id,
                                                          bool is_looping) {
  auto search_player = video_players_.find(texture_id);
  if (search_player == video_players_.end()) {
    return FlutterError("player_not_found", "This player ID was not found");
  }
  if (search_player->second->IsValid()) {
    search_player->second->SetLooping(is_looping);
  }

  return std::nullopt;
}

std::optional<FlutterError> VideoPlayerPlugin::SetVolume(int64_t texture_id,
                                                         double volume) {
  auto search_player = video_players_.find(texture_id);
  if (search_player == video_players_.end()) {
    return FlutterError("player_not_found", "This player ID was not found");
  }
  if (search_player->second->IsValid()) {
    search_player->second->SetVolume(volume);
  }

  return std::nullopt;
}

std::optional<FlutterError> VideoPlayerPlugin::SetPlaybackSpeed(
    int64_t texture_id, double speed) {
  auto search_player = video_players_.find(texture_id);
  if (search_player == video_players_.end()) {
    return FlutterError("player_not_found", "This player ID was not found");
  }
  if (search_player->second->IsValid()) {
    search_player->second->SetPlaybackSpeed(speed);
  }

  return std::nullopt;
}

std::optional<FlutterError> VideoPlayerPlugin::Play(int64_t texture_id) {
  auto search_player = video_players_.find(texture_id);
  if (search_player == video_players_.end()) {
    return FlutterError("player_not_found", "This player ID was not found");
  }
  if (search_player->second->IsValid()) {
    search_player->second->Play();
  }

  return std::nullopt;
}

ErrorOr<int64_t> VideoPlayerPlugin::Position(int64_t texture_id) {
  auto search_player = video_players_.find(texture_id);
  int64_t position = 0;
  if (search_player != video_players_.end()) {
    auto& player = search_player->second;
    if (player->IsValid()) {
      position = player->GetPosition();
      player->SendBufferingUpdate();
    }
  }
  return position;
}

std::optional<FlutterError> VideoPlayerPlugin::SeekTo(int64_t texture_id,
                                                      int64_t position) {
  auto search_player = video_players_.find(texture_id);
  if (search_player == video_players_.end()) {
    return FlutterError("player_not_found", "This player ID was not found");
  }
  if (search_player->second->IsValid()) {
    search_player->second->SeekTo(position);
  }

  return std::nullopt;
}

std::optional<FlutterError> VideoPlayerPlugin::Pause(int64_t texture_id) {
  auto search_player = video_players_.find(texture_id);
  if (search_player == video_players_.end()) {
    return FlutterError("player_not_found", "This player ID was not found");
  }
  if (search_player->second->IsValid()) {
    search_player->second->Pause();
  }

  return std::nullopt;
}

}  // namespace video_player_windows
