// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rfw/formats.dart' show parseLibraryFile;
import 'package:rfw/rfw.dart';

import 'utils.dart';

void main() {
  const LibraryName coreName = LibraryName(<String>['core']);
  const LibraryName materialName = LibraryName(<String>['material']);
  const LibraryName testName = LibraryName(<String>['test']);

  Runtime setupRuntime() {
    return Runtime()
      ..update(coreName, createCoreWidgets())
      ..update(materialName, createMaterialWidgets());
  }

  testWidgets('Material widgets', (WidgetTester tester) async {
    final Runtime runtime = setupRuntime();
    final DynamicContent data = DynamicContent();
    final List<String> eventLog = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: false),
        home: RemoteWidget(
          runtime: runtime,
          data: data,
          widget: const FullyQualifiedWidgetName(testName, 'root'),
          onEvent: (String eventName, DynamicMap eventArguments) {
            eventLog.add('$eventName $eventArguments');
          },
        ),
      ),
    );
    expect(tester.takeException().toString(),
        contains('Could not find remote widget named'));

    runtime.update(const LibraryName(<String>['test']), parseLibraryFile('''
      import core;
      import material;
      widget root = Scaffold(
        appBar: AppBar(
          title: Text(text: 'Title'),
          flexibleSpace: Placeholder(),
          bottom: SizedBox(height: 56.0, child: Placeholder()),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(),
              ListTile(
                visualDensity: 'adaptivePlatformDensity',
                title: Text(text: 'title'),
                subtitle: Text(text: 'title'),
              ),
              ListTile(
                visualDensity: 'comfortable',
                title: Text(text: 'title'),
                subtitle: Text(text: 'title'),
              ),
              ListTile(
                visualDensity: 'compact',
                title: Text(text: 'title'),
                subtitle: Text(text: 'title'),
              ),
              ListTile(
                visualDensity: 'standard',
                title: Text(text: 'title'),
                subtitle: Text(text: 'title'),
              ),
              ListTile(
                visualDensity: { horizontal: -4.0, vertical: 4.0 },
                title: Text(text: 'title'),
                subtitle: Text(text: 'title'),
              ),
              AboutListTile(),
            ],
          ),
        ),
        body: ListView(
          children: [
            Card(
              margin: [20.0],
              child: ListBody(
                children: [
                  ButtonBar(
                    children: [
                      ElevatedButton(
                        onPressed: event 'button' { },
                        child: Text(text: 'Elevated'),
                      ),
                      OutlinedButton(
                        onPressed: event 'button' { },
                        child: Text(text: 'Outlined'),
                      ),
                      TextButton(
                        onPressed: event 'button' { },
                        child: Text(text: 'Text'),
                      ),
                      VerticalDivider(),
                      InkWell(
                        child: Text(text: 'Ink'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: [20.0],
              child: Center(
                child: CircularProgressIndicator(
                  value: 0.6,
                ),
              ),
            ),
            Divider(),
            Padding(
              padding: [20.0],
              child: Center(
                child: LinearProgressIndicator(
                  value: 0.6,
                ),
              ),
            ),
            Divider(),
            Padding(
              padding: [20.0],
              child: Row(
                mainAxisAlignment: 'spaceEvenly',
                children: [
                  DropdownButton(
                    value: 'foo',
                    elevation: 14,
                    dropdownColor: 0xFF9E9E9E,
                    underline: Container(
                      height: 2,
                      color: 0xFF7C4DFF,
                    ),
                    style: {
                      color:0xFF7C4DFF,
                    },
                    items: [
                      {
                        value: 'foo',
                        child: Text(text: 'foo'),
                      },
                      {
                        value: 'bar',
                        child: Text(text: 'bar'),
                        onTap: event 'menu_item' { args: 'bar' },
                      },
                    ],
                    borderRadius:[{x: 8.0, y: 8.0}, {x: 8.0, y: 8.0}, {x: 8.0, y: 8.0}, {x: 8.0, y: 8.0}],
                    onChanged: event 'dropdown' {},
                  ),
                  DropdownButton(
                    value: 1.0,
                    items: [
                      {
                        value: 1.0,
                        child: Text(text: 'first'),
                      },
                      {
                        value: 2.0,
                        child: Text(text: 'second'),
                        onTap: event 'menu_item' { args: 'second' },
                      },
                    ],
                    onChanged: event 'dropdown' {},
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: event 'fab' {},
          child: Placeholder(),
        ),
      );
    '''));
    await tester.pump();
    await expectLater(
      find.byType(RemoteWidget),
      matchesGoldenFile('goldens/material_test.scaffold.png'),
      skip: !runGoldens,
    );

    await tester.tap(find.byType(DropdownButton<Object>).first);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/material_test.dropdown.png'),
      skip: !runGoldens,
    );
    // Tap on the second item.
    await tester.tap(find.text('bar'));
    await tester.pumpAndSettle();
    expect(eventLog, contains('menu_item {args: bar}'));
    expect(eventLog, contains('dropdown {value: bar}'));

    await tester.tap(find.byType(DropdownButton<Object>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('second'));
    await tester.pumpAndSettle();
    expect(eventLog, contains('menu_item {args: second}'));
    expect(eventLog,
        contains(kIsWeb ? 'dropdown {value: 2}' : 'dropdown {value: 2.0}'));

    await tester.tapAt(const Offset(20.0, 20.0));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await expectLater(
      find.byType(RemoteWidget),
      matchesGoldenFile('goldens/material_test.drawer.png'),
      skip: !runGoldens,
    );
  });

  testWidgets('OverflowBar configured to resemble ButtonBar',
      (WidgetTester tester) async {
    final Runtime runtime = setupRuntime();
    final DynamicContent data = DynamicContent();
    final List<String> eventLog = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: false),
        home: RemoteWidget(
          runtime: runtime,
          data: data,
          widget: const FullyQualifiedWidgetName(testName, 'root'),
          onEvent: (String eventName, DynamicMap eventArguments) {
            eventLog.add('$eventName $eventArguments');
          },
        ),
      ),
    );
    expect(tester.takeException().toString(),
        contains('Could not find remote widget named'));

    runtime.update(testName, parseLibraryFile('''
      import core;
      import material;
      widget root = Scaffold(
        body: Card(
          margin: [20.0],
          child: Padding(
            padding: [8.0],
            child: OverflowBar(
              spacing: 8.0,
              children: [
                ElevatedButton(
                  onPressed: event 'button' { },
                  child: Text(text: 'Elevated'),
                ),
                OutlinedButton(
                  onPressed: event 'button' { },
                  child: Text(text: 'Outlined'),
                ),
                TextButton(
                  onPressed: event 'button' { },
                  child: Text(text: 'Text'),
                ),
              ],
            ),
          ),
        ),
      );
    '''));
    await tester.pump();
    await expectLater(
      find.byType(RemoteWidget),
      matchesGoldenFile(
          'goldens/material_test.overflow_bar_resembles_button_bar.png'),
      skip: !runGoldens,
    );
  });

  testWidgets('Implement OverflowBar properties', (WidgetTester tester) async {
    final Runtime runtime = setupRuntime();
    final DynamicContent data = DynamicContent();
    final List<String> eventLog = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: false),
        home: RemoteWidget(
          runtime: runtime,
          data: data,
          widget: const FullyQualifiedWidgetName(testName, 'root'),
          onEvent: (String eventName, DynamicMap eventArguments) {
            eventLog.add('$eventName $eventArguments');
          },
        ),
      ),
    );
    expect(tester.takeException().toString(),
        contains('Could not find remote widget named'));

    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    runtime.update(testName, parseLibraryFile('''
      import core;
      import material;
      widget root = Scaffold(
        body: Center(
          child: OverflowBar(
            spacing: 16.0,
            alignment: 'end',
            overflowSpacing: 4.0,
            overflowAlignment: 'center',
            overflowDirection: 'up',
            children: [
              ElevatedButton(
                onPressed: event 'button' { },
                child: Text(text: 'Elevated'),
              ),
              OutlinedButton(
                onPressed: event 'button' { },
                child: Text(text: 'Outlined'),
              ),
              TextButton(
                onPressed: event 'button' { },
                child: Text(text: 'Text'),
              ),
            ],
          ),
        ),
      );
    '''));
    await tester.pump();

    await expectLater(
      find.byType(RemoteWidget),
      matchesGoldenFile('goldens/material_test.overflow_bar_properties.png'),
      skip: !runGoldens,
    );

    // Update the surface size for OverflowBar to overflow.
    await tester.binding.setSurfaceSize(const Size(200.0, 600.0));
    await tester.pump();

    await expectLater(
      find.byType(RemoteWidget),
      matchesGoldenFile(
          'goldens/material_test.overflow_bar_properties.overflow.png'),
      skip: !runGoldens,
    );
  });
}
