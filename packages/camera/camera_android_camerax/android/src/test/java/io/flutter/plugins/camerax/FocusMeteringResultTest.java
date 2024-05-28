// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.camera.core.FocusMeteringResult;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.FocusMeteringResultFlutterApi;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class FocusMeteringResultTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public BinaryMessenger mockBinaryMessenger;
  @Mock public FocusMeteringResult focusMeteringResult;
  @Mock public FocusMeteringResultFlutterApi mockFlutterApi;

  InstanceManager testInstanceManager;

  @Before
  public void setUp() {
    testInstanceManager = InstanceManager.create(identifier -> {});
  }

  @After
  public void tearDown() {
    testInstanceManager.stopFinalizationListener();
  }

  @Test
  public void isFocusSuccessful_returnsExpectedResult() {
    final FocusMeteringResultHostApiImpl focusMeteringResultHostApiImpl =
        new FocusMeteringResultHostApiImpl(testInstanceManager);
    final Long focusMeteringResultIdentifier = 98L;
    final boolean result = true;

    testInstanceManager.addDartCreatedInstance(focusMeteringResult, focusMeteringResultIdentifier);

    when(focusMeteringResult.isFocusSuccessful()).thenReturn(result);

    assertTrue(focusMeteringResultHostApiImpl.isFocusSuccessful(focusMeteringResultIdentifier));
    verify(focusMeteringResult).isFocusSuccessful();
  }

  @Test
  public void flutterApiCreate_makesCallToCreateInstanceOnDartSide() {
    final FocusMeteringResultFlutterApiImpl flutterApi =
        new FocusMeteringResultFlutterApiImpl(mockBinaryMessenger, testInstanceManager);

    flutterApi.setApi(mockFlutterApi);

    flutterApi.create(focusMeteringResult, reply -> {});
    final long focusMeteringResultIdentifier =
        Objects.requireNonNull(
            testInstanceManager.getIdentifierForStrongReference(focusMeteringResult));

    verify(mockFlutterApi).create(eq(focusMeteringResultIdentifier), any());
  }
}
