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

#undef GetCurrentTime

using namespace winrt;

VideoPlayer::VideoPlayer(std::string asset) : VideoPlayer() {
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

  m_mediaEngineWrapper->Initialize(mediaSource.get());
}

VideoPlayer::VideoPlayer(std::string uri, flutter::EncodableMap httpHeaders)
    : VideoPlayer() {
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

  m_mediaEngineWrapper->Initialize(mediaSource.get());
}

VideoPlayer::VideoPlayer()
    : texture(flutter::PixelBufferTexture(
          std::bind(&VideoPlayer::CopyBufferCallback, this,
                    std::placeholders::_1, std::placeholders::_2))) {
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

FlutterDesktopPixelBuffer* VideoPlayer::CopyBufferCallback(size_t width,
                                                           size_t height) {
  // Lock buffer mutex to protect texture processing
  std::unique_lock<std::mutex> buffer_lock(m_buffer_mutex);

  m_windowSize.Width = (float)width;
  m_windowSize.Height = (float)height;

  const uint32_t bytes_per_pixel = 4;
  // Draw anything, for now
  m_buffer.width = width;
  m_buffer.height = height;
  auto buffer = new uint8_t[m_buffer.width * m_buffer.height * bytes_per_pixel];
  m_buffer.buffer = buffer;
  for (auto x = 0; x < m_buffer.width; x++) {
    for (auto y = 0; y < m_buffer.height; y++) {
      buffer[x * m_buffer.height + y + 0] =
          (x * m_buffer.height + y) % 256 - 127;
      buffer[x * m_buffer.height + y + 1] =
          (x * m_buffer.height + y) % 256 - 127;
      buffer[x * m_buffer.height + y + 2] =
          (x * m_buffer.height + y) % 256 - 127;
      buffer[x * m_buffer.height + y + 3] = 127;
    }
  }

  UpdateVideoSize();

  m_buffer.release_callback = [](void* release_context) {
    auto mutex = reinterpret_cast<std::mutex*>(release_context);
    mutex->unlock();
  };

  m_buffer.release_context = buffer_lock.release();

  return &m_buffer;
}

void VideoPlayer::OnMediaInitialized() {
  // Create video visual and add it to the DCOMP tree
  SetupVideoVisual();

  // Start playback
  m_mediaEngineWrapper->StartPlayingFrom(0);
}

void VideoPlayer::SetupVideoVisual() {
  auto lock = m_compositionLock.lock();

  // Complete setting up video visual if we have a surface from the media engine
  // and the visual tree has been initialized
  HANDLE videoSurfaceHandle =
      m_mediaEngineWrapper ? m_mediaEngineWrapper->GetSurfaceHandle() : NULL;

  if (!m_videoVisual && videoSurfaceHandle != NULL && m_target) {
    Compositor compositor = m_target.Compositor();

    // Create sprite visual for video
    SpriteVisual visual = compositor.CreateSpriteVisual();

    visual.Offset({
        0.0f,
        0.0f,
        0.0f,
    });

    // Use the ABI ICompositorInterop interface to create an ABI composition
    // surface using the video surface handle from the media engine
    winrt::com_ptr<abi::ICompositorInterop> compositorInterop{
        compositor.as<abi::ICompositorInterop>()};
    winrt::com_ptr<abi::ICompositionSurface> abiCompositionSurface;
    THROW_IF_FAILED(compositorInterop->CreateCompositionSurfaceForHandle(
        videoSurfaceHandle, abiCompositionSurface.put()));

    // Convert from ABI ICompositionSurface type to winrt CompositionSurface
    CompositionVisualSurface compositionSurface{nullptr};
    winrt::copy_from_abi(compositionSurface, abiCompositionSurface.get());

    // Setup surface brush with surface from MediaEngineWrapper
    CompositionSurfaceBrush surfaceBrush{compositor.CreateSurfaceBrush()};
    surfaceBrush.Surface(compositionSurface);
    visual.Brush(surfaceBrush);

    // Insert video visual intro tree
    m_videoVisual = visual;
    UpdateVideoSize();
    m_target.Root(m_videoVisual);
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
    m_videoVisual.Size({width, height});
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