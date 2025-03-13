// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_android/src/messages.g.dart';
import 'package:url_launcher_android/url_launcher_android.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

void main() {
  late _FakeUrlLauncherApi api;

  setUp(() {
    api = _FakeUrlLauncherApi();
  });

  test('registers instance', () {
    UrlLauncherAndroid.registerWith();
    expect(UrlLauncherPlatform.instance, isA<UrlLauncherAndroid>());
  });

  group('canLaunch', () {
    test('returns true', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      final bool canLaunch = await launcher.canLaunch('http://example.com/');

      expect(canLaunch, true);
    });

    test('returns false', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      final bool canLaunch = await launcher.canLaunch('unknown://scheme');

      expect(canLaunch, false);
    });

    test('checks a generic URL if an http URL returns false', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      final bool canLaunch = await launcher
          .canLaunch('http://${_FakeUrlLauncherApi.specialHandlerDomain}');

      expect(canLaunch, true);
    });

    test('checks a generic URL if an https URL returns false', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      final bool canLaunch = await launcher
          .canLaunch('https://${_FakeUrlLauncherApi.specialHandlerDomain}');

      expect(canLaunch, true);
    });
  });

  group('legacy launch without webview', () {
    test('calls through', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      final bool launched = await launcher.launch(
        'http://example.com/',
        useSafariVC: true,
        useWebView: false,
        enableJavaScript: false,
        enableDomStorage: false,
        universalLinksOnly: false,
        headers: const <String, String>{},
      );

      expect(launched, true);
      expect(api.usedWebView, false);
      expect(api.passedWebViewOptions?.headers, isEmpty);
    });

    test('passes headers', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      await launcher.launch(
        'http://example.com/',
        useSafariVC: true,
        useWebView: false,
        enableJavaScript: false,
        enableDomStorage: false,
        universalLinksOnly: false,
        headers: const <String, String>{'key': 'value'},
      );
      expect(api.passedWebViewOptions?.headers.length, 1);
      expect(api.passedWebViewOptions?.headers['key'], 'value');
    });

    test('passes through no-activity exception', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      await expectLater(
          launcher.launch(
            'https://noactivity',
            useSafariVC: false,
            useWebView: false,
            enableJavaScript: false,
            enableDomStorage: false,
            universalLinksOnly: false,
            headers: const <String, String>{},
          ),
          throwsA(isA<PlatformException>()));
    });

    test('throws if there is no handling activity', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      await expectLater(
          launcher.launch(
            'unknown://scheme',
            useSafariVC: false,
            useWebView: false,
            enableJavaScript: false,
            enableDomStorage: false,
            universalLinksOnly: false,
            headers: const <String, String>{},
          ),
          throwsA(isA<PlatformException>().having(
              (PlatformException e) => e.code, 'code', 'ACTIVITY_NOT_FOUND')));
    });
  });

  group('legacy launch with webview', () {
    test('calls through', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      final bool launched = await launcher.launch(
        'http://example.com/',
        useSafariVC: true,
        useWebView: true,
        enableJavaScript: false,
        enableDomStorage: false,
        universalLinksOnly: false,
        headers: const <String, String>{},
      );
      expect(launched, true);
      expect(api.usedWebView, true);
      expect(api.allowedCustomTab, false);
      expect(api.passedWebViewOptions?.enableDomStorage, false);
      expect(api.passedWebViewOptions?.enableJavaScript, false);
      expect(api.passedWebViewOptions?.headers, isEmpty);
    });

    test('passes enableJavaScript to webview', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      await launcher.launch(
        'http://example.com/',
        useSafariVC: true,
        useWebView: true,
        enableJavaScript: true,
        enableDomStorage: false,
        universalLinksOnly: false,
        headers: const <String, String>{},
      );

      expect(api.passedWebViewOptions?.enableJavaScript, true);
    });

    test('passes enableDomStorage to webview', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      await launcher.launch(
        'http://example.com/',
        useSafariVC: true,
        useWebView: true,
        enableJavaScript: false,
        enableDomStorage: true,
        universalLinksOnly: false,
        headers: const <String, String>{},
      );

      expect(api.passedWebViewOptions?.enableDomStorage, true);
    });

    test('passes showTitle to webview', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      await launcher.launchUrl(
        'http://example.com/',
        const LaunchOptions(
          browserConfiguration: InAppBrowserConfiguration(
            showTitle: true,
          ),
        ),
      );

      expect(api.passedBrowserOptions?.showTitle, true);
    });

    test('passes through no-activity exception', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      await expectLater(
          launcher.launch(
            'https://noactivity',
            useSafariVC: false,
            useWebView: true,
            enableJavaScript: false,
            enableDomStorage: false,
            universalLinksOnly: false,
            headers: const <String, String>{},
          ),
          throwsA(isA<PlatformException>()));
    });

    test('throws if there is no handling activity', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      await expectLater(
          launcher.launch(
            'unknown://scheme',
            useSafariVC: false,
            useWebView: true,
            enableJavaScript: false,
            enableDomStorage: false,
            universalLinksOnly: false,
            headers: const <String, String>{},
          ),
          throwsA(isA<PlatformException>().having(
              (PlatformException e) => e.code, 'code', 'ACTIVITY_NOT_FOUND')));
    });
  });

  group('launch without webview', () {
    test('calls through', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      final bool launched = await launcher.launchUrl(
        'http://example.com/',
        const LaunchOptions(mode: PreferredLaunchMode.externalApplication),
      );
      expect(launched, true);
      expect(api.usedWebView, false);
      expect(api.passedWebViewOptions?.headers, isEmpty);
    });

    test('passes headers', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      await launcher.launchUrl(
        'http://example.com/',
        const LaunchOptions(
            mode: PreferredLaunchMode.externalApplication,
            webViewConfiguration: InAppWebViewConfiguration(
                headers: <String, String>{'key': 'value'})),
      );
      expect(api.passedWebViewOptions?.headers.length, 1);
      expect(api.passedWebViewOptions?.headers['key'], 'value');
    });

    test('passes through no-activity exception', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      await expectLater(
          launcher.launchUrl('https://noactivity', const LaunchOptions()),
          throwsA(isA<PlatformException>()));
    });

    test('throws if there is no handling activity', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      await expectLater(
          launcher.launchUrl('unknown://scheme', const LaunchOptions()),
          throwsA(isA<PlatformException>().having(
              (PlatformException e) => e.code, 'code', 'ACTIVITY_NOT_FOUND')));
    });
  });

  group('launch with webview', () {
    test('calls through', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      final bool launched = await launcher.launchUrl('http://example.com/',
          const LaunchOptions(mode: PreferredLaunchMode.inAppWebView));
      expect(launched, true);
      expect(api.usedWebView, true);
      expect(api.allowedCustomTab, false);
      expect(api.passedWebViewOptions?.enableDomStorage, true);
      expect(api.passedWebViewOptions?.enableJavaScript, true);
      expect(api.passedWebViewOptions?.headers, isEmpty);
    });

    test('passes enableJavaScript to webview', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      await launcher.launchUrl(
          'http://example.com/',
          const LaunchOptions(
              mode: PreferredLaunchMode.inAppWebView,
              webViewConfiguration:
                  InAppWebViewConfiguration(enableJavaScript: false)));

      expect(api.passedWebViewOptions?.enableJavaScript, false);
    });

    test('passes enableDomStorage to webview', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      await launcher.launchUrl(
          'http://example.com/',
          const LaunchOptions(
              mode: PreferredLaunchMode.inAppWebView,
              webViewConfiguration:
                  InAppWebViewConfiguration(enableDomStorage: false)));

      expect(api.passedWebViewOptions?.enableDomStorage, false);
    });

    test('passes through no-activity exception', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      await expectLater(
          launcher.launchUrl('https://noactivity',
              const LaunchOptions(mode: PreferredLaunchMode.inAppWebView)),
          throwsA(isA<PlatformException>()));
    });

    test('throws if there is no handling activity', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      await expectLater(
          launcher.launchUrl('unknown://scheme',
              const LaunchOptions(mode: PreferredLaunchMode.inAppWebView)),
          throwsA(isA<PlatformException>().having(
              (PlatformException e) => e.code, 'code', 'ACTIVITY_NOT_FOUND')));
    });
  });

  group('launch with custom tab', () {
    test('calls through', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      final bool launched = await launcher.launchUrl('http://example.com/',
          const LaunchOptions(mode: PreferredLaunchMode.inAppBrowserView));
      expect(launched, true);
      expect(api.usedWebView, true);
      expect(api.allowedCustomTab, true);
    });
  });

  group('launch with platform default', () {
    test('uses custom tabs for http', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      final bool launched = await launcher.launchUrl(
          'http://example.com/', const LaunchOptions());
      expect(launched, true);
      expect(api.usedWebView, true);
      expect(api.allowedCustomTab, true);
    });

    test('uses custom tabs for https', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      final bool launched = await launcher.launchUrl(
          'https://example.com/', const LaunchOptions());
      expect(launched, true);
      expect(api.usedWebView, true);
      expect(api.allowedCustomTab, true);
    });

    test('uses external for other schemes', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      final bool launched = await launcher.launchUrl(
          'supportedcustomscheme://example.com/', const LaunchOptions());
      expect(launched, true);
      expect(api.usedWebView, false);
    });
  });

  group('supportsMode', () {
    test('returns true for platformDefault', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      expect(await launcher.supportsMode(PreferredLaunchMode.platformDefault),
          true);
    });

    test('returns true for external application', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      expect(
          await launcher.supportsMode(PreferredLaunchMode.externalApplication),
          true);
    });

    test('returns true for in app web view', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      expect(
          await launcher.supportsMode(PreferredLaunchMode.inAppWebView), true);
    });

    test('returns true for in app browser view when available', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      api.hasCustomTabSupport = true;
      expect(await launcher.supportsMode(PreferredLaunchMode.inAppBrowserView),
          true);
    });

    test('returns false for in app browser view when not available', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      api.hasCustomTabSupport = false;
      expect(await launcher.supportsMode(PreferredLaunchMode.inAppBrowserView),
          false);
    });
  });

  group('supportsCloseForMode', () {
    test('returns true for in app web view', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      expect(
          await launcher.supportsCloseForMode(PreferredLaunchMode.inAppWebView),
          true);
    });

    test('returns false for other modes', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      expect(
          await launcher
              .supportsCloseForMode(PreferredLaunchMode.externalApplication),
          false);
      expect(
          await launcher.supportsCloseForMode(
              PreferredLaunchMode.externalNonBrowserApplication),
          false);
      expect(
          await launcher
              .supportsCloseForMode(PreferredLaunchMode.inAppBrowserView),
          false);
    });
  });
}

