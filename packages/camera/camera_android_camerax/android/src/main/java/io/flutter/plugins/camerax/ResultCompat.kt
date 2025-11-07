// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax

/**
 * Provides Java compatible helper functions for the [kotlin.Result] class.
 *
 * The Kotlin Result class in used in the pigeon generated Kotlin code and there is no equivalent
 * class in Java. The Result class can have weird behavior when passed to Java (e.g. it has a weird
 * quirk where it seems to wrap itself).
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
    fun <T> failure(exception: Throwable, callback: Any) {
      val castedCallback: (Result<T>) -> Unit = callback as (Result<T>) -> Unit
      castedCallback(Result.failure(exception))
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
