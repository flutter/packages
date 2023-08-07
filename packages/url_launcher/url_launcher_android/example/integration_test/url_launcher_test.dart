// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

    // Launch a url then close.
    expect(
        await launcher.launch('https://flutter.dev',
            useSafariVC: true,
            useWebView: true,
            enableJavaScript: false,
            enableDomStorage: false,
            universalLinksOnly: false,
            headers: <String, String>{'my_header_key': 'my_header_value'}),
        true);
    // Allow time for page to load.
    await Future.delayed(Duration(seconds: 3));
    await launcher.closeWebView();
    // Delay required to catch android side crashes in onDestroy
    await Future.delayed(Duration(seconds: 3));

    // sms:, tel:, and mailto: links may not be openable on every device, so
    // aren't tested here.
  });
}
