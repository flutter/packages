// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This test is run using `flutter drive` by the CI (see /script/tool/README.md
// in this repository for details on driving that tooling manually), but can
// also be run using `flutter test` directly during development.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final HttpServer server =
      await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  unawaited(server.forEach((HttpRequest request) {
    if (request.uri.path == '/hello.txt') {
      request.response.writeln('Hello, world.');
    } else if (request.uri.path == '/secondary.txt') {
      request.response.writeln('How are you today?');
    } else if (request.uri.path == '/headers') {
      request.response.writeln('${request.headers}');
    } else if (request.uri.path == '/favicon.ico') {
      request.response.statusCode = HttpStatus.notFound;
    } else if (request.uri.path == '/http-basic-authentication') {
      final List<String>? authHeader =
          request.headers[HttpHeaders.authorizationHeader];
      if (authHeader != null) {
        final String encodedCredential = authHeader.first.split(' ')[1];
        final String credential =
            String.fromCharCodes(base64Decode(encodedCredential));
        if (credential == 'user:password') {
          request.response.writeln('Authorized');
        } else {
          request.response.headers.add(
              HttpHeaders.wwwAuthenticateHeader, 'Basic realm="Test realm"');
          request.response.statusCode = HttpStatus.unauthorized;
        }
      } else {
        request.response.headers
            .add(HttpHeaders.wwwAuthenticateHeader, 'Basic realm="Test realm"');
        request.response.statusCode = HttpStatus.unauthorized;
      }
    } else {
      fail('unexpected request: ${request.method} ${request.uri}');
    }
    request.response.close();
  }));
  final String prefixUrl = 'http://${server.address.address}:${server.port}';
  final String primaryUrl = '$prefixUrl/hello.txt';
  final String secondaryUrl = '$prefixUrl/secondary.txt';
  final String headersUrl = '$prefixUrl/headers';
  final String basicAuthUrl = '$prefixUrl/http-basic-authentication';

  testWidgets('loadRequest', (WidgetTester tester) async {
    final Completer<void> pageFinished = Completer<void>();

    final WebViewController controller = WebViewController();
    await controller.setNavigationDelegate(
      NavigationDelegate(onPageFinished: (_) => pageFinished.complete()),
    );
    await controller.loadRequest(Uri.parse(primaryUrl));

    await tester.pumpWidget(WebViewWidget(controller: controller));
    await pageFinished.future;

    final String? currentUrl = await controller.currentUrl();
    expect(currentUrl, primaryUrl);
  });

  testWidgets('runJavaScriptReturningResult', (WidgetTester tester) async {
    final Completer<void> pageFinished = Completer<void>();

    final WebViewController controller = WebViewController();
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setNavigationDelegate(
      NavigationDelegate(onPageFinished: (_) => pageFinished.complete()),
    );
    await controller.loadRequest(Uri.parse(primaryUrl));

    await tester.pumpWidget(WebViewWidget(controller: controller));

    await pageFinished.future;

    await expectLater(
      controller.runJavaScriptReturningResult('1 + 1'),
      completion(2),
    );
  });

  testWidgets('loadRequest with headers', (WidgetTester tester) async {
    final Map<String, String> headers = <String, String>{
      'test_header': 'flutter_test_header'
    };

    final StreamController<String> pageLoads = StreamController<String>();

    final WebViewController controller = WebViewController();
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setNavigationDelegate(
      NavigationDelegate(onPageFinished: (String url) => pageLoads.add(url)),
    );

    await tester.pumpWidget(WebViewWidget(controller: controller));

    await controller.loadRequest(Uri.parse(headersUrl), headers: headers);

    await pageLoads.stream.firstWhere((String url) => url == headersUrl);

    final String content = await controller.runJavaScriptReturningResult(
      'document.documentElement.innerText',
    ) as String;
    expect(content.contains('flutter_test_header'), isTrue);
  });

  testWidgets('JavascriptChannel', (WidgetTester tester) async {
    final Completer<void> pageFinished = Completer<void>();
    final WebViewController controller = WebViewController();
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setNavigationDelegate(
      NavigationDelegate(onPageFinished: (_) => pageFinished.complete()),
    );

    final Completer<String> channelCompleter = Completer<String>();
    await controller.addJavaScriptChannel(
      'Echo',
      onMessageReceived: (JavaScriptMessage message) {
        channelCompleter.complete(message.message);
      },
    );

    await controller.loadHtmlString(
      'data:text/html;charset=utf-8;base64,PCFET0NUWVBFIGh0bWw+',
    );

    await tester.pumpWidget(WebViewWidget(controller: controller));

    await pageFinished.future;

    await controller.runJavaScript('Echo.postMessage("hello");');
    await expectLater(channelCompleter.future, completion('hello'));
  });

  testWidgets('resize webview', (WidgetTester tester) async {
    final Completer<void> initialResizeCompleter = Completer<void>();
    final Completer<void> buttonTapResizeCompleter = Completer<void>();
    final Completer<void> onPageFinished = Completer<void>();

    bool resizeButtonTapped = false;
    await tester.pumpWidget(ResizableWebView(
      onResize: () {
        if (resizeButtonTapped) {
          buttonTapResizeCompleter.complete();
        } else {
          initialResizeCompleter.complete();
        }
      },
      onPageFinished: () => onPageFinished.complete(),
    ));

    await onPageFinished.future;
    // Wait for a potential call to resize after page is loaded.
    await initialResizeCompleter.future.timeout(
      const Duration(seconds: 3),
      onTimeout: () => null,
    );

    resizeButtonTapped = true;

    await tester.tap(find.byKey(const ValueKey<String>('resizeButton')));
    await tester.pumpAndSettle();

    await expectLater(buttonTapResizeCompleter.future, completes);
  });

  testWidgets('set custom userAgent', (WidgetTester tester) async {
    final Completer<void> pageFinished = Completer<void>();

    final WebViewController controller = WebViewController();
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setNavigationDelegate(NavigationDelegate(
      onPageFinished: (_) => pageFinished.complete(),
    ));
    await controller.setUserAgent('Custom_User_Agent1');
    await controller.loadRequest(Uri.parse('about:blank'));

    await tester.pumpWidget(WebViewWidget(controller: controller));

    await pageFinished.future;

    final String? customUserAgent = await controller.getUserAgent();
    expect(customUserAgent, 'Custom_User_Agent1');
  });

  group('Video playback policy', () {
    late String videoTestBase64;
    setUpAll(() async {
      final ByteData videoData =
          await rootBundle.load('assets/sample_video.mp4');
      final String base64VideoData =
          base64Encode(Uint8List.view(videoData.buffer));
      final String videoTest = '''
        <!DOCTYPE html><html>
        <head><title>Video auto play</title>
          <script type="text/javascript">
            function play() {
              var video = document.getElementById("video");
              video.play();
              video.addEventListener('timeupdate', videoTimeUpdateHandler, false);
            }
            function videoTimeUpdateHandler(e) {
              var video = document.getElementById("video");
              VideoTestTime.postMessage(video.currentTime);
            }
            function isPaused() {
              var video = document.getElementById("video");
              return video.paused;
            }
            function isFullScreen() {
              var video = document.getElementById("video");
              return video.webkitDisplayingFullscreen;
            }
          </script>
        </head>
        <body onload="play();">
        <video controls playsinline autoplay id="video">
          <source src="data:video/mp4;charset=utf-8;base64,$base64VideoData">
        </video>
        </body>
        </html>
      ''';
      videoTestBase64 = base64Encode(const Utf8Encoder().convert(videoTest));
    });

    testWidgets('Auto media playback', (WidgetTester tester) async {
      Completer<void> pageLoaded = Completer<void>();

      late PlatformWebViewControllerCreationParams params;
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        params = WebKitWebViewControllerCreationParams(
          mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
        );
      } else {
        params = const PlatformWebViewControllerCreationParams();
      }

      WebViewController controller =
          WebViewController.fromPlatformCreationParams(params);
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);

      await controller.setNavigationDelegate(
        NavigationDelegate(onPageFinished: (_) => pageLoaded.complete()),
      );

      if (controller.platform is AndroidWebViewController) {
        await (controller.platform as AndroidWebViewController)
            .setMediaPlaybackRequiresUserGesture(false);
      }

      await controller.loadRequest(
        Uri.parse('data:text/html;charset=utf-8;base64,$videoTestBase64'),
      );

      await tester.pumpWidget(WebViewWidget(controller: controller));

      await tester.pumpAndSettle();

      await pageLoaded.future;

      bool isPaused =
          await controller.runJavaScriptReturningResult('isPaused();') as bool;
      expect(isPaused, false);

      pageLoaded = Completer<void>();
      controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);

      await controller.setNavigationDelegate(
        NavigationDelegate(onPageFinished: (_) => pageLoaded.complete()),
      );

      await controller.loadRequest(
        Uri.parse('data:text/html;charset=utf-8;base64,$videoTestBase64'),
      );

      await tester.pumpWidget(WebViewWidget(controller: controller));

      await tester.pumpAndSettle();

      await pageLoaded.future;

      isPaused =
          await controller.runJavaScriptReturningResult('isPaused();') as bool;
      expect(isPaused, true);
    });

    testWidgets('Video plays inline', (WidgetTester tester) async {
      final Completer<void> pageLoaded = Completer<void>();
      final Completer<void> videoPlaying = Completer<void>();

      late PlatformWebViewControllerCreationParams params;
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        params = WebKitWebViewControllerCreationParams(
          mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
          allowsInlineMediaPlayback: true,
        );
      } else {
        params = const PlatformWebViewControllerCreationParams();
      }
      final WebViewController controller =
          WebViewController.fromPlatformCreationParams(params);
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);

      await controller.setNavigationDelegate(
        NavigationDelegate(onPageFinished: (_) => pageLoaded.complete()),
      );

      await controller.addJavaScriptChannel(
        'VideoTestTime',
        onMessageReceived: (JavaScriptMessage message) {
          final double currentTime = double.parse(message.message);
          // Let it play for at least 1 second to make sure the related video's properties are set.
          if (currentTime > 1 && !videoPlaying.isCompleted) {
            videoPlaying.complete(null);
          }
        },
      );

      if (controller.platform is AndroidWebViewController) {
        await (controller.platform as AndroidWebViewController)
            .setMediaPlaybackRequiresUserGesture(false);
      }

      await controller.loadRequest(
        Uri.parse('data:text/html;charset=utf-8;base64,$videoTestBase64'),
      );

      await tester.pumpWidget(WebViewWidget(controller: controller));
      await tester.pumpAndSettle();

      await pageLoaded.future;

      // Makes sure we get the correct event that indicates the video is actually playing.
      await videoPlaying.future;

      final bool fullScreen = await controller
          .runJavaScriptReturningResult('isFullScreen();') as bool;
      expect(fullScreen, false);
    });
  },
      // TODO(bparrishMines): Stop skipping once https://github.com/flutter/flutter/issues/148487 is resolved
      skip: true);

  group('Audio playback policy', () {
    late String audioTestBase64;
    setUpAll(() async {
      final ByteData audioData =
          await rootBundle.load('assets/sample_audio.ogg');
      final String base64AudioData =
          base64Encode(Uint8List.view(audioData.buffer));
      final String audioTest = '''
        <!DOCTYPE html><html>
        <head><title>Audio auto play</title>
          <script type="text/javascript">
            function play() {
              var audio = document.getElementById("audio");
              audio.play();
            }
            function isPaused() {
              var audio = document.getElementById("audio");
              return audio.paused;
            }
          </script>
        </head>
        <body onload="play();">
        <audio controls id="audio">
          <source src="data:audio/ogg;charset=utf-8;base64,$base64AudioData">
        </audio>
        </body>
        </html>
      ''';
      audioTestBase64 = base64Encode(const Utf8Encoder().convert(audioTest));
    });

    testWidgets('Auto media playback', (WidgetTester tester) async {
      Completer<void> pageLoaded = Completer<void>();

      late PlatformWebViewControllerCreationParams params;
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        params = WebKitWebViewControllerCreationParams(
          mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
        );
      } else {
        params = const PlatformWebViewControllerCreationParams();
      }

      WebViewController controller =
          WebViewController.fromPlatformCreationParams(params);
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setNavigationDelegate(
        NavigationDelegate(onPageFinished: (_) => pageLoaded.complete()),
      );

      if (controller.platform is AndroidWebViewController) {
        await (controller.platform as AndroidWebViewController)
            .setMediaPlaybackRequiresUserGesture(false);
      }

      await controller.loadRequest(
        Uri.parse('data:text/html;charset=utf-8;base64,$audioTestBase64'),
      );

      await tester.pumpWidget(WebViewWidget(controller: controller));
      await tester.pumpAndSettle();

      await pageLoaded.future;

      bool isPaused =
          await controller.runJavaScriptReturningResult('isPaused();') as bool;
      expect(isPaused, false);

      pageLoaded = Completer<void>();
      controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setNavigationDelegate(
        NavigationDelegate(onPageFinished: (_) => pageLoaded.complete()),
      );

      await controller.loadRequest(
        Uri.parse('data:text/html;charset=utf-8;base64,$audioTestBase64'),
      );

      await tester.pumpWidget(WebViewWidget(controller: controller));

      await tester.pumpAndSettle();
      await pageLoaded.future;

      isPaused =
          await controller.runJavaScriptReturningResult('isPaused();') as bool;
      expect(isPaused, true);
    });
  },
      // OGG playback is not supported on macOS, so the test data would need
      // to be changed to support macOS.
      skip: Platform.isMacOS);

  testWidgets('getTitle', (WidgetTester tester) async {
    const String getTitleTest = '''
        <!DOCTYPE html><html>
        <head><title>Some title</title>
        </head>
        <body>
        </body>
        </html>
      ''';
    final String getTitleTestBase64 =
        base64Encode(const Utf8Encoder().convert(getTitleTest));
    final Completer<void> pageLoaded = Completer<void>();

    final WebViewController controller = WebViewController();
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setNavigationDelegate(NavigationDelegate(
      onPageFinished: (_) => pageLoaded.complete(),
    ));
    await controller.loadRequest(
      Uri.parse('data:text/html;charset=utf-8;base64,$getTitleTestBase64'),
    );

    await tester.pumpWidget(WebViewWidget(controller: controller));

    await pageLoaded.future;

    // On at least iOS, it does not appear to be guaranteed that the native
    // code has the title when the page load completes. Execute some JavaScript
    // before checking the title to ensure that the page has been fully parsed
    // and processed.
    await controller.runJavaScript('1;');

    final String? title = await controller.getTitle();
    expect(title, 'Some title');
  });

  group('Programmatic Scroll', () {
    testWidgets('setAndGetScrollPosition', (WidgetTester tester) async {
      const String scrollTestPage = '''
        <!DOCTYPE html>
        <html>
          <head>
            <style>
              body {
                height: 100%;
                width: 100%;
              }
              #container{
                width:5000px;
                height:5000px;
            }
            </style>
          </head>
          <body>
            <div id="container"/>
          </body>
        </html>
      ''';

      final String scrollTestPageBase64 =
          base64Encode(const Utf8Encoder().convert(scrollTestPage));

      final Completer<void> pageLoaded = Completer<void>();
      final WebViewController controller = WebViewController();
      ScrollPositionChange? recordedPosition;
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => pageLoaded.complete(),
      ));
      await controller.setOnScrollPositionChange(
          (ScrollPositionChange contentOffsetChange) {
        recordedPosition = contentOffsetChange;
      });

      await controller.loadRequest(Uri.parse(
        'data:text/html;charset=utf-8;base64,$scrollTestPageBase64',
      ));

      await tester.pumpWidget(WebViewWidget(controller: controller));

      await pageLoaded.future;

      await tester.pumpAndSettle(const Duration(seconds: 3));

      Offset scrollPos = await controller.getScrollPosition();

      // Check scrollTo()
      const int X_SCROLL = 123;
      const int Y_SCROLL = 321;
      // Get the initial position; this ensures that scrollTo is actually
      // changing something, but also gives the native view's scroll position
      // time to settle.
      expect(scrollPos.dx, isNot(X_SCROLL));
      expect(scrollPos.dy, isNot(Y_SCROLL));
      expect(recordedPosition?.x, isNot(X_SCROLL));
      expect(recordedPosition?.y, isNot(Y_SCROLL));

      await controller.scrollTo(X_SCROLL, Y_SCROLL);
      scrollPos = await controller.getScrollPosition();
      expect(scrollPos.dx, X_SCROLL);
      expect(scrollPos.dy, Y_SCROLL);
      expect(recordedPosition?.x, X_SCROLL);
      expect(recordedPosition?.y, Y_SCROLL);

      // Check scrollBy() (on top of scrollTo())
      await controller.scrollBy(X_SCROLL, Y_SCROLL);
      scrollPos = await controller.getScrollPosition();
      expect(scrollPos.dx, X_SCROLL * 2);
      expect(scrollPos.dy, Y_SCROLL * 2);
      expect(recordedPosition?.x, X_SCROLL * 2);
      expect(recordedPosition?.y, Y_SCROLL * 2);
    });
  },
      // Scroll position is currently not implemented for macOS.
      // Flakes on iOS: https://github.com/flutter/flutter/issues/154826
      skip: Platform.isMacOS || Platform.isIOS);

  group('NavigationDelegate', () {
    const String blankPage = '<!DOCTYPE html><head></head><body></body></html>';
    final String blankPageEncoded = 'data:text/html;charset=utf-8;base64,'
        '${base64Encode(const Utf8Encoder().convert(blankPage))}';

    testWidgets('can allow requests', (WidgetTester tester) async {
      Completer<void> pageLoaded = Completer<void>();

      final WebViewController controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => pageLoaded.complete(),
        onNavigationRequest: (NavigationRequest navigationRequest) {
          return navigationRequest.url.contains('youtube.com')
              ? NavigationDecision.prevent
              : NavigationDecision.navigate;
        },
      ));

      await tester.pumpWidget(WebViewWidget(controller: controller));

      await controller.loadRequest(Uri.parse(blankPageEncoded));

      await pageLoaded.future; // Wait for initial page load.

      pageLoaded = Completer<void>();
      await controller.runJavaScript('location.href = "$secondaryUrl"');
      await pageLoaded.future; // Wait for the next page load.

      final String? currentUrl = await controller.currentUrl();
      expect(currentUrl, secondaryUrl);
    });

    testWidgets('onWebResourceError', (WidgetTester tester) async {
      final Completer<WebResourceError> errorCompleter =
          Completer<WebResourceError>();

      final WebViewController controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setNavigationDelegate(
          NavigationDelegate(onWebResourceError: (WebResourceError error) {
        errorCompleter.complete(error);
      }));
      await controller.loadRequest(Uri.parse('https://www.notawebsite..com'));

      await tester.pumpWidget(WebViewWidget(controller: controller));

      final WebResourceError error = await errorCompleter.future;
      expect(error, isNotNull);
    });

    testWidgets('onWebResourceError is not called with valid url',
        (WidgetTester tester) async {
      final Completer<WebResourceError> errorCompleter =
          Completer<WebResourceError>();
      final Completer<void> pageFinishCompleter = Completer<void>();

      final WebViewController controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => pageFinishCompleter.complete(),
        onWebResourceError: (WebResourceError error) {
          errorCompleter.complete(error);
        },
      ));
      await controller.loadRequest(
        Uri.parse('data:text/html;charset=utf-8;base64,PCFET0NUWVBFIGh0bWw+'),
      );

      await tester.pumpWidget(WebViewWidget(controller: controller));

      expect(errorCompleter.future, doesNotComplete);
      await pageFinishCompleter.future;
    });

    testWidgets('can block requests', (WidgetTester tester) async {
      Completer<void> pageLoaded = Completer<void>();

      final WebViewController controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setNavigationDelegate(NavigationDelegate(
          onPageFinished: (_) => pageLoaded.complete(),
          onNavigationRequest: (NavigationRequest navigationRequest) {
            return navigationRequest.url.contains('youtube.com')
                ? NavigationDecision.prevent
                : NavigationDecision.navigate;
          }));

      await tester.pumpWidget(WebViewWidget(controller: controller));

      await controller.loadRequest(Uri.parse(blankPageEncoded));

      await pageLoaded.future; // Wait for initial page load.

      pageLoaded = Completer<void>();
      await controller
          .runJavaScript('location.href = "https://www.youtube.com/"');

      // There should never be any second page load, since our new URL is
      // blocked. Still wait for a potential page change for some time in order
      // to give the test a chance to fail.
      await pageLoaded.future
          .timeout(const Duration(milliseconds: 500), onTimeout: () => '');
      final String? currentUrl = await controller.currentUrl();
      expect(currentUrl, isNot(contains('youtube.com')));
    });

    testWidgets('onHttpError', (WidgetTester tester) async {
      final Completer<HttpResponseError> errorCompleter =
          Completer<HttpResponseError>();

      final WebViewController controller = WebViewController();
      unawaited(controller.setJavaScriptMode(JavaScriptMode.unrestricted));

      final NavigationDelegate delegate = NavigationDelegate(
        onHttpError: (HttpResponseError error) {
          errorCompleter.complete(error);
        },
      );
      unawaited(controller.setNavigationDelegate(delegate));

      unawaited(controller.loadRequest(
        Uri.parse('$prefixUrl/favicon.ico'),
      ));

      await tester.pumpWidget(WebViewWidget(controller: controller));

      final HttpResponseError error = await errorCompleter.future;

      expect(error, isNotNull);
      expect(error.response?.statusCode, 404);
    });

    testWidgets('onHttpError is not called when no HTTP error is received',
        (WidgetTester tester) async {
      const String testPage = '''
        <!DOCTYPE html><html>
        </head>
        <body>
        </body>
        </html>
      ''';

      final Completer<HttpResponseError> errorCompleter =
          Completer<HttpResponseError>();
      final Completer<void> pageFinishCompleter = Completer<void>();

      final WebViewController controller = WebViewController();
      unawaited(controller.setJavaScriptMode(JavaScriptMode.unrestricted));

      final NavigationDelegate delegate = NavigationDelegate(
        onPageFinished: pageFinishCompleter.complete,
        onHttpError: (HttpResponseError error) {
          errorCompleter.complete(error);
        },
      );
      unawaited(controller.setNavigationDelegate(delegate));

      unawaited(controller.loadHtmlString(testPage));

      await tester.pumpWidget(WebViewWidget(controller: controller));

      expect(errorCompleter.future, doesNotComplete);
      await pageFinishCompleter.future;
    });

    testWidgets('supports asynchronous decisions', (WidgetTester tester) async {
      Completer<void> pageLoaded = Completer<void>();

      final WebViewController controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setNavigationDelegate(NavigationDelegate(
          onPageFinished: (_) => pageLoaded.complete(),
          onNavigationRequest: (NavigationRequest navigationRequest) async {
            NavigationDecision decision = NavigationDecision.prevent;
            decision = await Future<NavigationDecision>.delayed(
                const Duration(milliseconds: 10),
                () => NavigationDecision.navigate);
            return decision;
          }));

      await tester.pumpWidget(WebViewWidget(controller: controller));

      await controller.loadRequest(Uri.parse(blankPageEncoded));

      await pageLoaded.future; // Wait for initial page load.

      pageLoaded = Completer<void>();
      await controller.runJavaScript('location.href = "$secondaryUrl"');
      await pageLoaded.future; // Wait for second page to load.

      final String? currentUrl = await controller.currentUrl();
      expect(currentUrl, secondaryUrl);
    });

    testWidgets('can receive url changes', (WidgetTester tester) async {
      final Completer<void> pageLoaded = Completer<void>();

      final WebViewController controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => pageLoaded.complete(),
      ));
      await controller.loadRequest(Uri.parse(blankPageEncoded));

      await tester.pumpWidget(WebViewWidget(controller: controller));

      await pageLoaded.future;

      final Completer<String> urlChangeCompleter = Completer<String>();
      await controller.setNavigationDelegate(NavigationDelegate(
        onUrlChange: (UrlChange change) {
          urlChangeCompleter.complete(change.url);
        },
      ));

      await controller.runJavaScript('location.href = "$primaryUrl"');

      await expectLater(urlChangeCompleter.future, completion(primaryUrl));
    });

    testWidgets('can receive updates to history state',
        (WidgetTester tester) async {
      final Completer<void> pageLoaded = Completer<void>();

      final NavigationDelegate navigationDelegate = NavigationDelegate(
        onPageFinished: (_) => pageLoaded.complete(),
      );

      final WebViewController controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setNavigationDelegate(navigationDelegate);
      await controller.loadRequest(Uri.parse(primaryUrl));

      await tester.pumpWidget(WebViewWidget(controller: controller));

      await pageLoaded.future;

      final Completer<String> urlChangeCompleter = Completer<String>();
      await controller.setNavigationDelegate(NavigationDelegate(
        onUrlChange: (UrlChange change) {
          urlChangeCompleter.complete(change.url);
        },
      ));

      await controller.runJavaScript(
        'window.history.pushState({}, "", "secondary.txt");',
      );

      await expectLater(urlChangeCompleter.future, completion(secondaryUrl));
    });

    testWidgets('can receive HTTP basic auth requests',
        (WidgetTester tester) async {
      final Completer<void> authRequested = Completer<void>();
      final WebViewController controller = WebViewController();

      await controller.setNavigationDelegate(
        NavigationDelegate(
          onHttpAuthRequest: (HttpAuthRequest request) =>
              authRequested.complete(),
        ),
      );

      await tester.pumpWidget(WebViewWidget(controller: controller));

      await controller.loadRequest(Uri.parse(basicAuthUrl));

      await expectLater(authRequested.future, completes);
    });

    testWidgets('can authenticate to HTTP basic auth requests',
        (WidgetTester tester) async {
      final WebViewController controller = WebViewController();
      final Completer<void> pageFinished = Completer<void>();

      await controller.setNavigationDelegate(NavigationDelegate(
        onHttpAuthRequest: (HttpAuthRequest request) => request.onProceed(
          const WebViewCredential(
            user: 'user',
            password: 'password',
          ),
        ),
        onPageFinished: (_) => pageFinished.complete(),
        onWebResourceError: (_) => fail('Authentication failed'),
      ));

      await tester.pumpWidget(WebViewWidget(controller: controller));

      await controller.loadRequest(Uri.parse(basicAuthUrl));

      await expectLater(pageFinished.future, completes);
    });
  });

  testWidgets('target _blank opens in same window',
      (WidgetTester tester) async {
    final Completer<void> pageLoaded = Completer<void>();

    final WebViewController controller = WebViewController();
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setNavigationDelegate(NavigationDelegate(
      onPageFinished: (_) => pageLoaded.complete(),
    ));

    await tester.pumpWidget(WebViewWidget(controller: controller));

    await controller.runJavaScript('window.open("$primaryUrl", "_blank")');
    await pageLoaded.future;
    final String? currentUrl = await controller.currentUrl();
    expect(currentUrl, primaryUrl);
  });

  testWidgets(
    'can open new window and go back',
    (WidgetTester tester) async {
      Completer<void> pageLoaded = Completer<void>();

      final WebViewController controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => pageLoaded.complete(),
      ));
      await controller.loadRequest(Uri.parse(primaryUrl));

      await tester.pumpWidget(WebViewWidget(controller: controller));

      expect(controller.currentUrl(), completion(primaryUrl));
      await pageLoaded.future;
      pageLoaded = Completer<void>();

      await controller.runJavaScript('window.open("$secondaryUrl")');
      await pageLoaded.future;
      pageLoaded = Completer<void>();
      expect(controller.currentUrl(), completion(secondaryUrl));

      expect(controller.canGoBack(), completion(true));
      await controller.goBack();
      await pageLoaded.future;
      await expectLater(controller.currentUrl(), completion(primaryUrl));
    },
  );

  testWidgets(
    'clearLocalStorage',
    (WidgetTester tester) async {
      Completer<void> pageLoadCompleter = Completer<void>();

      final WebViewController controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => pageLoadCompleter.complete(),
      ));
      await controller.loadRequest(Uri.parse(primaryUrl));

      await tester.pumpWidget(WebViewWidget(controller: controller));

      await pageLoadCompleter.future;
      pageLoadCompleter = Completer<void>();

      await controller.runJavaScript('localStorage.setItem("myCat", "Tom");');
      final String myCatItem = await controller.runJavaScriptReturningResult(
        'localStorage.getItem("myCat");',
      ) as String;
      expect(myCatItem, _webViewString('Tom'));

      await controller.clearLocalStorage();

      // Reload page to have changes take effect.
      await controller.reload();
      await pageLoadCompleter.future;

      late final String? nullItem;
      try {
        nullItem = await controller.runJavaScriptReturningResult(
          'localStorage.getItem("myCat");',
        ) as String;
      } catch (exception) {
        if (_isWKWebView() &&
            exception is ArgumentError &&
            (exception.message as String).contains(
                'Result of JavaScript execution returned a `null` value.')) {
          nullItem = '<null>';
        }
      }
      expect(nullItem, _webViewNull());
    },
  );
}

