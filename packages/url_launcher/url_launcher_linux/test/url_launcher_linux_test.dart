// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_linux/src/messages.g.dart';
import 'package:url_launcher_linux/url_launcher_linux.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

void main() {
  group('UrlLauncherLinux', () {
    test('registers instance', () {
      UrlLauncherLinux.registerWith();
      expect(UrlLauncherPlatform.instance, isA<UrlLauncherLinux>());
    });

    test('canLaunch passes true', () async {
      final _FakeUrlLauncherApi api = _FakeUrlLauncherApi();
      final UrlLauncherLinux launcher = UrlLauncherLinux(api: api);

      final bool canLaunch = await launcher.canLaunch('http://example.com/');

      expect(canLaunch, true);
    });

    test('canLaunch passes false', () async {
      final _FakeUrlLauncherApi api = _FakeUrlLauncherApi(canLaunch: false);
      final UrlLauncherLinux launcher = UrlLauncherLinux(api: api);

      final bool canLaunch = await launcher.canLaunch('http://example.com/');

      expect(canLaunch, false);
    });

    test('launch', () async {
      final _FakeUrlLauncherApi api = _FakeUrlLauncherApi();
      final UrlLauncherLinux launcher = UrlLauncherLinux(api: api);
      const String url = 'http://example.com/';

      final bool launched = await launcher.launch(
        url,
        useSafariVC: true,
        useWebView: false,
        enableJavaScript: false,
        enableDomStorage: false,
        universalLinksOnly: false,
        headers: const <String, String>{},
      );

      expect(launched, true);
      expect(api.argument, url);
    });

    test('launch should throw if platform returns an error', () async {
      final _FakeUrlLauncherApi api = _FakeUrlLauncherApi(error: 'An error');
      final UrlLauncherLinux launcher = UrlLauncherLinux(api: api);

      await expectLater(
          launcher.launch(
            'http://example.com/',
            useSafariVC: true,
            useWebView: false,
            enableJavaScript: false,
            enableDomStorage: false,
            universalLinksOnly: false,
            headers: const <String, String>{},
          ),
          throwsA(isA<PlatformException>()
              .having((PlatformException e) => e.code, 'code', 'Launch Error')
              .having((PlatformException e) => e.message, 'message',
                  contains('Failed to launch URL: An error'))));
    });

    group('launchUrl', () {
      test('passes URL', () async {
        final _FakeUrlLauncherApi api = _FakeUrlLauncherApi();
        final UrlLauncherLinux launcher = UrlLauncherLinux(api: api);
        const String url = 'http://example.com/';

        final bool launched =
            await launcher.launchUrl(url, const LaunchOptions());

        expect(launched, true);
        expect(api.argument, url);
      });

      test('throws if platform returns an error', () async {
        final _FakeUrlLauncherApi api = _FakeUrlLauncherApi(error: 'An error');
        final UrlLauncherLinux launcher = UrlLauncherLinux(api: api);

        await expectLater(
            launcher.launchUrl('http://example.com/', const LaunchOptions()),
            throwsA(isA<PlatformException>()
                .having((PlatformException e) => e.code, 'code', 'Launch Error')
                .having((PlatformException e) => e.message, 'message',
                    contains('Failed to launch URL: An error'))));
      });
    });

    group('supportsMode', () {
      test('returns true for platformDefault', () async {
        final UrlLauncherLinux launcher = UrlLauncherLinux();
        expect(await launcher.supportsMode(PreferredLaunchMode.platformDefault),
            true);
      });

      test('returns true for external application', () async {
        final UrlLauncherLinux launcher = UrlLauncherLinux();
        expect(
            await launcher
                .supportsMode(PreferredLaunchMode.externalApplication),
            true);
      });

      test('returns false for other modes', () async {
        final UrlLauncherLinux launcher = UrlLauncherLinux();
        expect(
            await launcher.supportsMode(
                PreferredLaunchMode.externalNonBrowserApplication),
            false);
        expect(
            await launcher.supportsMode(PreferredLaunchMode.inAppBrowserView),
            false);
        expect(await launcher.supportsMode(PreferredLaunchMode.inAppWebView),
            false);
      });
    });

    test('supportsCloseForMode returns false', () async {
      final UrlLauncherLinux launcher = UrlLauncherLinux();
      expect(
          await launcher
              .supportsCloseForMode(PreferredLaunchMode.platformDefault),
          false);
      expect(
          await launcher
              .supportsCloseForMode(PreferredLaunchMode.externalApplication),
          false);
    });
  });
}

class _FakeUrlLauncherApi implements UrlLauncherApi {
  _FakeUrlLauncherApi({this.canLaunch = true, this.error});

  /// The value to return from canLaunch.
  final bool canLaunch;

  /// The error to return from launchUrl, if any.
  final String? error;

  /// The argument that was passed to an API call.
  String? argument;

  @override
  Future<bool> canLaunchUrl(String url) async {
    argument = url;
    return canLaunch;
  }

  @override
  Future<String?> launchUrl(String url) async {
    argument = url;
    return error;
  }

  @override
  // ignore: non_constant_identifier_names
  BinaryMessenger? get pigeonVar_binaryMessenger => null;

  @override
  // ignore: non_constant_identifier_names
  String get pigeonVar_messageChannelSuffix => '';
}
