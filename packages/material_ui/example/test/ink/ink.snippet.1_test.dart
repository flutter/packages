// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/ink/ink.snippet.1.dart' as example;

const List<int> _kTransparentImage = <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];

class _TestAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin') {
      return const StandardMessageCodec().encodeMessage(<String, Object?>{
        'cat.jpeg': <Object?>[
          <String, Object?>{'asset': 'cat.jpeg'},
        ],
      })!;
    }
    if (key == 'cat.jpeg') {
      return ByteData.sublistView(Uint8List.fromList(_kTransparentImage));
    }
    throw FlutterError('Asset not found: $key');
  }
}

void main() {
  testWidgets('Ink.image paints image on Material with InkWell above it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: _TestAssetBundle(),
        child: const example.ExampleApp(),
      ),
    );
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage('cat.jpeg'),
        tester.element(find.text('KITTEN')),
      );
    });
    await tester.pumpAndSettle();

    expect(find.text('KITTEN'), findsOneWidget);
    expect(tester.getSize(find.byType(Ink)), const Size(300.0, 200.0));

    final MaterialInkController controller = Material.of(
      tester.element(find.text('KITTEN')),
    );
    expect(controller, paints..drawImageRect());

    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.text('KITTEN')),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      controller,
      paints
        ..drawImageRect()
        ..rect(),
    );

    await gesture.up();
    await tester.pumpAndSettle();
  });
}
