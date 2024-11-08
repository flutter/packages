// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'android_proxy.dart';
import 'android_webview.dart' as android_webview;
import 'android_webview_api_impls.dart';
import 'instance_manager.dart';
import 'platform_views_service_proxy.dart';
import 'weak_reference_utils.dart';

/// Object specifying creation parameters for creating a [AndroidWebViewController].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebViewControllerCreationParams] for
/// more information.
@immutable
class AndroidWebViewControllerCreationParams
    extends PlatformWebViewControllerCreationParams {
  /// Creates a new [AndroidWebViewControllerCreationParams] instance.
  AndroidWebViewControllerCreationParams({
    @visibleForTesting this.androidWebViewProxy = const AndroidWebViewProxy(),
    @visibleForTesting android_webview.WebStorage? androidWebStorage,
  })  : androidWebStorage =
            androidWebStorage ?? android_webview.WebStorage.instance,
        super();

  /// Creates a [AndroidWebViewControllerCreationParams] instance based on [PlatformWebViewControllerCreationParams].
  factory AndroidWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebViewControllerCreationParams params, {
    @visibleForTesting
    AndroidWebViewProxy androidWebViewProxy = const AndroidWebViewProxy(),
    @visibleForTesting android_webview.WebStorage? androidWebStorage,
  }) {
    return AndroidWebViewControllerCreationParams(
      androidWebViewProxy: androidWebViewProxy,
      androidWebStorage:
          androidWebStorage ?? android_webview.WebStorage.instance,
    );
  }

  /// Handles constructing objects and calling static methods for the Android WebView
  /// native library.
  @visibleForTesting
  final AndroidWebViewProxy androidWebViewProxy;

  /// Manages the JavaScript storage APIs provided by the [android_webview.WebView].
  @visibleForTesting
  final android_webview.WebStorage androidWebStorage;
}

/// Android-specific resources that can require permissions.
class AndroidWebViewPermissionResourceType
    extends WebViewPermissionResourceType {
  const AndroidWebViewPermissionResourceType._(super.name);

  /// A resource that will allow sysex messages to be sent to or received from
  /// MIDI devices.
  static const AndroidWebViewPermissionResourceType midiSysex =
      AndroidWebViewPermissionResourceType._('midiSysex');

  /// A resource that belongs to a protected media identifier.
  static const AndroidWebViewPermissionResourceType protectedMediaId =
      AndroidWebViewPermissionResourceType._('protectedMediaId');
}

/// Implementation of the [PlatformWebViewController] with the Android WebView API.
class AndroidWebViewController extends PlatformWebViewController {
  /// Creates a new [AndroidWebViewController].
  AndroidWebViewController(PlatformWebViewControllerCreationParams params)
      : super.implementation(params is AndroidWebViewControllerCreationParams
            ? params
            : AndroidWebViewControllerCreationParams
                .fromPlatformWebViewControllerCreationParams(params)) {
    _webView.settings.setDomStorageEnabled(true);
    _webView.settings.setJavaScriptCanOpenWindowsAutomatically(true);
    _webView.settings.setSupportMultipleWindows(true);
    _webView.settings.setLoadWithOverviewMode(true);
    _webView.settings.setUseWideViewPort(true);
    _webView.settings.setDisplayZoomControls(false);
    _webView.settings.setBuiltInZoomControls(true);

    _webView.setWebChromeClient(_webChromeClient);
  }

  AndroidWebViewControllerCreationParams get _androidWebViewParams =>
      params as AndroidWebViewControllerCreationParams;

  /// The native [android_webview.WebView] being controlled.
  late final android_webview.WebView _webView =
      _androidWebViewParams.androidWebViewProxy.createAndroidWebView(
          onScrollChanged: withWeakReferenceTo(this,
              (WeakReference<AndroidWebViewController> weakReference) {
    return (int left, int top, int oldLeft, int oldTop) async {
      final void Function(ScrollPositionChange)? callback =
          weakReference.target?._onScrollPositionChangedCallback;
      callback?.call(ScrollPositionChange(left.toDouble(), top.toDouble()));
    };
  }));

