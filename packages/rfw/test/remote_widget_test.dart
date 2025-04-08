// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rfw/formats.dart' show parseLibraryFile;
import 'package:rfw/rfw.dart';

void main() {
  testWidgets('RemoteWidget', (WidgetTester tester) async {
    final Runtime runtime1 = Runtime()
      ..update(const LibraryName(<String>['core']), createCoreWidgets())
      ..update(const LibraryName(<String>['test']), parseLibraryFile('''
        import core;
        widget root = Placeholder();
      '''));
    addTearDown(runtime1.dispose);
    final Runtime runtime2 = Runtime()
      ..update(const LibraryName(<String>['core']), createCoreWidgets())
      ..update(const LibraryName(<String>['test']), parseLibraryFile('''
        import core;
        widget root = Container();
      '''));
    addTearDown(runtime2.dispose);
    final DynamicContent data = DynamicContent();
    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime1,
        data: data,
        widget: const FullyQualifiedWidgetName(
            LibraryName(<String>['test']), 'root'),
      ),
    );
    expect(find.byType(RemoteWidget), findsOneWidget);
    expect(find.byType(Placeholder), findsOneWidget);
    expect(find.byType(Container), findsNothing);

    await tester.pumpWidget(
      RemoteWidget(
        runtime: runtime2,
        data: data,
        widget: const FullyQualifiedWidgetName(
            LibraryName(<String>['test']), 'root'),
      ),
    );
    expect(find.byType(RemoteWidget), findsOneWidget);
    expect(find.byType(Placeholder), findsNothing);
    expect(find.byType(Container), findsOneWidget);
  });
}
