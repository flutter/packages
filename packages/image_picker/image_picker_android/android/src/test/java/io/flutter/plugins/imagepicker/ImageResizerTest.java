// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.core.IsEqual.equalTo;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.when;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import java.io.File;
import java.io.IOException;
import java.util.List;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.robolectric.RobolectricTestRunner;

// RobolectricTestRunner always creates a default mock bitmap when reading from file. So we cannot actually test the scaling.
// But we can still test whether the original or scaled file is created.
@RunWith(RobolectricTestRunner.class)
public class ImageResizerTest {
  ImageResizer resizer;
  Context mockContext;
  File imageFile;
  File svgImageFile;
  File externalDirectory;
  Bitmap originalImageBitmap;

  AutoCloseable mockCloseable;

  @Before
  public void setUp() throws IOException {
    mockCloseable = MockitoAnnotations.openMocks(this);
    imageFile = new File(getClass().getClassLoader().getResource("pngImage.png").getFile());
    svgImageFile = new File(getClass().getClassLoader().getResource("flutter_image.svg").getFile());
    originalImageBitmap = BitmapFactory.decodeFile(imageFile.getPath());
    TemporaryFolder temporaryFolder = new TemporaryFolder();
    temporaryFolder.create();
    externalDirectory = temporaryFolder.newFolder("image_picker_testing_path");
    mockContext = mock(Context.class);
    when(mockContext.getCacheDir()).thenReturn(externalDirectory);
    resizer = new ImageResizer(mockContext, new ExifDataCopier());
  }

  @After
  public void tearDown() throws Exception {
    mockCloseable.close();
  }

  @Test
  public void onResizeImageIfNeeded_whenQualityIsMax_shouldNotResize_returnTheUnscaledFile() {
    String outputFile = resizer.resizeImageIfNeeded(imageFile.getPath(), null, null, 100);
    assertThat(outputFile, equalTo(imageFile.getPath()));
  }

  @Test
  public void onResizeImageIfNeeded_whenQualityIsNotMax_shouldResize_returnResizedFile() {
    String outputFile = resizer.resizeImageIfNeeded(imageFile.getPath(), null, null, 50);
    assertThat(outputFile, equalTo(externalDirectory.getPath() + "/scaled_pngImage.png"));
  }

  @Test
  public void onResizeImageIfNeeded_whenWidthIsNotNull_shouldResize_returnResizedFile() {
    String outputFile = resizer.resizeImageIfNeeded(imageFile.getPath(), 50.0, null, 100);
    assertThat(outputFile, equalTo(externalDirectory.getPath() + "/scaled_pngImage.png"));
  }

  @Test
  public void onResizeImageIfNeeded_whenHeightIsNotNull_shouldResize_returnResizedFile() {
    String outputFile = resizer.resizeImageIfNeeded(imageFile.getPath(), null, 50.0, 100);
    assertThat(outputFile, equalTo(externalDirectory.getPath() + "/scaled_pngImage.png"));
  }

  @Test
  public void onResizeImageIfNeeded_whenImagePathIsNotBitmap_shouldReturnPathAndNotNull() {
    String nonBitmapImagePath = svgImageFile.getPath();

    // Mock the static method
    try (MockedStatic<BitmapFactory> mockedBitmapFactory =
        Mockito.mockStatic(BitmapFactory.class)) {
      // Configure the method to return null when called with a non-bitmap image
      mockedBitmapFactory
          .when(() -> BitmapFactory.decodeFile(nonBitmapImagePath, null))
          .thenReturn(null);

      String resizedImagePath = resizer.resizeImageIfNeeded(nonBitmapImagePath, null, null, 100);

      assertNotNull(resizedImagePath);
      assertThat(resizedImagePath, equalTo(nonBitmapImagePath));
    }
  }

  @Test
  public void onResizeImageIfNeeded_whenResizeIsNotNecessary_shouldOnlyQueryBitmapDimensions() {
    try (MockedStatic<BitmapFactory> mockBitmapFactory =
        mockStatic(BitmapFactory.class, Mockito.CALLS_REAL_METHODS)) {
      String outputFile = resizer.resizeImageIfNeeded(imageFile.getPath(), null, null, 100);
      ArgumentCaptor<BitmapFactory.Options> argument =
          ArgumentCaptor.forClass(BitmapFactory.Options.class);
      mockBitmapFactory.verify(() -> BitmapFactory.decodeFile(anyString(), argument.capture()));
      BitmapFactory.Options capturedOptions = argument.getValue();
      assertTrue(capturedOptions.inJustDecodeBounds);
    }
  }

  @Test
  public void onResizeImageIfNeeded_whenResizeIsNecessary_shouldDecodeBitmapPixels() {
    try (MockedStatic<BitmapFactory> mockBitmapFactory =
        mockStatic(BitmapFactory.class, Mockito.CALLS_REAL_METHODS)) {
      String outputFile = resizer.resizeImageIfNeeded(imageFile.getPath(), 50.0, 50.0, 100);
      ArgumentCaptor<BitmapFactory.Options> argument =
          ArgumentCaptor.forClass(BitmapFactory.Options.class);
      mockBitmapFactory.verify(
          () -> BitmapFactory.decodeFile(anyString(), argument.capture()), times(2));
      List<BitmapFactory.Options> capturedOptions = argument.getAllValues();
      assertTrue(capturedOptions.get(0).inJustDecodeBounds);
      assertFalse(capturedOptions.get(1).inJustDecodeBounds);
    }
  }
}
