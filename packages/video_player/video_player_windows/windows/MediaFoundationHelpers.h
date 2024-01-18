// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#ifndef PACKAGES_VIDEO_PLAYER_VIDEO_PLAYER_WINDOWS_WINDOWS_MEDIA_FOUNDATION_HELPERS_H_
#define PACKAGES_VIDEO_PLAYER_VIDEO_PLAYER_WINDOWS_WINDOWS_MEDIA_FOUNDATION_HELPERS_H_

namespace video_player_windows {

class MFPlatformRef {
 public:
  MFPlatformRef() {}

  virtual ~MFPlatformRef() { Shutdown(); }

  void Startup() {
    if (!started_) {
      THROW_IF_FAILED(MFStartup(MF_VERSION, MFSTARTUP_FULL));
      started_ = true;
    }
  }

  void Shutdown() {
    if (started_) {
      THROW_IF_FAILED(MFShutdown());
      started_ = false;
    }
  }

 private:
  bool started_ = false;
};

class MFCallbackBase
    : public winrt::implements<MFCallbackBase, IMFAsyncCallback> {
 public:
  MFCallbackBase(DWORD flags = 0,
                 DWORD queue = MFASYNC_CALLBACK_QUEUE_MULTITHREADED)
      : flags_(flags), queue_(queue) {}

  DWORD GetQueue() const { return queue_; }
  DWORD GetFlags() const { return flags_; }

  // IMFAsyncCallback methods
  IFACEMETHODIMP GetParameters(_Out_ DWORD* flags, _Out_ DWORD* queue) {
    *flags = flags_;
    *queue = queue_;
    return S_OK;
  }

 private:
  DWORD flags_ = 0;
  DWORD queue_ = 0;
};

class SyncMFCallback : public MFCallbackBase {
 public:
  SyncMFCallback() { invoke_event_.create(); }

  void Wait(uint32_t timeout = INFINITE) {
    if (!invoke_event_.wait(timeout)) {
      THROW_HR(ERROR_TIMEOUT);
    }
  }

  IMFAsyncResult* GetResult() { return result_.get(); }

  // IMFAsyncCallback methods

  IFACEMETHODIMP Invoke(_In_opt_ IMFAsyncResult* result) noexcept override try {
    result_.copy_from(result);
    invoke_event_.SetEvent();
    return S_OK;
  }
  CATCH_RETURN();

 private:
  wil::unique_event invoke_event_;
  winrt::com_ptr<IMFAsyncResult> result_;
};

class MFWorkItem : public MFCallbackBase {
 public:
  MFWorkItem(std::function<void()> callback, DWORD flags = 0,
             DWORD queue = MFASYNC_CALLBACK_QUEUE_MULTITHREADED)
      : MFCallbackBase(flags, queue) {
    callback_ = callback;
  }

  // IMFAsyncCallback methods

  IFACEMETHODIMP Invoke(_In_opt_ IMFAsyncResult* /*result*/) noexcept override
      try {
    callback_();
    return S_OK;
  }
  CATCH_RETURN();

 private:
  std::function<void()> callback_;
};

inline void MFPutWorkItem(std::function<void()> callback) {
  winrt::com_ptr<MFWorkItem> work_item = winrt::make_self<MFWorkItem>(callback);
  THROW_IF_FAILED(
      MFPutWorkItem2(work_item->GetQueue(), 0, work_item.get(), nullptr));
}

// Helper function for ensuring that the provided callback runs synchronously on
// a MTA thread. All MediaFoundation calls should be made on a MTA thread to
// avoid subtle deadlock bugs due to objects inadvertedly being created in a STA
inline void RunSyncInMTA(std::function<void()> callback) {
  APTTYPE apartment_type = {};
  APTTYPEQUALIFIER qualifier = {};

  THROW_IF_FAILED(CoGetApartmentType(&apartment_type, &qualifier));

  if (apartment_type == APTTYPE_MTA) {
    wil::unique_couninitialize_call unique_coinit;
    if (qualifier == APTTYPEQUALIFIER_IMPLICIT_MTA) {
      unique_coinit = wil::CoInitializeEx_failfast(COINIT_MULTITHREADED);
    }
    callback();
  } else {
    wil::unique_event complete;
    complete.create();
    MFPutWorkItem([&]() {
      callback();
      complete.SetEvent();
    });
    complete.wait();
  }
}

constexpr uint64_t kMSPerSecond = 1000;

template <typename SecondsT>
inline uint64_t ConvertSecondsToMs(SecondsT seconds) {
  return static_cast<uint64_t>(seconds * kMSPerSecond);
}

template <typename MsT>
inline double ConvertMsToSeconds(MsT ms) {
  return static_cast<double>(ms) / kMSPerSecond;
}

}  // namespace video_player_windows

#endif  // PACKAGES_VIDEO_PLAYER_VIDEO_PLAYER_WINDOWS_WINDOWS_MEDIA_FOUNDATION_HELPERS_H_