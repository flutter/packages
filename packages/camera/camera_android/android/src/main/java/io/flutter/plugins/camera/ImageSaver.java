// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import android.media.Image;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.exifinterface.media.ExifInterface;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;

/** Saves a JPEG {@link Image} into the specified {@link File}. */
public class ImageSaver implements Runnable {
  private static final String TAG = "ImageSaver";

  /** The JPEG image */
  private final Image image;

  /** The file we save the image into. */
  private final File file;

  /** Used to report the status of the save action. */
  private final Callback callback;

  /** The exposure time in nanoseconds, or null if not available. */
  @Nullable private final Long exposureTimeNs;

  /**
   * Creates an instance of the ImageSaver runnable
   *
   * @param image - The image to save
   * @param file - The file to save the image to
   * @param callback - The callback that is run on completion, or when an error is encountered.
   * @param exposureTimeNs - The exposure time in nanoseconds, or null if not available.
   */
  ImageSaver(
      @NonNull Image image,
      @NonNull File file,
      @NonNull Callback callback,
      @Nullable Long exposureTimeNs) {
    this.image = image;
    this.file = file;
    this.callback = callback;
    this.exposureTimeNs = exposureTimeNs;
  }

  @Override
  public void run() {
    ByteBuffer buffer = image.getPlanes()[0].getBuffer();
    byte[] bytes = new byte[buffer.remaining()];
    buffer.get(bytes);
    FileOutputStream output = null;
    try {
      output = FileOutputStreamFactory.create(file);
      output.write(bytes);

      // Write exposure time to EXIF if available and not already present
      if (exposureTimeNs != null) {
        try {
          ExifInterface exif = new ExifInterface(file.getAbsolutePath());
          // Only set exposure time if it's not already present in EXIF
          String existingExposureTime = exif.getAttribute(ExifInterface.TAG_EXPOSURE_TIME);
          if (existingExposureTime == null || existingExposureTime.isEmpty()) {
            // Convert nanoseconds to seconds
            double exposureTimeInSeconds = exposureTimeNs / 1_000_000_000.0;
            exif.setAttribute(ExifInterface.TAG_EXPOSURE_TIME, String.valueOf(exposureTimeInSeconds));
            exif.saveAttributes();
          }
        } catch (IOException e) {
          // Log error but don't fail the save operation
          Log.w(TAG, "Failed to write exposure time to EXIF", e);
        }
      }

      callback.onComplete(file.getAbsolutePath());

    } catch (IOException e) {
      callback.onError("IOError", "Failed saving image");
    } finally {
      image.close();
      if (null != output) {
        try {
          output.close();
        } catch (IOException e) {
          callback.onError("cameraAccess", e.getMessage());
        }
      }
    }
  }

  /**
   * The interface for the callback that is passed to ImageSaver, for detecting completion or
   * failure of the image saving task.
   */
  public interface Callback {
    /**
     * Called when the image file has been saved successfully.
     *
     * @param absolutePath - The absolute path of the file that was saved.
     */
    void onComplete(@NonNull String absolutePath);

    /**
     * Called when an error is encountered while saving the image file.
     *
     * @param errorCode - The error code.
     * @param errorMessage - The human readable error message.
     */
    void onError(@NonNull String errorCode, @NonNull String errorMessage);
  }

  /** Factory class that assists in creating a {@link FileOutputStream} instance. */
  static class FileOutputStreamFactory {
    /**
     * Creates a new instance of the {@link FileOutputStream} class.
     *
     * <p>This method is visible for testing purposes only and should never be used outside this *
     * class.
     *
     * @param file - The file to create the output stream for
     * @return new instance of the {@link FileOutputStream} class.
     * @throws FileNotFoundException when the supplied file could not be found.
     */
    @VisibleForTesting
    public static FileOutputStream create(File file) throws FileNotFoundException {
      return new FileOutputStream(file);
    }
  }
}
