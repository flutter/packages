// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockConstruction;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.media.Image;
import androidx.exifinterface.media.ExifInterface;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.mockito.MockedConstruction;
import org.mockito.MockedStatic;

public class ImageSaverExifTests {
  private Image mockImage;
  private File mockFile;
  private ImageSaver.Callback mockCallback;
  private MockedStatic<ImageSaver.FileOutputStreamFactory> mockFileOutputStreamFactory;
  private FileOutputStream mockFileOutputStream;

  @Before
  public void setup() {
    mockFile = mock(File.class);
    when(mockFile.getAbsolutePath()).thenReturn("absolute/path");
    Image.Plane mockPlane = mock(Image.Plane.class);
    when(mockPlane.getBuffer())
        .thenReturn(java.nio.ByteBuffer.wrap(new byte[] {0x42, 0x00, 0x13}));
    mockImage = mock(Image.class);
    when(mockImage.getPlanes()).thenReturn(new Image.Plane[] {mockPlane});
    mockFileOutputStreamFactory = mockStatic(ImageSaver.FileOutputStreamFactory.class);
    mockFileOutputStream = mock(FileOutputStream.class);
    mockFileOutputStreamFactory
        .when(() -> ImageSaver.FileOutputStreamFactory.create(any()))
        .thenReturn(mockFileOutputStream);
    mockCallback = mock(ImageSaver.Callback.class);
  }

  @After
  public void teardown() {
    mockFileOutputStreamFactory.close();
  }

  @Test
  public void run_writesExposureTimeToExif_whenNotPresent() throws IOException {
    ImageSaver imageSaver = new ImageSaver(mockImage, mockFile, mockCallback, 1_000_000_000L);
    try (MockedConstruction<ExifInterface> mockedExif =
        mockConstruction(
            ExifInterface.class,
            (mock, ctx) -> when(mock.getAttribute(ExifInterface.TAG_EXPOSURE_TIME)).thenReturn(null))) {
      imageSaver.run();
      ExifInterface exif = mockedExif.constructed().get(0);
      verify(exif).getAttribute(ExifInterface.TAG_EXPOSURE_TIME);
      verify(exif).setAttribute(eq(ExifInterface.TAG_EXPOSURE_TIME), eq("1.0"));
      verify(exif).saveAttributes();
    }
  }

  @Test
  public void run_convertsNanosecondsToSeconds() throws IOException {
    ImageSaver imageSaver = new ImageSaver(mockImage, mockFile, mockCallback, 500_000_000L);
    try (MockedConstruction<ExifInterface> mockedExif =
        mockConstruction(
            ExifInterface.class,
            (mock, ctx) -> when(mock.getAttribute(ExifInterface.TAG_EXPOSURE_TIME)).thenReturn(null))) {
      imageSaver.run();
      verify(mockedExif.constructed().get(0))
          .setAttribute(eq(ExifInterface.TAG_EXPOSURE_TIME), eq("0.5"));
    }
  }

  @Test
  public void run_doesNotWriteExif_whenExposureTimeIsNull() throws IOException {
    ImageSaver imageSaver = new ImageSaver(mockImage, mockFile, mockCallback, null);
    try (MockedConstruction<ExifInterface> mockedExif = mockConstruction(ExifInterface.class)) {
      imageSaver.run();
      assertEquals(0, mockedExif.constructed().size());
    }
  }

  @Test
  public void run_doesNotOverwriteExistingExposureTime() throws IOException {
    ImageSaver imageSaver = new ImageSaver(mockImage, mockFile, mockCallback, 1_000_000_000L);
    try (MockedConstruction<ExifInterface> mockedExif =
        mockConstruction(
            ExifInterface.class,
            (mock, ctx) ->
                when(mock.getAttribute(ExifInterface.TAG_EXPOSURE_TIME)).thenReturn("0.8"))) {
      imageSaver.run();
      ExifInterface exif = mockedExif.constructed().get(0);
      verify(exif).getAttribute(ExifInterface.TAG_EXPOSURE_TIME);
      verify(exif, never()).setAttribute(eq(ExifInterface.TAG_EXPOSURE_TIME), any());
      verify(exif, never()).saveAttributes();
    }
  }

  @Test
  public void run_continuesOnExifError() throws IOException {
    ImageSaver imageSaver = new ImageSaver(mockImage, mockFile, mockCallback, 1_000_000_000L);
    try (MockedConstruction<ExifInterface> mockedExif =
        mockConstruction(
            ExifInterface.class,
            (mock, ctx) -> {
              when(mock.getAttribute(ExifInterface.TAG_EXPOSURE_TIME)).thenReturn(null);
              doThrow(new IOException()).when(mock).setAttribute(any(), any());
            })) {
      imageSaver.run();
      verify(mockCallback).onComplete("absolute/path");
      verify(mockCallback, never()).onError(any(), any());
      org.junit.Assert.assertFalse(mockedExif.constructed().isEmpty());
    }
  }
}
