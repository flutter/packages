// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlesignin

/** Wraps Kotlin Result for use in Java unit tests. */
@Suppress("UNCHECKED_CAST")
class ResultCompat<T>(private val result: Result<T>) {
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