  late final android_webview.WebChromeClient _webChromeClient =
      _androidWebViewParams.androidWebViewProxy.createAndroidWebChromeClient(
    onProgressChanged: withWeakReferenceTo(this,
        (WeakReference<AndroidWebViewController> weakReference) {
      return (android_webview.WebView webView, int progress) {
        if (weakReference.target?._currentNavigationDelegate?._onProgress !=
            null) {
          weakReference
              .target!._currentNavigationDelegate!._onProgress!(progress);
        }
      };
    }),
    onGeolocationPermissionsShowPrompt: withWeakReferenceTo(this,
        (WeakReference<AndroidWebViewController> weakReference) {
      return (String origin,
          android_webview.GeolocationPermissionsCallback callback) async {
        final OnGeolocationPermissionsShowPrompt? onShowPrompt =
            weakReference.target?._onGeolocationPermissionsShowPrompt;
        if (onShowPrompt != null) {
          final GeolocationPermissionsResponse response = await onShowPrompt(
            GeolocationPermissionsRequestParams(origin: origin),
          );
          return callback.invoke(origin, response.allow, response.retain);
        } else {
          // default don't allow
          return callback.invoke(origin, false, false);
        }
      };
    }),
    onGeolocationPermissionsHidePrompt: withWeakReferenceTo(this,
        (WeakReference<AndroidWebViewController> weakReference) {
      return (android_webview.WebChromeClient instance) {
        final OnGeolocationPermissionsHidePrompt? onHidePrompt =
            weakReference.target?._onGeolocationPermissionsHidePrompt;
        if (onHidePrompt != null) {
          onHidePrompt();
        }
      };
    }),
    onShowCustomView: withWeakReferenceTo(this,
        (WeakReference<AndroidWebViewController> weakReference) {
      return (_, android_webview.View view,
          android_webview.CustomViewCallback callback) {
        final AndroidWebViewController? webViewController =
            weakReference.target;
        if (webViewController == null) {
          callback.onCustomViewHidden();
          return;
        }
        final OnShowCustomWidgetCallback? onShowCallback =
            webViewController._onShowCustomWidgetCallback;
        if (onShowCallback == null) {
          callback.onCustomViewHidden();
          return;
        }
        onShowCallback(
          AndroidCustomViewWidget.private(
            controller: webViewController,
            customView: view,
          ),
          () => callback.onCustomViewHidden(),
        );
      };
    }),
    onHideCustomView: withWeakReferenceTo(this,
        (WeakReference<AndroidWebViewController> weakReference) {
      return (android_webview.WebChromeClient instance) {
        final OnHideCustomWidgetCallback? onHideCustomViewCallback =
            weakReference.target?._onHideCustomWidgetCallback;
        if (onHideCustomViewCallback != null) {
          onHideCustomViewCallback();
        }
      };
    }),
    onShowFileChooser: withWeakReferenceTo(
      this,
      (WeakReference<AndroidWebViewController> weakReference) {
        return (android_webview.WebView webView,
            android_webview.FileChooserParams params) async {
          if (weakReference.target?._onShowFileSelectorCallback != null) {
            return weakReference.target!._onShowFileSelectorCallback!(
              FileSelectorParams._fromFileChooserParams(params),
            );
          }
          return <String>[];
        };
      },
    ),
    onConsoleMessage: withWeakReferenceTo(
      this,
      (WeakReference<AndroidWebViewController> weakReference) {
        return (android_webview.WebChromeClient webChromeClient,
            android_webview.ConsoleMessage consoleMessage) async {
          final void Function(JavaScriptConsoleMessage)? callback =
              weakReference.target?._onConsoleLogCallback;
          if (callback != null) {
            JavaScriptLogLevel logLevel;
            switch (consoleMessage.level) {
              // Android maps `console.debug` to `MessageLevel.TIP`, it seems
              // `MessageLevel.DEBUG` if not being used.
              case ConsoleMessageLevel.debug:
              case ConsoleMessageLevel.tip:
                logLevel = JavaScriptLogLevel.debug;
              case ConsoleMessageLevel.error:
                logLevel = JavaScriptLogLevel.error;
              case ConsoleMessageLevel.warning:
                logLevel = JavaScriptLogLevel.warning;
              case ConsoleMessageLevel.unknown:
              case ConsoleMessageLevel.log:
                logLevel = JavaScriptLogLevel.log;
            }

            callback(JavaScriptConsoleMessage(
              level: logLevel,
              message: consoleMessage.message,
            ));
          }
        };
      },
    ),
    onPermissionRequest: withWeakReferenceTo(
      this,
      (WeakReference<AndroidWebViewController> weakReference) {
        return (_, android_webview.PermissionRequest request) async {
          final void Function(PlatformWebViewPermissionRequest)? callback =
              weakReference.target?._onPermissionRequestCallback;
          if (callback == null) {
            return request.deny();
          } else {
            final Set<WebViewPermissionResourceType> types = request.resources
                .map<WebViewPermissionResourceType?>((String type) {
                  switch (type) {
                    case android_webview.PermissionRequest.videoCapture:
                      return WebViewPermissionResourceType.camera;
                    case android_webview.PermissionRequest.audioCapture:
                      return WebViewPermissionResourceType.microphone;
                    case android_webview.PermissionRequest.midiSysex:
                      return AndroidWebViewPermissionResourceType.midiSysex;
                    case android_webview.PermissionRequest.protectedMediaId:
                      return AndroidWebViewPermissionResourceType
                          .protectedMediaId;
                  }

                  // Type not supported.
                  return null;
                })
                .whereType<WebViewPermissionResourceType>()
                .toSet();

            // If the request didn't contain any permissions recognized by the
            // implementation, deny by default.
            if (types.isEmpty) {
              return request.deny();
            }

            callback(AndroidWebViewPermissionRequest._(
              types: types,
              request: request,
            ));
          }
        };
      },
    ),
    onJsAlert: withWeakReferenceTo(this,
        (WeakReference<AndroidWebViewController> weakReference) {
      return (String url, String message) async {
        final Future<void> Function(JavaScriptAlertDialogRequest)? callback =
            weakReference.target?._onJavaScriptAlert;
        if (callback != null) {
          final JavaScriptAlertDialogRequest request =
              JavaScriptAlertDialogRequest(message: message, url: url);

          await callback.call(request);
        }
        return;
      };
    }),
    onJsConfirm: withWeakReferenceTo(this,
        (WeakReference<AndroidWebViewController> weakReference) {
      return (String url, String message) async {
        final Future<bool> Function(JavaScriptConfirmDialogRequest)? callback =
            weakReference.target?._onJavaScriptConfirm;
        if (callback != null) {
          final JavaScriptConfirmDialogRequest request =
              JavaScriptConfirmDialogRequest(message: message, url: url);
          final bool result = await callback.call(request);
          return result;
        }
        return false;
      };
    }),
    onJsPrompt: withWeakReferenceTo(this,
        (WeakReference<AndroidWebViewController> weakReference) {
      return (String url, String message, String defaultValue) async {
        final Future<String> Function(JavaScriptTextInputDialogRequest)?
            callback = weakReference.target?._onJavaScriptPrompt;
        if (callback != null) {
          final JavaScriptTextInputDialogRequest request =
              JavaScriptTextInputDialogRequest(
                  message: message, url: url, defaultText: defaultValue);
          final String result = await callback.call(request);
          return result;
        }
        return '';
      };
    }),
  );

  /// The native [android_webview.FlutterAssetManager] allows managing assets.
  late final android_webview.FlutterAssetManager _flutterAssetManager =
      _androidWebViewParams.androidWebViewProxy.createFlutterAssetManager();

  final Map<String, AndroidJavaScriptChannelParams> _javaScriptChannelParams =
      <String, AndroidJavaScriptChannelParams>{};

  AndroidNavigationDelegate? _currentNavigationDelegate;

  Future<List<String>> Function(FileSelectorParams)?
      _onShowFileSelectorCallback;

  OnGeolocationPermissionsShowPrompt? _onGeolocationPermissionsShowPrompt;

  OnGeolocationPermissionsHidePrompt? _onGeolocationPermissionsHidePrompt;

  OnShowCustomWidgetCallback? _onShowCustomWidgetCallback;

  OnHideCustomWidgetCallback? _onHideCustomWidgetCallback;

  void Function(PlatformWebViewPermissionRequest)? _onPermissionRequestCallback;

  void Function(JavaScriptConsoleMessage consoleMessage)? _onConsoleLogCallback;

  Future<void> Function(JavaScriptAlertDialogRequest request)?
      _onJavaScriptAlert;
  Future<bool> Function(JavaScriptConfirmDialogRequest request)?
      _onJavaScriptConfirm;
  Future<String> Function(JavaScriptTextInputDialogRequest request)?
      _onJavaScriptPrompt;

  void Function(ScrollPositionChange scrollPositionChange)?
      _onScrollPositionChangedCallback;

  /// Whether to enable the platform's webview content debugging tools.
  ///
  /// Defaults to false.
  static Future<void> enableDebugging(
    bool enabled, {
    @visibleForTesting
    AndroidWebViewProxy webViewProxy = const AndroidWebViewProxy(),
  }) {
    return webViewProxy.setWebContentsDebuggingEnabled(enabled);
  }

