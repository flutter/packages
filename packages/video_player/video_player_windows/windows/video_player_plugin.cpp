// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "include/video_player_windows/video_player_plugin.h"

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

#include "messages.h"
#include "video_player.h"

#undef GetCurrentTime

using namespace Messages;

namespace {

class VideoPlayerPlugin : public flutter::Plugin, public WindowsVideoPlayerApi {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  VideoPlayerPlugin(flutter::PluginRegistrarWindows* registrar);

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

  flutter::TextureRegistrar* _textureRegistry;
  flutter::PluginRegistrarWindows* registrar_;
};

// static
void VideoPlayerPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<VideoPlayerPlugin>(registrar);
  registrar->AddPlugin(std::move(plugin));
}

VideoPlayerPlugin::VideoPlayerPlugin(flutter::PluginRegistrarWindows* registrar)
    : registrar_(registrar) {
  _textureRegistry = registrar->texture_registrar();
  WindowsVideoPlayerApi::SetUp(registrar->messenger(), this);
}

std::optional<FlutterError> VideoPlayerPlugin::Initialize() {
  for (int i = 0; i < videoPlayers.size(); i++) {
    videoPlayers.at((int64_t)i)->Dispose();
  }
  videoPlayers.clear();

  return {};
}

ErrorOr<int64_t> VideoPlayerPlugin::Create(
    const std::string* asset, const std::string* uri,
    const std::string* package_name, const std::string* format_hint,
    const flutter::EncodableMap& http_headers) {
  std::unique_ptr<VideoPlayer> player{nullptr};
  if (asset && !asset->empty()) {
    std::string assetPath;
    if (package_name && !package_name->empty()) {
      // TODO: Not supported on Windows
      // assetPath = [_registrar lookupKeyForAsset:input.asset
      // fromPackage:input.packageName];
      assetPath = *asset;
    } else {
      assetPath = *asset;
    }

    try {
      auto modulePath = wil::GetModuleFileNameW<std::wstring>(nullptr);

      size_t found = modulePath.find_last_of(L"/\\");
      modulePath = modulePath.substr(0, found);

      std::wstring finalAssetPath =
          modulePath + L"/data/flutter_assets/" +
          std::wstring(assetPath.begin(), assetPath.end());

      player = std::make_unique<VideoPlayer>(
          registrar_->GetView(), finalAssetPath, flutter::EncodableMap());
    } catch (std::exception& e) {
      return FlutterError("asset_load_failed", e.what());
    }
  } else if (uri && !uri->empty()) {
    try {
      std::string assetPath = *uri;
      player = std::make_unique<VideoPlayer>(
          registrar_->GetView(),
          std::wstring(assetPath.begin(), assetPath.end()), http_headers);
    } catch (std::exception& e) {
      return FlutterError("uri_load_failed", e.what());
    }
  } else {
    return FlutterError("not_implemented", "Set either an asset or a uri");
  }

  auto textureId = _textureRegistry->RegisterTexture(&player->texture);

  player->Init(registrar_, textureId);

  videoPlayers.insert(
      std::make_pair(player->GetTextureId(), std::move(player)));

  return textureId;
}

std::optional<FlutterError> VideoPlayerPlugin::Dispose(int64_t texture_id) {
  auto searchPlayer = videoPlayers.find(texture_id);
  if (searchPlayer == videoPlayers.end()) {
    return FlutterError("player_not_found", "This player ID was not found");
  }
  if (searchPlayer->second->IsValid()) {
    searchPlayer->second->Dispose();
    videoPlayers.erase(texture_id);
  }

  return {};
}

std::optional<FlutterError> VideoPlayerPlugin::SetLooping(int64_t texture_id,
                                                          bool is_looping) {
  auto searchPlayer = videoPlayers.find(texture_id);
  if (searchPlayer == videoPlayers.end()) {
    return FlutterError("player_not_found", "This player ID was not found");
  }
  if (searchPlayer->second->IsValid()) {
    searchPlayer->second->SetLooping(is_looping);
  }

  return {};
}

std::optional<FlutterError> VideoPlayerPlugin::SetVolume(int64_t texture_id,
                                                         double volume) {
  auto searchPlayer = videoPlayers.find(texture_id);
  if (searchPlayer == videoPlayers.end()) {
    return FlutterError("player_not_found", "This player ID was not found");
  }
  if (searchPlayer->second->IsValid()) {
    searchPlayer->second->SetVolume(volume);
  }

  return {};
}

std::optional<FlutterError> VideoPlayerPlugin::SetPlaybackSpeed(
    int64_t texture_id, double speed) {
  auto searchPlayer = videoPlayers.find(texture_id);
  if (searchPlayer == videoPlayers.end()) {
    return FlutterError("player_not_found", "This player ID was not found");
  }
  if (searchPlayer->second->IsValid()) {
    searchPlayer->second->SetPlaybackSpeed(speed);
  }

  return {};
}

std::optional<FlutterError> VideoPlayerPlugin::Play(int64_t texture_id) {
  auto searchPlayer = videoPlayers.find(texture_id);
  if (searchPlayer == videoPlayers.end()) {
    return FlutterError("player_not_found", "This player ID was not found");
  }
  if (searchPlayer->second->IsValid()) {
    searchPlayer->second->Play();
  }

  return {};
}

ErrorOr<int64_t> VideoPlayerPlugin::Position(int64_t texture_id) {
  auto searchPlayer = videoPlayers.find(texture_id);
  int64_t position = 0;
  if (searchPlayer != videoPlayers.end()) {
    auto& player = searchPlayer->second;
    if (player->IsValid()) {
      position = player->GetPosition();
      player->SendBufferingUpdate();
    }
  }
  return position;
}

std::optional<FlutterError> VideoPlayerPlugin::SeekTo(int64_t texture_id,
                                                      int64_t position) {
  auto searchPlayer = videoPlayers.find(texture_id);
  if (searchPlayer == videoPlayers.end()) {
    return FlutterError("player_not_found", "This player ID was not found");
  }
  if (searchPlayer->second->IsValid()) {
    searchPlayer->second->SeekTo(position);
  }

  return {};
}

std::optional<FlutterError> VideoPlayerPlugin::Pause(int64_t texture_id) {
  auto searchPlayer = videoPlayers.find(texture_id);
  if (searchPlayer == videoPlayers.end()) {
    return FlutterError("player_not_found", "This player ID was not found");
  }
  if (searchPlayer->second->IsValid()) {
    searchPlayer->second->Pause();
  }

  return {};
}

std::optional<FlutterError> VideoPlayerPlugin::SetMixWithOthers(
    bool mix_with_others) {
  mixWithOthers = mix_with_others;

  return {};
}

VideoPlayerPlugin::~VideoPlayerPlugin() {}

}  // namespace

void VideoPlayerPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  VideoPlayerPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}