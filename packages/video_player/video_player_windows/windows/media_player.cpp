// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "media_player.h"

#include <d3d10.h>
#include <mfapi.h>
#include <mferror.h>
#include <mfidl.h>
#include <roapi.h>
#include <wrl/implements.h>

#include <chrono>
#include <cmath>
#include <future>
#include <limits>
#include <sstream>
#include <utility>

namespace video_player_windows {
namespace {
using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;
using Microsoft::WRL::ComPtr;

class MediaEngineNotify
    : public Microsoft::WRL::RuntimeClass<
          Microsoft::WRL::RuntimeClassFlags<Microsoft::WRL::ClassicCom>,
          IMFMediaEngineNotify> {
 public:
  explicit MediaEngineNotify(std::weak_ptr<PlayerWorkQueue> queue)
      : queue_(std::move(queue)) {}

  HRESULT STDMETHODCALLTYPE EventNotify(DWORD event, DWORD_PTR parameter,
                                        DWORD detail) override {
    if (event == MF_MEDIA_ENGINE_EVENT_NOTIFYSTABLESTATE) {
      // Media Foundation may be synchronously waiting; this cannot enter our
      // queue.
      SetEvent(reinterpret_cast<HANDLE>(parameter));
      return S_OK;
    }
    if (auto queue = queue_.lock()) {
      std::lock_guard<std::mutex> lock(queue->mutex);
      if (!queue->stopping) {
        queue->notifications.push_back({event, parameter, detail});
        queue->changed.notify_one();
      }
    }
    return S_OK;
  }

 private:
  std::weak_ptr<PlayerWorkQueue> queue_;
};
}  // namespace

std::wstring Utf16FromUtf8(const std::string& text) {
  if (text.empty()) {
    return {};
  }
  const int length =
      MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, text.data(),
                          static_cast<int>(text.size()), nullptr, 0);
  if (length == 0) {
    return {};
  }
  std::wstring result(length, L'\0');
  MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, text.data(),
                      static_cast<int>(text.size()), result.data(), length);
  return result;
}

int64_t SecondsToMilliseconds(double seconds) {
  if (!std::isfinite(seconds) || seconds <= 0) {
    return 0;
  }
  const double milliseconds = seconds * 1000.0;
  if (milliseconds >=
      static_cast<double>(std::numeric_limits<int64_t>::max())) {
    return std::numeric_limits<int64_t>::max();
  }
  return static_cast<int64_t>(std::llround(milliseconds));
}

MediaPlayer::MediaPlayer(std::string source,
                         std::shared_ptr<FrameBuffer> frames,
                         std::function<void()> frame_available,
                         EventCallback on_event, std::string network_source,
                         std::string network_relay)
    : source_(std::move(source)),
      network_source_(std::move(network_source)),
      network_relay_(std::move(network_relay)),
      frames_(std::move(frames)),
      frame_available_(std::move(frame_available)),
      on_event_(std::move(on_event)),
      queue_(std::make_shared<PlayerWorkQueue>()),
      worker_([this] { Run(); }) {}

MediaPlayer::~MediaPlayer() {
  {
    std::lock_guard<std::mutex> lock(queue_->mutex);
    queue_->stopping = true;
  }
  queue_->changed.notify_one();
  worker_.join();
}

HRESULT MediaPlayer::Invoke(std::function<HRESULT()> command) {
  auto result = std::make_shared<std::promise<HRESULT>>();
  auto future = result->get_future();
  {
    std::lock_guard<std::mutex> lock(queue_->mutex);
    if (queue_->stopping) {
      return MF_E_SHUTDOWN;
    }
    queue_->commands.push_back([this, result, command = std::move(command)] {
      result->set_value(FAILED(initialization_result_) ? initialization_result_
                                                       : command());
    });
  }
  queue_->changed.notify_one();
  return future.get();
}

