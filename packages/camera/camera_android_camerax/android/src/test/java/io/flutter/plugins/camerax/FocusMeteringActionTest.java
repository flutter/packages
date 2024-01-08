// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.camera.core.FocusMeteringAction;
import io.flutter.plugin.common.BinaryMessenger;
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
        new FocusMeteringActionHostApiImpl(testInstanceManager);
    final Long focusMeteringActionIdentifier = 43L;

    FocusMeteringAction.Builder mockFocusMeteringActionBuilder =
        mock(FocusMeteringAction.Builder.class);
    MeteringPoint mockMeteringPoint1 = mock(MeteringPoint.class);
    MeteringPoint mockMeteringPoint2 = mock(MeteringPoint.class);
    MeteringPoint mockMeteringPoint3 = mock(MeteringPoint.class);
    Long mockMeteringPoint1Id = 47L;
    Long mockMeteringPoint2Id = 56L;
    Long mockMeteringPoint3Id = 99L;
    int mockMeteringPoint1Mode = FocusMeteringAction.FLAG_AE;
    int mockMeteringPoint2Mode = FocusMeteringAction.FLAG_AF;

    MeteringPointInfo fakeMeteringPointInfo1 =
        new MeteringPointInfo.Builder()
            .setMeteringPointId(mockMeteringPoint1Id)
            .setMeteringMode(mockMeteringPoint1Mode);
    MeteringPointInfo fakeMeteringPointInfo2 =
        new MeteringPointInfo.Builder()
            .setMeteringPointId(mockMeteringPoint2Id)
            .setMeteringMode(mockMeteringPoint2Mode);
    MeteringPointInfo fakeMeteringPointInfo3 =
        new MeteringPointInfo.Builder()
            .setMeteringPointId(mockMeteringPoint3Id)
            .setMeteringMode(null);

    instanceManager.addDartCreatedInstance(mockMeteringPoint1, mockMeteringPoint1Id);
    instanceManager.addDartCreatedInstance(mockMeteringPoint2, mockMeteringPoint2Id);
    instanceManager.addDartCreatedInstance(mockMeteringPoint3, mockMeteringPoint3Id);

    when(proxySpy.getFocusMeteringActionBuilder(mockMeteringPoint1, mockMeteringPoint2))
        .thenReturn(mockFocusMeteringActionBuilder);
    when(mockFocusMeteringActionBuilder.build()).thenReturn(focusMeteringAction);

    List<MeteringPointInfo> mockMeteringPointInfos =
        Arrays.asList(fakeMeteringPointInfo1, fakeMeteringPointInfo2, fakeMeteringPointInfo3);

    hostApi.create(focusMeteringActionIdentifier, mockMeteringPointInfos);

    verify(mockFocusMeteringActionBuilder.addPoint(mockMeteringPoint2, mockMeteringPoint2Mode));
    verify(mockFocusMeteringActionBuilder.addPoint(mockMeteringPoint3));
    assertEquals(instanceManager.getInstance(focusMeteringActionIdentifier), focusMeteringAction);
  }

  @Test
  public void
      hostApiCreate_createsExpectedFocusMeteringActionWithInitialPointThatDoesNotHaveMode() {
    FocusMeteringActionHostApiImpl.FocusMeteringActionProxy proxySpy =
        spy(new FocusMeteringActionHostApiImpl.FocusMeteringActionProxy());
    FocusMeteringActionHostApiImpl hostApi =
        new FocusMeteringActionHostApiImpl(testInstanceManager);
    final Long focusMeteringActionIdentifier = 43L;

    FocusMeteringAction.Builder mockFocusMeteringActionBuilder =
        mock(FocusMeteringAction.Builder.class);
    MeteringPoint mockMeteringPoint1 = mock(MeteringPoint.class);
    MeteringPoint mockMeteringPoint2 = mock(MeteringPoint.class);
    MeteringPoint mockMeteringPoint3 = mock(MeteringPoint.class);
    Long mockMeteringPoint1Id = 47L;
    Long mockMeteringPoint2Id = 56L;
    Long mockMeteringPoint3Id = 99L;
    int mockMeteringPoint2Mode = FocusMeteringAction.FLAG_AF;

    MeteringPointInfo fakeMeteringPointInfo1 =
        new MeteringPointInfo.Builder()
            .setMeteringPointId(mockMeteringPoint1Id)
            .setMeteringMode(null);
    MeteringPointInfo fakeMeteringPointInfo2 =
        new MeteringPointInfo.Builder()
            .setMeteringPointId(mockMeteringPoint2Id)
            .setMeteringMode(mockMeteringPoint2Mode);
    MeteringPointInfo fakeMeteringPointInfo3 =
        new MeteringPointInfo.Builder()
            .setMeteringPointId(mockMeteringPoint3Id)
            .setMeteringMode(null);

    instanceManager.addDartCreatedInstance(mockMeteringPoint1, mockMeteringPoint1Id);
    instanceManager.addDartCreatedInstance(mockMeteringPoint2, mockMeteringPoint2Id);
    instanceManager.addDartCreatedInstance(mockMeteringPoint3, mockMeteringPoint3Id);

    when(proxySpy.getFocusMeteringActionBuilder(mockMeteringPoint1))
        .thenReturn(mockFocusMeteringActionBuilder);
    when(mockFocusMeteringActionBuilder.build()).thenReturn(focusMeteringAction);

    List<MeteringPointInfo> mockMeteringPointInfos =
        Arrays.asList(fakeMeteringPointInfo1, fakeMeteringPointInfo2, fakeMeteringPointInfo3);

    hostApi.create(focusMeteringActionIdentifier, mockMeteringPointInfos);

    verify(mockFocusMeteringActionBuilder.addPoint(mockMeteringPoint2, mockMeteringPoint2Mode));
    verify(mockFocusMeteringActionBuilder.addPoint(mockMeteringPoint3));
    assertEquals(instanceManager.getInstance(focusMeteringActionIdentifier), focusMeteringAction);
  }
}
