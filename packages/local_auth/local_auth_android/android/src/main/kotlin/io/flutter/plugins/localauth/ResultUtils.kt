// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.localauth

fun <T> completeWithError(callback: (Result<@JvmSuppressWildcards T>) -> Unit, failure: Throwable) {
  callback(Result.failure(failure))
}

fun <T> completeWithValue(callback: (Result<@JvmSuppressWildcards T>) -> Unit, value: T) {
  callback(Result.success(value))
}
