// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.media;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.graphics.ImageFormat;
import android.media.Image;
import android.media.ImageReader;
import android.os.Handler;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugins.camera.types.CameraCaptureProperties;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class ImageStreamReaderTest {
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

  /** If we request YUV42 we should stream in YUV420. */
  @Test
  public void computeStreamImageFormat_computesCorrectStreamFormatYuv() {
    int requestedStreamFormat = ImageFormat.YUV_420_888;
    int result = ImageStreamReader.computeStreamImageFormat(requestedStreamFormat);
    assertEquals(result, ImageFormat.YUV_420_888);
  }

  /**
   * When we want to stream in NV21, we should still request YUV420 from the camera because we will
   * convert it to NV21 before sending it to dart.
   */
  @Test
  public void computeStreamImageFormat_computesCorrectStreamFormatNv21() {
    int requestedStreamFormat = ImageFormat.NV21;
    int result = ImageStreamReader.computeStreamImageFormat(requestedStreamFormat);
    assertEquals(result, ImageFormat.YUV_420_888);
  }

  /**
   * If we are requesting NV21, then the planes should be processed and converted to NV21 before
   * being sent to dart. We make sure yuv420ThreePlanesToNV21 is called when we are requesting
   */
  @Test
  public void onImageAvailable_parsesPlanesForNv21() {
    // Dart wants NV21 frames
    int dartImageFormat = ImageFormat.NV21;

    ImageReader mockImageReader = mock(ImageReader.class);
    ImageStreamReaderUtils mockImageStreamReaderUtils = mock(ImageStreamReaderUtils.class);
    ImageStreamReader imageStreamReader =
        new ImageStreamReader(mockImageReader, dartImageFormat, mockImageStreamReaderUtils);

    ByteBuffer mockBytes = ByteBuffer.allocate(0);
    when(mockImageStreamReaderUtils.yuv420ThreePlanesToNV21(any(), anyInt(), anyInt()))
        .thenReturn(mockBytes);

    // Note: the code for getImage() was previously inlined, with uSize set to one less than
    // getImage() calculates (see function implementation)
    Image mockImage = ImageStreamReaderTest.getImage(1280, 720, 256, ImageFormat.YUV_420_888);

    CameraCaptureProperties mockCaptureProps = mock(CameraCaptureProperties.class);
    EventChannel.EventSink mockEventSink = mock(EventChannel.EventSink.class);
    imageStreamReader.onImageAvailable(mockImage, mockCaptureProps, mockEventSink);

    // Make sure we processed the frame with parsePlanesForNv21
    verify(mockImageStreamReaderUtils)
        .yuv420ThreePlanesToNV21(
            mockImage.getPlanes(), mockImage.getWidth(), mockImage.getHeight());
  }

  /** If we are requesting YUV420, then we should send the 3-plane image as it is. */
  @Test
  public void onImageAvailable_parsesPlanesForYuv420() {
    // Dart wants NV21 frames
    int dartImageFormat = ImageFormat.YUV_420_888;

    ImageReader mockImageReader = mock(ImageReader.class);
    ImageStreamReaderUtils mockImageStreamReaderUtils = mock(ImageStreamReaderUtils.class);
    ImageStreamReader imageStreamReader =
        new ImageStreamReader(mockImageReader, dartImageFormat, mockImageStreamReaderUtils);

    ByteBuffer mockBytes = ByteBuffer.allocate(0);
    when(mockImageStreamReaderUtils.yuv420ThreePlanesToNV21(any(), anyInt(), anyInt()))
        .thenReturn(mockBytes);

    // Note: the code for getImage() was previously inlined, with uSize set to one less than
    // getImage() calculates (see function implementation)
    Image mockImage = ImageStreamReaderTest.getImage(1280, 720, 256, ImageFormat.YUV_420_888);

    CameraCaptureProperties mockCaptureProps = mock(CameraCaptureProperties.class);
    EventChannel.EventSink mockEventSink = mock(EventChannel.EventSink.class);
    imageStreamReader.onImageAvailable(mockImage, mockCaptureProps, mockEventSink);

    // Make sure we processed the frame with parsePlanesForYuvOrJpeg
    verify(mockImageStreamReaderUtils, never()).yuv420ThreePlanesToNV21(any(), anyInt(), anyInt());
  }

  @Test
  public void onImageAvailable_dropFramesWhenHandlerHalted() {
    final int numExtraFramesPerBatch = ImageStreamReader.MAX_IMAGES_IN_TRANSIT * 2;
    final int numFramesPerBatch = ImageStreamReader.MAX_IMAGES_IN_TRANSIT + numExtraFramesPerBatch;

    int dartImageFormat = ImageFormat.YUV_420_888;
    final List<Runnable> runnables = new ArrayList<Runnable>();

    ImageReader mockImageReader = mock(ImageReader.class);
    ImageStreamReaderUtils mockImageStreamReaderUtils = mock(ImageStreamReaderUtils.class);
    ImageStreamReader imageStreamReader =
        new ImageStreamReader(mockImageReader, dartImageFormat, mockImageStreamReaderUtils);

    Handler mockHandler = mock(Handler.class);
    imageStreamReader.handler = mockHandler;

    // initially, handler will simulate a hanging main looper, that only queues inputs
    when(mockHandler.post(any(Runnable.class)))
        .thenAnswer(
            inputs -> {
              Runnable r = inputs.getArgument(0, Runnable.class);
              runnables.add(r);
              return true;
            });

    CameraCaptureProperties mockCaptureProps = mock(CameraCaptureProperties.class);
    EventChannel.EventSink mockEventSink = mock(EventChannel.EventSink.class);

    // send some images whose "main-looper" callbacks won't get run, so some frames will drop
    for (int i = 0; i < numFramesPerBatch; ++i) {
      Image mockImage = ImageStreamReaderTest.getImage(1280, 720, 256, ImageFormat.YUV_420_888);
      imageStreamReader.onImageAvailable(mockImage, mockCaptureProps, mockEventSink);

      // make sure the image was closed, even when skipping frames
      verify(mockImage, times(1)).close();

      // frames beyond MAX_IMAGES_IN_TRANSIT are expected to be skipped
      final int expectedFramesInQueue =
          i < ImageStreamReader.MAX_IMAGES_IN_TRANSIT
              ? i + 1
              : ImageStreamReader.MAX_IMAGES_IN_TRANSIT;

      // check that we collected all runnables in this method
      assertEquals(runnables.size(), expectedFramesInQueue);

      // ensure the stream reader's count agrees
      assertEquals(imageStreamReader.numImagesInTransit, expectedFramesInQueue);

      // verify post() was not called more times than it should have
      verify(mockHandler, times(expectedFramesInQueue)).post(any(Runnable.class));
    }

    // make sure callback was not yet invoked
    verify(mockEventSink, never()).success(any(Map.class));

    // simulate frame processing
    for (Runnable r : runnables) {
      r.run();
    }

    // make sure all callbacks were invoked so far
    verify(mockEventSink, times(ImageStreamReader.MAX_IMAGES_IN_TRANSIT)).success(any(Map.class));

    // switch handler to simulate a running main looper
    when(mockHandler.post(any(Runnable.class)))
        .thenAnswer(
            input -> {
              Runnable r = input.getArgument(0, Runnable.class);
              r.run();
              return true;
            });

    // send some images that will get processed by the handler
    for (int i = 0; i < numFramesPerBatch; ++i) {
      Image mockImage = ImageStreamReaderTest.getImage(1280, 720, 256, ImageFormat.YUV_420_888);
      imageStreamReader.onImageAvailable(mockImage, mockCaptureProps, mockEventSink);

      // make sure the image is closed when no frame-skipping happens
      verify(mockImage, times(1)).close();

      // since the handler is not "halting", each image available should cause a post(), which the
      // mockHandler runs immediately, thus numImagesInTransit should remain zero.
      verify(mockHandler, times(ImageStreamReader.MAX_IMAGES_IN_TRANSIT + i + 1))
          .post(any(Runnable.class));
      assertEquals(imageStreamReader.numImagesInTransit, 0);
    }

    // make sure all callbacks were invoked
    verify(mockEventSink, times(ImageStreamReader.MAX_IMAGES_IN_TRANSIT + numFramesPerBatch))
        .success(any(Map.class));
  }
}
