// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#pragma once

#include <flutter/plugin_registrar_windows.h>

#include <thread>
#include <tuple>

#include "MediaEngineExtension.h"
#include "MediaFoundationHelpers.h"

namespace media {

// This class handles creation and management of the MediaFoundation
// MediaEngine. It uses the provided IMFMediaSource to feed media
// samples into the MediaEngine pipeline.
class MediaEngineWrapper
    : public winrt::implements<MediaEngineWrapper, IUnknown> {
 public:
  using ErrorCB = std::function<void(MF_MEDIA_ENGINE_ERR, HRESULT)>;

  enum class BufferingState { HAVE_NOTHING = 0, HAVE_ENOUGH = 1 };
  using BufferingStateChangeCB = std::function<void(BufferingState)>;

  MediaEngineWrapper(std::function<void()> initializedCB, ErrorCB errorCB,
                     BufferingStateChangeCB bufferingStateChangeCB,
                     std::function<void()> playbackEndedCB,
                     std::function<void()> timeUpdateCB)
      : m_initializedCB(initializedCB),
        m_errorCB(errorCB),
        m_bufferingStateChangeCB(bufferingStateChangeCB),
        m_playbackEndedCB(playbackEndedCB),
        m_timeUpdateCB(timeUpdateCB) {
    // The initialize callback is required
    THROW_HR_IF(E_INVALIDARG, !m_initializedCB);
  }
  ~MediaEngineWrapper() {
    m_shouldExitLoop = true;
    if (m_backgroundThread.joinable()) {
      m_backgroundThread.join();
    }
  }

  // Create the media engine with the provided media source
  void Initialize(winrt::com_ptr<IDXGIAdapter> adapter,
                  IMFMediaSource* mediaSource);

  // Stop playback and cleanup resources
  void Pause();
  void Shutdown();

  // Control various aspects of playback
  void StartPlayingFrom(uint64_t timeStamp);
  void SetPlaybackRate(double playbackRate);
  void SetVolume(float volume);
  void SetLooping(bool isLooping);
  void SeekTo(uint64_t timeStamp);

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
  wil::critical_section m_lock;
  std::function<void()> m_initializedCB;
  ErrorCB m_errorCB;
  BufferingStateChangeCB m_bufferingStateChangeCB;
  std::function<void()> m_playbackEndedCB;
  std::function<void()> m_timeUpdateCB;
  MFPlatformRef m_platformRef;
  winrt::com_ptr<IMFMediaEngine> m_mediaEngine;
  UINT m_deviceResetToken = 0;
  winrt::com_ptr<IDXGIAdapter> m_adapter;
  winrt::com_ptr<ID3D11Device> m_d3d11Device;
  winrt::com_ptr<ID3D11Texture2D> m_pTexture;
  winrt::com_ptr<IMFDXGIDeviceManager> m_dxgiDeviceManager;
  winrt::com_ptr<MediaEngineExtension> m_mediaEngineExtension;
  winrt::com_ptr<IMFMediaEngineNotify> m_callbackHelper;
  std::thread m_backgroundThread;
  std::atomic<bool> m_shouldExitLoop = false;
  HANDLE m_videoSurfaceSharedHandle{0};
  uint32_t m_width = 0;
  uint32_t m_height = 0;
  bool m_hasSetSource = false;
  bool EnsureTextureCreated(DWORD width, DWORD height);
  bool UpdateDXTexture();
  bool UpdateDXTexture(DWORD width, DWORD height);
  void InitializeVideo();
  void CreateMediaEngine(IMFMediaSource* mediaSource);
  void OnLoaded();
  void OnError(MF_MEDIA_ENGINE_ERR error, HRESULT hr);
  void OnBufferingStateChange(BufferingState state);
  void OnPlaybackEnded();
  void OnTimeUpdate();
};

}  // namespace media