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
      await tester.pump();

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
      await tester.pump();

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
    });

    testWidgets('click to navigate to external link',
        (WidgetTester tester) async {
      final Uri uri = Uri.parse('https://flutter.dev');
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
      await tester.pump();

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
    });

    testWidgets('keydown to navigate to external link',
        (WidgetTester tester) async {
      final Uri uri = Uri.parse('https://flutter.dev');
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
      await tester.pump();

      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);

      final html.Element anchor = _findSingleAnchor();

      await followLinkCallback!();
      final html.KeyboardEvent event = _simulateKeydown(anchor);

      // External links that are triggered by keyboard are handled by calling
      // `launchUrl`, and there's no change to the app's route name.
      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, <String>['https://flutter.dev']);
      expect(event.defaultPrevented, isFalse);
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
          children: <Widget>[
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
      await tester.pump();

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
    });

    testWidgets('trigger signals are reset after a delay',
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
      await tester.pump();

      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);

      final html.Element anchor = _findSingleAnchor();

      // A large delay between signals should reset the previous signal.
      await followLinkCallback!();
      await Future<void>.delayed(const Duration(seconds: 1));
      final html.Event event1 = _simulateClick(anchor);

      // The link shouldn't have been triggered.
      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);
      expect(event1.defaultPrevented, isFalse);

      await Future<void>.delayed(const Duration(seconds: 1));

      // Signals with large delay (in reverse order).
      final html.Event event2 = _simulateClick(anchor);
      await Future<void>.delayed(const Duration(seconds: 1));
      await followLinkCallback!();

      // The link shouldn't have been triggered.
      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);
      expect(event2.defaultPrevented, isFalse);

      await Future<void>.delayed(const Duration(seconds: 1));

      // A small delay is okay.
      await followLinkCallback!();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final html.Event event3 = _simulateClick(anchor);

      // The link should've been triggered now.
      expect(pushedRouteNames, <String>['/foobar']);
      expect(testPlugin.launches, isEmpty);
      expect(event3.defaultPrevented, isTrue);
    });

    testWidgets('ignores clicks on non-Flutter link',
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
      await tester.pump();

      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);

      final html.Element nonFlutterAnchor = html.document.createElement('a');
      nonFlutterAnchor.setAttribute('href', '/non-flutter');

      await followLinkCallback!();
      final html.Event event = _simulateClick(nonFlutterAnchor);

      // The link shouldn't have been triggered.
      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);
      expect(event.defaultPrevented, isFalse);
    });

    testWidgets('handles cmd+click correctly', (WidgetTester tester) async {
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
      await tester.pump();

      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);

      final html.Element anchor = _findSingleAnchor();

      await followLinkCallback!();
      final html.Event event = _simulateClick(anchor, metaKey: true);

      // When a modifier key is present, we should let the browser handle the
      // navigation. That means we do nothing on our side.
      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);
      expect(event.defaultPrevented, isFalse);
    });

    testWidgets('ignores keydown when it is a modifier key',
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
      await tester.pump();

      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);

      final html.Element anchor = _findSingleAnchor();

      final html.KeyboardEvent event1 = _simulateKeydown(anchor, metaKey: true);
      await followLinkCallback!();

      // When the pressed key is a modifier key, we should ignore it.
      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);
      expect(event1.defaultPrevented, isFalse);

      // If later we receive another trigger, it should work.
      final html.KeyboardEvent event2 = _simulateKeydown(anchor);

      // Now the link should be triggered.
      expect(pushedRouteNames, <String>['/foobar']);
      expect(testPlugin.launches, isEmpty);
      expect(event2.defaultPrevented, isFalse);
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
      await tester.pump();

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
      await tester.pump();

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
    });

    testWidgets('click to navigate to external link',
        (WidgetTester tester) async {
      final Uri uri = Uri.parse('https://flutter.dev');
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
      await tester.pump();

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
    });

    testWidgets('keydown to navigate to external link',
        (WidgetTester tester) async {
      final Uri uri = Uri.parse('https://flutter.dev');
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
      await tester.pump();

      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);

      final html.Element anchor = _findSingleAnchor();

      final html.KeyboardEvent event = _simulateKeydown(anchor);
      await followLinkCallback!();

      // External links that are triggered by keyboard are handled by calling
      // `launchUrl`, and there's no change to the app's route name.
      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, <String>['https://flutter.dev']);
      expect(event.defaultPrevented, isFalse);
    });
  });

  group('Link semantics', () {
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

    testWidgets('produces the correct semantics tree with a button',
        (WidgetTester tester) async {
      final SemanticsHandle semanticsHandle = tester.ensureSemantics();
      final Key linkKey = UniqueKey();

      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: WebLinkDelegate(
          key: linkKey,
          semanticsIdentifier: 'test-link-12',
          TestLinkInfo(
            uri: Uri.parse('https://foobar/example?q=1'),
            target: LinkTarget.blank,
            builder: (BuildContext context, FollowLink? followLink) {
              return ElevatedButton(
                onPressed: followLink,
                child: const Text('Button Link Text'),
              );
            },
          ),
        ),
      ));

      final Finder linkFinder = find.byKey(linkKey);
      expect(
        tester.getSemantics(find.descendant(
          of: linkFinder,
          matching: find.byType(Semantics).first,
        )),
        matchesSemantics(
          isLink: true,
          identifier: 'test-link-12',
          // linkUrl: 'https://foobar/example?q=1',
          children: <Matcher>[
            matchesSemantics(
              hasTapAction: true,
              hasEnabledState: true,
              hasFocusAction: true,
              isEnabled: true,
              isButton: true,
              isFocusable: true,
              label: 'Button Link Text',
            ),
          ],
        ),
      );

      semanticsHandle.dispose();
    });

    testWidgets('produces the correct semantics tree with text',
        (WidgetTester tester) async {
      final SemanticsHandle semanticsHandle = tester.ensureSemantics();
      final Key linkKey = UniqueKey();

      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: WebLinkDelegate(
          key: linkKey,
          semanticsIdentifier: 'test-link-43',
          TestLinkInfo(
            uri: Uri.parse('https://foobar/example?q=1'),
            target: LinkTarget.blank,
            builder: (BuildContext context, FollowLink? followLink) {
              return GestureDetector(
                onTap: followLink,
                child: const Text('Link Text'),
              );
            },
          ),
        ),
      ));

      final Finder linkFinder = find.byKey(linkKey);
      expect(
        tester.getSemantics(find.descendant(
          of: linkFinder,
          matching: find.byType(Semantics),
        )),
        matchesSemantics(
          isLink: true,
          hasTapAction: true,
          identifier: 'test-link-43',
          // linkUrl: 'https://foobar/example?q=1',
          label: 'Link Text',
        ),
      );

      semanticsHandle.dispose();
    });

    testWidgets('handles clicks on semantic link with a button',
        (WidgetTester tester) async {
      final Uri uri = Uri.parse('/foobar');
      FollowLink? followLinkCallback;

      await tester.pumpWidget(MaterialApp(
        routes: <String, WidgetBuilder>{
          '/foobar': (BuildContext context) => const Text('Internal route'),
        },
        home: WebLinkDelegate(
          semanticsIdentifier: 'test-link-27',
          TestLinkInfo(
            uri: uri,
            target: LinkTarget.blank,
            builder: (BuildContext context, FollowLink? followLink) {
              followLinkCallback = followLink;
              return ElevatedButton(
                onPressed: () {},
                child: const Text('My Button Link'),
              );
            },
          ),
        ),
      ));
      // Platform view creation happens asynchronously.
      await tester.pumpAndSettle();
      await tester.pump();

      final html.Element semanticsHost =
          html.document.createElement('flt-semantics-host');
      html.document.body!.append(semanticsHost);
      final html.Element semanticsAnchor = html.document.createElement('a')
        ..setAttribute('id', 'flt-semantic-node-99')
        ..setAttribute('flt-semantics-identifier', 'test-link-27')
        ..setAttribute('href', '/foobar');
      semanticsHost.append(semanticsAnchor);
      final html.Element semanticsContainer =
          html.document.createElement('flt-semantics-container');
      semanticsAnchor.append(semanticsContainer);
      final html.Element semanticsButton =
          html.document.createElement('flt-semantics')
            ..setAttribute('role', 'button')
            ..textContent = 'My Button Link';
      semanticsContainer.append(semanticsButton);

      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);

      await followLinkCallback!();
      // Click on the button (child of the anchor).
      final html.Event event1 = _simulateClick(semanticsButton);

      expect(pushedRouteNames, <String>['/foobar']);
      expect(testPlugin.launches, isEmpty);
      expect(event1.defaultPrevented, isTrue);
      pushedRouteNames.clear();

      await followLinkCallback!();
      // Click on the anchor itself.
      final html.Event event2 = _simulateClick(semanticsAnchor);

      expect(pushedRouteNames, <String>['/foobar']);
      expect(testPlugin.launches, isEmpty);
      expect(event2.defaultPrevented, isTrue);
    });

    testWidgets('handles clicks on semantic link with text',
        (WidgetTester tester) async {
      final Uri uri = Uri.parse('/foobar');
      FollowLink? followLinkCallback;

      await tester.pumpWidget(MaterialApp(
        routes: <String, WidgetBuilder>{
          '/foobar': (BuildContext context) => const Text('Internal route'),
        },
        home: WebLinkDelegate(
          semanticsIdentifier: 'test-link-71',
          TestLinkInfo(
            uri: uri,
            target: LinkTarget.blank,
            builder: (BuildContext context, FollowLink? followLink) {
              followLinkCallback = followLink;
              return GestureDetector(
                onTap: () {},
                child: const Text('My Link'),
              );
            },
          ),
        ),
      ));
      // Platform view creation happens asynchronously.
      await tester.pumpAndSettle();
      await tester.pump();

      final html.Element semanticsHost =
          html.document.createElement('flt-semantics-host');
      html.document.body!.append(semanticsHost);
      final html.Element semanticsAnchor = html.document.createElement('a')
        ..setAttribute('id', 'flt-semantic-node-99')
        ..setAttribute('flt-semantics-identifier', 'test-link-71')
        ..setAttribute('href', '/foobar')
        ..textContent = 'My Text Link';
      semanticsHost.append(semanticsAnchor);

      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);

      await followLinkCallback!();
      final html.Event event = _simulateClick(semanticsAnchor);

      expect(pushedRouteNames, <String>['/foobar']);
      expect(testPlugin.launches, isEmpty);
      expect(event.defaultPrevented, isTrue);
    });

    // TODO(mdebbar): Remove this test after the engine PR [1] makes it to stable.
    //                [1] https://github.com/flutter/engine/pull/52720
    testWidgets('handles clicks on (old) semantic link with a button',
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
      await tester.pump();

      final html.Element semanticsHost =
          html.document.createElement('flt-semantics-host');
      html.document.body!.append(semanticsHost);
      final html.Element semanticsAnchor = html.document.createElement('a')
        ..setAttribute('id', 'flt-semantic-node-99')
        ..setAttribute('href', '#');
      semanticsHost.append(semanticsAnchor);
      final html.Element semanticsContainer =
          html.document.createElement('flt-semantics-container');
      semanticsAnchor.append(semanticsContainer);
      final html.Element semanticsButton =
          html.document.createElement('flt-semantics')
            ..setAttribute('role', 'button')
            ..textContent = 'My Button';
      semanticsContainer.append(semanticsButton);

      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);

      await followLinkCallback!();
      final html.Event event1 = _simulateClick(semanticsButton);

      // Before the changes land in the web engine, this will not trigger the
      // link properly.
      expect(pushedRouteNames, <String>[]);
      expect(testPlugin.launches, isEmpty);
      expect(event1.defaultPrevented, isFalse);
    });

    // TODO(mdebbar): Remove this test after the engine PR [1] makes it to stable.
    //                [1] https://github.com/flutter/engine/pull/52720
    testWidgets('handles clicks on (old) semantic link with text',
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
            return GestureDetector(
              onTap: () {},
              child: const Text('My Link'),
            );
          },
        )),
      ));
      // Platform view creation happens asynchronously.
      await tester.pumpAndSettle();
      await tester.pump();

      final html.Element semanticsHost =
          html.document.createElement('flt-semantics-host');
      html.document.body!.append(semanticsHost);
      final html.Element semanticsAnchor = html.document.createElement('a')
        ..setAttribute('id', 'flt-semantic-node-99')
        ..setAttribute('href', '#')
        ..textContent = 'My Text Link';
      semanticsHost.append(semanticsAnchor);

      expect(pushedRouteNames, isEmpty);
      expect(testPlugin.launches, isEmpty);

      await followLinkCallback!();
      final html.Event event = _simulateClick(semanticsAnchor);

      // Before the changes land in the web engine, this will not trigger the
      // link properly.
      expect(pushedRouteNames, <String>[]);
      expect(testPlugin.launches, isEmpty);
      expect(event.defaultPrevented, isFalse);
    });
  });
}