  /// Identifier used to retrieve the underlying native `WKWebView`.
  ///
  /// This is typically used by other plugins to retrieve the native `WebView`
  /// from an `InstanceManager`.
  ///
  /// See Java method `WebViewFlutterPlugin.getWebView`.
  int get webViewIdentifier =>
      // ignore: invalid_use_of_visible_for_testing_member
      android_webview.WebView.api.instanceManager.getIdentifier(_webView)!;

  @override
  Future<void> loadFile(
    String absoluteFilePath,
  ) {
    final String url = absoluteFilePath.startsWith('file://')
        ? absoluteFilePath
        : Uri.file(absoluteFilePath).toString();

    _webView.settings.setAllowFileAccess(true);
    return _webView.loadUrl(url, <String, String>{});
  }

  @override
  Future<void> loadFlutterAsset(
    String key,
  ) async {
    final String assetFilePath =
        await _flutterAssetManager.getAssetFilePathByName(key);
    final List<String> pathElements = assetFilePath.split('/');
    final String fileName = pathElements.removeLast();
    final List<String?> paths =
        await _flutterAssetManager.list(pathElements.join('/'));

    if (!paths.contains(fileName)) {
      throw ArgumentError(
        'Asset for key "$key" not found.',
        'key',
      );
    }

    return _webView.loadUrl(
      Uri.file('/android_asset/$assetFilePath').toString(),
      <String, String>{},
    );
  }

  @override
  Future<void> loadHtmlString(
    String html, {
    String? baseUrl,
  }) {
    return _webView.loadDataWithBaseUrl(
      baseUrl: baseUrl,
      data: html,
      mimeType: 'text/html',
    );
  }

  @override
  Future<void> loadRequest(
    LoadRequestParams params,
  ) {
    if (!params.uri.hasScheme) {
      throw ArgumentError('WebViewRequest#uri is required to have a scheme.');
    }
    switch (params.method) {
      case LoadRequestMethod.get:
        return _webView.loadUrl(params.uri.toString(), params.headers);
      case LoadRequestMethod.post:
        return _webView.postUrl(
            params.uri.toString(), params.body ?? Uint8List(0));
    }
    // The enum comes from a different package, which could get a new value at
    // any time, so a fallback case is necessary. Since there is no reasonable
    // default behavior, throw to alert the client that they need an updated
    // version. This is deliberately outside the switch rather than a `default`
    // so that the linter will flag the switch as needing an update.
    // ignore: dead_code
    throw UnimplementedError(
        'This version of `AndroidWebViewController` currently has no '
        'implementation for HTTP method ${params.method.serialize()} in '
        'loadRequest.');
  }

  @override
  Future<String?> currentUrl() => _webView.getUrl();

  @override
  Future<bool> canGoBack() => _webView.canGoBack();

  @override
  Future<bool> canGoForward() => _webView.canGoForward();

  @override
  Future<void> goBack() => _webView.goBack();

  @override
  Future<void> goForward() => _webView.goForward();

  @override
  Future<void> reload() => _webView.reload();

  @override
  Future<void> clearCache() => _webView.clearCache(true);

  @override
  Future<void> clearLocalStorage() =>
      _androidWebViewParams.androidWebStorage.deleteAllData();

  @override
  Future<void> setPlatformNavigationDelegate(
      covariant AndroidNavigationDelegate handler) async {
    _currentNavigationDelegate = handler;
    await Future.wait(<Future<void>>[
      handler.setOnLoadRequest(loadRequest),
      _webView.setWebViewClient(handler.androidWebViewClient),
      _webView.setDownloadListener(handler.androidDownloadListener),
    ]);
  }

  @override
  Future<void> runJavaScript(String javaScript) {
    return _webView.evaluateJavascript(javaScript);
  }

  @override
  Future<Object> runJavaScriptReturningResult(String javaScript) async {
    final String? result = await _webView.evaluateJavascript(javaScript);

    if (result == null) {
      return '';
    } else if (result == 'true') {
      return true;
    } else if (result == 'false') {
      return false;
    }

    return num.tryParse(result) ?? result;
  }

  @override
  Future<void> addJavaScriptChannel(
    JavaScriptChannelParams javaScriptChannelParams,
  ) {
    final AndroidJavaScriptChannelParams androidJavaScriptParams =
        javaScriptChannelParams is AndroidJavaScriptChannelParams
            ? javaScriptChannelParams
            : AndroidJavaScriptChannelParams.fromJavaScriptChannelParams(
                javaScriptChannelParams);

    // When JavaScript channel with the same name exists make sure to remove it
    // before registering the new channel.
    if (_javaScriptChannelParams.containsKey(androidJavaScriptParams.name)) {
      _webView
          .removeJavaScriptChannel(androidJavaScriptParams._javaScriptChannel);
    }

    _javaScriptChannelParams[androidJavaScriptParams.name] =
        androidJavaScriptParams;

    return _webView
        .addJavaScriptChannel(androidJavaScriptParams._javaScriptChannel);
  }

  @override
  Future<void> removeJavaScriptChannel(String javaScriptChannelName) async {
    final AndroidJavaScriptChannelParams? javaScriptChannelParams =
        _javaScriptChannelParams[javaScriptChannelName];
    if (javaScriptChannelParams == null) {
      return;
    }

    _javaScriptChannelParams.remove(javaScriptChannelName);
    return _webView
        .removeJavaScriptChannel(javaScriptChannelParams._javaScriptChannel);
  }

  @override
  Future<String?> getTitle() => _webView.getTitle();

  @override
  Future<void> scrollTo(int x, int y) => _webView.scrollTo(x, y);

  @override
  Future<void> scrollBy(int x, int y) => _webView.scrollBy(x, y);

  @override
  Future<Offset> getScrollPosition() {
    return _webView.getScrollPosition();
  }

  @override
  Future<void> enableZoom(bool enabled) =>
      _webView.settings.setSupportZoom(enabled);