void MediaPlayer::Run() {
  const HRESULT apartment = RoInitialize(RO_INIT_MULTITHREADED);
  const HRESULT foundation =
      SUCCEEDED(apartment) ? MFStartup(MF_VERSION) : apartment;
  initialization_result_ = SUCCEEDED(foundation) ? Initialize() : foundation;
  if (FAILED(initialization_result_)) {
    EmitError(initialization_result_);
  }

  for (;;) {
    std::deque<std::function<void()>> commands;
    std::deque<MediaNotification> notifications;
    {
      std::unique_lock<std::mutex> lock(queue_->mutex);
      queue_->changed.wait_for(
          lock, std::chrono::milliseconds(playing_ ? 8 : 40), [this] {
            return queue_->stopping || !queue_->commands.empty() ||
                   !queue_->notifications.empty();
          });
      if (queue_->stopping) {
        break;
      }
      commands.swap(queue_->commands);
      notifications.swap(queue_->notifications);
    }
    for (auto& command : commands) {
      command();
    }
    if (SUCCEEDED(initialization_result_) && !failed_) {
      for (const auto& notification : notifications) {
        HandleNotification(notification);
      }
      if (initialized_ && !failed_) {
        const HRESULT frame_result = RenderFrame();
        if (FAILED(frame_result)) {
          EmitError(frame_result);
        }
      }
    }
  }

  SetThreadExecutionState(ES_CONTINUOUS);
  if (adaptive_) adaptive_->Close();
  if (engine_) {
    engine_->Shutdown();
    engine_.Reset();
  }
  staging_.Reset();
  render_target_.Reset();
  device_manager_.Reset();
  context_.Reset();
  device_.Reset();
  adaptive_.reset();
  if (SUCCEEDED(foundation)) {
    MFShutdown();
  }
  if (SUCCEEDED(apartment)) {
    RoUninitialize();
  }
}

HRESULT MediaPlayer::Initialize() {
  const std::wstring source = Utf16FromUtf8(source_);
  if (source.empty()) {
    return E_INVALIDARG;
  }
  HRESULT hr = D3D11CreateDevice(
      nullptr, D3D_DRIVER_TYPE_HARDWARE, nullptr,
      D3D11_CREATE_DEVICE_VIDEO_SUPPORT | D3D11_CREATE_DEVICE_BGRA_SUPPORT,
      nullptr, 0, D3D11_SDK_VERSION, &device_, nullptr, &context_);
  if (FAILED(hr)) {
    hr = D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_WARP, nullptr,
                           D3D11_CREATE_DEVICE_BGRA_SUPPORT, nullptr, 0,
                           D3D11_SDK_VERSION, &device_, nullptr, &context_);
  }
  if (FAILED(hr)) {
    return hr;
  }
  ComPtr<ID3D10Multithread> multithread;
  if (FAILED(hr = device_.As(&multithread))) {
    return hr;
  }
  multithread->SetMultithreadProtected(TRUE);
  UINT token = 0;
  if (FAILED(hr = MFCreateDXGIDeviceManager(&token, &device_manager_)) ||
      FAILED(hr = device_manager_->ResetDevice(device_.Get(), token))) {
    return hr;
  }
  ComPtr<IMFAttributes> attributes;
  if (FAILED(hr = MFCreateAttributes(&attributes, 3))) {
    return hr;
  }
  auto notify = Microsoft::WRL::Make<MediaEngineNotify>(queue_);
  if (FAILED(hr = attributes->SetUnknown(MF_MEDIA_ENGINE_CALLBACK,
                                         notify.Get())) ||
      FAILED(hr = attributes->SetUnknown(MF_MEDIA_ENGINE_DXGI_MANAGER,
                                         device_manager_.Get())) ||
      FAILED(hr = attributes->SetUINT32(MF_MEDIA_ENGINE_VIDEO_OUTPUT_FORMAT,
                                        DXGI_FORMAT_B8G8R8A8_UNORM))) {
    return hr;
  }
  ComPtr<IMFMediaEngineClassFactory> factory;
  if (!network_source_.empty()) {
    adaptive_ = std::make_unique<AdaptiveSource>();
    if (FAILED(hr = attributes->SetUnknown(MF_MEDIA_ENGINE_EXTENSION,
                                           adaptive_->extension()))) {
      return hr;
    }
  }
  if (FAILED(hr = CoCreateInstance(CLSID_MFMediaEngineClassFactory, nullptr,
                                   CLSCTX_INPROC_SERVER,
                                   IID_PPV_ARGS(&factory))) ||
      FAILED(hr = factory->CreateInstance(0, attributes.Get(), &engine_))) {
    return hr;
  }
  if (adaptive_) {
    std::weak_ptr<PlayerWorkQueue> pending = queue_;
    adaptive_->Open(
        network_source_, network_relay_,
        [this, pending](HRESULT result, bool adaptive) {
          if (auto queue = pending.lock()) {
            std::lock_guard<std::mutex> lock(queue->mutex);
            if (queue->stopping) return;
            queue->commands.push_back([this, result, adaptive] {
              const HRESULT status =
                  FAILED(result)
                      ? result
                      : LoadSource(adaptive ? "adaptive://source" : source_);
              if (FAILED(status)) EmitError(status);
            });
            queue->changed.notify_one();
          }
        });
    return S_OK;
  }
  return LoadSource(source_);
}

