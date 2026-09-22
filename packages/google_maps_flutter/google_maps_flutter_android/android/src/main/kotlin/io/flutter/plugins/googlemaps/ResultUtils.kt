// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps

import kotlin.coroutines.Continuation
import kotlin.coroutines.CoroutineContext
import kotlin.coroutines.EmptyCoroutineContext
import kotlin.coroutines.intrinsics.COROUTINE_SUSPENDED
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

fun <T> resumeWithValue(continuation: Continuation<T>, value: T) {
  continuation.resume(value)
}

fun resumeWithUnitSuccess(continuation: Continuation<Unit>) {
  continuation.resume(Unit)
}

fun resumeWithException(continuation: Continuation<*>, exception: Throwable) {
  @Suppress("UNCHECKED_CAST") (continuation as Continuation<Any?>).resumeWithException(exception)
}

fun coroutineSuspended(): Any = COROUTINE_SUSPENDED

private val noopContinuation =
    object : Continuation<Any?> {
      override val context: CoroutineContext = EmptyCoroutineContext

      override fun resumeWith(result: Result<Any?>) {}
    }

@Suppress("UNCHECKED_CAST")
fun <T> emptyContinuation(): Continuation<T> = noopContinuation as Continuation<T>

@Suppress("UNCHECKED_CAST")
class ResultCompat<T>(private val result: Result<T>) {
  private val value: T? = result.getOrNull()
  private val exception = result.exceptionOrNull()

  companion object {
    @JvmStatic
    fun <T> asContinuation(result: (ResultCompat<T>) -> Unit): Continuation<T> {
      return object : Continuation<T> {
        override val context: CoroutineContext = EmptyCoroutineContext

        override fun resumeWith(result: Result<T>) {
          result(ResultCompat(result))
        }
      }
    }
  }

  fun getOrNull(): T? {
    return value
  }

  fun exceptionOrNull(): Throwable? {
    return exception
  }
}