  @override
  Future<void> setBackgroundColor(Color color) =>
      _webView.setBackgroundColor(color);

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) =>
      _webView.settings
          .setJavaScriptEnabled(javaScriptMode == JavaScriptMode.unrestricted);

  @override
  Future<void> setUserAgent(String? userAgent) =>
      _webView.settings.setUserAgentString(userAgent);

  @override
  Future<void> setOnScrollPositionChange(
      void Function(ScrollPositionChange scrollPositionChange)?
          onScrollPositionChange) async {
    _onScrollPositionChangedCallback = onScrollPositionChange;
  }

  /// Sets the restrictions that apply on automatic media playback.
  Future<void> setMediaPlaybackRequiresUserGesture(bool require) {
    return _webView.settings.setMediaPlaybackRequiresUserGesture(require);
  }

  /// Sets the text zoom of the page in percent.
  ///
  /// The default is 100.
  Future<void> setTextZoom(int textZoom) =>
      _webView.settings.setTextZoom(textZoom);

  /// Sets the callback that is invoked when the client should show a file
  /// selector.
  Future<void> setOnShowFileSelector(
    Future<List<String>> Function(FileSelectorParams params)?
        onShowFileSelector,
  ) {
    _onShowFileSelectorCallback = onShowFileSelector;
    return _webChromeClient.setSynchronousReturnValueForOnShowFileChooser(
      onShowFileSelector != null,
    );
  }

  /// Sets a callback that notifies the host application that web content is
  /// requesting permission to access the specified resources.
  ///
  /// Only invoked on Android versions 21+.
  @override
  Future<void> setOnPlatformPermissionRequest(
    void Function(
      PlatformWebViewPermissionRequest request,
    ) onPermissionRequest,
  ) async {
    _onPermissionRequestCallback = onPermissionRequest;
  }

  /// Sets the callback that is invoked when the client request handle geolocation permissions.
  ///
  /// Param [onShowPrompt] notifies the host application that web content from the specified origin is attempting to use the Geolocation API,
  /// but no permission state is currently set for that origin.
  ///
  /// The host application should invoke the specified callback with the desired permission state.
  /// See GeolocationPermissions for details.
  ///
  /// Note that for applications targeting Android N and later SDKs (API level > Build.VERSION_CODES.M)
  /// this method is only called for requests originating from secure origins such as https.
  /// On non-secure origins geolocation requests are automatically denied.
  ///
  /// Param [onHidePrompt] notifies the host application that a request for Geolocation permissions,
  /// made with a previous call to onGeolocationPermissionsShowPrompt() has been canceled.
  /// Any related UI should therefore be hidden.
  ///
  /// See https://developer.android.com/reference/android/webkit/WebChromeClient#onGeolocationPermissionsShowPrompt(java.lang.String,%20android.webkit.GeolocationPermissions.Callback)
  ///
  /// See https://developer.android.com/reference/android/webkit/WebChromeClient#onGeolocationPermissionsHidePrompt()
  Future<void> setGeolocationPermissionsPromptCallbacks({
    OnGeolocationPermissionsShowPrompt? onShowPrompt,
    OnGeolocationPermissionsHidePrompt? onHidePrompt,
  }) async {
    _onGeolocationPermissionsShowPrompt = onShowPrompt;
    _onGeolocationPermissionsHidePrompt = onHidePrompt;
  }

  /// Sets the callbacks that are invoked when the host application wants to
  /// show or hide a custom widget.
  ///
  /// The most common use case these methods are invoked a video element wants
  /// to be displayed in fullscreen.
  ///
  /// The [onShowCustomWidget] notifies the host application that web content
  /// from the specified origin wants to be displayed in a custom widget. After
  /// this call, web content will no longer be rendered in the `WebViewWidget`,
  /// but will instead be rendered in the custom widget. The application may
  /// explicitly exit fullscreen mode by invoking `onCustomWidgetHidden` in the
  /// [onShowCustomWidget] callback (ex. when the user presses the back
  /// button). However, this is generally not necessary as the web page will
  /// often show its own UI to close out of fullscreen. Regardless of how the
  /// WebView exits fullscreen mode, WebView will invoke [onHideCustomWidget],
  /// signaling for the application to remove the custom widget. If this value
  /// is `null` when passed to an `AndroidWebViewWidget`, a default handler
  /// will be set.
  ///
  /// The [onHideCustomWidget] notifies the host application that the custom
  /// widget must be hidden. After this call, web content will render in the
  /// original `WebViewWidget` again.
  Future<void> setCustomWidgetCallbacks({
    required OnShowCustomWidgetCallback? onShowCustomWidget,
    required OnHideCustomWidgetCallback? onHideCustomWidget,
  }) async {
    _onShowCustomWidgetCallback = onShowCustomWidget;
    _onHideCustomWidgetCallback = onHideCustomWidget;
  }

  /// Sets a callback that notifies the host application of any log messages
  /// written to the JavaScript console.
  @override
  Future<void> setOnConsoleMessage(
      void Function(JavaScriptConsoleMessage consoleMessage)
          onConsoleMessage) async {
    _onConsoleLogCallback = onConsoleMessage;

    return _webChromeClient.setSynchronousReturnValueForOnConsoleMessage(
        _onConsoleLogCallback != null);
  }

  @override
  Future<String?> getUserAgent() => _webView.settings.getUserAgentString();

  @override
  Future<void> setOnJavaScriptAlertDialog(
      Future<void> Function(JavaScriptAlertDialogRequest request)
          onJavaScriptAlertDialog) async {
    _onJavaScriptAlert = onJavaScriptAlertDialog;
    return _webChromeClient.setSynchronousReturnValueForOnJsAlert(true);
  }

  @override
  Future<void> setOnJavaScriptConfirmDialog(
      Future<bool> Function(JavaScriptConfirmDialogRequest request)
          onJavaScriptConfirmDialog) async {
    _onJavaScriptConfirm = onJavaScriptConfirmDialog;
    return _webChromeClient.setSynchronousReturnValueForOnJsConfirm(true);
  }

  @override
  Future<void> setOnJavaScriptTextInputDialog(
      Future<String> Function(JavaScriptTextInputDialogRequest request)
          onJavaScriptTextInputDialog) async {
    _onJavaScriptPrompt = onJavaScriptTextInputDialog;
    return _webChromeClient.setSynchronousReturnValueForOnJsPrompt(true);
  }
}

/// Android implementation of [PlatformWebViewPermissionRequest].
class AndroidWebViewPermissionRequest extends PlatformWebViewPermissionRequest {
  const AndroidWebViewPermissionRequest._({
    required super.types,
    required android_webview.PermissionRequest request,
  }) : _request = request;

  final android_webview.PermissionRequest _request;

  @override
  Future<void> grant() {
    return _request
        .grant(types.map<String>((WebViewPermissionResourceType type) {
      switch (type) {
        case WebViewPermissionResourceType.camera:
          return android_webview.PermissionRequest.videoCapture;
        case WebViewPermissionResourceType.microphone:
          return android_webview.PermissionRequest.audioCapture;
        case AndroidWebViewPermissionResourceType.midiSysex:
          return android_webview.PermissionRequest.midiSysex;
        case AndroidWebViewPermissionResourceType.protectedMediaId:
          return android_webview.PermissionRequest.protectedMediaId;
      }

      throw UnsupportedError(
        'Resource of type `${type.name}` is not supported.',
      );
    }).toList());
  }

  @override
  Future<void> deny() {
    return _request.deny();
  }
}

