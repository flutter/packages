// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is hand-formatted.

// This file contains and briefly tests the snippets used in the README.md file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rfw/formats.dart';
import 'package:rfw/rfw.dart';

const Map<String, String> rawRemoteWidgetSnippets = <String, String>{
'root': '''
// #docregion root
import local;
widget root = GreenBox(
  child: Hello(name: "World"),
);
// #enddocregion root
''',

'fruit': '''
import local;
// #docregion fruit
widget fruit = Foo(
  bar: { quux: [ 'apple', 'banana', 'cherry' ] },
);
// #enddocregion fruit
''',

'example1': '''
import local;
// #docregion example1
widget example1 = GreenBox(
  child: Foo(
    bar: 'Jean',
  ),
);
// #enddocregion example1
''',

'example2': '''
import local;
// #docregion example2
widget example2 = GreenBox(
  child: Foo(
    bar: { name: 'Jean' },
  ),
);
// #enddocregion example2
''',

'example3': '''
import local;
// #docregion example3
widget example3 = GreenBox(
  child: Foo(
    text: ['apple', 'banana']
  ),
);
// #enddocregion example3
''',

'tap': '''
import local;
import core;
widget tap = GestureDetector(
  onTap: event 'test' { },
  child: SizedBox(),
);
''',

'tapDown': '''
import local;
import core;
widget tapDown = GestureDetector(
  onTapDown: event 'test' { },
  child: SizedBox(),
);
''',

'Shop': '''
// #docregion Shop
import core;

widget Shop = ListView(
  children: [
    Text(text: "Products:"),
    ...for product in data.server.games:
      Product(product: product)
  ],
);

widget Product = Text(text: args.product.name, softWrap: false, overflow: "fade");
// #enddocregion Shop
''',

'MaterialShop': '''
// #docregion MaterialShop
import core;
import material;

widget MaterialShop = Scaffold(
  appBar: AppBar(
    title: Text(text: ['Products']),
  ),
  body: ListView(
    children: [
      ...for product in data.server.games:
        Product(product: product)
    ],
  ),
);

widget Product = ListTile(
  title: Text(text: args.product.name),
  onTap: event 'shop.productSelect' { name: args.product.name, path: args.product.link },
);
// #enddocregion MaterialShop
''',
};

// The empty docregion at the end of the following causes the snippet to end with "// ...".
const String gameData =
'''
// #docregion game-data
{ "games": [
{"rating": 8.219, "users-rated": 16860, "name": "Twilight Struggle", "rank": 1, "link": "/boardgame/12333/twilight-struggle", "id": 12333},
{"rating": 8.093, "users-rated": 11750, "name": "Through the Ages: A Story of Civilization", "rank": 2, "link": "/boardgame/25613/through-ages-story-civilization", "id": 25613},
{"rating": 8.088, "users-rated": 34745, "name": "Agricola", "rank": 3, "link": "/boardgame/31260/agricola", "id": 31260},
{"rating": 8.082, "users-rated": 8913, "name": "Terra Mystica", "rank": 4, "link": "/boardgame/120677/terra-mystica", "id": 120677},
// #enddocregion game-data
// #docregion game-data
// #enddocregion game-data
] }
''';

