// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <windows.h>

// Include ABI composition headers for interop with DCOMP surface handle from
// MediaEngine
#include <windows.ui.composition.h>
#include <windows.ui.composition.interop.h>

// Include prior to C++/WinRT Headers
#include <wil/cppwinrt.h>

// C++/WinRT Headers
#include <winrt/Windows.ApplicationModel.Core.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.UI.Composition.h>
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

// STL headers
#include <functional>
#include <memory>

#include "MediaEngineWrapper.h"
#include "MediaFoundationHelpers.h"

using namespace Microsoft::WRL;

namespace media {

namespace {
class MediaEngineCallbackHelper
    : public winrt::implements<MediaEngineCallbackHelper,
                               IMFMediaEngineNotify> {
 public:
  MediaEngineCallbackHelper(
      std::function<void()> onLoadedCB, MediaEngineWrapper::ErrorCB errorCB,
      MediaEngineWrapper::BufferingStateChangeCB bufferingStateChangeCB,
      std::function<void()> playbackEndedCB, std::function<void()> timeUpdateCB)
      : m_onLoadedCB(onLoadedCB),
        m_errorCB(errorCB),
        m_bufferingStateChangeCB(bufferingStateChangeCB),
        m_playbackEndedCB(playbackEndedCB),
        m_timeUpdateCB(timeUpdateCB) {
    // Ensure that callbacks are valid
    THROW_HR_IF(E_INVALIDARG, !m_onLoadedCB);
    THROW_HR_IF(E_INVALIDARG, !m_errorCB);
    THROW_HR_IF(E_INVALIDARG, !m_bufferingStateChangeCB);
    THROW_HR_IF(E_INVALIDARG, !m_playbackEndedCB);
    THROW_HR_IF(E_INVALIDARG, !m_timeUpdateCB);
  }
  virtual ~MediaEngineCallbackHelper() = default;

  void DetachParent() {
    auto lock = m_lock.lock();
    m_detached = true;
    m_onLoadedCB = nullptr;
    m_errorCB = nullptr;
    m_bufferingStateChangeCB = nullptr;
    m_playbackEndedCB = nullptr;
    m_timeUpdateCB = nullptr;
  }

  // IMFMediaEngineNotify
  IFACEMETHODIMP EventNotify(DWORD eventCode, DWORD_PTR param1,
                             DWORD param2) noexcept override try {
    auto lock = m_lock.lock();
    THROW_HR_IF(MF_E_SHUTDOWN, m_detached);

    switch ((MF_MEDIA_ENGINE_EVENT)eventCode) {
      case MF_MEDIA_ENGINE_EVENT_LOADEDMETADATA:
        m_onLoadedCB();
        break;
      case MF_MEDIA_ENGINE_EVENT_ERROR:
        m_errorCB((MF_MEDIA_ENGINE_ERR)param1, (HRESULT)param2);
        break;
      case MF_MEDIA_ENGINE_EVENT_PLAYING:
        m_bufferingStateChangeCB(
            MediaEngineWrapper::BufferingState::HAVE_ENOUGH);
        break;
      case MF_MEDIA_ENGINE_EVENT_WAITING:
        m_bufferingStateChangeCB(
            MediaEngineWrapper::BufferingState::HAVE_NOTHING);
        break;
      case MF_MEDIA_ENGINE_EVENT_ENDED:
        m_playbackEndedCB();
        break;
      case MF_MEDIA_ENGINE_EVENT_TIMEUPDATE:
        m_timeUpdateCB();
        break;
      default:
        break;
    }

    return S_OK;
  }
  CATCH_RETURN();

 private:
  wil::critical_section m_lock;
  std::function<void()> m_onLoadedCB;
  MediaEngineWrapper::ErrorCB m_errorCB;
  MediaEngineWrapper::BufferingStateChangeCB m_bufferingStateChangeCB;
  std::function<void()> m_playbackEndedCB;
  std::function<void()> m_timeUpdateCB;
  bool m_detached = false;
};
}  // namespace

// Public methods

void MediaEngineWrapper::Initialize(IMFMediaSource* mediaSource) {
  RunSyncInMTA([&]() {
    InitializeVideo();
    CreateMediaEngine(mediaSource);
  });
}

void MediaEngineWrapper::Pause() {
  RunSyncInMTA([&]() {
    auto lock = m_lock.lock();
    THROW_IF_FAILED(m_mediaEngine->Pause());
  });
}

void MediaEngineWrapper::Shutdown() {
  RunSyncInMTA([&]() {
    auto lock = m_lock.lock();
    THROW_IF_FAILED(m_mediaEngine->Shutdown());
  });
}

void MediaEngineWrapper::StartPlayingFrom(uint64_t timeStamp) {
  RunSyncInMTA([&]() {
    auto lock = m_lock.lock();
    const double timestampInSeconds = ConvertHnsToSeconds(timeStamp);
    THROW_IF_FAILED(m_mediaEngine->SetCurrentTime(timestampInSeconds));
    THROW_IF_FAILED(m_mediaEngine->Play());
  });
}

void MediaEngineWrapper::SetPlaybackRate(double playbackRate) {
  RunSyncInMTA([&]() {
    auto lock = m_lock.lock();
    THROW_IF_FAILED(m_mediaEngine->SetPlaybackRate(playbackRate));
  });
}

void MediaEngineWrapper::SetVolume(float volume) {
  RunSyncInMTA([&]() {
    auto lock = m_lock.lock();
    THROW_IF_FAILED(m_mediaEngine->SetVolume(volume));
  });
}

void MediaEngineWrapper::SetLooping(bool isLooping) {
  RunSyncInMTA([&]() {
    auto lock = m_lock.lock();
    THROW_IF_FAILED(m_mediaEngine->SetLoop(isLooping));
  });
}

void MediaEngineWrapper::SeekTo(uint64_t timeStamp) {
  RunSyncInMTA([&]() {
    auto lock = m_lock.lock();
    const double timestampInSeconds = ConvertHnsToSeconds(timeStamp);
    THROW_IF_FAILED(m_mediaEngine->SetCurrentTime(timestampInSeconds));
  });
}

uint64_t MediaEngineWrapper::GetMediaTime() {
  uint64_t currentTimeInHns = 0;
  RunSyncInMTA([&]() {
    auto lock = m_lock.lock();
    double currentTimeInSeconds = m_mediaEngine->GetCurrentTime();
    currentTimeInHns = ConvertSecondsToHns(currentTimeInSeconds);
  });
  return currentTimeInHns;
}

uint64_t MediaEngineWrapper::GetDuration() {
  uint64_t durationInHns = 0;
  RunSyncInMTA([&]() {
    auto lock = m_lock.lock();
    double durationInSeconds = m_mediaEngine->GetDuration();
    durationInHns = ConvertSecondsToHns(durationInSeconds);
  });
  return durationInHns;
}

std::vector<std::tuple<uint64_t, uint64_t>>
MediaEngineWrapper::GetBufferedRanges() {
  std::vector<std::tuple<uint64_t, uint64_t>> result;
  RunSyncInMTA([&]() {
    auto lock = m_lock.lock();

    winrt::com_ptr<IMFMediaTimeRange> mediaTimeRange;
    THROW_IF_FAILED(m_mediaEngine->GetBuffered(mediaTimeRange.put()));

    double start;
    double end;
    for (uint32_t i = 0; i < mediaTimeRange->GetLength(); i++) {
      mediaTimeRange->GetStart(i, &start);
      mediaTimeRange->GetEnd(i, &end);
      result.push_back(std::make_tuple(ConvertSecondsToHns(start),
                                       ConvertSecondsToHns(end)));
    }
  });
  return result;
}

void MediaEngineWrapper::GetNativeVideoSize(uint32_t& cx, uint32_t& cy) {
  cx = 0;
  cy = 0;

  RunSyncInMTA([&]() {
    auto lock = m_lock.lock();

    DWORD x, y;
    m_mediaEngine->GetNativeVideoSize(&x, &y);

    cx = x;
    cy = y;
  });
}

HANDLE MediaEngineWrapper::GetSurfaceHandle() {
  HANDLE surfaceHandle = INVALID_HANDLE_VALUE;
  RunSyncInMTA([&]() { surfaceHandle = m_dcompSurfaceHandle.get(); });
  return surfaceHandle;
}

void MediaEngineWrapper::OnWindowUpdate(uint32_t width, uint32_t height) {
  RunSyncInMTA([&]() {
    auto lock = m_lock.lock();

    if (width != m_width || height != m_height) {
      m_width = width;
      m_height = height;
    }

    if (m_mediaEngine) {
      RECT destRect{0, 0, static_cast<LONG>(m_width),
                    static_cast<LONG>(m_height)};
      winrt::com_ptr<IMFMediaEngineEx> mediaEngineEx =
          m_mediaEngine.as<IMFMediaEngineEx>();
      THROW_IF_FAILED(
          mediaEngineEx->UpdateVideoStream(nullptr, &destRect, nullptr));
    }
  });
}

// Internal methods

void MediaEngineWrapper::CreateMediaEngine(IMFMediaSource* mediaSource) {
  winrt::com_ptr<IMFMediaEngineClassFactory> classFactory;
  winrt::com_ptr<IMFAttributes> creationAttributes;

  m_platformRef.Startup();

  InitializeVideo();

  THROW_IF_FAILED(MFCreateAttributes(creationAttributes.put(), 7));
  m_callbackHelper = winrt::make<MediaEngineCallbackHelper>(
      [&]() { this->OnLoaded(); },
      [&](MF_MEDIA_ENGINE_ERR error, HRESULT hr) { this->OnError(error, hr); },
      [&](BufferingState state) { this->OnBufferingStateChange(state); },
      [&]() { this->OnPlaybackEnded(); }, [&]() { this->OnTimeUpdate(); });
  THROW_IF_FAILED(creationAttributes->SetUnknown(MF_MEDIA_ENGINE_CALLBACK,
                                                 m_callbackHelper.get()));
  THROW_IF_FAILED(
      creationAttributes->SetUINT32(MF_MEDIA_ENGINE_CONTENT_PROTECTION_FLAGS,
                                    MF_MEDIA_ENGINE_ENABLE_PROTECTED_CONTENT));
  THROW_IF_FAILED(creationAttributes->SetGUID(
      MF_MEDIA_ENGINE_BROWSER_COMPATIBILITY_MODE,
      MF_MEDIA_ENGINE_BROWSER_COMPATIBILITY_MODE_IE_EDGE));
  THROW_IF_FAILED(creationAttributes->SetUINT32(MF_MEDIA_ENGINE_AUDIO_CATEGORY,
                                                AudioCategory_Media));

  if (m_dxgiDeviceManager != nullptr) {
    THROW_IF_FAILED(creationAttributes->SetUnknown(MF_MEDIA_ENGINE_DXGI_MANAGER,
                                                   m_dxgiDeviceManager.get()));
  }

  m_mediaEngineExtension = winrt::make_self<MediaEngineExtension>();
  THROW_IF_FAILED(creationAttributes->SetUnknown(MF_MEDIA_ENGINE_EXTENSION,
                                                 m_mediaEngineExtension.get()));

  THROW_IF_FAILED(CoCreateInstance(CLSID_MFMediaEngineClassFactory, nullptr,
                                   CLSCTX_INPROC_SERVER,
                                   IID_PPV_ARGS(classFactory.put())));
  THROW_IF_FAILED(classFactory->CreateInstance(0, creationAttributes.get(),
                                               m_mediaEngine.put()));

  winrt::com_ptr<IUnknown> sourceUnknown;
  THROW_IF_FAILED(
      mediaSource->QueryInterface(IID_PPV_ARGS(sourceUnknown.put())));
  m_mediaEngineExtension->SetMediaSource(sourceUnknown.get());

  winrt::com_ptr<IMFMediaEngineEx> mediaEngineEx =
      m_mediaEngine.as<IMFMediaEngineEx>();
  if (!m_hasSetSource) {
    wil::unique_bstr source = wil::make_bstr(L"customSrc");
    THROW_IF_FAILED(mediaEngineEx->SetSource(source.get()));
    m_hasSetSource = true;
  } else {
    THROW_IF_FAILED(mediaEngineEx->Load());
  }
}

void MediaEngineWrapper::InitializeVideo() {
  m_dxgiDeviceManager = nullptr;
  THROW_IF_FAILED(
      MFLockDXGIDeviceManager(&m_deviceResetToken, m_dxgiDeviceManager.put()));

  winrt::com_ptr<ID3D11Device> d3d11Device;
  UINT creationFlags =
      (D3D11_CREATE_DEVICE_VIDEO_SUPPORT | D3D11_CREATE_DEVICE_BGRA_SUPPORT |
       D3D11_CREATE_DEVICE_PREVENT_INTERNAL_THREADING_OPTIMIZATIONS);
  constexpr D3D_FEATURE_LEVEL featureLevels[] = {
      D3D_FEATURE_LEVEL_11_1, D3D_FEATURE_LEVEL_11_0, D3D_FEATURE_LEVEL_10_1,
      D3D_FEATURE_LEVEL_10_0, D3D_FEATURE_LEVEL_9_3,  D3D_FEATURE_LEVEL_9_2,
      D3D_FEATURE_LEVEL_9_1};
  THROW_IF_FAILED(D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_HARDWARE, 0,
                                    creationFlags, featureLevels,
                                    ARRAYSIZE(featureLevels), D3D11_SDK_VERSION,
                                    d3d11Device.put(), nullptr, nullptr));

