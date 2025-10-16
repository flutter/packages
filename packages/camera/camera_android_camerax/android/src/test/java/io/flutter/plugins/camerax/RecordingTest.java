// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import androidx.camera.video.Recording;
import org.junit.Test;

public class RecordingTest {
  @Test
  public void close_callsCloseOnInstance() {
    final PigeonApiRecording api = new TestProxyApiRegistrar().getPigeonApiRecording();

    final Recording instance = mock(Recording.class);
    api.close(instance);

    verify(instance).close();
  }

  @Test
  public void pause_callsPauseOnInstance() {
    final PigeonApiRecording api = new TestProxyApiRegistrar().getPigeonApiRecording();

    final Recording instance = mock(Recording.class);
    api.pause(instance);

    verify(instance).pause();
  }

  @Test
  public void resume_callsResumeOnInstance() {
    final PigeonApiRecording api = new TestProxyApiRegistrar().getPigeonApiRecording();

    final Recording instance = mock(Recording.class);
    api.resume(instance);

    verify(instance).resume();
  }

  @Test
  public void stop_callsStopOnInstance() {
    final PigeonApiRecording api = new TestProxyApiRegistrar().getPigeonApiRecording();

    final Recording instance = mock(Recording.class);
    api.stop(instance);

    verify(instance).stop();
  }
}
