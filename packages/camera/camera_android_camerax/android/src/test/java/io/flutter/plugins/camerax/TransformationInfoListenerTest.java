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

import androidx.camera.core.SurfaceRequest.TransformationInfo;
import org.junit.Test;

public class TransformationInfoListenerTest {
  @Test
  public void pigeon_defaultConstructor_makesCallToCreateTransformationInfoListenerInstance() {
    final PigeonApiTransformationInfoListener api =
        new TestProxyApiRegistrar().getPigeonApiTransformationInfoListener();

    assertTrue(
        api.pigeon_defaultConstructor()
            instanceof TransformationInfoListenerProxyApi.TransformationInfoListenerImpl);
  }

  @Test
  public void onTransformationInfoUpdate_makesCallToDartOnTransformationInfoUpdate() {
    final TransformationInfoListenerProxyApi mockApi =
        mock(TransformationInfoListenerProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final TransformationInfoListenerProxyApi.TransformationInfoListenerImpl instance =
        new TransformationInfoListenerProxyApi.TransformationInfoListenerImpl(mockApi);
    final TransformationInfo transformationInfo = mock(TransformationInfo.class);
    instance.onTransformationInfoUpdate(transformationInfo);

    verify(mockApi).onTransformationInfoUpdate(eq(instance), eq(transformationInfo), any());
  }
}
