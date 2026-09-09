// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer_interceptor_ios/pointer_interceptor_ios.dart';

class TestApp extends StatefulWidget {
  const TestApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return TestAppState();
  }
}

class TestAppState extends State<TestApp> {
  String _buttonText = 'Test Button';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: PointerInterceptorIOS().buildWidget(
          child: GestureDetector(
            onTap: () => setState(() {
              _buttonText = 'Clicked';
            }),
            child: Text(_buttonText),
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Button remains clickable and is added to '
      'hierarchy after being wrapped in pointer interceptor', (WidgetTester tester) async {
    await tester.pumpWidget(const TestApp());
    await tester.tap(find.text('Test Button'));
    await tester.pump();
    expect(find.text('Clicked'), findsOneWidget);
  });
}
