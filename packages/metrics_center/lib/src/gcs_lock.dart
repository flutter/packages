// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'package:googleapis/storage/v1.dart';

/// Global (in terms of earth) mutex using Google Cloud Storage.
class GcsLock {
  /// Create a lock with an authenticated client and a GCS bucket name.
  ///
  /// The client is used to communicate with Google Cloud Storage APIs.
  GcsLock(this._api, this._bucketName);

  /// Create a temporary lock file in GCS, and use it as a mutex mechanism to
  /// run a piece of code exclusively.
  ///
  /// There must be no existing lock file with the same name in order to
  /// proceed. If multiple [GcsLock]s with the same `bucketName` and
  /// `lockFileName` try [protectedRun] simultaneously, only one will proceed
  /// and create the lock file. All others will be blocked.
  ///
  /// When [protectedRun] finishes, the lock file is deleted, and other blocked
  /// [protectedRun] may proceed.
  ///
  /// If the lock file is stuck (e.g., `_unlock` is interrupted unexpectedly),
  /// one may need to manually delete the lock file from GCS to unblock any
  /// [protectedRun] that may depend on it.
  Future<void> protectedRun(
      String lockFileName, Future<void> Function() f) async {
    await _lock(lockFileName);
    try {
      await f();
    } catch (e, stacktrace) {
      print(stacktrace);
      rethrow;
    } finally {
      await _unlock(lockFileName);
    }
  }

  Future<void> _lock(String lockFileName) async {
    final Object object = Object();
    object.bucket = _bucketName;
    object.name = lockFileName;
    final Media content = Media(const Stream<List<int>>.empty(), 0);

    Duration waitPeriod = const Duration(milliseconds: 10);
    bool locked = false;
    while (!locked) {
      try {
        await _api.objects.insert(object, _bucketName,
            ifGenerationMatch: '0', uploadMedia: content);
        locked = true;
      } on DetailedApiRequestError catch (e) {
        if (e.status == 412) {
          // Status 412 means that the lock file already exists. Wait until
          // that lock file is deleted.
          await Future<void>.delayed(waitPeriod);
          waitPeriod *= 2;
          if (waitPeriod >= _kWarningThreshold) {
            print(
              'The lock is waiting for a long time: $waitPeriod. '
              'If the lock file $lockFileName in bucket $_bucketName '
              'seems to be stuck (i.e., it was created a long time ago and '
              'no one seems to be owning it currently), delete it manually '
              'to unblock this.',
            );
          }
        } else {
          rethrow;
        }
      }
    }
  }

  Future<void> _unlock(String lockFileName) async {
    Duration waitPeriod = const Duration(milliseconds: 10);
    bool unlocked = false;
    // Retry in the case of GCS returning an API error, but rethrow if unable
    // to unlock after a certain period of time.
    while (!unlocked) {
      try {
        await _api.objects.delete(_bucketName, lockFileName);
        unlocked = true;
      } on DetailedApiRequestError {
        if (waitPeriod < _unlockThreshold) {
          await Future<void>.delayed(waitPeriod);
          waitPeriod *= 2;
        } else {
          rethrow;
        }
      }
    }
  }

  final String _bucketName;
  final StorageApi _api;

  static const Duration _kWarningThreshold = Duration(seconds: 10);
  static const Duration _unlockThreshold = Duration(minutes: 1);
}
