// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/android_webview.g.dart',
    dartTestOut: 'test/test_android_webview.g.dart',
    dartOptions: DartOptions(copyrightHeader: <String>[
      'Copyright 2013 The Flutter Authors. All rights reserved.',
      'Use of this source code is governed by a BSD-style license that can be',
      'found in the LICENSE file.',
    ]),
    javaOut:
        'android/src/main/java/io/flutter/plugins/webviewflutter/GeneratedAndroidWebView.java',
    javaOptions: JavaOptions(
      package: 'io.flutter.plugins.webviewflutter',
      className: 'GeneratedAndroidWebView',
      copyrightHeader: <String>[
        'Copyright 2013 The Flutter Authors. All rights reserved.',
        'Use of this source code is governed by a BSD-style license that can be',
        'found in the LICENSE file.',
      ],
    ),
  ),
)

/// Host API for managing the native `InstanceManager`.
@HostApi(dartHostTestHandler: 'TestInstanceManagerHostApi')
abstract class InstanceManagerHostApi {
  /// Clear the native `InstanceManager`.
  ///
  /// This is typically only used after a hot restart.
  void clear();
}

/// Mode of how to select files for a file chooser.
///
/// See https://developer.android.com/reference/android/webkit/WebChromeClient.FileChooserParams.
enum FileChooserMode {
  /// Open single file and requires that the file exists before allowing the
  /// user to pick it.
  ///
  /// See https://developer.android.com/reference/android/webkit/WebChromeClient.FileChooserParams#MODE_OPEN.
  open,

  /// Similar to [open] but allows multiple files to be selected.
  ///
  /// See https://developer.android.com/reference/android/webkit/WebChromeClient.FileChooserParams#MODE_OPEN_MULTIPLE.
  openMultiple,

  /// Allows picking a nonexistent file and saving it.
  ///
  /// See https://developer.android.com/reference/android/webkit/WebChromeClient.FileChooserParams#MODE_SAVE.
  save,
}

/// Indicates the type of message logged to the console.
///
/// See https://developer.android.com/reference/android/webkit/ConsoleMessage.MessageLevel.
enum ConsoleMessageLevel {
  /// Indicates a message is logged for debugging.
  ///
  /// See https://developer.android.com/reference/android/webkit/ConsoleMessage.MessageLevel#DEBUG.
  debug,

  /// Indicates a message is provided as an error.
  ///
  /// See https://developer.android.com/reference/android/webkit/ConsoleMessage.MessageLevel#ERROR.
  error,

  /// Indicates a message is provided as a basic log message.
  ///
  /// See https://developer.android.com/reference/android/webkit/ConsoleMessage.MessageLevel#LOG.
  log,

  /// Indicates a message is provided as a tip.
  ///
  /// See https://developer.android.com/reference/android/webkit/ConsoleMessage.MessageLevel#TIP.
  tip,

  /// Indicates a message is provided as a warning.
  ///
  /// See https://developer.android.com/reference/android/webkit/ConsoleMessage.MessageLevel#WARNING.
  warning,

  /// Indicates a message with an unknown level.
  ///
  /// This does not represent an actual value provided by the platform and only
  /// indicates a value was provided that isn't currently supported.
  unknown,
}

class WebResourceRequestData {
  WebResourceRequestData(
    this.url,
    this.isForMainFrame,
    this.isRedirect,
    this.hasGesture,
    this.method,
    this.requestHeaders,
  );

  String url;
  bool isForMainFrame;
  bool? isRedirect;
  bool hasGesture;
  String method;
  Map<String?, String?> requestHeaders;
}

class WebResourceResponseData {
  WebResourceResponseData(
    this.statusCode,
  );

  int statusCode;
}

class WebResourceErrorData {
  WebResourceErrorData(this.errorCode, this.description);

  int errorCode;
  String description;
}

class WebViewPoint {
  WebViewPoint(this.x, this.y);

  int x;
  int y;
}

/// Represents a JavaScript console message from WebCore.
///
/// See https://developer.android.com/reference/android/webkit/ConsoleMessage
class ConsoleMessage {
  late int lineNumber;
  late String message;
  late ConsoleMessageLevel level;
  late String sourceId;
}

/// Handles methods calls to the native Java Object class.
///
/// Also handles calls to remove the reference to an instance with `dispose`.
///
/// See https://docs.oracle.com/javase/7/docs/api/java/lang/Object.html.
@HostApi(dartHostTestHandler: 'TestJavaObjectHostApi')
abstract class JavaObjectHostApi {
  void dispose(int identifier);
}

