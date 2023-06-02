// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/src/information_provider.dart';

const String initialRoute = '/';
const String newRoute = '/new';

void main() {
  group('GoRouteInformationProvider', () {
    testWidgets('notifies its listeners when set by the app',
        (WidgetTester tester) async {
      late final GoRouteInformationProvider provider =
          GoRouteInformationProvider(
              initialLocation: initialRoute, initialExtra: null);
      provider.addListener(expectAsync0(() {}));
      provider.go(newRoute);
    });

    testWidgets('notifies its listeners when set by the platform',
        (WidgetTester tester) async {
      late final GoRouteInformationProvider provider =
          GoRouteInformationProvider(
              initialLocation: initialRoute, initialExtra: null);
      provider.addListener(expectAsync0(() {}));
      // TODO(chunhtai): remove this ignore and migrate the code
      // https://github.com/flutter/flutter/issues/124045.
      // ignore_for_file: deprecated_member_use
      provider
          .didPushRouteInformation(const RouteInformation(location: newRoute));
    });
  });
}
