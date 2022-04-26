// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/listener.dart';
import 'package:vector_graphics/vector_graphics.dart';

import 'package:vector_graphics_codec/vector_graphics_codec.dart';

const VectorGraphicsCodec codec = VectorGraphicsCodec();

void main() {
  test('Can decode a message without a stroke and vertices', () {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    final FlutterVectorGraphicsListener listener =
        FlutterVectorGraphicsListener();
    final int paintId = codec.writeStroke(buffer, 44, 1, 2, 3, 4.0, 6.0);
    codec.writeDrawVertices(
        buffer,
        Float32List.fromList(<double>[
          0.0,
          2.0,
          3.0,
          4.0,
          2.0,
          4.0,
        ]),
        null,
        paintId);

    codec.decode(buffer.done(), listener);

    expect(listener.toPicture, returnsNormally);
  });

  test('Can decode a message with a fill and path', () {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    final FlutterVectorGraphicsListener listener =
        FlutterVectorGraphicsListener();
    final int paintId = codec.writeFill(buffer, 23, 0);
    final int pathId = codec.writeStartPath(buffer, 0);
    codec.writeMoveTo(buffer, 1, 2);
    codec.writeLineTo(buffer, 2, 3);
    codec.writeClose(buffer);
    codec.writeFinishPath(buffer);
    codec.writeDrawPath(buffer, pathId, paintId);

    codec.decode(buffer.done(), listener);

    expect(listener.toPicture, returnsNormally);
  });

  test('Asserts if toPicture is called more than once', () {
    final FlutterVectorGraphicsListener listener =
        FlutterVectorGraphicsListener();
    listener.toPicture();

    expect(listener.toPicture, throwsAssertionError);
  });

  testWidgets(
      'Creates layout widgets when VectorGraphic is sized (0x0 graphic)',
      (WidgetTester tester) async {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    await tester.pumpWidget(VectorGraphic(
      loader: TestBytesLoader(buffer.done()),
      width: 100,
      height: 100,
    ));
    await tester.pumpAndSettle();

    expect(find.byType(SizedBox), findsNWidgets(2));

    final SizedBox sizedBox =
        (find.byType(SizedBox).evaluate().first.widget as SizedBox);

    expect(sizedBox.width, 100);
    expect(sizedBox.height, 100);
  });

  testWidgets('Creates layout widgets when VectorGraphic is sized (1:1 ratio)',
      (WidgetTester tester) async {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    const VectorGraphicsCodec().writeSize(buffer, 50, 50);
    await tester.pumpWidget(VectorGraphic(
      loader: TestBytesLoader(buffer.done()),
      width: 100,
      height: 100,
    ));
    await tester.pumpAndSettle();

    expect(find.byType(SizedBox), findsNWidgets(2));

    final SizedBox sizedBox =
        (find.byType(SizedBox).evaluate().first.widget as SizedBox);

    expect(sizedBox.width, 100);
    expect(sizedBox.height, 100);
  });

  testWidgets('Creates layout widgets when VectorGraphic is sized (3:5 ratio)',
      (WidgetTester tester) async {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    const VectorGraphicsCodec().writeSize(buffer, 30, 50);
    await tester.pumpWidget(VectorGraphic(
      loader: TestBytesLoader(buffer.done()),
      width: 100,
      height: 100,
    ));
    await tester.pumpAndSettle();

    expect(find.byType(SizedBox), findsNWidgets(2));

    final SizedBox sizedBox =
        (find.byType(SizedBox).evaluate().first.widget as SizedBox);

    expect(sizedBox.width, 60);
    expect(sizedBox.height, 100);
  });

  testWidgets('Creates alignment widgets when VectorGraphic is aligned',
      (WidgetTester tester) async {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    await tester.pumpWidget(VectorGraphic(
      loader: TestBytesLoader(buffer.done()),
      alignment: Alignment.centerLeft,
      fit: BoxFit.fitHeight,
    ));
    await tester.pumpAndSettle();

    expect(find.byType(FittedBox), findsOneWidget);

    final FittedBox fittedBox =
        (find.byType(FittedBox).evaluate().first.widget as FittedBox);

    expect(fittedBox.fit, BoxFit.fitHeight);
    expect(fittedBox.alignment, Alignment.centerLeft);
    expect(fittedBox.clipBehavior, Clip.hardEdge);
  });

  testWidgets('Sizes VectorGraphic based on encoded viewbox information',
      (WidgetTester tester) async {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    codec.writeSize(buffer, 100, 200);

    await tester.pumpWidget(VectorGraphic(
      loader: TestBytesLoader(buffer.done()),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(SizedBox), findsNWidgets(2));

    final SizedBox sizedBox =
        (find.byType(SizedBox).evaluate().last.widget as SizedBox);

    expect(sizedBox.width, 100);
    expect(sizedBox.height, 200);
  });

  testWidgets('Reloads bytes when position changes in tree',
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

    expect(testBundle.loadKeys, <String>['foo.svg', 'foo.svg']);
  });

  testWidgets('Reloads bytes when configuration changes',
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

    await tester.pumpWidget(DefaultAssetBundle(
      bundle: testBundle,
      child: VectorGraphic(
        key: key,
        loader: const AssetBytesLoader('bar.svg'),
      ),
    ));

    expect(testBundle.loadKeys, <String>['foo.svg', 'bar.svg']);
  });

  testWidgets('Can update SVG picture', (WidgetTester tester) async {
    final TestAssetBundle testBundle = TestAssetBundle();

    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: testBundle,
        child: const VectorGraphic(
          loader: AssetBytesLoader('foo.svg'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.layers, contains(isA<PictureLayer>()));

    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: testBundle,
        child: const VectorGraphic(
          loader: AssetBytesLoader('bar.svg'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.layers, contains(isA<PictureLayer>()));
  });

  testWidgets('Uses repaint boundary', (WidgetTester tester) async {
    final TestAssetBundle testBundle = TestAssetBundle();

    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: testBundle,
        child: const VectorGraphic(
          loader: AssetBytesLoader('foo.svg'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RepaintBoundary), findsOneWidget);
  });

  testWidgets('PictureInfo.dispose is safe to call multiple times',
      (WidgetTester tester) async {
    final FlutterVectorGraphicsListener listener =
        FlutterVectorGraphicsListener();
    final PictureInfo info = listener.toPicture();

    info.dispose();
    expect(info.dispose, returnsNormally);
  });

  testWidgets('Can set locale and text direction', (WidgetTester tester) async {
    final TestAssetBundle testBundle = TestAssetBundle();
    await tester.pumpWidget(
      Localizations(
        delegates: const <LocalizationsDelegate<Object>>[
          DefaultWidgetsLocalizations.delegate
        ],
        locale: const Locale('fr', 'CH'),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: DefaultAssetBundle(
            bundle: testBundle,
            child: const VectorGraphic(
              loader: AssetBytesLoader('bar.svg'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(debugLastLocale, const Locale('fr', 'CH'));
    expect(debugLastTextDirection, TextDirection.rtl);

    await tester.pumpWidget(
      Localizations(
        delegates: const <LocalizationsDelegate<Object>>[
          DefaultWidgetsLocalizations.delegate
        ],
        locale: const Locale('ab', 'AB'),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: DefaultAssetBundle(
            bundle: testBundle,
            child: const VectorGraphic(
              loader: AssetBytesLoader('bar.svg'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(debugLastLocale, const Locale('ab', 'AB'));
    expect(debugLastTextDirection, TextDirection.ltr);
  });

  testWidgets('Can exclude from semantics', (WidgetTester tester) async {
    final TestAssetBundle testBundle = TestAssetBundle();

    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: testBundle,
        child: const VectorGraphic(
          loader: AssetBytesLoader('foo.svg'),
          excludeFromSemantics: true,
          semanticsLabel: 'Foo',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Foo'), findsNothing);
  });

  testWidgets('Can add semantic label', (WidgetTester tester) async {
    final TestAssetBundle testBundle = TestAssetBundle();

    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: testBundle,
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: VectorGraphic(
            loader: AssetBytesLoader('foo.svg'),
            semanticsLabel: 'Foo',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.bySemanticsLabel('Foo')),
      matchesSemantics(
        label: 'Foo',
        isImage: true,
      ),
    );
  });

  testWidgets('Default placeholder builder', (WidgetTester tester) async {
    final TestAssetBundle testBundle = TestAssetBundle();

    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: testBundle,
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: VectorGraphic(
            loader: AssetBytesLoader('foo.svg'),
            semanticsLabel: 'Foo',
          ),
        ),
      ),
    );

    expect(find.byType(SizedBox), findsOneWidget);
  });

  testWidgets('Custom placeholder builder', (WidgetTester tester) async {
    final TestAssetBundle testBundle = TestAssetBundle();

    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: testBundle,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: VectorGraphic(
            loader: const AssetBytesLoader('foo.svg'),
            semanticsLabel: 'Foo',
            placeholderBuilder: (BuildContext context) {
              return Container(key: const ValueKey<int>(23));
            },
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey<int>(23)), findsOneWidget);
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

class TestBytesLoader extends BytesLoader {
  const TestBytesLoader(this.data);

  final ByteData data;

  @override
  Future<ByteData> loadBytes(BuildContext context) async {
    return data;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  bool operator ==(Object other) {
    return other is TestBytesLoader && other.data == data;
  }
}
