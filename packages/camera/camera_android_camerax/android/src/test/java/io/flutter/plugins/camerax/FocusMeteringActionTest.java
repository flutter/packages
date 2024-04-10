// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.camera.core.FocusMeteringAction;
import androidx.camera.core.MeteringPoint;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.MeteringPointInfo;
import java.util.Arrays;
import java.util.List;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class FocusMeteringActionTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public BinaryMessenger mockBinaryMessenger;
  @Mock public FocusMeteringAction focusMeteringAction;

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
  public void hostApiCreate_createsExpectedFocusMeteringActionWithInitialPointThatHasMode() {
    FocusMeteringActionHostApiImpl.FocusMeteringActionProxy proxySpy =
        spy(new FocusMeteringActionHostApiImpl.FocusMeteringActionProxy());
    FocusMeteringActionHostApiImpl hostApi =
        new FocusMeteringActionHostApiImpl(testInstanceManager, proxySpy);
    final Long focusMeteringActionIdentifier = 43L;

    FocusMeteringAction.Builder mockFocusMeteringActionBuilder =
        mock(FocusMeteringAction.Builder.class);
    final MeteringPoint mockMeteringPoint1 = mock(MeteringPoint.class);
    final MeteringPoint mockMeteringPoint2 = mock(MeteringPoint.class);
    final MeteringPoint mockMeteringPoint3 = mock(MeteringPoint.class);
    final Long mockMeteringPoint1Id = 47L;
    final Long mockMeteringPoint2Id = 56L;
    final Long mockMeteringPoint3Id = 99L;
    final Integer mockMeteringPoint1Mode = FocusMeteringAction.FLAG_AE;
    final Integer mockMeteringPoint2Mode = FocusMeteringAction.FLAG_AF;

    MeteringPointInfo fakeMeteringPointInfo1 =
        new MeteringPointInfo.Builder()
            .setMeteringPointId(mockMeteringPoint1Id)
            .setMeteringMode(mockMeteringPoint1Mode.longValue())
            .build();
    MeteringPointInfo fakeMeteringPointInfo2 =
        new MeteringPointInfo.Builder()
            .setMeteringPointId(mockMeteringPoint2Id)
            .setMeteringMode(mockMeteringPoint2Mode.longValue())
            .build();
    MeteringPointInfo fakeMeteringPointInfo3 =
        new MeteringPointInfo.Builder()
            .setMeteringPointId(mockMeteringPoint3Id)
            .setMeteringMode(null)
            .build();

    testInstanceManager.addDartCreatedInstance(mockMeteringPoint1, mockMeteringPoint1Id);
    testInstanceManager.addDartCreatedInstance(mockMeteringPoint2, mockMeteringPoint2Id);
    testInstanceManager.addDartCreatedInstance(mockMeteringPoint3, mockMeteringPoint3Id);

    when(proxySpy.getFocusMeteringActionBuilder(
            mockMeteringPoint1, mockMeteringPoint1Mode.intValue()))
        .thenReturn(mockFocusMeteringActionBuilder);
    when(mockFocusMeteringActionBuilder.build()).thenReturn(focusMeteringAction);

    List<MeteringPointInfo> mockMeteringPointInfos =
        Arrays.asList(fakeMeteringPointInfo1, fakeMeteringPointInfo2, fakeMeteringPointInfo3);

    hostApi.create(focusMeteringActionIdentifier, mockMeteringPointInfos, null);

    verify(mockFocusMeteringActionBuilder).addPoint(mockMeteringPoint2, mockMeteringPoint2Mode);
    verify(mockFocusMeteringActionBuilder).addPoint(mockMeteringPoint3);
    assertEquals(
        testInstanceManager.getInstance(focusMeteringActionIdentifier), focusMeteringAction);
  }

  @Test
  public void
      hostApiCreate_createsExpectedFocusMeteringActionWithInitialPointThatDoesNotHaveMode() {
    FocusMeteringActionHostApiImpl.FocusMeteringActionProxy proxySpy =
        spy(new FocusMeteringActionHostApiImpl.FocusMeteringActionProxy());
    FocusMeteringActionHostApiImpl hostApi =
        new FocusMeteringActionHostApiImpl(testInstanceManager, proxySpy);
    final Long focusMeteringActionIdentifier = 43L;

    FocusMeteringAction.Builder mockFocusMeteringActionBuilder =
        mock(FocusMeteringAction.Builder.class);
    final MeteringPoint mockMeteringPoint1 = mock(MeteringPoint.class);
    final MeteringPoint mockMeteringPoint2 = mock(MeteringPoint.class);
    final MeteringPoint mockMeteringPoint3 = mock(MeteringPoint.class);
    final Long mockMeteringPoint1Id = 47L;
    final Long mockMeteringPoint2Id = 56L;
    final Long mockMeteringPoint3Id = 99L;
    final Integer mockMeteringPoint2Mode = FocusMeteringAction.FLAG_AF;

    MeteringPointInfo fakeMeteringPointInfo1 =
        new MeteringPointInfo.Builder()
            .setMeteringPointId(mockMeteringPoint1Id)
            .setMeteringMode(null)
            .build();
    MeteringPointInfo fakeMeteringPointInfo2 =
        new MeteringPointInfo.Builder()
            .setMeteringPointId(mockMeteringPoint2Id)
            .setMeteringMode(mockMeteringPoint2Mode.longValue())
            .build();
    MeteringPointInfo fakeMeteringPointInfo3 =
        new MeteringPointInfo.Builder()
            .setMeteringPointId(mockMeteringPoint3Id)
            .setMeteringMode(null)
            .build();

    testInstanceManager.addDartCreatedInstance(mockMeteringPoint1, mockMeteringPoint1Id);
    testInstanceManager.addDartCreatedInstance(mockMeteringPoint2, mockMeteringPoint2Id);
    testInstanceManager.addDartCreatedInstance(mockMeteringPoint3, mockMeteringPoint3Id);

    when(proxySpy.getFocusMeteringActionBuilder(mockMeteringPoint1))
        .thenReturn(mockFocusMeteringActionBuilder);
    when(mockFocusMeteringActionBuilder.build()).thenReturn(focusMeteringAction);

    List<MeteringPointInfo> mockMeteringPointInfos =
        Arrays.asList(fakeMeteringPointInfo1, fakeMeteringPointInfo2, fakeMeteringPointInfo3);

    hostApi.create(focusMeteringActionIdentifier, mockMeteringPointInfos, null);

    verify(mockFocusMeteringActionBuilder).addPoint(mockMeteringPoint2, mockMeteringPoint2Mode);
    verify(mockFocusMeteringActionBuilder).addPoint(mockMeteringPoint3);
    assertEquals(
        testInstanceManager.getInstance(focusMeteringActionIdentifier), focusMeteringAction);
  }

  @Test
  public void hostApiCreate_disablesAutoCancelAsExpected() {
    FocusMeteringActionHostApiImpl.FocusMeteringActionProxy proxySpy =
        spy(new FocusMeteringActionHostApiImpl.FocusMeteringActionProxy());
    FocusMeteringActionHostApiImpl hostApi =
        new FocusMeteringActionHostApiImpl(testInstanceManager, proxySpy);

    FocusMeteringAction.Builder mockFocusMeteringActionBuilder =
        mock(FocusMeteringAction.Builder.class);
    final MeteringPoint mockMeteringPoint = mock(MeteringPoint.class);
    final Long mockMeteringPointId = 47L;

    MeteringPointInfo fakeMeteringPointInfo =
        new MeteringPointInfo.Builder()
            .setMeteringPointId(mockMeteringPointId)
            .setMeteringMode(null)
            .build();

    testInstanceManager.addDartCreatedInstance(mockMeteringPoint, mockMeteringPointId);

    when(proxySpy.getFocusMeteringActionBuilder(mockMeteringPoint))
        .thenReturn(mockFocusMeteringActionBuilder);
    when(mockFocusMeteringActionBuilder.build()).thenReturn(focusMeteringAction);

    List<MeteringPointInfo> mockMeteringPointInfos = Arrays.asList(fakeMeteringPointInfo);

    // Test not disabling auto cancel.
    hostApi.create(73L, mockMeteringPointInfos, /* disableAutoCancel */ null);
    verify(mockFocusMeteringActionBuilder, never()).disableAutoCancel();

    hostApi.create(74L, mockMeteringPointInfos, /* disableAutoCancel */ false);
    verify(mockFocusMeteringActionBuilder, never()).disableAutoCancel();

    // Test disabling auto cancel.
    hostApi.create(75L, mockMeteringPointInfos, /* disableAutoCancel */ true);
    verify(mockFocusMeteringActionBuilder).disableAutoCancel();
  }
}
