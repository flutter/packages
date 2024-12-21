// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
// ignore: implementation_imports
import 'package:webview_flutter_platform_interface/src/webview_flutter_platform_interface_legacy.dart';

import '../common/platform_webview.dart';
import '../common/weak_reference_utils.dart';
import '../common/web_kit.g.dart';
import '../common/webkit_constants.dart';

/// A [Widget] that displays a [WKWebView].
class WebKitWebViewWidget extends StatefulWidget {
  /// Constructs a [WebKitWebViewWidget].
  const WebKitWebViewWidget({
    super.key,
    required this.creationParams,
    required this.callbacksHandler,
    required this.javascriptChannelRegistry,
    required this.onBuildWidget,
    this.configuration,
    @visibleForTesting this.webViewProxy = const WebViewWidgetProxy(),
  });

  /// The initial parameters used to setup the WebView.
  final CreationParams creationParams;

  /// The handler of callbacks made made by [NavigationDelegate].
  final WebViewPlatformCallbacksHandler callbacksHandler;

  /// Manager of named JavaScript channels and forwarding incoming messages on the correct channel.
  final JavascriptChannelRegistry javascriptChannelRegistry;

  /// A collection of properties used to initialize a web view.
  ///
  /// If null, a default configuration is used.
  final WKWebViewConfiguration? configuration;

  /// The handler for constructing [WKWebView]s and calling static methods.
  ///
  /// This should only be changed for testing purposes.
  final WebViewWidgetProxy webViewProxy;

  /// A callback to build a widget once [WKWebView] has been initialized.
  final Widget Function(WebKitWebViewPlatformController controller)
      onBuildWidget;

  @override
  State<StatefulWidget> createState() => _WebKitWebViewWidgetState();
}

class _WebKitWebViewWidgetState extends State<WebKitWebViewWidget> {
  late final WebKitWebViewPlatformController controller;

  @override
  void initState() {
    super.initState();
    controller = WebKitWebViewPlatformController(
      creationParams: widget.creationParams,
      callbacksHandler: widget.callbacksHandler,
      javascriptChannelRegistry: widget.javascriptChannelRegistry,
      configuration: widget.configuration,
      webViewProxy: widget.webViewProxy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.onBuildWidget(controller);
  }
}

/// An implementation of [WebViewPlatformController] with the WebKit api.
class WebKitWebViewPlatformController extends WebViewPlatformController {
  /// Construct a [WebKitWebViewPlatformController].
  WebKitWebViewPlatformController({
    required CreationParams creationParams,
    required this.callbacksHandler,
    required this.javascriptChannelRegistry,
    WKWebViewConfiguration? configuration,
    @visibleForTesting this.webViewProxy = const WebViewWidgetProxy(),
  }) : super(callbacksHandler) {
    _setCreationParams(
      creationParams,
      configuration: configuration ?? WKWebViewConfiguration(),
    );
  }

  bool _zoomEnabled = true;
  bool _hasNavigationDelegate = false;
  bool _progressObserverSet = false;

  final Map<String, WKScriptMessageHandler> _scriptMessageHandlers =
      <String, WKScriptMessageHandler>{};

  /// Handles callbacks that are made by navigation.
  final WebViewPlatformCallbacksHandler callbacksHandler;

  /// Manages named JavaScript channels and forwarding incoming messages on the correct channel.
  final JavascriptChannelRegistry javascriptChannelRegistry;

  /// Handles constructing a [WKWebView].
  ///
  /// This should only be changed when used for testing.
  final WebViewWidgetProxy webViewProxy;

  /// Represents the WebView maintained by platform code.
  late final PlatformWebView webView;

  /// Used to integrate custom user interface elements into web view interactions.
  @visibleForTesting
  late final WKUIDelegate uiDelegate = webViewProxy.createUIDelgate(
    onCreateWebView: (
      WKUIDelegate instance,
      WKWebView webView,
      WKWebViewConfiguration configuration,
      WKNavigationAction navigationAction,
    ) {
      final bool isForMainFrame =
          navigationAction.targetFrame?.isMainFrame ?? false;
      if (!isForMainFrame) {
        PlatformWebView.fromNativeWebView(webView).load(
          navigationAction.request,
        );
      }
    },
  );

