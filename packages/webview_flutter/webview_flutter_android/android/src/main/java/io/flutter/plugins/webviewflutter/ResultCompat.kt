// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter

/**
 * ResultCompat.
 *
 * It is intended to solve the problem of being unable to obtain [kotlin.Result] in Java.
 *
 * [kotlin.Result] has a weird quirk when it is passed to Java where it seems to wrap itself.
 */
@Suppress("UNCHECKED_CAST")
class ResultCompat<T>(val result: Result<T>) {
  private val value: T? = result.getOrNull()
  private val exception = result.exceptionOrNull()
  val isSuccess = result.isSuccess
  val isFailure = result.isFailure

  companion object {
    @JvmStatic
    fun <T> success(value: T, callback: Any) {
      val castedCallback: (Result<T>) -> Unit = callback as (Result<T>) -> Unit
      castedCallback(Result.success(value))
    }

    @JvmStatic
    fun <T> asCompatCallback(result: (ResultCompat<T>) -> Unit): (Result<T>) -> Unit {
      return { result(ResultCompat(it)) }
    }
  }

  fun getOrNull(): T? {
    return value
  }

  fun exceptionOrNull(): Throwable? {
    return exception
  }
}
