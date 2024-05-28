// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is hand-formatted.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rfw/formats.dart' show parseLibraryFile;
import 'package:rfw/rfw.dart';

void main() {
  testWidgets('Core widgets', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['core']), createCoreWidgets());
    final DynamicContent data = DynamicContent();
    final List<String> eventLog = <String>[];
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['test']), 'root'),
        onEvent: (String eventName, DynamicMap eventArguments) {
          eventLog.add('$eventName $eventArguments');
        },
      ),
    );
    expect(tester.takeException().toString(), contains('Could not find remote widget named'));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = GestureDetector(
        onTapDown: event 'tapdown' { },
        onTapUp: event 'tapup' { },
        onTap: event 'tap' { },
        child: ColoredBox(),
      );
    '''));
    await tester.pump();
    await tester.tap(find.byType(ColoredBox));
    expect(eventLog, <String>['tapdown {}', 'tapup {}', 'tap {}']);
    eventLog.clear();

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = IntrinsicHeight();
    '''));
    await tester.pump();
    expect(find.byType(IntrinsicHeight), findsOneWidget);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = IntrinsicWidth();
    '''));
    await tester.pump();
    expect(find.byType(IntrinsicWidth), findsOneWidget);

    ArgumentDecoders.imageProviderDecoders['beepboop'] = (DataSource source, List<Object> key) {
      return MemoryImage(Uint8List.fromList(<int>[
        0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x01, 0x00,  0x01, 0x00, 0x80, 0xff, 0x00, 0xc0, 0xc0, 0xc0,
        0x00, 0x00, 0x00, 0x21, 0xf9, 0x04, 0x01, 0x00,  0x00, 0x00, 0x00, 0x2c, 0x00, 0x00, 0x00, 0x00,
        0x01, 0x00, 0x01, 0x00, 0x00, 0x02, 0x02, 0x44,  0x01, 0x00, 0x3b,
      ]));
    };
    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Image(source: 'beepboop');
    '''));
    await tester.pump();
    expect(find.byType(Image), findsOneWidget);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = SingleChildScrollView(child: ListBody());
    '''));
    await tester.pump();
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(ListBody), findsOneWidget);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Directionality(
        textDirection: "rtl",
        child: ListView(
          children: [
            Container(height: 67.0),
            Container(height: 67.0),
            Container(height: 67.0),
            Container(height: 67.0),
            Container(height: 67.0),
            Container(height: 67.0),
            Container(height: 67.0),
            Container(height: 67.0),
            Container(height: 67.0),
            Container(height: 67.0), // number 10 is not visible
          ],
        ),
      );
    '''));
    await tester.pump();
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(Container), findsNWidgets(9));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Opacity(
        onEnd: event 'end' {},
        child: Placeholder(),
      );
    '''));
    await tester.pump();
    expect(tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).onEnd, isNot(isNull));
    expect(eventLog, isEmpty);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Directionality(textDirection: "ltr", child: Padding(padding: [12.0]));
    '''));
    await tester.pump();
    expect(tester.widget<Padding>(find.byType(Padding)).padding.resolve(TextDirection.ltr), const EdgeInsets.all(12.0));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Directionality(textDirection: "ltr", child: Padding(padding: [24.0]));
    '''));
    await tester.pump();
    expect(tester.widget<Padding>(find.byType(Padding)).padding.resolve(TextDirection.ltr), const EdgeInsets.all(12.0));
    await tester.pump(const Duration(seconds: 4));
    expect(tester.widget<Padding>(find.byType(Padding)).padding.resolve(TextDirection.ltr), const EdgeInsets.all(24.0));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Placeholder();
    '''));
    await tester.pump();
    expect(find.byType(Placeholder), findsOneWidget);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Directionality(
        textDirection: "ltr",
        child: Stack(
          children: [
            Positioned(
              start: 0.0,
              top: 0.0,
              width: 10.0,
              height: 10.0,
              child: ColoredBox(),
            ),
          ],
        ),
      );
    '''));
    await tester.pump();
    expect(find.byType(Stack), findsOneWidget);
    expect(find.byType(Positioned), findsOneWidget);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Directionality(
        textDirection: "rtl",
        child: Rotation(turns: 0.0),
      );
    '''));
    await tester.pump();
    expect(find.byType(AnimatedRotation), findsOneWidget);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Directionality(
        textDirection: "rtl",
        child: Rotation(turns: 1.0, onEnd: event 'end' { from: "rotation" }),
      );
    '''));
    await tester.pump();
    expect(find.byType(AnimatedRotation), findsOneWidget);
    expect(eventLog, isEmpty);
    await tester.pump(const Duration(seconds: 1));
    expect(eventLog, <String>['end {from: rotation}']);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Directionality(
        textDirection: "rtl",
        child: Row(
          crossAxisAlignment: "start",
          children: [SizedBox(width: 10.0)]
        ),
      );
    '''));
    await tester.pump();
    expect(tester.getTopLeft(find.byType(SizedBox)), const Offset(790.0, 0.0));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Directionality(
        textDirection: "rtl",
        child: Row(
          crossAxisAlignment: "start",
          children: [Spacer()]
        ),
      );
    '''));
    await tester.pump();
    expect(tester.getTopLeft(find.byType(SizedBox)), Offset.zero);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = SizedBoxExpand();
    '''));
    await tester.pump();
    expect(find.byType(SizedBox), findsOneWidget);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = SizedBoxShrink();
    '''));
    await tester.pump();
    expect(find.byType(SizedBox), findsOneWidget);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Directionality(
        textDirection: "ltr",
        child: FractionallySizedBox(
          widthFactor: 0.5,
          heightFactor: 0.8,
          child: Text(
            text: "test",
            textScaleFactor: 3.0,
          ),
        ),
      );
    '''));
    await tester.pump();
    final Size fractionallySizedBoxSize = tester.getSize(find.byType(FractionallySizedBox));
    final Size childSize = tester.getSize(find.text('test'));
    expect(childSize.width, fractionallySizedBoxSize.width * 0.5);
    expect(childSize.height, fractionallySizedBoxSize.height * 0.8);
    expect(tester.widget<Text>(find.text('test')).textScaler, const TextScaler.linear(3));
    expect(tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox)).alignment, Alignment.center);
  });

  testWidgets('More core widgets', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['core']), createCoreWidgets());
    final DynamicContent data = DynamicContent();
    final List<String> eventLog = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: RemoteWidget(
          runtime: runtime,
          data: data,
          widget: const FullyQualifiedWidgetName(LibraryName(<String>['test']), 'root'),
          onEvent: (String eventName, DynamicMap eventArguments) {
            eventLog.add('$eventName $eventArguments');
          },
        ),
      ),
    );
    expect(tester.takeException().toString(), contains('Could not find remote widget named'));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = SafeArea(
        child: SizedBoxShrink(),
      );
    '''));
    await tester.pump();
    expect(find.byType(SafeArea), findsOneWidget);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Scale();
    '''));
    await tester.pump();
    expect(find.byType(AnimatedScale), findsOneWidget);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Wrap();
    '''));
    await tester.pump();
    expect(find.byType(Wrap), findsOneWidget);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = ClipRRect();
    '''));
    await tester.pump();
    expect(find.byType(ClipRRect), findsOneWidget);
    final RenderClipRRect renderClip = tester.allRenderObjects.whereType<RenderClipRRect>().first;
    expect(renderClip.clipBehavior, equals(Clip.antiAlias));
    expect(renderClip.borderRadius, equals(BorderRadius.zero));
  });
}