HRESULT MediaPlayer::LoadSource(const std::string& location) {
  const std::wstring source = Utf16FromUtf8(location);
  BSTR url = SysAllocStringLen(source.data(), static_cast<UINT>(source.size()));
  if (!url) {
    return E_OUTOFMEMORY;
  }
  HRESULT hr = engine_->SetSource(url);
  SysFreeString(url);
  if (FAILED(hr)) {
    return hr;
  }
  return engine_->Load();
}

HRESULT MediaPlayer::EnsureRenderTargets(DWORD width, DWORD height) {
  if (render_target_ && width == width_ && height == height_) {
    return S_OK;
  }
  if (width == 0 || height == 0 || width > 16384 || height > 16384) {
    return E_INVALIDARG;
  }
  D3D11_TEXTURE2D_DESC description = {};
  description.Width = width;
  description.Height = height;
  description.MipLevels = 1;
  description.ArraySize = 1;
  description.Format = DXGI_FORMAT_B8G8R8A8_UNORM;
  description.SampleDesc.Count = 1;
  description.Usage = D3D11_USAGE_DEFAULT;
  description.BindFlags = D3D11_BIND_RENDER_TARGET;
  render_target_.Reset();
  staging_.Reset();
  HRESULT hr = device_->CreateTexture2D(&description, nullptr, &render_target_);
  if (FAILED(hr)) {
    return hr;
  }
  description.Usage = D3D11_USAGE_STAGING;
  description.BindFlags = 0;
  description.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
  if (FAILED(hr = device_->CreateTexture2D(&description, nullptr, &staging_))) {
    return hr;
  }
  width_ = width;
  height_ = height;
  return S_OK;
}

HRESULT MediaPlayer::RenderFrame() {
  if (!engine_->HasVideo()) {
    return S_OK;
  }
  LONGLONG timestamp = 0;
  HRESULT hr = engine_->OnVideoStreamTick(&timestamp);
  // S_FALSE means there is no new frame; it is not a decoder failure.
  if (hr != S_OK) {
    return hr;
  }
  DWORD width = 0;
  DWORD height = 0;
  if (FAILED(hr = engine_->GetNativeVideoSize(&width, &height)) ||
      FAILED(hr = EnsureRenderTargets(width, height))) {
    return hr;
  }
  RECT destination = {0, 0, static_cast<LONG>(width),
                      static_cast<LONG>(height)};
  MFVideoNormalizedRect source = {0, 0, 1, 1};
  MFARGB background = {0, 0, 0, 255};
  if (FAILED(hr = engine_->TransferVideoFrame(render_target_.Get(), &source,
                                              &destination, &background))) {
    return hr;
  }
  context_->CopyResource(staging_.Get(), render_target_.Get());
  D3D11_MAPPED_SUBRESOURCE mapped = {};
  if (FAILED(
          hr = context_->Map(staging_.Get(), 0, D3D11_MAP_READ, 0, &mapped))) {
    return hr;
  }
  auto frame = std::make_shared<VideoFrame>();
  frame->width = width;
  frame->height = height;
  frame->rgba.resize(static_cast<size_t>(width) * height * 4);

  // D3D rows can contain padding; Flutter requires tightly packed RGBA pixels.
  for (DWORD y = 0; y < height; ++y) {
    const auto* row =
        static_cast<const uint8_t*>(mapped.pData) + y * mapped.RowPitch;
    auto* output = frame->rgba.data() + static_cast<size_t>(y) * width * 4;
    for (DWORD x = 0; x < width; ++x) {
      output[x * 4] = row[x * 4 + 2];
      output[x * 4 + 1] = row[x * 4 + 1];
      output[x * 4 + 2] = row[x * 4];
      output[x * 4 + 3] = 255;
    }
  }
  context_->Unmap(staging_.Get(), 0);
  frames_->Publish(std::move(frame));
  frame_available_();
  return S_OK;
}

