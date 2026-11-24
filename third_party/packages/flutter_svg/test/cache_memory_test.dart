import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pending decodes use the current budget when completing out of order', () async {
    final cache = Cache()..maximumByteSize = 10;
    final first = Completer<ByteData>();
    final second = Completer<ByteData>();
    final Future<ByteData> firstLoad = cache.putIfAbsent('first', () => first.future);
    final Future<ByteData> secondLoad = cache.putIfAbsent('second', () => second.future);

    cache.maximumByteSize = 5;
    second.complete(ByteData(3));
    await secondLoad;
    first.complete(ByteData(4));
    await firstLoad;

    expect(cache.count, 1);
    expect(cache.currentByteSize, 4);
    expect(cache.evict('second'), isFalse);
    cache.clear();
    expect(cache.currentByteSize, 0);
  });

  test('disabling then enabling the budget keeps an earlier load invalidated', () async {
    final cache = Cache();
    final old = Completer<ByteData>();
    final Future<ByteData> oldLoad = cache.putIfAbsent('icon', () => old.future);

    cache.maximumByteSize = 0;
    cache.maximumByteSize = 10;
    final fresh = ByteData(2);
    await cache.putIfAbsent('icon', () => SynchronousFuture<ByteData>(fresh));
    old.complete(ByteData(9));
    await oldLoad;

    expect(cache.currentByteSize, 2);
    expect(
      await cache.putIfAbsent('icon', () => throw StateError('unexpected reload')),
      same(fresh),
    );
  });

  test('oversized decodes leave existing entries and byte accounting intact', () async {
    final cache = Cache()..maximumByteSize = 3;
    final small = ByteData(3);
    await cache.putIfAbsent('small', () => SynchronousFuture<ByteData>(small));
    await cache.putIfAbsent('huge', () => SynchronousFuture<ByteData>(ByteData(4)));

    expect(cache.count, 1);
    expect(cache.currentByteSize, 3);
    expect(
      await cache.putIfAbsent('small', () => throw StateError('unexpected reload')),
      same(small),
    );
  });

  test('the byte budget evicts least-recently-used entries', () async {
    final cache = Cache()..maximumByteSize = 5;
    final a = ByteData(3);
    final b = ByteData(2);
    final c = ByteData(2);

    await cache.putIfAbsent('a', () => SynchronousFuture<ByteData>(a));
    await cache.putIfAbsent('b', () => SynchronousFuture<ByteData>(b));
    expect(cache.count, 2);
    expect(cache.currentByteSize, 5);

    await cache.putIfAbsent('a', () => throw StateError('unexpected reload'));
    await cache.putIfAbsent('c', () => SynchronousFuture<ByteData>(c));

    expect(cache.count, 2);
    expect(cache.currentByteSize, 5);
    expect(cache.evict('b'), isFalse);
    expect(cache.evict('a'), isTrue);
    expect(cache.currentByteSize, 2);
    expect(cache.evict('c'), isTrue);
    expect(cache.currentByteSize, 0);
  });

  test('shrinking count and byte limits evicts immediately', () async {
    final cache = Cache();
    await cache.putIfAbsent('a', () => SynchronousFuture<ByteData>(ByteData(3)));
    await cache.putIfAbsent('b', () => SynchronousFuture<ByteData>(ByteData(2)));

    expect(cache.currentByteSize, 5);
    cache.maximumSize = 1;
    expect(cache.count, 1);
    expect(cache.currentByteSize, 2);

    cache.maximumByteSize = 1;
    expect(cache.count, 0);
    expect(cache.currentByteSize, 0);
  });

  test('oversized entries render but are not stored or retained', () async {
    final cache = Cache()..maximumByteSize = 3;
    final huge = ByteData(4);
    var loads = 0;

    Future<ByteData> load() {
      loads++;
      return SynchronousFuture<ByteData>(huge);
    }

    expect(identical(await cache.putIfAbsent('huge', load), huge), isTrue);
    expect(identical(await cache.putIfAbsent('huge', load), huge), isTrue);
    expect(loads, 2);
    expect(cache.count, 0);
    expect(cache.currentByteSize, 0);
  });

  test('a zero-byte budget disables caching and invalidates pending data', () async {
    final cache = Cache();
    final pending = Completer<ByteData>();
    final Future<ByteData> oldLoad = cache.putIfAbsent('old', () => pending.future);

    cache.maximumByteSize = 0;
    pending.complete(ByteData(5));
    await oldLoad;
    await cache.putIfAbsent('zero', () => SynchronousFuture<ByteData>(ByteData(0)));

    expect(cache.count, 0);
    expect(cache.currentByteSize, 0);
    cache.maximumByteSize = 32 * 1024 * 1024;
    expect(cache.maximumByteSize, 32 * 1024 * 1024);
  });
}