List<WidgetLibrary> _createLocalWidgets(String region) {
  switch (region) {
    case 'root':
      return <WidgetLibrary>[LocalWidgetLibrary(<String, LocalWidgetBuilder>{
        // #docregion defaultLocalWidgets
        'GreenBox': (BuildContext context, DataSource source) {
          return ColoredBox(color: const Color(0xFF002211), child: source.child(<Object>['child']));
        },
        'Hello': (BuildContext context, DataSource source) {
          return Center(child: Text('Hello, ${source.v<String>(<Object>["name"])}!', textDirection: TextDirection.ltr));
        },
        // #enddocregion defaultLocalWidgets
      })];
    case 'fruit':
      return <WidgetLibrary>[
        LocalWidgetLibrary(<String, LocalWidgetBuilder>{
          // #docregion v
          'Foo': (BuildContext context, DataSource source) {
            return Text(source.v<String>(<Object>['bar', 'quux', 2])!);
          },
          // #enddocregion v
        }),
        LocalWidgetLibrary(<String, LocalWidgetBuilder>{
          // #docregion isList
          'Foo': (BuildContext context, DataSource source) {
            if (source.isList(<Object>['bar', 'quux'])) {
              return Text('${source.v<String>(<Object>['bar', 'quux', 2])}', textDirection: TextDirection.ltr);
            }
            return Text('${source.v<String>(<Object>['baz'])}', textDirection: TextDirection.ltr);
          },
          // #enddocregion isList
        }),
      ];
    case 'example1':
    case 'example2':
      return <WidgetLibrary>[LocalWidgetLibrary(<String, LocalWidgetBuilder>{
        // #docregion child
        'GreenBox': (BuildContext context, DataSource source) {
          return ColoredBox(color: const Color(0xFF002211), child: source.child(<Object>['child']));
        },
        // #enddocregion child
        // #docregion isMap
        'Foo': (BuildContext context, DataSource source) {
          if (source.isMap(<Object>['bar'])) {
            return Text('${source.v<String>(<Object>['bar', 'name'])}', textDirection: TextDirection.ltr);
          }
          return Text('${source.v<String>(<Object>['bar'])}', textDirection: TextDirection.ltr);
        },
        // #enddocregion isMap
      })];
    case 'example3':
      return <WidgetLibrary>[LocalWidgetLibrary(<String, LocalWidgetBuilder>{
        // #docregion optionalChild
        'GreenBox': (BuildContext context, DataSource source) {
          return ColoredBox(color: const Color(0xFF002211), child: source.optionalChild(<Object>['child']));
        },
        // #enddocregion optionalChild
        // #docregion length
        'Foo': (BuildContext context, DataSource source) {
          final int length = source.length(<Object>['text']);
          if (length > 0) {
            final StringBuffer text = StringBuffer();
            for (int index = 0; index < length; index += 1) {
              text.write(source.v<String>(<Object>['text', index]));
            }
            return Text(text.toString(), textDirection: TextDirection.ltr);
          }
          return const Text('<empty>', textDirection: TextDirection.ltr);
        },
        // #enddocregion length
      })];
    case 'tap':
      // #docregion onTap
      return <WidgetLibrary>[
        LocalWidgetLibrary(<String, LocalWidgetBuilder>{
          // The local widget is called `GestureDetector`...
          'GestureDetector': (BuildContext context, DataSource source) {
            // The local widget is implemented using the `GestureDetector`
            // widget from the Flutter framework.
            return GestureDetector(
              onTap: source.voidHandler(<Object>['onTap']),
              // A full implementation of a `GestureDetector` local widget
              // would have more arguments here, like `onTapDown`, etc.
              child: source.optionalChild(<Object>['child']),
            );
          },
        }),
      ];
      // #enddocregion onTap
    case 'tapDown':
      return <WidgetLibrary>[
        LocalWidgetLibrary(<String, LocalWidgetBuilder>{
          'GestureDetector': (BuildContext context, DataSource source) {
            // #docregion onTapDown
            return GestureDetector(
              onTapDown: source.handler(<Object>['onTapDown'], (HandlerTrigger trigger) => (TapDownDetails details) => trigger()),
              child: source.optionalChild(<Object>['child']),
            );
            // #enddocregion onTapDown
          },
        }),
        LocalWidgetLibrary(<String, LocalWidgetBuilder>{
          'GestureDetector': (BuildContext context, DataSource source) {
            // #docregion onTapDown-long
            return GestureDetector(
              // onTapDown expects a function that takes a TapDownDetails
              onTapDown: source.handler<GestureTapDownCallback>( // this returns a function that takes a TapDownDetails
                <Object>['onTapDown'],
                (HandlerTrigger trigger) { // "trigger" is the function that will send the event to RemoteWidget.onEvent
                  return (TapDownDetails details) { // this is the function that is returned by handler() above
                    trigger(); // the function calls "trigger"
                  };
                },
              ),
              child: source.optionalChild(<Object>['child']),
            );
            // #enddocregion onTapDown-long
          },
        }),
        LocalWidgetLibrary(<String, LocalWidgetBuilder>{
          'GestureDetector': (BuildContext context, DataSource source) {
            // #docregion onTapDown-position
            return GestureDetector(
              onTapDown: source.handler(<Object>['onTapDown'], (HandlerTrigger trigger) {
                return (TapDownDetails details) => trigger(<String, Object>{
                  'x': details.globalPosition.dx,
                  'y': details.globalPosition.dy,
                });
              }),
              child: source.optionalChild(<Object>['child']),
            );
            // #enddocregion onTapDown-position
          },
        }),
      ];
    case 'Shop':
    case 'MaterialShop':
      return <WidgetLibrary>[];
    default:
      fail('test has no defined local widgets for root widget "$region"');
  }
}

void main() {
  testWidgets('readme snippets', (WidgetTester tester) async {
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['core']), createCoreWidgets())
      ..update(const LibraryName(<String>['material']), createMaterialWidgets());
    addTearDown(runtime.dispose);
    final DynamicContent data = DynamicContent(parseDataFile(gameData));
    for (final String region in rawRemoteWidgetSnippets.keys) {
      final String body = rawRemoteWidgetSnippets[region]!;
      runtime.update(LibraryName(<String>[region]), parseLibraryFile(body));
    }
    for (final String region in rawRemoteWidgetSnippets.keys) {
      for (final WidgetLibrary localWidgets in _createLocalWidgets(region)) {
        await tester.pumpWidget(
          MaterialApp(
            home: RemoteWidget(
              runtime: runtime
                ..update(const LibraryName(<String>['local']), localWidgets),
              data: data,
              widget: FullyQualifiedWidgetName(LibraryName(<String>[region]), region),
            ),
          ),
        );
      }
    }
  });
}
