// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.exifinterface.media.ExifInterface;
import java.io.IOException;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

public class ExifDataCopierTest {
  @Mock ExifInterface mockOldExif;
  @Mock ExifInterface mockNewExif;

  ExifDataCopier exifDataCopier = new ExifDataCopier();

  AutoCloseable mockCloseable;

  String orientationValue = "Horizontal (normal)";
  String imageWidthValue = "4032";
  String whitePointValue = "0.96419 1 0.82489";
  String colorSpaceValue = "Uncalibrated";
  String exposureTimeValue = "1/9";
  String exposureModeValue = "Auto";
  String exifVersionValue = "0232";
  String makeValue = "Apple";
  String dateTimeOriginalValue = "2023:02:14 18:55:19";
  String offsetTimeValue = "+01:00";

  @Before
  public void setUp() {
    mockCloseable = MockitoAnnotations.openMocks(this);
  }

  @After
  public void tearDown() throws Exception {
    mockCloseable.close();
  }

  @Test
  public void copyExif_copiesOrientationAttribute() throws IOException {
    when(mockOldExif.getAttribute(ExifInterface.TAG_ORIENTATION)).thenReturn(orientationValue);

    exifDataCopier.copyExif(mockOldExif, mockNewExif);

    verify(mockNewExif).setAttribute(ExifInterface.TAG_ORIENTATION, orientationValue);
  }

  @Test
  public void copyExif_doesNotCopyCategory1AttributesExceptForOrientation() throws IOException {
    when(mockOldExif.getAttribute(ExifInterface.TAG_IMAGE_WIDTH)).thenReturn(imageWidthValue);
    when(mockOldExif.getAttribute(ExifInterface.TAG_WHITE_POINT)).thenReturn(whitePointValue);
    when(mockOldExif.getAttribute(ExifInterface.TAG_COLOR_SPACE)).thenReturn(colorSpaceValue);

    exifDataCopier.copyExif(mockOldExif, mockNewExif);

    verify(mockNewExif, never()).setAttribute(eq(ExifInterface.TAG_IMAGE_WIDTH), any());
    verify(mockNewExif, never()).setAttribute(eq(ExifInterface.TAG_WHITE_POINT), any());
    verify(mockNewExif, never()).setAttribute(eq(ExifInterface.TAG_COLOR_SPACE), any());
  }

  @Test
  public void copyExif_copiesCategory2Attributes() throws IOException {
    when(mockOldExif.getAttribute(ExifInterface.TAG_EXPOSURE_TIME)).thenReturn(exposureTimeValue);
    when(mockOldExif.getAttribute(ExifInterface.TAG_EXPOSURE_MODE)).thenReturn(exposureModeValue);
    when(mockOldExif.getAttribute(ExifInterface.TAG_EXIF_VERSION)).thenReturn(exifVersionValue);

    exifDataCopier.copyExif(mockOldExif, mockNewExif);

    verify(mockNewExif).setAttribute(ExifInterface.TAG_EXPOSURE_TIME, exposureTimeValue);
    verify(mockNewExif).setAttribute(ExifInterface.TAG_EXPOSURE_MODE, exposureModeValue);
    verify(mockNewExif).setAttribute(ExifInterface.TAG_EXIF_VERSION, exifVersionValue);
  }

  @Test
  public void copyExif_copiesCategory3Attributes() throws IOException {
    when(mockOldExif.getAttribute(ExifInterface.TAG_MAKE)).thenReturn(makeValue);
    when(mockOldExif.getAttribute(ExifInterface.TAG_DATETIME_ORIGINAL))
        .thenReturn(dateTimeOriginalValue);
    when(mockOldExif.getAttribute(ExifInterface.TAG_OFFSET_TIME)).thenReturn(offsetTimeValue);

    exifDataCopier.copyExif(mockOldExif, mockNewExif);

    verify(mockNewExif).setAttribute(ExifInterface.TAG_MAKE, makeValue);
    verify(mockNewExif).setAttribute(ExifInterface.TAG_DATETIME_ORIGINAL, dateTimeOriginalValue);
    verify(mockNewExif).setAttribute(ExifInterface.TAG_OFFSET_TIME, offsetTimeValue);
  }

  @Test
  public void copyExif_doesNotCopyUnsetAttributes() throws IOException {
    when(mockOldExif.getAttribute(ExifInterface.TAG_EXPOSURE_TIME)).thenReturn(null);

    exifDataCopier.copyExif(mockOldExif, mockNewExif);

    verify(mockNewExif, never()).setAttribute(eq(ExifInterface.TAG_EXPOSURE_TIME), any());
  }

  @Test
  public void copyExif_savesAttributes() throws IOException {
    exifDataCopier.copyExif(mockOldExif, mockNewExif);

    verify(mockNewExif).saveAttributes();
  }
}
