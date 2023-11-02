import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor_platform_interface/pointer_interceptor_platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:pointer_interceptor_ios/pointer_interceptor_ios.dart';

final Completer<WebViewController> _controller = Completer<WebViewController>();

class DummyPlatformView extends StatelessWidget {
  const DummyPlatformView({super.key});

  @override
  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
    const String viewType = 'dummy_platform_view';
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{};

    return UiKitView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}

Widget boilerplate() {
  return MaterialApp(
      home: Scaffold(
        body: const DummyPlatformView(),
        floatingActionButton: FloatingActionButton(
            onPressed: () {  },
            child: Container(
              child: PointerInterceptorIOSPlugin().buildWidget(child: Container()),
            )),
      ));
}

Future<void> injectTouchListener() async {
  final WebViewController controller = await _controller.future;
  controller.evaluateJavascript(
      "document.addEventListener('touchstart', (event) => { Log.postMessage(String(event)); }, true);");
}

void main() {
  testWidgets('Button remains clickable and is added to '
      'hierarchy after being wrapped in pointer interceptor', (WidgetTester tester) async {
        await tester.pumpWidget(boilerplate());
        await tester.pump();
// Test by adding a new html element when clicked?
      });
}