// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.sharedpreferences

import java.io.IOException
import java.io.InputStream
import java.io.ObjectInputStream
import java.io.ObjectStreamClass

/**
 * An ObjectInputStream that only allows string lists, to prevent injected prefs from instantiating
 * arbitrary objects.
 */
class StringListObjectInputStream(input: InputStream) : ObjectInputStream(input) {
  @Throws(ClassNotFoundException::class, IOException::class)
  override fun resolveClass(desc: ObjectStreamClass?): Class<*>? {
    val allowList =
        setOf(
            "java.util.Arrays\$ArrayList",
            "java.util.ArrayList",
            "java.lang.String",
            "[Ljava.lang.String;")
    val name = desc?.name
    if (name != null && !allowList.contains(name)) {
      throw ClassNotFoundException(desc.name)
    }
    return super.resolveClass(desc)
  }
}
