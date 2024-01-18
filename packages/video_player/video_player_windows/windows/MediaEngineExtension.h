// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#ifndef PACKAGES_VIDEO_PLAYER_VIDEO_PLAYER_WINDOWS_WINDOWS_MEDIA_ENGINE_EXTENSION_H_
#define PACKAGES_VIDEO_PLAYER_VIDEO_PLAYER_WINDOWS_WINDOWS_MEDIA_ENGINE_EXTENSION_H_

namespace video_player_windows {

// This implementation of IMFMediaEngineExtension is used to integrate a custom
// IMFMediaSource with the MediaEngine pipeline
class MediaEngineExtension
    : public winrt::implements<MediaEngineExtension, IMFMediaEngineExtension> {
 public:
  MediaEngineExtension() = default;
  ~MediaEngineExtension() override = default;

  // IMFMediaEngineExtension
  IFACEMETHOD(CanPlayType)
  (BOOL is_audio_only, BSTR mime_type,
   MF_MEDIA_ENGINE_CANPLAY* result) noexcept override;
  IFACEMETHOD(BeginCreateObject)
  (BSTR url, IMFByteStream* byte_stream, MF_OBJECT_TYPE type,
   IUnknown** cancel_cookie, IMFAsyncCallback* callback,
   IUnknown* state) noexcept override;
  IFACEMETHOD(CancelObjectCreation)(IUnknown* cancel_cookie) noexcept override;
  IFACEMETHOD(EndCreateObject)
  (IMFAsyncResult* result, IUnknown** object) noexcept override;

  // Public methods
  void SetMediaSource(IUnknown* mf_media_source);
  void Shutdown();

 private:
  wil::critical_section lock_;
  enum class ExtensionUriType { kUnknown = 0, kCustomSource };
  ExtensionUriType uri_type_ = ExtensionUriType::kUnknown;
  bool has_shutdown_ = false;
  winrt::com_ptr<IUnknown> mf_media_source_;
};

}  // namespace video_player_windows

#endif  // PACKAGES_VIDEO_PLAYER_VIDEO_PLAYER_WINDOWS_WINDOWS_MEDIA_ENGINE_EXTENSION_H_