/// A fake implementation of the host API that reacts to specific schemes.
///
/// See _launch for the behaviors.
class _FakeUrlLauncherApi implements UrlLauncherApi {
  bool hasCustomTabSupport = true;
  WebViewOptions? passedWebViewOptions;
  BrowserOptions? passedBrowserOptions;
  bool? usedWebView;
  bool? allowedCustomTab;
  bool? closed;

  /// A domain that will be treated as having no handler, even for http(s).
  static String specialHandlerDomain = 'special.handler.domain';

  @override
  Future<bool> canLaunchUrl(String url) async {
    return _launch(url);
  }

  @override
  Future<bool> launchUrl(String url, Map<String, String> headers) async {
    passedWebViewOptions = WebViewOptions(
      enableJavaScript: false,
      enableDomStorage: false,
      headers: headers,
    );

    usedWebView = false;
    return _launch(url);
  }

  @override
  Future<void> closeWebView() async {
    closed = true;
  }

  @override
  Future<bool> openUrlInApp(
    String url,
    bool allowCustomTab,
    WebViewOptions webViewOptions,
    BrowserOptions browserOptions,
  ) async {
    passedWebViewOptions = webViewOptions;
    passedBrowserOptions = browserOptions;
    usedWebView = true;
    allowedCustomTab = allowCustomTab;
    return _launch(url);
  }

  @override
  Future<bool> supportsCustomTabs() async {
    return hasCustomTabSupport;
  }

  bool _launch(String url) {
    final String scheme = url.split(':')[0];
    switch (scheme) {
      case 'http':
      case 'https':
      case 'supportedcustomscheme':
        if (url.endsWith('noactivity')) {
          throw PlatformException(code: 'NO_ACTIVITY');
        }
        return !url.contains(specialHandlerDomain);
      default:
        return false;
    }
  }

  @override
  // ignore: non_constant_identifier_names
  BinaryMessenger? get pigeonVar_binaryMessenger => null;

  @override
  // ignore: non_constant_identifier_names
  String get pigeonVar_messageChannelSuffix => '';
}
