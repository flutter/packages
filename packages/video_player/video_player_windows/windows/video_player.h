// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#pragma once

#include <flutter/event_channel.h>
#include <flutter/event_stream_handler.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>
#undef GetCurrentTime
#include <shobjidl.h>
#include <unknwn.h>
#include <wincodec.h>
#include <winrt/Windows.Foundation.Collections.h>

#include <future>
#include <map>
#include <memory>
#include <sstream>
#include <string>

#include "winrt/Windows.System.h"

// Include prior to C++/WinRT Headers
#include <wil/cppwinrt.h>

// C++/WinRT Headers
#include <winrt/Windows.ApplicationModel.Core.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.UI.Core.h>
#include <winrt/Windows.UI.Input.h>

// Direct3D
#include <d3d11.h>

// Windows Implementation Library
#include <wil/resource.h>
#include <wil/result_macros.h>

// MediaFoundation headers
#include <Audioclient.h>
#include <d3d11.h>
#include <mfapi.h>
#include <mferror.h>
#include <mfmediaengine.h>
#include <wincodec.h>

// STL headers
#include <functional>
#include <map>
#include <memory>
#include <mutex>
#include <sstream>
#include <string>

#include "MediaEngineWrapper.h"
#include "MediaFoundationHelpers.h"
#include "messages.h"

using namespace Messages;

using namespace winrt;

class VideoPlayer {
 public:
  VideoPlayer(IDXGIAdapter* adapter, HWND window, std::wstring uri,
              flutter::EncodableMap httpHeaders);

  void Dispose();
  void SetLooping(bool isLooping);
  void SetVolume(double volume);
  void SetPlaybackSpeed(double playbackSpeed);
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
            std::function<void()> textureFrameAvailableCallback,
            int64_t textureId);

  virtual ~VideoPlayer();

  flutter::TextureVariant texture;

 private:
  // Media members
  media::MFPlatformRef m_mfPlatform;
  winrt::com_ptr<media::MediaEngineWrapper> m_mediaEngineWrapper;

  // Composition members
  wil::critical_section m_compositionLock;
  winrt::Windows::Foundation::Size m_windowSize{};

  std::atomic<bool> m_valid = true;
  int64_t m_textureId;

  FlutterDesktopGpuSurfaceDescriptor m_descriptor{};
  std::mutex m_buffer_mutex;
  winrt::com_ptr<IDXGIAdapter> m_adapter;
  HWND m_window;
  std::function<void()> m_textureFrameAvailableCallback;

  bool isInitialized = false;

  void SendInitialized();
  void SetBuffering(bool buffering);

  void OnMediaInitialized();
  void OnMediaError(MF_MEDIA_ENGINE_ERR error, HRESULT hr);
  void OnMediaStateChange(
      media::MediaEngineWrapper::BufferingState bufferingState);
  void OnPlaybackEnded();
  void UpdateVideoSize();

  std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>> _eventChannel;

  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> _eventSink;

  VideoPlayer(IDXGIAdapter* adapter, HWND window);
};