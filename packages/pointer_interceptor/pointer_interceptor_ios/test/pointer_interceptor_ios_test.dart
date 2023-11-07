import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:pointer_interceptor_ios/pointer_interceptor_ios.dart';

final Completer<WebViewController> _controller = Completer<WebViewController>();

Widget boilerplate() {
  return MaterialApp(
      home: Scaffold(
        body: const DummyPlatformView(),
        floatingActionButton: FloatingActionButton(
            onPressed: () {  },
            child: PointerInterceptorIOSPlugin().buildWidget(child: child)),
      ));
}

/// Find the tests in the

void main() {
  testWidgets('Button remains clickable and is added to '
      'hierarchy after being wrapped in pointer interceptor', (WidgetTester tester) async {
        await tester.pumpWidget(boilerplate());
        await tester.pump();
// Test by adding a new html element when clicked?
      });
}