void MediaPlayer::HandleNotification(const MediaNotification& notification) {
  switch (notification.event) {
    case MF_MEDIA_ENGINE_EVENT_LOADEDMETADATA: {
      if (initialized_) {
        break;
      }
      DWORD width = 0;
      DWORD height = 0;
      engine_->GetNativeVideoSize(&width, &height);
      initialized_ = true;
      std::vector<TrackData> tracks;
      if (SUCCEEDED(ReadTracks(false, &tracks))) {
        for (const auto& track : tracks) {
          if (track.is_selected()) default_video_track_ = track.id();
        }
      }
      on_event_(
          {{{EncodableValue("event"), EncodableValue("initialized")},
            {EncodableValue("duration"),
             EncodableValue(SecondsToMilliseconds(engine_->GetDuration()))},
            {EncodableValue("width"),
             EncodableValue(static_cast<int64_t>(width))},
            {EncodableValue("height"),
             EncodableValue(static_cast<int64_t>(height))}},
           {}});
      break;
    }
    case MF_MEDIA_ENGINE_EVENT_ERROR:
      EmitError(notification.detail == 0
                    ? E_FAIL
                    : static_cast<HRESULT>(notification.detail));
      break;
    case MF_MEDIA_ENGINE_EVENT_PLAYING:
      Emit("bufferingEnd");
      EmitPlaying(true);
      break;
    case MF_MEDIA_ENGINE_EVENT_PAUSE:
      EmitPlaying(false);
      break;
    case MF_MEDIA_ENGINE_EVENT_ENDED:
      if (!engine_->GetLoop()) {
        EmitPlaying(false);
        Emit("completed");
      }
      break;
    case MF_MEDIA_ENGINE_EVENT_WAITING:
    case MF_MEDIA_ENGINE_EVENT_BUFFERINGSTARTED:
      Emit("bufferingStart");
      break;
    case MF_MEDIA_ENGINE_EVENT_CANPLAY:
      ready_to_seek_ = true;
      if (pending_seek_) {
        const double seconds = static_cast<double>(*pending_seek_) / 1000.0;
        pending_seek_.reset();
        const HRESULT result = engine_->SetCurrentTime(seconds);
        if (FAILED(result)) EmitError(result);
      }
      Emit("bufferingEnd");
      EmitBuffered();
      break;
    case MF_MEDIA_ENGINE_EVENT_BUFFERINGENDED:
      Emit("bufferingEnd");
      EmitBuffered();
      break;
    case MF_MEDIA_ENGINE_EVENT_PROGRESS:
      EmitBuffered();
      break;
    default:
      break;
  }
}

void MediaPlayer::Emit(const std::string& event) {
  on_event_({{{EncodableValue("event"), EncodableValue(event)}}, {}});
}

void MediaPlayer::EmitPlaying(bool playing) {
  playing_ = playing;
  UpdateDisplaySleep();
  on_event_({{{EncodableValue("event"), EncodableValue("isPlayingStateUpdate")},
              {EncodableValue("isPlaying"), EncodableValue(playing)}},
             {}});
}

void MediaPlayer::EmitBuffered() {
  ComPtr<IMFMediaTimeRange> ranges;
  if (FAILED(engine_->GetBuffered(&ranges))) {
    return;
  }
  EncodableList values;
  for (DWORD i = 0; i < ranges->GetLength(); ++i) {
    double start = 0;
    double end = 0;
    if (SUCCEEDED(ranges->GetStart(i, &start)) &&
        SUCCEEDED(ranges->GetEnd(i, &end))) {
      values.emplace_back(
          EncodableList{EncodableValue(SecondsToMilliseconds(start)),
                        EncodableValue(SecondsToMilliseconds(end))});
    }
  }
  on_event_({{{EncodableValue("event"), EncodableValue("bufferingUpdate")},
              {EncodableValue("values"), EncodableValue(values)}},
             {}});
}

void MediaPlayer::EmitError(HRESULT result) {
  if (failed_) {
    return;
  }
  failed_ = true;
  playing_ = false;
  UpdateDisplaySleep();
  std::ostringstream message;
  message << "Media Foundation playback failed (HRESULT 0x" << std::hex
          << static_cast<unsigned long>(result) << ").";
  on_event_({{}, message.str()});
}

