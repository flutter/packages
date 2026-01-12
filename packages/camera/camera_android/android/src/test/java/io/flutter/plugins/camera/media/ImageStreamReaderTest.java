// Copyright 2013 The Flutter Authors
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
import java.lang.ref.WeakReference;
import java.lang.reflect.Field;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class ImageStreamReaderTest {
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
    Image mockImage = ImageStreamReaderTestUtils.getImage(1280, 720, 256, ImageFormat.YUV_420_888);

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
    Image mockImage = ImageStreamReaderTestUtils.getImage(1280, 720, 256, ImageFormat.YUV_420_888);

    CameraCaptureProperties mockCaptureProps = mock(CameraCaptureProperties.class);
    EventChannel.EventSink mockEventSink = mock(EventChannel.EventSink.class);
    imageStreamReader.onImageAvailable(mockImage, mockCaptureProps, mockEventSink);

    // Make sure we processed the frame with parsePlanesForYuvOrJpeg
    verify(mockImageStreamReaderUtils, never()).yuv420ThreePlanesToNV21(any(), anyInt(), anyInt());
  }

  @Test
  public void onImageAvailable_dropFramesWhenHandlerHalted() {
    int dartImageFormat = ImageFormat.YUV_420_888;

    ImageReader mockImageReader = mock(ImageReader.class);
    ImageStreamReaderUtils mockImageStreamReaderUtils = mock(ImageStreamReaderUtils.class);
    ImageStreamReader imageStreamReader =
        new ImageStreamReader(mockImageReader, dartImageFormat, mockImageStreamReaderUtils);

    for (boolean invalidateWeakReference : new boolean[] {true, false}) {
      final List<Runnable> runnables = new ArrayList<Runnable>();

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

      Image mockImage =
          ImageStreamReaderTestUtils.getImage(1280, 720, 256, ImageFormat.YUV_420_888);
      imageStreamReader.onImageAvailable(mockImage, mockCaptureProps, mockEventSink);

      // make sure the image was closed, even when skipping frames
      verify(mockImage, times(1)).close();

      // check that we collected all runnables in this method
      assertEquals(runnables.size(), 1);

      // verify post() was not called more times than it should have
      verify(mockHandler, times(1)).post(any(Runnable.class));

      // make sure callback was not yet invoked
      verify(mockEventSink, never()).success(any(Map.class));

      // simulate frame processing
      for (Runnable r : runnables) {
        if (invalidateWeakReference) {
          // Replace the captured WeakReference with one pointing to null.
          Field[] fields = r.getClass().getDeclaredFields();
          for (Field field : fields) {
            if (field.getType().equals(WeakReference.class)) {
              // Remove the `final` modifier
              try {
                field.set(r, new WeakReference<Map<String, Object>>(null));
              } catch (IllegalAccessException e) {
                throw new RuntimeException("Failed to inject null WeakReference", e);
              }
            }
          }
        }

        r.run();
      }

      // make sure all callbacks were invoked so far
      verify(mockEventSink, invalidateWeakReference ? never() : times(1)).success(any(Map.class));
    }
  }
}
