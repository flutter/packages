// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;

import android.util.Size;
import androidx.camera.core.resolutionselector.ResolutionFilter;
import java.util.ArrayList;
import java.util.List;
import org.junit.Test;

public class ResolutionFilterTest {
  @Test
  public void createWithOnePreferredSize_createsExpectedResolutionFilterInstance() {
    final PigeonApiResolutionFilter api =
        new TestProxyApiRegistrar().getPigeonApiResolutionFilter();

    final int preferredResolutionWidth = 20;
    final int preferredResolutionHeight = 80;
    final ResolutionFilter resolutionFilter =
        api.createWithOnePreferredSize(
            new Size(preferredResolutionWidth, preferredResolutionHeight));

    // Test that instance filters supported resolutions as expected.
    final Size fakeSupportedSize1 = new Size(720, 480);
    final Size fakeSupportedSize2 = new Size(20, 80);
    final Size fakeSupportedSize3 = new Size(2, 8);
    final Size preferredSize = new Size(preferredResolutionWidth, preferredResolutionHeight);

    final ArrayList<Size> fakeSupportedSizes = new ArrayList<>();
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
