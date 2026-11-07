// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_VIDEO_PLAYER_WINDOWS_ADAPTIVE_SOURCE_H_
#define PACKAGES_VIDEO_PLAYER_WINDOWS_ADAPTIVE_SOURCE_H_

#include <mfmediaengine.h>
#include <wrl/client.h>

#include <cstdint>
#include <functional>
#include <memory>
#include <optional>
#include <string>
#include <vector>

#include "messages.g.h"

namespace video_player_windows {

class AdaptiveSource {
 public:
  AdaptiveSource();
  ~AdaptiveSource();

  // Success with ready's boolean set to false requires the caller to load the
  // progressive source through the normal engine path.
  void Open(const std::string& source, const std::string& relay,
            std::function<void(HRESULT, bool)> ready);
  void Close();

  IMFMediaEngineExtension* extension() const;
  bool available() const;

  HRESULT GetTracks(std::vector<TrackData>* tracks);
  HRESULT SelectTrack(std::optional<int64_t> bitrate);

 private:
  struct State;
  std::shared_ptr<State> state_;
  Microsoft::WRL::ComPtr<IMFMediaEngineExtension> extension_;
};

}  // namespace video_player_windows

#endif
