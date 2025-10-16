// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.camera.video.VideoRecordEvent;
import org.junit.Test;

public class VideoRecordEventListenerTest {
  @Test
  public void pigeon_defaultConstructor_createsExpectedVideoRecordEvent() {
    final PigeonApiVideoRecordEventListener api =
        new TestProxyApiRegistrar().getPigeonApiVideoRecordEventListener();

    assertTrue(
        api.pigeon_defaultConstructor()
            instanceof VideoRecordEventListenerProxyApi.VideoRecordEventListenerImpl);
  }

  @Test
  public void onEvent_makesCallToDartCallback() {
    final VideoRecordEventListenerProxyApi mockApi = mock(VideoRecordEventListenerProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final VideoRecordEventListenerProxyApi.VideoRecordEventListenerImpl instance =
        new VideoRecordEventListenerProxyApi.VideoRecordEventListenerImpl(mockApi);
    final androidx.camera.video.VideoRecordEvent event = mock(VideoRecordEvent.class);
    instance.onEvent(event);

    verify(mockApi).onEvent(eq(instance), eq(event), any());
  }
}
