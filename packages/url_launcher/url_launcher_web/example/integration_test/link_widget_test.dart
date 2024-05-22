// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';
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

  final List<String> pushedRouteNames = <String>[];
  late Future<ByteData> Function(String) originalPushFunction;

  setUp(() {
    pushedRouteNames.clear();
    originalPushFunction = pushRouteToFrameworkFunction;
    pushRouteToFrameworkFunction = (String routeName) {
      pushedRouteNames.add(routeName);
      return Future<ByteData>.value(ByteData(0));
    };
  });

  tearDown(() {
    pushRouteToFrameworkFunction = originalPushFunction;
    pushedRouteNames.clear();
    LinkViewController.debugReset();
  });

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
      final Uri uri = Uri.parse('/foobar');
      FollowLink? followLinkCallback;

      await tester.pumpWidget(MaterialApp(
        routes: <String, WidgetBuilder>{
          '/foobar': (BuildContext context) => const Text('Internal route'),
        },
        home: WebLinkDelegate(TestLinkInfo(
          uri: uri,
          target: LinkTarget.blank,
          builder: (BuildContext context, FollowLink? followLink) {
            followLinkCallback = followLink;
            return const SizedBox(width: 100, height: 100);
          },
        )),
      ));
      // Platform view creation happens asynchronously.
      await tester.pumpAndSettle();

      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);

      final html.Element anchor = _findSingleAnchor();

      await followLinkCallback!();
      final html.Event event = _simulateClick(anchor);

      // Internal links should navigate the app to the specified route. There
      // should be no calls to `launchUrl`.
      expect(pushedRouteNames, <String>['/foobar']);
      expect(testPlugin.launches, isEmpty);
      expect(event.defaultPrevented, isTrue);

      // Needed when testing on on Chrome98 headless in CI.
      // See https://github.com/flutter/flutter/issues/121161
      await tester.pumpAndSettle();
    });

    testWidgets('keydown to navigate to internal link',
        (WidgetTester tester) async {
      final Uri uri = Uri.parse('/foobar');
      FollowLink? followLinkCallback;

      await tester.pumpWidget(MaterialApp(
        routes: <String, WidgetBuilder>{
          '/foobar': (BuildContext context) => const Text('Internal route'),
        },
        home: WebLinkDelegate(TestLinkInfo(
          uri: uri,
          target: LinkTarget.blank,
          builder: (BuildContext context, FollowLink? followLink) {
            followLinkCallback = followLink;
            return const SizedBox(width: 100, height: 100);
          },
        )),
      ));
      // Platform view creation happens asynchronously.
      await tester.pumpAndSettle();

      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);

      final html.Element anchor = _findSingleAnchor();

      await followLinkCallback!();
      final html.KeyboardEvent event = _simulateKeydown(anchor);

      // Internal links should navigate the app to the specified route. There
      // should be no calls to `launchUrl`.
      expect(pushedRouteNames, <String>['/foobar']);
      expect(testPlugin.launches, isEmpty);
      expect(event.defaultPrevented, isFalse);

      // Needed when testing on on Chrome98 headless in CI.
      // See https://github.com/flutter/flutter/issues/121161
      await tester.pumpAndSettle();
    });

    testWidgets('click to navigate to external link',
        (WidgetTester tester) async {
      final Uri uri = Uri.parse('https://google.com');
      FollowLink? followLinkCallback;

      await tester.pumpWidget(MaterialApp(
        home: WebLinkDelegate(TestLinkInfo(
          uri: uri,
          target: LinkTarget.blank,
          builder: (BuildContext context, FollowLink? followLink) {
            followLinkCallback = followLink;
            return const SizedBox(width: 100, height: 100);
          },
        )),
      ));
      // Platform view creation happens asynchronously.
      await tester.pumpAndSettle();

      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);

      final html.Element anchor = _findSingleAnchor();

      await followLinkCallback!();
      final html.Event event = _simulateClick(anchor);

      // External links that are triggered by a click are left to be handled by
      // the browser, so there should be no change to the app's route name, and
      // no calls to `launchUrl`.
      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);
      expect(event.defaultPrevented, isFalse);

      // Needed when testing on on Chrome98 headless in CI.
      // See https://github.com/flutter/flutter/issues/121161
      await tester.pumpAndSettle();
    });

    testWidgets('keydown to navigate to external link',
        (WidgetTester tester) async {
      final Uri uri = Uri.parse('https://google.com');
      FollowLink? followLinkCallback;

      await tester.pumpWidget(MaterialApp(
        home: WebLinkDelegate(TestLinkInfo(
          uri: uri,
          target: LinkTarget.blank,
          builder: (BuildContext context, FollowLink? followLink) {
            followLinkCallback = followLink;
            return const SizedBox(width: 100, height: 100);
          },
        )),
      ));
      // Platform view creation happens asynchronously.
      await tester.pumpAndSettle();

      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);

      final html.Element anchor = _findSingleAnchor();

      await followLinkCallback!();
      final html.KeyboardEvent event = _simulateKeydown(anchor);

      // External links that are triggered by keyboard are handled by calling
      // `launchUrl`, and there's no change to the app's route name.
      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, <String>['https://google.com']);
      expect(event.defaultPrevented, isFalse);

      // Needed when testing on on Chrome98 headless in CI.
      // See https://github.com/flutter/flutter/issues/121161
      await tester.pumpAndSettle();
    });

    testWidgets('click on mismatched link', (WidgetTester tester) async {
      final Uri uri1 = Uri.parse('/foobar1');
      final Uri uri2 = Uri.parse('/foobar2');
      FollowLink? followLinkCallback1;
      FollowLink? followLinkCallback2;

      await tester.pumpWidget(MaterialApp(
        routes: <String, WidgetBuilder>{
          '/foobar1': (BuildContext context) => const Text('Internal route 1'),
          '/foobar2': (BuildContext context) => const Text('Internal route 2'),
        },
        home: Column(
          children: [
            WebLinkDelegate(TestLinkInfo(
              uri: uri1,
              target: LinkTarget.blank,
              builder: (BuildContext context, FollowLink? followLink) {
                followLinkCallback1 = followLink;
                return const SizedBox(width: 100, height: 100);
              },
            )),
            WebLinkDelegate(TestLinkInfo(
              uri: uri2,
              target: LinkTarget.blank,
              builder: (BuildContext context, FollowLink? followLink) {
                followLinkCallback2 = followLink;
                return const SizedBox(width: 100, height: 100);
              },
            )),
          ],
        ),
      ));
      // Platform view creation happens asynchronously.
      await tester.pumpAndSettle();

      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);

      final [
        html.Element anchor1,
        html.Element anchor2,
        ...List<html.Element> rest,
      ] = _findAllAnchors();
      expect(rest, isEmpty);

      await followLinkCallback2!();
      // Click on mismatched link.
      final html.Event event1 = _simulateClick(anchor1);

      // The link shouldn't have been triggered.
      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);
      expect(event1.defaultPrevented, isTrue);

      // Click on mismatched link (in reverse order).
      final html.Event event2 = _simulateClick(anchor2);
      await followLinkCallback1!();

      // The link shouldn't have been triggered.
      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);
      expect(event2.defaultPrevented, isTrue);

      await followLinkCallback2!();
      // Click on the correct link.
      final html.Event event = _simulateClick(anchor2);

      // The link should've been triggered now.
      expect(pushedRouteNames, <String>['/foobar2']);
      expect(testPlugin.launches, isEmpty);
      expect(event.defaultPrevented, isTrue);

      // Needed when testing on on Chrome98 headless in CI.
      // See https://github.com/flutter/flutter/issues/121161
      await tester.pumpAndSettle();
    });
  });

  group('Follows links (reversed order)', () {
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
      final Uri uri = Uri.parse('/foobar');
      FollowLink? followLinkCallback;

      await tester.pumpWidget(MaterialApp(
        routes: <String, WidgetBuilder>{
          '/foobar': (BuildContext context) => const Text('Internal route'),
        },
        home: WebLinkDelegate(TestLinkInfo(
          uri: uri,
          target: LinkTarget.blank,
          builder: (BuildContext context, FollowLink? followLink) {
            followLinkCallback = followLink;
            return const SizedBox(width: 100, height: 100);
          },
        )),
      ));
      // Platform view creation happens asynchronously.
      await tester.pumpAndSettle();

      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);

      final html.Element anchor = _findSingleAnchor();

      final html.Event event = _simulateClick(anchor);
      await followLinkCallback!();

      // Internal links should navigate the app to the specified route. There
      // should be no calls to `launchUrl`.
      expect(pushedRouteNames, <String>['/foobar']);
      expect(testPlugin.launches, isEmpty);
      expect(event.defaultPrevented, isTrue);

      // Needed when testing on on Chrome98 headless in CI.
      // See https://github.com/flutter/flutter/issues/121161
      await tester.pumpAndSettle();
    });

    testWidgets('keydown to navigate to internal link',
        (WidgetTester tester) async {
      final Uri uri = Uri.parse('/foobar');
      FollowLink? followLinkCallback;

      await tester.pumpWidget(MaterialApp(
        routes: <String, WidgetBuilder>{
          '/foobar': (BuildContext context) => const Text('Internal route'),
        },
        home: WebLinkDelegate(TestLinkInfo(
          uri: uri,
          target: LinkTarget.blank,
          builder: (BuildContext context, FollowLink? followLink) {
            followLinkCallback = followLink;
            return const SizedBox(width: 100, height: 100);
          },
        )),
      ));
      // Platform view creation happens asynchronously.
      await tester.pumpAndSettle();

      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);

      final html.Element anchor = _findSingleAnchor();

      final html.KeyboardEvent event = _simulateKeydown(anchor);
      await followLinkCallback!();

      // Internal links should navigate the app to the specified route. There
      // should be no calls to `launchUrl`.
      expect(pushedRouteNames, <String>['/foobar']);
      expect(testPlugin.launches, isEmpty);
      expect(event.defaultPrevented, isFalse);

      // Needed when testing on on Chrome98 headless in CI.
      // See https://github.com/flutter/flutter/issues/121161
      await tester.pumpAndSettle();
    });

    testWidgets('click to navigate to external link',
        (WidgetTester tester) async {
      final Uri uri = Uri.parse('https://google.com');
      FollowLink? followLinkCallback;

      await tester.pumpWidget(MaterialApp(
        home: WebLinkDelegate(TestLinkInfo(
          uri: uri,
          target: LinkTarget.blank,
          builder: (BuildContext context, FollowLink? followLink) {
            followLinkCallback = followLink;
            return const SizedBox(width: 100, height: 100);
          },
        )),
      ));
      // Platform view creation happens asynchronously.
      await tester.pumpAndSettle();

      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);

      final html.Element anchor = _findSingleAnchor();

      final html.Event event = _simulateClick(anchor);
      await followLinkCallback!();

      // External links that are triggered by a click are left to be handled by
      // the browser, so there should be no change to the app's route name, and
      // no calls to `launchUrl`.
      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);
      expect(event.defaultPrevented, isFalse);

      // Needed when testing on on Chrome98 headless in CI.
      // See https://github.com/flutter/flutter/issues/121161
      await tester.pumpAndSettle();
    });

    testWidgets('keydown to navigate to external link',
        (WidgetTester tester) async {
      final Uri uri = Uri.parse('https://google.com');
      FollowLink? followLinkCallback;

      await tester.pumpWidget(MaterialApp(
        home: WebLinkDelegate(TestLinkInfo(
          uri: uri,
          target: LinkTarget.blank,
          builder: (BuildContext context, FollowLink? followLink) {
            followLinkCallback = followLink;
            return const SizedBox(width: 100, height: 100);
          },
        )),
      ));
      // Platform view creation happens asynchronously.
      await tester.pumpAndSettle();

      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);

      final html.Element anchor = _findSingleAnchor();

      final html.KeyboardEvent event = _simulateKeydown(anchor);
      await followLinkCallback!();

      // External links that are triggered by keyboard are handled by calling
      // `launchUrl`, and there's no change to the app's route name.
      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, <String>['https://google.com']);
      expect(event.defaultPrevented, isFalse);

      // Needed when testing on on Chrome98 headless in CI.
      // See https://github.com/flutter/flutter/issues/121161
      await tester.pumpAndSettle();
    });
  });
}

