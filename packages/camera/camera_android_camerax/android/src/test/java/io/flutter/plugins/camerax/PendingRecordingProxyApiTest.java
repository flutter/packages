// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

import androidx.camera.video.PendingRecording
import androidx.camera.video.Recording
import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import org.mockito.Mockito;
import org.mockito.Mockito.any;
import java.util.HashMap;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class PendingRecordingProxyApiTest {
  @Test
  public void start() {
    final PigeonApiPendingRecording api = new TestProxyApiRegistrar().getPigeonApiPendingRecording();

    final PendingRecording instance = mock(PendingRecording.class);
    final VideoRecordEventListener listener = mock(VideoRecordEventListener.class);
    final androidx.camera.video.Recording value = mock(Recording.class);
    when(instance.start(listener)).thenReturn(value);

    assertEquals(value, api.start(instance, listener));
  }

}
