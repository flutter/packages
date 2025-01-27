// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:linked_text/linked_text.dart';
import 'package:url_launcher/link.dart';

import './text_utils.dart';

void main() {
  final RegExp hashTagRegExp = RegExp(r'#[a-zA-Z0-9]*');
  final RegExp urlRegExp = RegExp(r'(?<!@[a-zA-Z0-9-]*)(?<![\/\.a-zA-Z0-9-])((https?:\/\/)?(([a-zA-Z0-9-]*\.)*[a-zA-Z0-9-]+(\.[a-zA-Z]+)+))(?::\d{1,5})?(?:\/[^\s]*)?(?:\?[^\s#]*)?(?:#[^\s]*)?(?![a-zA-Z0-9-]*@)');

  testWidgets('links urls by default', (WidgetTester tester) async {
    Uri? lastTappedUri;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return LinkedText(
                onTapUri: (Uri uri) {
                  lastTappedUri = uri;
                },
                text: 'Check out flutter.dev.',
              );
            },
          ),
        ),
      ),
    );

    expect(lastTappedUri, isNull);

    await tester.tap(find.byType(Link));

    // The https:// host is automatically added.
    expect(lastTappedUri, Uri.parse('https://flutter.dev'));
  });

  testWidgets('can pass custom regexp', (WidgetTester tester) async {
    String? lastTappedLink;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return LinkedText.regExp(
                regExp: hashTagRegExp,
                onTap: (String linkString) {
                  lastTappedLink = linkString;
                },
                text: 'Flutter is great #crossplatform #declarative',
              );
            },
          ),
        ),
      ),
    );

    expect(lastTappedLink, isNull);

    await tester.tap(find.byType(Link).first);
    expect(lastTappedLink, '#crossplatform');

    await tester.tap(find.byType(Link).at(1));
    expect(lastTappedLink, '#declarative');
  });

  testWidgets('can pass custom regexp with .textLinkers', (WidgetTester tester) async {
    const String text = 'Flutter is great #crossplatform #declarative';
    String? lastTappedLink;
    final List<TapGestureRecognizer> recognizers = <TapGestureRecognizer>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return LinkedText.textLinkers(
                textLinkers: <TextLinker>[
                  TextLinker(
                    regExp: hashTagRegExp,
                    linkBuilder: (String displayString, String linkString) {
                      final TapGestureRecognizer recognizer = TapGestureRecognizer()
                          ..onTap = () {
                            lastTappedLink = linkString;
                          };
                      recognizers.add(recognizer);
                      return TextSpan(
                        style: LinkedText.defaultLinkStyle,
                        text: displayString,
                        recognizer: recognizer,
                      );
                    },
                  ),
                ],
                text: text,
              );
            },
          ),
        ),
      ),
    );

    expect(lastTappedLink, isNull);

    await tester.tapAt(getTextRect(tester, '#crossplatform').center);
    expect(lastTappedLink, '#crossplatform');

    expect(recognizers, hasLength(2));
    for (final TapGestureRecognizer recognizer in recognizers) {
      recognizer.dispose();
    }
  });

  testWidgets('can link multiple different types', (WidgetTester tester) async {
    const String text = 'flutter.dev is great #crossplatform #declarative';
    String? lastTappedLink;
    final List<TapGestureRecognizer> recognizers = <TapGestureRecognizer>[];
    final TextLinker urlTextLinker = TextLinker(
      regExp: urlRegExp,
      linkBuilder: (String displayString, String linkString) {
        final TapGestureRecognizer recognizer = TapGestureRecognizer()
            ..onTap = () {
              lastTappedLink = linkString;
            };
        recognizers.add(recognizer);
        return TextSpan(
          style: LinkedText.defaultLinkStyle,
          text: displayString,
          recognizer: recognizer,
        );
      },
    );
    final TextLinker hashTagTextLinker = TextLinker(
      regExp: hashTagRegExp,
      linkBuilder: (String displayString, String linkString) {
        final TapGestureRecognizer recognizer = TapGestureRecognizer()
            ..onTap = () {
              lastTappedLink = linkString;
            };
        recognizers.add(recognizer);
        return TextSpan(
          style: LinkedText.defaultLinkStyle,
          text: displayString,
          recognizer: recognizer,
        );
      },
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return LinkedText.textLinkers(
                textLinkers: <TextLinker>[urlTextLinker, hashTagTextLinker],
                text: text,
              );
            },
          ),
        ),
      ),
    );

    expect(lastTappedLink, isNull);

    await tester.tapAt(getTextRect(tester, 'flutter.dev').center);
    expect(lastTappedLink, 'flutter.dev');

    await tester.tapAt(getTextRect(tester, '#crossplatform').center);
    expect(lastTappedLink, '#crossplatform');

    await tester.tapAt(getTextRect(tester, '#declarative').center);
    expect(lastTappedLink, '#declarative');

    expect(recognizers, hasLength(3));
    for (final TapGestureRecognizer recognizer in recognizers) {
      recognizer.dispose();
    }
  });

  testWidgets('can customize linkBuilder', (WidgetTester tester) async {
    String? lastTappedLink;
    final List<TapGestureRecognizer> recognizers = <TapGestureRecognizer>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return LinkedText.textLinkers(
                textLinkers: <TextLinker>[
                  TextLinker(
                    regExp: LinkedText.defaultUriRegExp,
                    linkBuilder: (String displayString, String linkString) {
                      final TapGestureRecognizer recognizer = TapGestureRecognizer()
                          ..onTap = () {
                            lastTappedLink = linkString;
                          };
                      recognizers.add(recognizer);
                      return TextSpan(
                        recognizer: recognizer,
                        text: displayString,
                        mouseCursor: SystemMouseCursors.help,
                      );
                    },
                  ),
                ],
                text: 'Check out flutter.dev.',
              );
            },
          ),
        ),
      ),
    );

    expect(find.byType(RichText), findsOneWidget);
    expect(lastTappedLink, isNull);

    final TestGesture gesture = await tester.createGesture(kind: PointerDeviceKind.mouse, pointer: 1);
    await gesture.addPointer(location: tester.getCenter(find.byType(Scaffold)));
    await tester.pump();
    expect(RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1), SystemMouseCursors.basic);
    await gesture.moveTo(tester.getCenter(find.byType(RichText)));
    expect(RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1), SystemMouseCursors.help);

    await tester.tapAt(tester.getCenter(find.byType(RichText)));
    expect(lastTappedLink, 'flutter.dev');

    expect(recognizers, hasLength(1));
    for (final TapGestureRecognizer recognizer in recognizers) {
      recognizer.dispose();
    }
  });

  testWidgets('can take nested spans', (WidgetTester tester) async {
    Uri? lastTappedUri;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return LinkedText(
                onTapUri: (Uri uri) {
                  lastTappedUri = uri;
                },
                spans: <InlineSpan>[
                  TextSpan(
                    text: 'Check out fl',
                    style: DefaultTextStyle.of(context).style,
                    children: const <InlineSpan>[
                      TextSpan(
                        text: 'u',
                        children: <InlineSpan>[
                          TextSpan(
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                            text: 'tt',
                          ),
                          TextSpan(
                            text: 'er',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const TextSpan(
                    text: '.dev.',
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    // 1. fl 2. u 3. tt 4. er 5. .dev
    expect(find.byType(Link), findsNWidgets(5));
    expect(lastTappedUri, isNull);

    await tester.tapAt(tester.getCenter(find.byType(Link).first));

    // The https:// host is automatically added.
    expect(lastTappedUri, Uri.parse('https://flutter.dev'));
  });

  testWidgets('can handle WidgetSpans', (WidgetTester tester) async {
    Uri? lastTappedUri;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return LinkedText(
                onTapUri: (Uri uri) {
                  lastTappedUri = uri;
                },
                spans: <InlineSpan>[
                  TextSpan(
                    text: 'Check out fl',
                    style: DefaultTextStyle.of(context).style,
                    children: const <InlineSpan>[
                      TextSpan(
                        text: 'u',
                        children: <InlineSpan>[
                          TextSpan(
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                            text: 'tt',
                          ),
                          WidgetSpan(
                            child: FlutterLogo(),
                          ),
                          TextSpan(
                            text: 'er',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const TextSpan(
                    text: '.dev.',
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    // 1. fl 2. u 3. tt 4. er 5. .dev
    expect(find.byType(Link), findsNWidgets(5));
    expect(lastTappedUri, isNull);

    await tester.tapAt(tester.getCenter(find.byType(Link).first));

    // The WidgetSpan is ignored, so a link is still produced even though it has
    // a FlutterLogo in the middle of it.
    expect(lastTappedUri, Uri.parse('https://flutter.dev'));
  });

  testWidgets('builds the widget specified by builder', (WidgetTester tester) async {
    final GlobalKey key = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return LinkedText(
                onTapUri: (Uri uri) {},
                text: 'Check out flutter.dev.',
                builder: (BuildContext context, Iterable<InlineSpan> linkedSpans) {
                  return RichText(
                    key: key,
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: linkedSpans.toList(),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );

    expect(find.byKey(key), findsOneWidget);
    final RichText richText = tester.widget(find.byKey(key));
    expect(richText.textAlign, TextAlign.center);
  });
}
