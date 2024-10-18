// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#ifndef PACKAGES_VIDEO_PLAYER_VIDEO_PLAYER_WINDOWS_WINDOWS_MEDIA_FOUNDATION_HELPERS_H_
#define PACKAGES_VIDEO_PLAYER_VIDEO_PLAYER_WINDOWS_WINDOWS_MEDIA_FOUNDATION_HELPERS_H_

namespace video_player_windows {

// Helper class for managing the lifetime of the MediaFoundation platform.
class MFPlatformRef {
 public:
  MFPlatformRef() {}

  virtual ~MFPlatformRef() { Shutdown(); }

  // Start the MediaFoundation platform.
  void Startup() {
    if (!started_) {
      THROW_IF_FAILED(MFStartup(MF_VERSION, MFSTARTUP_FULL));
      started_ = true;
    }
  }

  // Shutdown the MediaFoundation platform.
  void Shutdown() {
    if (started_) {
      THROW_IF_FAILED(MFShutdown());
      started_ = false;
    }
  }

 private:
  // Whether the MediaFoundation platform has been started.
  bool started_ = false;
};

// Helper base class for implementing IMFAsyncCallback.
class MFCallbackBase
    : public winrt::implements<MFCallbackBase, IMFAsyncCallback> {
 public:
  MFCallbackBase(DWORD flags = 0,
                 DWORD queue = MFASYNC_CALLBACK_QUEUE_MULTITHREADED)
      : flags_(flags), queue_(queue) {}

  // Getter for the callback queue.
  DWORD GetQueue() const { return queue_; }
  // Getter for the callback flags.
  DWORD GetFlags() const { return flags_; }

  // IMFAsyncCallback methods
  IFACEMETHODIMP GetParameters(_Out_ DWORD* flags, _Out_ DWORD* queue) {
    *flags = flags_;
    *queue = queue_;
    return S_OK;
  }

 private:
  // Callback flags.
  DWORD flags_ = 0;
  // Callback queue.
  DWORD queue_ = 0;
};

// Helper class for synchronously waiting for a MediaFoundation callback.
class SyncMFCallback : public MFCallbackBase {
 public:
  SyncMFCallback() { invoke_event_.create(); }

  void Wait(uint32_t timeout = INFINITE) {
    if (!invoke_event_.wait(timeout)) {
      THROW_HR(ERROR_TIMEOUT);
    }
  }

  // Getter for the result of the callback.
  IMFAsyncResult* GetResult() { return result_.get(); }

  // IMFAsyncCallback methods
  IFACEMETHODIMP Invoke(_In_opt_ IMFAsyncResult* result) noexcept override try {
    result_.copy_from(result);
    invoke_event_.SetEvent();
    return S_OK;
  }
  CATCH_RETURN();

 private:
  // Event used to wait for the callback to be invoked.
  wil::unique_event invoke_event_;
  // Field storing the result of the callback.
  winrt::com_ptr<IMFAsyncResult> result_;
};

// Helper class for running a callback on a MediaFoundation work queue.
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
  // Callback to run.
  std::function<void()> callback_;
};

// Helper function for running a callback on a MediaFoundation work queue.
inline void MFPutWorkItem(std::function<void()> callback) {
  winrt::com_ptr<MFWorkItem> work_item = winrt::make_self<MFWorkItem>(callback);
  THROW_IF_FAILED(
      MFPutWorkItem2(work_item->GetQueue(), 0, work_item.get(), nullptr));
}

// Helper function for ensuring that the provided callback runs synchronously on
// a MTA thread. All MediaFoundation calls should be made on a MTA thread to
// avoid subtle deadlock bugs due to objects inadvertedly being created in a
// STA.
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

// The number of milliseconds in one second.
constexpr uint64_t kMSPerSecond = 1000;

// Helper function for converting seconds to milliseconds.
template <typename SecondsT>
inline uint64_t ConvertSecondsToMs(SecondsT seconds) {
  return static_cast<uint64_t>(seconds * kMSPerSecond);
}

// Helper function for converting milliseconds to seconds.
template <typename MsT>
inline double ConvertMsToSeconds(MsT ms) {
  return static_cast<double>(ms) / kMSPerSecond;
}

}  // namespace video_player_windows

#endif  // PACKAGES_VIDEO_PLAYER_VIDEO_PLAYER_WINDOWS_WINDOWS_MEDIA_FOUNDATION_HELPERS_H_