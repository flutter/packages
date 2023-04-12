
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(bparrishMines): Remove GenApiImpls from filename or copy classes/methods to your own implementation

package io.flutter.plugins.camerax;

// TODO(bparrishMines): Import native classes
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.Observer;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.LiveDataFlutterApi;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class LiveDataTest {

  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @SuppressWarnings("rawtypes")
  @Mock public LiveData mockLiveData;

  @Mock public BinaryMessenger mockBinaryMessenger;

  @Mock public LiveDataFlutterApi mockFlutterApi;

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
  @SuppressWarnings({"unchecked", "rawtypes"})
  public void observe() {

    final Observer mockObserver = mock(Observer.class);
    final long observerIdentifier = 20;
    instanceManager.addDartCreatedInstance(mockObserver, observerIdentifier);

    final long instanceIdentifier = 0;
    instanceManager.addDartCreatedInstance(mockLiveData, instanceIdentifier);

    final LiveDataHostApiImpl hostApi =
        new LiveDataHostApiImpl(mockBinaryMessenger, instanceManager);

    LifecycleOwner fakeLifecycleOwner = mock(LifecycleOwner.class);
    hostApi.setLifecycleOwner(fakeLifecycleOwner);

    hostApi.observe(instanceIdentifier, observerIdentifier);

    verify(mockLiveData).observe(fakeLifecycleOwner, mockObserver);
  }

  @Test
  public void removeObservers() {

    final long instanceIdentifier = 0;
    instanceManager.addDartCreatedInstance(mockLiveData, instanceIdentifier);

    final LiveDataHostApiImpl hostApi =
        new LiveDataHostApiImpl(mockBinaryMessenger, instanceManager);

        LifecycleOwner fakeLifecycleOwner = mock(LifecycleOwner.class);
        hostApi.setLifecycleOwner(fakeLifecycleOwner);

    hostApi.removeObservers(instanceIdentifier);

    verify(mockLiveData).removeObservers(fakeLifecycleOwner);
  }

  @Test
  public void flutterApiCreate() {
    final LiveDataFlutterApiWrapper flutterApi =
        new LiveDataFlutterApiWrapper(mockBinaryMessenger, instanceManager);
    flutterApi.setApi(mockFlutterApi);

    flutterApi.create(mockLiveData, reply -> {});

    final long instanceIdentifier =
        Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(mockLiveData));
    verify(mockFlutterApi).create(eq(instanceIdentifier), any());
  }
}