  /// Methods for handling navigation changes and tracking navigation requests.
  @visibleForTesting
  late final WKNavigationDelegate navigationDelegate = withWeakReferenceTo(
    this,
    (WeakReference<WebKitWebViewPlatformController> weakReference) {
      return webViewProxy.createNavigationDelegate(
        didFinishNavigation: (_, __, String? url) {
          weakReference.target?.callbacksHandler.onPageFinished(url ?? '');
        },
        didStartProvisionalNavigation: (_, __, String? url) {
          weakReference.target?.callbacksHandler.onPageStarted(url ?? '');
        },
        decidePolicyForNavigationAction: (
          _,
          __,
          WKNavigationAction action,
        ) async {
          if (weakReference.target == null) {
            return NavigationActionPolicy.allow;
          }

          if (!weakReference.target!._hasNavigationDelegate) {
            return NavigationActionPolicy.allow;
          }

          final bool allow =
              await weakReference.target!.callbacksHandler.onNavigationRequest(
            url: await action.request.getUrl() ?? '',
            isForMainFrame: action.targetFrame?.isMainFrame ?? false,
          );

          return allow
              ? NavigationActionPolicy.allow
              : NavigationActionPolicy.cancel;
        },
        didFailNavigation: (_, __, NSError error) {
          weakReference.target?.callbacksHandler.onWebResourceError(
            _toWebResourceError(error),
          );
        },
        didFailProvisionalNavigation: (_, __, NSError error) {
          weakReference.target?.callbacksHandler.onWebResourceError(
            _toWebResourceError(error),
          );
        },
        webViewWebContentProcessDidTerminate: (_, __) {
          weakReference.target?.callbacksHandler.onWebResourceError(
            WebResourceError(
              errorCode: WKErrorCode.webContentProcessTerminated,
              // Value from https://developer.apple.com/documentation/webkit/wkerrordomain?language=objc.
              domain: 'WKErrorDomain',
              description: '',
              errorType: WebResourceErrorType.webContentProcessTerminated,
            ),
          );
        },
        decidePolicyForNavigationResponse: (_, __, ___) async {
          return NavigationResponsePolicy.allow;
        },
        didReceiveAuthenticationChallenge: (_, __, ___) async {
          return AuthenticationChallengeResponse(
            disposition:
                UrlSessionAuthChallengeDisposition.performDefaultHandling,
          );
        },
      );
    },
  );

  Future<void> _setCreationParams(
    CreationParams params, {
    required WKWebViewConfiguration configuration,
  }) async {
    _setWebViewConfiguration(
      configuration,
      allowsInlineMediaPlayback: params.webSettings?.allowsInlineMediaPlayback,
      autoMediaPlaybackPolicy: params.autoMediaPlaybackPolicy,
    );

    webView = webViewProxy.createWebView(
      configuration,
      observeValue: withWeakReferenceTo(
        callbacksHandler,
        (WeakReference<WebViewPlatformCallbacksHandler> weakReference) {
          return (
            String keyPath,
            NSObject object,
            Map<KeyValueChangeKey, Object?> change,
          ) {
            final double progress =
                change[KeyValueChangeKey.newValue]! as double;
            weakReference.target?.onProgress((progress * 100).round());
          };
        },
      ),
    );

    unawaited(webView.setUIDelegate(uiDelegate));

    await addJavascriptChannels(params.javascriptChannelNames);

    unawaited(webView.setNavigationDelegate(navigationDelegate));

    if (params.userAgent != null) {
      unawaited(webView.setCustomUserAgent(params.userAgent));
    }

    if (params.webSettings != null) {
      unawaited(updateSettings(params.webSettings!));
    }

    if (params.backgroundColor != null) {
      unawaited(webView.setOpaque(false));
      unawaited(webView.setBackgroundColor(Colors.transparent.value));
      unawaited(
        webView.scrollView.setBackgroundColor(params.backgroundColor?.value),
      );
    }

    if (params.initialUrl != null) {
      await loadUrl(params.initialUrl!, null);
    }
  }

