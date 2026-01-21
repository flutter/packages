// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/src/misc/error_screen.dart';

import 'helpers/error_screen_helpers.dart';

void main() {
  testWidgets(
    'shows "page not found" by default',
    testPageNotFound(widget: widgetsAppBuilder(home: const ErrorScreen(null))),
  );

  final exception = Exception('Something went wrong!');
  testWidgets(
    'shows the exception message when provided',
    testPageShowsExceptionMessage(
      exception: exception,
      widget: widgetsAppBuilder(home: ErrorScreen(exception)),
    ),
  );

  testWidgets(
    'clicking the button should redirect to /',
    testClickingTheButtonRedirectsToRoot(
      buttonFinder: find.byWidgetPredicate(
        (Widget widget) => widget is GestureDetector,
      ),
      widget: widgetsAppBuilder(home: const ErrorScreen(null)),
    ),
  );
}

Widget widgetsAppBuilder({required Widget home}) {
  return WidgetsApp(
    onGenerateRoute: (_) {
      return MaterialPageRoute<void>(builder: (BuildContext _) => home);
    },
    color: Colors.white,
  );
}
