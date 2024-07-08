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

namespace camera_windows {
using Microsoft::WRL::ComPtr;

enum class RecordingType {
  // Camera is not recording.
  kNone,
  // Recording continues until it is stopped with a separate stop command.
  kContinuous,
  // Recording stops automatically after requested record time is passed.
  kTimed
};

// States that the record handler can be in.
//
// When created, the handler starts in |kNotStarted| state and transtions in
// sequential order through the states.
enum class RecordState { kNotStarted, kStarting, kRunning, kStopping };

// Recording media settings.
//
// Used in [Camera::InitCamera].
// Allows to tune recorded video parameters, such as resolution, frame rate,
// bitrate. If [fps], [video_bitrate] or [audio_bitrate] are passed, they must
// be greater than zero.
struct RecordSettings {
  explicit RecordSettings(
      const bool record_audio = false,
      const std::optional<uint32_t>& fps = std::nullopt,
      const std::optional<uint32_t>& video_bitrate = std::nullopt,
      const std::optional<uint32_t>& audio_bitrate = std::nullopt)
      : record_audio(record_audio),
        fps(fps),
        video_bitrate(video_bitrate),
        audio_bitrate(audio_bitrate) {
    assert(!fps.has_value() || fps.value() > 0);
    assert(!video_bitrate.has_value() || video_bitrate.value() > 0);
    assert(!audio_bitrate.has_value() || audio_bitrate.value() > 0);
  }

  // Controls audio presence in recorded video.
  bool record_audio{false};

  // Rate at which frames should be captured by the camera in frames per second.
  std::optional<uint32_t> fps{std::nullopt};

  // The video encoding bit rate for recording.
  std::optional<uint32_t> video_bitrate{std::nullopt};

  // The audio encoding bit rate for recording.
  std::optional<uint32_t> audio_bitrate{std::nullopt};
};

// Handler for video recording via the camera.
//
// Handles record sink initialization and manages the state of video recording.
class RecordHandler {
 public:
  explicit RecordHandler(const RecordSettings& record_settings)
      : media_settings_(record_settings) {}

  virtual ~RecordHandler() = default;

  // Prevent copying.
  RecordHandler(RecordHandler const&) = delete;
  RecordHandler& operator=(RecordHandler const&) = delete;

  // Initializes record sink and requests capture engine to start recording.
  //
  // Sets record state to: starting.
  //
  // file_path:       A string that hold file path for video capture.
  // max_duration:    A int64 value of maximun recording duration.
  //                  If value is -1 video recording is considered as
  //                  a continuous recording.
  // capture_engine:  A pointer to capture engine instance. Used to start
  //                  the actual recording.
  // base_media_type: A pointer to base media type used as a base
  //                  for the actual video capture media type.
  HRESULT StartRecord(const std::string& file_path, int64_t max_duration,
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

  // Returns true if recording type is continuous recording.
  bool IsContinuousRecording() const {
    return type_ == RecordingType::kContinuous;
  }

  // Returns true if recording type is timed recording.
  bool IsTimedRecording() const { return type_ == RecordingType::kTimed; }

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

  // Returns true if recording time has exceeded the maximum duration for timed
  // recordings.
  bool ShouldStopTimedRecording() const;

 private:
  // Initializes record sink for video file capture.
  HRESULT InitRecordSink(IMFCaptureEngine* capture_engine,
                         IMFMediaType* base_media_type);

  const RecordSettings media_settings_;
  int64_t max_video_duration_ms_ = -1;
  int64_t recording_start_timestamp_us_ = -1;
  uint64_t recording_duration_us_ = 0;
  std::string file_path_;
  RecordState recording_state_ = RecordState::kNotStarted;
  RecordingType type_ = RecordingType::kNone;
  ComPtr<IMFCaptureRecordSink> record_sink_;
};

}  // namespace camera_windows

#endif  // PACKAGES_CAMERA_CAMERA_WINDOWS_WINDOWS_RECORD_HANDLER_H_
