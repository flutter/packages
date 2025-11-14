package dev.flutter.packages.cross_file_android

import android.content.Context
import android.os.Build
import android.os.Looper
import androidx.annotation.ChecksSdkIntAtLeast
import dev.flutter.packages.cross_file_android.proxies.DocumentFilePigeonProxyApiRegistrar
import dev.flutter.packages.cross_file_android.proxies.PigeonApiContentResolver
import dev.flutter.packages.cross_file_android.proxies.PigeonApiDocumentFile
import dev.flutter.packages.cross_file_android.proxies.PigeonApiInputStream
import dev.flutter.packages.cross_file_android.proxies.PigeonApiInputStreamReadBytesResponse
import io.flutter.plugin.common.BinaryMessenger
import android.os.Handler
import dev.flutter.packages.cross_file_android.proxies.ContentResolverProxyApi
import dev.flutter.packages.cross_file_android.proxies.DocumentFileProxyApi
import dev.flutter.packages.cross_file_android.proxies.InputStreamProxyApi
import dev.flutter.packages.cross_file_android.proxies.InputStreamReadBytesResponseProxyApi

/**
 * Implementation of [InteractiveMediaAdsLibraryPigeonProxyApiRegistrar] that provides each ProxyApi
 * implementation and any additional resources needed by an implementation.
 */
open class ProxyApiRegistrar(binaryMessenger: BinaryMessenger, var context: Context) :
  DocumentFilePigeonProxyApiRegistrar(binaryMessenger) {

  // Added to be overriden for tests. The test implementation calls `callback` immediately, instead
  // of waiting for the main thread to run it.
  internal open fun runOnMainThread(callback: Runnable) {
    Handler(Looper.getMainLooper()).post { callback.run() }
  }

  // Interface for an injectable SDK version checker.
  @ChecksSdkIntAtLeast(parameter = 0)
  open fun sdkIsAtLeast(version: Int): Boolean {
    return Build.VERSION.SDK_INT >= version
  }

  override fun getPigeonApiDocumentFile(): PigeonApiDocumentFile {
    return DocumentFileProxyApi(this)
  }

  override fun getPigeonApiContentResolver(): PigeonApiContentResolver {
    return ContentResolverProxyApi(this)
  }

  override fun getPigeonApiInputStreamReadBytesResponse(): PigeonApiInputStreamReadBytesResponse {
    return InputStreamReadBytesResponseProxyApi(this)
  }

  override fun getPigeonApiInputStream(): PigeonApiInputStream {
    return InputStreamProxyApi(this)
  }
}