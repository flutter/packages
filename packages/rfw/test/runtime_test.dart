// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is hand-formatted.

// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rfw/formats.dart' show parseDataFile, parseLibraryFile;
import 'package:rfw/rfw.dart';

void main() {
  testWidgets('list lookup', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['core']), createCoreWidgets());
    final DynamicContent data = DynamicContent(<String, Object?>{
      'list': <Object?>[ 0, 1, 2, 3, 4 ],
    });
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['test']), 'root'),
      ),
    );
    expect(find.byType(RemoteWidget), findsOneWidget);
    expect(tester.takeException().toString(), contains('Could not find remote widget named'));
    expect(find.byType(ErrorWidget), findsOneWidget);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Column(
        children: [
          ...for v in data.list: Text(text: v, textDirection: "ltr"),
        ],
      );
    '''));
    await tester.pump();
    expect(find.byType(Text), findsNWidgets(5));
  });

  testWidgets('data updates', (WidgetTester tester) async {
    int buildCount = 0;
    int? lastValue;
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['core']), LocalWidgetLibrary(<String, LocalWidgetBuilder>{
        'Test': (BuildContext context, DataSource source) {
          buildCount += 1;
          lastValue = source.v<int>(<Object>['value']);
          return const SizedBox.shrink();
        },
      }));
    final DynamicContent data = DynamicContent(<String, Object?>{
      'list': <Object?>[
        <String, Object?>{ 'a': 0 },
        <String, Object?>{ 'a': 1 },
        <String, Object?>{ 'a': 2 },
      ],
    });
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['test']), 'root'),
      ),
    );
    expect(tester.takeException().toString(), contains('Could not find remote widget named'));
    expect(buildCount, 0);
    expect(lastValue, isNull);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Test(value: data.list.1.a);
    '''));
    await tester.pump();
    expect(buildCount, 1);
    expect(lastValue, 1);

    data.update('list', <Object?>[
      <String, Object?>{ 'a': 0 },
      <String, Object?>{ 'a': 3 },
      <String, Object?>{ 'a': 2 },
    ]);
    await tester.pump();
    expect(buildCount, 2);
    expect(lastValue, 3);

    data.update('list', <Object?>[
      <String, Object?>{ 'a': 1 },
      <String, Object?>{ 'a': 3 },
    ]);
    await tester.pump();
    expect(buildCount, 2);
    expect(lastValue, 3);

    data.update('list', <Object?>[
      <String, Object?>{ 'a': 1 },
      <String, Object?>{ },
    ]);
    await tester.pump();
    expect(buildCount, 3);
    expect(lastValue, null);

    data.update('list', <Object?>[
      <String, Object?>{ 'a': 1 },
    ]);
    await tester.pump();
    expect(buildCount, 3);
    expect(lastValue, null);
  });

  testWidgets('$RemoteFlutterWidgetsException', (WidgetTester tester) async {
    expect(const RemoteFlutterWidgetsException('test').toString(), 'test');
  });

  testWidgets('deepClone', (WidgetTester tester) async {
    final Map<String, Object> map = <String, Object>{
      'outer': <String, Object>{
        'inner': true,
      }
    };
    expect(identical(deepClone(map), map), isFalse);
    expect(deepClone(map), equals(map));
  });

  testWidgets('updateText, updateBinary, clearLibraries', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['core']), createCoreWidgets());
    final DynamicContent data = DynamicContent();
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['test']), 'root'),
      ),
    );
    expect(find.byType(RemoteWidget), findsOneWidget);
    expect(tester.takeException().toString(), contains('Could not find remote widget named'));
    expect(find.byType(ErrorWidget), findsOneWidget);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = ColoredBox(color: 0xFF000000);
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0xFF000000));

    runtime.update(const LibraryName(<String>['test']), decodeLibraryBlob(encodeLibraryBlob(parseLibraryFile('''
      import core;
      widget root = ColoredBox(color: 0xFF000001);
    '''))));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0xFF000001));

    runtime.clearLibraries();
    await tester.pump();
    expect(find.byType(RemoteWidget), findsOneWidget);
    expect(tester.takeException().toString(), contains('Could not find remote widget named'));
    expect(find.byType(ErrorWidget), findsOneWidget);
  });

  testWidgets('Runtime cached build', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['core']), createCoreWidgets());
    final DynamicContent data = DynamicContent();
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['core']), 'Placeholder'),
      ),
    );

    expect(find.byType(Placeholder), findsOneWidget);
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['core']), 'SizedBoxShrink'),
      ),
    );
    expect(find.byType(Placeholder), findsNothing);
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['core']), 'Placeholder'),
      ),
    );
    expect(find.byType(Placeholder), findsOneWidget);
  });

  testWidgets('Import loops', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['a']), parseLibraryFile('''
        import b;
      '''))
      ..update(const LibraryName(<String>['b']), parseLibraryFile('''
        import a;
      '''));
    final DynamicContent data = DynamicContent();
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['a']), 'widget'),
      ),
    );
    expect(tester.takeException().toString(), 'Library a indirectly depends on itself via b which depends on a.');
  });

  testWidgets('Import loops', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['a']), parseLibraryFile('''
        import a;
      '''));
    final DynamicContent data = DynamicContent();
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['a']), 'widget'),
      ),
    );
    expect(tester.takeException().toString(), 'Library a depends on itself.');
  });

  testWidgets('Missing libraries in import', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['a']), parseLibraryFile('''
        import b;
      '''));
    final DynamicContent data = DynamicContent();
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['a']), 'widget'),
      ),
    );
    expect(tester.takeException().toString(), contains('Could not find remote widget named'));
    expect(tester.widget<ErrorWidget>(find.byType(ErrorWidget)).message, 'Could not find remote widget named widget in a, possibly because some dependencies were missing: b');
  });

  testWidgets('Missing libraries in specified widget', (WidgetTester tester) async {
    final Runtime runtime = Runtime();
    final DynamicContent data = DynamicContent();
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['a']), 'widget'),
      ),
    );
    expect(tester.takeException().toString(), contains('Could not find remote widget named'));
    expect(tester.widget<ErrorWidget>(find.byType(ErrorWidget)).message, 'Could not find remote widget named widget in a, possibly because some dependencies were missing: a');
  });

  testWidgets('Missing libraries in import via dependency', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['a']), parseLibraryFile('''
        import b;
        widget widget = test();
      '''));
    final DynamicContent data = DynamicContent();
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['a']), 'widget'),
      ),
    );
    expect(tester.takeException().toString(), contains('Could not find remote widget named'));
    expect(tester.widget<ErrorWidget>(find.byType(ErrorWidget)).message, 'Could not find remote widget named test in a, possibly because some dependencies were missing: b');
  });

  testWidgets('Missing widget', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['a']), parseLibraryFile(''));
    final DynamicContent data = DynamicContent();
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['a']), 'widget'),
      ),
    );
    expect(tester.takeException().toString(), contains('Could not find remote widget named'));
    expect(tester.widget<ErrorWidget>(find.byType(ErrorWidget)).message, 'Could not find remote widget named widget in a.');
  });

  testWidgets('Runtime', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['core']), createCoreWidgets());
    final DynamicContent data = DynamicContent();
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['test']), 'root'),
      ),
    );
    expect(tester.takeException().toString(), contains('Could not find remote widget named'));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root { level: 0 } = inner(level: state.level);
      widget inner { level: 1 } = ColoredBox(color: args.level);
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0x00000000));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root { level: 0 } = inner(level: state.level);
      widget inner { level: 1 } = ColoredBox(color: state.level);
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0x00000001));
  });

  testWidgets('Runtime', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['core']), createCoreWidgets());
    final DynamicContent data = DynamicContent();
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['test']), 'root'),
      ),
    );
    expect(tester.takeException().toString(), contains('Could not find remote widget named'));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root { level: 0 } = switch state.level {
        0: ColoredBox(color: 2),
      };
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0x00000002));
  });

  testWidgets('Runtime', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
          ..update(const LibraryName(<String>['core']), createCoreWidgets());
    expect(runtime.libraries.length, 1);
    final LibraryName libraryName = runtime.libraries.entries.first.key;
    expect('$libraryName', 'core');
    final WidgetLibrary widgetLibrary = runtime.libraries.entries.first.value;
    expect(widgetLibrary, isA<LocalWidgetLibrary>());
    widgetLibrary as LocalWidgetLibrary;
    expect(widgetLibrary.widgets.length, greaterThan(1));
  });

  testWidgets('Runtime', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['core']), createCoreWidgets());
    final DynamicContent data = DynamicContent();
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['test']), 'root'),
      ),
    );
    expect(tester.takeException().toString(), contains('Could not find remote widget named'));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root { level: 0 } = GestureDetector(
        onTap: set state.level = 1,
        child: ColoredBox(color: state.level),
      );
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0x00000000));
    await tester.tap(find.byType(ColoredBox));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0x00000001));
  });

  testWidgets('DynamicContent', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['core']), createCoreWidgets());
    final DynamicContent data = DynamicContent();
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['test']), 'root'),
      ),
    );
    expect(tester.takeException().toString(), contains('Could not find remote widget named'));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = ColoredBox(color: data.color.value);
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0xFF000000));

    data.update('color', json.decode('{"value":1}') as Object);
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0x00000001));

    data.update('color', parseDataFile('{value:2}'));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0x00000002));

    data.update('color', decodeDataBlob(Uint8List.fromList(<int>[
      0xFE, 0x52, 0x57, 0x44, // signature
      0x07, // data is a map
      0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // ...which has one key
      0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // ...which has five letters
      0x76, 0x61, 0x6c, 0x75, 0x65, // ...which are "value"
      0x02, // and the value is an integer
      0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // ...which is the number 2
    ])));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0x00000002));
  });

  testWidgets('DynamicContent', (WidgetTester tester) async {
    final DynamicContent data = DynamicContent(<String, Object?>{'hello': 'world'});
    expect(data.toString(), 'DynamicContent({hello: world})');
  });

  testWidgets('binding loop variables', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['core']), createCoreWidgets());
    final DynamicContent data = DynamicContent(<String, Object?>{
      'list': <Object?>[
        <String, Object?>{
          'a': <String, Object?>{ 'b': 0xEE },
          'c': <Object?>[ 0xDD ],
        },
      ],
    });
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
    expect(find.byType(RemoteWidget), findsOneWidget);
    expect(tester.takeException().toString(), contains('Could not find remote widget named'));
    expect(find.byType(ErrorWidget), findsOneWidget);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget verify = ColoredBox(color: args.value.0.q.0);
      widget root = verify(
        value: [
          ...for v in data.list: {
            q: [ v.a.b ],
          },
        ],
      );
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0x000000EE));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget verify = ColoredBox(color: args.value.0.q.0);
      widget root = verify(
        value: [
          ...for v in data.list: {
            q: [ ...for w in v.c: w ],
          },
        ],
      );
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0x000000DD));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget verify = ColoredBox(color: args.value.0.q);
      widget root = verify(
        value: [
          ...for v in data.list: {
            q: switch v.a.b {
              0xEE: 0xCC,
              default: 0xFF,
            },
          },
        ],
      );
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0x000000CC));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget verify { state: true } = ColoredBox(color: args.value.c.0);
      widget remote = SizedBox(child: args.corn.0);
      widget root = remote(
        corn: [
          ...for v in data.list:
            verify(value: v),
        ],
      );
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0x000000DD));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget verify { state: true } = ColoredBox(color: args.value);
      widget remote = SizedBox(child: args.corn.0);
      widget root = remote(
        corn: [
          ...for v in data.list:
            verify(value: switch v.c.0 {
              0: 0xFF000000,
              0xDD: 0xFF0D0D0D,
              default: v,
            }),
        ],
      );
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0xFF0D0D0D));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget verify { state: true } = switch args.value.c.0 {
        0xDD: ColoredBox(color: 0xFF0D0D0D),
        default: ColoredBox(color: args.value),
      };
      widget remote = SizedBox(child: args.corn.0);
      widget root = remote(
        corn: [
          ...for v in data.list:
            verify(value: v),
        ],
      );
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0xFF0D0D0D));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget verify { state: true } = GestureDetector(
        onTap: event 'test' { test: args.value.a.b },
        child: ColoredBox(),
      );
      widget remote = SizedBox(child: args.corn.0);
      widget root = remote(
        corn: [
          ...for v in data.list:
            verify(value: v),
        ],
      );
    '''));
    expect(eventLog, isEmpty);
    await tester.pump();
    await tester.tap(find.byType(ColoredBox));
    expect(eventLog, <String>['test {test: ${0xEE}}']);
    eventLog.clear();

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget verify { state: 0x00 } = GestureDetector(
        onTap: set state.state = args.value.a.b,
        child: ColoredBox(color: switch state.state {
          0x00: 0xFF000001,
          0xEE: 0xFF000002,
        }),
      );
      widget remote = SizedBox(child: args.corn.0);
      widget root = remote(
        corn: [
          ...for v in data.list:
            verify(value: v),
        ],
      );
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0xFF000001));
    await tester.tap(find.byType(ColoredBox));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0xFF000002));

  });

  testWidgets('list lookup of esoteric values', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['core']), createCoreWidgets());
    final DynamicContent data = DynamicContent();
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['test']), 'root'),
      ),
    );
    expect(tester.takeException().toString(), contains('Could not find remote widget named'));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = test(list: ['A'], loop: [...for b in ["B", "C"]: b]);
      widget test = Text(
        textDirection: "ltr",
        text: [
          '>',
          ...for a in args.list: a,
          ...for b in args.loop: b,
          '<',
        ],
      );
    '''));
    await tester.pump();
    expect(find.text('>ABC<'), findsOneWidget);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Text(
        textDirection: "ltr",
        text: [
          '>',
          ...for a in root(): a,
          '<',
        ],
      );
    '''));
    await tester.pump();
    expect(find.text('><'), findsOneWidget);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = test(list: [test()]);
      widget test = Text(
        textDirection: "ltr",
        text: [
          '>',
          ...for a in args.list: a,
          '<',
        ],
      );
    '''));
    await tester.pump();
    expect(find.text('><'), findsOneWidget);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root { list: [ 0x01 ] } = GestureDetector(
        onTap: set state.list = [ 0x02, 0x03 ],
        child: Column(
          children: [
            ...for v in state.list:
              SizedBox(height: 10.0, width: 10.0, child: ColoredBox(color: v)),
          ],
        ),
      );
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0x00000001));
    await tester.tap(find.byType(ColoredBox));
    await tester.pump();
    expect(tester.firstWidget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0x00000002));
    expect(find.byType(ColoredBox), findsNWidgets(2));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Column(
        children: [
          ...for v in switch 0 {
            0: [ColoredBox(color: 0x00000001)],
            default: [ColoredBox(color: 0xFFFF0000)],
          }: v,
        ],
      );
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0x00000001));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = Column(
        children: [
          ...for v in {
            a: [ColoredBox(color: 0x00000001)],
            b: [ColoredBox(color: 0xFFFF0000)],
          }: v,
        ],
      );
    '''));
    await tester.pump();
    expect(find.byType(ColoredBox), findsNothing);

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = test(
        list: [...for w in [ColoredBox(color: 0xFF00FF00)]: w],
      );
      widget test = Column(
        children: [
          ...for v in args.list: v,
        ],
      );
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0xFF00FF00));
  });

  testWidgets('data lookup', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['core']), createCoreWidgets());
    final DynamicContent data = DynamicContent(<String, Object?>{
      'map': <String, Object?>{ 'list': <Object?>[ 0xAB ] },
    });
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['test']), 'root'),
      ),
    );
    expect(tester.takeException().toString(), contains('Could not find remote widget named'));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = test(list: data.map.list);
      widget test = ColoredBox(color: args.list.0);
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0x000000AB));
  });

  testWidgets('args lookup', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['core']), createCoreWidgets());
    final DynamicContent data = DynamicContent();
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['test']), 'root'),
      ),
    );
    expect(tester.takeException().toString(), contains('Could not find remote widget named'));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = test1(map: { 'list': [ 0xAC ] });
      widget test1 = test2(list: args.map.list);
      widget test2 = ColoredBox(color: args.list.0);
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0x000000AC));
  });

  testWidgets('state lookup', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['core']), createCoreWidgets());
    final DynamicContent data = DynamicContent();
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['test']), 'root'),
      ),
    );
    expect(tester.takeException().toString(), contains('Could not find remote widget named'));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root { map: { 'list': [ 0xAD ] } } = test(list: state.map.list);
      widget test = ColoredBox(color: args.list.0);
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0x000000AD));
  });

  testWidgets('switch', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['core']), createCoreWidgets());
    final DynamicContent data = DynamicContent();
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['test']), 'root'),
      ),
    );
    expect(tester.takeException().toString(), contains('Could not find remote widget named'));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = ColoredBox(color: switch data.a.b {
        0: 0x11111111,
        default: 0x22222222,
      });
    '''));
    data.update('a', parseDataFile('{ b: 1 }'));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0x22222222));
    data.update('a', parseDataFile('{ b: 0 }'));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0x11111111));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = switch true {};
    '''));
    await tester.pump();
    expect(tester.takeException().toString(), 'Switch in test:root did not resolve to a widget (got <missing>).');
  });

  testWidgets('events with arguments', (WidgetTester tester) async {
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
        onTap: event 'tap' {
          list: [...for a in [0,1]: a],
        },
        child: ColoredBox(),
      );
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0xFF000000));
    expect(eventLog, isEmpty);
    await tester.tap(find.byType(ColoredBox));
    expect(eventLog, <String>['tap {list: [0, 1]}']);
    eventLog.clear();

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root = GestureDetector(
        onTap: [ event 'tap' { a: 1 }, event 'tap' { a: 2 }, event 'final tap' { } ],
        child: ColoredBox(),
      );
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0xFF000000));
    expect(eventLog, isEmpty);
    await tester.tap(find.byType(ColoredBox));
    expect(eventLog, <String>['tap {a: 1}', 'tap {a: 2}', 'final tap {}']);
    eventLog.clear();
  });

  testWidgets('_CurriedWidget toStrings', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['core']), createCoreWidgets());
    final DynamicContent data = DynamicContent();
    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget stateless = ColoredBox(color: 0xAA);
      widget stateful { test: false } = ColoredBox(color: 0xBB);
      widget switchy = switch true { default: ColoredBox(color: 0xCC) };
    '''));
    expect(
      (runtime.build(
        tester.element(find.byType(Container)),
        const FullyQualifiedWidgetName(LibraryName(<String>['test']), 'stateless'),
        data,
        (String eventName, DynamicMap eventArguments) {},
      ) as dynamic).curriedWidget.toString(),
      'core:ColoredBox {} {color: 170}',
    );
    expect(
      (runtime.build(
        tester.element(find.byType(Container)),
        const FullyQualifiedWidgetName(LibraryName(<String>['test']), 'stateful'),
        data,
        (String eventName, DynamicMap eventArguments) {},
      ) as dynamic).curriedWidget.toString(),
      'test:stateful {test: false} {} = core:ColoredBox {} {color: 187}',
    );
    expect(
      (runtime.build(
        tester.element(find.byType(Container)),
        const FullyQualifiedWidgetName(LibraryName(<String>['test']), 'switchy'),
        data,
        (String eventName, DynamicMap eventArguments) {},
      ) as dynamic).curriedWidget.toString(),
      'test:switchy {} {} = switch true {null: core:ColoredBox {} {color: 204}}',
    );
  });

  testWidgets('state setting', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['core']), createCoreWidgets());
    final DynamicContent data = DynamicContent();
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['test']), 'root'),
      ),
    );
    expect(tester.takeException().toString(), contains('Could not find remote widget named'));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root { a: 0 } = GestureDetector(
        onTap: set state.b = 0,
        child: ColoredBox(),
      );
    '''));
    await tester.pump();
    await tester.tap(find.byType(ColoredBox));
    expect(tester.takeException().toString(), 'b does not identify existing state.');

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root { a: 0 } = GestureDetector(
        onTap: set state.0 = 0,
        child: ColoredBox(),
      );
    '''));
    await tester.pump();
    await tester.tap(find.byType(ColoredBox));
    expect(tester.takeException().toString(), '0 does not identify existing state.');

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root { a: [] } = GestureDetector(
        onTap: set state.a.b = 0,
        child: ColoredBox(),
      );
    '''));
    await tester.pump();
    await tester.tap(find.byType(ColoredBox));
    expect(tester.takeException().toString(), 'a.b does not identify existing state.');

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root { a: [] } = GestureDetector(
        onTap: set state.a.0 = 0,
        child: ColoredBox(),
      );
    '''));
    await tester.pump();
    await tester.tap(find.byType(ColoredBox));
    expect(tester.takeException().toString(), 'a.0 does not identify existing state.');

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root { a: true } = GestureDetector(
        onTap: set state.a.0 = 0,
        child: ColoredBox(),
      );
    '''));
    await tester.pump();
    await tester.tap(find.byType(ColoredBox));
    expect(tester.takeException().toString(), 'a.0 does not identify existing state.');

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root { a: true } = GestureDetector(
        onTap: set state.a.b = 0,
        child: ColoredBox(),
      );
    '''));
    await tester.pump();
    await tester.tap(find.byType(ColoredBox));
    expect(tester.takeException().toString(), 'a.b does not identify existing state.');

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root { a: { b: 0 } } = GestureDetector(
        onTap: set state.a = 15,
        child: ColoredBox(color: state.a),
      );
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0xFF000000));
    await tester.tap(find.byType(ColoredBox));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0x0000000F));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root { a: [ 0 ] } = GestureDetector(
        onTap: set state.a = 10,
        child: ColoredBox(color: state.a),
      );
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0xFF000000));
    await tester.tap(find.byType(ColoredBox));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0x0000000A));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      widget root { a: [ [ 1 ] ] } = GestureDetector(
        onTap: set state.a.0.0 = 11,
        child: ColoredBox(color: state.a.0.0),
      );
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0x00000001));
    await tester.tap(find.byType(ColoredBox));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0x0000000B));
  });

  testWidgets('DataSource', (WidgetTester tester) async {
    final Runtime runtime = Runtime();
    final DynamicContent data = DynamicContent();
    final List<String> eventLog = <String>[];
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['remote']), 'test'),
        onEvent: (String name, DynamicMap arguments) {
          eventLog.add('$name $arguments');
        },
      ),
    );
    expect(tester.takeException().toString(), contains('Could not find remote widget named'));

    runtime.update(const LibraryName(<String>['local']), LocalWidgetLibrary(<String, LocalWidgetBuilder>{
      'Test': (BuildContext context, DataSource source) {
        expect(source.isList(<Object>['a']), isFalse);
        expect(source.isList(<Object>['b']), isTrue);
        expect(source.length(<Object>['b']), 1);
        expect(source.child(<Object>['missing']), isA<ErrorWidget>());
        expect(tester.takeException().toString(), 'Not a widget at [missing] (got <missing>) for local:Test.');
        expect(source.childList(<Object>['a']), <Matcher>[isA<ErrorWidget>()]);
        expect(tester.takeException().toString(), 'Not a widget list at [a] (got 0) for local:Test.');
        expect(source.childList(<Object>['b']), <Matcher>[isA<ErrorWidget>()]);
        expect(tester.takeException().toString(), 'Not a widget at [b] (got 1) for local:Test.');
        expect(eventLog, isEmpty);
        source.voidHandler(<Object>['callback'], <String, Object?>{ 'extra': 4, 'b': 3 })!();
        expect(eventLog, <String>['e {a: 1, b: 3, extra: 4}']);
        return const ColoredBox(color: Color(0xAABBCCDD));
      },
    }));
    runtime.update(const LibraryName(<String>['remote']), parseLibraryFile('''
      import local;
      widget test = Test(a: 0, b: [1], callback: event 'e' { a: 1, b: 2 });
    '''));
    await tester.pump();
    expect(tester.widget<ColoredBox>(find.byType(ColoredBox)).color, const Color(0xAABBCCDD));
    bool tested = false;
    tester.element(find.byType(ColoredBox)).visitAncestorElements((Element node) {
      expect(node.toString(), equalsIgnoringHashCodes('_Widget(state: _WidgetState#00000(name: "local:Test"))'));
      tested = true;
      return false;
    });
    expect(tested, isTrue);
  });
}
