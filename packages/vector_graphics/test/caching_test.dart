// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/vector_graphics.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';

const VectorGraphicsCodec codec = VectorGraphicsCodec();

void main() {
  setUp(() {
    imageCache.clear();
    imageCache.clearLiveImages();
  });

  testWidgets(
    'Does not reload identical bytes when forced to re-create state object',
    (WidgetTester tester) async {
      final testBundle = TestAssetBundle();
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        DefaultAssetBundle(
          key: UniqueKey(),
          bundle: testBundle,
          child: VectorGraphic(
            key: key,
            loader: const AssetBytesLoader('foo.svg'),
          ),
        ),
      );

      expect(testBundle.loadKeys.single, 'foo.svg');

      await tester.pumpWidget(
        DefaultAssetBundle(
          key: UniqueKey(),
          bundle: testBundle,
          child: VectorGraphic(
            key: key,
            loader: const AssetBytesLoader('foo.svg'),
          ),
        ),
      );

      expect(testBundle.loadKeys, <String>['foo.svg']);
    },
  );

  testWidgets('Only loads bytes once for a repeated vg', (
    WidgetTester tester,
  ) async {
    final testBundle = TestAssetBundle();

    await tester.pumpWidget(
      DefaultAssetBundle(
        key: UniqueKey(),
        bundle: testBundle,
        child: Column(
          children: <Widget>[
            VectorGraphic(
              key: GlobalKey(),
              loader: const AssetBytesLoader('foo.svg'),
            ),
            VectorGraphic(
              key: GlobalKey(),
              loader: const AssetBytesLoader('foo.svg'),
            ),
            VectorGraphic(
              key: GlobalKey(),
              loader: const AssetBytesLoader('foo.svg'),
            ),
          ],
        ),
      ),
    );

    expect(testBundle.loadKeys.single, 'foo.svg');

    await tester.pumpWidget(const SizedBox());

    await tester.pumpWidget(
      DefaultAssetBundle(
        key: UniqueKey(),
        bundle: testBundle,
        child: Column(
          children: <Widget>[
            VectorGraphic(
              key: GlobalKey(),
              loader: const AssetBytesLoader('foo.svg'),
            ),
            VectorGraphic(
              key: GlobalKey(),
              loader: const AssetBytesLoader('foo.svg'),
            ),
            VectorGraphic(
              key: GlobalKey(),
              loader: const AssetBytesLoader('foo.svg'),
            ),
          ],
        ),
      ),
    );

    expect(testBundle.loadKeys, <String>['foo.svg', 'foo.svg']);
  });

  testWidgets('Does not cache bytes that come from different asset bundles', (
    WidgetTester tester,
  ) async {
    final testBundleA = TestAssetBundle();
    final testBundleB = TestAssetBundle();
    final GlobalKey key = GlobalKey();

    await tester.pumpWidget(
      DefaultAssetBundle(
        key: UniqueKey(),
        bundle: testBundleA,
        child: VectorGraphic(
          key: key,
          loader: const AssetBytesLoader('foo.svg'),
        ),
      ),
    );

    expect(testBundleA.loadKeys.single, 'foo.svg');
    expect(testBundleB.loadKeys, isEmpty);

    await tester.pumpWidget(
      DefaultAssetBundle(
        key: UniqueKey(),
        bundle: testBundleB,
        child: VectorGraphic(
          key: key,
          loader: const AssetBytesLoader('foo.svg'),
        ),
      ),
    );

    expect(testBundleA.loadKeys.single, 'foo.svg');
    expect(testBundleB.loadKeys.single, 'foo.svg');
  });

  testWidgets('reload bytes when locale changes', (WidgetTester tester) async {
    final testBundle = TestAssetBundle();
    final GlobalKey key = GlobalKey();

    await tester.pumpWidget(
      Localizations(
        delegates: <LocalizationsDelegate<Object?>>[
          TestLocalizationsDelegate(),
        ],
        locale: const Locale('fr', 'CH'),
        child: DefaultAssetBundle(
          bundle: testBundle,
          child: VectorGraphic(
            key: key,
            loader: const AssetBytesLoader('foo.svg'),
          ),
        ),
      ),
    );
    // async localization loading requires extra pump and settle.
    await tester.pumpAndSettle();

    expect(testBundle.loadKeys.single, 'foo.svg');

    await tester.pumpWidget(
      Localizations(
        delegates: <LocalizationsDelegate<Object?>>[
          TestLocalizationsDelegate(),
        ],
        locale: const Locale('ab', 'cd'),
        child: DefaultAssetBundle(
          bundle: testBundle,
          child: VectorGraphic(
            key: key,
            loader: const AssetBytesLoader('foo.svg'),
          ),
        ),
      ),
    );
    // async localization loading requires extra pump and settle.
    await tester.pumpAndSettle();

    expect(testBundle.loadKeys, <String>['foo.svg', 'foo.svg']);
  });

  testWidgets('reload bytes when text direction changes', (
    WidgetTester tester,
  ) async {
    final testBundle = TestAssetBundle();
    final GlobalKey key = GlobalKey();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DefaultAssetBundle(
          bundle: testBundle,
          child: VectorGraphic(
            key: key,
            loader: const AssetBytesLoader('foo.svg'),
          ),
        ),
      ),
    );

    expect(testBundle.loadKeys.single, 'foo.svg');

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: DefaultAssetBundle(
          bundle: testBundle,
          child: VectorGraphic(
            key: key,
            loader: const AssetBytesLoader('foo.svg'),
          ),
        ),
      ),
    );

    expect(testBundle.loadKeys, <String>['foo.svg', 'foo.svg']);
  });

  testWidgets(
    'Cache is purged immediately after last VectorGraphic removed from tree',
    (WidgetTester tester) async {
      final testBundle = TestAssetBundle();
      final GlobalKey key = GlobalKey();

      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: testBundle,
          child: VectorGraphic(
            key: key,
            loader: const AssetBytesLoader('foo.svg'),
          ),
        ),
      );

      expect(testBundle.loadKeys.single, 'foo.svg');

      // Force VectorGraphic removed from tree.
      await tester.pumpWidget(const SizedBox());

      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: testBundle,
          child: VectorGraphic(
            key: key,
            loader: const AssetBytesLoader('foo.svg'),
          ),
        ),
      );

      expect(testBundle.loadKeys, <String>['foo.svg', 'foo.svg']);
    },
  );

  // For this test we evaluate an edge case where asset loading starts, but then a new
  // asset is requested before the first can load. We want to ensure that first asset does
  // not populate the cache in such a way that it gets "stuck".
  testWidgets('Bytes loading that becomes stale does not populate the cache', (
    WidgetTester tester,
  ) async {
    final testBundle = TestAssetBundle();
    final GlobalKey key = GlobalKey();
    final loader = ControlledAssetBytesLoader('foo.svg');

    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: testBundle,
        child: VectorGraphic(key: key, loader: loader),
      ),
    );

    expect(testBundle.loadKeys, isEmpty);

    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: testBundle,
        child: VectorGraphic(
          key: key,
          loader: const AssetBytesLoader('bar.svg'),
        ),
      ),
    );

    expect(testBundle.loadKeys, <String>['bar.svg']);
    loader.completer.complete();
    await tester.pumpAndSettle();

    expect(testBundle.loadKeys, <String>['bar.svg', 'foo.svg']);

    // Even though foo.svg was loaded above, it should have been immediately discarded since
    // the vector graphic widget was no longer requesting it. Thus we should see it loaded
    // a second time below.
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: testBundle,
        child: VectorGraphic(
          key: key,
          loader: const AssetBytesLoader('foo.svg'),
        ),
      ),
    );

    expect(testBundle.loadKeys, <String>['bar.svg', 'foo.svg', 'foo.svg']);
  });

  testWidgets(
    'precacheVectorGraphic warms live cache so VectorGraphic renders without reloading',
    (WidgetTester tester) async {
      final testBundle = TestAssetBundle();

      // Precache with the same context that VectorGraphic will inherit.
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DefaultAssetBundle(
            bundle: testBundle,
            child: Builder(
              builder: (BuildContext context) {
                precacheVectorGraphic(
                  const AssetBytesLoader('foo.svg'),
                  context,
                );
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(Duration.zero),
      );

      expect(testBundle.loadKeys.single, 'foo.svg');

      // Now mount a VectorGraphic with the same key -- it should hit the cache.
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DefaultAssetBundle(
            bundle: testBundle,
            child: VectorGraphic(
              loader: const AssetBytesLoader('foo.svg'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The asset was already decoded; no second load should occur.
      expect(testBundle.loadKeys.single, 'foo.svg');
    },
  );

  testWidgets(
    'precacheVectorGraphic keeps picture alive across widget unmount/remount',
    (WidgetTester tester) async {
      final testBundle = TestAssetBundle();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DefaultAssetBundle(
            bundle: testBundle,
            child: Builder(
              builder: (BuildContext context) {
                precacheVectorGraphic(
                  const AssetBytesLoader('foo.svg'),
                  context,
                );
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(Duration.zero),
      );

      expect(testBundle.loadKeys.single, 'foo.svg');

      // Mount then unmount -- simulates a route transition.
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DefaultAssetBundle(
            bundle: testBundle,
            child: VectorGraphic(
              loader: const AssetBytesLoader('foo.svg'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());

      // Remount -- the precache reference should keep the picture alive.
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DefaultAssetBundle(
            bundle: testBundle,
            child: VectorGraphic(
              loader: const AssetBytesLoader('foo.svg'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Only a single load should have happened across all mounts.
      expect(testBundle.loadKeys.single, 'foo.svg');
    },
  );

  testWidgets(
    'precacheVectorGraphic calls onError and does not throw on loader failure',
    (WidgetTester tester) async {
      Object? caughtError;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (BuildContext context) {
              precacheVectorGraphic(
                const _FailingBytesLoader(),
                context,
                onError: (Object error, StackTrace? _) {
                  caughtError = error;
                },
              );
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(Duration.zero),
      );

      expect(caughtError, isNotNull);
    },
  );

  testWidgets(
    'precacheVectorGraphic called twice for the same key does not double-count',
    (WidgetTester tester) async {
      final testBundle = TestAssetBundle();

      late BuildContext capturedContext;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DefaultAssetBundle(
            bundle: testBundle,
            child: Builder(
              builder: (BuildContext context) {
                capturedContext = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // Call precache twice; only one asset load should happen and the picture
      // should survive an unmount/remount without a second decode.
      await tester.runAsync(() async {
        await precacheVectorGraphic(
          const AssetBytesLoader('foo.svg'),
          capturedContext,
        );
        await precacheVectorGraphic(
          const AssetBytesLoader('foo.svg'),
          capturedContext,
        );
      });

      expect(testBundle.loadKeys.single, 'foo.svg');

      // Mount then fully unmount.
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DefaultAssetBundle(
            bundle: testBundle,
            child: VectorGraphic(
              loader: const AssetBytesLoader('foo.svg'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());

      // Remount — double-precache must not have leaked a phantom reference that
      // keeps the count above what _maybeReleasePicture expects, causing the
      // picture to be disposed prematurely or kept alive one extra decrement too
      // many.  A single load across all pumps confirms correct reference balance.
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: DefaultAssetBundle(
            bundle: testBundle,
            child: VectorGraphic(
              loader: const AssetBytesLoader('foo.svg'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(testBundle.loadKeys.single, 'foo.svg');
    },
  );

  testWidgets(
    'precacheVectorGraphic rethrows when no onError is provided',
    (WidgetTester tester) async {
      late Future<void> precacheFuture;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (BuildContext context) {
              precacheFuture = precacheVectorGraphic(
                const _FailingBytesLoader(),
                context,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      await tester.runAsync(() async {
        await expectLater(precacheFuture, throwsException);
      });
    },
  );
}

class TestAssetBundle extends Fake implements AssetBundle {
  final List<String> loadKeys = <String>[];

  @override
  Future<ByteData> load(String key) async {
    loadKeys.add(key);
    final buffer = VectorGraphicsBuffer();
    codec.writeSize(buffer, 100, 200);
    return buffer.done();
  }
}

class ControlledAssetBytesLoader extends AssetBytesLoader {
  ControlledAssetBytesLoader(super.assetName);

  final Completer<void> completer = Completer<void>();

  @override
  Future<ByteData> loadBytes(BuildContext? context) async {
    await completer.future;
    return super.loadBytes(context);
  }
}

class TestLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  @override
  bool isSupported(Locale locale) {
    return true;
  }

  @override
  Future<WidgetsLocalizations> load(Locale locale) async {
    return TestWidgetsLocalizations();
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<WidgetsLocalizations> old) {
    return false;
  }
}

class TestWidgetsLocalizations extends DefaultWidgetsLocalizations {
  @override
  TextDirection get textDirection => TextDirection.ltr;
}

class _FailingBytesLoader extends BytesLoader {
  const _FailingBytesLoader();

  @override
  Future<ByteData> loadBytes(BuildContext? context) {
    return Future<ByteData>.error(Exception('load failed'));
  }

  @override
  Object cacheKey(BuildContext? context) => '_FailingBytesLoader';
}