void MediaPlayer::UpdateDisplaySleep() {
  // Execution state is thread-local, so updates and cleanup stay on the worker.
  SetThreadExecutionState(
      ES_CONTINUOUS |
      (playing_ && prevents_display_sleep_ ? ES_DISPLAY_REQUIRED : 0));
}

HRESULT MediaPlayer::Play() {
  return Invoke([this] { return engine_->Play(); });
}

HRESULT MediaPlayer::Pause() {
  return Invoke([this] { return engine_->Pause(); });
}

HRESULT MediaPlayer::SetLooping(bool looping) {
  return Invoke([this, looping] { return engine_->SetLoop(looping); });
}

HRESULT MediaPlayer::SetVolume(double volume) {
  if (!std::isfinite(volume) || volume < 0 || volume > 1) {
    return E_INVALIDARG;
  }
  return Invoke([this, volume] { return engine_->SetVolume(volume); });
}

HRESULT MediaPlayer::SetPlaybackSpeed(double speed) {
  if (!std::isfinite(speed) || speed <= 0) {
    return E_INVALIDARG;
  }
  return Invoke([this, speed] { return engine_->SetPlaybackRate(speed); });
}

HRESULT MediaPlayer::SeekTo(int64_t milliseconds) {
  if (milliseconds < 0) {
    return E_INVALIDARG;
  }
  return Invoke([this, milliseconds] {
    // MSE sources can report metadata before their initial buffers exist.
    // Seeking then can strand a download queue at the original position.
    if (adaptive_ && adaptive_->available() && !ready_to_seek_) {
      pending_seek_ = milliseconds;
      return S_OK;
    }
    return engine_->SetCurrentTime(static_cast<double>(milliseconds) / 1000.0);
  });
}

HRESULT MediaPlayer::GetPosition(int64_t* milliseconds) {
  return Invoke([this, milliseconds] {
    *milliseconds = pending_seek_.value_or(
        SecondsToMilliseconds(engine_->GetCurrentTime()));
    return S_OK;
  });
}

HRESULT MediaPlayer::SetPreventsDisplaySleep(bool prevents) {
  return Invoke([this, prevents] {
    prevents_display_sleep_ = prevents;
    UpdateDisplaySleep();
    return S_OK;
  });
}

