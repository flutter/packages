// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.core.util.SizeFCompat;
import androidx.exifinterface.media.ExifInterface;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

class ImageResizer {
  private final Context context;
  private final ExifDataCopier exifDataCopier;

  ImageResizer(final @NonNull Context context, final @NonNull ExifDataCopier exifDataCopier) {
    this.context = context;
    this.exifDataCopier = exifDataCopier;
  }

  /**
   * If necessary, resizes the image located in imagePath and then returns the path for the scaled
   * image.
   *
   * <p>If no resizing is needed, returns the path for the original image.
   */
  String resizeImageIfNeeded(
      String imagePath, @Nullable Double maxWidth, @Nullable Double maxHeight, int imageQuality) {
    SizeFCompat originalSize = readFileDimensions(imagePath);
    if (originalSize.getWidth() == -1 || originalSize.getHeight() == -1) {
      return imagePath;
    }
    boolean shouldScale = maxWidth != null || maxHeight != null || imageQuality < 100;
    if (!shouldScale) {
      return imagePath;
    }
    try {
      String[] pathParts = imagePath.split("/");
      String imageName = pathParts[pathParts.length - 1];
      SizeFCompat targetSize =
          calculateTargetSize(
              (double) originalSize.getWidth(),
              (double) originalSize.getHeight(),
              maxWidth,
              maxHeight);
      BitmapFactory.Options options = new BitmapFactory.Options();
      options.inSampleSize =
          calculateSampleSize(options, (int) targetSize.getWidth(), (int) targetSize.getHeight());
      Bitmap bmp = decodeFile(imagePath, options);
      if (bmp == null) {
        return imagePath;
      }
      File file =
          resizedImage(
              bmp,
              (double) targetSize.getWidth(),
              (double) targetSize.getHeight(),
              imageQuality,
              imageName);
      copyExif(imagePath, file.getPath());
      return file.getPath();
    } catch (IOException e) {
      throw new RuntimeException(e);
    }
  }

  private File resizedImage(
      Bitmap bmp, Double width, Double height, int imageQuality, String outputImageName)
      throws IOException {
    Bitmap scaledBmp = createScaledBitmap(bmp, width.intValue(), height.intValue(), false);
    File file =
        createImageOnExternalDirectory("/scaled_" + outputImageName, scaledBmp, imageQuality);
    return file;
  }

  private SizeFCompat calculateTargetSize(
      double originalWidth,
      double originalHeight,
      @Nullable Double maxWidth,
      @Nullable Double maxHeight) {
    double aspectRatio = originalWidth / originalHeight;

    boolean hasMaxWidth = maxWidth != null;
    boolean hasMaxHeight = maxHeight != null;

    double width = hasMaxWidth ? Math.min(originalWidth, Math.round(maxWidth)) : originalWidth;
    double height = hasMaxHeight ? Math.min(originalHeight, Math.round(maxHeight)) : originalHeight;

    boolean shouldDownscaleWidth = hasMaxWidth && maxWidth < originalWidth;
    boolean shouldDownscaleHeight = hasMaxHeight && maxHeight < originalHeight;
    boolean shouldDownscale = shouldDownscaleWidth || shouldDownscaleHeight;

    if (shouldDownscale) {
      double WidthForMaxHeight = height * aspectRatio;
      double heightForMaxWidth = width / aspectRatio;

      if (heightForMaxWidth > height) {
        width = (double) Math.round(WidthForMaxHeight);
      } else {
        height = (double) Math.round(heightForMaxWidth);
      }
    }

    return new SizeFCompat((float) width, (float) height);
  }

  private File createFile(File externalFilesDirectory, String child) {
    File image = new File(externalFilesDirectory, child);
    if (!image.getParentFile().exists()) {
      image.getParentFile().mkdirs();
    }
    return image;
  }

  private FileOutputStream createOutputStream(File imageFile) throws IOException {
    return new FileOutputStream(imageFile);
  }

  private void copyExif(String filePathOri, String filePathDest) {
    try {
      exifDataCopier.copyExif(new ExifInterface(filePathOri), new ExifInterface(filePathDest));
    } catch (Exception ex) {
      Log.e("ImageResizer", "Error preserving Exif data on selected image: " + ex);
    }
  }

  @VisibleForTesting
  SizeFCompat readFileDimensions(String path) {
    BitmapFactory.Options options = new BitmapFactory.Options();
    options.inJustDecodeBounds = true;
    decodeFile(path, options);
    return new SizeFCompat(options.outWidth, options.outHeight);
  }

  private Bitmap decodeFile(String path, @Nullable BitmapFactory.Options opts) {
    return BitmapFactory.decodeFile(path, opts);
  }

  private Bitmap createScaledBitmap(Bitmap bmp, int width, int height, boolean filter) {
    return Bitmap.createScaledBitmap(bmp, width, height, filter);
  }

  /**
   * Calculates the largest sample size value that is a power of two based on a target width and
   * height.
   *
   * <p>This value is necessary to tell the Bitmap decoder to subsample the original image,
   * returning a smaller image to save memory.
   *
   * @see <a
   *     href="https://developer.android.com/topic/performance/graphics/load-bitmap#load-bitmap">
   *     Loading Large Bitmaps Efficiently</a>
   */
  private int calculateSampleSize(
      BitmapFactory.Options options, int targetWidth, int targetHeight) {
    final int height = options.outHeight;
    final int width = options.outWidth;
    int sampleSize = 1;
    if (height > targetHeight || width > targetWidth) {
      final int halfHeight = height / 2;
      final int halfWidth = width / 2;
      while ((halfHeight / sampleSize) >= targetHeight && (halfWidth / sampleSize) >= targetWidth) {
        sampleSize *= 2;
      }
    }
    return sampleSize;
  }

  private File createImageOnExternalDirectory(String name, Bitmap bitmap, int imageQuality)
      throws IOException {
    ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
    boolean saveAsPNG = bitmap.hasAlpha();
    if (saveAsPNG) {
      Log.d(
          "ImageResizer",
          "image_picker: compressing is not supported for type PNG. Returning the image with original quality");
    }
    bitmap.compress(
        saveAsPNG ? Bitmap.CompressFormat.PNG : Bitmap.CompressFormat.JPEG,
        imageQuality,
        outputStream);

    File cacheDirectory = context.getCacheDir();
    File imageFile = createFile(cacheDirectory, name);
    FileOutputStream fileOutput = createOutputStream(imageFile);
    fileOutput.write(outputStream.toByteArray());
    fileOutput.close();
    return imageFile;
  }
}
