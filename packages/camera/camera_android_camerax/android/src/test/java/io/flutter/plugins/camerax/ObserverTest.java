
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(bparrishMines): Remove GenApiImpls from filename or copy classes/methods to your own implementation

package io.flutter.plugins.camerax;

// TODO(bparrishMines): Import native classes
import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.lifecycle.Observer;
import androidx.camera.core.CameraState;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ObserverFlutterApi;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class ObserverTest {

  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @SuppressWarnings("rawtypes")
  @Mock public ObserverHostApiImpl.ObserverImpl mockObserver;

  @Mock public BinaryMessenger mockBinaryMessenger;

  @Mock public ObserverFlutterApi mockFlutterApi;

  @Mock public ObserverHostApiImpl.ObserverProxy mockProxy;

  InstanceManager instanceManager;

  @Before
  public void setUp() {
    instanceManager = InstanceManager.open(identifier -> {});
  }

  @After
  public void tearDown() {
    instanceManager.close();
  }

  @Test
  @SuppressWarnings({"rawtypes", "unchecked"})
  
  public void hostApiCreate() {

    when(mockProxy.create(mockBinaryMessenger, instanceManager)).thenReturn(mockObserver);

    final ObserverHostApiImpl hostApi =
        new ObserverHostApiImpl(mockBinaryMessenger, instanceManager, mockProxy);

    final long instanceIdentifier = 0;
    hostApi.create(instanceIdentifier);

    assertEquals(instanceManager.getInstance(instanceIdentifier), mockObserver);
  }

  @Test
  public void onChanged() {
    final ObserverFlutterApiWrapper flutterApi =
        new ObserverFlutterApiWrapper(mockBinaryMessenger, instanceManager);
    flutterApi.setApi(mockFlutterApi);

    final ObserverHostApiImpl.ObserverImpl<Object> instance =
        new ObserverHostApiImpl.ObserverImpl<Object>(mockBinaryMessenger, instanceManager);

    instance.setApi(flutterApi);

    final long instanceIdentifier = 0;
    instanceManager.addDartCreatedInstance(instance, instanceIdentifier);

    final CameraState mockValue = CameraState.create(CameraState.Type.CLOSED);
    Long mockValueIdentifier = instanceManager.addHostCreatedInstance(mockValue);

    instance.onChanged(mockValue);

    verify(mockFlutterApi)
        .onChanged(
            eq(instanceIdentifier),
            eq(Objects.requireNonNull(mockValueIdentifier)),
            any());
  }
}
