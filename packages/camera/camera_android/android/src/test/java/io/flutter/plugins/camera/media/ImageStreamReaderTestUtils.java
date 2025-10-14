// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.media;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import android.media.Image;
import java.nio.ByteBuffer;

public class ImageStreamReaderTestUtils {
  /**
   * Creates a mock {@link android.media.Image} object for use in tests, simulating the specified
   * dimensions, padding, and image format.
   */
  public static Image getImage(int imageWidth, int imageHeight, int padding, int imageFormat) {
    int rowStride = imageWidth + padding;

    int ySize = (rowStride * imageHeight) - padding;
    int uSize = (ySize / 2) - (padding / 2);
    int vSize = uSize;

    // Mock YUV image
    Image mockImage = mock(Image.class);
    when(mockImage.getWidth()).thenReturn(imageWidth);
    when(mockImage.getHeight()).thenReturn(imageHeight);
    when(mockImage.getFormat()).thenReturn(imageFormat);

    // Mock planes. YUV images have 3 planes (Y, U, V).
    Image.Plane planeY = mock(Image.Plane.class);
    Image.Plane planeU = mock(Image.Plane.class);
    Image.Plane planeV = mock(Image.Plane.class);

    // Y plane is width*height
    // Row stride is generally == width but when there is padding it will
    // be larger.
    // Here we are adding 256 padding.
    when(planeY.getBuffer()).thenReturn(ByteBuffer.allocate(ySize));
    when(planeY.getRowStride()).thenReturn(rowStride);
    when(planeY.getPixelStride()).thenReturn(1);

    // U and V planes are always the same sizes/values.
    // https://developer.android.com/reference/android/graphics/ImageFormat#YUV_420_888
    when(planeU.getBuffer()).thenReturn(ByteBuffer.allocate(uSize));
    when(planeV.getBuffer()).thenReturn(ByteBuffer.allocate(vSize));
    when(planeU.getRowStride()).thenReturn(rowStride);
    when(planeV.getRowStride()).thenReturn(rowStride);
    when(planeU.getPixelStride()).thenReturn(2);
    when(planeV.getPixelStride()).thenReturn(2);

    // Add planes to image
    Image.Plane[] planes = {planeY, planeU, planeV};
    when(mockImage.getPlanes()).thenReturn(planes);

    return mockImage;
  }
}
