// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:url_launcher_ios/src/messages.g.dart';
import 'package:url_launcher_ios/url_launcher_ios.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'url_launcher_ios_test.mocks.dart';

// A web URL to use in tests where the specifics of the URL don't matter.
const String _webUrl = 'https://example.com/';

@GenerateMocks(<Type>[UrlLauncherApi])
void main() {
  late MockUrlLauncherApi api;

  setUp(() {
    api = MockUrlLauncherApi();
  });

  test('registers instance', () {
    UrlLauncherIOS.registerWith();
    expect(UrlLauncherPlatform.instance, isA<UrlLauncherIOS>());
  });

  group('canLaunch', () {
    test('handles success', () async {
      when(
        api.canLaunchUrl(_webUrl),
      ).thenAnswer((_) async => LaunchResult.success);
      final launcher = UrlLauncherIOS(api: api);
      expect(await launcher.canLaunch(_webUrl), true);
    });

    test('handles failure', () async {
      when(
        api.canLaunchUrl(_webUrl),
      ).thenAnswer((_) async => LaunchResult.failure);
      final launcher = UrlLauncherIOS(api: api);
      expect(await launcher.canLaunch(_webUrl), false);
    });

    test('throws PlatformException for invalid URL', () async {
      when(
        api.canLaunchUrl(_webUrl),
      ).thenAnswer((_) async => LaunchResult.invalidUrl);
      final launcher = UrlLauncherIOS(api: api);
      await expectLater(
        launcher.canLaunch(_webUrl),
        throwsA(
          isA<PlatformException>().having(
            (PlatformException e) => e.code,
            'code',
            'argument_error',
          ),
        ),
      );
    });
  });

  group('legacy launch', () {
    test('handles success', () async {
      when(
        api.launchUrl(_webUrl, any),
      ).thenAnswer((_) async => LaunchResult.success);
      final launcher = UrlLauncherIOS(api: api);
      expect(
        await launcher.launch(
          _webUrl,
          useSafariVC: false,
          useWebView: false,
          enableJavaScript: false,
          enableDomStorage: false,
          universalLinksOnly: false,
          headers: const <String, String>{},
        ),
        true,
      );
      verifyNever(api.openUrlInSafariViewController(any));
    });

    test('handles failure', () async {
      when(
        api.launchUrl(_webUrl, any),
      ).thenAnswer((_) async => LaunchResult.failure);
      final launcher = UrlLauncherIOS(api: api);
      expect(
        await launcher.launch(
          _webUrl,
          useSafariVC: false,
          useWebView: false,
          enableJavaScript: false,
          enableDomStorage: false,
          universalLinksOnly: false,
          headers: const <String, String>{},
        ),
        false,
      );
      verifyNever(api.openUrlInSafariViewController(any));
    });

    test('throws PlatformException for invalid URL', () async {
      when(
        api.launchUrl(_webUrl, any),
      ).thenAnswer((_) async => LaunchResult.invalidUrl);
      final launcher = UrlLauncherIOS(api: api);
      await expectLater(
        launcher.launch(
          _webUrl,
          useSafariVC: false,
          useWebView: false,
          enableJavaScript: false,
          enableDomStorage: false,
          universalLinksOnly: false,
          headers: const <String, String>{},
        ),
        throwsA(
          isA<PlatformException>().having(
            (PlatformException e) => e.code,
            'code',
            'argument_error',
          ),
        ),
      );
    });

    test('force SafariVC is handled', () async {
      when(
        api.openUrlInSafariViewController(_webUrl),
      ).thenAnswer((_) async => InAppLoadResult.success);
      final launcher = UrlLauncherIOS(api: api);
      expect(
        await launcher.launch(
          _webUrl,
          useSafariVC: true,
          useWebView: false,
          enableJavaScript: false,
          enableDomStorage: false,
          universalLinksOnly: false,
          headers: const <String, String>{},
        ),
        true,
      );
      verifyNever(api.launchUrl(any, any));
    });

    test('universal links only is handled', () async {
      when(
        api.launchUrl(_webUrl, any),
      ).thenAnswer((_) async => LaunchResult.success);
      final launcher = UrlLauncherIOS(api: api);
      expect(
        await launcher.launch(
          _webUrl,
          useSafariVC: false,
          useWebView: false,
          enableJavaScript: false,
          enableDomStorage: false,
          universalLinksOnly: true,
          headers: const <String, String>{},
        ),
        true,
      );
      verifyNever(api.openUrlInSafariViewController(any));
    });

    test('disallowing SafariVC is handled', () async {
      when(
        api.launchUrl(_webUrl, any),
      ).thenAnswer((_) async => LaunchResult.success);
      final launcher = UrlLauncherIOS(api: api);
      expect(
        await launcher.launch(
          _webUrl,
          useSafariVC: false,
          useWebView: false,
          enableJavaScript: false,
          enableDomStorage: false,
          universalLinksOnly: false,
          headers: const <String, String>{},
        ),
        true,
      );
      verifyNever(api.openUrlInSafariViewController(any));
    });
  });

  test('closeWebView calls through', () async {
    final launcher = UrlLauncherIOS(api: api);
    await launcher.closeWebView();
    verify(api.closeSafariViewController()).called(1);
  });

  group('launch without webview', () {
    test('calls through', () async {
      when(
        api.launchUrl(_webUrl, any),
      ).thenAnswer((_) async => LaunchResult.success);
      final launcher = UrlLauncherIOS(api: api);
      final bool launched = await launcher.launchUrl(
        _webUrl,
        const LaunchOptions(mode: PreferredLaunchMode.externalApplication),
      );
      expect(launched, true);
      verifyNever(api.openUrlInSafariViewController(any));
    });

    test('throws PlatformException for invalid URL', () async {
      when(
        api.launchUrl(_webUrl, any),
      ).thenAnswer((_) async => LaunchResult.invalidUrl);
      final launcher = UrlLauncherIOS(api: api);
      await expectLater(
        launcher.launchUrl(
          _webUrl,
          const LaunchOptions(mode: PreferredLaunchMode.externalApplication),
        ),
        throwsA(
          isA<PlatformException>().having(
            (PlatformException e) => e.code,
            'code',
            'argument_error',
          ),
        ),
      );
    });
  });

  group('launch with Safari view controller', () {
    test('calls through with inAppWebView', () async {
      when(
        api.openUrlInSafariViewController(_webUrl),
      ).thenAnswer((_) async => InAppLoadResult.success);
      final launcher = UrlLauncherIOS(api: api);
      final bool launched = await launcher.launchUrl(
        _webUrl,
        const LaunchOptions(mode: PreferredLaunchMode.inAppWebView),
      );
      expect(launched, true);
      verifyNever(api.launchUrl(any, any));
    });

    test('calls through with inAppBrowserView', () async {
      when(
        api.openUrlInSafariViewController(_webUrl),
      ).thenAnswer((_) async => InAppLoadResult.success);
      final launcher = UrlLauncherIOS(api: api);
      final bool launched = await launcher.launchUrl(
        _webUrl,
        const LaunchOptions(mode: PreferredLaunchMode.inAppBrowserView),
      );
      expect(launched, true);
      verifyNever(api.launchUrl(any, any));
    });

    test('throws PlatformException for invalid URL', () async {
      when(
        api.openUrlInSafariViewController(_webUrl),
      ).thenAnswer((_) async => InAppLoadResult.invalidUrl);
      final launcher = UrlLauncherIOS(api: api);
      await expectLater(
        launcher.launchUrl(
          _webUrl,
          const LaunchOptions(mode: PreferredLaunchMode.inAppWebView),
        ),
        throwsA(
          isA<PlatformException>().having(
            (PlatformException e) => e.code,
            'code',
            'argument_error',
          ),
        ),
      );
    });

    test('throws PlatformException for missing view controller', () async {
      when(
        api.openUrlInSafariViewController(_webUrl),
      ).thenAnswer((_) async => InAppLoadResult.noUI);
      final launcher = UrlLauncherIOS(api: api);
      await expectLater(
        launcher.launchUrl(
          _webUrl,
          const LaunchOptions(mode: PreferredLaunchMode.inAppWebView),
        ),
        throwsA(
          isA<PlatformException>().having(
            (PlatformException e) => e.code,
            'code',
            'no_ui_available',
          ),
        ),
      );
    });

    test('throws PlatformException for load failure', () async {
      when(
        api.openUrlInSafariViewController(_webUrl),
      ).thenAnswer((_) async => InAppLoadResult.failedToLoad);
      final launcher = UrlLauncherIOS(api: api);
      await expectLater(
        launcher.launchUrl(
          _webUrl,
          const LaunchOptions(mode: PreferredLaunchMode.inAppWebView),
        ),
        throwsA(
          isA<PlatformException>().having(
            (PlatformException e) => e.code,
            'code',
            'Error',
          ),
        ),
      );
    });
  });

  group('launch with universal links', () {
    test('calls through', () async {
      when(
        api.launchUrl(_webUrl, any),
      ).thenAnswer((_) async => LaunchResult.success);
      final launcher = UrlLauncherIOS(api: api);
      final bool launched = await launcher.launchUrl(
        _webUrl,
        const LaunchOptions(
          mode: PreferredLaunchMode.externalNonBrowserApplication,
        ),
      );
      expect(launched, true);
      verifyNever(api.openUrlInSafariViewController(any));
    });

    test('throws PlatformException for invalid URL', () async {
      when(
        api.launchUrl(_webUrl, any),
      ).thenAnswer((_) async => LaunchResult.invalidUrl);
      final launcher = UrlLauncherIOS(api: api);
      await expectLater(
        launcher.launchUrl(
          _webUrl,
          const LaunchOptions(
            mode: PreferredLaunchMode.externalNonBrowserApplication,
          ),
        ),
        throwsA(
          isA<PlatformException>().having(
            (PlatformException e) => e.code,
            'code',
            'argument_error',
          ),
        ),
      );
    });
  });

  group('launch with platform default', () {
    test('uses Safari view controller for http', () async {
      const httpUrl = 'http://example.com/';
      when(
        api.openUrlInSafariViewController(httpUrl),
      ).thenAnswer((_) async => InAppLoadResult.success);
      final launcher = UrlLauncherIOS(api: api);
      final bool launched = await launcher.launchUrl(
        httpUrl,
        const LaunchOptions(),
      );
      expect(launched, true);
      verifyNever(api.launchUrl(any, any));
    });

    test('uses Safari view controller for https', () async {
      const httpsUrl = 'https://example.com/';
      when(
        api.openUrlInSafariViewController(httpsUrl),
      ).thenAnswer((_) async => InAppLoadResult.success);
      final launcher = UrlLauncherIOS(api: api);
      final bool launched = await launcher.launchUrl(
        httpsUrl,
        const LaunchOptions(),
      );
      expect(launched, true);
      verifyNever(api.launchUrl(any, any));
    });

    test('uses standard external for other schemes', () async {
      const nonWebUrl = 'supportedcustomscheme://example.com/';
      when(
        api.launchUrl(nonWebUrl, any),
      ).thenAnswer((_) async => LaunchResult.success);
      final launcher = UrlLauncherIOS(api: api);
      final bool launched = await launcher.launchUrl(
        nonWebUrl,
        const LaunchOptions(),
      );
      expect(launched, true);
      verifyNever(api.openUrlInSafariViewController(any));
    });
  });

  group('supportsMode', () {
    test('returns true for platformDefault', () async {
      final launcher = UrlLauncherIOS(api: api);
      expect(
        await launcher.supportsMode(PreferredLaunchMode.platformDefault),
        true,
      );
    });

    test('returns true for external application', () async {
      final launcher = UrlLauncherIOS(api: api);
      expect(
        await launcher.supportsMode(PreferredLaunchMode.externalApplication),
        true,
      );
    });

    test('returns true for external non-browser application', () async {
      final launcher = UrlLauncherIOS(api: api);
      expect(
        await launcher.supportsMode(
          PreferredLaunchMode.externalNonBrowserApplication,
        ),
        true,
      );
    });

    test('returns true for in app web view', () async {
      final launcher = UrlLauncherIOS(api: api);
      expect(
        await launcher.supportsMode(PreferredLaunchMode.inAppWebView),
        true,
      );
    });

    test('returns true for in app browser view', () async {
      final launcher = UrlLauncherIOS(api: api);
      expect(
        await launcher.supportsMode(PreferredLaunchMode.inAppBrowserView),
        true,
      );
    });
  });

  group('supportsCloseForMode', () {
    test('returns true for in app web view', () async {
      final launcher = UrlLauncherIOS(api: api);
      expect(
        await launcher.supportsCloseForMode(PreferredLaunchMode.inAppWebView),
        true,
      );
    });

    test('returns true for in app browser view', () async {
      final launcher = UrlLauncherIOS(api: api);
      expect(
        await launcher.supportsCloseForMode(
          PreferredLaunchMode.inAppBrowserView,
        ),
        true,
      );
    });

    test('returns false for other modes', () async {
      final launcher = UrlLauncherIOS(api: api);
      expect(
        await launcher.supportsCloseForMode(
          PreferredLaunchMode.externalApplication,
        ),
        false,
      );
      expect(
        await launcher.supportsCloseForMode(
          PreferredLaunchMode.externalNonBrowserApplication,
        ),
        false,
      );
    });
  });
}
