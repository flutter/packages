// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.cross_file_android.proxies

import dev.flutter.packages.cross_file_android.InputStreamReadBytesResponse
import dev.flutter.packages.cross_file_android.ProxyApiRegistrar
import java.io.InputStream

/**
 * ProxyApi implementation for [InputStream].
 *
 * This class may handle instantiating native object instances that are attached to a Dart instance
 * or handle method calls on the associated native class or an instance of that class.
 */
class InputStreamProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiInputStream(pigeonRegistrar) {
  override fun readBytes(pigeon_instance: InputStream, len: Long): InputStreamReadBytesResponse {
    val bytes = ByteArray(len.toInt())
    return InputStreamReadBytesResponse(pigeon_instance.read(bytes), bytes)
  }

  override fun readAllBytes(pigeon_instance: InputStream): ByteArray {
    return pigeon_instance.readBytes()
  }

  override fun skip(pigeon_instance: InputStream, n: Long): Long {
    return pigeon_instance.skip(n)
  }
}
