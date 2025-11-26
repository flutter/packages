// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.cross_file_android.proxies

import androidx.core.net.toUri
import androidx.documentfile.provider.DocumentFile
import dev.flutter.packages.cross_file_android.ProxyApiRegistrar

/**
 * ProxyApi implementation for [DocumentFile].
 *
 * This class may handle instantiating native object instances that are attached to a Dart instance
 * or handle method calls on the associated native class or an instance of that class.
 */
class DocumentFileProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiDocumentFile(pigeonRegistrar) {
  override fun fromSingleUri(path: String): DocumentFile {
    // Only returns null on platforms below Android 19.
    return DocumentFile.fromSingleUri(pigeonRegistrar.context, path.toUri())!!
  }

  override fun canRead(pigeon_instance: DocumentFile): Boolean {
    return pigeon_instance.canRead()
  }

  override fun delete(pigeon_instance: DocumentFile): Boolean {
    return pigeon_instance.delete()
  }

  override fun exists(pigeon_instance: DocumentFile): Boolean {
    return pigeon_instance.exists()
  }

  override fun lastModified(pigeon_instance: DocumentFile): Long {
    return pigeon_instance.lastModified()
  }

  override fun length(pigeon_instance: DocumentFile): Long {
    return pigeon_instance.length()
  }
}
