// Copyright 2013 The Flutter Authors. All rights reserved.
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

@GenerateMocks(<Type>[UrlLauncherApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UrlLauncherIOS', () {
    late MockUrlLauncherApi api;
    late UrlLauncherIOS launcher;

    setUp(() {
      api = MockUrlLauncherApi();
      launcher = UrlLauncherIOS(api: api);
    });

    test('registers instance', () {
      UrlLauncherIOS.registerWith();
      expect(UrlLauncherPlatform.instance, isA<UrlLauncherIOS>());
    });

    test('canLaunch success', () async {
      when(api.canLaunchUrl(any)).thenAnswer(
        (_) async => LaunchResult.success,
      );
      expect(await launcher.canLaunch('http://example.com/'), true);
    });

    test('canLaunch failure', () async {
      when(api.canLaunchUrl(any)).thenAnswer(
        (_) async => LaunchResult.failedToLoad,
      );
      expect(await launcher.canLaunch('unknown://scheme'), false);
    });

    test('canLaunch invalid URL passes the PlatformException through',
        () async {
      when(api.canLaunchUrl(any)).thenAnswer(
        (_) async => LaunchResult.invalidUrl,
      );
      await expectLater(launcher.canLaunch('invalid://u r l'),
          throwsA(isA<PlatformException>()));
    });

    test('launch success', () async {
      when(api.launchUrl(any, any)).thenAnswer(
        (_) async => LaunchResult.success,
      );
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

      verify(api.launchUrl(any, false)).called(1);
      verifyNever(api.openUrlInSafariViewController(any));
    });

    test('launch failure', () async {
      when(api.launchUrl(any, any)).thenAnswer(
        (_) async => LaunchResult.failedToLoad,
      );
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
      verify(api.launchUrl(any, false)).called(1);
      verifyNever(api.openUrlInSafariViewController(any));
    });

    test('launch invalid URL passes the PlatformException through', () async {
      when(api.launchUrl(any, any)).thenAnswer(
        (_) async => LaunchResult.invalidUrl,
      );
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

    test('launch failed to load URL returns false', () async {
      when(api.launchUrl(any, any)).thenAnswer(
        (_) async => LaunchResult.failedToLoad,
      );
      expect(
          await launcher.launch(
            'invalid://u r l',
            useSafariVC: false,
            useWebView: false,
            enableJavaScript: false,
            enableDomStorage: false,
            universalLinksOnly: false,
            headers: const <String, String>{},
          ),
          false);
    });

    test('launch force SafariVC', () async {
      when(api.openUrlInSafariViewController(any)).thenAnswer(
        (_) async => LaunchResult.success,
      );
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
      verify(api.openUrlInSafariViewController(any)).called(1);
      verifyNever(api.launchUrl(any, any));
    });

    test('launch universal links only', () async {
      when(api.launchUrl(any, any)).thenAnswer(
        (_) async => LaunchResult.success,
      );
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
      verify(api.launchUrl(any, true)).called(1);
      verifyNever(api.openUrlInSafariViewController(any));
    });

    test('launch force SafariVC to false', () async {
      when(api.launchUrl(any, any)).thenAnswer(
        (_) async => LaunchResult.success,
      );
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
      verify(api.launchUrl(any, false)).called(1);
      verifyNever(api.openUrlInSafariViewController(any));
    });

    test('closeWebView default behavior', () async {
      await launcher.closeWebView();
      verify(api.closeSafariViewController()).called(1);
    });
  });
}
