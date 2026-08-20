// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
public class ImagePickerUtilsTest {

  @Test
  @Config(sdk = 35)
  public void effectiveUsePhotoPicker_belowApi36_usesDartPreference() {
    assertFalse(ImagePickerUtils.effectiveUsePhotoPicker(false));
    assertTrue(ImagePickerUtils.effectiveUsePhotoPicker(true));
  }

  @Test
  @Config(sdk = 36)
  public void effectiveUsePhotoPicker_onApi36_alwaysUsesPhotoPicker() {
    assertTrue(ImagePickerUtils.effectiveUsePhotoPicker(false));
    assertTrue(ImagePickerUtils.effectiveUsePhotoPicker(true));
  }
}
