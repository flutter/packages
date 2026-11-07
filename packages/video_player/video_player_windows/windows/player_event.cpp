// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "player_event.h"

#include <algorithm>
#include <utility>
#include <vector>

namespace video_player_windows {

void PendingPlayerEvents::Add(PlayerEvent event) {
  const auto type = event.value.find(flutter::EncodableValue("event"));

  events_.erase(
      std::remove_if(
          events_.begin(), events_.end(),
          [&](const PlayerEvent& previous) {
            const auto previous_type =
                previous.value.find(flutter::EncodableValue("event"));
            return (!event.error.empty() && !previous.error.empty()) ||
                   (type != event.value.end() &&
                    previous_type != previous.value.end() &&
                    type->second == previous_type->second);
          }),
      events_.end());

  events_.push_back(std::move(event));
}

std::vector<PlayerEvent> PendingPlayerEvents::Take() {
  return std::exchange(events_, {});
}

}  // namespace video_player_windows