/// Handles callbacks methods for the native Java Object class.
///
/// See https://docs.oracle.com/javase/7/docs/api/java/lang/Object.html.
@FlutterApi()
abstract class JavaObjectFlutterApi {
  void dispose(int identifier);
}

/// Host API for `CookieManager`.
///
/// This class may handle instantiating and adding native object instances that
/// are attached to a Dart instance or handle method calls on the associated
/// native class or an instance of the class.
@HostApi(dartHostTestHandler: 'TestCookieManagerHostApi')
abstract class CookieManagerHostApi {
  /// Handles attaching `CookieManager.instance` to a native instance.
  void attachInstance(int instanceIdentifier);

  /// Handles Dart method `CookieManager.setCookie`.
  void setCookie(int identifier, String url, String value);

  /// Handles Dart method `CookieManager.removeAllCookies`.
  @async
  bool removeAllCookies(int identifier);

  /// Handles Dart method `CookieManager.setAcceptThirdPartyCookies`.
  void setAcceptThirdPartyCookies(
    int identifier,
    int webViewIdentifier,
    bool accept,
  );
}

@HostApi(dartHostTestHandler: 'TestWebViewHostApi')
abstract class WebViewHostApi {
  void create(int instanceId);

  void loadData(
    int instanceId,
    String data,
    String? mimeType,
    String? encoding,
  );

  void loadDataWithBaseUrl(
    int instanceId,
    String? baseUrl,
    String data,
    String? mimeType,
    String? encoding,
    String? historyUrl,
  );

  void loadUrl(
    int instanceId,
    String url,
    Map<String, String> headers,
  );

  void postUrl(
    int instanceId,
    String url,
    Uint8List data,
  );

  String? getUrl(int instanceId);

  bool canGoBack(int instanceId);

  bool canGoForward(int instanceId);

  void goBack(int instanceId);

  void goForward(int instanceId);

  void reload(int instanceId);

  void clearCache(int instanceId, bool includeDiskFiles);

  @async
  String? evaluateJavascript(
    int instanceId,
    String javascriptString,
  );

  String? getTitle(int instanceId);

  void scrollTo(int instanceId, int x, int y);

  void scrollBy(int instanceId, int x, int y);

  int getScrollX(int instanceId);

  int getScrollY(int instanceId);

  WebViewPoint getScrollPosition(int instanceId);

  void setWebContentsDebuggingEnabled(bool enabled);

  void setWebViewClient(int instanceId, int webViewClientInstanceId);

  void addJavaScriptChannel(int instanceId, int javaScriptChannelInstanceId);

  void removeJavaScriptChannel(int instanceId, int javaScriptChannelInstanceId);

  void setDownloadListener(int instanceId, int? listenerInstanceId);

  void setWebChromeClient(int instanceId, int? clientInstanceId);

  void setBackgroundColor(int instanceId, int color);
}

/// Flutter API for `WebView`.
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
///
/// See https://developer.android.com/reference/android/webkit/WebView.
@FlutterApi()
abstract class WebViewFlutterApi {
  /// Create a new Dart instance and add it to the `InstanceManager`.
  void create(int identifier);

  void onScrollChanged(
    int webViewInstanceId,
    int left,
    int top,
    int oldLeft,
    int oldTop,
  );
}

@HostApi(dartHostTestHandler: 'TestWebSettingsHostApi')
abstract class WebSettingsHostApi {
  void create(int instanceId, int webViewInstanceId);

  void setDomStorageEnabled(int instanceId, bool flag);

  void setJavaScriptCanOpenWindowsAutomatically(int instanceId, bool flag);

  void setSupportMultipleWindows(int instanceId, bool support);

  void setJavaScriptEnabled(int instanceId, bool flag);

  void setUserAgentString(int instanceId, String? userAgentString);

  void setMediaPlaybackRequiresUserGesture(int instanceId, bool require);

  void setSupportZoom(int instanceId, bool support);

  void setLoadWithOverviewMode(int instanceId, bool overview);

  void setUseWideViewPort(int instanceId, bool use);

  void setDisplayZoomControls(int instanceId, bool enabled);

  void setBuiltInZoomControls(int instanceId, bool enabled);

  void setAllowFileAccess(int instanceId, bool enabled);

  void setTextZoom(int instanceId, int textZoom);

  String getUserAgentString(int instanceId);
}

@HostApi(dartHostTestHandler: 'TestJavaScriptChannelHostApi')
abstract class JavaScriptChannelHostApi {
  void create(int instanceId, String channelName);
}

@FlutterApi()
abstract class JavaScriptChannelFlutterApi {
  void postMessage(int instanceId, String message);
}