/// Signature for the `setGeolocationPermissionsPromptCallbacks` callback responsible for request the Geolocation API.
typedef OnGeolocationPermissionsShowPrompt
    = Future<GeolocationPermissionsResponse> Function(
        GeolocationPermissionsRequestParams request);

/// Signature for the `setGeolocationPermissionsPromptCallbacks` callback responsible for request the Geolocation API is cancel.
typedef OnGeolocationPermissionsHidePrompt = void Function();

/// Signature for the `setCustomWidgetCallbacks` callback responsible for showing the custom view.
typedef OnShowCustomWidgetCallback = void Function(
    Widget widget, void Function() onCustomWidgetHidden);

/// Signature for the `setCustomWidgetCallbacks` callback responsible for hiding the custom view.
typedef OnHideCustomWidgetCallback = void Function();

/// A request params used by the host application to set the Geolocation permission state for an origin.
@immutable
class GeolocationPermissionsRequestParams {
  /// [origin]: The origin for which permissions are set.
  const GeolocationPermissionsRequestParams({
    required this.origin,
  });

  /// [origin]: The origin for which permissions are set.
  final String origin;
}

/// A response used by the host application to set the Geolocation permission state for an origin.
@immutable
class GeolocationPermissionsResponse {
  /// [allow]: Whether or not the origin should be allowed to use the Geolocation API.
  ///
  /// [retain]: Whether the permission should be retained beyond the lifetime of
  /// a page currently being displayed by a WebView.
  const GeolocationPermissionsResponse({
    required this.allow,
    required this.retain,
  });

  /// Whether or not the origin should be allowed to use the Geolocation API.
  final bool allow;

  /// Whether the permission should be retained beyond the lifetime of
  /// a page currently being displayed by a WebView.
  final bool retain;
}

/// Mode of how to select files for a file chooser.
enum FileSelectorMode {
  /// Open single file and requires that the file exists before allowing the
  /// user to pick it.
  open,

  /// Similar to [open] but allows multiple files to be selected.
  openMultiple,

  /// Allows picking a nonexistent file and saving it.
  save,
}

/// Parameters received when the `WebView` should show a file selector.
@immutable
class FileSelectorParams {
  /// Constructs a [FileSelectorParams].
  const FileSelectorParams({
    required this.isCaptureEnabled,
    required this.acceptTypes,
    this.filenameHint,
    required this.mode,
  });

  factory FileSelectorParams._fromFileChooserParams(
    android_webview.FileChooserParams params,
  ) {
    final FileSelectorMode mode;
    switch (params.mode) {
      case android_webview.FileChooserMode.open:
        mode = FileSelectorMode.open;
      case android_webview.FileChooserMode.openMultiple:
        mode = FileSelectorMode.openMultiple;
      case android_webview.FileChooserMode.save:
        mode = FileSelectorMode.save;
    }

    return FileSelectorParams(
      isCaptureEnabled: params.isCaptureEnabled,
      acceptTypes: params.acceptTypes,
      mode: mode,
      filenameHint: params.filenameHint,
    );
  }

  /// Preference for a live media captured value (e.g. Camera, Microphone).
  final bool isCaptureEnabled;

  /// A list of acceptable MIME types.
  final List<String> acceptTypes;

  /// The file name of a default selection if specified, or null.
  final String? filenameHint;

  /// Mode of how to select files for a file selector.
  final FileSelectorMode mode;
}

/// An implementation of [JavaScriptChannelParams] with the Android WebView API.
///
/// See [AndroidWebViewController.addJavaScriptChannel].
@immutable
class AndroidJavaScriptChannelParams extends JavaScriptChannelParams {
  /// Constructs a [AndroidJavaScriptChannelParams].
  AndroidJavaScriptChannelParams({
    required super.name,
    required super.onMessageReceived,
    @visibleForTesting
    AndroidWebViewProxy webViewProxy = const AndroidWebViewProxy(),
  })  : assert(name.isNotEmpty),
        _javaScriptChannel = webViewProxy.createJavaScriptChannel(
          name,
          postMessage: withWeakReferenceTo(
            onMessageReceived,
            (WeakReference<void Function(JavaScriptMessage)> weakReference) {
              return (
                String message,
              ) {
                if (weakReference.target != null) {
                  weakReference.target!(
                    JavaScriptMessage(message: message),
                  );
                }
              };
            },
          ),
        );

  /// Constructs a [AndroidJavaScriptChannelParams] using a
  /// [JavaScriptChannelParams].
  AndroidJavaScriptChannelParams.fromJavaScriptChannelParams(
    JavaScriptChannelParams params, {
    @visibleForTesting
    AndroidWebViewProxy webViewProxy = const AndroidWebViewProxy(),
  }) : this(
          name: params.name,
          onMessageReceived: params.onMessageReceived,
          webViewProxy: webViewProxy,
        );

  final android_webview.JavaScriptChannel _javaScriptChannel;
}

/// Object specifying creation parameters for creating a [AndroidWebViewWidget].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebViewWidgetCreationParams] for
/// more information.
@immutable
class AndroidWebViewWidgetCreationParams
    extends PlatformWebViewWidgetCreationParams {
  /// Creates [AndroidWebWidgetCreationParams].
  AndroidWebViewWidgetCreationParams({
    super.key,
    required super.controller,
    super.layoutDirection,
    super.gestureRecognizers,
    this.displayWithHybridComposition = false,
    @visibleForTesting InstanceManager? instanceManager,
    @visibleForTesting
    this.platformViewsServiceProxy = const PlatformViewsServiceProxy(),
  }) : instanceManager =
            instanceManager ?? android_webview.JavaObject.globalInstanceManager;

  /// Constructs a [WebKitWebViewWidgetCreationParams] using a
  /// [PlatformWebViewWidgetCreationParams].
  AndroidWebViewWidgetCreationParams.fromPlatformWebViewWidgetCreationParams(
    PlatformWebViewWidgetCreationParams params, {
    bool displayWithHybridComposition = false,
    @visibleForTesting InstanceManager? instanceManager,
    @visibleForTesting PlatformViewsServiceProxy platformViewsServiceProxy =
        const PlatformViewsServiceProxy(),
  }) : this(
          key: params.key,
          controller: params.controller,
          layoutDirection: params.layoutDirection,
          gestureRecognizers: params.gestureRecognizers,
          displayWithHybridComposition: displayWithHybridComposition,
          instanceManager: instanceManager,
          platformViewsServiceProxy: platformViewsServiceProxy,
        );

  /// Maintains instances used to communicate with the native objects they
  /// represent.
  ///
  /// This field is exposed for testing purposes only and should not be used
  /// outside of tests.
  @visibleForTesting
  final InstanceManager instanceManager;

  /// Proxy that provides access to the platform views service.
  ///
  /// This service allows creating and controlling platform-specific views.
  @visibleForTesting
  final PlatformViewsServiceProxy platformViewsServiceProxy;

  /// Whether the [WebView] will be displayed using the Hybrid Composition
  /// PlatformView implementation.
  ///
  /// For most use cases, this flag should be set to false. Hybrid Composition
  /// can have performance costs but doesn't have the limitation of rendering to
  /// an Android SurfaceTexture. See
  /// * https://docs.flutter.dev/platform-integration/android/platform-views#performance
  /// * https://github.com/flutter/flutter/issues/104889
  /// * https://github.com/flutter/flutter/issues/116954
  ///
  /// Defaults to false.
  final bool displayWithHybridComposition;

  @override
  int get hashCode => Object.hash(
        controller,
        layoutDirection,
        displayWithHybridComposition,
        platformViewsServiceProxy,
        instanceManager,
      );

  @override
  bool operator ==(Object other) {
    return other is AndroidWebViewWidgetCreationParams &&
        controller == other.controller &&
        layoutDirection == other.layoutDirection &&
        displayWithHybridComposition == other.displayWithHybridComposition &&
        platformViewsServiceProxy == other.platformViewsServiceProxy &&
        instanceManager == other.instanceManager;
  }
}

