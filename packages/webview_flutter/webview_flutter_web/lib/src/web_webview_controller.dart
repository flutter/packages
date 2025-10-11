// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/helpers.dart';
import 'package:web/web.dart' as web;
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'content_type.dart';
import 'http_request_factory.dart';

/// An implementation of [PlatformWebViewControllerCreationParams] using Flutter
/// for Web API.
@immutable
class WebWebViewControllerCreationParams
    extends PlatformWebViewControllerCreationParams {
  /// Creates a new [WebWebViewControllerCreationParams] instance.
  WebWebViewControllerCreationParams({
    @visibleForTesting this.httpRequestFactory = const HttpRequestFactory(),
  }) : super();

  /// Creates a [WebWebViewControllerCreationParams] instance based on [PlatformWebViewControllerCreationParams].
  WebWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebViewControllerCreationParams params, {
    @visibleForTesting
    HttpRequestFactory httpRequestFactory = const HttpRequestFactory(),
  }) : this(httpRequestFactory: httpRequestFactory);

  static int _nextIFrameId = 0;

  /// Handles creating and sending URL requests.
  final HttpRequestFactory httpRequestFactory;

  /// The underlying element used as the WebView.
  @visibleForTesting
  final web.HTMLIFrameElement iFrame =
      web.HTMLIFrameElement()
        ..id = 'webView${_nextIFrameId++}'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none';

  final Duration _iFrameWaitDelay = const Duration(milliseconds: 100);
}

/// An implementation of [PlatformWebViewController] using Flutter for Web API.
class WebWebViewController extends PlatformWebViewController {
  /// Constructs a [WebWebViewController].
  WebWebViewController(PlatformWebViewControllerCreationParams params)
    : super.implementation(
        params is WebWebViewControllerCreationParams
            ? params
            : WebWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(
              params,
            ),
      );

  WebWebViewControllerCreationParams get _webWebViewParams =>
      params as WebWebViewControllerCreationParams;

  // Retrieves the iFrame's content body after attachment to DOM.
  Future<web.HTMLBodyElement> _getIFrameBody() async {
    final web.Document document = await _getIFrameDocument();

    while (document.body == null) {
      await Future<void>.delayed(_webWebViewParams._iFrameWaitDelay);
    }

    return document.body! as HTMLBodyElement;
  }

  // Retrieves the iFrame's content document after attachment to DOM.
  Future<web.Document> _getIFrameDocument() async {
    try {
      // If the document is not yet available, wait for the 'load' event.
      if (_webWebViewParams.iFrame.contentDocument == null) {
        final Completer<void> completer = Completer<void>();
        _webWebViewParams.iFrame.addEventListener(
          'load',
          (web.Event _) {
            completer.complete();
          }.toJS,
          AddEventListenerOptions(once: true),
        );
        // If src is not set, the iframe will never load.
        if (_webWebViewParams.iFrame.src.isEmpty) {
          _webWebViewParams.iFrame.src = 'about:blank';
        }
        await completer.future;
      }
      // Test origin permission
      _webWebViewParams.iFrame.contentDocument!.body;
      // Return on success
      return _webWebViewParams.iFrame.contentDocument!;
    } catch (_) {
      throw StateError('Web view origin mismatch');
    }
  }

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) {
    final Completer<void> loading = Completer<void>();

    // Load listener for load completion
    _webWebViewParams.iFrame.addEventListener(
      'load',
      () {
        try {
          _webWebViewParams.iFrame.contentDocument?.write(html.toJS);
        } finally {
          loading.complete();
        }
      }.toJS,
      AddEventListenerOptions(once: true),
    );

    // Initiate load
    _webWebViewParams.iFrame.src = baseUrl ?? 'about:blank';

    // Time out in case load listener is not triggered
    Future<void>.delayed(
      const Duration(minutes: 3),
    ).then<void>((_) => loading.complete());

    // Return future completion
    return loading.future;
  }

  @override
  Future<void> loadRequest(LoadRequestParams params) async {
    if (!params.uri.hasScheme) {
      throw ArgumentError(
        'LoadRequestParams#uri is required to have a scheme.',
      );
    }

    if (params.headers.isEmpty &&
        (params.body == null || params.body!.isEmpty) &&
        params.method == LoadRequestMethod.get) {
      _webWebViewParams.iFrame.src = params.uri.toString();
    } else {
      await _updateIFrameFromXhr(params);
    }
  }

  @override
  Future<void> runJavaScript(String javaScript) async {
    final Completer<void> run = Completer<void>();
    final web.Document document = await _getIFrameDocument();
    final web.HTMLBodyElement body = await _getIFrameBody();
    final web.HTMLScriptElement script =
        document.createElement('script') as web.HTMLScriptElement;

    // Load listener for script completion
    script.addEventListener(
      'load',
      () {
        try {
          body.removeChild(script);
        } finally {
          run.complete();
        }
      }.toJS,
      AddEventListenerOptions(once: true),
    );

    // Prepare script
    script.src =
        Uri.dataFromString(
          javaScript,
          mimeType: 'text/javascript',
          encoding: utf8,
        ).toString();

    // Initiate script execution
    body.appendChild(script);

    // Time out in case load listener is not triggered
    unawaited(
      Future<void>.delayed(
        const Duration(seconds: 3),
      ).then<void>((_) => run.complete()),
    );

    // Return future completion
    await run.future;
  }

  /// Performs an AJAX request defined by [params].
  Future<void> _updateIFrameFromXhr(LoadRequestParams params) async {
    final web.Response response =
        await _webWebViewParams.httpRequestFactory.request(
              params.uri.toString(),
              method: params.method.serialize(),
              requestHeaders: params.headers,
              sendData: params.body,
            )
            as web.Response;

    final String header = response.headers.get('content-type') ?? 'text/html';
    final ContentType contentType = ContentType.parse(header);
    final Encoding encoding = Encoding.getByName(contentType.charset) ?? utf8;

    _webWebViewParams.iFrame.src =
        Uri.dataFromString(
          (await response.text().toDart).toDart,
          mimeType: contentType.mimeType,
          encoding: encoding,
        ).toString();
  }
}

/// An implementation of [PlatformWebViewWidget] using Flutter the for Web API.
class WebWebViewWidget extends PlatformWebViewWidget {
  /// Constructs a [WebWebViewWidget].
  WebWebViewWidget(PlatformWebViewWidgetCreationParams params)
    : super.implementation(params) {
    final WebWebViewController controller =
        params.controller as WebWebViewController;
    ui_web.platformViewRegistry.registerViewFactory(
      controller._webWebViewParams.iFrame.id,
      (int viewId) => controller._webWebViewParams.iFrame,
    );
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      key: params.key,
      viewType:
          (params.controller as WebWebViewController)
              ._webWebViewParams
              .iFrame
              .id,
    );
  }
}
