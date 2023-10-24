// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_ios/src/messages.g.dart';
import 'package:url_launcher_ios/url_launcher_ios.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeUrlLauncherApi api;

  setUp(() {
    api = _FakeUrlLauncherApi();
  });

  test('registers instance', () {
    UrlLauncherIOS.registerWith();
    expect(UrlLauncherPlatform.instance, isA<UrlLauncherIOS>());
  });

  group('canLaunch', () {
    test('handles success', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      expect(await launcher.canLaunch('http://example.com/'), true);
    });

    test('handles failure', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      expect(await launcher.canLaunch('unknown://scheme'), false);
    });

    test('passes invalid URL PlatformException through', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      await expectLater(launcher.canLaunch('invalid://u r l'),
          throwsA(isA<PlatformException>()));
    });
  });

  group('legacy launch', () {
    test('handles success', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      expect(
          await launcher.launch(
            'http://example.com/',
            useSafariVC: false,
            useWebView: false,
            enableJavaScript: false,
            enableDomStorage: false,
            universalLinksOnly: false,
            headers: const <String, String>{},
          ),
          true);
      expect(api.passedUniversalLinksOnly, false);
    });

    test('handles failure', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      expect(
          await launcher.launch(
            'unknown://scheme',
            useSafariVC: false,
            useWebView: false,
            enableJavaScript: false,
            enableDomStorage: false,
            universalLinksOnly: false,
            headers: const <String, String>{},
          ),
          false);
      expect(api.passedUniversalLinksOnly, false);
    });

    test('passes invalid URL PlatformException through', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      await expectLater(
          launcher.launch(
            'invalid://u r l',
            useSafariVC: false,
            useWebView: false,
            enableJavaScript: false,
            enableDomStorage: false,
            universalLinksOnly: false,
            headers: const <String, String>{},
          ),
          throwsA(isA<PlatformException>()));
    });

    test('force SafariVC is handled', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      expect(
          await launcher.launch(
            'http://example.com/',
            useSafariVC: true,
            useWebView: false,
            enableJavaScript: false,
            enableDomStorage: false,
            universalLinksOnly: false,
            headers: const <String, String>{},
          ),
          true);
      expect(api.usedSafariViewController, true);
    });

    test('universal links only is handled', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      expect(
          await launcher.launch(
            'http://example.com/',
            useSafariVC: false,
            useWebView: false,
            enableJavaScript: false,
            enableDomStorage: false,
            universalLinksOnly: true,
            headers: const <String, String>{},
          ),
          true);
      expect(api.passedUniversalLinksOnly, true);
    });

    test('disallowing SafariVC is handled', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      expect(
          await launcher.launch(
            'http://example.com/',
            useSafariVC: false,
            useWebView: false,
            enableJavaScript: false,
            enableDomStorage: false,
            universalLinksOnly: false,
            headers: const <String, String>{},
          ),
          true);
      expect(api.usedSafariViewController, false);
    });
  });

  test('closeWebView calls through', () async {
    final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
    await launcher.closeWebView();
    expect(api.closed, true);
  });

  group('launch without webview', () {
    test('calls through', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      final bool launched = await launcher.launchUrl(
        'http://example.com/',
        const LaunchOptions(mode: PreferredLaunchMode.externalApplication),
      );
      expect(launched, true);
      expect(api.usedSafariViewController, false);
    });

    test('passes invalid URL PlatformException through', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      await expectLater(
          launcher.launchUrl('invalid://u r l', const LaunchOptions()),
          throwsA(isA<PlatformException>()));
    });
  });

  group('launch with Safari view controller', () {
    test('calls through with inAppWebView', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      final bool launched = await launcher.launchUrl('http://example.com/',
          const LaunchOptions(mode: PreferredLaunchMode.inAppWebView));
      expect(launched, true);
      expect(api.usedSafariViewController, true);
    });

    test('calls through with inAppBrowserView', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      final bool launched = await launcher.launchUrl('http://example.com/',
          const LaunchOptions(mode: PreferredLaunchMode.inAppBrowserView));
      expect(launched, true);
      expect(api.usedSafariViewController, true);
    });

    test('passes invalid URL PlatformException through', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      await expectLater(
          launcher.launchUrl('invalid://u r l',
              const LaunchOptions(mode: PreferredLaunchMode.inAppWebView)),
          throwsA(isA<PlatformException>()));
    });
  });

  group('launch with universal links', () {
    test('calls through', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      final bool launched = await launcher.launchUrl(
        'http://example.com/',
        const LaunchOptions(
            mode: PreferredLaunchMode.externalNonBrowserApplication),
      );
      expect(launched, true);
      expect(api.usedSafariViewController, false);
      expect(api.passedUniversalLinksOnly, true);
    });

    test('passes invalid URL PlatformException through', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      await expectLater(
          launcher.launchUrl(
              'invalid://u r l',
              const LaunchOptions(
                  mode: PreferredLaunchMode.externalNonBrowserApplication)),
          throwsA(isA<PlatformException>()));
    });
  });

  group('launch with platform default', () {
    test('uses Safari view controller for http', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      final bool launched = await launcher.launchUrl(
          'http://example.com/', const LaunchOptions());
      expect(launched, true);
      expect(api.usedSafariViewController, true);
    });

    test('uses Safari view controller for https', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      final bool launched = await launcher.launchUrl(
          'https://example.com/', const LaunchOptions());
      expect(launched, true);
      expect(api.usedSafariViewController, true);
    });

    test('uses standard external for other schemes', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      final bool launched = await launcher.launchUrl(
          'supportedcustomscheme://example.com/', const LaunchOptions());
      expect(launched, true);
      expect(api.usedSafariViewController, false);
      expect(api.passedUniversalLinksOnly, false);
    });
  });

  group('supportsMode', () {
    test('returns true for platformDefault', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      expect(await launcher.supportsMode(PreferredLaunchMode.platformDefault),
          true);
    });

    test('returns true for external application', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      expect(
          await launcher.supportsMode(PreferredLaunchMode.externalApplication),
          true);
    });

    test('returns true for external non-browser application', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      expect(
          await launcher
              .supportsMode(PreferredLaunchMode.externalNonBrowserApplication),
          true);
    });

    test('returns true for in app web view', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      expect(
          await launcher.supportsMode(PreferredLaunchMode.inAppWebView), true);
    });

    test('returns true for in app browser view', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      expect(await launcher.supportsMode(PreferredLaunchMode.inAppBrowserView),
          true);
    });
  });

  group('supportsCloseForMode', () {
    test('returns true for in app web view', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      expect(
          await launcher.supportsCloseForMode(PreferredLaunchMode.inAppWebView),
          true);
    });

    test('returns true for in app browser view', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      expect(
          await launcher
              .supportsCloseForMode(PreferredLaunchMode.inAppBrowserView),
          true);
    });

    test('returns false for other modes', () async {
      final UrlLauncherIOS launcher = UrlLauncherIOS(api: api);
      expect(
          await launcher
              .supportsCloseForMode(PreferredLaunchMode.externalApplication),
          false);
      expect(
          await launcher.supportsCloseForMode(
              PreferredLaunchMode.externalNonBrowserApplication),
          false);
    });
  });
}

/// A fake implementation of the host API that reacts to specific schemes.
///
/// See _isLaunchable for the behaviors.
class _FakeUrlLauncherApi implements UrlLauncherApi {
  bool? passedUniversalLinksOnly;
  bool? usedSafariViewController;
  bool? closed;

  @override
  Future<bool> canLaunchUrl(String url) async {
    return _isLaunchable(url);
  }

  @override
  Future<bool> launchUrl(String url, bool universalLinksOnly) async {
    passedUniversalLinksOnly = universalLinksOnly;
    usedSafariViewController = false;
    return _isLaunchable(url);
  }

  @override
  Future<bool> openUrlInSafariViewController(String url) async {
    usedSafariViewController = true;
    return _isLaunchable(url);
  }

  @override
  Future<void> closeSafariViewController() async {
    closed = true;
  }

  bool _isLaunchable(String url) {
    final String scheme = url.split(':')[0];
    switch (scheme) {
      case 'http':
      case 'https':
      case 'supportedcustomscheme':
        return true;
      case 'invalid':
        throw PlatformException(code: 'argument_error');
      default:
        return false;
    }
  }
}