/// An implementation of [PlatformWebViewWidget] with the Android WebView API.
class AndroidWebViewWidget extends PlatformWebViewWidget {
  /// Constructs a [WebKitWebViewWidget].
  AndroidWebViewWidget(PlatformWebViewWidgetCreationParams params)
      : super.implementation(
          params is AndroidWebViewWidgetCreationParams
              ? params
              : AndroidWebViewWidgetCreationParams
                  .fromPlatformWebViewWidgetCreationParams(params),
        );

  AndroidWebViewWidgetCreationParams get _androidParams =>
      params as AndroidWebViewWidgetCreationParams;

  @override
  Widget build(BuildContext context) {
    _trySetDefaultOnShowCustomWidgetCallbacks(context);
    return PlatformViewLink(
      // Setting a default key using `params` ensures the `PlatformViewLink`
      // recreates the PlatformView when changes are made.
      key: _androidParams.key ??
          ValueKey<AndroidWebViewWidgetCreationParams>(
              params as AndroidWebViewWidgetCreationParams),
      viewType: 'plugins.flutter.io/webview',
      surfaceFactory: (
        BuildContext context,
        PlatformViewController controller,
      ) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: _androidParams.gestureRecognizers,
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (PlatformViewCreationParams params) {
        return _initAndroidView(
          params,
          displayWithHybridComposition:
              _androidParams.displayWithHybridComposition,
          platformViewsServiceProxy: _androidParams.platformViewsServiceProxy,
          view:
              (_androidParams.controller as AndroidWebViewController)._webView,
          instanceManager: _androidParams.instanceManager,
          layoutDirection: _androidParams.layoutDirection,
        )
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..create();
      },
    );
  }

  // Attempt to handle custom views with a default implementation if it has not
  // been set.
  void _trySetDefaultOnShowCustomWidgetCallbacks(BuildContext context) {
    final AndroidWebViewController controller =
        _androidParams.controller as AndroidWebViewController;

    if (controller._onShowCustomWidgetCallback == null) {
      controller.setCustomWidgetCallbacks(
        onShowCustomWidget:
            (Widget widget, OnHideCustomWidgetCallback callback) {
          Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (BuildContext context) => widget,
            fullscreenDialog: true,
          ));
        },
        onHideCustomWidget: () {
          Navigator.of(context).pop();
        },
      );
    }
  }
}

/// Represents a Flutter implementation of the Android [View](https://developer.android.com/reference/android/view/View)
/// that is created by the host platform when web content needs to be displayed
/// in fullscreen mode.
///
/// The [AndroidCustomViewWidget] cannot be manually instantiated and is
/// provided to the host application through the callbacks specified using the
/// [AndroidWebViewController.setCustomWidgetCallbacks] method.
///
/// The [AndroidCustomViewWidget] is initialized internally and should only be
/// exposed as a [Widget] externally. The type [AndroidCustomViewWidget] is
/// visible for testing purposes only and should never be called externally.
@visibleForTesting
class AndroidCustomViewWidget extends StatelessWidget {
  /// Creates a [AndroidCustomViewWidget].
  ///
  /// The [AndroidCustomViewWidget] should only be instantiated internally.
  /// This constructor is visible for testing purposes only and should
  /// never be called externally.
  @visibleForTesting
  AndroidCustomViewWidget.private({
    super.key,
    required this.controller,
    required this.customView,
    @visibleForTesting InstanceManager? instanceManager,
    @visibleForTesting
    this.platformViewsServiceProxy = const PlatformViewsServiceProxy(),
  }) : instanceManager =
            instanceManager ?? android_webview.JavaObject.globalInstanceManager;

  /// The reference to the Android native view that should be shown.
  final android_webview.View customView;

  /// The [PlatformWebViewController] that allows controlling the native web
  /// view.
  final PlatformWebViewController controller;

  /// Maintains instances used to communicate with the native objects they
  /// represent.
  ///
  /// This field is exposed for testing purposes only and should not be used
  /// outside of tests.
  @visibleForTesting
  final InstanceManager instanceManager;

  /// Proxy that provides access to the platform views service.
  ///
  /// This service allows creating and controlling platform-specific views.
  @visibleForTesting
  final PlatformViewsServiceProxy platformViewsServiceProxy;

  @override
  Widget build(BuildContext context) {
    return PlatformViewLink(
      key: key,
      viewType: 'plugins.flutter.io/webview',
      surfaceFactory: (
        BuildContext context,
        PlatformViewController controller,
      ) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
        );
      },
      onCreatePlatformView: (PlatformViewCreationParams params) {
        return _initAndroidView(
          params,
          displayWithHybridComposition: false,
          platformViewsServiceProxy: platformViewsServiceProxy,
          view: customView,
          instanceManager: instanceManager,
        )
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..create();
      },
    );
  }
}

