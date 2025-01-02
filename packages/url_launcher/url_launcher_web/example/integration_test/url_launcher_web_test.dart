// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart' show Mock, any, verify, when;
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:url_launcher_web/url_launcher_web.dart';
import 'package:web/web.dart' as html;

abstract class MyWindow {
  html.Window? open(Object? a, Object? b, Object? c);
  html.Navigator? get navigator;
}

@JSExport()
class MockWindow extends Mock implements MyWindow {}

abstract class MyNavigator {
  String? get userAgent;
}

@JSExport()
class MockNavigator extends Mock implements MyNavigator {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('UrlLauncherPlugin', () {
    late MockWindow mockWindow;
    late MockNavigator mockNavigator;
    late html.Window jsMockWindow;

    late UrlLauncherPlugin plugin;

    setUp(() {
      mockWindow = MockWindow();
      mockNavigator = MockNavigator();

      jsMockWindow = createJSInteropWrapper(mockWindow) as html.Window;
      final html.Navigator jsMockNavigator =
          createJSInteropWrapper(mockNavigator) as html.Navigator;

      when(mockWindow.navigator).thenReturn(jsMockNavigator);

      // Simulate that window.open does something.
      when(mockWindow.open(any, any, any)).thenReturn(jsMockWindow);

      when(mockNavigator.userAgent).thenReturn(
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36');

      plugin = UrlLauncherPlugin(debugWindow: jsMockWindow);
    });

    group('canLaunch', () {
      testWidgets('"http" URLs -> true', (WidgetTester _) async {
        expect(plugin.canLaunch('http://google.com'), completion(isTrue));
      });

      testWidgets('"https" URLs -> true', (WidgetTester _) async {
        expect(plugin.canLaunch('https://google.com'), completion(isTrue));
      });

      testWidgets('"mailto" URLs -> true', (WidgetTester _) async {
        expect(
            plugin.canLaunch('mailto:name@mydomain.com'), completion(isTrue));
      });

      testWidgets('"tel" URLs -> true', (WidgetTester _) async {
        expect(plugin.canLaunch('tel:5551234567'), completion(isTrue));
      });

      testWidgets('"sms" URLs -> true', (WidgetTester _) async {
        expect(plugin.canLaunch('sms:+19725551212?body=hello%20there'),
            completion(isTrue));
      });

      testWidgets('"javascript" URLs -> false', (WidgetTester _) async {
        expect(plugin.canLaunch('javascript:alert("1")'), completion(isFalse));
      });
    });

    group('launch', () {
      testWidgets('launching a URL returns true', (WidgetTester _) async {
        expect(
            plugin.launch(
              'https://www.google.com',
            ),
            completion(isTrue));
      });

      testWidgets('launching a "mailto" returns true', (WidgetTester _) async {
        expect(
            plugin.launch(
              'mailto:name@mydomain.com',
            ),
            completion(isTrue));
      });

      testWidgets('launching a "tel" returns true', (WidgetTester _) async {
        expect(
            plugin.launch(
              'tel:5551234567',
            ),
            completion(isTrue));
      });

      testWidgets('launching a "sms" returns true', (WidgetTester _) async {
        expect(
            plugin.launch(
              'sms:+19725551212?body=hello%20there',
            ),
            completion(isTrue));
      });

      testWidgets('launching a "javascript" returns false',
          (WidgetTester _) async {
        expect(plugin.launch('javascript:alert("1")'), completion(isFalse));
      });

      testWidgets('launching a unknown sceheme returns true',
          (WidgetTester _) async {
        expect(
            plugin.launch(
              'foo:bar',
            ),
            completion(isTrue));
      });
    });

    group('openNewWindow', () {
      testWidgets('http urls should be launched in a new window',
          (WidgetTester _) async {
        plugin.openNewWindow('http://www.google.com');

        verify(mockWindow.open(
            'http://www.google.com', '', 'noopener,noreferrer'));
      });

      testWidgets('https urls should be launched in a new window',
          (WidgetTester _) async {
        plugin.openNewWindow('https://www.google.com');

        verify(mockWindow.open(
            'https://www.google.com', '', 'noopener,noreferrer'));
      });

      testWidgets('mailto urls should be launched on a new window',
          (WidgetTester _) async {
        plugin.openNewWindow('mailto:name@mydomain.com');

        verify(mockWindow.open(
            'mailto:name@mydomain.com', '', 'noopener,noreferrer'));
      });

      testWidgets('tel urls should be launched on a new window',
          (WidgetTester _) async {
        plugin.openNewWindow('tel:5551234567');

        verify(mockWindow.open('tel:5551234567', '', 'noopener,noreferrer'));
      });

      testWidgets('sms urls should be launched on a new window',
          (WidgetTester _) async {
        plugin.openNewWindow('sms:+19725551212?body=hello%20there');

        verify(mockWindow.open(
            'sms:+19725551212?body=hello%20there', '', 'noopener,noreferrer'));
      });
      testWidgets(
          'setting webOnlyLinkTarget as _self opens the url in the same tab',
          (WidgetTester _) async {
        plugin.openNewWindow('https://www.google.com',
            webOnlyWindowName: '_self');
        verify(mockWindow.open(
            'https://www.google.com', '_self', 'noopener,noreferrer'));
      });

      testWidgets(
          'setting webOnlyLinkTarget as _blank opens the url in a new tab',
          (WidgetTester _) async {
        plugin.openNewWindow('https://www.google.com',
            webOnlyWindowName: '_blank');
        verify(mockWindow.open(
            'https://www.google.com', '_blank', 'noopener,noreferrer'));
      });

      group('Safari', () {
        setUp(() {
          when(mockNavigator.userAgent).thenReturn(
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5.1 Safari/605.1.15');
          // Recreate the plugin, so it grabs the overrides from this group
          plugin = UrlLauncherPlugin(debugWindow: jsMockWindow);
        });

        testWidgets('http urls should be launched in a new window',
            (WidgetTester _) async {
          plugin.openNewWindow('http://www.google.com');

          verify(mockWindow.open(
              'http://www.google.com', '', 'noopener,noreferrer'));
        });

        testWidgets('https urls should be launched in a new window',
            (WidgetTester _) async {
          plugin.openNewWindow('https://www.google.com');

          verify(mockWindow.open(
              'https://www.google.com', '', 'noopener,noreferrer'));
        });

        testWidgets('mailto urls should be launched on the same window',
            (WidgetTester _) async {
          plugin.openNewWindow('mailto:name@mydomain.com');

          verify(mockWindow.open(
              'mailto:name@mydomain.com', '_top', 'noopener,noreferrer'));
        });

        testWidgets('tel urls should be launched on the same window',
            (WidgetTester _) async {
          plugin.openNewWindow('tel:5551234567');

          verify(
              mockWindow.open('tel:5551234567', '_top', 'noopener,noreferrer'));
        });

        testWidgets('sms urls should be launched on the same window',
            (WidgetTester _) async {
          plugin.openNewWindow('sms:+19725551212?body=hello%20there');

          verify(mockWindow.open('sms:+19725551212?body=hello%20there', '_top',
              'noopener,noreferrer'));
        });
        testWidgets(
            'mailto urls should use _blank if webOnlyWindowName is set as _blank',
            (WidgetTester _) async {
          plugin.openNewWindow('mailto:name@mydomain.com',
              webOnlyWindowName: '_blank');
          verify(mockWindow.open(
              'mailto:name@mydomain.com', '_blank', 'noopener,noreferrer'));
        });
      });
    });

    group('supportsMode', () {
      testWidgets('returns true for platformDefault', (WidgetTester _) async {
        expect(plugin.supportsMode(PreferredLaunchMode.platformDefault),
            completion(isTrue));
      });

      testWidgets('returns false for other modes', (WidgetTester _) async {
        expect(plugin.supportsMode(PreferredLaunchMode.externalApplication),
            completion(isFalse));
        expect(
            plugin.supportsMode(
                PreferredLaunchMode.externalNonBrowserApplication),
            completion(isFalse));
        expect(plugin.supportsMode(PreferredLaunchMode.inAppBrowserView),
            completion(isFalse));
        expect(plugin.supportsMode(PreferredLaunchMode.inAppWebView),
            completion(isFalse));
      });
    });

    testWidgets('supportsCloseForMode returns false', (WidgetTester _) async {
      expect(plugin.supportsCloseForMode(PreferredLaunchMode.platformDefault),
          completion(isFalse));
    });
  });
}
