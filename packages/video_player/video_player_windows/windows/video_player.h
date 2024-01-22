// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#ifndef PACKAGES_VIDEO_PLAYER_VIDEO_PLAYER_WINDOWS_WINDOWS_VIDEO_PLAYER_H_
#define PACKAGES_VIDEO_PLAYER_VIDEO_PLAYER_WINDOWS_WINDOWS_VIDEO_PLAYER_H_

#include <flutter/event_channel.h>
#include <flutter/event_stream_handler.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>
#undef GetCurrentTime
#include <shobjidl.h>
#include <unknwn.h>
#include <wincodec.h>

// STL headers.
#include <functional>
#include <future>
#include <map>
#include <memory>
#include <mutex>
#include <sstream>
#include <string>

// Include prior to C++/WinRT Headers.
#include <wil/cppwinrt.h>

// Windows Implementation Library.
#include <wil/resource.h>

// MediaFoundation headers.
#include <Audioclient.h>
#include <d3d11.h>
#include <mfapi.h>
#include <mferror.h>
#include <mfmediaengine.h>
#include <wincodec.h>

#include "MediaEngineWrapper.h"
#include "MediaFoundationHelpers.h"
#include "messages.h"

namespace video_player_windows {

class VideoPlayer {
 public:
  VideoPlayer(IDXGIAdapter* adapter, HWND window, std::wstring uri,
              flutter::EncodableMap http_headers);

  virtual ~VideoPlayer();

  void Dispose();
  void SetLooping(bool is_looping);
  void SetVolume(double volume);
  void SetPlaybackSpeed(double speed);
  void Play();
  void Pause();
  int64_t GetPosition();
  void SendBufferingUpdate();
  void SeekTo(int64_t seek);
  int64_t GetTextureId();
  bool IsValid();

  FlutterDesktopGpuSurfaceDescriptor* ObtainDescriptorCallback(size_t width,
                                                               size_t height);

  void Init(flutter::BinaryMessenger* messenger,
            std::function<void(int64_t)> texture_frame_available_callback,
            flutter::TextureRegistrar* texture_registry);

 private:
  void SendInitialized();
  void SetBuffering(bool buffering);

  void OnMediaInitialized();
  void OnMediaError(MF_MEDIA_ENGINE_ERR error, HRESULT hr);
  void OnMediaStateChange(MediaEngineWrapper::BufferingState state);
  void OnPlaybackEnded();
  void UpdateVideoSize();

  // Media members.
  MFPlatformRef mf_platform_;
  winrt::com_ptr<MediaEngineWrapper> media_engine_wrapper_;

  wil::critical_section lock_;
  winrt::Windows::Foundation::Size window_size_{};

  std::atomic<bool> valid_ = true;
  flutter::TextureVariant texture_;
  int64_t texture_id_;

  FlutterDesktopGpuSurfaceDescriptor descriptor_{};
  std::mutex buffer_mutex_;
  HWND window_;
  std::function<void(int64_t)> texture_frame_available_callback_;

  bool is_initialized_ = false;

  std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>>
      event_channel_;

  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> event_sink_;
};

}  // namespace video_player_windows

#endif  // PACKAGES_VIDEO_PLAYER_VIDEO_PLAYER_WINDOWS_WINDOWS_VIDEO_PLAYER_H_