List<html.Element> _findAllAnchors() {
  final List<html.Element> foundAnchors = <html.Element>[];
  html.NodeList anchors = html.document.querySelectorAll('a');
  for (int i = 0; i < anchors.length; i++) {
    final html.Element anchor = anchors.item(i)! as html.Element;
    if (anchor.hasProperty(linkViewIdProperty.toJS).toDart) {
      foundAnchors.add(anchor);
    }
  }

  // Search inside the shadow DOM as well.
  final html.ShadowRoot? shadowRoot =
      html.document.querySelector('flt-glass-pane')?.shadowRoot;
  if (shadowRoot != null) {
    anchors = shadowRoot.querySelectorAll('a');
    for (int i = 0; i < anchors.length; i++) {
      final html.Element anchor = anchors.item(i)! as html.Element;
      if (anchor.hasProperty(linkViewIdProperty.toJS).toDart) {
        foundAnchors.add(anchor);
      }
    }
  }

  return foundAnchors;
}

html.Element _findSingleAnchor() {
  return _findAllAnchors().single;
}

html.MouseEvent _simulateClick(html.Element target) {
  final html.MouseEvent mouseEvent = html.MouseEvent(
    'click',
    html.MouseEventInit()
      ..bubbles = true
      ..cancelable = true,
  );
  LinkViewController.handleGlobalClick(event: mouseEvent, target: target);
  return mouseEvent;
}

html.KeyboardEvent _simulateKeydown(html.Element target) {
  final html.KeyboardEvent keydownEvent = html.KeyboardEvent(
    'keydown',
    html.KeyboardEventInit()
      ..bubbles = true
      ..cancelable = true,
  );
  LinkViewController.handleGlobalKeydown(event: keydownEvent);
  return keydownEvent;
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
