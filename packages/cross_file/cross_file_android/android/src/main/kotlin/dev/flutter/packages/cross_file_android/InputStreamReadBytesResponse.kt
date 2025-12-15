// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.cross_file_android

/** Represents the result of reading bytes from an [java.io.InputStream]. */
data class InputStreamReadBytesResponse(val returnValue: Int, val bytes: ByteArray) {
  override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (javaClass != other?.javaClass) return false

    other as InputStreamReadBytesResponse

    if (returnValue != other.returnValue) return false
    if (!bytes.contentEquals(other.bytes)) return false

    return true
  }

  override fun hashCode(): Int {
    var result = returnValue
    result = 31 * result + bytes.contentHashCode()
    return result
  }
}
