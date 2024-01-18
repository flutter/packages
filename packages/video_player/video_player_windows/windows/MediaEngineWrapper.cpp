// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <windows.h>

// Include prior to C++/WinRT Headers
#include <wil/cppwinrt.h>

// Windows Implementation Library
#include <wil/resource.h>

// MediaFoundation headers
#include <Audioclient.h>
#include <d3d11.h>
#include <dxgi1_2.h>
#include <mfapi.h>
#include <mferror.h>
#include <mfmediaengine.h>

// STL headers
#include <functional>
#include <memory>

#include "MediaEngineWrapper.h"

namespace video_player_windows {

namespace {
class MediaEngineCallbackHelper
    : public winrt::implements<MediaEngineCallbackHelper,
                               IMFMediaEngineNotify> {
 public:
  MediaEngineCallbackHelper(
      std::function<void()> on_loaded_cb, MediaEngineWrapper::ErrorCB error_cb,
      MediaEngineWrapper::BufferingStateChangeCB buffering_state_change_cb,
      std::function<void()> playback_ended_cb,
      std::function<void()> time_update_cb)
      : on_loaded_cb_(on_loaded_cb),
        error_cb_(error_cb),
        buffering_state_change_cb_(buffering_state_change_cb),
        playback_ended_cb_(playback_ended_cb),
        time_update_cb_(time_update_cb) {
    // Ensure that callbacks are valid
    THROW_HR_IF(E_INVALIDARG, !on_loaded_cb_);
    THROW_HR_IF(E_INVALIDARG, !error_cb_);
    THROW_HR_IF(E_INVALIDARG, !buffering_state_change_cb_);
    THROW_HR_IF(E_INVALIDARG, !playback_ended_cb_);
    THROW_HR_IF(E_INVALIDARG, !time_update_cb_);
  }
  virtual ~MediaEngineCallbackHelper() = default;

  void DetachParent() {
    auto lock = lock_.lock();
    detached_ = true;
    on_loaded_cb_ = nullptr;
    error_cb_ = nullptr;
    buffering_state_change_cb_ = nullptr;
    playback_ended_cb_ = nullptr;
    time_update_cb_ = nullptr;
  }

  // IMFMediaEngineNotify
  IFACEMETHODIMP EventNotify(DWORD event_code, DWORD_PTR param_1,
                             DWORD param_2) noexcept override try {
    auto lock = lock_.lock();
    THROW_HR_IF(MF_E_SHUTDOWN, detached_);

    switch ((MF_MEDIA_ENGINE_EVENT)event_code) {
      case MF_MEDIA_ENGINE_EVENT_LOADEDMETADATA:
        on_loaded_cb_();
        break;
      case MF_MEDIA_ENGINE_EVENT_ERROR:
        error_cb_((MF_MEDIA_ENGINE_ERR)param_1, (HRESULT)param_2);
        break;
      case MF_MEDIA_ENGINE_EVENT_PLAYING:
        buffering_state_change_cb_(
            MediaEngineWrapper::BufferingState::kHaveEnough);
        break;
      case MF_MEDIA_ENGINE_EVENT_WAITING:
        buffering_state_change_cb_(
            MediaEngineWrapper::BufferingState::kHaveNothing);
        break;
      case MF_MEDIA_ENGINE_EVENT_ENDED:
        playback_ended_cb_();
        break;
      case MF_MEDIA_ENGINE_EVENT_TIMEUPDATE:
        time_update_cb_();
        break;
      default:
        break;
    }

    return S_OK;
  }
  CATCH_RETURN();

 private:
  wil::critical_section lock_;
  std::function<void()> on_loaded_cb_;
  MediaEngineWrapper::ErrorCB error_cb_;
  MediaEngineWrapper::BufferingStateChangeCB buffering_state_change_cb_;
  std::function<void()> playback_ended_cb_;
  std::function<void()> time_update_cb_;
  bool detached_ = false;
};
}  // namespace

// Public methods

MediaEngineWrapper::~MediaEngineWrapper() {
  should_exit_loop_ = true;
  if (background_thread_.joinable()) {
    background_thread_.join();
  }
}

void MediaEngineWrapper::Initialize(winrt::com_ptr<IDXGIAdapter> adapter,
                                    IMFMediaSource* media_source) {
  RunSyncInMTA([&]() {
    adapter_ = adapter;
    InitializeVideo();
    CreateMediaEngine(media_source);
  });
}

void MediaEngineWrapper::Pause() {
  RunSyncInMTA([&]() {
    auto lock = lock_.lock();
    THROW_IF_FAILED(media_engine_->Pause());
  });
}

void MediaEngineWrapper::Shutdown() {
  RunSyncInMTA([&]() {
    auto lock = lock_.lock();
    THROW_IF_FAILED(media_engine_->Shutdown());
  });
}

void MediaEngineWrapper::StartPlayingFrom(uint64_t time_stamp) {
  RunSyncInMTA([&]() {
    auto lock = lock_.lock();
    const double time_stamp_in_seconds = ConvertMsToSeconds(time_stamp);
    THROW_IF_FAILED(media_engine_->SetCurrentTime(time_stamp_in_seconds));
    THROW_IF_FAILED(media_engine_->Play());
  });
}

void MediaEngineWrapper::SetPlaybackRate(double playback_rate) {
  RunSyncInMTA([&]() {
    auto lock = lock_.lock();
    THROW_IF_FAILED(media_engine_->SetPlaybackRate(playback_rate));
  });
}

void MediaEngineWrapper::SetVolume(float volume) {
  RunSyncInMTA([&]() {
    auto lock = lock_.lock();
    THROW_IF_FAILED(media_engine_->SetVolume(volume));
  });
}

void MediaEngineWrapper::SetLooping(bool is_looping) {
  RunSyncInMTA([&]() {
    auto lock = lock_.lock();
    THROW_IF_FAILED(media_engine_->SetLoop(is_looping));
  });
}

void MediaEngineWrapper::SeekTo(uint64_t time_stamp) {
  RunSyncInMTA([&]() {
    auto lock = lock_.lock();
    const double time_stamp_in_seconds = ConvertMsToSeconds(time_stamp);
    THROW_IF_FAILED(media_engine_->SetCurrentTime(time_stamp_in_seconds));
  });
}

uint64_t MediaEngineWrapper::GetMediaTime() {
  uint64_t current_time_in_ms = 0;
  RunSyncInMTA([&]() {
    auto lock = lock_.lock();
    double current_time_in_seconds = media_engine_->GetCurrentTime();
    current_time_in_ms = ConvertSecondsToMs(current_time_in_seconds);
  });
  return current_time_in_ms;
}

uint64_t MediaEngineWrapper::GetDuration() {
  uint64_t duration_in_ms = 0;
  RunSyncInMTA([&]() {
    auto lock = lock_.lock();
    double duration_in_seconds = media_engine_->GetDuration();
    duration_in_ms = ConvertSecondsToMs(duration_in_seconds);
  });
  return duration_in_ms;
}

std::vector<std::tuple<uint64_t, uint64_t>>
MediaEngineWrapper::GetBufferedRanges() {
  std::vector<std::tuple<uint64_t, uint64_t>> result;
  RunSyncInMTA([&]() {
    auto lock = lock_.lock();

    winrt::com_ptr<IMFMediaTimeRange> media_time_range;
    THROW_IF_FAILED(media_engine_->GetBuffered(media_time_range.put()));

    double start;
    double end;
    for (uint32_t i = 0; i < media_time_range->GetLength(); i++) {
      media_time_range->GetStart(i, &start);
      media_time_range->GetEnd(i, &end);
      result.push_back(
          std::make_tuple(ConvertSecondsToMs(start), ConvertSecondsToMs(end)));
    }
  });
  return result;
}

void MediaEngineWrapper::GetNativeVideoSize(uint32_t& cx, uint32_t& cy) {
  cx = 0;
  cy = 0;

  RunSyncInMTA([&]() {
    auto lock = lock_.lock();

    DWORD x, y;
    media_engine_->GetNativeVideoSize(&x, &y);

    cx = x;
    cy = y;
  });
}

bool MediaEngineWrapper::EnsureTextureCreated(DWORD width, DWORD height) {
  bool should_create = false;
  D3D11_TEXTURE2D_DESC desc;

  if (!texture_) {
    should_create = true;
  } else {
    texture_->GetDesc(&desc);
    if (desc.Width != width || desc.Height != height) {
      should_create = true;
    }
  }

  if (should_create) {
    RtlZeroMemory(&desc, sizeof(D3D11_TEXTURE2D_DESC));
    desc.Width = width;
    desc.Height = height;
    desc.MipLevels = 1;
    desc.ArraySize = 1;
    desc.Format = DXGI_FORMAT_B8G8R8A8_UNORM;

    desc.SampleDesc.Count = 1;
    desc.Usage = D3D11_USAGE_DEFAULT;
    desc.BindFlags = D3D11_BIND_RENDER_TARGET | D3D11_BIND_SHADER_RESOURCE;
    desc.CPUAccessFlags = 0;
    desc.MiscFlags = D3D11_RESOURCE_MISC_SHARED;

    THROW_IF_FAILED(
        d3d11_device_->CreateTexture2D(&desc, nullptr, texture_.put()));
  }

  return should_create;
}

void MediaEngineWrapper::UpdateSurfaceDescriptor(
    uint32_t width, uint32_t height, std::function<void()> callback,
    FlutterDesktopGpuSurfaceDescriptor& descriptor) {
  if (descriptor.struct_size == 0) {
    descriptor.struct_size = sizeof(FlutterDesktopGpuSurfaceDescriptor);
    descriptor.format = kFlutterDesktopPixelFormatNone;
  }

  if (EnsureTextureCreated(width, height)) {
    UpdateDXTexture(width, height);

    StartBackgroundThread(callback);

    winrt::com_ptr<IDXGIResource1> sp_dxgi_resource =
        texture_.as<IDXGIResource1>();

    if (sp_dxgi_resource) {
      THROW_IF_FAILED(
          sp_dxgi_resource->GetSharedHandle(&video_surface_shared_handle_));
    }

    descriptor.handle = video_surface_shared_handle_;
    D3D11_TEXTURE2D_DESC desc;
    texture_->GetDesc(&desc);
    descriptor.width = descriptor.visible_width = desc.Width;
    descriptor.height = descriptor.visible_height = desc.Height;
    descriptor.release_context = texture_.get();
    descriptor.release_callback = [](void* release_context) {
      auto texture = reinterpret_cast<ID3D11Texture2D*>(release_context);
      texture->Release();
    };
  }
  texture_->AddRef();
}

void MediaEngineWrapper::StartBackgroundThread(std::function<void()> callback) {
  if (background_thread_.joinable()) {
    return;
  }

  should_exit_loop_ = false;
  background_thread_ = std::thread([this, callback]() {
    auto next = std::chrono::high_resolution_clock::now();
    while (!should_exit_loop_) {
      RunSyncInMTA([&]() {
        auto lock = lock_.lock();
        if (UpdateDXTexture()) {
          callback();
        }
      });

      next += std::chrono::milliseconds(16);
      std::this_thread::sleep_until(next);
    }
  });
}

bool MediaEngineWrapper::UpdateDXTexture() {
  D3D11_TEXTURE2D_DESC desc;

  if (!texture_) {
    return false;
  }

  texture_->GetDesc(&desc);
  return UpdateDXTexture(desc.Width, desc.Height);
}

bool MediaEngineWrapper::UpdateDXTexture(DWORD width, DWORD height) {
  auto rc_normalized = MFVideoNormalizedRect();

  RECT rect;
  rect.top = 0;
  rect.left = 0;
  rect.bottom = height;
  rect.right = width;

  LONGLONG pts;
  if (media_engine_->OnVideoStreamTick(&pts) == S_OK) {
    HRESULT hr = media_engine_->TransferVideoFrame(
        texture_.get(), &rc_normalized, &rect, nullptr);

    if (hr == S_OK) {
      return true;
    }
  }

  return false;
}

void MediaEngineWrapper::OnWindowUpdate(uint32_t width, uint32_t height) {
  RunSyncInMTA([&]() {
    auto lock = lock_.lock();

    if (width != width_ || height != height_) {
      width_ = width;
      height_ = height;
    }

    if (media_engine_) {
      RECT dest_rect{0, 0, static_cast<LONG>(width_),
                     static_cast<LONG>(height_)};
      winrt::com_ptr<IMFMediaEngineEx> media_engine_ex =
          media_engine_.as<IMFMediaEngineEx>();
      THROW_IF_FAILED(
          media_engine_ex->UpdateVideoStream(nullptr, &dest_rect, nullptr));
    }
  });
}

// Internal methods

void MediaEngineWrapper::CreateMediaEngine(IMFMediaSource* media_source) {
  winrt::com_ptr<IMFMediaEngineClassFactory> class_factory;
  winrt::com_ptr<IMFAttributes> creation_attributes;

  platform_ref_.Startup();

  InitializeVideo();

  THROW_IF_FAILED(MFCreateAttributes(creation_attributes.put(), 7));
  callback_helper_ = winrt::make<MediaEngineCallbackHelper>(
      [&]() { OnLoaded(); },
      [&](MF_MEDIA_ENGINE_ERR error, HRESULT hr) { OnError(error, hr); },
      [&](BufferingState state) { OnBufferingStateChange(state); },
      [&]() { OnPlaybackEnded(); }, [&]() { OnTimeUpdate(); });
  THROW_IF_FAILED(creation_attributes->SetUnknown(MF_MEDIA_ENGINE_CALLBACK,
                                                  callback_helper_.get()));
  THROW_IF_FAILED(
      creation_attributes->SetUINT32(MF_MEDIA_ENGINE_CONTENT_PROTECTION_FLAGS,
                                     MF_MEDIA_ENGINE_ENABLE_PROTECTED_CONTENT));
  THROW_IF_FAILED(creation_attributes->SetGUID(
      MF_MEDIA_ENGINE_BROWSER_COMPATIBILITY_MODE,
      MF_MEDIA_ENGINE_BROWSER_COMPATIBILITY_MODE_IE_EDGE));
  THROW_IF_FAILED(creation_attributes->SetUINT32(MF_MEDIA_ENGINE_AUDIO_CATEGORY,
                                                 AudioCategory_Media));

  if (dxgi_device_manager_ != nullptr) {
    THROW_IF_FAILED(creation_attributes->SetUnknown(
        MF_MEDIA_ENGINE_DXGI_MANAGER, dxgi_device_manager_.get()));
  }

  media_engine_extension_ = winrt::make_self<MediaEngineExtension>();
  THROW_IF_FAILED(creation_attributes->SetUnknown(
      MF_MEDIA_ENGINE_EXTENSION, media_engine_extension_.get()));

  THROW_IF_FAILED(CoCreateInstance(CLSID_MFMediaEngineClassFactory, nullptr,
                                   CLSCTX_INPROC_SERVER,
                                   IID_PPV_ARGS(class_factory.put())));
  THROW_IF_FAILED(class_factory->CreateInstance(0, creation_attributes.get(),
                                                media_engine_.put()));

  winrt::com_ptr<IUnknown> source_unknown;
  THROW_IF_FAILED(
      media_source->QueryInterface(IID_PPV_ARGS(source_unknown.put())));
  media_engine_extension_->SetMediaSource(source_unknown.get());

  winrt::com_ptr<IMFMediaEngineEx> media_engine_ex =
      media_engine_.as<IMFMediaEngineEx>();
  if (!has_set_source_) {
    wil::unique_bstr source = wil::make_bstr(L"customSrc");
    THROW_IF_FAILED(media_engine_ex->SetSource(source.get()));
    has_set_source_ = true;
  } else {
    THROW_IF_FAILED(media_engine_ex->Load());
  }
}

void MediaEngineWrapper::InitializeVideo() {
  dxgi_device_manager_ = nullptr;
  THROW_IF_FAILED(MFLockDXGIDeviceManager(&device_reset_token_,
                                          dxgi_device_manager_.put()));

  UINT creation_flags = 0;
  constexpr D3D_FEATURE_LEVEL feature_levels[] = {D3D_FEATURE_LEVEL_10_0};

  THROW_IF_FAILED(D3D11CreateDevice(
      adapter_.get(), D3D_DRIVER_TYPE_UNKNOWN, 0, creation_flags,
      feature_levels, ARRAYSIZE(feature_levels), D3D11_SDK_VERSION,
      d3d11_device_.put(), nullptr, nullptr));

  winrt::com_ptr<ID3D10Multithread> multithreaded_device =
      d3d11_device_.as<ID3D10Multithread>();
  multithreaded_device->SetMultithreadProtected(TRUE);

  THROW_IF_FAILED(dxgi_device_manager_->ResetDevice(d3d11_device_.get(),
                                                    device_reset_token_));
}

// Callback methods

void MediaEngineWrapper::OnLoaded() {
  // Call asynchronously to prevent potential deadlock due to lock inversion
  // Ensure that the callback lambda holds a reference to this object to ensure
  // that it isn't destroyed while there is a pending callback
  winrt::com_ptr<MediaEngineWrapper> ref;
  ref.copy_from(this);
  MFPutWorkItem([&, ref]() {
    {
      auto lock = lock_.lock();
      winrt::com_ptr<IMFMediaEngineEx> media_engine_ex =
          media_engine_.as<IMFMediaEngineEx>();
      THROW_IF_FAILED(media_engine_ex->EnableWindowlessSwapchainMode(true));

      // If the wrapper has been notified of the actual window width / height,
      // use the correct values, otherwise, use a default size of 640x480
      uint32_t width = width_ != 0 ? width_ : 640;
      uint32_t height = height_ != 0 ? height_ : 480;
      OnWindowUpdate(width, height);
    }
    initialized_cb_();
  });
}

void MediaEngineWrapper::OnError(MF_MEDIA_ENGINE_ERR error, HRESULT hr) {
  if (error_cb_) {
    error_cb_(error, hr);
  }
}

void MediaEngineWrapper::OnBufferingStateChange(BufferingState state) {
  if (buffering_state_change_cb_) {
    buffering_state_change_cb_(state);
  }
}

void MediaEngineWrapper::OnPlaybackEnded() {
  if (playback_ended_cb_) {
    playback_ended_cb_();
  }
}

void MediaEngineWrapper::OnTimeUpdate() {
  if (time_update_cb_) {
    time_update_cb_();
  }
}

}  // namespace video_player_windows
