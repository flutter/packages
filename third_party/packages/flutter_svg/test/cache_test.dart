import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_svg/src/cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Sanity', () async {
    final cache = Cache();
    expect(cache.maximumSize, 100);
    expect(cache.count, 0);
    final completer = Completer<ByteData>();
    final Future<ByteData> put = cache.putIfAbsent(1, () => completer.future);
    expect(put, completer.future);
    expect(cache.count, 0);
    completer.complete(ByteData(1));
    expect(cache.count, 0);
    await null;
    expect(cache.count, 1);
    cache.clear();
    expect(cache.count, 0);
    // Not bothering to check result since it's from the same completer.
    unawaited(cache.putIfAbsent(1, () => completer.future));
    expect(cache.count, 0);
    await null;
    expect(cache.count, 1);
    expect(cache.evict(1), true);
    expect(cache.count, 0);
    expect(cache.evict(1), false);
  });

  test('LRU', () async {
    final cache = Cache();
    cache.maximumSize = 2;
    final completerA = Completer<ByteData>()..complete(ByteData(1));
    final completerB = Completer<ByteData>()..complete(ByteData(2));
    final completerC = Completer<ByteData>()..complete(ByteData(3));

    expect(cache.count, 0);

    await cache.putIfAbsent(1, () => completerA.future);
    expect(cache.count, 1);

    await cache.putIfAbsent(2, () => completerB.future);
    expect(cache.count, 2);

    await cache.putIfAbsent(3, () => completerC.future);
    expect(cache.count, 2);

    expect(cache.evict(1), false);
    expect(cache.evict(2), true);
    expect(cache.evict(3), true);

    await cache.putIfAbsent(1, () => completerA.future);
    expect(cache.count, 1);

    await cache.putIfAbsent(2, () => completerB.future);
    expect(cache.count, 2);

    await cache.putIfAbsent(1, () => completerA.future);
    expect(cache.count, 2);

    await cache.putIfAbsent(3, () => completerC.future);
    expect(cache.count, 2);

    expect(cache.evict(1), true);
    expect(cache.evict(2), false);
    expect(cache.evict(3), true);
  });

  test('Adding beyond max with synchronous futures', () async {
    final cache = Cache();
    cache.maximumSize = 2;
    final Future<ByteData> completerA = SynchronousFuture<ByteData>(ByteData(1));
    final Future<ByteData> completerB = SynchronousFuture<ByteData>(ByteData(2));
    final Future<ByteData> completerC = SynchronousFuture<ByteData>(ByteData(3));

    expect(cache.count, 0);

    unawaited(cache.putIfAbsent(1, () => completerA));
    expect(cache.count, 1);

    unawaited(cache.putIfAbsent(2, () => completerB));
    expect(cache.count, 2);

    unawaited(cache.putIfAbsent(2, () => completerB));
    expect(cache.count, 2);

    unawaited(cache.putIfAbsent(3, () => completerC));
    expect(cache.count, 2);

    unawaited(cache.putIfAbsent(2, () => completerB));
    expect(cache.count, 2);
  });

  test('Futures completing late/together', () async {
    final cache = Cache();
    cache.maximumSize = 2;
    final completerA = Completer<ByteData>();
    final completerB = Completer<ByteData>();
    final completerC = Completer<ByteData>();

    expect(cache.count, 0);

    unawaited(cache.putIfAbsent(1, () => completerA.future));
    unawaited(cache.putIfAbsent(2, () => completerB.future));
    completerA.complete(ByteData(1));
    completerB.complete(ByteData(1));

    expect(cache.count, 0);
    await null;
    expect(cache.count, 2);

    unawaited(cache.putIfAbsent(3, () => completerC.future));
    expect(cache.count, 2);

    completerC.complete(ByteData(1));
    expect(cache.count, 2);

    await null;
    expect(cache.count, 2);
  });

  test('Failed async load does not poison pending cache or leak uncaught zone errors', () async {
    final cache = Cache();
    final uncaughtErrors = <Object>[];
    var loaderCalls = 0;

    await runZonedGuarded(
      () async {
        final failingCompleter = Completer<ByteData>();
        final Future<ByteData> first = cache.putIfAbsent(1, () {
          loaderCalls++;
          return failingCompleter.future;
        });
        final Future<ByteData> concurrent = cache.putIfAbsent(1, () {
          loaderCalls++;
          return Completer<ByteData>().future;
        });

        expect(loaderCalls, 1);
        expect(concurrent, same(first));

        final Future<void> firstExpectation = expectLater(first, throwsA(isA<StateError>()));
        final Future<void> concurrentExpectation = expectLater(
          concurrent,
          throwsA(isA<StateError>()),
        );
        failingCompleter.completeError(StateError('transient HTTP failure'));
        await firstExpectation;
        await concurrentExpectation;
        await Future<void>.delayed(Duration.zero);

        expect(cache.count, 0);

        final expected = ByteData(4);
        final ByteData recovered = await cache.putIfAbsent(1, () {
          loaderCalls++;
          return SynchronousFuture<ByteData>(expected);
        });
        expect(loaderCalls, 2);
        expect(recovered, same(expected));
        expect(cache.count, 1);
      },
      (Object error, StackTrace stackTrace) {
        uncaughtErrors.add(error);
      },
    );

    expect(uncaughtErrors, isEmpty);
  });

  test('clear prevents pending loads from repopulating stale entries', () async {
    final cache = Cache();
    final oldLoad = Completer<ByteData>();
    final Future<ByteData> oldFuture = cache.putIfAbsent('icon', () => oldLoad.future);

    cache.clear();

    final replacement = ByteData(3);
    expect(
      identical(
        await cache.putIfAbsent('icon', () => Future<ByteData>.value(replacement)),
        replacement,
      ),
      isTrue,
    );

    oldLoad.complete(ByteData(1));
    await oldFuture;
    expect(cache.count, 1);

    final ByteData cached = await cache.putIfAbsent(
      'icon',
      () => throw StateError('stale load replaced the cache'),
    );
    expect(identical(cached, replacement), isTrue);
  });

  test('evict invalidates in-flight loads as well as completed loads', () async {
    final cache = Cache();
    final oldLoad = Completer<ByteData>();
    final Future<ByteData> oldFuture = cache.putIfAbsent('icon', () => oldLoad.future);

    expect(cache.evict('icon'), isTrue);
    expect(cache.evict('icon'), isFalse);
    oldLoad.complete(ByteData(1));
    await oldFuture;
    expect(cache.count, 0);

    final fresh = ByteData(2);
    await cache.putIfAbsent('icon', () => Future<ByteData>.value(fresh));
    expect(cache.count, 1);
    expect(cache.evict('icon'), isTrue);
    expect(cache.count, 0);
  });

  test('an evicted request cannot cache a Future reused by a later request', () async {
    final cache = Cache();
    final shared = Completer<ByteData>();
    final Future<ByteData> first = cache.putIfAbsent('icon', () => shared.future);
    expect(cache.evict('icon'), isTrue);

    final Future<int> countBetweenCallbacks = shared.future.then((_) => cache.count);
    final Future<ByteData> second = cache.putIfAbsent('icon', () => shared.future);

    final data = ByteData(1);
    shared.complete(data);
    expect(await first, same(data));
    expect(await countBetweenCallbacks, 0);
    expect(await second, same(data));
    expect(cache.count, 1);
  });

  test('an invalidated failure leaves the replacement pending load intact', () async {
    final cache = Cache();
    final obsolete = Completer<ByteData>();
    final current = Completer<ByteData>();
    final Future<ByteData> oldFuture = cache.putIfAbsent('icon', () => obsolete.future);
    final Future<void> expectedFailure = expectLater(oldFuture, throwsStateError);
    cache.evict('icon');
    final Future<ByteData> currentFuture = cache.putIfAbsent('icon', () => current.future);

    obsolete.completeError(StateError('obsolete request failed'));
    await expectedFailure;
    expect(
      identical(currentFuture, cache.putIfAbsent('icon', () => throw StateError('duplicate'))),
      isTrue,
    );

    final fresh = ByteData(2);
    current.complete(fresh);
    await currentFuture;
    expect(await cache.putIfAbsent('icon', () => throw StateError('missing cache')), same(fresh));
  });

  test('disabling and restoring cache invalidates requests from before disabling', () async {
    final cache = Cache();
    final obsolete = Completer<ByteData>();
    final Future<ByteData> oldFuture = cache.putIfAbsent('icon', () => obsolete.future);
    cache.maximumSize = 0;
    cache.maximumSize = 100;

    obsolete.complete(ByteData(1));
    await oldFuture;
    expect(cache.count, 0);

    final fresh = ByteData(2);
    expect(await cache.putIfAbsent('icon', () => SynchronousFuture<ByteData>(fresh)), same(fresh));
    expect(cache.count, 1);
  });
}
