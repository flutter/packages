// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:url_launcher_web/src/link.dart';
import 'package:url_launcher_web/url_launcher_web.dart';
import 'package:web/web.dart' as html;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Link Widget', () {
    testWidgets('creates anchor with correct attributes',
        (WidgetTester tester) async {
      final Uri uri = Uri.parse('http://foobar/example?q=1');
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: WebLinkDelegate(TestLinkInfo(
          uri: uri,
          target: LinkTarget.blank,
          builder: (BuildContext context, FollowLink? followLink) {
            return const SizedBox(width: 100, height: 100);
          },
        )),
      ));
      // Platform view creation happens asynchronously.
      await tester.pumpAndSettle();
      await tester.pump();

      final html.Element anchor = _findSingleAnchor();
      expect(anchor.getAttribute('href'), uri.toString());
      expect(anchor.getAttribute('target'), '_blank');

      final Uri uri2 = Uri.parse('http://foobar2/example?q=2');
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: WebLinkDelegate(TestLinkInfo(
          uri: uri2,
          target: LinkTarget.self,
          builder: (BuildContext context, FollowLink? followLink) {
            return const SizedBox(width: 100, height: 100);
          },
        )),
      ));
      await tester.pumpAndSettle();
      await tester.pump();

      // Check that the same anchor has been updated.
      expect(anchor.getAttribute('href'), uri2.toString());
      expect(anchor.getAttribute('target'), '_self');

      final Uri uri3 = Uri.parse('/foobar');
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: WebLinkDelegate(TestLinkInfo(
          uri: uri3,
          target: LinkTarget.self,
          builder: (BuildContext context, FollowLink? followLink) {
            return const SizedBox(width: 100, height: 100);
          },
        )),
      ));
      await tester.pumpAndSettle();
      await tester.pump();

      // Check that internal route properly prepares using the default
      // [UrlStrategy]
      expect(anchor.getAttribute('href'),
          ui_web.urlStrategy?.prepareExternalUrl(uri3.toString()));
      expect(anchor.getAttribute('target'), '_self');

      // Needed when testing on on Chrome98 headless in CI.
      // See https://github.com/flutter/flutter/issues/121161
      await tester.pumpAndSettle();
    });

    testWidgets('sizes itself correctly', (WidgetTester tester) async {
      final Key containerKey = GlobalKey();
      final Uri uri = Uri.parse('http://foobar');
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints.tight(const Size(100.0, 100.0)),
            child: WebLinkDelegate(TestLinkInfo(
              uri: uri,
              target: LinkTarget.blank,
              builder: (BuildContext context, FollowLink? followLink) {
                return Container(
                  key: containerKey,
                  child: const SizedBox(width: 50.0, height: 50.0),
                );
              },
            )),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.pump();

      final Size containerSize = tester.getSize(find.byKey(containerKey));
      // The Stack widget inserted by the `WebLinkDelegate` shouldn't loosen the
      // constraints before passing them to the inner container. So the inner
      // container should respect the tight constraints given by the ancestor
      // `ConstrainedBox` widget.
      expect(containerSize.width, 100.0);
      expect(containerSize.height, 100.0);

      // Needed when testing on on Chrome98 headless in CI.
      // See https://github.com/flutter/flutter/issues/121161
      await tester.pumpAndSettle();
    });

    // See: https://github.com/flutter/plugins/pull/3522#discussion_r574703724
    testWidgets('uri can be null', (WidgetTester tester) async {
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: WebLinkDelegate(TestLinkInfo(
          uri: null,
          target: LinkTarget.defaultTarget,
          builder: (BuildContext context, FollowLink? followLink) {
            return const SizedBox(width: 100, height: 100);
          },
        )),
      ));
      // Platform view creation happens asynchronously.
      await tester.pumpAndSettle();
      await tester.pump();

      final html.Element anchor = _findSingleAnchor();
      expect(anchor.hasAttribute('href'), false);

      // Needed when testing on on Chrome98 headless in CI.
      // See https://github.com/flutter/flutter/issues/121161
      await tester.pumpAndSettle();
    });

    testWidgets('can be created and disposed', (WidgetTester tester) async {
      final Uri uri = Uri.parse('http://foobar');
      const int itemCount = 500;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: ListView.builder(
              itemCount: itemCount,
              itemBuilder: (_, int index) => WebLinkDelegate(TestLinkInfo(
                uri: uri,
                target: LinkTarget.defaultTarget,
                builder: (BuildContext context, FollowLink? followLink) =>
                    Text('#$index', textAlign: TextAlign.center),
              )),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.pump();

      await tester.scrollUntilVisible(
        find.text('#${itemCount - 1}'),
        800,
        maxScrolls: 1000,
      );

      // Needed when testing on on Chrome98 headless in CI.
      // See https://github.com/flutter/flutter/issues/121161
      await tester.pumpAndSettle();
    });
  });

  group('Follows links', () {
    late TestUrlLauncherPlugin testPlugin;
    late UrlLauncherPlatform originalPlugin;

    setUp(() {
      originalPlugin = UrlLauncherPlatform.instance;
      testPlugin = TestUrlLauncherPlugin();
      UrlLauncherPlatform.instance = testPlugin;
    });

    tearDown(() {
      UrlLauncherPlatform.instance = originalPlugin;
    });

    testWidgets('click to navigate to internal link',
        (WidgetTester tester) async {
      final TestNavigatorObserver observer = TestNavigatorObserver();
      final Uri uri = Uri.parse('/foobar');
      FollowLink? followLinkCallback;

      await tester.pumpWidget(MaterialApp(
        navigatorObservers: <NavigatorObserver>[observer],
        routes: <String, WidgetBuilder>{
          '/foobar': (BuildContext context) => const Text('Internal route'),
        },
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: WebLinkDelegate(TestLinkInfo(
            uri: uri,
            target: LinkTarget.blank,
            builder: (BuildContext context, FollowLink? followLink) {
              followLinkCallback = followLink;
              return const SizedBox(width: 100, height: 100);
            },
          )),
        ),
      ));
      // Platform view creation happens asynchronously.
      await tester.pumpAndSettle();
      await tester.pump();

      expect(observer.currentRouteName, '/');
      expect(testPlugin.launches, isEmpty);

      final html.Element anchor = _findSingleAnchor();

      await followLinkCallback!();
      _simulateClick(anchor);
      await tester.pumpAndSettle();

      // Internal links should navigate the app to the specified route. There
      // should be no calls to `launchUrl`.
      expect(observer.currentRouteName, '/foobar');
      expect(testPlugin.launches, isEmpty);
    });

    testWidgets('keydown to navigate to internal link',
        (WidgetTester tester) async {
      final TestNavigatorObserver observer = TestNavigatorObserver();
      final Uri uri = Uri.parse('/foobar');
      FollowLink? followLinkCallback;

      await tester.pumpWidget(MaterialApp(
        navigatorObservers: <NavigatorObserver>[observer],
        routes: <String, WidgetBuilder>{
          '/foobar': (BuildContext context) => const Text('Internal route'),
        },
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: WebLinkDelegate(TestLinkInfo(
            uri: uri,
            target: LinkTarget.blank,
            builder: (BuildContext context, FollowLink? followLink) {
              followLinkCallback = followLink;
              return const SizedBox(width: 100, height: 100);
            },
          )),
        ),
      ));
      // Platform view creation happens asynchronously.
      await tester.pumpAndSettle();
      await tester.pump();

      expect(observer.currentRouteName, '/');
      expect(testPlugin.launches, isEmpty);

      final html.Element anchor = _findSingleAnchor();

      await followLinkCallback!();
      _simulateKeydown(anchor);
      await tester.pumpAndSettle();

      // Internal links should navigate the app to the specified route. There
      // should be no calls to `launchUrl`.
      expect(observer.currentRouteName, '/foobar');
      expect(testPlugin.launches, isEmpty);
    });

    testWidgets('click to navigate to external link',
        (WidgetTester tester) async {
      final TestNavigatorObserver observer = TestNavigatorObserver();
      final Uri uri = Uri.parse('https://google.com');
      FollowLink? followLinkCallback;

      await tester.pumpWidget(MaterialApp(
        navigatorObservers: <NavigatorObserver>[observer],
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: WebLinkDelegate(TestLinkInfo(
            uri: uri,
            target: LinkTarget.blank,
            builder: (BuildContext context, FollowLink? followLink) {
              followLinkCallback = followLink;
              return const SizedBox(width: 100, height: 100);
            },
          )),
        ),
      ));
      // Platform view creation happens asynchronously.
      await tester.pumpAndSettle();
      await tester.pump();

      expect(observer.currentRouteName, '/');
      expect(testPlugin.launches, isEmpty);

      final html.Element anchor = _findSingleAnchor();

      await followLinkCallback!();
      _simulateClick(anchor);
      await tester.pumpAndSettle();

      // External links that are triggered by a click are left to be handled by
      // the browser, so there should be no change to the app's route name, and
      // no calls to `launchUrl`.
      expect(observer.currentRouteName, '/');
      expect(testPlugin.launches, isEmpty);
    });

    testWidgets('keydown to navigate to external link',
        (WidgetTester tester) async {
      final TestNavigatorObserver observer = TestNavigatorObserver();
      final Uri uri = Uri.parse('https://google.com');
      FollowLink? followLinkCallback;

      await tester.pumpWidget(MaterialApp(
        navigatorObservers: <NavigatorObserver>[observer],
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: WebLinkDelegate(TestLinkInfo(
            uri: uri,
            target: LinkTarget.blank,
            builder: (BuildContext context, FollowLink? followLink) {
              followLinkCallback = followLink;
              return const SizedBox(width: 100, height: 100);
            },
          )),
        ),
      ));
      // Platform view creation happens asynchronously.
      await tester.pumpAndSettle();
      await tester.pump();

      expect(observer.currentRouteName, '/');
      expect(testPlugin.launches, isEmpty);

      final html.Element anchor = _findSingleAnchor();

      await followLinkCallback!();
      _simulateKeydown(anchor);
      await tester.pumpAndSettle();

      // External links that are triggered by keyboard are handled by calling
      // `launchUrl`, and there's no change to the app's route name.
      expect(observer.currentRouteName, '/');
      expect(testPlugin.launches, <String>['https://google.com']);
    });
  });
}

