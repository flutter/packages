// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlesignin

fun completeWithUnitSuccess(callback: (Result<Unit>) -> Unit) {
  callback(Result.success(Unit))
}

fun completeWithUnitError(callback: (Result<Unit>) -> Unit, failure: FlutterError) {
  callback(Result.failure(failure))
}

fun <T> completeWithValue(callback: (Result<T>) -> Unit, value: T) {
  callback(Result.success(value))
}
