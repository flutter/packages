// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.sharedpreferences

/**
 * An interface used to provide conversion logic between List<String> and String for
 * SharedPreferencesPlugin.
 */
interface SharedPreferencesListEncoder {
  /** Converts list to String for storing in shared preferences. */
  fun encode(list: List<String>): String

  /** Converts stored String representing List<String> to List. */
  fun decode(listString: String): List<String>
}
