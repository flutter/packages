// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_linux/url_launcher_linux.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UrlLauncherLinux', () {
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/url_launcher_linux');
    final List<MethodCall> log = <MethodCall>[];
    _ambiguate(TestDefaultBinaryMessengerBinding.instance)!
        .defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);

      // Return null explicitly instead of relying on the implicit null
      // returned by the method channel if no return statement is specified.
      return null;
    });

    tearDown(() {
      log.clear();
    });

    test('registers instance', () {
      UrlLauncherLinux.registerWith();
      expect(UrlLauncherPlatform.instance, isA<UrlLauncherLinux>());
    });

    test('canLaunch', () async {
      final UrlLauncherLinux launcher = UrlLauncherLinux();
      await launcher.canLaunch('http://example.com/');
      expect(
        log,
        <Matcher>[isMethodCall('canLaunch', arguments: 'http://example.com/')],
      );
    });

    test('canLaunch should return false if platform returns null', () async {
      final UrlLauncherLinux launcher = UrlLauncherLinux();
      final bool canLaunch = await launcher.canLaunch('http://example.com/');

      expect(canLaunch, false);
    });

    test('launch', () async {
      final UrlLauncherLinux launcher = UrlLauncherLinux();
      await launcher.launch(
        'http://example.com/',
        useSafariVC: true,
        useWebView: false,
        enableJavaScript: false,
        enableDomStorage: false,
        universalLinksOnly: false,
        headers: const <String, String>{},
      );
      expect(
        log,
        <Matcher>[isMethodCall('launch', arguments: 'http://example.com/')],
      );
    });

    test('launch should return false if platform returns null', () async {
      final UrlLauncherLinux launcher = UrlLauncherLinux();
      final bool launched = await launcher.launch(
        'http://example.com/',
        useSafariVC: true,
        useWebView: false,
        enableJavaScript: false,
        enableDomStorage: false,
        universalLinksOnly: false,
        headers: const <String, String>{},
      );

      expect(launched, false);
    });

    group('launchUrl', () {
      test('passes URL', () async {
        final UrlLauncherLinux launcher = UrlLauncherLinux();
        await launcher.launchUrl('http://example.com/', const LaunchOptions());
        expect(
          log,
          <Matcher>[isMethodCall('launch', arguments: 'http://example.com/')],
        );
      });

      test('returns false if platform returns null', () async {
        final UrlLauncherLinux launcher = UrlLauncherLinux();
        final bool launched = await launcher.launchUrl(
            'http://example.com/', const LaunchOptions());

        expect(launched, false);
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

/// This allows a value of type T or T? to be treated as a value of type T?.
///
/// We use this so that APIs that have become non-nullable can still be used
/// with `!` and `?` on the stable branch.
T? _ambiguate<T>(T? value) => value;
