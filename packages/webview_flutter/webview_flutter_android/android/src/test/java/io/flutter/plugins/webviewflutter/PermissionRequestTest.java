// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.webkit.PermissionRequest;
import java.util.Collections;
import java.util.List;
import org.junit.Test;

public class PermissionRequestTest {
  // These values MUST equal the constants for the Dart PermissionRequestConstants class.
  @Test
  public void enums() {
    assertEquals(PermissionRequest.RESOURCE_AUDIO_CAPTURE, "android.webkit.resource.AUDIO_CAPTURE");
    assertEquals(PermissionRequest.RESOURCE_VIDEO_CAPTURE, "android.webkit.resource.VIDEO_CAPTURE");
    assertEquals(PermissionRequest.RESOURCE_MIDI_SYSEX, "android.webkit.resource.MIDI_SYSEX");
    assertEquals(
        PermissionRequest.RESOURCE_PROTECTED_MEDIA_ID,
        "android.webkit.resource.PROTECTED_MEDIA_ID");
  }

  @Test
  public void grant() {
    final PigeonApiPermissionRequest api =
        new TestProxyApiRegistrar().getPigeonApiPermissionRequest();

    final PermissionRequest instance = mock(PermissionRequest.class);
    final List<String> resources =
        Collections.singletonList(PermissionRequest.RESOURCE_AUDIO_CAPTURE);
    api.grant(instance, resources);

    verify(instance).grant(new String[] {PermissionRequest.RESOURCE_AUDIO_CAPTURE});
  }

  @Test
  public void deny() {
    final PigeonApiPermissionRequest api =
        new TestProxyApiRegistrar().getPigeonApiPermissionRequest();

    final PermissionRequest instance = mock(PermissionRequest.class);
    api.deny(instance);

    verify(instance).deny();
  }

  @Test
  public void resources() {
    final PigeonApiPermissionRequest api =
        new TestProxyApiRegistrar().getPigeonApiPermissionRequest();

    final PermissionRequest instance = mock(PermissionRequest.class);
    final List<String> value = Collections.singletonList(PermissionRequest.RESOURCE_AUDIO_CAPTURE);
    when(instance.getResources()).thenReturn(value.toArray(new String[0]));

    assertEquals(value, api.resources(instance));
  }
}
