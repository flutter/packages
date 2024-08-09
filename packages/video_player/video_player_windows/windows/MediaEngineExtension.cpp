// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Include prior to C++/WinRT Headers
#include <wil/cppwinrt.h>

// Windows Implementation Library
#include <wil/resource.h>

// MediaFoundation headers
#include <Audioclient.h>
#include <d3d11.h>
#include <mfapi.h>
#include <mferror.h>
#include <mfmediaengine.h>

// STL headers
#include <functional>
#include <memory>

#include "MediaEngineExtension.h"
#include "MediaEngineWrapper.h"
#include "MediaFoundationHelpers.h"

using namespace Microsoft::WRL;

namespace video_player_windows {

IFACEMETHODIMP MediaEngineExtension::CanPlayType(
    BOOL /*is_audio_only*/, BSTR /*mime_type*/,
    MF_MEDIA_ENGINE_CANPLAY* result) noexcept {
  *result = MF_MEDIA_ENGINE_CANPLAY_NOT_SUPPORTED;
  return S_OK;
}

IFACEMETHODIMP MediaEngineExtension::BeginCreateObject(
    BSTR /*url*/, IMFByteStream* /*byte_stream*/, MF_OBJECT_TYPE type,
    IUnknown** cancel_cookie, IMFAsyncCallback* callback,
    IUnknown* state) noexcept try {
  if (cancel_cookie) {
    *cancel_cookie = nullptr;
  }
  winrt::com_ptr<IUnknown> local_source;
  {
    auto lock = lock_.lock();
    THROW_HR_IF(MF_E_SHUTDOWN, has_shutdown_);
    local_source = mf_media_source_;
  }

  if (type == MF_OBJECT_MEDIASOURCE && local_source != nullptr) {
    winrt::com_ptr<IMFAsyncResult> async_result;
    THROW_IF_FAILED(MFCreateAsyncResult(local_source.get(), callback, state,
                                        async_result.put()));
    THROW_IF_FAILED(async_result->SetStatus(S_OK));
    uri_type_ = ExtensionUriType::kCustomSource;
    // Invoke the callback synchronously since no outstanding work is required.
    THROW_IF_FAILED(callback->Invoke(async_result.get()));
  } else {
    THROW_HR(MF_E_UNEXPECTED);
  }

  return S_OK;
}
CATCH_RETURN();

STDMETHODIMP MediaEngineExtension::CancelObjectCreation(
    _In_ IUnknown* /*cancel_cookie*/) noexcept {
  // Cancellation not supported
  return E_NOTIMPL;
}

STDMETHODIMP MediaEngineExtension::EndCreateObject(IMFAsyncResult* result,
                                                   IUnknown** object) noexcept
    try {
  *object = nullptr;
  if (uri_type_ == ExtensionUriType::kCustomSource) {
    THROW_IF_FAILED(result->GetStatus());
    THROW_IF_FAILED(result->GetObject(object));
    uri_type_ = ExtensionUriType::kUnknown;
  } else {
    THROW_HR(MF_E_UNEXPECTED);
  }
  return S_OK;
}
CATCH_RETURN();

void MediaEngineExtension::SetMediaSource(IUnknown* mf_media_source) {
  auto lock = lock_.lock();
  THROW_HR_IF(MF_E_SHUTDOWN, has_shutdown_);
  mf_media_source_.copy_from(mf_media_source);
}

// Break circular references.
void MediaEngineExtension::Shutdown() {
  auto lock = lock_.lock();
  if (!has_shutdown_) {
    mf_media_source_ = nullptr;
    has_shutdown_ = true;
  }
}

}  // namespace video_player_windows