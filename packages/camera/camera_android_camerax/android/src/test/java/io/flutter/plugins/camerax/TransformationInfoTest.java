// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import androidx.camera.core.SurfaceRequest.TransformationInfo;
import org.junit.Test;

public class TransformationInfoTest {
  @Test
  public void rotationDegrees_returnsExpectedRotationDegrees() {
    final PigeonApiTransformationInfo api =
        new TestProxyApiRegistrar().getPigeonApiTransformationInfo();
    final TransformationInfo instance = mock(TransformationInfo.class);
    when(instance.getRotationDegrees()).thenReturn(270);

    assertEquals(270, api.rotationDegrees(instance));
  }

  @Test
  public void hasCameraTransform_returnsExpectedValue() {
    final PigeonApiTransformationInfo api =
        new TestProxyApiRegistrar().getPigeonApiTransformationInfo();
    final TransformationInfo instance = mock(TransformationInfo.class);

    when(instance.hasCameraTransform()).thenReturn(true);
    assertTrue(api.hasCameraTransform(instance));

    when(instance.hasCameraTransform()).thenReturn(false);
    assertFalse(api.hasCameraTransform(instance));
  }

  @Test
  public void isMirroring_returnsExpectedValue() {
    final PigeonApiTransformationInfo api =
        new TestProxyApiRegistrar().getPigeonApiTransformationInfo();
    final TransformationInfo instance = mock(TransformationInfo.class);

    when(instance.isMirroring()).thenReturn(true);
    assertTrue(api.isMirroring(instance));

    when(instance.isMirroring()).thenReturn(false);
    assertFalse(api.isMirroring(instance));
  }
}
