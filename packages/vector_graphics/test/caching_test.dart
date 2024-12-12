// Copyright 2013 The Flutter Authors. All rights reserved.
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
    final TestAssetBundle testBundle = TestAssetBundle();
    final GlobalKey key = GlobalKey();

    await tester.pumpWidget(DefaultAssetBundle(
      key: UniqueKey(),
      bundle: testBundle,
      child: VectorGraphic(
        key: key,
        loader: const AssetBytesLoader('foo.svg'),
      ),
    ));

    expect(testBundle.loadKeys.single, 'foo.svg');

    await tester.pumpWidget(DefaultAssetBundle(
      key: UniqueKey(),
      bundle: testBundle,
      child: VectorGraphic(
        key: key,
        loader: const AssetBytesLoader('foo.svg'),
      ),
    ));

    expect(testBundle.loadKeys, <String>['foo.svg']);
  });

  testWidgets('Only loads bytes once for a repeated vg',
      (WidgetTester tester) async {
    final TestAssetBundle testBundle = TestAssetBundle();

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

  testWidgets('Does not cache bytes that come from different asset bundles',
      (WidgetTester tester) async {
    final TestAssetBundle testBundleA = TestAssetBundle();
    final TestAssetBundle testBundleB = TestAssetBundle();
    final GlobalKey key = GlobalKey();

    await tester.pumpWidget(DefaultAssetBundle(
      key: UniqueKey(),
      bundle: testBundleA,
      child: VectorGraphic(
        key: key,
        loader: const AssetBytesLoader('foo.svg'),
      ),
    ));

    expect(testBundleA.loadKeys.single, 'foo.svg');
    expect(testBundleB.loadKeys, isEmpty);

    await tester.pumpWidget(DefaultAssetBundle(
      key: UniqueKey(),
      bundle: testBundleB,
      child: VectorGraphic(
        key: key,
        loader: const AssetBytesLoader('foo.svg'),
      ),
    ));

    expect(testBundleA.loadKeys.single, 'foo.svg');
    expect(testBundleB.loadKeys.single, 'foo.svg');
  });

  testWidgets('reload bytes when locale changes', (WidgetTester tester) async {
    final TestAssetBundle testBundle = TestAssetBundle();
    final GlobalKey key = GlobalKey();

    await tester.pumpWidget(
      Localizations(
        delegates: <LocalizationsDelegate<Object?>>[
          TestLocalizationsDelegate()
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
          TestLocalizationsDelegate()
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

  testWidgets('reload bytes when text direction changes',
      (WidgetTester tester) async {
    final TestAssetBundle testBundle = TestAssetBundle();
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
    final TestAssetBundle testBundle = TestAssetBundle();
    final GlobalKey key = GlobalKey();

    await tester.pumpWidget(DefaultAssetBundle(
      bundle: testBundle,
      child: VectorGraphic(
        key: key,
        loader: const AssetBytesLoader('foo.svg'),
      ),
    ));

    expect(testBundle.loadKeys.single, 'foo.svg');

    // Force VectorGraphic removed from tree.
    await tester.pumpWidget(const SizedBox());

    await tester.pumpWidget(DefaultAssetBundle(
      bundle: testBundle,
      child: VectorGraphic(
        key: key,
        loader: const AssetBytesLoader('foo.svg'),
      ),
    ));

    expect(testBundle.loadKeys, <String>['foo.svg', 'foo.svg']);
  });

  // For this test we evaluate an edge case where asset loading starts, but then a new
  // asset is requested before the first can load. We want to ensure that first asset does
  // not populate the cache in such a way that it gets "stuck".
  testWidgets('Bytes loading that becomes stale does not populate the cache',
      (WidgetTester tester) async {
    final TestAssetBundle testBundle = TestAssetBundle();
    final GlobalKey key = GlobalKey();
    final ControlledAssetBytesLoader loader =
        ControlledAssetBytesLoader('foo.svg');

    await tester.pumpWidget(DefaultAssetBundle(
      bundle: testBundle,
      child: VectorGraphic(
        key: key,
        loader: loader,
      ),
    ));

    expect(testBundle.loadKeys, isEmpty);

    await tester.pumpWidget(DefaultAssetBundle(
      bundle: testBundle,
      child: VectorGraphic(
        key: key,
        loader: const AssetBytesLoader('bar.svg'),
      ),
    ));

    expect(testBundle.loadKeys, <String>['bar.svg']);
    loader.completer.complete();
    await tester.pumpAndSettle();

    expect(testBundle.loadKeys, <String>['bar.svg', 'foo.svg']);

    // Even though foo.svg was loaded above, it should have been immediately discarded since
    // the vector graphic widget was no longer requesting it. Thus we should see it loaded
    // a second time below.
    await tester.pumpWidget(DefaultAssetBundle(
      bundle: testBundle,
      child: VectorGraphic(
        key: key,
        loader: const AssetBytesLoader('foo.svg'),
      ),
    ));

    expect(testBundle.loadKeys, <String>['bar.svg', 'foo.svg', 'foo.svg']);
  });
}

class TestAssetBundle extends Fake implements AssetBundle {
  final List<String> loadKeys = <String>[];

  @override
  Future<ByteData> load(String key) async {
    loadKeys.add(key);
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
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
