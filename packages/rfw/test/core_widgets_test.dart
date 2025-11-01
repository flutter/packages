// Copyright 2013 The Flutter Authors
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
    addTearDown(runtime.dispose);
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
    imageCache.clear();
  });

  testWidgets('More core widgets', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['core']), createCoreWidgets());
    addTearDown(runtime.dispose);
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

  testWidgets('Flexible widget', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['core']), createCoreWidgets());
    addTearDown(runtime.dispose);
    final DynamicContent data = DynamicContent();

    // Test Flexible with default values
    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Directionality(
        textDirection: "ltr",
        child: Column(
          children: [
            Flexible(
              child: Text(text: "Default flexible"),
            ),
          ],
        ),
      );
    '''));

    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['test']), 'root'),
      ),
    );
    await tester.pump();
    expect(find.byType(Flexible), findsOneWidget);
    final Flexible defaultFlexible = tester.widget<Flexible>(find.byType(Flexible));
    expect(defaultFlexible.flex, equals(1));
    expect(defaultFlexible.fit, equals(FlexFit.loose));

    // Test Flexible with custom flex value
    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Directionality(
        textDirection: "ltr",
        child: Column(
          children: [
            Flexible(
              flex: 3,
              child: Text(text: "Custom flex"),
            ),
          ],
        ),
      );
    '''));
    await tester.pumpAndSettle();
    final Flexible customFlexFlexible = tester.widget<Flexible>(find.byType(Flexible));
    expect(customFlexFlexible.flex, equals(3));
    expect(customFlexFlexible.fit, equals(FlexFit.loose));

    // Test Flexible with fit: "tight"
    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Directionality(
        textDirection: "ltr",
        child: Column(
          children: [
            Flexible(
              flex: 2,
              fit: "tight",
              child: Text(text: "Tight fit"),
            ),
          ],
        ),
      );
    '''));
    await tester.pumpAndSettle();
    final Flexible tightFlexible = tester.widget<Flexible>(find.byType(Flexible));
    expect(tightFlexible.flex, equals(2));
    expect(tightFlexible.fit, equals(FlexFit.tight));

    // Test Flexible with fit: "loose"
    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Directionality(
        textDirection: "ltr",
        child: Column(
          children: [
            Flexible(
              flex: 4,
              fit: "loose",
              child: Text(text: "Loose fit"),
            ),
          ],
        ),
      );
    '''));
    await tester.pumpAndSettle();
    final Flexible looseFlexible = tester.widget<Flexible>(find.byType(Flexible));
    expect(looseFlexible.flex, equals(4));
    expect(looseFlexible.fit, equals(FlexFit.loose));

    // Test multiple Flexible widgets in a Column
    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Directionality(
        textDirection: "ltr",
        child: Column(
          children: [
            Flexible(
              flex: 1,
              fit: "loose",
              child: Text(text: "First"),
            ),
            Flexible(
              flex: 2,
              fit: "tight",
              child: Text(text: "Second"),
            ),
            Flexible(
              flex: 1,
              child: Text(text: "Third"),
            ),
          ],
        ),
      );
    '''));
    await tester.pumpAndSettle();
    expect(find.byType(Flexible), findsNWidgets(3));

    final List<Flexible> flexibleWidgets = tester.widgetList<Flexible>(find.byType(Flexible)).toList();
    expect(flexibleWidgets[0].flex, equals(1));
    expect(flexibleWidgets[0].fit, equals(FlexFit.loose));
    expect(flexibleWidgets[1].flex, equals(2));
    expect(flexibleWidgets[1].fit, equals(FlexFit.tight));
    expect(flexibleWidgets[2].flex, equals(1));
    expect(flexibleWidgets[2].fit, equals(FlexFit.loose));
  });
}