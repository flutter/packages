import 'package:flutter/material.dart';
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
    return MaterialApp(
        home: Scaffold(
      body: const Text('Body'),
      floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: PointerInterceptorIOSPlugin().buildWidget(
              child: TextButton(
            onPressed: () => setState(() {
              _buttonText = 'Clicked';
            }),
            child: Text(_buttonText),
          ))),
    ));
  }
}

void main() {
  testWidgets(
      'Button remains clickable and is added to '
      'hierarchy after being wrapped in pointer interceptor',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TestApp());
    await tester.tap(find.text('Test Button'));
    expect(find.text('Clicked'), findsOneWidget);
  });
}
