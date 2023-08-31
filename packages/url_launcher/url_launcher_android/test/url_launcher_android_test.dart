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

  group('launch without webview', () {
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
            'noactivity://',
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

  group('launch with webview', () {
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

    test('passes through no-activity exception', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      await expectLater(
          launcher.launch(
            'noactivity://scheme',
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

  group('closeWebView', () {
    test('calls through', () async {
      final UrlLauncherAndroid launcher = UrlLauncherAndroid(api: api);
      await launcher.closeWebView();

      expect(api.closed, true);
    });
  });
}

/// A fake implementation of the host API that reacts to specific schemes.
///
/// See _launch for the behaviors.
class _FakeUrlLauncherApi implements UrlLauncherApi {
  WebViewOptions? passedWebViewOptions;
  bool? usedWebView;
  bool? closed;

  /// A domain that will be treated as having no handler, even for http(s).
  static String specialHandlerDomain = 'special.handler.domain';

  @override
  Future<bool> canLaunchUrl(String url) async {
    return _launch(url);
  }

  @override
  Future<bool> launchUrl(String url, Map<String?, String?> headers) async {
    passedWebViewOptions = WebViewOptions(
        enableJavaScript: false, enableDomStorage: false, headers: headers);
    usedWebView = false;
    return _launch(url);
  }

  @override
  Future<void> closeWebView() async {
    closed = true;
  }

  @override
  Future<bool> openUrlInWebView(String url, WebViewOptions options) async {
    passedWebViewOptions = options;
    usedWebView = true;
    return _launch(url);
  }

  bool _launch(String url) {
    final String scheme = url.split(':')[0];
    switch (scheme) {
      case 'http':
      case 'https':
        return !url.contains(specialHandlerDomain);
      case 'noactivity':
        throw PlatformException(code: 'NO_ACTIVITY');
      default:
        return false;
    }
  }
}
