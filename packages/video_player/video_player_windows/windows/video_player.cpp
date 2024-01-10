#include "video_player.h"

#include <flutter/event_channel.h>
#include <flutter/event_stream_handler.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <shobjidl.h>
#include <wil/stl.h>
#include <wil/win32_helpers.h>
#include <windows.h>

#include "DirectCompositionLayer.h"

#undef GetCurrentTime

using namespace winrt;

VideoPlayer::VideoPlayer(flutter::FlutterView* view, std::string asset) : VideoPlayer(view) {
  // Create a source resolver to create an IMFMediaSource for the content URL.
  // This will create an instance of an inbuilt OS media source for playback.
  // An application can skip this step and instantiate a custom IMFMediaSource
  // implementation instead.
  winrt::com_ptr<IMFSourceResolver> sourceResolver;
  THROW_IF_FAILED(MFCreateSourceResolver(sourceResolver.put()));
  constexpr uint32_t sourceResolutionFlags =
      MF_RESOLUTION_MEDIASOURCE | MF_RESOLUTION_READ;
  MF_OBJECT_TYPE objectType = {};

  asset = "/data/flutter_assets/" + asset;

  auto modulePath = wil::GetModuleFileNameW<std::wstring>(nullptr);

  size_t found = modulePath.find_last_of(L"/\\");
  modulePath = modulePath.substr(0, found);

  winrt::com_ptr<IMFMediaSource> mediaSource;
  THROW_IF_FAILED(sourceResolver->CreateObjectFromURL(
      ((modulePath + std::wstring(asset.begin(), asset.end()))).c_str(),
      sourceResolutionFlags, nullptr, &objectType,
      reinterpret_cast<IUnknown**>(mediaSource.put_void())));

  m_mediaEngineWrapper->Initialize(m_adapter, m_window, mediaSource.get());
}

VideoPlayer::VideoPlayer(flutter::FlutterView* view, std::string uri, flutter::EncodableMap httpHeaders)
    : VideoPlayer(view) {
  // Create a source resolver to create an IMFMediaSource for the content URL.
  // This will create an instance of an inbuilt OS media source for playback.
  // An application can skip this step and instantiate a custom IMFMediaSource
  // implementation instead.
  winrt::com_ptr<IMFSourceResolver> sourceResolver;
  THROW_IF_FAILED(MFCreateSourceResolver(sourceResolver.put()));
  constexpr uint32_t sourceResolutionFlags =
      MF_RESOLUTION_MEDIASOURCE | MF_RESOLUTION_READ;
  MF_OBJECT_TYPE objectType = {};

  winrt::com_ptr<IMFMediaSource> mediaSource;
  THROW_IF_FAILED(sourceResolver->CreateObjectFromURL(
      winrt::to_hstring(uri).c_str(), sourceResolutionFlags, nullptr,
      &objectType, reinterpret_cast<IUnknown**>(mediaSource.put_void())));

  m_mediaEngineWrapper->Initialize(m_adapter, m_window, mediaSource.get());
}

VideoPlayer::VideoPlayer(flutter::FlutterView* view)
    : texture(flutter::GpuSurfaceTexture(
          FlutterDesktopGpuSurfaceType::kFlutterDesktopGpuSurfaceTypeDxgiSharedHandle,
          std::bind(&VideoPlayer::ObtainDescriptorCallback, this,
                    std::placeholders::_1, std::placeholders::_2))) {

  m_adapter.attach(view->GetGraphicsAdapter());
  m_window = view->GetNativeWindow();

  m_mfPlatform.Startup();

  // Callbacks invoked by the media engine wrapper
  auto onInitialized = std::bind(&VideoPlayer::OnMediaInitialized, this);
  auto onError = std::bind(&VideoPlayer::OnMediaError, this,
                           std::placeholders::_1, std::placeholders::_2);
  auto onBufferingStateChanged =
      std::bind(&VideoPlayer::OnMediaStateChange, this, std::placeholders::_1);
  auto onPlaybackEndedCB = std::bind(&VideoPlayer::OnPlaybackEnded, this);

  // Create and initialize the MediaEngineWrapper which manages media playback
  m_mediaEngineWrapper = winrt::make_self<media::MediaEngineWrapper>(
      onInitialized, onError, onBufferingStateChanged, onPlaybackEndedCB,
      nullptr);
}