@HostApi(dartHostTestHandler: 'TestWebViewClientHostApi')
abstract class WebViewClientHostApi {
  void create(int instanceId);

  void setSynchronousReturnValueForShouldOverrideUrlLoading(
    int instanceId,
    bool value,
  );
}

@FlutterApi()
abstract class WebViewClientFlutterApi {
  void onPageStarted(int instanceId, int webViewInstanceId, String url);

  void onPageFinished(int instanceId, int webViewInstanceId, String url);

  void onReceivedHttpError(
    int instanceId,
    int webViewInstanceId,
    WebResourceRequestData request,
    WebResourceResponseData response,
  );

  void onReceivedRequestError(
    int instanceId,
    int webViewInstanceId,
    WebResourceRequestData request,
    WebResourceErrorData error,
  );

  void onReceivedError(
    int instanceId,
    int webViewInstanceId,
    int errorCode,
    String description,
    String failingUrl,
  );

  void requestLoading(
    int instanceId,
    int webViewInstanceId,
    WebResourceRequestData request,
  );

  void urlLoading(int instanceId, int webViewInstanceId, String url);

  void doUpdateVisitedHistory(
    int instanceId,
    int webViewInstanceId,
    String url,
    bool isReload,
  );

  void onReceivedHttpAuthRequest(
    int instanceId,
    int webViewInstanceId,
    int httpAuthHandlerInstanceId,
    String host,
    String realm,
  );
}

@HostApi(dartHostTestHandler: 'TestDownloadListenerHostApi')
abstract class DownloadListenerHostApi {
  void create(int instanceId);
}

@FlutterApi()
abstract class DownloadListenerFlutterApi {
  void onDownloadStart(
    int instanceId,
    String url,
    String userAgent,
    String contentDisposition,
    String mimetype,
    int contentLength,
  );
}

@HostApi(dartHostTestHandler: 'TestWebChromeClientHostApi')
abstract class WebChromeClientHostApi {
  void create(int instanceId);

  void setSynchronousReturnValueForOnShowFileChooser(
    int instanceId,
    bool value,
  );

  void setSynchronousReturnValueForOnConsoleMessage(
    int instanceId,
    bool value,
  );

  void setSynchronousReturnValueForOnJsAlert(
    int instanceId,
    bool value,
  );

  void setSynchronousReturnValueForOnJsConfirm(
    int instanceId,
    bool value,
  );

  void setSynchronousReturnValueForOnJsPrompt(
    int instanceId,
    bool value,
  );
}

@HostApi(dartHostTestHandler: 'TestAssetManagerHostApi')
abstract class FlutterAssetManagerHostApi {
  List<String> list(String path);

  String getAssetFilePathByName(String name);
}

@FlutterApi()
abstract class WebChromeClientFlutterApi {
  void onProgressChanged(int instanceId, int webViewInstanceId, int progress);

  @async
  List<String> onShowFileChooser(
    int instanceId,
    int webViewInstanceId,
    int paramsInstanceId,
  );

  /// Callback to Dart function `WebChromeClient.onPermissionRequest`.
  void onPermissionRequest(int instanceId, int requestInstanceId);

  /// Callback to Dart function `WebChromeClient.onShowCustomView`.
  void onShowCustomView(
    int instanceId,
    int viewIdentifier,
    int callbackIdentifier,
  );

  /// Callback to Dart function `WebChromeClient.onHideCustomView`.
  void onHideCustomView(int instanceId);

  /// Callback to Dart function `WebChromeClient.onGeolocationPermissionsShowPrompt`.
  void onGeolocationPermissionsShowPrompt(
    int instanceId,
    int paramsInstanceId,
    String origin,
  );

  /// Callback to Dart function `WebChromeClient.onGeolocationPermissionsHidePrompt`.
  void onGeolocationPermissionsHidePrompt(int identifier);

  /// Callback to Dart function `WebChromeClient.onConsoleMessage`.
  void onConsoleMessage(int instanceId, ConsoleMessage message);

  @async
  void onJsAlert(int instanceId, String url, String message);

  @async
  bool onJsConfirm(int instanceId, String url, String message);

  @async
  String onJsPrompt(
      int instanceId, String url, String message, String defaultValue);
}

@HostApi(dartHostTestHandler: 'TestWebStorageHostApi')
abstract class WebStorageHostApi {
  void create(int instanceId);

  void deleteAllData(int instanceId);
}

