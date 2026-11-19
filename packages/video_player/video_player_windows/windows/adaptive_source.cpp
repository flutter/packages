// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "adaptive_source.h"

#include <mfapi.h>
#include <mferror.h>
#include <mfidl.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Media.Streaming.Adaptive.h>
#include <winrt/Windows.Web.Http.Filters.h>
#include <winrt/Windows.Web.Http.Headers.h>
#include <winrt/Windows.Web.Http.h>
#include <wrl/implements.h>

#include <algorithm>
#include <cwchar>
#include <mutex>
#include <utility>

namespace video_player_windows {
namespace {
using Microsoft::WRL::ComPtr;
using namespace winrt::Windows::Foundation;
using namespace winrt::Windows::Media::Streaming::Adaptive;
using namespace winrt::Windows::Web::Http;

class RelayFilter
    : public winrt::implements<RelayFilter, Filters::IHttpFilter, IClosable> {
 public:
  explicit RelayFilter(std::string relay) : relay_(winrt::to_hstring(relay)) {}

  IAsyncOperationWithProgress<HttpResponseMessage, HttpProgress>
  SendRequestAsync(HttpRequestMessage request) {
    auto lifetime = get_strong();
    (co_await winrt::get_cancellation_token()).enable_propagation();

    HttpRequestMessage forwarded(
        request.Method(),
        Uri(relay_ + L"/resource?url=" +
            Uri::EscapeComponent(request.RequestUri().AbsoluteUri())));
    for (const auto& header : request.Headers()) {
      forwarded.Headers().TryAppendWithoutValidation(header.Key(),
                                                     header.Value());
    }

    auto response = co_await client_.SendRequestAsync(
        forwarded, HttpCompletionOption::ResponseHeadersRead);
    // Relative playlist and segment URLs must use the upstream redirect
    // destination as their base, rather than the loopback address.
    if (response.Headers().HasKey(L"x-video-player-location")) {
      request.RequestUri(
          Uri(response.Headers().Lookup(L"x-video-player-location")));
      response.Headers().Remove(L"x-video-player-location");
    }
    response.RequestMessage(request);
    co_return response;
  }

  void Close() { client_.Close(); }

 private:
  winrt::hstring relay_;
  HttpClient client_;
};

class SourceExtension
    : public Microsoft::WRL::RuntimeClass<
          Microsoft::WRL::RuntimeClassFlags<Microsoft::WRL::ClassicCom>,
          IMFMediaEngineExtension> {
 public:
  void SetSource(ComPtr<IUnknown> source) {
    std::lock_guard<std::mutex> lock(mutex_);
    source_ = std::move(source);
  }

  HRESULT STDMETHODCALLTYPE
  CanPlayType(BOOL, BSTR, MF_MEDIA_ENGINE_CANPLAY* result) override {
    *result = MF_MEDIA_ENGINE_CANPLAY_MAYBE;
    return S_OK;
  }

  HRESULT STDMETHODCALLTYPE BeginCreateObject(BSTR url, IMFByteStream*,
                                              MF_OBJECT_TYPE type,
                                              IUnknown** cookie,
                                              IMFAsyncCallback* callback,
                                              IUnknown* state) override {
    if (cookie) *cookie = nullptr;
    if (!url || std::wcscmp(url, L"adaptive://source") != 0 ||
        type != MF_OBJECT_MEDIASOURCE) {
      return MF_E_UNSUPPORTED_BYTESTREAM_TYPE;
    }

    ComPtr<IUnknown> source;
    {
      std::lock_guard<std::mutex> lock(mutex_);
      source = source_;
    }
    if (!source) return MF_E_SHUTDOWN;

    ComPtr<IMFAsyncResult> result;
    HRESULT hr = MFCreateAsyncResult(source.Get(), callback, state, &result);
    return FAILED(hr) ? hr : MFInvokeCallback(result.Get());
  }

  HRESULT STDMETHODCALLTYPE CancelObjectCreation(IUnknown*) override {
    return S_OK;
  }

  HRESULT STDMETHODCALLTYPE EndCreateObject(IMFAsyncResult* result,
                                            IUnknown** object) override {
    return result->GetObject(object);
  }

 private:
  std::mutex mutex_;
  ComPtr<IUnknown> source_;
};
}  // namespace

struct AdaptiveSource::State {
  std::mutex mutex;
  bool closed = false;
  HttpClient client{nullptr};
  AdaptiveMediaSource adaptive{nullptr};
  ComPtr<SourceExtension> extension = Microsoft::WRL::Make<SourceExtension>();
  std::optional<uint32_t> selected;
};

AdaptiveSource::AdaptiveSource() : state_(std::make_shared<State>()) {
  extension_ = state_->extension;
}

AdaptiveSource::~AdaptiveSource() { Close(); }

IMFMediaEngineExtension* AdaptiveSource::extension() const {
  return extension_.Get();
}

void AdaptiveSource::Open(const std::string& source, const std::string& relay,
                          std::function<void(HRESULT, bool)> ready) {
  // The coroutine owns only detached state; a disposed player must never be
  // retained while a remote manifest is still pending.
  [](std::shared_ptr<State> state, std::string source, std::string relay,
     std::function<void(HRESULT, bool)> ready) -> winrt::fire_and_forget {
    HRESULT status = S_OK;
    bool adaptive = false;
    try {
      co_await winrt::resume_background();
      HttpClient client(winrt::make<RelayFilter>(relay));
      {
        std::lock_guard<std::mutex> lock(state->mutex);
        if (state->closed) co_return;
        state->client = client;
      }

      const auto result = co_await AdaptiveMediaSource::CreateFromUriAsync(
          Uri(winrt::to_hstring(source)), client);
      std::lock_guard<std::mutex> lock(state->mutex);
      if (state->closed) co_return;
      if (result.Status() == AdaptiveMediaSourceCreationStatus::Success) {
        state->adaptive = result.MediaSource();
        // AdaptiveMediaSource exposes an MSE source through this service,
        // rather than implementing IMFMediaSource directly.
        ComPtr<IMFMediaSourceExtension> native;
        winrt::check_hresult(MFGetService(winrt::get_unknown(state->adaptive),
                                          MF_MEDIASOURCE_SERVICE,
                                          IID_PPV_ARGS(&native)));
        state->extension->SetSource(std::move(native));
        adaptive = true;
      } else if (result.Status() != AdaptiveMediaSourceCreationStatus::
                                        UnsupportedManifestContentType) {
        status = result.ExtendedError();
        if (SUCCEEDED(status)) status = MF_E_UNSUPPORTED_BYTESTREAM_TYPE;
      }
    } catch (...) {
      status = winrt::to_hresult();
    }

    ready(status, adaptive);
  }(state_, source, relay, std::move(ready));
}

void AdaptiveSource::Close() {
  HttpClient client{nullptr};
  AdaptiveMediaSource adaptive{nullptr};
  {
    std::lock_guard<std::mutex> lock(state_->mutex);
    if (state_->closed) return;
    state_->closed = true;
    client = std::exchange(state_->client, nullptr);
    adaptive = std::exchange(state_->adaptive, nullptr);
    state_->extension->SetSource(nullptr);
  }
  try {
    if (client) client.Close();
    if (adaptive) adaptive.Close();
  } catch (...) {
  }
}

bool AdaptiveSource::available() const {
  std::lock_guard<std::mutex> lock(state_->mutex);
  return state_->adaptive != nullptr;
}

HRESULT AdaptiveSource::GetTracks(std::vector<TrackData>* tracks) {
  try {
    std::lock_guard<std::mutex> lock(state_->mutex);
    if (!state_->adaptive) return MF_E_NOT_INITIALIZED;
    for (uint32_t bitrate : state_->adaptive.AvailableBitrates()) {
      TrackData track(bitrate, state_->selected == bitrate);
      track.set_bitrate(bitrate);
      track.set_label(std::to_string(bitrate / 1000) + " kbps");
      tracks->push_back(std::move(track));
    }
    return S_OK;
  } catch (...) {
    return winrt::to_hresult();
  }
}

HRESULT AdaptiveSource::SelectTrack(std::optional<int64_t> bitrate) {
  try {
    std::lock_guard<std::mutex> lock(state_->mutex);
    if (!state_->adaptive) return MF_E_NOT_INITIALIZED;
    const auto available = state_->adaptive.AvailableBitrates();
    if (bitrate && std::find(available.begin(), available.end(), *bitrate) ==
                       available.end()) {
      return E_INVALIDARG;
    }

    const auto previous = state_->selected;
    auto apply = [&](std::optional<uint32_t> selection) {
      // Clear the old bounds before switching, otherwise raising the minimum
      // above a previously locked maximum is rejected by Windows.
      state_->adaptive.DesiredMinBitrate(nullptr);
      state_->adaptive.DesiredMaxBitrate(nullptr);
      if (selection) {
        state_->adaptive.DesiredMaxBitrate(*selection);
        state_->adaptive.DesiredMinBitrate(*selection);
      }
    };

    try {
      const auto selection =
          bitrate ? std::optional<uint32_t>(static_cast<uint32_t>(*bitrate))
                  : std::nullopt;
      apply(selection);
      state_->selected = selection;
    } catch (...) {
      const HRESULT error = winrt::to_hresult();
      apply(previous);
      return error;
    }
    return S_OK;
  } catch (...) {
    return winrt::to_hresult();
  }
}

}  // namespace video_player_windows
