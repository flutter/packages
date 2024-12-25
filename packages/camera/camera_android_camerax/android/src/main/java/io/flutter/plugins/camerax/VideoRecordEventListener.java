package io.flutter.plugins.camerax;

import androidx.camera.video.VideoRecordEvent;

public interface VideoRecordEventListener {
  void onEvent(VideoRecordEvent event);
}
