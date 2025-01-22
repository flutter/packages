// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import io.flutter.plugin.common.EventChannel;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

final class VideoPlayerEventCallbacks implements VideoPlayerCallbacks {
  private final EventChannel.EventSink eventSink;

  static VideoPlayerEventCallbacks bindTo(EventChannel eventChannel) {
    QueuingEventSink eventSink = new QueuingEventSink();
    eventChannel.setStreamHandler(
        new EventChannel.StreamHandler() {
          @Override
          public void onListen(Object arguments, EventChannel.EventSink events) {
            eventSink.setDelegate(events);
          }

          @Override
          public void onCancel(Object arguments) {
            eventSink.setDelegate(null);
          }
        });
    return VideoPlayerEventCallbacks.withSink(eventSink);
  }

  @VisibleForTesting
  static VideoPlayerEventCallbacks withSink(EventChannel.EventSink eventSink) {
    return new VideoPlayerEventCallbacks(eventSink);
  }

  private VideoPlayerEventCallbacks(EventChannel.EventSink eventSink) {
    this.eventSink = eventSink;
  }

  @Override
  public void onInitialized(
      int width, int height, long durationInMs, int rotationCorrectionInDegrees) {
    Map<String, Object> event = new HashMap<>();
    event.put("event", "initialized");
    event.put("width", width);
    event.put("height", height);
    event.put("duration", durationInMs);
    if (rotationCorrectionInDegrees != 0) {
      event.put("rotationCorrection", rotationCorrectionInDegrees);
    }
    eventSink.success(event);
  }

  @Override
  public void onBufferingStart() {
    Map<String, Object> event = new HashMap<>();
    event.put("event", "bufferingStart");
    eventSink.success(event);
  }

  @Override
  public void onBufferingUpdate(long bufferedPosition) {
    // iOS supports a list of buffered ranges, so we send as a list with a single range.
    Map<String, Object> event = new HashMap<>();
    event.put("event", "bufferingUpdate");

    List<? extends Number> range = Arrays.asList(0, bufferedPosition);
    event.put("values", Collections.singletonList(range));
    eventSink.success(event);
  }

  @Override
  public void onBufferingEnd() {
    Map<String, Object> event = new HashMap<>();
    event.put("event", "bufferingEnd");
    eventSink.success(event);
  }

  @Override
  public void onCompleted() {
    Map<String, Object> event = new HashMap<>();
    event.put("event", "completed");
    eventSink.success(event);
  }

  @Override
  public void onError(@NonNull String code, @Nullable String message, @Nullable Object details) {
    eventSink.error(code, message, details);
  }

  @Override
  public void onIsPlayingStateUpdate(boolean isPlaying) {
    Map<String, Object> event = new HashMap<>();
    event.put("event", "isPlayingStateUpdate");
    event.put("isPlaying", isPlaying);
    eventSink.success(event);
  }
}