  void _setWebViewConfiguration(
    WKWebViewConfiguration configuration, {
    required bool? allowsInlineMediaPlayback,
    required AutoMediaPlaybackPolicy autoMediaPlaybackPolicy,
  }) {
    if (allowsInlineMediaPlayback != null) {
      configuration.setAllowsInlineMediaPlayback(allowsInlineMediaPlayback);
    }

    late final bool requiresUserAction;
    switch (autoMediaPlaybackPolicy) {
      case AutoMediaPlaybackPolicy.require_user_action_for_all_media_types:
        requiresUserAction = true;
      case AutoMediaPlaybackPolicy.always_allow:
        requiresUserAction = false;
    }

    configuration.setMediaTypesRequiringUserActionForPlayback(
      requiresUserAction ? AudiovisualMediaType.all : AudiovisualMediaType.none,
    );
  }

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) {
    return webView.loadHtmlString(html, baseUrl);
  }

  @override
  Future<void> loadFile(String absoluteFilePath) async {
    await webView.loadFileUrl(
      absoluteFilePath,
      path.dirname(absoluteFilePath),
    );
  }

  @override
  Future<void> clearCache() async {
    final WKWebsiteDataStore dataStore =
        await webView.configuration.getWebsiteDataStore();
    await dataStore.removeDataOfTypes(
      <WebsiteDataType>[
        WebsiteDataType.memoryCache,
        WebsiteDataType.diskCache,
        WebsiteDataType.offlineWebApplicationCache,
        WebsiteDataType.localStorage,
      ],
      0,
    );
  }

  @override
  Future<void> loadFlutterAsset(String key) async {
    assert(key.isNotEmpty);
    return webView.loadFlutterAsset(key);
  }

  @override
  Future<void> loadUrl(String url, Map<String, String>? headers) async {
    final URLRequest request = webViewProxy.createRequest(url: url);
    unawaited(
      request.setAllHttpHeaderFields(headers ?? const <String, String>{}),
    );
    return webView.load(request);
  }

  @override
  Future<void> loadRequest(WebViewRequest request) async {
    if (!request.uri.hasScheme) {
      throw ArgumentError('WebViewRequest#uri is required to have a scheme.');
    }

    final URLRequest urlRequest = webViewProxy.createRequest(
      url: request.uri.toString(),
    );
    unawaited(urlRequest.setAllHttpHeaderFields(request.headers));
    unawaited(urlRequest.setHttpMethod(request.method.name));
    unawaited(urlRequest.setHttpBody(request.body));

    return webView.load(urlRequest);
  }

  @override
  Future<bool> canGoBack() => webView.canGoBack();

  @override
  Future<bool> canGoForward() => webView.canGoForward();

  @override
  Future<void> goBack() => webView.goBack();

  @override
  Future<void> goForward() => webView.goForward();

  @override
  Future<void> reload() => webView.reload();

  @override
  Future<String> evaluateJavascript(String javascript) async {
    final Object? result = await webView.evaluateJavaScript(javascript);
    return _asObjectiveCString(result);
  }

  @override
  Future<void> runJavascript(String javascript) async {
    try {
      await webView.evaluateJavaScript(javascript);
    } on PlatformException catch (exception) {
      // WebKit will throw an error when the type of the evaluated value is
      // unsupported. This also goes for `null` and `undefined` on iOS 14+. For
      // example, when running a void function. For ease of use, this specific
      // error is ignored when no return value is expected.
      final Object? details = exception.details;
      if (details is! NSError ||
          details.code != WKErrorCode.javaScriptResultTypeIsUnsupported) {
        rethrow;
      }
    }
  }

  @override
  Future<String> runJavascriptReturningResult(String javascript) async {
    final Object? result = await webView.evaluateJavaScript(javascript);
    if (result == null) {
      throw ArgumentError(
        'Result of JavaScript execution returned a `null` value. '
        'Use `runJavascript` when expecting a null return value.',
      );
    }
    return _asObjectiveCString(result);
  }

  @override
  Future<String?> getTitle() => webView.getTitle();

  @override
  Future<String?> currentUrl() => webView.getUrl();

