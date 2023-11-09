// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:url_launcher_windows/src/messages.g.dart';
import 'package:url_launcher_windows/url_launcher_windows.dart';

void main() {
  late _FakeUrlLauncherApi api;
  late UrlLauncherWindows plugin;

  setUp(() {
    api = _FakeUrlLauncherApi();
    plugin = UrlLauncherWindows(api: api);
  });

  test('registers instance', () {
    UrlLauncherWindows.registerWith();
    expect(UrlLauncherPlatform.instance, isA<UrlLauncherWindows>());
  });

  group('canLaunch', () {
    test('handles true', () async {
      api.canLaunch = true;

      final bool result = await plugin.canLaunch('http://example.com/');

      expect(result, isTrue);
      expect(api.argument, 'http://example.com/');
    });

    test('handles false', () async {
      api.canLaunch = false;

      final bool result = await plugin.canLaunch('http://example.com/');

      expect(result, isFalse);
      expect(api.argument, 'http://example.com/');
    });
  });

  group('launch', () {
    test('handles success', () async {
      api.canLaunch = true;

      expect(
          await plugin.launch(
            'http://example.com/',
            useSafariVC: true,
            useWebView: false,
            enableJavaScript: false,
            enableDomStorage: false,
            universalLinksOnly: false,
            headers: const <String, String>{},
          ),
          true);
      expect(api.argument, 'http://example.com/');
    });

    test('handles failure', () async {
      api.canLaunch = false;

      expect(
          await plugin.launch(
            'http://example.com/',
            useSafariVC: true,
            useWebView: false,
            enableJavaScript: false,
            enableDomStorage: false,
            universalLinksOnly: false,
            headers: const <String, String>{},
          ),
          false);
      expect(api.argument, 'http://example.com/');
    });

    test('handles errors', () async {
      api.throwError = true;

      await expectLater(
          plugin.launch(
            'http://example.com/',
            useSafariVC: true,
            useWebView: false,
            enableJavaScript: false,
            enableDomStorage: false,
            universalLinksOnly: false,
            headers: const <String, String>{},
          ),
          throwsA(isA<PlatformException>()));
      expect(api.argument, 'http://example.com/');
    });
  });

  group('supportsMode', () {
    test('returns true for platformDefault', () async {
      final UrlLauncherWindows launcher = UrlLauncherWindows(api: api);
      expect(await launcher.supportsMode(PreferredLaunchMode.platformDefault),
          true);
    });

    test('returns true for external application', () async {
      final UrlLauncherWindows launcher = UrlLauncherWindows(api: api);
      expect(
          await launcher.supportsMode(PreferredLaunchMode.externalApplication),
          true);
    });

    test('returns false for other modes', () async {
      final UrlLauncherWindows launcher = UrlLauncherWindows(api: api);
      expect(
          await launcher
              .supportsMode(PreferredLaunchMode.externalNonBrowserApplication),
          false);
      expect(await launcher.supportsMode(PreferredLaunchMode.inAppBrowserView),
          false);
      expect(
          await launcher.supportsMode(PreferredLaunchMode.inAppWebView), false);
    });
  });

  test('supportsCloseForMode returns false', () async {
    final UrlLauncherWindows launcher = UrlLauncherWindows(api: api);
    expect(
        await launcher
            .supportsCloseForMode(PreferredLaunchMode.platformDefault),
        false);
    expect(
        await launcher
            .supportsCloseForMode(PreferredLaunchMode.externalApplication),
        false);
  });
}

class _FakeUrlLauncherApi implements UrlLauncherApi {
  /// The argument that was passed to an API call.
  String? argument;

  /// Controls the behavior of the fake canLaunch implementations.
  ///
  /// - [canLaunchUrl] returns this value.
  /// - [launchUrl] returns this value if [throwError] is false.
  bool canLaunch = false;

  /// Whether to throw a platform exception.
  bool throwError = false;

  @override
  Future<bool> canLaunchUrl(String url) async {
    argument = url;
    return canLaunch;
  }

  @override
  Future<bool> launchUrl(String url) async {
    argument = url;
    if (throwError) {
      throw PlatformException(code: 'Failed');
    }
    return canLaunch;
  }
}
