// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.cross_file_android

import android.content.Context
import dev.flutter.packages.cross_file_android.proxies.AndroidLibraryPigeonProxyApiRegistrar
import dev.flutter.packages.cross_file_android.proxies.ContentResolverProxyApi
import dev.flutter.packages.cross_file_android.proxies.DocumentFileProxyApi
import dev.flutter.packages.cross_file_android.proxies.InputStreamProxyApi
import dev.flutter.packages.cross_file_android.proxies.PigeonApiContentResolver
import dev.flutter.packages.cross_file_android.proxies.PigeonApiDocumentFile
import dev.flutter.packages.cross_file_android.proxies.PigeonApiInputStream
import io.flutter.plugin.common.BinaryMessenger

/**
 * Implementation of [AndroidLibraryPigeonProxyApiRegistrar] that provides each ProxyApi
 * implementation and any additional resources needed by an implementation.
 */
open class ProxyApiRegistrar(binaryMessenger: BinaryMessenger, var context: Context) :
    AndroidLibraryPigeonProxyApiRegistrar(binaryMessenger) {

  override fun getPigeonApiDocumentFile(): PigeonApiDocumentFile {
    return DocumentFileProxyApi(this)
  }

  override fun getPigeonApiContentResolver(): PigeonApiContentResolver {
    return ContentResolverProxyApi(this)
  }

  override fun getPigeonApiInputStream(): PigeonApiInputStream {
    return InputStreamProxyApi(this)
  }
}