void VideoPlayer::Init(flutter::PluginRegistrarWindows* registrar,
                       int64_t textureId) {
  _textureId = textureId;

  _eventChannel =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
          registrar->messenger(),
          std::string("flutter.io/videoPlayer/videoEvents") +
              std::to_string(textureId),
          &flutter::StandardMethodCodec::GetInstance());

  _eventChannel->SetStreamHandler(
      std::make_unique<
          flutter::StreamHandlerFunctions<flutter::EncodableValue>>(
          [this](const flutter::EncodableValue* arguments,
                 std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&&
                     events)
              -> std::unique_ptr<
                  flutter::StreamHandlerError<flutter::EncodableValue>> {
            this->_eventSink = std::move(events);
            return nullptr;
          },
          [this](const flutter::EncodableValue* arguments)
              -> std::unique_ptr<
                  flutter::StreamHandlerError<flutter::EncodableValue>> {
            this->_eventSink = nullptr;
            return nullptr;
          }));
}

VideoPlayer::~VideoPlayer() {}

FlutterDesktopGpuSurfaceDescriptor* VideoPlayer::ObtainDescriptorCallback(size_t width,
                                                           size_t height) {

  // Lock buffer mutex to protect texture processing
  std::unique_lock<std::mutex> buffer_lock(m_buffer_mutex);

  m_descriptor = {};
  m_descriptor.struct_size = sizeof(FlutterDesktopGpuSurfaceDescriptor);
  m_descriptor.format = kFlutterDesktopPixelFormatNone;
  if (!m_videoSurfaceSharedHandle) {
    winrt::com_ptr<ID3D11Texture2D> spTexture =
        m_mediaEngineWrapper->TransferVideoFrame();

    winrt::com_ptr<IDXGIResource1> spDXGIResource =
        spTexture.as<IDXGIResource1>();

    if (spDXGIResource) {
        THROW_IF_FAILED(spDXGIResource->GetSharedHandle(&m_videoSurfaceSharedHandle));
    }

    m_descriptor.handle = m_videoSurfaceSharedHandle;
    D3D11_TEXTURE2D_DESC desc;
    spTexture->GetDesc(&desc);
    m_descriptor.width = m_descriptor.visible_width = desc.Width;
    m_descriptor.height = m_descriptor.visible_height = desc.Height;
  }
  m_descriptor.release_context = buffer_lock.release();
  m_descriptor.release_callback = [](void* release_context) {
    auto mutex = reinterpret_cast<std::mutex*>(release_context);
    mutex->unlock();
  };

  UpdateVideoSize();

  return &m_descriptor;
}

void VideoPlayer::OnMediaInitialized() {
  // Create video visual and add it to the DCOMP tree
  SetupVideoVisual();

  // Start playback
  m_mediaEngineWrapper->StartPlayingFrom(0);
}

void VideoPlayer::SetupVideoVisual() {

  // Complete setting up video visual if we have a surface from the media engine
  // and the visual tree has been initialized
  m_videoSurfaceHandle = m_mediaEngineWrapper->GetSurfaceHandle();
  m_videoSurfaceSharedHandle = 0;

  m_target = m_mediaEngineWrapper->GetCompositionTarget();

  if (!m_videoVisual && m_videoSurfaceHandle != NULL && m_target != nullptr) {

    // Create root visual and set it on the target
    // THROW_IF_FAILED(m_mediaEngineWrapper->GetCompositionDevice()->CreateVisual(m_videoVisual.put()));
    // THROW_IF_FAILED(m_target->SetRoot(m_videoVisual.get()));

    // // Create video visual and add it to the DCOMP tree
    // winrt::com_ptr<IDCompositionDevice> dcompDevice;
    // THROW_IF_FAILED(m_mediaEngineWrapper->GetCompositionDevice()->QueryInterface(IID_PPV_ARGS(dcompDevice.put())));
    // std::shared_ptr<ui::DirectCompositionLayer> videoLayer =
    //     ui::DirectCompositionLayer::CreateFromSurface(dcompDevice.get(), m_videoSurfaceHandle);
    // THROW_IF_FAILED(m_videoVisual->AddVisual(videoLayer->GetVisual(), TRUE, nullptr));
    // m_videoVisual->SetOffsetX(100);
    // m_videoVisual->SetOffsetY(100);

    UpdateVideoSize();

    //dcompDevice->Commit();
  }
}

void VideoPlayer::UpdateVideoSize() {
  auto lock = m_compositionLock.lock();

  // If the window has not been initialized yet, use a default size of 640x480
  const bool windowInitialized =
      m_windowSize.Width != 0 && m_windowSize.Height != 0;
  float width = windowInitialized ? m_windowSize.Width : 640;
  float height = windowInitialized ? m_windowSize.Height : 480;

  if (m_videoVisual) {
    // uint32_t width;
    // uint32_t height;
    // m_mediaEngineWrapper->GetNativeVideoSize(width, height);
    //m_videoVisual->(Size({width, height});
    // What to do here?
  }

  if (m_mediaEngineWrapper) {
    // Call into media engine wrapper on MTA thread to resize the video surface
    media::RunSyncInMTA([&]() {
      m_mediaEngineWrapper->OnWindowUpdate(static_cast<uint32_t>(width),
                                           static_cast<uint32_t>(height));
    });
  }
}

