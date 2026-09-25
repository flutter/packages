// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package android.net

/**
 * Redeclaration of Uri that works for tests.
 *
 * Without this redeclaration, `Uri.parse` always returns null.
 */
data class Uri(val uri: String) {
  companion object {
    @JvmStatic
    fun parse(value: String): Uri {
      return Uri(value)
    }
  }

  override fun toString(): String {
    return this.uri
  }
}
