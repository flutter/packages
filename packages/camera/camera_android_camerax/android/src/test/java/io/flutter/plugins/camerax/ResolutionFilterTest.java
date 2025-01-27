// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;

import android.util.Size;
import androidx.camera.core.resolutionselector.ResolutionFilter;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ResolutionInfo;
import java.util.ArrayList;
import java.util.List;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class ResolutionFilterTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  InstanceManager instanceManager;

  @Before
  public void setUp() {
    instanceManager = InstanceManager.create(identifier -> {});
  }

  @After
  public void tearDown() {
    instanceManager.stopFinalizationListener();
  }

  @Test
  public void hostApiCreateWithOnePreferredSize_createsExpectedResolutionFilterInstance() {
    final ResolutionFilterHostApiImpl hostApi = new ResolutionFilterHostApiImpl(instanceManager);
    final long instanceIdentifier = 50;
    final long preferredResolutionWidth = 20;
    final long preferredResolutionHeight = 80;
    final ResolutionInfo preferredResolution =
        new ResolutionInfo.Builder()
            .setWidth(preferredResolutionWidth)
            .setHeight(preferredResolutionHeight)
            .build();

    hostApi.createWithOnePreferredSize(instanceIdentifier, preferredResolution);

    // Test that instance filters supported resolutions as expected.
    final ResolutionFilter resolutionFilter = instanceManager.getInstance(instanceIdentifier);
    final Size fakeSupportedSize1 = new Size(720, 480);
    final Size fakeSupportedSize2 = new Size(20, 80);
    final Size fakeSupportedSize3 = new Size(2, 8);
    final Size preferredSize =
        new Size((int) preferredResolutionWidth, (int) preferredResolutionHeight);

    final ArrayList<Size> fakeSupportedSizes = new ArrayList<Size>();
    fakeSupportedSizes.add(fakeSupportedSize1);
    fakeSupportedSizes.add(fakeSupportedSize2);
    fakeSupportedSizes.add(preferredSize);
    fakeSupportedSizes.add(fakeSupportedSize3);

    // Test the case where preferred resolution is supported.
    List<Size> filteredSizes = resolutionFilter.filter(fakeSupportedSizes, 90);
    assertEquals(filteredSizes.get(0), preferredSize);

    // Test the case where preferred resolution is not supported.
    fakeSupportedSizes.remove(0);
    filteredSizes = resolutionFilter.filter(fakeSupportedSizes, 90);
    assertEquals(filteredSizes, fakeSupportedSizes);
  }
}
