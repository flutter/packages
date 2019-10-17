// Copyright (c) 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io' show HttpOverrides;
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_image/network.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiver/testing/async.dart';

String _imageUrl(String fileName) {
  return 'http://localhost:11111/$fileName';
}

void main() {
  AutomatedTestWidgetsFlutterBinding();
  HttpOverrides.global = null;

  group('NetworkImageWithRetry', () {
    setUp(() {
      FlutterError.onError = (FlutterErrorDetails error) {
        fail('$error');
      };
    });

    tearDown(() {
      FlutterError.onError = FlutterError.dumpErrorToConsole;
    });

    test('loads image from network', () async {
      final NetworkImageWithRetry subject = NetworkImageWithRetry(
        _imageUrl('immediate_success.png'),
      );

      subject.load(subject, PaintingBinding.instance.instantiateImageCodec).addListener(
        ImageStreamListener(expectAsync2((ImageInfo image, bool synchronousCall) {
          expect(image.image.height, 1);
          expect(image.image.width, 1);
        })),
      );
    });

    test('retries 6 times then gives up', () async {
      final List<FlutterErrorDetails> errorLog = <FlutterErrorDetails>[];
      FlutterError.onError = errorLog.add;

      final FakeAsync fakeAsync = FakeAsync();
      final dynamic maxAttemptCountReached = expectAsync0(() {});

      int attemptCount = 0;
      Future<void> onAttempt() async {
        expect(attemptCount, lessThan(7));
        if (attemptCount == 6) {
          maxAttemptCountReached();
        }
        await Future<void>.delayed(Duration.zero);
        fakeAsync.elapse(const Duration(seconds: 60));
        attemptCount++;
      }

      final NetworkImageWithRetry subject = NetworkImageWithRetry(
        _imageUrl('error.png'),
        fetchStrategy: (Uri uri, FetchFailure failure) {
          Timer.run(onAttempt);
          return fakeAsync.run((FakeAsync fakeAsync) {
            return NetworkImageWithRetry.defaultFetchStrategy(uri, failure);
          });
        },
      );

      subject.load(subject, PaintingBinding.instance.instantiateImageCodec).addListener(
        ImageStreamListener(expectAsync2((ImageInfo image, bool synchronousCall) {
          expect(errorLog.single.exception, isInstanceOf<FetchFailure>());
          expect(image, null);
        })),
      );
    });

    test('gives up immediately on non-retriable errors (HTTP 404)', () async {
      final List<FlutterErrorDetails> errorLog = <FlutterErrorDetails>[];
      FlutterError.onError = errorLog.add;

      final FakeAsync fakeAsync = FakeAsync();

      int attemptCount = 0;
      Future<void> onAttempt() async {
        expect(attemptCount, lessThan(2));
        await Future<void>.delayed(Duration.zero);
        fakeAsync.elapse(const Duration(seconds: 60));
        attemptCount++;
      }

      final NetworkImageWithRetry subject = NetworkImageWithRetry(
        _imageUrl('does_not_exist.png'),
        fetchStrategy: (Uri uri, FetchFailure failure) {
          Timer.run(onAttempt);
          return fakeAsync.run((FakeAsync fakeAsync) {
            return NetworkImageWithRetry.defaultFetchStrategy(uri, failure);
          });
        },
      );

      subject.load(subject, PaintingBinding.instance.instantiateImageCodec).addListener(
        ImageStreamListener(expectAsync2((ImageInfo image, bool synchronousCall) {
          expect(errorLog.single.exception, isInstanceOf<FetchFailure>());
          expect(image, null);
        })),
      );
    });

    test('succeeds on successful retry', () async {
      final NetworkImageWithRetry subject = NetworkImageWithRetry(
        _imageUrl('error.png'),
        fetchStrategy: (Uri uri, FetchFailure failure) async {
          if (failure == null) {
            return FetchInstructions.attempt(
              uri: uri,
              timeout: const Duration(minutes: 1),
            );
          } else {
            expect(failure.attemptCount, lessThan(2));
            return FetchInstructions.attempt(
              uri: Uri.parse(_imageUrl('immediate_success.png')),
              timeout: const Duration(minutes: 1),
            );
          }
        },
      );

      subject.load(subject, PaintingBinding.instance.instantiateImageCodec).addListener(
        ImageStreamListener(expectAsync2((ImageInfo image, bool synchronousCall) {
          expect(image.image.height, 1);
          expect(image.image.width, 1);
        })),
      );
    });
  });
}