// JavaScript `null` evaluate to different string values per platform.
// This utility method returns the string boolean value of the current platform.
String _webViewNull() {
  if (_isWKWebView()) {
    return '<null>';
  }
  return 'null';
}

// JavaScript String evaluates to different strings depending on the platform.
// This utility method returns the string boolean value of the current platform.
String _webViewString(String value) {
  if (_isWKWebView()) {
    return value;
  }
  return '"$value"';
}

bool _isWKWebView() {
  return defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;
}

class ResizableWebView extends StatefulWidget {
  const ResizableWebView({
    super.key,
    required this.onResize,
    required this.onPageFinished,
  });

  final VoidCallback onResize;
  final VoidCallback onPageFinished;

  @override
  State<StatefulWidget> createState() => ResizableWebViewState();
}

class ResizableWebViewState extends State<ResizableWebView> {
  late final WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(NavigationDelegate(
      onPageFinished: (_) => widget.onPageFinished(),
    ))
    ..addJavaScriptChannel(
      'Resize',
      onMessageReceived: (_) {
        widget.onResize();
      },
    )
    ..loadRequest(
      Uri.parse(
        'data:text/html;charset=utf-8;base64,${base64Encode(const Utf8Encoder().convert(resizePage))}',
      ),
    );

  double webViewWidth = 200;
  double webViewHeight = 200;

  static const String resizePage = '''
        <!DOCTYPE html><html>
        <head><title>Resize test</title>
          <script type="text/javascript">
            function onResize() {
              Resize.postMessage("resize");
            }
            function onLoad() {
              window.onresize = onResize;
            }
          </script>
        </head>
        <body onload="onLoad();" bgColor="blue">
        </body>
        </html>
      ''';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: <Widget>[
          SizedBox(
              width: webViewWidth,
              height: webViewHeight,
              child: WebViewWidget(controller: controller)),
          TextButton(
            key: const Key('resizeButton'),
            onPressed: () {
              setState(() {
                webViewWidth += 100.0;
                webViewHeight += 100.0;
              });
            },
            child: const Text('ResizeButton'),
          ),
        ],
      ),
    );
  }
}
