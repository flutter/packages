// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_RECORD_HANDLER_H_
#define PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_RECORD_HANDLER_H_

#include <mfapi.h>
#include <mfcaptureengine.h>
#include <wrl/client.h>

#include <cassert>
#include <memory>
#include <optional>
#include <string>

#include "messages.g.h"

namespace camera_windows {
using Microsoft::WRL::ComPtr;

// States that the record handler can be in.
//
// When created, the handler starts in |kNotStarted| state and transtions in
// sequential order through the states.
enum class RecordState { kNotStarted, kStarting, kRunning, kStopping };

// Handler for video recording via the camera.
//
// Handles record sink initialization and manages the state of video recording.
class RecordHandler {
 public:
  explicit RecordHandler(const PlatformMediaSettings& media_settings)
      : media_settings_(media_settings) {}

  virtual ~RecordHandler() = default;

  // Prevent copying.
  RecordHandler(RecordHandler const&) = delete;
  RecordHandler& operator=(RecordHandler const&) = delete;

  // Initializes record sink and requests capture engine to start recording.
  //
  // Sets record state to: starting.
  //
  // file_path:       A string that hold file path for video capture.
  // capture_engine:  A pointer to capture engine instance. Used to start
  //                  the actual recording.
  // base_media_type: A pointer to base media type used as a base
  //                  for the actual video capture media type.
  HRESULT StartRecord(const std::string& file_path,
                      IMFCaptureEngine* capture_engine,
                      IMFMediaType* base_media_type);

  // Stops existing recording.
  //
  // capture_engine:  A pointer to capture engine instance. Used to stop
  //                  the ongoing recording.
  HRESULT StopRecord(IMFCaptureEngine* capture_engine);

  // Set the record handler recording state to: running.
  void OnRecordStarted();

  // Resets the record handler state and
  // sets recording state to: not started.
  void OnRecordStopped();

  // Returns true if new recording can be started.
  bool CanStart() const { return recording_state_ == RecordState::kNotStarted; }

  // Returns true if recording can be stopped.
  bool CanStop() const { return recording_state_ == RecordState::kRunning; }

  // Returns the filesystem path of the video recording.
  std::string GetRecordPath() const { return file_path_; }

  // Returns the duration of the video recording in microseconds.
  uint64_t GetRecordedDuration() const { return recording_duration_us_; }

  // Calculates new recording time from capture timestamp.
  void UpdateRecordingTime(uint64_t timestamp);

 private:
  // Initializes record sink for video file capture.
  HRESULT InitRecordSink(IMFCaptureEngine* capture_engine,
                         IMFMediaType* base_media_type);

  const PlatformMediaSettings media_settings_;
  int64_t recording_start_timestamp_us_ = -1;
  uint64_t recording_duration_us_ = 0;
  std::string file_path_;
  RecordState recording_state_ = RecordState::kNotStarted;
  ComPtr<IMFCaptureRecordSink> record_sink_;
};

}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_RECORD_HANDLER_H_
