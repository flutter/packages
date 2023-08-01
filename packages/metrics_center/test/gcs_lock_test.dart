// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:gcloud/storage.dart';
import 'package:googleapis/storage/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:metrics_center/src/constants.dart';
import 'package:metrics_center/src/gcs_lock.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'common.dart';
import 'gcs_lock_test.mocks.dart';
import 'utility.dart';

enum TestPhase {
  run1,
  run2,
}

@GenerateMocks(<Type>[
  AuthClient,
  StorageApi
], customMocks: <MockSpec<dynamic>>[
  MockSpec<ObjectsResource>(onMissingStub: OnMissingStub.returnDefault)
])
void main() {
  const Duration kDelayStep = Duration(milliseconds: 10);
  final Map<String, dynamic>? credentialsJson = getTestGcpCredentialsJson();

  test('GcsLock prints warnings for long waits', () {
    // Capture print to verify error messages.
    final List<String> prints = <String>[];
    final ZoneSpecification spec =
        ZoneSpecification(print: (_, __, ___, String msg) => prints.add(msg));

    Zone.current.fork(specification: spec).run<void>(() {
      fakeAsync((FakeAsync fakeAsync) {
        final MockAuthClient mockClient = MockAuthClient();
        final GcsLock lock = GcsLock(StorageApi(mockClient), 'mockBucket');
        when(mockClient.send(any)).thenThrow(DetailedApiRequestError(412, ''));
        final Future<void> runFinished =
            lock.protectedRun('mock.lock', () async {});
        fakeAsync.elapse(const Duration(seconds: 10));
        when(mockClient.send(any)).thenThrow(AssertionError('Stop!'));
        runFinished.catchError((dynamic e) {
          final AssertionError error = e as AssertionError;
          expect(error.message, 'Stop!');
          // TODO(goderbauer): We should not be printing from a test.
          // ignore: avoid_print
          print('${error.message}');
        });
        fakeAsync.elapse(const Duration(seconds: 20));
      });
    });

    const String kExpectedErrorMessage = 'The lock is waiting for a long time: '
        '0:00:10.240000. If the lock file mock.lock in bucket mockBucket '
        'seems to be stuck (i.e., it was created a long time ago and no one '
        'seems to be owning it currently), delete it manually to unblock this.';
    expect(prints, equals(<String>[kExpectedErrorMessage, 'Stop!']));
  });

  test('GcsLock integration test: single protectedRun is successful', () async {
    final AutoRefreshingAuthClient client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(credentialsJson), Storage.SCOPES);
    final GcsLock lock = GcsLock(StorageApi(client), kTestBucketName);
    int testValue = 0;
    await lock.protectedRun('test.lock', () async {
      testValue = 1;
    });
    expect(testValue, 1);
  }, skip: credentialsJson == null);

  test('GcsLock integration test: protectedRun is exclusive', () async {
    final AutoRefreshingAuthClient client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(credentialsJson), Storage.SCOPES);
    final GcsLock lock1 = GcsLock(StorageApi(client), kTestBucketName);
    final GcsLock lock2 = GcsLock(StorageApi(client), kTestBucketName);

    TestPhase phase = TestPhase.run1;
    final Completer<void> started1 = Completer<void>();
    final Future<void> finished1 = lock1.protectedRun('test.lock', () async {
      started1.complete();
      while (phase == TestPhase.run1) {
        await Future<void>.delayed(kDelayStep);
      }
    });

    await started1.future;

    final Completer<void> started2 = Completer<void>();
    final Future<void> finished2 = lock2.protectedRun('test.lock', () async {
      started2.complete();
    });

    // started2 should not be set even after a long wait because lock1 is
    // holding the GCS lock file.
    await Future<void>.delayed(kDelayStep * 10);
    expect(started2.isCompleted, false);

    // When phase is switched to run2, lock1 should be released soon and
    // lock2 should soon be able to proceed its protectedRun.
    phase = TestPhase.run2;
    await started2.future;
    await finished1;
    await finished2;
  }, skip: credentialsJson == null);

  test('GcsLock attempts to unlock again on a DetailedApiRequestError',
      () async {
    fakeAsync((FakeAsync fakeAsync) {
      final StorageApi mockStorageApi = MockStorageApi();
      final ObjectsResource mockObjectsResource = MockObjectsResource();
      final GcsLock gcsLock = GcsLock(mockStorageApi, kTestBucketName);
      const String lockFileName = 'test.lock';
      when(mockStorageApi.objects).thenReturn(mockObjectsResource);

      // Simulate a failure to delete a lock file.
      when(mockObjectsResource.delete(kTestBucketName, lockFileName))
          .thenThrow(DetailedApiRequestError(504, ''));

      gcsLock.protectedRun(lockFileName, () async {});

      // Allow time to pass by to ensure deleting the lock file is retried multiple times.
      fakeAsync.elapse(const Duration(milliseconds: 30));
      verify(mockObjectsResource.delete(kTestBucketName, lockFileName))
          .called(3);

      // Simulate a successful deletion of the lock file.
      when(mockObjectsResource.delete(kTestBucketName, lockFileName))
          .thenAnswer((_) => Future<void>(
                () {
                  return;
                },
              ));

      // At this point, there should only be one more (successful) attempt to delete the lock file.
      fakeAsync.elapse(const Duration(minutes: 2));
      verify(mockObjectsResource.delete(kTestBucketName, lockFileName))
          .called(1);
    });
  });
}