  @override
  Future<void> scrollTo(int x, int y) {
    return webView.scrollView.setContentOffset(x.toDouble(), y.toDouble());
  }

  @override
  Future<void> scrollBy(int x, int y) async {
    return webView.scrollView.scrollBy(x.toDouble(), y.toDouble());
  }

  @override
  Future<int> getScrollX() async {
    final List<double> offset = await webView.scrollView.getContentOffset();
    return offset[0].toInt();
  }

  @override
  Future<int> getScrollY() async {
    final List<double> offset = await webView.scrollView.getContentOffset();
    return offset[1].toInt();
  }

  @override
  Future<void> updateSettings(WebSettings setting) async {
    if (setting.hasNavigationDelegate != null) {
      _hasNavigationDelegate = setting.hasNavigationDelegate!;
    }
    await Future.wait(<Future<void>>[
      _setUserAgent(setting.userAgent),
      if (setting.hasProgressTracking != null)
        _setHasProgressTracking(setting.hasProgressTracking!),
      if (setting.javascriptMode != null)
        _setJavaScriptMode(setting.javascriptMode!),
      if (setting.zoomEnabled != null) _setZoomEnabled(setting.zoomEnabled!),
      if (setting.gestureNavigationEnabled != null)
        webView.setAllowsBackForwardNavigationGestures(
          setting.gestureNavigationEnabled!,
        ),
    ]);
  }

  @override
  Future<void> addJavascriptChannels(Set<String> javascriptChannelNames) async {
    await Future.wait<void>(
      javascriptChannelNames.where(
        (String channelName) {
          return !_scriptMessageHandlers.containsKey(channelName);
        },
      ).map<Future<void>>(
        (String channelName) async {
          final WKScriptMessageHandler handler =
              webViewProxy.createScriptMessageHandler(
            didReceiveScriptMessage: withWeakReferenceTo(
              javascriptChannelRegistry,
              (WeakReference<JavascriptChannelRegistry> weakReference) {
                return (
                  WKScriptMessageHandler instance,
                  WKUserContentController userContentController,
                  WKScriptMessage message,
                ) {
                  weakReference.target?.onJavascriptChannelMessage(
                    message.name,
                    message.body!.toString(),
                  );
                };
              },
            ),
          );
          _scriptMessageHandlers[channelName] = handler;

          final String wrapperSource =
              'window.$channelName = webkit.messageHandlers.$channelName;';
          final WKUserScript wrapperScript = WKUserScript(
            source: wrapperSource,
            injectionTime: UserScriptInjectionTime.atDocumentStart,
            isForMainFrameOnly: false,
          );
          final WKUserContentController controller =
              await webView.configuration.getUserContentController();
          unawaited(controller.addUserScript(wrapperScript));
          await controller.addScriptMessageHandler(
            handler,
            channelName,
          );
        },
      ),
    );
  }

  @override
  Future<void> removeJavascriptChannels(
    Set<String> javascriptChannelNames,
  ) async {
    if (javascriptChannelNames.isEmpty) {
      return;
    }

    await _resetUserScripts(removedJavaScriptChannels: javascriptChannelNames);
  }

  Future<void> _setHasProgressTracking(bool hasProgressTracking) async {
    if (hasProgressTracking) {
      _progressObserverSet = true;
      await webView.addObserver(
        webView.nativeWebView,
        'estimatedProgress',
        <KeyValueObservingOptions>[KeyValueObservingOptions.newValue],
      );
    } else if (_progressObserverSet) {
      // Calls to removeObserver before addObserver causes a crash.
      _progressObserverSet = false;
      await webView.removeObserver(webView.nativeWebView, 'estimatedProgress');
    }
  }

  Future<void> _setJavaScriptMode(JavascriptMode mode) async {
    final WKPreferences preferences =
        await webView.configuration.getPreferences();
    switch (mode) {
      case JavascriptMode.disabled:
        await preferences.setJavaScriptEnabled(false);
      case JavascriptMode.unrestricted:
        await preferences.setJavaScriptEnabled(true);
    }
  }

