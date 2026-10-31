// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_VIDEO_PLAYER_WINDOWS_MEDIA_PLAYER_H_
#define PACKAGES_VIDEO_PLAYER_WINDOWS_MEDIA_PLAYER_H_

#include <d3d11.h>
#include <flutter/encodable_value.h>
#include <mfmediaengine.h>
#include <windows.h>
#include <wrl/client.h>

#include <condition_variable>
#include <cstdint>
#include <deque>
#include <functional>
#include <memory>
#include <mutex>
#include <optional>
#include <string>
#include <thread>
#include <vector>

#include "adaptive_source.h"
#include "frame_buffer.h"
#include "messages.g.h"
#include "player_event.h"

namespace video_player_windows {

struct MediaNotification {
  DWORD event;
  DWORD_PTR parameter;
  DWORD detail;
};

struct PlayerWorkQueue {
  std::mutex mutex;
  std::condition_variable changed;
  std::deque<std::function<void()>> commands;
  std::deque<MediaNotification> notifications;
  bool stopping = false;
};

std::wstring Utf16FromUtf8(const std::string& text);
int64_t SecondsToMilliseconds(double seconds);

// Owns an MTA worker. Commands wait for that worker; callbacks run on it and
// must not reenter the player, which would wait for itself.
class MediaPlayer {
 public:
  using EventCallback = std::function<void(PlayerEvent)>;

  MediaPlayer(std::string source, std::shared_ptr<FrameBuffer> frames,
              std::function<void()> frame_available, EventCallback on_event,
              std::string network_source = {}, std::string network_relay = {});
  ~MediaPlayer();
  MediaPlayer(const MediaPlayer&) = delete;
  MediaPlayer& operator=(const MediaPlayer&) = delete;

  HRESULT Play();
  HRESULT Pause();
  HRESULT SetLooping(bool looping);
  HRESULT SetVolume(double volume);
  HRESULT SetPlaybackSpeed(double speed);
  HRESULT SeekTo(int64_t milliseconds);
  HRESULT GetPosition(int64_t* milliseconds);
  HRESULT SetPreventsDisplaySleep(bool prevents);
  HRESULT GetTracks(bool audio, std::vector<TrackData>* tracks);
  HRESULT SelectTrack(bool audio, std::optional<int64_t> track_id);

 private:
  HRESULT Invoke(std::function<HRESULT()> command);
  void Run();
  HRESULT Initialize();
  HRESULT LoadSource(const std::string& source);
  HRESULT RenderFrame();
  HRESULT EnsureRenderTargets(DWORD width, DWORD height);
  void HandleNotification(const MediaNotification& notification);
  void Emit(const std::string& event);
  void EmitPlaying(bool playing);
  void EmitBuffered();
  void EmitError(HRESULT result);
  void UpdateDisplaySleep();
  HRESULT ReadTracks(bool audio, std::vector<TrackData>* tracks);

  std::string source_;
  std::string network_source_;
  std::string network_relay_;
  std::unique_ptr<AdaptiveSource> adaptive_;
  std::shared_ptr<FrameBuffer> frames_;
  std::function<void()> frame_available_;
  EventCallback on_event_;
  std::shared_ptr<PlayerWorkQueue> queue_;
  Microsoft::WRL::ComPtr<IMFMediaEngine> engine_;
  Microsoft::WRL::ComPtr<ID3D11Device> device_;
  Microsoft::WRL::ComPtr<ID3D11DeviceContext> context_;
  Microsoft::WRL::ComPtr<IMFDXGIDeviceManager> device_manager_;
  Microsoft::WRL::ComPtr<ID3D11Texture2D> render_target_;
  Microsoft::WRL::ComPtr<ID3D11Texture2D> staging_;
  DWORD width_ = 0;
  DWORD height_ = 0;
  HRESULT initialization_result_ = E_PENDING;
  bool initialized_ = false;
  bool ready_to_seek_ = false;
  bool failed_ = false;
  bool playing_ = false;
  bool prevents_display_sleep_ = true;
  std::optional<int64_t> default_video_track_;
  std::optional<int64_t> pending_seek_;
  std::thread worker_;
};

}  // namespace video_player_windows

#endif
