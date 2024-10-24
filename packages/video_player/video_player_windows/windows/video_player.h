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

// The VideoPlayer class represents a video player instance.
// This class provides methods to control video playback, such as play, pause,
// seek, and set volume. It also handles media initialization, error handling,
// and event notifications.
class VideoPlayer {
 public:
  VideoPlayer(IDXGIAdapter* adapter, std::wstring uri,
              flutter::EncodableMap http_headers);

  virtual ~VideoPlayer() = default;

  // Releases any resources held by the video player and prepares it for
  // destruction.
  void Dispose(flutter::TextureRegistrar* texture_registry);
  // Sets the video's looping attribute to the given value.
  void SetLooping(bool is_looping);
  // Sets the video's volume to the given value.
  void SetVolume(double volume);
  // Sets the video's playback speed to the given value.
  void SetPlaybackSpeed(double speed);
  // Starts or resumes video playback.
  void Play();
  // Pauses video playback.
  void Pause();
  // Returns the current playback position.
  int64_t GetPosition();
  // Sends the current playback position to the Dart side.
  void SendBufferingUpdate();
  // Sets the video's position to the given value.
  void SeekTo(int64_t seek);
  // Returns the video's duration.
  int64_t GetTextureId();

  // Callback for Flutter's GpuSurfaceTexture descriptor.
  FlutterDesktopGpuSurfaceDescriptor* ObtainDescriptorCallback(size_t width,
                                                               size_t height);

  // Initializes the video player.
  void Init(flutter::BinaryMessenger* messenger,
            std::function<void(int64_t)> texture_frame_available_callback,
            flutter::TextureRegistrar* texture_registry);

 private:
  // Sends the initialized event to the Dart side, with the video's duration and
  // size.
  void SendInitialized();

  // Sends the bufferingStart or bufferingEnd event to the Dart side, depending
  // on the given buffering state.
  void SetBuffering(bool buffering);

  // MediaEngineWrapper initialization callback.
  void OnMediaInitialized();

  // Sends the error event to the Dart side, with the given error code and
  // description.
  void OnMediaError(MF_MEDIA_ENGINE_ERR error, HRESULT hr);

  // MediaEngineWrapper buffering state change callback.
  void OnMediaStateChange(MediaEngineWrapper::BufferingState state);

  // MediaEngineWrapper playback ended callback.
  void OnPlaybackEnded();

  // Update's MediaEngineWrapper's video size.
  void UpdateVideoSize(uint32_t width, uint32_t height);

  // Media members.
  MFPlatformRef mf_platform_;

  // MediaEngineWrapper instance.
  winrt::com_ptr<MediaEngineWrapper> media_engine_wrapper_;

  // The internal texture instance.
  flutter::TextureVariant texture_;
  // The texture identifier from Flutter.
  int64_t texture_id_;

  // The Surface Descriptor sent to Flutter when a texture frame is available.
  FlutterDesktopGpuSurfaceDescriptor descriptor_{};

  // A mutex is used to synchronize access to the texture descriptor.
  std::mutex buffer_mutex_;

  // The callback to invoke when a texture frame is available.
  std::function<void(int64_t)> texture_frame_available_callback_;

  // A flag indicating whether the video is initialized, to avoid sending the
  // event multiple times.
  bool is_initialized_ = false;

  // The internal Flutter event channel instance.
  std::unique_ptr<flutter::EventChannel<flutter::EncodableValue>>
      event_channel_;

  // The internal Flutter event sink instance, used to send events to the Dart
  // side.
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> event_sink_;
};

}  // namespace video_player_windows

#endif  // PACKAGES_VIDEO_PLAYER_VIDEO_PLAYER_WINDOWS_WINDOWS_VIDEO_PLAYER_H_