AndroidViewController _initAndroidView(
  PlatformViewCreationParams params, {
  required bool displayWithHybridComposition,
  required PlatformViewsServiceProxy platformViewsServiceProxy,
  required android_webview.View view,
  required InstanceManager instanceManager,
  TextDirection layoutDirection = TextDirection.ltr,
}) {
  final int? instanceId = instanceManager.getIdentifier(view);

  if (displayWithHybridComposition) {
    return platformViewsServiceProxy.initExpensiveAndroidView(
      id: params.id,
      viewType: 'plugins.flutter.io/webview',
      layoutDirection: layoutDirection,
      creationParams: instanceId,
      creationParamsCodec: const StandardMessageCodec(),
    );
  } else {
    return platformViewsServiceProxy.initSurfaceAndroidView(
      id: params.id,
      viewType: 'plugins.flutter.io/webview',
      layoutDirection: layoutDirection,
      creationParams: instanceId,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}

/// Signature for the `loadRequest` callback responsible for loading the [url]
/// after a navigation request has been approved.
typedef LoadRequestCallback = Future<void> Function(LoadRequestParams params);

/// Error returned in `WebView.onWebResourceError` when a web resource loading error has occurred.
@immutable
class AndroidWebResourceError extends WebResourceError {
  /// Creates a new [AndroidWebResourceError].
  AndroidWebResourceError._({
    required super.errorCode,
    required super.description,
    super.isForMainFrame,
    super.url,
  })  : failingUrl = url,
        super(
          errorType: _errorCodeToErrorType(errorCode),
        );

  /// Gets the URL for which the failing resource request was made.
  @Deprecated('Please use `url`.')
  final String? failingUrl;

  static WebResourceErrorType? _errorCodeToErrorType(int errorCode) {
    switch (errorCode) {
      case android_webview.WebViewClient.errorAuthentication:
        return WebResourceErrorType.authentication;
      case android_webview.WebViewClient.errorBadUrl:
        return WebResourceErrorType.badUrl;
      case android_webview.WebViewClient.errorConnect:
        return WebResourceErrorType.connect;
      case android_webview.WebViewClient.errorFailedSslHandshake:
        return WebResourceErrorType.failedSslHandshake;
      case android_webview.WebViewClient.errorFile:
        return WebResourceErrorType.file;
      case android_webview.WebViewClient.errorFileNotFound:
        return WebResourceErrorType.fileNotFound;
      case android_webview.WebViewClient.errorHostLookup:
        return WebResourceErrorType.hostLookup;
      case android_webview.WebViewClient.errorIO:
        return WebResourceErrorType.io;
      case android_webview.WebViewClient.errorProxyAuthentication:
        return WebResourceErrorType.proxyAuthentication;
      case android_webview.WebViewClient.errorRedirectLoop:
        return WebResourceErrorType.redirectLoop;
      case android_webview.WebViewClient.errorTimeout:
        return WebResourceErrorType.timeout;
      case android_webview.WebViewClient.errorTooManyRequests:
        return WebResourceErrorType.tooManyRequests;
      case android_webview.WebViewClient.errorUnknown:
        return WebResourceErrorType.unknown;
      case android_webview.WebViewClient.errorUnsafeResource:
        return WebResourceErrorType.unsafeResource;
      case android_webview.WebViewClient.errorUnsupportedAuthScheme:
        return WebResourceErrorType.unsupportedAuthScheme;
      case android_webview.WebViewClient.errorUnsupportedScheme:
        return WebResourceErrorType.unsupportedScheme;
    }

    throw ArgumentError(
      'Could not find a WebResourceErrorType for errorCode: $errorCode',
    );
  }
}

/// Object specifying creation parameters for creating a [AndroidNavigationDelegate].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformNavigationDelegateCreationParams] for
/// more information.
@immutable
class AndroidNavigationDelegateCreationParams
    extends PlatformNavigationDelegateCreationParams {
  /// Creates a new [AndroidNavigationDelegateCreationParams] instance.
  const AndroidNavigationDelegateCreationParams._({
    @visibleForTesting this.androidWebViewProxy = const AndroidWebViewProxy(),
  }) : super();

  /// Creates a [AndroidNavigationDelegateCreationParams] instance based on [PlatformNavigationDelegateCreationParams].
  factory AndroidNavigationDelegateCreationParams.fromPlatformNavigationDelegateCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformNavigationDelegateCreationParams params, {
    @visibleForTesting
    AndroidWebViewProxy androidWebViewProxy = const AndroidWebViewProxy(),
  }) {
    return AndroidNavigationDelegateCreationParams._(
      androidWebViewProxy: androidWebViewProxy,
    );
  }

  /// Handles constructing objects and calling static methods for the Android WebView
  /// native library.
  @visibleForTesting
  final AndroidWebViewProxy androidWebViewProxy;
}

/// Android details of the change to a web view's url.
class AndroidUrlChange extends UrlChange {
  /// Constructs an [AndroidUrlChange].
  const AndroidUrlChange({required super.url, required this.isReload});

  /// Whether the url is being reloaded.
  final bool isReload;
}

/// A place to register callback methods responsible to handle navigation events
/// triggered by the [android_webview.WebView].
class AndroidNavigationDelegate extends PlatformNavigationDelegate {
  /// Creates a new [AndroidNavigationDelegate].
  AndroidNavigationDelegate(PlatformNavigationDelegateCreationParams params)
      : super.implementation(params is AndroidNavigationDelegateCreationParams
            ? params
            : AndroidNavigationDelegateCreationParams
                .fromPlatformNavigationDelegateCreationParams(params)) {
    final WeakReference<AndroidNavigationDelegate> weakThis =
        WeakReference<AndroidNavigationDelegate>(this);

    _webViewClient = (this.params as AndroidNavigationDelegateCreationParams)
        .androidWebViewProxy
        .createAndroidWebViewClient(
      onPageFinished: (android_webview.WebView webView, String url) {
        final PageEventCallback? callback = weakThis.target?._onPageFinished;
        if (callback != null) {
          callback(url);
        }
      },
      onPageStarted: (android_webview.WebView webView, String url) {
        final PageEventCallback? callback = weakThis.target?._onPageStarted;
        if (callback != null) {
          callback(url);
        }
      },
      onReceivedHttpError: (
        android_webview.WebView webView,
        android_webview.WebResourceRequest request,
        android_webview.WebResourceResponse response,
      ) {
        if (weakThis.target?._onHttpError != null) {
          weakThis.target!._onHttpError!(
            HttpResponseError(
              request: WebResourceRequest(
                uri: Uri.parse(request.url),
              ),
              response: WebResourceResponse(
                uri: null,
                statusCode: response.statusCode,
              ),
            ),
          );
        }
      },
      onReceivedRequestError: (
        android_webview.WebView webView,
        android_webview.WebResourceRequest request,
        android_webview.WebResourceError error,
      ) {
        final WebResourceErrorCallback? callback =
            weakThis.target?._onWebResourceError;
        if (callback != null) {
          callback(AndroidWebResourceError._(
            errorCode: error.errorCode,
            description: error.description,
            url: request.url,
            isForMainFrame: request.isForMainFrame,
          ));
        }
      },
      onReceivedError: (
        android_webview.WebView webView,
        int errorCode,
        String description,
        String failingUrl,
      ) {
        final WebResourceErrorCallback? callback =
            weakThis.target?._onWebResourceError;
        if (callback != null) {
          callback(AndroidWebResourceError._(
            errorCode: errorCode,
            description: description,
            url: failingUrl,
            isForMainFrame: true,
          ));
        }
      },
      requestLoading: (
        android_webview.WebView webView,
        android_webview.WebResourceRequest request,
      ) {
        weakThis.target?._handleNavigation(
          request.url,
          headers: request.requestHeaders,
          isForMainFrame: request.isForMainFrame,
        );
      },
      urlLoading: (android_webview.WebView webView, String url) {
        weakThis.target?._handleNavigation(url, isForMainFrame: true);
      },
      doUpdateVisitedHistory: (
        android_webview.WebView webView,
        String url,
        bool isReload,
      ) {
        final UrlChangeCallback? callback = weakThis.target?._onUrlChange;
        if (callback != null) {
          callback(AndroidUrlChange(url: url, isReload: isReload));
        }
      },
      onReceivedHttpAuthRequest: (
        android_webview.WebView webView,
        android_webview.HttpAuthHandler httpAuthHandler,
        String host,
        String realm,
      ) {
        final void Function(HttpAuthRequest)? callback =
            weakThis.target?._onHttpAuthRequest;
        if (callback != null) {
          callback(
            HttpAuthRequest(
              onProceed: (WebViewCredential credential) {
                httpAuthHandler.proceed(credential.user, credential.password);
              },
              onCancel: () {
                httpAuthHandler.cancel();
              },
              host: host,
              realm: realm,
            ),
          );
        } else {
          httpAuthHandler.cancel();
        }
      },
    );

    _downloadListener = (this.params as AndroidNavigationDelegateCreationParams)
        .androidWebViewProxy
        .createDownloadListener(
      onDownloadStart: (
        String url,
        String userAgent,
        String contentDisposition,
        String mimetype,
        int contentLength,
      ) {
        if (weakThis.target != null) {
          weakThis.target?._handleNavigation(url, isForMainFrame: true);
        }
      },
    );
  }

  AndroidNavigationDelegateCreationParams get _androidParams =>
      params as AndroidNavigationDelegateCreationParams;

  late final android_webview.WebChromeClient _webChromeClient =
      _androidParams.androidWebViewProxy.createAndroidWebChromeClient();

  /// Gets the native [android_webview.WebChromeClient] that is bridged by this [AndroidNavigationDelegate].
  ///
  /// Used by the [AndroidWebViewController] to set the `android_webview.WebView.setWebChromeClient`.
  @Deprecated(
    'This value is not used by `AndroidWebViewController` and has no effect on the `WebView`.',
  )
  android_webview.WebChromeClient get androidWebChromeClient =>
      _webChromeClient;

  late final android_webview.WebViewClient _webViewClient;

  /// Gets the native [android_webview.WebViewClient] that is bridged by this [AndroidNavigationDelegate].
  ///
  /// Used by the [AndroidWebViewController] to set the `android_webview.WebView.setWebViewClient`.
  android_webview.WebViewClient get androidWebViewClient => _webViewClient;

  late final android_webview.DownloadListener _downloadListener;

  /// Gets the native [android_webview.DownloadListener] that is bridged by this [AndroidNavigationDelegate].
  ///
  /// Used by the [AndroidWebViewController] to set the `android_webview.WebView.setDownloadListener`.
  android_webview.DownloadListener get androidDownloadListener =>
      _downloadListener;

  PageEventCallback? _onPageFinished;
  PageEventCallback? _onPageStarted;
  HttpResponseErrorCallback? _onHttpError;
  ProgressCallback? _onProgress;
  WebResourceErrorCallback? _onWebResourceError;
  NavigationRequestCallback? _onNavigationRequest;
  LoadRequestCallback? _onLoadRequest;
  UrlChangeCallback? _onUrlChange;
  HttpAuthRequestCallback? _onHttpAuthRequest;

  void _handleNavigation(
    String url, {
    required bool isForMainFrame,
    Map<String, String> headers = const <String, String>{},
  }) {
    final LoadRequestCallback? onLoadRequest = _onLoadRequest;
    final NavigationRequestCallback? onNavigationRequest = _onNavigationRequest;

    // The client is only allowed to stop navigations that target the main frame because
    // overridden URLs are passed to `loadUrl` and `loadUrl` cannot load a subframe.
    if (!isForMainFrame ||
        onNavigationRequest == null ||
        onLoadRequest == null) {
      return;
    }

    final FutureOr<NavigationDecision> returnValue = onNavigationRequest(
      NavigationRequest(
        url: url,
        isMainFrame: isForMainFrame,
      ),
    );

    if (returnValue is NavigationDecision &&
        returnValue == NavigationDecision.navigate) {
      onLoadRequest(LoadRequestParams(
        uri: Uri.parse(url),
        headers: headers,
      ));
    } else if (returnValue is Future<NavigationDecision>) {
      returnValue.then((NavigationDecision shouldLoadUrl) {
        if (shouldLoadUrl == NavigationDecision.navigate) {
          onLoadRequest(LoadRequestParams(
            uri: Uri.parse(url),
            headers: headers,
          ));
        }
      });
    }
  }

  /// Invoked when loading the url after a navigation request is approved.
  Future<void> setOnLoadRequest(
    LoadRequestCallback onLoadRequest,
  ) async {
    _onLoadRequest = onLoadRequest;
  }

  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback onNavigationRequest,
  ) async {
    _onNavigationRequest = onNavigationRequest;
    return _webViewClient
        .setSynchronousReturnValueForShouldOverrideUrlLoading(true);
  }

  @override
  Future<void> setOnPageStarted(
    PageEventCallback onPageStarted,
  ) async {
    _onPageStarted = onPageStarted;
  }

  @override
  Future<void> setOnPageFinished(
    PageEventCallback onPageFinished,
  ) async {
    _onPageFinished = onPageFinished;
  }

  @override
  Future<void> setOnHttpError(
    HttpResponseErrorCallback onHttpError,
  ) async {
    _onHttpError = onHttpError;
  }

  @override
  Future<void> setOnProgress(
    ProgressCallback onProgress,
  ) async {
    _onProgress = onProgress;
  }

  @override
  Future<void> setOnWebResourceError(
    WebResourceErrorCallback onWebResourceError,
  ) async {
    _onWebResourceError = onWebResourceError;
  }

  @override
  Future<void> setOnUrlChange(UrlChangeCallback onUrlChange) async {
    _onUrlChange = onUrlChange;
  }

  @override
  Future<void> setOnHttpAuthRequest(
    HttpAuthRequestCallback onHttpAuthRequest,
  ) async {
    _onHttpAuthRequest = onHttpAuthRequest;
  }
}