  Future<void> _setUserAgent(WebSetting<String?> userAgent) async {
    if (userAgent.isPresent) {
      await webView.setCustomUserAgent(userAgent.value);
    }
  }

  Future<void> _setZoomEnabled(bool zoomEnabled) async {
    if (_zoomEnabled == zoomEnabled) {
      return;
    }

    _zoomEnabled = zoomEnabled;
    if (!zoomEnabled) {
      return _disableZoom();
    }

    return _resetUserScripts();
  }

  Future<void> _disableZoom() async {
    final WKUserScript userScript = WKUserScript(
      source: "var meta = document.createElement('meta');\n"
          "meta.name = 'viewport';\n"
          "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, "
          "user-scalable=no';\n"
          "var head = document.getElementsByTagName('head')[0];head.appendChild(meta);",
      injectionTime: UserScriptInjectionTime.atDocumentEnd,
      isForMainFrameOnly: true,
    );
    final WKUserContentController controller =
        await webView.configuration.getUserContentController();
    return controller.addUserScript(userScript);
  }

  // WkWebView does not support removing a single user script, so all user
  // scripts and all message handlers are removed instead. And the JavaScript
  // channels that shouldn't be removed are re-registered. Note that this
  // workaround could interfere with exposing support for custom scripts from
  // applications.
  Future<void> _resetUserScripts({
    Set<String> removedJavaScriptChannels = const <String>{},
  }) async {
    final WKUserContentController controller =
        await webView.configuration.getUserContentController();
    unawaited(controller.removeAllUserScripts());
    // TODO(bparrishMines): This can be replaced with
    // `removeAllScriptMessageHandlers` once Dart supports runtime version
    // checking. (e.g. The equivalent to @availability in Objective-C.)
    _scriptMessageHandlers.keys.forEach(controller.removeScriptMessageHandler);

    removedJavaScriptChannels.forEach(_scriptMessageHandlers.remove);
    final Set<String> remainingNames = _scriptMessageHandlers.keys.toSet();
    _scriptMessageHandlers.clear();

    await Future.wait(<Future<void>>[
      addJavascriptChannels(remainingNames),
      // Zoom is disabled with a WKUserScript, so this adds it back if it was
      // removed above.
      if (!_zoomEnabled) _disableZoom(),
    ]);
  }

  static WebResourceError _toWebResourceError(NSError error) {
    WebResourceErrorType? errorType;

    switch (error.code) {
      case WKErrorCode.unknown:
        errorType = WebResourceErrorType.unknown;
      case WKErrorCode.webContentProcessTerminated:
        errorType = WebResourceErrorType.webContentProcessTerminated;
      case WKErrorCode.webViewInvalidated:
        errorType = WebResourceErrorType.webViewInvalidated;
      case WKErrorCode.javaScriptExceptionOccurred:
        errorType = WebResourceErrorType.javaScriptExceptionOccurred;
      case WKErrorCode.javaScriptResultTypeIsUnsupported:
        errorType = WebResourceErrorType.javaScriptResultTypeIsUnsupported;
    }

    return WebResourceError(
      errorCode: error.code,
      domain: error.domain,
      description: error.userInfo[NSErrorUserInfoKey.NSLocalizedDescription]
              as String? ??
          '',
      errorType: errorType,
    );
  }

  // The legacy implementation of webview_flutter_wkwebview would convert
  // objects to strings before returning them to Dart. This method attempts
  // to converts Dart objects to Strings the way it is done in Objective-C
  // to avoid breaking users expecting the same String format.
  // TODO(bparrishMines): Remove this method with the next breaking change.
  // See https://github.com/flutter/flutter/issues/107491
  String _asObjectiveCString(Object? value, {bool inContainer = false}) {
    if (value == null) {
      // An NSNull inside an NSArray or NSDictionary is represented as a String
      // differently than a nil.
      if (inContainer) {
        return '"<null>"';
      }
      return '(null)';
    } else if (value is bool) {
      return value ? '1' : '0';
    } else if (value is double && value.truncate() == value) {
      return value.truncate().toString();
    } else if (value is List) {
      final List<String> stringValues = <String>[];
      for (final Object? listValue in value) {
        stringValues.add(_asObjectiveCString(listValue, inContainer: true));
      }
      return '(${stringValues.join(',')})';
    } else if (value is Map) {
      final List<String> stringValues = <String>[];
      for (final MapEntry<Object?, Object?> entry in value.entries) {
        stringValues.add(
          '${_asObjectiveCString(entry.key, inContainer: true)} '
          '= '
          '${_asObjectiveCString(entry.value, inContainer: true)}',
        );
      }
      return '{${stringValues.join(';')}}';
    }

    return value.toString();
  }
}

