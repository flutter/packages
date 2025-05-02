// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is hand-formatted.
// ignore_for_file: use_raw_strings, avoid_escaping_inner_quotes

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rfw/formats.dart';
import 'package:rfw/rfw.dart';

const String sourceFile = '''
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
  );''';

void main() {
  testWidgets('parseLibraryFile: source location tracking', (WidgetTester tester) async {
    final RemoteWidgetLibrary test = parseLibraryFile(sourceFile);
    expect(test.widgets.first.source, isNull);
  });

  testWidgets('parseLibraryFile: source location tracking', (WidgetTester tester) async {
    String extract(BlobNode node) => (node.source!.start.source as String).substring(node.source!.start.offset, node.source!.end.offset);
    // We use the actual source text as the sourceIdentifier to make it trivial to find the source contents.
    // In normal operation, the sourceIdentifier would be the file name or some similar object.
    final RemoteWidgetLibrary test = parseLibraryFile(sourceFile, sourceIdentifier: sourceFile);
    expect(extract(test.widgets.first), '''
widget verify { state: true } = switch args.value.c.0 {
    0xDD: ColoredBox(color: 0xFF0D0D0D),
    default: ColoredBox(color: args.value),
  };''');
    expect(extract((test.widgets.first.root as Switch).input as ArgsReference), 'args.value.c.0');
  });

  testWidgets('Runtime: source location tracking', (WidgetTester tester) async {
    String extract(BlobNode node) {
      if (node.source == null) {
        printOnFailure('This node had no source information: ${node.runtimeType} $node');
      }
      return (node.source!.start.source as String).substring(node.source!.start.offset, node.source!.end.offset);
    }
    final Runtime runtime = Runtime()
      ..update(const LibraryName(<String>['core']), createCoreWidgets())
      // We use the actual source text as the sourceIdentifier to make it trivial to find the source contents.
      // In normal operation, the sourceIdentifier would be the file name or some similar object.
      ..update(const LibraryName(<String>['test']), parseLibraryFile(sourceFile, sourceIdentifier: sourceFile));
    addTearDown(runtime.dispose);
    final DynamicContent data = DynamicContent(<String, Object?>{
      'list': <Object?>[
        <String, Object?>{
          'a': <String, Object?>{ 'b': 0xEE },
          'c': <Object?>[ 0xDD ],
        },
      ],
    });
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime,
        data: data,
        widget: const FullyQualifiedWidgetName(LibraryName(<String>['test']), 'root'),
        onEvent: (String eventName, DynamicMap eventArguments) {
          fail('unexpected event $eventName');
        },
      ),
    );
    expect(extract(Runtime.blobNodeFor(tester.firstElement(find.byType(ColoredBox)))!), 'ColoredBox(color: 0xFF0D0D0D)');
  });
}
