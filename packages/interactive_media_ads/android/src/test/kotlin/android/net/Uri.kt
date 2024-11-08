// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package android.net

/**
 * Redeclaration of Uri that works for tests.
 *
 * Without this redeclaration, `Uri.parse` always returns null.
 */
class Uri {
  companion object {
    @JvmStatic var lastValue: String? = null

    @JvmStatic
    fun parse(value: String): Uri {
      lastValue = value
      return Uri()
    }
  }
}
