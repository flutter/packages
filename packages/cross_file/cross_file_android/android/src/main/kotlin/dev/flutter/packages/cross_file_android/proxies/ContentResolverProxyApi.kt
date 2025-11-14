// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.cross_file_android.proxies

import android.content.ContentResolver
import androidx.core.net.toUri
import dev.flutter.packages.cross_file_android.ProxyApiRegistrar
import java.io.InputStream

/**
 * ProxyApi implementation for [ContentResolver].
 *
 * This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class ContentResolverProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) : PigeonApiContentResolver(pigeonRegistrar) {
  override fun instance(): ContentResolver {
    return pigeonRegistrar.context.contentResolver
  }

  override fun openInputStream(pigeon_instance: ContentResolver,uri: String): InputStream? {
    return pigeon_instance.openInputStream(uri.toUri())
  }
}
