// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.media;

import android.graphics.ImageFormat;
import android.media.Image;
import java.nio.ByteBuffer;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class ImageStreamReaderUtilsTest {
  private ImageStreamReaderUtils imageStreamReaderUtils;

  @Before
  public void setUp() {
    this.imageStreamReaderUtils = new ImageStreamReaderUtils();
  }

  /** Ensure that passing in an image with padding returns one without padding */
  @Test
  public void yuv420ThreePlanesToNV21_trimsPaddingWhenPresent() {
    Image mockImage = ImageStreamReaderTestUtils.getImage(160, 120, 16, ImageFormat.YUV_420_888);
    int imageWidth = mockImage.getWidth();
    int imageHeight = mockImage.getHeight();

    ByteBuffer result =
        imageStreamReaderUtils.yuv420ThreePlanesToNV21(
            mockImage.getPlanes(), mockImage.getWidth(), mockImage.getHeight());
    Assert.assertEquals(
        ((long) imageWidth * imageHeight) + (2 * ((long) (imageWidth / 2) * (imageHeight / 2))),
        result.limit());
  }

  /** Ensure that passing in an image without padding returns the same size */
  @Test
  public void yuv420ThreePlanesToNV21_trimsPaddingWhenAbsent() {
    Image mockImage = ImageStreamReaderTestUtils.getImage(160, 120, 0, ImageFormat.YUV_420_888);
    int imageWidth = mockImage.getWidth();
    int imageHeight = mockImage.getHeight();

    ByteBuffer result =
        imageStreamReaderUtils.yuv420ThreePlanesToNV21(
            mockImage.getPlanes(), mockImage.getWidth(), mockImage.getHeight());
    Assert.assertEquals(
        ((long) imageWidth * imageHeight) + (2 * ((long) (imageWidth / 2) * (imageHeight / 2))),
        result.limit());
  }
}