/// Handles callbacks methods for the native Java FileChooserParams class.
///
/// See https://developer.android.com/reference/android/webkit/WebChromeClient.FileChooserParams.
@FlutterApi()
abstract class FileChooserParamsFlutterApi {
  void create(
    int instanceId,
    bool isCaptureEnabled,
    List<String> acceptTypes,
    FileChooserMode mode,
    String? filenameHint,
  );
}

/// Host API for `PermissionRequest`.
///
/// This class may handle instantiating and adding native object instances that
/// are attached to a Dart instance or handle method calls on the associated
/// native class or an instance of the class.
///
/// See https://developer.android.com/reference/android/webkit/PermissionRequest.
@HostApi(dartHostTestHandler: 'TestPermissionRequestHostApi')
abstract class PermissionRequestHostApi {
  /// Handles Dart method `PermissionRequest.grant`.
  void grant(int instanceId, List<String> resources);

  /// Handles Dart method `PermissionRequest.deny`.
  void deny(int instanceId);
}

/// Flutter API for `PermissionRequest`.
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
///
/// See https://developer.android.com/reference/android/webkit/PermissionRequest.
@FlutterApi()
abstract class PermissionRequestFlutterApi {
  /// Create a new Dart instance and add it to the `InstanceManager`.
  void create(int instanceId, List<String> resources);
}

/// Host API for `CustomViewCallback`.
///
/// This class may handle instantiating and adding native object instances that
/// are attached to a Dart instance or handle method calls on the associated
/// native class or an instance of the class.
///
/// See https://developer.android.com/reference/android/webkit/WebChromeClient.CustomViewCallback.
@HostApi(dartHostTestHandler: 'TestCustomViewCallbackHostApi')
abstract class CustomViewCallbackHostApi {
  /// Handles Dart method `CustomViewCallback.onCustomViewHidden`.
  void onCustomViewHidden(int identifier);
}

/// Flutter API for `CustomViewCallback`.
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
///
/// See https://developer.android.com/reference/android/webkit/WebChromeClient.CustomViewCallback.
@FlutterApi()
abstract class CustomViewCallbackFlutterApi {
  /// Create a new Dart instance and add it to the `InstanceManager`.
  void create(int identifier);
}

/// Flutter API for `View`.
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
///
/// See https://developer.android.com/reference/android/view/View.
@FlutterApi()
abstract class ViewFlutterApi {
  /// Create a new Dart instance and add it to the `InstanceManager`.
  void create(int identifier);
}

/// Host API for `GeolocationPermissionsCallback`.
///
/// This class may handle instantiating and adding native object instances that
/// are attached to a Dart instance or handle method calls on the associated
/// native class or an instance of the class.
///
/// See https://developer.android.com/reference/android/webkit/GeolocationPermissions.Callback.
@HostApi(dartHostTestHandler: 'TestGeolocationPermissionsCallbackHostApi')
abstract class GeolocationPermissionsCallbackHostApi {
  /// Handles Dart method `GeolocationPermissionsCallback.invoke`.
  void invoke(int instanceId, String origin, bool allow, bool retain);
}

/// Flutter API for `GeolocationPermissionsCallback`.
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
///
/// See https://developer.android.com/reference/android/webkit/GeolocationPermissions.Callback.
@FlutterApi()
abstract class GeolocationPermissionsCallbackFlutterApi {
  /// Create a new Dart instance and add it to the `InstanceManager`.
  void create(int instanceId);
}

/// Host API for `HttpAuthHandler`.
///
/// This class may handle instantiating and adding native object instances that
/// are attached to a Dart instance or handle method calls on the associated
/// native class or an instance of the class.
///
/// See https://developer.android.com/reference/android/webkit/HttpAuthHandler.
@HostApi(dartHostTestHandler: 'TestHttpAuthHandlerHostApi')
abstract class HttpAuthHandlerHostApi {
  /// Handles Dart method `HttpAuthHandler.useHttpAuthUsernamePassword`.
  bool useHttpAuthUsernamePassword(int instanceId);

  /// Handles Dart method `HttpAuthHandler.cancel`.
  void cancel(int instanceId);

  /// Handles Dart method `HttpAuthHandler.proceed`.
  void proceed(int instanceId, String username, String password);
}

/// Flutter API for `HttpAuthHandler`.
///
/// This class may handle instantiating and adding Dart instances that are
/// attached to a native instance or receiving callback methods from an
/// overridden native class.
///
/// See https://developer.android.com/reference/android/webkit/HttpAuthHandler.
@FlutterApi()
abstract class HttpAuthHandlerFlutterApi {
  /// Create a new Dart instance and add it to the `InstanceManager`.
  void create(int instanceId);
}
