// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlesignin

fun completeWithGetGetCredentialResult(
    callback: (Result<GetCredentialResult>) -> Unit,
    result: GetCredentialResult
) {
  callback(Result.success(result))
}

fun completeWithGetCredentialFailure(
    callback: (Result<GetCredentialFailure>) -> Unit,
    failure: GetCredentialFailure
) {
  callback(Result.success(failure))
}

fun completeWithUnitSuccess(callback: (Result<Unit>) -> Unit) {
  callback(Result.success(Unit))
}

fun completeWithUnitError(callback: (Result<Unit>) -> Unit, failure: FlutterError) {
  callback(Result.failure(failure))
}

fun completeWithAuthorizationResult(
    callback: (Result<AuthorizeResult>) -> Unit,
    result: PlatformAuthorizationResult
) {
  callback(Result.success(result))
}

fun completeWithAuthorizeFailure(
    callback: (Result<AuthorizeResult>) -> Unit,
    failure: AuthorizeFailure
) {
  callback(Result.success(failure))
}
