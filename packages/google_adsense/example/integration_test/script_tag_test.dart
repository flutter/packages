// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_adsense/google_adsense.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web/web.dart' as web;

const String testClient = 'test_client';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // We test this separately so we don't have to worry about removing the script
  // from the page. Tests in `ad_widget_test.dart` use overrides in `initialize`
  // to keep them self-contained.
  group('JS initialization', () {
    testWidgets('Initialization adds AdSense snippet.', (WidgetTester _) async {
      // Given
      const String expectedScriptUrl =
          'https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-$testClient';

      // When (using the singleton adSense from the plugin)
      await adSense.initialize(testClient);

      // Then
      final web.HTMLScriptElement? injected =
          web.document.head?.lastElementChild as web.HTMLScriptElement?;

      expect(injected, isNotNull);
      expect(injected!.src, expectedScriptUrl);
      expect(injected.crossOrigin, 'anonymous');
      expect(injected.async, true);
    });
  });
}