/// Handles constructing objects and calling static methods.
///
/// This should only be used for testing purposes.
@visibleForTesting
class WebViewWidgetProxy {
  /// Constructs a [WebViewWidgetProxy].
  const WebViewWidgetProxy({@visibleForTesting this.overriddenIsMacOS});

  /// If set, replaces [Platform] checks when picking implementation classes.
  @visibleForTesting
  final bool? overriddenIsMacOS;

  /// Constructs a [WKWebView].
  PlatformWebView createWebView(
    WKWebViewConfiguration configuration, {
    void Function(
      String keyPath,
      NSObject object,
      Map<KeyValueChangeKey, Object?> change,
    )? observeValue,
  }) {
    return PlatformWebView(initialConfiguration: configuration);
  }

  /// Constructs a [URLRequest].
  URLRequest createRequest({required String url}) {
    return URLRequest(url: url);
  }

  /// Constructs a [WKScriptMessageHandler].
  WKScriptMessageHandler createScriptMessageHandler({
    required void Function(
      WKScriptMessageHandler instance,
      WKUserContentController userContentController,
      WKScriptMessage message,
    ) didReceiveScriptMessage,
  }) {
    return WKScriptMessageHandler(
      didReceiveScriptMessage: didReceiveScriptMessage,
    );
  }

  /// Constructs a [WKUIDelegate].
  WKUIDelegate createUIDelgate({
    void Function(
      WKUIDelegate instance,
      WKWebView webView,
      WKWebViewConfiguration configuration,
      WKNavigationAction navigationAction,
    )? onCreateWebView,
  }) {
    return WKUIDelegate(onCreateWebView: onCreateWebView);
  }

  /// Constructs a [WKNavigationDelegate].
  WKNavigationDelegate createNavigationDelegate({
    void Function(WKNavigationDelegate, WKWebView webView, String? url)?
        didFinishNavigation,
    void Function(WKNavigationDelegate, WKWebView webView, String? url)?
        didStartProvisionalNavigation,
    required Future<NavigationActionPolicy> Function(
      WKNavigationDelegate,
      WKWebView webView,
      WKNavigationAction navigationAction,
    ) decidePolicyForNavigationAction,
    void Function(WKNavigationDelegate, WKWebView webView, NSError error)?
        didFailNavigation,
    void Function(WKNavigationDelegate, WKWebView webView, NSError error)?
        didFailProvisionalNavigation,
    void Function(WKNavigationDelegate, WKWebView webView)?
        webViewWebContentProcessDidTerminate,
    required Future<NavigationResponsePolicy> Function(
      WKNavigationDelegate,
      WKWebView webView,
      WKNavigationResponse navigationResponse,
    ) decidePolicyForNavigationResponse,
    required Future<AuthenticationChallengeResponse> Function(
      WKNavigationDelegate,
      WKWebView webView,
      URLAuthenticationChallenge challenge,
    ) didReceiveAuthenticationChallenge,
  }) {
    return WKNavigationDelegate(
      didFinishNavigation: didFinishNavigation,
      didStartProvisionalNavigation: didStartProvisionalNavigation,
      decidePolicyForNavigationAction: decidePolicyForNavigationAction,
      didFailNavigation: didFailNavigation,
      didFailProvisionalNavigation: didFailProvisionalNavigation,
      webViewWebContentProcessDidTerminate:
          webViewWebContentProcessDidTerminate,
      decidePolicyForNavigationResponse: decidePolicyForNavigationResponse,
      didReceiveAuthenticationChallenge: didReceiveAuthenticationChallenge,
    );
  }
}
