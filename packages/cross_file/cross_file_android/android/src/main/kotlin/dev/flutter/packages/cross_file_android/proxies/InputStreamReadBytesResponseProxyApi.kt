// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.cross_file_android.proxies

import dev.flutter.packages.cross_file_android.InputStreamReadBytesResponse
import dev.flutter.packages.cross_file_android.ProxyApiRegistrar

/**
 * ProxyApi implementation for [InputStreamReadBytesResponse].
 *
 * This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class InputStreamReadBytesResponseProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) : PigeonApiInputStreamReadBytesResponse(pigeonRegistrar) {

  override fun returnValue(pigeon_instance: InputStreamReadBytesResponse): Long {
    return pigeon_instance.returnValue.toLong()
  }

  override fun bytes(pigeon_instance: InputStreamReadBytesResponse): ByteArray {
    return pigeon_instance.bytes
  }

}
