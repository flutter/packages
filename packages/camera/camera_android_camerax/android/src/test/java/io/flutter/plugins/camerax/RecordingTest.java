// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.video.Recording;
import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

public class RecordingTest {
  @Test
  public void close() {
    final PigeonApiRecording api = new TestProxyApiRegistrar().getPigeonApiRecording();

    final Recording instance = mock(Recording.class);
    api.close(instance );

    verify(instance).close();
  }

  @Test
  public void pause() {
    final PigeonApiRecording api = new TestProxyApiRegistrar().getPigeonApiRecording();

    final Recording instance = mock(Recording.class);
    api.pause(instance );

    verify(instance).pause();
  }

  @Test
  public void resume() {
    final PigeonApiRecording api = new TestProxyApiRegistrar().getPigeonApiRecording();

    final Recording instance = mock(Recording.class);
    api.resume(instance );

    verify(instance).resume();
  }

  @Test
  public void stop() {
    final PigeonApiRecording api = new TestProxyApiRegistrar().getPigeonApiRecording();

    final Recording instance = mock(Recording.class);
    api.stop(instance );

    verify(instance).stop();
  }
}
