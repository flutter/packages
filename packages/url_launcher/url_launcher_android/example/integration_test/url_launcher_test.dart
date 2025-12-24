// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('canLaunch', (WidgetTester _) async {
    final UrlLauncherPlatform launcher = UrlLauncherPlatform.instance;

    expect(await launcher.canLaunch('randomstring'), false);

    // Generally all devices should have some default browser.
    expect(await launcher.canLaunch('http://flutter.dev'), true);

    // sms:, tel:, and mailto: links may not be openable on every device, so
    // aren't tested here.
  });

  testWidgets('launch and close', (WidgetTester _) async {
    final UrlLauncherPlatform launcher = UrlLauncherPlatform.instance;

    // Setup fake http server.
    final HttpServer server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    unawaited(
      server.forEach((HttpRequest request) {
        if (request.uri.path == '/hello.txt') {
          request.response.writeln('Hello, world.');
        } else {
          fail('unexpected request: ${request.method} ${request.uri}');
        }
        request.response.close();
      }),
    );
    // Https to avoid cleartext warning on android.
    final prefixUrl = 'https://${server.address.address}:${server.port}';
    final primaryUrl = '$prefixUrl/hello.txt';

    // Launch a url then close.
    expect(
      await launcher.launch(
        primaryUrl,
        useSafariVC: true,
        useWebView: true,
        enableJavaScript: false,
        enableDomStorage: false,
        universalLinksOnly: false,
        headers: <String, String>{},
      ),
      true,
    );
    await launcher.closeWebView();
    // Delay required to catch android side crashes in onDestroy.
    //
    // If this test flakes with an android crash during this delay the test
    // should be considered failing because this integration test can have a
    // false positive pass if the test closes before an onDestroy crash.
    // See https://github.com/flutter/flutter/issues/126460 for more info.
    await Future<void>.delayed(const Duration(seconds: 5));
  });
}
