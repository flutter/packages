// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef PACKAGES_VIDEO_PLAYER_WINDOWS_PLAYER_EVENT_H_
#define PACKAGES_VIDEO_PLAYER_WINDOWS_PLAYER_EVENT_H_

#include <flutter/encodable_value.h>

#include <string>
#include <vector>

namespace video_player_windows {

struct PlayerEvent {
  flutter::EncodableMap value;
  std::string error;
};

// Before a Dart listener attaches, only the latest event of each kind is
// needed. Their last-occurrence order must be preserved for paired buffering
// transitions.
class PendingPlayerEvents {
 public:
  void Add(PlayerEvent event);
  std::vector<PlayerEvent> Take();

 private:
  std::vector<PlayerEvent> events_;
};

}  // namespace video_player_windows

#endif
