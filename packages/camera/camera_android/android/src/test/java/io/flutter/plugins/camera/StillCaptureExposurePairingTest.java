// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoMoreInteractions;
import static org.mockito.Mockito.when;

import android.hardware.camera2.CaptureResult;
import android.hardware.camera2.TotalCaptureResult;
import android.media.Image;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class StillCaptureExposurePairingTest {

  private StillCaptureExposurePairing pairing;
  private StillCaptureExposurePairing.SaveSink saveSink;

  @Before
  public void setUp() {
    pairing = new StillCaptureExposurePairing();
    saveSink = mock(StillCaptureExposurePairing.SaveSink.class);
  }

  @Test
  public void totalCaptureResultBeforeImage_pairsBySensorTimestamp() {
    TotalCaptureResult result = mock(TotalCaptureResult.class);
    when(result.get(CaptureResult.SENSOR_TIMESTAMP)).thenReturn(100L);
    when(result.get(CaptureResult.SENSOR_EXPOSURE_TIME)).thenReturn(42L);

    pairing.onTotalCaptureResult(result, saveSink);

    Image image = mock(Image.class);
    when(image.getTimestamp()).thenReturn(100L);
    pairing.onImageAvailable(image, saveSink);

    verify(saveSink).save(eq(image), eq(42L));
    verifyNoMoreInteractions(saveSink);
  }

  @Test
  public void imageBeforeTotalCaptureResult_pairsBySensorTimestamp() {
    Image image = mock(Image.class);
    when(image.getTimestamp()).thenReturn(200L);
    pairing.onImageAvailable(image, saveSink);

    TotalCaptureResult result = mock(TotalCaptureResult.class);
    when(result.get(CaptureResult.SENSOR_TIMESTAMP)).thenReturn(200L);
    when(result.get(CaptureResult.SENSOR_EXPOSURE_TIME)).thenReturn(99L);

    pairing.onTotalCaptureResult(result, saveSink);

    verify(saveSink).save(eq(image), eq(99L));
    verifyNoMoreInteractions(saveSink);
  }

  @Test
  public void nullSensorTimestamp_resultFirst_thenImage_usesFallbackExposure() {
    TotalCaptureResult result = mock(TotalCaptureResult.class);
    when(result.get(CaptureResult.SENSOR_TIMESTAMP)).thenReturn(null);
    when(result.get(CaptureResult.SENSOR_EXPOSURE_TIME)).thenReturn(77L);

    pairing.onTotalCaptureResult(result, saveSink);

    Image image = mock(Image.class);
    when(image.getTimestamp()).thenReturn(300L);
    pairing.onImageAvailable(image, saveSink);

    verify(saveSink).save(eq(image), eq(77L));
    verifyNoMoreInteractions(saveSink);
  }

  @Test
  public void nullSensorTimestamp_imageFirst_drainsPendingWithFallbackExposure() {
    Image image = mock(Image.class);
    when(image.getTimestamp()).thenReturn(400L);
    pairing.onImageAvailable(image, saveSink);

    TotalCaptureResult result = mock(TotalCaptureResult.class);
    when(result.get(CaptureResult.SENSOR_TIMESTAMP)).thenReturn(null);
    when(result.get(CaptureResult.SENSOR_EXPOSURE_TIME)).thenReturn(88L);

    pairing.onTotalCaptureResult(result, saveSink);

    verify(saveSink).save(eq(image), eq(88L));
    verifyNoMoreInteractions(saveSink);
  }

  @Test
  public void imageTimestampZero_usesFallbackExposure() {
    TotalCaptureResult result = mock(TotalCaptureResult.class);
    when(result.get(CaptureResult.SENSOR_TIMESTAMP)).thenReturn(null);
    when(result.get(CaptureResult.SENSOR_EXPOSURE_TIME)).thenReturn(55L);
    pairing.onTotalCaptureResult(result, saveSink);

    Image image = mock(Image.class);
    when(image.getTimestamp()).thenReturn(0L);
    pairing.onImageAvailable(image, saveSink);

    verify(saveSink).save(eq(image), eq(55L));
    verifyNoMoreInteractions(saveSink);
  }

  @Test
  public void reset_closesPendingImages() {
    Image image = mock(Image.class);
    when(image.getTimestamp()).thenReturn(500L);
    pairing.onImageAvailable(image, saveSink);

    pairing.reset();

    verify(image).close();
    verify(saveSink, never()).save(any(), any());
  }

  @Test
  public void reset_discardsBufferedResults() {
    TotalCaptureResult result = mock(TotalCaptureResult.class);
    when(result.get(CaptureResult.SENSOR_TIMESTAMP)).thenReturn(600L);
    when(result.get(CaptureResult.SENSOR_EXPOSURE_TIME)).thenReturn(1L);
    pairing.onTotalCaptureResult(result, saveSink);

    pairing.reset();

    Image image = mock(Image.class);
    when(image.getTimestamp()).thenReturn(600L);
    pairing.onImageAvailable(image, saveSink);

    verify(saveSink, never()).save(any(), any());
    pairing.reset();
    verify(image).close();
  }
}
