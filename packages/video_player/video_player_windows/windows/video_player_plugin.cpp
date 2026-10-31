// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "video_player_plugin.h"

#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/standard_method_codec.h>

#include <deque>
#include <mutex>
#include <sstream>
#include <utility>
#include <vector>

namespace video_player_windows {
namespace {
using flutter::EncodableValue;
constexpr UINT kDispatchEvents = WM_APP + 1;
constexpr wchar_t kWindowClass[] = L"FlutterVideoPlayerWindowsEvents";

FlutterError NativeError(HRESULT result) {
  std::ostringstream message;
  message << "Media Foundation operation failed (HRESULT 0x" << std::hex
          << static_cast<unsigned long>(result) << ").";
  return FlutterError("VideoError", message.str());
}
}  // namespace

struct EventDispatcher {
  std::mutex mutex;
  HWND window = nullptr;
  std::deque<std::pair<std::weak_ptr<PlayerEntry>, PlayerEvent>> events;

  // Event sinks belong to the platform thread; media callbacks must reach them
  // through this window's message queue.
  void Post(std::weak_ptr<PlayerEntry> player, PlayerEvent event) {
    std::lock_guard<std::mutex> lock(mutex);
    if (window) {
      events.emplace_back(std::move(player), std::move(event));
      PostMessage(window, kDispatchEvents, 0, 0);
    }
  }
};

struct PlayerEntry {
  flutter::TextureRegistrar* textures;
  int64_t id;
  std::shared_ptr<FrameBuffer> frames;
  std::unique_ptr<MediaPlayer> player;
  std::unique_ptr<flutter::EventChannel<EncodableValue>> channel;
  std::unique_ptr<flutter::EventSink<EncodableValue>> sink;
  PendingPlayerEvents pending;

  ~PlayerEntry() {
    player.reset();
    channel->SetStreamHandler(nullptr);
    channel.reset();
    // Flutter may still invoke the texture callback until unregistration
    // completes.
    textures->UnregisterTexture(id, [retained_frames = std::move(frames)] {});
  }

  void Send(PlayerEvent event) {
    if (!sink) {
      pending.Add(std::move(event));
      return;
    }
    if (event.error.empty()) {
      sink->Success(EncodableValue(event.value));
    } else {
      sink->Error("VideoError", event.error);
    }
  }
};

void VideoPlayerPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto plugin = std::make_unique<VideoPlayerPlugin>(registrar);
  WindowsVideoPlayerApi::SetUp(registrar->messenger(), plugin.get());
  registrar->AddPlugin(std::move(plugin));
}

VideoPlayerPlugin::VideoPlayerPlugin(flutter::PluginRegistrarWindows* registrar)
    : registrar_(registrar), dispatcher_(std::make_shared<EventDispatcher>()) {
  WNDCLASSW window_class = {};
  window_class.lpfnWndProc = WindowProc;
  window_class.hInstance = GetModuleHandle(nullptr);
  window_class.lpszClassName = kWindowClass;
  RegisterClassW(&window_class);
  window_ = CreateWindowExW(0, kWindowClass, L"", 0, 0, 0, 0, 0, HWND_MESSAGE,
                            nullptr, window_class.hInstance, this);
  dispatcher_->window = window_;
}

VideoPlayerPlugin::~VideoPlayerPlugin() {
  WindowsVideoPlayerApi::SetUp(registrar_->messenger(), nullptr);

  // Workers can still emit events while being joined during player disposal.
  // Disable posting before tearing down players and the dispatch window.
  {
    std::lock_guard<std::mutex> lock(dispatcher_->mutex);
    dispatcher_->window = nullptr;
    dispatcher_->events.clear();
  }

  players_.clear();
  if (window_) {
    DestroyWindow(window_);
  }
}

LRESULT CALLBACK VideoPlayerPlugin::WindowProc(HWND window, UINT message,
                                               WPARAM wparam, LPARAM lparam) {
  if (message == WM_NCCREATE) {
    const auto* create = reinterpret_cast<CREATESTRUCT*>(lparam);
    SetWindowLongPtr(window, GWLP_USERDATA,
                     reinterpret_cast<LONG_PTR>(create->lpCreateParams));
  }
  auto* plugin = reinterpret_cast<VideoPlayerPlugin*>(
      GetWindowLongPtr(window, GWLP_USERDATA));
  if (message == kDispatchEvents && plugin) {
    plugin->DrainEvents();
    return 0;
  }
  return DefWindowProc(window, message, wparam, lparam);
}

void VideoPlayerPlugin::DrainEvents() {
  std::deque<std::pair<std::weak_ptr<PlayerEntry>, PlayerEvent>> events;
  {
    std::lock_guard<std::mutex> lock(dispatcher_->mutex);
    events.swap(dispatcher_->events);
  }

  for (auto& [target, event] : events) {
    if (auto entry = target.lock()) {
      entry->Send(std::move(event));
    }
  }
}

std::optional<FlutterError> VideoPlayerPlugin::Initialize() {
  players_.clear();
  return std::nullopt;
}

