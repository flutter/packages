// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/src/go_router_error_page.dart';

import 'error_screen_helpers.dart';

void main() {
  testWidgets(
    'shows "page not found" by default',
    testPageNotFound(
      widget: widgetsAppBuilder(
        home: const GoRouterErrorScreen(null),
      ),
    ),
  );

  final Exception exception = Exception('Something went wrong!');
  testWidgets(
    'shows the exception message when provided',
    testPageShowsExceptionMessage(
      exception: exception,
      widget: widgetsAppBuilder(
        home: GoRouterErrorScreen(exception),
      ),
    ),
  );

  testWidgets(
    'clicking the button should redirect to /',
    testClickingTheButtonRedirectsToRoot(
      buttonFinder:
          find.byWidgetPredicate((Widget widget) => widget is GestureDetector),
      widget: widgetsAppBuilder(
        home: const GoRouterErrorScreen(null),
      ),
    ),
  );
}

Widget widgetsAppBuilder({required Widget home}) {
  return WidgetsApp(
    onGenerateRoute: (_) {
      return MaterialPageRoute<void>(
        builder: (BuildContext _) => home,
      );
    },
    color: Colors.white,
  );
}

class DummyStatefulWidget extends StatefulWidget {
  const DummyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<DummyStatefulWidget> createState() => _DummyStatefulWidgetState();
}

class _DummyStatefulWidgetState extends State<DummyStatefulWidget> {
  @override
  Widget build(BuildContext context) => Container();
}
