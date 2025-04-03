// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import androidx.camera.video.PendingRecording;
import androidx.camera.video.Recording;
import androidx.core.content.ContextCompat;
import java.util.concurrent.Executor;
import org.junit.Test;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.stubbing.Answer;

public class PendingRecordingTest {
  @Test
  public void start_callsStartOnInstance() {
    final PigeonApiPendingRecording api =
        new TestProxyApiRegistrar().getPigeonApiPendingRecording();

    final PendingRecording instance = mock(PendingRecording.class);
    final VideoRecordEventListener listener = event -> {};
    final Recording value = mock(Recording.class);

    try (MockedStatic<ContextCompat> mockedContextCompat =
        Mockito.mockStatic(ContextCompat.class)) {
      mockedContextCompat
          .when(() -> ContextCompat.getMainExecutor(any()))
          .thenAnswer((Answer<Executor>) invocation -> mock(Executor.class));

      when(instance.start(any(), any())).thenReturn(value);

      assertEquals(value, api.start(instance, listener));
    }
  }
}
