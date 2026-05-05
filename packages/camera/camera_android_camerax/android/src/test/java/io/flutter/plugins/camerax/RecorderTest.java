// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import android.content.Context;
import androidx.camera.video.FileOutputOptions;
import androidx.camera.video.PendingRecording;
import androidx.camera.video.Quality;
import androidx.camera.video.QualitySelector;
import androidx.camera.video.Recorder;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class RecorderTest {
  @Test
  public void pigeon_defaultConstructor_createsExpectedRecorderInstance() {
    final PigeonApiRecorder api = new TestProxyApiRegistrar().getPigeonApiRecorder();

    final long aspectRatio = 5;
    final long targetVideoEncodingBitRate = 7;
    final QualitySelector qualitySelector = QualitySelector.from(Quality.HD);
    final Recorder recorder =
        api.pigeon_defaultConstructor(aspectRatio, targetVideoEncodingBitRate, qualitySelector);

    assertEquals(recorder.getAspectRatio(), aspectRatio);
    assertEquals(recorder.getTargetVideoEncodingBitRate(), targetVideoEncodingBitRate);
    assertEquals(recorder.getQualitySelector(), qualitySelector);
  }

  @Test
  public void getAspectRatio_returnsExpectedAspectRatio() {
    final PigeonApiRecorder api = new TestProxyApiRegistrar().getPigeonApiRecorder();

    final Recorder instance = mock(Recorder.class);
    final long value = 0;
    when(instance.getAspectRatio()).thenReturn((int) value);

    assertEquals(value, api.getAspectRatio(instance));
  }

  @Test
  public void getTargetVideoEncodingBitRate_returnsExpectedBitRate() {
    final PigeonApiRecorder api = new TestProxyApiRegistrar().getPigeonApiRecorder();

    final Recorder instance = mock(Recorder.class);
    final long value = 0;
    when(instance.getTargetVideoEncodingBitRate()).thenReturn((int) value);

    assertEquals(value, api.getTargetVideoEncodingBitRate(instance));
  }

  @Test
  public void getQualitySelector_returnsExpectedQualitySelector() {
    final PigeonApiRecorder api = new TestProxyApiRegistrar().getPigeonApiRecorder();

    final Recorder instance = mock(Recorder.class);
    final androidx.camera.video.QualitySelector value = mock(QualitySelector.class);
    when(instance.getQualitySelector()).thenReturn(value);

    assertEquals(value, api.getQualitySelector(instance));
  }

  @Test
  public void prepareRecording_returnsExpectedPendingRecording() {
    final PigeonApiRecorder api = new TestProxyApiRegistrar().getPigeonApiRecorder();

    final Recorder mockRecorder = mock(Recorder.class);
    final PendingRecording mockPendingRecording = mock(PendingRecording.class);
    when(mockRecorder.prepareRecording(any(Context.class), any(FileOutputOptions.class)))
        .thenReturn(mockPendingRecording);

    assertEquals(mockPendingRecording, api.prepareRecording(mockRecorder, "myFile.mp4"));
  }

  @Test(expected = RuntimeException.class)
  public void prepareRecording_errorsOnInvalidPath() {
    final PigeonApiRecorder api = new TestProxyApiRegistrar().getPigeonApiRecorder();

    final Recorder mockRecorder = mock(Recorder.class);

    // This should trigger the catch block in RecorderProxyApi.openTempFile if path is null,
    // but Pigeon ensures it's non-null.
    // However, we can test that it throws if openTempFile fails (e.g. SecurityException).
    // But since openTempFile just calls new File(path), it doesn't throw much.

    // Let's test with a null path to trigger NullPointerException if we could,
    // but Pigeon marks it @NonNull.

    // Actually, RecorderProxyApi.prepareRecording is what we want to test.
    api.prepareRecording(mockRecorder, null);
  }
}
