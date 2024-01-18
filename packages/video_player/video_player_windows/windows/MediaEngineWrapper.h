// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#ifndef PACKAGES_VIDEO_PLAYER_VIDEO_PLAYER_WINDOWS_WINDOWS_MEDIA_ENGINE_WRAPPER_H_
#define PACKAGES_VIDEO_PLAYER_VIDEO_PLAYER_WINDOWS_WINDOWS_MEDIA_ENGINE_WRAPPER_H_

#include <flutter/plugin_registrar_windows.h>

#include <thread>
#include <tuple>

#include "MediaEngineExtension.h"
#include "MediaFoundationHelpers.h"

namespace video_player_windows {

// This class handles creation and management of the MediaFoundation
// MediaEngine. It uses the provided IMFMediaSource to feed media
// samples into the MediaEngine pipeline.
class MediaEngineWrapper
    : public winrt::implements<MediaEngineWrapper, IUnknown> {
 public:
  using ErrorCB = std::function<void(MF_MEDIA_ENGINE_ERR, HRESULT)>;

  enum class BufferingState { kHaveNothing = 0, kHaveEnough = 1 };
  using BufferingStateChangeCB = std::function<void(BufferingState)>;

  MediaEngineWrapper(std::function<void()> initialized_cb, ErrorCB error_cb,
                     BufferingStateChangeCB buffering_state_change_cb,
                     std::function<void()> playback_ended_cb,
                     std::function<void()> time_update_cb)
      : initialized_cb_(initialized_cb),
        error_cb_(error_cb),
        buffering_state_change_cb_(buffering_state_change_cb),
        playback_ended_cb_(playback_ended_cb),
        time_update_cb_(time_update_cb) {
    // The initialize callback is required
    THROW_HR_IF(E_INVALIDARG, !initialized_cb_);
  }
  ~MediaEngineWrapper();

  // Create the media engine with the provided media source
  void Initialize(winrt::com_ptr<IDXGIAdapter> adapter,
                  IMFMediaSource* media_source);

  // Stop playback and cleanup resources
  void Pause();
  void Shutdown();

  // Control various aspects of playback
  void StartPlayingFrom(uint64_t time_stamp);
  void SetPlaybackRate(double playback_rate);
  void SetVolume(float volume);
  void SetLooping(bool is_looping);
  void SeekTo(uint64_t time_stamp);

  // Query the current playback position
  uint64_t GetMediaTime();

  uint64_t GetDuration();

  std::vector<std::tuple<uint64_t, uint64_t>> GetBufferedRanges();

  void GetNativeVideoSize(uint32_t& cx, uint32_t& cy);

  void UpdateSurfaceDescriptor(uint32_t width, uint32_t height,
                               std::function<void()> callback,
                               FlutterDesktopGpuSurfaceDescriptor& descriptor);
  void StartBackgroundThread(std::function<void()> callback);

  // Inform media engine of output window position & size changes
  void OnWindowUpdate(uint32_t width, uint32_t height);

 private:
  wil::critical_section lock_;
  std::function<void()> initialized_cb_;
  ErrorCB error_cb_;
  BufferingStateChangeCB buffering_state_change_cb_;
  std::function<void()> playback_ended_cb_;
  std::function<void()> time_update_cb_;
  MFPlatformRef platform_ref_;
  winrt::com_ptr<IMFMediaEngine> media_engine_;
  UINT device_reset_token_ = 0;
  winrt::com_ptr<IDXGIAdapter> adapter_;
  winrt::com_ptr<ID3D11Device> d3d11_device_;
  winrt::com_ptr<ID3D11Texture2D> texture_;
  winrt::com_ptr<IMFDXGIDeviceManager> dxgi_device_manager_;
  winrt::com_ptr<MediaEngineExtension> media_engine_extension_;
  winrt::com_ptr<IMFMediaEngineNotify> callback_helper_;
  std::thread background_thread_;
  std::atomic<bool> should_exit_loop_ = false;
  HANDLE video_surface_shared_handle_{0};
  uint32_t width_ = 0;
  uint32_t height_ = 0;
  bool has_set_source_ = false;
  bool EnsureTextureCreated(DWORD width, DWORD height);
  bool UpdateDXTexture();
  bool UpdateDXTexture(DWORD width, DWORD height);
  void InitializeVideo();
  void CreateMediaEngine(IMFMediaSource* media_source);
  void OnLoaded();
  void OnError(MF_MEDIA_ENGINE_ERR error, HRESULT hr);
  void OnBufferingStateChange(BufferingState state);
  void OnPlaybackEnded();
  void OnTimeUpdate();
};

}  // namespace video_player_windows

#endif  // PACKAGES_VIDEO_PLAYER_VIDEO_PLAYER_WINDOWS_WINDOWS_MEDIA_ENGINE_WRAPPER_H_