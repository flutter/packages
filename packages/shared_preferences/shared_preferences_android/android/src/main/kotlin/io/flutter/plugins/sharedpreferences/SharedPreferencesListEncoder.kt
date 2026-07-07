// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.sharedpreferences

/**
 * An interface used to provide conversion logic between List<String> and String for
 * SharedPreferencesPlugin.
</String> */
interface SharedPreferencesListEncoder {
    /** Converts list to String for storing in shared preferences.  */
    fun encode(list: MutableList<String?>): String

    /** Converts stored String representing List<String> to List. </String> */
    fun decode(listString: String): MutableList<String?>
}
