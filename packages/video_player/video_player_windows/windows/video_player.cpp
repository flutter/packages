// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "video_player.h"

#include <flutter/event_channel.h>
#include <flutter/event_stream_handler.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/standard_method_codec.h>

#undef GetCurrentTime

using namespace winrt;

namespace video_player_windows {

VideoPlayer::VideoPlayer(IDXGIAdapter* adapter, HWND window, std::wstring uri,
                         flutter::EncodableMap http_headers)
    : texture_(flutter::GpuSurfaceTexture(
          FlutterDesktopGpuSurfaceType::
              kFlutterDesktopGpuSurfaceTypeDxgiSharedHandle,
          std::bind(&VideoPlayer::ObtainDescriptorCallback, this,
                    std::placeholders::_1, std::placeholders::_2))) {
  mf_platform_.Startup();

  // Callbacks invoked by the media engine wrapper.
  auto on_initialized = std::bind(&VideoPlayer::OnMediaInitialized, this);
  auto on_error = std::bind(&VideoPlayer::OnMediaError, this,
                            std::placeholders::_1, std::placeholders::_2);
  auto on_buffering_state_changed =
      std::bind(&VideoPlayer::OnMediaStateChange, this, std::placeholders::_1);
  auto on_playback_ended_cb = std::bind(&VideoPlayer::OnPlaybackEnded, this);

  // Create and initialize the MediaEngineWrapper which manages media playback.
  media_engine_wrapper_ = winrt::make_self<MediaEngineWrapper>(
      on_initialized, on_error, on_buffering_state_changed,
      on_playback_ended_cb, nullptr);

  // Create a source resolver to create an IMFMediaSource for the content URL.
  // This will create an instance of an inbuilt OS media source for playback.
  winrt::com_ptr<IMFSourceResolver> source_resolver;
  THROW_IF_FAILED(MFCreateSourceResolver(source_resolver.put()));
  constexpr uint32_t source_resolution_flags =
      MF_RESOLUTION_MEDIASOURCE | MF_RESOLUTION_READ;
  MF_OBJECT_TYPE object_type = {};

  winrt::com_ptr<IMFMediaSource> media_source;
  THROW_IF_FAILED(source_resolver->CreateObjectFromURL(
      uri.c_str(), source_resolution_flags, nullptr, &object_type,
      reinterpret_cast<IUnknown**>(media_source.put_void())));
  media_engine_wrapper_->Initialize(adapter, media_source.get());
}

void VideoPlayer::Init(
    flutter::BinaryMessenger* messenger,
    std::function<void(int64_t)> texture_frame_available_callback,
    flutter::TextureRegistrar* texture_registry) {
  texture_id_ = texture_registry->RegisterTexture(&texture_);
  texture_frame_available_callback_ = texture_frame_available_callback;

  event_channel_ =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
          messenger,
          std::string("flutter.io/videoPlayer/videoEvents") +
              std::to_string(texture_id_),
          &flutter::StandardMethodCodec::GetInstance());

  event_channel_->SetStreamHandler(
      std::make_unique<
          flutter::StreamHandlerFunctions<flutter::EncodableValue>>(
          [this](const flutter::EncodableValue* arguments,
                 std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&&
                     events)
              -> std::unique_ptr<
                  flutter::StreamHandlerError<flutter::EncodableValue>> {
            event_sink_ = std::move(events);
            return nullptr;
          },
          [this](const flutter::EncodableValue* arguments)
              -> std::unique_ptr<
                  flutter::StreamHandlerError<flutter::EncodableValue>> {
            event_sink_ = nullptr;
            return nullptr;
          }));
}

FlutterDesktopGpuSurfaceDescriptor* VideoPlayer::ObtainDescriptorCallback(
    size_t width, size_t height) {
  // Lock buffer mutex to protect texture processing.
  std::lock_guard<std::mutex> buffer_lock(buffer_mutex_);

  if (texture_id_ == -1) {
    return nullptr;
  }

  uint32_t texture_width = static_cast<uint32_t>(width);
  uint32_t texture_height = static_cast<uint32_t>(height);

  media_engine_wrapper_->UpdateSurfaceDescriptor(
      texture_width, texture_height,
      [&]() {
        if (texture_frame_available_callback_) {
          texture_frame_available_callback_(texture_id_);
        }
      },
      descriptor_);

  UpdateVideoSize(texture_width, texture_height);

  return &descriptor_;
}