  winrt::com_ptr<ID3D10Multithread> multithreadedDevice =
      d3d11Device.as<ID3D10Multithread>();
  multithreadedDevice->SetMultithreadProtected(TRUE);

  THROW_IF_FAILED(
      m_dxgiDeviceManager->ResetDevice(d3d11Device.get(), m_deviceResetToken));
}

// Callback methods

void MediaEngineWrapper::OnLoaded() {
  // Call asynchronously to prevent potential deadlock due to lock inversion
  // Ensure that the callback lambda holds a reference to this object to ensure
  // that it isn't destroyed while there is a pending callback
  winrt::com_ptr<MediaEngineWrapper> ref;
  ref.copy_from(this);
  media::MFPutWorkItem([&, ref]() {
    {
      auto lock = m_lock.lock();
      // Put media engine into DCOMP mode (as opposed to frame server mode) and
      // obtain a handle to the DCOMP surface handle
      winrt::com_ptr<IMFMediaEngineEx> mediaEngineEx =
          m_mediaEngine.as<IMFMediaEngineEx>();
      THROW_IF_FAILED(mediaEngineEx->EnableWindowlessSwapchainMode(true));

      // If the wrapper has been notified of the actual window width / height,
      // use the correct values, otherwise, use a default size of 640x480
      uint32_t width = m_width != 0 ? m_width : 640;
      uint32_t height = m_height != 0 ? m_height : 480;
      OnWindowUpdate(width, height);
      THROW_IF_FAILED(
          mediaEngineEx->GetVideoSwapchainHandle(&m_dcompSurfaceHandle));
    }
    m_initializedCB();
  });
}

void MediaEngineWrapper::OnError(MF_MEDIA_ENGINE_ERR error, HRESULT hr) {
  if (m_errorCB) {
    m_errorCB(error, hr);
  }
}

void MediaEngineWrapper::OnBufferingStateChange(BufferingState state) {
  if (m_bufferingStateChangeCB) {
    m_bufferingStateChangeCB(state);
  }
}

void MediaEngineWrapper::OnPlaybackEnded() {
  if (m_playbackEndedCB) {
    m_playbackEndedCB();
  }
}

void MediaEngineWrapper::OnTimeUpdate() {
  if (m_timeUpdateCB) {
    m_timeUpdateCB();
  }
}

}  // namespace media