#include "include/video_player_windows/video_player_plugin.h"

#include <flutter/event_channel.h>
#include <flutter/event_stream_handler.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_codec_serializer.h>
#include <flutter/standard_method_codec.h>
#include <shobjidl.h>
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
  ErrorOr<TextureMessage> Create(const CreateMessage& arg) override;
  std::optional<FlutterError> Dispose(const TextureMessage& arg) override;
  std::optional<FlutterError> SetLooping(const LoopingMessage& arg) override;
  std::optional<FlutterError> SetVolume(const VolumeMessage& arg) override;
  std::optional<FlutterError> SetPlaybackSpeed(
      const PlaybackSpeedMessage& arg) override;
  std::optional<FlutterError> Play(const TextureMessage& arg) override;
  ErrorOr<PositionMessage> Position(
      const TextureMessage& arg) override;
  std::optional<FlutterError> SeekTo(const PositionMessage& arg) override;
  std::optional<FlutterError> Pause(const TextureMessage& arg) override;
  std::optional<FlutterError> SetMixWithOthers(
      const MixWithOthersMessage& arg) override;

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

ErrorOr<TextureMessage> VideoPlayerPlugin::Create(
    const CreateMessage& input) {
  std::unique_ptr<VideoPlayer> player{nullptr};
  if (input.asset() && !input.asset()->empty()) {
    std::string assetPath;
    if (input.package_name() && !input.package_name()->empty()) {
      // TODO
      // assetPath = [_registrar lookupKeyForAsset:input.asset
      // fromPackage:input.packageName];
      assetPath = *input.asset();
    } else {
      assetPath = *input.asset();
    }

    player = std::make_unique<VideoPlayer>(registrar_->GetView(), assetPath);
  } else if (input.uri() && !input.uri()->empty()) {
    player = std::make_unique<VideoPlayer>(registrar_->GetView(), *input.uri(), input.http_headers());
  } else {
    return FlutterError("not_implemented", "Set either an asset or a uri");
  }

  auto textureId = _textureRegistry->RegisterTexture(&player->texture);

  player->Init(registrar_, textureId);

  videoPlayers.insert(
      std::make_pair(player->GetTextureId(), std::move(player)));

  TextureMessage textureMessage = TextureMessage(textureId);
  return textureMessage;
}

std::optional<FlutterError> VideoPlayerPlugin::Dispose(
    const TextureMessage& arg) {
  auto searchPlayer = videoPlayers.find(arg.texture_id());
  if (searchPlayer == videoPlayers.end()) {
    return FlutterError("player_not_found", "This player ID was not found");
  }
  if (searchPlayer->second->IsValid()) {
    searchPlayer->second->Dispose();
    videoPlayers.erase(arg.texture_id());
  }

  return {};
}

std::optional<FlutterError> VideoPlayerPlugin::SetLooping(
    const LoopingMessage& arg) {
  auto searchPlayer = videoPlayers.find(arg.texture_id());
  if (searchPlayer == videoPlayers.end()) {
    return FlutterError("player_not_found", "This player ID was not found");
  }
  if (searchPlayer->second->IsValid()) {
    searchPlayer->second->SetLooping(arg.is_looping());
  }

  return {};
}

std::optional<FlutterError> VideoPlayerPlugin::SetVolume(
    const VolumeMessage& arg) {
  auto searchPlayer = videoPlayers.find(arg.texture_id());
  if (searchPlayer == videoPlayers.end()) {
    return FlutterError("player_not_found", "This player ID was not found");
  }
  if (searchPlayer->second->IsValid()) {
    searchPlayer->second->SetVolume(arg.volume());
  }

  return {};
}

std::optional<FlutterError> VideoPlayerPlugin::SetPlaybackSpeed(
    const PlaybackSpeedMessage& arg) {
  auto searchPlayer = videoPlayers.find(arg.texture_id());
  if (searchPlayer == videoPlayers.end()) {
    return FlutterError("player_not_found", "This player ID was not found");
  }
  if (searchPlayer->second->IsValid()) {
    searchPlayer->second->SetPlaybackSpeed(arg.speed());
  }

  return {};
}

std::optional<FlutterError> VideoPlayerPlugin::Play(const TextureMessage& arg) {
  auto searchPlayer = videoPlayers.find(arg.texture_id());
  if (searchPlayer == videoPlayers.end()) {
    return FlutterError("player_not_found", "This player ID was not found");
  }
  if (searchPlayer->second->IsValid()) {
    searchPlayer->second->Play();
  }

  return {};
}

ErrorOr<PositionMessage> VideoPlayerPlugin::Position(
    const TextureMessage& arg) {
  auto searchPlayer = videoPlayers.find(arg.texture_id());
  PositionMessage result = PositionMessage(arg.texture_id(), 0);
  if (searchPlayer != videoPlayers.end()) {
    auto& player = searchPlayer->second;
    if (player->IsValid()) {
        result.set_position(player->GetPosition());
        player->SendBufferingUpdate();
    }
  }
  return result;
}

std::optional<FlutterError> VideoPlayerPlugin::SeekTo(
    const PositionMessage& arg) {
  auto searchPlayer = videoPlayers.find(arg.texture_id());
  if (searchPlayer == videoPlayers.end()) {
    return FlutterError("player_not_found", "This player ID was not found");
  }
  if (searchPlayer->second->IsValid()) {
    searchPlayer->second->SeekTo(arg.position());
  }

  return {};
}

std::optional<FlutterError> VideoPlayerPlugin::Pause(
    const TextureMessage& arg) {
  auto searchPlayer = videoPlayers.find(arg.texture_id());
  if (searchPlayer == videoPlayers.end()) {
    return FlutterError("player_not_found", "This player ID was not found");
  }
  if (searchPlayer->second->IsValid()) {
    searchPlayer->second->Pause();
  }

  return {};
}

std::optional<FlutterError> VideoPlayerPlugin::SetMixWithOthers(
    const MixWithOthersMessage& arg) {
  mixWithOthers = arg.mix_with_others();

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