// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router_examples/extra_codec.dart' as example;

void main() {
  testWidgets('example works', (WidgetTester tester) async {
    await tester.pumpWidget(const example.MyApp());
    expect(find.text('The extra for this page is: null'), findsOneWidget);

    await tester.tap(find.text('Set extra to ComplexData1'));
    await tester.pumpAndSettle();
    expect(find.text('The extra for this page is: ComplexData1(data: data)'),
        findsOneWidget);

    await tester.tap(find.text('Set extra to ComplexData2'));
    await tester.pumpAndSettle();
    expect(find.text('The extra for this page is: ComplexData2(data: data)'),
        findsOneWidget);
  });

  test('invalid extra throws', () {
    const example.MyExtraCodec extraCodec = example.MyExtraCodec();
    const List<Object?> invalidValue = <Object?>['invalid'];

    expect(
      () => extraCodec.decode(invalidValue),
      throwsA(
        predicate(
          (Object? exception) =>
              exception is FormatException &&
              exception.message == 'Unable to parse input: $invalidValue',
        ),
      ),
    );
  });
}
