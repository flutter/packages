// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "player_event.h"

#include <gtest/gtest.h>

#include <string>

namespace video_player_windows {
namespace {
PlayerEvent Event(const std::string& type) {
  return {{{flutter::EncodableValue("event"), flutter::EncodableValue(type)}},
          {}};
}
}  // namespace

TEST(PendingPlayerEvents, PreservesLatestBufferingTransitionOrder) {
  PendingPlayerEvents pending;
  pending.Add(Event("initialized"));
  pending.Add(Event("bufferingStart"));
  pending.Add(Event("bufferingEnd"));
  pending.Add(Event("bufferingStart"));

  const auto events = pending.Take();

  ASSERT_EQ(events.size(), 3u);
  EXPECT_EQ(events.front().value, Event("initialized").value);
  EXPECT_EQ(events[1].value, Event("bufferingEnd").value);
  EXPECT_EQ(events.back().value, Event("bufferingStart").value);
  EXPECT_TRUE(pending.Take().empty());
}

TEST(PendingPlayerEvents, KeepsLatestPayloadAndErrorWithoutDroppingMetadata) {
  PendingPlayerEvents pending;
  pending.Add(Event("initialized"));
  PlayerEvent playing = Event("isPlayingStateUpdate");
  playing.value[flutter::EncodableValue("isPlaying")] =
      flutter::EncodableValue(true);
  pending.Add(playing);
  pending.Add({{}, "first failure"});
  playing.value[flutter::EncodableValue("isPlaying")] =
      flutter::EncodableValue(false);
  pending.Add(playing);
  pending.Add({{}, "last failure"});

  const auto events = pending.Take();

  ASSERT_EQ(events.size(), 3u);
  EXPECT_EQ(events.front().value, Event("initialized").value);
  EXPECT_EQ(events[1].value, playing.value);
  EXPECT_EQ(events.back().error, "last failure");
}

}  // namespace video_player_windows
