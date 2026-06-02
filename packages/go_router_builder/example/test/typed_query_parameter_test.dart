// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_builder_example/typed_query_parameter_example.dart';

void main() {
  testWidgets('It should increase the counts when pressed', (tester) async {
    await tester.pumpWidget(App());

    expect(
      find.text('null'),
      findsExactly(2),
      reason: 'intField and intFieldWithSpace are both null',
    );
    expect(find.text('1'), findsOne);

    await tester.tap(find.text('intField:'));
    await tester.pumpAndSettle();
    expect(
      find.text('1'),
      findsExactly(2),
      reason: 'intField and intFieldWithDefaultValue are both 1',
    );
    expect(find.text('null'), findsOne);

    await tester.tap(find.text('intFieldWithDefaultValue:'));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOne);
    expect(find.text('2'), findsOne);
    expect(find.text('null'), findsOne);

    await tester.tap(find.text('intFieldWithSpace:'));
    await tester.pumpAndSettle();
    expect(
      find.text('1'),
      findsExactly(2),
      reason: 'intField and intFieldWithSpace are both 1',
    );
    expect(find.text('2'), findsOne);
  });

  testWidgets('It should modify the custom fields when tapped', (tester) async {
    await tester.pumpWidget(App());

    expect(find.text('customField:'), findsOne);
    expect(find.text('customFieldWithDefaultValue:'), findsOne);

    expect(find.text('default,0'), findsOne);

    await tester.tap(find.text('customField:'));
    await tester.pumpAndSettle();
    expect(find.text('-,1'), findsOne);
    expect(find.text('default,0'), findsOne);

    await tester.tap(find.text('customFieldWithDefaultValue:'));
    await tester.pumpAndSettle();
    expect(find.text('-,1'), findsOne);
    expect(find.text('default-,1'), findsOne);
  });
}