void VideoPlayer::OnMediaError(MF_MEDIA_ENGINE_ERR error, HRESULT hr) {
  LOG_HR_MSG(hr, "MediaEngine error (%d)", error);
}

void VideoPlayer::OnMediaStateChange(
    media::MediaEngineWrapper::BufferingState bufferingState) {
  if (bufferingState ==
      media::MediaEngineWrapper::BufferingState::HAVE_NOTHING) {
    this->SetBuffering(true);
    this->SendBufferingUpdate();
  } else {
    if (!this->isInitialized) {
      this->isInitialized = true;
      this->SendInitialized();
    }
    this->SetBuffering(false);
  }
}

void VideoPlayer::OnPlaybackEnded() {
  if (this->_eventSink) {
    this->_eventSink->Success(
        flutter::EncodableMap({{flutter::EncodableValue("event"),
                                flutter::EncodableValue("completed")}}));
  }
}

void VideoPlayer::SetBuffering(bool buffering) {
  if (_eventSink) {
    _eventSink->Success(flutter::EncodableMap(
        {{flutter::EncodableValue("event"),
          flutter::EncodableValue(buffering ? "bufferingStart"
                                            : "bufferingEnd")}}));
  }
}

void VideoPlayer::SendInitialized() {
  if (isInitialized) {
    auto event = flutter::EncodableMap(
        {{flutter::EncodableValue("event"),
          flutter::EncodableValue("initialized")},
         {flutter::EncodableValue("duration"),
          flutter::EncodableValue((int64_t)m_mediaEngineWrapper->GetDuration() *
                                  1000)}});

    uint32_t width;
    uint32_t height;
    m_mediaEngineWrapper->GetNativeVideoSize(width, height);
    // TODO
    // auto rotationDegrees = session.PlaybackRotation();
    // Switch the width/height if video was taken in portrait mode
    // if (rotationDegrees ==
    // Windows::Media::MediaProperties::MediaRotation::Clockwise90Degrees ||
    //     rotationDegrees ==
    //     Windows::Media::MediaProperties::MediaRotation::Clockwise270Degrees)
    //     { width = session.NaturalVideoHeight(); height =
    //     session.NaturalVideoWidth();
    // }
    event.insert({flutter::EncodableValue("width"),
                  flutter::EncodableValue((int32_t)width)});
    event.insert({flutter::EncodableValue("height"),
                  flutter::EncodableValue((int32_t)height)});

    if (this->_eventSink) {
      _eventSink->Success(event);
    }
  }
}

void VideoPlayer::Dispose() {
  if (isInitialized) {
    m_mediaEngineWrapper->Pause();
  }
  // textureEntry.release();
  _eventChannel = nullptr;
  /*if (surface != null) {
      surface.release();
  }
  */
  /*if (mediaPlayerElement != nullptr) {
      mediaPlayerElement = nullptr;
      desktopSource = nullptr;
  }
  */
}

void VideoPlayer::SetLooping(bool isLooping) {
  m_mediaEngineWrapper->SetLooping(isLooping);
}

void VideoPlayer::SetVolume(double volume) {
  m_mediaEngineWrapper->SetVolume((float)volume);
}

void VideoPlayer::SetPlaybackSpeed(double playbackSpeed) {
  m_mediaEngineWrapper->SetPlaybackRate(playbackSpeed);
}

void VideoPlayer::Play() {
  m_mediaEngineWrapper->StartPlayingFrom(m_mediaEngineWrapper->GetMediaTime());
}

void VideoPlayer::Pause() { m_mediaEngineWrapper->Pause(); }

int64_t VideoPlayer::GetPosition() {
  return m_mediaEngineWrapper->GetMediaTime() * 1000;
}

void VideoPlayer::SendBufferingUpdate() {
  auto values = flutter::EncodableList();
  auto ranges = m_mediaEngineWrapper->GetBufferedRanges();
  for (uint32_t i = 0; i < ranges.size(); i++) {
    auto [start, end] = ranges.at(i);
    values.push_back(flutter::EncodableList(
        {flutter::EncodableValue((int64_t)(start * 1000)),
         flutter::EncodableValue((int64_t)(end * 1000))}));
  }

  if (this->_eventSink) {
    this->_eventSink->Success(
        flutter::EncodableMap({{flutter::EncodableValue("event"),
                                flutter::EncodableValue("bufferingUpdate")},
                               {flutter::EncodableValue("values"), values}}));
  }
}

void VideoPlayer::SeekTo(int64_t seek) {
  m_mediaEngineWrapper->SeekTo(seek / 1000);
}

int64_t VideoPlayer::GetTextureId() { return _textureId; }