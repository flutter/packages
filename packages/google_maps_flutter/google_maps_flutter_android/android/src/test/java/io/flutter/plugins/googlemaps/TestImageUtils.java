// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.Base64;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;

// Collection of helper methods for generating test images.
public class TestImageUtils {
  // Helper method to generate 1x1 pixel base64 encoded png test image.
  public static String generateBase64Image() {
    int width = 1;
    int height = 1;
    Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
    Canvas canvas = new Canvas(bitmap);

    // Draw on the Bitmap
    Paint paint = new Paint();
    paint.setColor(Color.parseColor("#FF8080FF"));
    canvas.drawRect(0, 0, width, height, paint);

    // Convert the Bitmap to PNG format
    ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
    bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream);
    byte[] pngBytes = outputStream.toByteArray();

    // Encode the PNG bytes as a base64 string
    return Base64.encodeToString(pngBytes, Base64.DEFAULT);
  }

  // Helper method to generate input stream for 1x1 pixel test image.
  public static InputStream buildImageInputStream() {
    Bitmap fakeBitmap = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888);
    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
    fakeBitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream);
    byte[] byteArray = byteArrayOutputStream.toByteArray();
    return new ByteArrayInputStream(byteArray);
  }
}
