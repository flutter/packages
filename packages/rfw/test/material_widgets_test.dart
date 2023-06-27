// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rfw/formats.dart' show parseLibraryFile;
import 'package:rfw/rfw.dart';

// See Contributing section of README.md file.
final bool runGoldens = Platform.isLinux &&
    (!Platform.environment.containsKey('CHANNEL') ||
        Platform.environment['CHANNEL'] == 'master');

void main() {
  testWidgets('Material widgets', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['core']), createCoreWidgets())
      ..update(
          const LibraryName(<String>['material']), createMaterialWidgets());
    final DynamicContent data = DynamicContent();
    final List<String> eventLog = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: false),
        home: RemoteWidget(
          runtime: runtime,
          data: data,
          widget: const FullyQualifiedWidgetName(
              LibraryName(<String>['test']), 'root'),
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
    );
    await tester.tapAt(const Offset(20.0, 20.0));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await expectLater(
      find.byType(RemoteWidget),
      matchesGoldenFile('goldens/material_test.drawer.png'),
    );
  }, skip: !runGoldens);
}
