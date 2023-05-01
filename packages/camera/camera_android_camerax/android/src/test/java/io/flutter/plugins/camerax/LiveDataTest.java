// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;

import androidx.camera.core.CameraState;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.Observer;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.LiveDataFlutterApi;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.LiveDataSupportedType;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.LiveDataSupportedTypeData;

import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class LiveDataTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock
  public LiveData<CameraState> mockLiveData;

  @Mock public BinaryMessenger mockBinaryMessenger;
  @Mock public LiveDataFlutterApi mockFlutterApi;

  InstanceManager instanceManager;

  @Before
  public void setUp() {
    instanceManager = InstanceManager.create(identifier -> {});
  }

  @After
  public void tearDown() {
    instanceManager.clear();
  }

  @Test
  @SuppressWarnings({"unchecked", "rawtypes"})
  public void observe_addsExpectedObserverToLiveDataInstance() {
    final LiveDataHostApiImpl hostApi =
        new LiveDataHostApiImpl(mockBinaryMessenger, instanceManager);
    final Observer mockObserver = mock(Observer.class);
    final long observerIdentifier = 20;
    final long instanceIdentifier = 0;
    final LifecycleOwner mockLifecycleOwner = mock(LifecycleOwner.class);

    instanceManager.addDartCreatedInstance(mockObserver, observerIdentifier);
    instanceManager.addDartCreatedInstance(mockLiveData, instanceIdentifier);

    hostApi.setLifecycleOwner(mockLifecycleOwner);
    hostApi.observe(instanceIdentifier, observerIdentifier);

    verify(mockLiveData).observe(mockLifecycleOwner, mockObserver);
  }

  @Test
  public void removeObservers_makesCallToRemoveObserversFromLiveDataInstance() {
    final LiveDataHostApiImpl hostApi =
        new LiveDataHostApiImpl(mockBinaryMessenger, instanceManager);
    final long instanceIdentifier = 0;
    final LifecycleOwner mockLifecycleOwner = mock(LifecycleOwner.class);

    instanceManager.addDartCreatedInstance(mockLiveData, instanceIdentifier);

    hostApi.setLifecycleOwner(mockLifecycleOwner);
    hostApi.removeObservers(instanceIdentifier);

    verify(mockLiveData).removeObservers(mockLifecycleOwner);
  }

  @Test
  public void flutterApiCreate_makesCallToDartToCreateInstance() {
    final LiveDataFlutterApiWrapper flutterApi =
        new LiveDataFlutterApiWrapper(mockBinaryMessenger, instanceManager);
    final LiveDataSupportedType liveDataType = LiveDataSupportedType.CAMERA_STATE; 

    flutterApi.setApi(mockFlutterApi);

    final ArgumentCaptor<LiveDataSupportedTypeData> liveDataSupportedTypeDataCaptor =
    ArgumentCaptor.forClass(LiveDataSupportedTypeData.class);


    flutterApi.create(mockLiveData, liveDataType, reply -> {});

    final long instanceIdentifier =
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(mockLiveData));
    verify(mockFlutterApi).create(eq(instanceIdentifier), liveDataSupportedTypeDataCaptor.capture(), any());
    assertEquals(liveDataSupportedTypeDataCaptor.getValue().getValue(), liveDataType);
  }
}