void VideoPlayer::OnMediaInitialized() {
  // Start playback.
  media_engine_wrapper_->SeekTo(0);
  if (!is_initialized_) {
    is_initialized_ = true;
    SendInitialized();
  }
}

void VideoPlayer::UpdateVideoSize(uint32_t width, uint32_t height) {
  if (media_engine_wrapper_) {
    media_engine_wrapper_->OnWindowUpdate(width, height);
  }
}

void VideoPlayer::OnMediaError(MF_MEDIA_ENGINE_ERR error, HRESULT hr) {
  LOG_HR_MSG(hr, "MediaEngine error (%d)", error);
}

void VideoPlayer::OnMediaStateChange(MediaEngineWrapper::BufferingState state) {
  if (state == MediaEngineWrapper::BufferingState::kHaveNothing) {
    SetBuffering(true);
    SendBufferingUpdate();
  } else {
    if (!is_initialized_) {
      is_initialized_ = true;
      SendInitialized();
    }
    SetBuffering(false);
  }
}

void VideoPlayer::OnPlaybackEnded() {
  if (event_sink_) {
    event_sink_->Success(
        flutter::EncodableMap({{flutter::EncodableValue("event"),
                                flutter::EncodableValue("completed")}}));
  }
}

void VideoPlayer::SetBuffering(bool buffering) {
  if (event_sink_) {
    event_sink_->Success(flutter::EncodableMap(
        {{flutter::EncodableValue("event"),
          flutter::EncodableValue(buffering ? "bufferingStart"
                                            : "bufferingEnd")}}));
  }
}

void VideoPlayer::SendInitialized() {
  if (!event_sink_) {
    return;
  }
  auto event = flutter::EncodableMap(
      {{flutter::EncodableValue("event"),
        flutter::EncodableValue("initialized")},
       {flutter::EncodableValue("duration"),
        flutter::EncodableValue(
            (int64_t)media_engine_wrapper_->GetDuration())}});

  uint32_t width;
  uint32_t height;
  media_engine_wrapper_->GetNativeVideoSize(width, height);
  event.insert({flutter::EncodableValue("width"),
                flutter::EncodableValue((int32_t)width)});
  event.insert({flutter::EncodableValue("height"),
                flutter::EncodableValue((int32_t)height)});

  event_sink_->Success(event);
}

void VideoPlayer::Dispose(flutter::TextureRegistrar* texture_registry) {
  std::lock_guard<std::mutex> buffer_lock(buffer_mutex_);
  texture_frame_available_callback_ = nullptr;

  if (is_initialized_) {
    media_engine_wrapper_->Pause();
  }
  texture_registry->UnregisterTexture(texture_id_);
  texture_id_ = -1;
  event_channel_ = nullptr;
  media_engine_wrapper_->Shutdown();
  media_engine_wrapper_.detach();
  mf_platform_.Shutdown();
}

void VideoPlayer::SetLooping(bool is_looping) {
  media_engine_wrapper_->SetLooping(is_looping);
}

void VideoPlayer::SetVolume(double volume) {
  media_engine_wrapper_->SetVolume((float)volume);
}

void VideoPlayer::SetPlaybackSpeed(double speed) {
  media_engine_wrapper_->SetPlaybackRate(speed);
}

void VideoPlayer::Play() {
  media_engine_wrapper_->StartPlayingFrom(
      media_engine_wrapper_->GetMediaTime());
}

void VideoPlayer::Pause() { media_engine_wrapper_->Pause(); }

int64_t VideoPlayer::GetPosition() {
  return media_engine_wrapper_->GetMediaTime();
}

void VideoPlayer::SendBufferingUpdate() {
  if (!event_sink_) {
    return;
  }
  auto values = flutter::EncodableList();
  auto ranges = media_engine_wrapper_->GetBufferedRanges();
  for (uint32_t i = 0; i < ranges.size(); i++) {
    auto [start, end] = ranges.at(i);
    values.push_back(
        flutter::EncodableList({flutter::EncodableValue((int64_t)(start)),
                                flutter::EncodableValue((int64_t)(end))}));
  }

  event_sink_->Success(
      flutter::EncodableMap({{flutter::EncodableValue("event"),
                              flutter::EncodableValue("bufferingUpdate")},
                             {flutter::EncodableValue("values"), values}}));
}

void VideoPlayer::SeekTo(int64_t seek) { media_engine_wrapper_->SeekTo(seek); }

int64_t VideoPlayer::GetTextureId() { return texture_id_; }

}  // namespace video_player_windows