html.Element _findSingleAnchor() {
  final List<html.Element> foundAnchors = <html.Element>[];
  final html.NodeList anchors = html.document.querySelectorAll('a');
  for (int i = 0; i < anchors.length; i++) {
    final html.Element anchor = anchors.item(i)! as html.Element;
    if (anchor.hasProperty(linkViewIdProperty.toJS).toDart) {
      foundAnchors.add(anchor);
    }
  }

  return foundAnchors.single;
}

void _simulateClick(html.Element target) {
  // Stop the browser from navigating away from the test suite.
  target.addEventListener(
      'click',
      (html.Event e) {
        e.preventDefault();
      }.toJS);
  // Synthesize a click event.
  target.dispatchEvent(
    html.MouseEvent(
      'click',
      html.MouseEventInit(
        bubbles: true,
        cancelable: true,
      ),
    ),
  );
}

void _simulateKeydown(html.Element target) {
  target.dispatchEvent(
    html.KeyboardEvent(
      'keydown',
      html.KeyboardEventInit(
        bubbles: true,
        cancelable: true,
        code: 'Space',
      ),
    ),
  );
}

class TestNavigatorObserver extends NavigatorObserver {
  String? currentRouteName;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRouteName = route.settings.name;
  }
}

class TestLinkInfo extends LinkInfo {
  TestLinkInfo({
    required this.uri,
    required this.target,
    required this.builder,
  });

  @override
  final LinkWidgetBuilder builder;

  @override
  final Uri? uri;

  @override
  final LinkTarget target;

  @override
  bool get isDisabled => uri == null;
}

class TestUrlLauncherPlugin extends UrlLauncherPlugin {
  final List<String> launches = <String>[];

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launches.add(url);
    return true;
  }
}
