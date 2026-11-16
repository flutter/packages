// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.googlemaps

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.util.Base64
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.InputStream

// Collection of helper methods for generating test images.
object TestImageUtils {
  // Helper method to generate 1x1 pixel base64 encoded png test image.
  fun generateBase64Image(): String {
    val width = 1
    val height = 1
    val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(bitmap)

    // Draw on the Bitmap
    val paint = Paint()
    paint.setColor(Color.parseColor("#FF8080FF"))
    canvas.drawRect(0f, 0f, width.toFloat(), height.toFloat(), paint)

    // Convert the Bitmap to PNG format
    val outputStream = ByteArrayOutputStream()
    bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
    val pngBytes = outputStream.toByteArray()

    // Encode the PNG bytes as a base64 string
    return Base64.encodeToString(pngBytes, Base64.DEFAULT)
  }

  // Helper method to generate input stream for 1x1 pixel test image.
  fun buildImageInputStream(): InputStream {
    val fakeBitmap = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888)
    val byteArrayOutputStream = ByteArrayOutputStream()
    fakeBitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream)
    val byteArray = byteArrayOutputStream.toByteArray()
    return ByteArrayInputStream(byteArray)
  }
}