ErrorOr<int64_t> VideoPlayerPlugin::Create(const std::string& source,
                                           const std::string* network_source,
                                           const std::string* network_relay) {
  if (!window_) {
    return FlutterError("VideoError",
                        "Could not create the Windows event dispatcher.");
  }
  if (source.empty() || Utf16FromUtf8(source).empty()) {
    return FlutterError("VideoError",
                        "A valid UTF-8 video source is required.");
  }

  auto frames = std::make_shared<FrameBuffer>();
  auto* textures = registrar_->texture_registrar();
  const int64_t id = textures->RegisterTexture(frames->texture());
  if (id < 0) {
    return FlutterError("VideoError", "Could not register the video texture.");
  }

  auto entry = std::make_shared<PlayerEntry>();
  entry->textures = textures;
  entry->id = id;
  entry->frames = frames;
  entry->channel = std::make_unique<flutter::EventChannel<EncodableValue>>(
      registrar_->messenger(),
      "flutter.dev/video_player_windows/events/" + std::to_string(id),
      &flutter::StandardMethodCodec::GetInstance());
  auto* entry_ptr = entry.get();
  entry->channel->SetStreamHandler(
      std::make_unique<flutter::StreamHandlerFunctions<EncodableValue>>(
          [entry_ptr](
              const EncodableValue*,
              std::unique_ptr<flutter::EventSink<EncodableValue>>&& sink)
              -> std::unique_ptr<flutter::StreamHandlerError<EncodableValue>> {
            entry_ptr->sink = std::move(sink);
            auto pending = entry_ptr->pending.Take();
            for (auto& event : pending) {
              entry_ptr->Send(std::move(event));
            }
            return nullptr;
          },
          [entry_ptr](const EncodableValue*)
              -> std::unique_ptr<flutter::StreamHandlerError<EncodableValue>> {
            entry_ptr->sink.reset();
            return nullptr;
          }));

  std::weak_ptr<EventDispatcher> dispatcher = dispatcher_;
  // Texture IDs can be reused after disposal; queued events must retain the
  // original player's identity rather than look up its ID again.
  std::weak_ptr<PlayerEntry> player = entry;
  entry->player = std::make_unique<MediaPlayer>(
      source, frames,
      [textures, id] { textures->MarkTextureFrameAvailable(id); },
      [dispatcher, player](PlayerEvent event) {
        if (auto target = dispatcher.lock()) {
          target->Post(player, std::move(event));
        }
      },
      network_source ? *network_source : "",
      network_relay ? *network_relay : "");
  players_.emplace(id, std::move(entry));
  return id;
}

std::optional<FlutterError> VideoPlayerPlugin::Dispose(int64_t player_id) {
  players_.erase(player_id);
  return std::nullopt;
}

std::optional<FlutterError> VideoPlayerPlugin::WithPlayer(
    int64_t id, std::function<HRESULT(MediaPlayer&)> operation) {
  const auto entry = players_.find(id);
  if (entry == players_.end()) {
    return FlutterError("UnknownPlayer",
                        "The player has already been disposed.",
                        EncodableValue(id));
  }
  const HRESULT result = operation(*entry->second->player);
  return FAILED(result) ? std::optional<FlutterError>(NativeError(result))
                        : std::nullopt;
}

std::optional<FlutterError> VideoPlayerPlugin::Play(int64_t id) {
  return WithPlayer(id, [](MediaPlayer& player) { return player.Play(); });
}
std::optional<FlutterError> VideoPlayerPlugin::Pause(int64_t id) {
  return WithPlayer(id, [](MediaPlayer& player) { return player.Pause(); });
}
std::optional<FlutterError> VideoPlayerPlugin::SetLooping(int64_t id,
                                                          bool looping) {
  return WithPlayer(id, [looping](MediaPlayer& player) {
    return player.SetLooping(looping);
  });
}
std::optional<FlutterError> VideoPlayerPlugin::SetVolume(int64_t id,
                                                         double volume) {
  return WithPlayer(
      id, [volume](MediaPlayer& player) { return player.SetVolume(volume); });
}
std::optional<FlutterError> VideoPlayerPlugin::SetPlaybackSpeed(int64_t id,
                                                                double speed) {
  return WithPlayer(id, [speed](MediaPlayer& player) {
    return player.SetPlaybackSpeed(speed);
  });
}
std::optional<FlutterError> VideoPlayerPlugin::SeekTo(int64_t id,
                                                      int64_t milliseconds) {
  return WithPlayer(id, [milliseconds](MediaPlayer& player) {
    return player.SeekTo(milliseconds);
  });
}
ErrorOr<int64_t> VideoPlayerPlugin::GetPosition(int64_t id) {
  int64_t milliseconds = 0;
  const auto error = WithPlayer(id, [&milliseconds](MediaPlayer& player) {
    return player.GetPosition(&milliseconds);
  });
  if (error) {
    return *error;
  }
  return milliseconds;
}
ErrorOr<flutter::EncodableList> VideoPlayerPlugin::GetTracks(int64_t id,
                                                             bool audio) {
  std::vector<TrackData> tracks;
  const auto error = WithPlayer(id, [&](MediaPlayer& player) {
    return player.GetTracks(audio, &tracks);
  });
  if (error) return *error;
  flutter::EncodableList result;
  for (const auto& track : tracks) {
    result.emplace_back(flutter::CustomEncodableValue(track));
  }
  return result;
}

std::optional<FlutterError> VideoPlayerPlugin::SelectTrack(
    int64_t id, bool audio, const int64_t* track_id) {
  const std::optional<int64_t> selection =
      track_id ? std::optional<int64_t>(*track_id) : std::nullopt;
  return WithPlayer(id, [audio, selection](MediaPlayer& player) {
    return player.SelectTrack(audio, selection);
  });
}
std::optional<FlutterError> VideoPlayerPlugin::SetPreventsDisplaySleep(
    int64_t id, bool prevents) {
  return WithPlayer(id, [prevents](MediaPlayer& player) {
    return player.SetPreventsDisplaySleep(prevents);
  });
}

}  // namespace video_player_windows
