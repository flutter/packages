// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
    group('succeeds', () {
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

        assertThatImageLoadingSucceeds(subject);
      });

      test('loads image from network with an extra header', () async {
        final NetworkImageWithRetry subject = NetworkImageWithRetry(
          _imageUrl('extra_header.png'),
          headers: const <String, Object>{'ExtraHeader': 'special'},
        );

        assertThatImageLoadingSucceeds(subject);
      });

      test('succeeds on successful retry', () async {
        final NetworkImageWithRetry subject = NetworkImageWithRetry(
          _imageUrl('error.png'),
          fetchStrategy: (Uri uri, FetchFailure? failure) async {
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
        assertThatImageLoadingSucceeds(subject);
      });
    });

    group('fails', () {
      final List<FlutterErrorDetails> errorLog = <FlutterErrorDetails>[];
      FakeAsync fakeAsync = FakeAsync();

      setUp(() {
        FlutterError.onError = errorLog.add;
      });

      tearDown(() {
        fakeAsync = FakeAsync();
        errorLog.clear();
        FlutterError.onError = FlutterError.dumpErrorToConsole;
      });

      test('retries 6 times then gives up', () async {
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
          fetchStrategy: (Uri uri, FetchFailure? failure) {
            Timer.run(onAttempt);
            return fakeAsync.run((FakeAsync fakeAsync) {
              return NetworkImageWithRetry.defaultFetchStrategy(uri, failure);
            });
          },
        );

        assertThatImageLoadingFails(subject, errorLog);
      });

      test('gives up immediately on non-retriable errors (HTTP 404)', () async {
        int attemptCount = 0;
        Future<void> onAttempt() async {
          expect(attemptCount, lessThan(2));
          await Future<void>.delayed(Duration.zero);
          fakeAsync.elapse(const Duration(seconds: 60));
          attemptCount++;
        }

        final NetworkImageWithRetry subject = NetworkImageWithRetry(
          _imageUrl('does_not_exist.png'),
          fetchStrategy: (Uri uri, FetchFailure? failure) {
            Timer.run(onAttempt);
            return fakeAsync.run((FakeAsync fakeAsync) {
              return NetworkImageWithRetry.defaultFetchStrategy(uri, failure);
            });
          },
        );

        assertThatImageLoadingFails(subject, errorLog);
      });
    });
  });
}

void assertThatImageLoadingFails(
  NetworkImageWithRetry subject,
  List<FlutterErrorDetails> errorLog,
) {
  final ImageStreamCompleter completer = subject.load(
    subject,
    _ambiguate(PaintingBinding.instance)!.instantiateImageCodec,
  );
  completer.addListener(ImageStreamListener(
    (ImageInfo image, bool synchronousCall) {},
    onError: expectAsync2((Object error, StackTrace? _) {
      expect(errorLog.single.exception, isInstanceOf<FetchFailure>());
      expect(error, isInstanceOf<FetchFailure>());
      expect(error, equals(errorLog.single.exception));
    }),
  ));
}

void assertThatImageLoadingSucceeds(
  NetworkImageWithRetry subject,
) {
  final ImageStreamCompleter completer = subject.load(
    subject,
    _ambiguate(PaintingBinding.instance)!.instantiateImageCodec,
  );
  completer.addListener(ImageStreamListener(
    expectAsync2((ImageInfo image, bool synchronousCall) {
      expect(image.image.height, 1);
      expect(image.image.width, 1);
    }),
  ));
}

/// This allows a value of type T or T? to be treated as a value of type T?.
///
/// We use this so that APIs that have become non-nullable can still be used
/// with `!` and `?` on the stable branch.
// TODO(ianh): Remove this once the relevant APIs have shipped to stable.
// See https://github.com/flutter/flutter/issues/64830
T? _ambiguate<T>(T? value) => value;