HRESULT MediaPlayer::ReadTracks(bool audio, std::vector<TrackData>* tracks) {
  if (!initialized_) return MF_E_NOT_INITIALIZED;
  ComPtr<IMFMediaEngineEx> extended;
  HRESULT hr = engine_.As(&extended);
  if (FAILED(hr)) return hr;
  DWORD count = 0;
  if (FAILED(hr = extended->GetNumberOfStreams(&count))) return hr;
  for (DWORD index = 0; index < count; ++index) {
    PROPVARIANT value = {};
    hr = extended->GetStreamAttribute(index, MF_MT_MAJOR_TYPE, &value);
    const bool matches =
        SUCCEEDED(hr) && value.vt == VT_CLSID && value.puuid &&
        *value.puuid == (audio ? MFMediaType_Audio : MFMediaType_Video);
    PropVariantClear(&value);
    if (FAILED(hr)) return hr;
    if (!matches) continue;
    BOOL selected = FALSE;
    if (FAILED(hr = extended->GetStreamSelection(index, &selected))) return hr;
    TrackData track(index, selected != FALSE);
    auto string_attribute = [&](REFGUID key) -> std::optional<std::string> {
      PROPVARIANT attribute = {};
      std::optional<std::string> result;
      if (SUCCEEDED(extended->GetStreamAttribute(index, key, &attribute)) &&
          attribute.vt == VT_LPWSTR && attribute.pwszVal) {
        const int size = WideCharToMultiByte(CP_UTF8, 0, attribute.pwszVal, -1,
                                             nullptr, 0, nullptr, nullptr);
        if (size > 1) {
          std::string text(size, '\0');
          WideCharToMultiByte(CP_UTF8, 0, attribute.pwszVal, -1, text.data(),
                              size, nullptr, nullptr);
          text.pop_back();
          result = std::move(text);
        }
      }
      PropVariantClear(&attribute);
      return result;
    };
    auto integer_attribute = [&](REFGUID key) -> std::optional<uint64_t> {
      PROPVARIANT attribute = {};
      std::optional<uint64_t> result;
      if (SUCCEEDED(extended->GetStreamAttribute(index, key, &attribute))) {
        if (attribute.vt == VT_UI4) result = attribute.ulVal;
        if (attribute.vt == VT_UI8) result = attribute.uhVal.QuadPart;
      }
      PropVariantClear(&attribute);
      return result;
    };
    if (auto label = string_attribute(MF_SD_STREAM_NAME))
      track.set_label(*label);
    if (auto language = string_attribute(MF_SD_LANGUAGE))
      track.set_language(*language);
    if (audio) {
      if (auto rate = integer_attribute(MF_MT_AUDIO_SAMPLES_PER_SECOND))
        track.set_sample_rate(*rate);
      if (auto channels = integer_attribute(MF_MT_AUDIO_NUM_CHANNELS))
        track.set_channel_count(*channels);
      if (auto bytes = integer_attribute(MF_MT_AUDIO_AVG_BYTES_PER_SECOND))
        track.set_bitrate(*bytes * 8);
    } else {
      if (auto bitrate = integer_attribute(MF_MT_AVG_BITRATE))
        track.set_bitrate(*bitrate);

      // GetNativeVideoSize can still describe the previous stream immediately
      // after selection; derive display dimensions from this stream's metadata.
      if (auto size = integer_attribute(MF_MT_FRAME_SIZE)) {
        double display_width = static_cast<double>(*size >> 32);
        if (auto ratio = integer_attribute(MF_MT_PIXEL_ASPECT_RATIO)) {
          const uint64_t numerator = *ratio >> 32;
          const uint64_t denominator = *ratio & 0xffffffff;
          if (numerator > 0 && denominator > 0) {
            display_width *= static_cast<double>(numerator) / denominator;
          }
        }
        if (display_width > 0 &&
            display_width <
                static_cast<double>(std::numeric_limits<int64_t>::max())) {
          track.set_width(static_cast<int64_t>(std::llround(display_width)));
        }
        track.set_height(*size & 0xffffffff);
      }

      if (auto rate = integer_attribute(MF_MT_FRAME_RATE)) {
        const auto denominator = *rate & 0xffffffff;
        if (denominator)
          track.set_frame_rate(static_cast<double>(*rate >> 32) / denominator);
      }
    }
    tracks->push_back(std::move(track));
  }
  return S_OK;
}

HRESULT MediaPlayer::GetTracks(bool audio, std::vector<TrackData>* tracks) {
  return Invoke([&] {
    if (!audio && adaptive_ && adaptive_->available()) {
      return adaptive_->GetTracks(tracks);
    }
    return ReadTracks(audio, tracks);
  });
}

HRESULT MediaPlayer::SelectTrack(bool audio, std::optional<int64_t> track_id) {
  return Invoke([this, audio, track_id] {
    if (!audio && adaptive_ && adaptive_->available()) {
      return adaptive_->SelectTrack(track_id);
    }
    const auto target =
        track_id ? track_id : (audio ? std::nullopt : default_video_track_);
    std::vector<TrackData> tracks;
    HRESULT hr = ReadTracks(audio, &tracks);
    if (FAILED(hr)) return hr;

    bool found = false;
    for (const auto& track : tracks) {
      if (target && track.id() == *target) found = true;
    }
    if (!found) return E_INVALIDARG;

    ComPtr<IMFMediaEngineEx> extended;
    if (FAILED(hr = engine_.As(&extended))) return hr;

    // Selections are staged until ApplyStreamSelections; restore the whole
    // previous set if staging or application fails partway through.
    auto restore = [&] {
      for (const auto& track : tracks) {
        extended->SetStreamSelection(static_cast<DWORD>(track.id()),
                                     track.is_selected());
      }
      extended->ApplyStreamSelections();
    };

    for (const auto& track : tracks) {
      hr = extended->SetStreamSelection(static_cast<DWORD>(track.id()),
                                        track.id() == *target);
      if (FAILED(hr)) {
        restore();
        return hr;
      }
    }

    hr = extended->ApplyStreamSelections();
    if (FAILED(hr)) restore();
    return hr;
  });
}

}  // namespace video_player_windows
