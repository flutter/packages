// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert' show base64Decode;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/src/listener.dart';
import 'package:vector_graphics/src/vector_graphics.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';

const VectorGraphicsCodec codec = VectorGraphicsCodec();

void main() {
  setUp(() {
    imageCache.clear();
    imageCache.clearLiveImages();
  });

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
    final int pathId = codec.writePath(
      buffer,
      Uint8List.fromList(<int>[
        ControlPointTypes.moveTo,
        ControlPointTypes.lineTo,
        ControlPointTypes.close,
      ]),
      Float32List.fromList(<double>[
        1,
        2,
        2,
        3,
      ]),
      0,
    );
    codec.writeDrawPath(buffer, pathId, paintId, null);

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
        find.byType(SizedBox).evaluate().first.widget as SizedBox;

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
        find.byType(SizedBox).evaluate().first.widget as SizedBox;

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
        find.byType(SizedBox).evaluate().first.widget as SizedBox;

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
        find.byType(FittedBox).evaluate().first.widget as FittedBox;

    expect(fittedBox.fit, BoxFit.fitHeight);
    expect(fittedBox.alignment, Alignment.centerLeft);
    expect(fittedBox.clipBehavior, Clip.hardEdge);
  });

  group('ClipBehavior', () {
    testWidgets('Sets clipBehavior to hardEdge if not provided',
        (WidgetTester tester) async {
      final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
      await tester.pumpWidget(VectorGraphic(
        loader: TestBytesLoader(buffer.done()),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(FittedBox), findsOneWidget);

      final FittedBox fittedBox =
          find.byType(FittedBox).evaluate().first.widget as FittedBox;

      expect(fittedBox.clipBehavior, Clip.hardEdge);
    });

    testWidgets('Passes clipBehavior to FittedBox if provided',
        (WidgetTester tester) async {
      final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
      await tester.pumpWidget(VectorGraphic(
        loader: TestBytesLoader(buffer.done()),
        clipBehavior: Clip.none,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(FittedBox), findsOneWidget);

      final FittedBox fittedBox =
          find.byType(FittedBox).evaluate().first.widget as FittedBox;

      expect(fittedBox.clipBehavior, Clip.none);
    });
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
        find.byType(SizedBox).evaluate().last.widget as SizedBox;

    expect(sizedBox.width, 100);
    expect(sizedBox.height, 200);
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

  testWidgets('Test animated switch between placeholder and image',
      (WidgetTester tester) async {
    final TestAssetBundle testBundle = TestAssetBundle();
    const Text placeholderWidget = Text('Placeholder');

    await tester.pumpWidget(DefaultAssetBundle(
      bundle: testBundle,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: VectorGraphic(
          loader: const AssetBytesLoader('bar.svg'),
          placeholderBuilder: (BuildContext context) => placeholderWidget,
          transitionDuration: const Duration(microseconds: 500),
        ),
      ),
    ));

    expect(find.text('Placeholder'), findsOneWidget);
    expect(find.byType(Container), findsNothing); // No image yet

    await tester.pumpAndSettle(const Duration(microseconds: 500));

    expect(find.text('Placeholder'), findsNothing);
    expect(testBundle.loadKeys, <String>['bar.svg']);
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

  testWidgets('Does not call setState after unmounting',
      (WidgetTester tester) async {
    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    codec.writeSize(buffer, 100, 200);
    final Completer<ByteData> completer = Completer<ByteData>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: VectorGraphic(
          loader: DelayedBytesLoader(completer.future),
        ),
      ),
    );
    await tester.pumpWidget(const Placeholder());
    completer.complete(buffer.done());
  });

  testWidgets('Loads a picture with loadPicture', (WidgetTester tester) async {
    final TestAssetBundle testBundle = TestAssetBundle();
    final Completer<PictureInfo> completer = Completer<PictureInfo>();
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
            child: Builder(builder: (BuildContext context) {
              vg
                  .loadPicture(const AssetBytesLoader('foo.svg'), context)
                  .then(completer.complete);
              return const Center();
            }),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(await completer.future, isA<PictureInfo>());
    expect(debugLastLocale, const Locale('fr', 'CH'));
    expect(debugLastTextDirection, TextDirection.rtl);
  });

  testWidgets('Loads a picture with loadPicture and null build context',
      (WidgetTester tester) async {
    final TestAssetBundle testBundle = TestAssetBundle();
    final Completer<PictureInfo> completer = Completer<PictureInfo>();
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
            child: Builder(builder: (BuildContext context) {
              vg
                  .loadPicture(
                      AssetBytesLoader('foo.svg', assetBundle: testBundle),
                      null)
                  .then(completer.complete);
              return const Center();
            }),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(await completer.future, isA<PictureInfo>());
    expect(debugLastLocale, PlatformDispatcher.instance.locale);
    expect(debugLastTextDirection, TextDirection.ltr);
  });

  testWidgets('Throws a helpful exception if decoding fails',
      (WidgetTester tester) async {
    final Uint8List data = Uint8List(256);
    final TestBytesLoader loader = TestBytesLoader(
      data.buffer.asByteData(),
      '/foo/bar/whatever.vec',
    );
    final GlobalKey key = GlobalKey();
    await tester.pumpWidget(Placeholder(key: key));

    late final VectorGraphicsDecodeException exception;
    try {
      await vg.loadPicture(loader, key.currentContext);
    } on VectorGraphicsDecodeException catch (e) {
      exception = e;
    }

    expect(exception.source, loader);
    expect(exception.originalException, isA<StateError>());
    expect(exception.toString(), contains(loader.toString()));
  });

  testWidgets(
    'Construct vector graphic with drawPicture strategy',
    (WidgetTester tester) async {
      final TestAssetBundle testBundle = TestAssetBundle();

      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: testBundle,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: createCompatVectorGraphic(
              loader: const AssetBytesLoader('foo.svg'),
              colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
              opacity: const AlwaysStoppedAnimation<double>(0.5),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.layers.last, isA<PictureLayer>());
      // Opacity and color filter are drawn as savelayer
      expect(tester.layers, isNot(contains(isA<OpacityLayer>())));
      expect(tester.layers, isNot(contains(isA<ColorFilterLayer>())));
    },
    skip: kIsWeb,
  ); // picture rasterization works differently on HTML due to saveLayer bugs in HTML backend

  testWidgets('Can render VG with image', (WidgetTester tester) async {
    const String bluePngPixel =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPj/HwADBwIAMCbHYQAAAABJRU5ErkJggg==';

    final VectorGraphicsBuffer buffer = VectorGraphicsBuffer();
    const VectorGraphicsCodec codec = VectorGraphicsCodec();
    codec.writeSize(buffer, 100, 100);

    codec.writeDrawImage(
      buffer,
      codec.writeImage(buffer, 0, base64Decode(bluePngPixel)),
      0,
      0,
      100,
      100,
      null,
    );
    final UniqueKey key = UniqueKey();
    final TestBytesLoader loader = TestBytesLoader(buffer.done());
    // See listener.dart.
    final int imageKey = Object.hash(loader.hashCode, 0, 0);

    expect(imageCache.currentSize, 0);
    expect(imageCache.statusForKey(imageKey).untracked, true);

    await tester.pumpWidget(RepaintBoundary(
      key: key,
      child: VectorGraphic(
        loader: loader,
        width: 100,
        height: 100,
      ),
    ));

    expect(imageCache.currentSize, 0);
    expect(imageCache.statusForKey(imageKey).pending, true);

    // A blank image, because the image hasn't loaded yet.
    await expectLater(
      find.byKey(key),
      matchesGoldenFile('vg_with_image_blank.png'),
    );

    expect(imageCache.currentSize, 1);
    expect(imageCache.statusForKey(imageKey).live, false);
    expect(imageCache.statusForKey(imageKey).keepAlive, true);

    await tester.runAsync(() => vg.waitForPendingDecodes());
    await tester.pump();

    expect(imageCache.currentSize, 1);
    expect(imageCache.statusForKey(imageKey).live, false);
    expect(imageCache.statusForKey(imageKey).keepAlive, true);

    // A blue square, becuase the image is available now.
    await expectLater(
      find.byKey(key),
      matchesGoldenFile('vg_with_image_blue.png'),
    );
  }, skip: kIsWeb);

  test('AssetBytesLoader respects packages', () async {
    final TestBundle bundle = TestBundle(<String, ByteData>{
      'foo': Uint8List(0).buffer.asByteData(),
      'packages/packageName/foo': Uint8List(1).buffer.asByteData(),
    });
    final AssetBytesLoader loader =
        AssetBytesLoader('foo', assetBundle: bundle);
    final AssetBytesLoader packageLoader = AssetBytesLoader('foo',
        assetBundle: bundle, packageName: 'packageName');
    expect((await loader.loadBytes(null)).lengthInBytes, 0);
    expect((await packageLoader.loadBytes(null)).lengthInBytes, 1);
  });

  testWidgets('Respects text direction', (WidgetTester tester) async {
    final TestAssetBundle testBundle = TestAssetBundle();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: DefaultAssetBundle(
          bundle: testBundle,
          child: const VectorGraphic(
            loader: AssetBytesLoader('foo.svg'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Transform), findsNothing);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: DefaultAssetBundle(
          bundle: testBundle,
          child: const VectorGraphic(
            loader: AssetBytesLoader('foo.svg'),
            matchTextDirection: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Matrix4 matrix = Matrix4.identity();
    final RenderObject transformObject =
        find.byType(Transform).evaluate().first.renderObject!;
    bool visited = false;
    transformObject.visitChildren((RenderObject child) {
      if (!visited) {
        transformObject.applyPaintTransform(child, matrix);
      }
      visited = true;
    });
    expect(visited, true);
    expect(matrix.getTranslation().x,
        100); // Width specified in the TestAssetBundle.
    expect(matrix.getTranslation().y, 0);
    expect(matrix.row0.x, -1);
    expect(matrix.row1.y, 1);
  });

  testWidgets('VectorGraphicsWidget can handle errors from bytes loader',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      VectorGraphic(
        loader: const ThrowingBytesLoader(),
        width: 100,
        height: 100,
        errorBuilder:
            (BuildContext context, Object error, StackTrace stackTrace) {
          return const Directionality(
            textDirection: TextDirection.ltr,
            child: Text('Error is handled'),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Error is handled'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class TestBundle extends Fake implements AssetBundle {
  TestBundle(this.map);

  final Map<String, ByteData> map;

  @override
  Future<ByteData> load(String key) async {
    return map[key]!;
  }
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

class DelayedBytesLoader extends BytesLoader {
  const DelayedBytesLoader(this.data);

  final Future<ByteData> data;

  @override
  Future<ByteData> loadBytes(BuildContext? context) async {
    return data;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  bool operator ==(Object other) {
    return other is DelayedBytesLoader && other.data == data;
  }
}

class TestBytesLoader extends BytesLoader {
  const TestBytesLoader(this.data, [this.source]);

  final ByteData data;
  final String? source;

  @override
  Future<ByteData> loadBytes(BuildContext? context) async {
    return data;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  bool operator ==(Object other) {
    return other is TestBytesLoader && other.data == data;
  }

  @override
  String toString() => 'TestBytesLoader: $source';
}

class ThrowingBytesLoader extends BytesLoader {
  const ThrowingBytesLoader();

  @override
  Future<ByteData> loadBytes(BuildContext? context) {
    throw UnimplementedError('Test exception');
  }
}