List<html.Element> _findAllAnchors() {
  final List<html.Element> foundAnchors = <html.Element>[];
  final html.NodeList anchors = html.document.querySelectorAll('a');
  for (int i = 0; i < anchors.length; i++) {
    final html.Element anchor = anchors.item(i)! as html.Element;
    if (anchor.hasProperty(linkViewIdProperty.toJS).toDart) {
      foundAnchors.add(anchor);
    }
  }

  return foundAnchors;
}

html.Element _findSingleAnchor() {
  return _findAllAnchors().single;
}

html.MouseEvent _simulateClick(html.Element target, {bool metaKey = false}) {
  // // Stop the browser from navigating away from the test suite.
  // target.addEventListener(
  //     'click',
  //     (html.Event e) {
  //       e.preventDefault();
  //     }.toJS);
  final html.MouseEvent mouseEvent = html.MouseEvent(
    'click',
    html.MouseEventInit(
      bubbles: true,
      cancelable: true,
      metaKey: metaKey,
    ),
  );
  LinkViewController.handleGlobalClick(event: mouseEvent, target: target);
  return mouseEvent;
}

html.KeyboardEvent _simulateKeydown(html.Element target,
    {bool metaKey = false}) {
  final html.KeyboardEvent keydownEvent = html.KeyboardEvent(
      'keydown',
      html.KeyboardEventInit(
        bubbles: true,
        cancelable: true,
        metaKey: metaKey,
        // code: 'Space',
      ));
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
