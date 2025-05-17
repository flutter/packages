// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    copyrightHeader: 'pigeons/copyright.txt',
    dartOut: 'lib/src/android_webkit.g.dart',
    kotlinOut:
        'android/src/main/java/io/flutter/plugins/webviewflutter/AndroidWebkitLibrary.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'io.flutter.plugins.webviewflutter',
      errorClassName: 'AndroidWebKitError',
    ),
  ),
)

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

  /// Indicates a `FileChooserMode` with an unknown mode.
  ///
  /// This does not represent an actual value provided by the platform and only
  /// indicates a value was provided that isn't currently supported.
  unknown,
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

/// The over-scroll mode for a view.
///
/// See https://developer.android.com/reference/android/view/View#OVER_SCROLL_ALWAYS.
enum OverScrollMode {
  /// Always allow a user to over-scroll this view, provided it is a view that
  /// can scroll.
  always,

  /// Allow a user to over-scroll this view only if the content is large enough
  /// to meaningfully scroll, provided it is a view that can scroll.
  ifContentScrolls,

  /// Never allow a user to over-scroll this view.
  never,

  /// The type is not recognized by this wrapper.
  unknown,
}

/// Type of error for a SslCertificate.
///
/// See https://developer.android.com/reference/android/net/http/SslError#SSL_DATE_INVALID.
enum SslErrorType {
  /// The date of the certificate is invalid.
  dateInvalid,

  /// The certificate has expired.
  expired,

  /// Hostname mismatch.
  idMismatch,

  /// A generic error occurred.
  invalid,

  /// The certificate is not yet valid.
  notYetValid,

  /// The certificate authority is not trusted.
  untrusted,

  /// The type is not recognized by this wrapper.
  unknown,
}

/// Encompasses parameters to the `WebViewClient.shouldInterceptRequest` method.
///
/// See https://developer.android.com/reference/android/webkit/WebResourceRequest.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.webkit.WebResourceRequest',
  ),
)
abstract class WebResourceRequest {
  /// The URL for which the resource request was made.
  late String url;

  /// Whether the request was made in order to fetch the main frame's document.
  late bool isForMainFrame;

  /// Whether the request was a result of a server-side redirect.
  late bool? isRedirect;

  /// Whether a gesture (such as a click) was associated with the request.
  late bool hasGesture;

  /// The method associated with the request, for example "GET".
  late String method;

  /// The headers associated with the request.
  late Map<String, String>? requestHeaders;
}

/// Encapsulates a resource response.
///
/// See https://developer.android.com/reference/android/webkit/WebResourceResponse.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.webkit.WebResourceResponse',
  ),
)
abstract class WebResourceResponse {
  /// The resource response's status code.
  late int statusCode;
}

/// Encapsulates information about errors that occurred during loading of web
/// resources.
///
/// See https://developer.android.com/reference/android/webkit/WebResourceError.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.webkit.WebResourceError',
    minAndroidApi: 23,
  ),
)
abstract class WebResourceError {
  /// The error code of the error.
  late int errorCode;

  /// The string describing the error.
  late String description;
}

/// Encapsulates information about errors that occurred during loading of web
/// resources.
///
/// See https://developer.android.com/reference/androidx/webkit/WebResourceErrorCompat.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'androidx.webkit.WebResourceErrorCompat',
  ),
)
abstract class WebResourceErrorCompat {
  /// The error code of the error.
  late int errorCode;

  /// The string describing the error.
  late String description;
}

/// Represents a position on a web page.
///
/// This is a custom class created for convenience of the wrapper.
@ProxyApi()
abstract class WebViewPoint {
  late int x;
  late int y;
}

/// Represents a JavaScript console message from WebCore.
///
/// See https://developer.android.com/reference/android/webkit/ConsoleMessage
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.webkit.ConsoleMessage',
  ),
)
abstract class ConsoleMessage {
  late int lineNumber;
  late String message;
  late ConsoleMessageLevel level;
  late String sourceId;
}

/// Manages the cookies used by an application's `WebView` instances.
///
/// See https://developer.android.com/reference/android/webkit/CookieManager.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.webkit.CookieManager',
  ),
)
abstract class CookieManager {
  @static
  late CookieManager instance;

  /// Sets a single cookie (key-value pair) for the given URL.
  void setCookie(String url, String value);

  /// Removes all cookies.
  @async
  bool removeAllCookies();

  /// Sets whether the `WebView` should allow third party cookies to be set.
  void setAcceptThirdPartyCookies(WebView webView, bool accept);
}

/// A View that displays web pages.
///
/// See https://developer.android.com/reference/android/webkit/WebView.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.webkit.WebView',
  ),
)
abstract class WebView extends View {
  WebView();

  /// This is called in response to an internal scroll in this view (i.e., the
  /// view scrolled its own contents).
  late void Function(
    int left,
    int top,
    int oldLeft,
    int oldTop,
  )? onScrollChanged;

  /// The WebSettings object used to control the settings for this WebView.
  @attached
  late WebSettings settings;

  /// Loads the given data into this WebView using a 'data' scheme URL.
  void loadData(String data, String? mimeType, String? encoding);

  /// Loads the given data into this WebView, using baseUrl as the base URL for
  /// the content.
  void loadDataWithBaseUrl(
    String? baseUrl,
    String data,
    String? mimeType,
    String? encoding,
    String? historyUrl,
  );

  /// Loads the given URL.
  void loadUrl(String url, Map<String, String> headers);

  /// Loads the URL with postData using "POST" method into this WebView.
  void postUrl(String url, Uint8List data);

  /// Gets the URL for the current page.
  String? getUrl();

  /// Gets whether this WebView has a back history item.
  bool canGoBack();

  /// Gets whether this WebView has a forward history item.
  bool canGoForward();

  /// Goes back in the history of this WebView.
  void goBack();

  /// Goes forward in the history of this WebView.
  void goForward();

  /// Reloads the current URL.
  void reload();

  /// Clears the resource cache.
  void clearCache(bool includeDiskFiles);

  /// Asynchronously evaluates JavaScript in the context of the currently
  /// displayed page.
  @async
  String? evaluateJavascript(String javascriptString);

  /// Gets the title for the current page.
  String? getTitle();

  /// Enables debugging of web contents (HTML / CSS / JavaScript) loaded into
  /// any WebViews of this application.
  @static
  void setWebContentsDebuggingEnabled(bool enabled);

  /// Sets the WebViewClient that will receive various notifications and
  /// requests.
  void setWebViewClient(WebViewClient? client);

  /// Injects the supplied Java object into this WebView.
  void addJavaScriptChannel(JavaScriptChannel channel);

  /// Removes a previously injected Java object from this WebView.
  void removeJavaScriptChannel(String name);

  /// Registers the interface to be used when content can not be handled by the
  /// rendering engine, and should be downloaded instead.
  void setDownloadListener(DownloadListener? listener);

  /// Sets the chrome handler.
  void setWebChromeClient(WebChromeClient? client);

  /// Sets the background color for this view.
  void setBackgroundColor(int color);

  /// Destroys the internal state of this WebView.
  void destroy();
}

/// Manages settings state for a `WebView`.
///
/// See https://developer.android.com/reference/android/webkit/WebSettings.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.webkit.WebSettings',
  ),
)
abstract class WebSettings {
  /// Sets whether the DOM storage API is enabled.
  void setDomStorageEnabled(bool flag);

  /// Tells JavaScript to open windows automatically.
  void setJavaScriptCanOpenWindowsAutomatically(bool flag);

  /// Sets whether the WebView whether supports multiple windows.
  void setSupportMultipleWindows(bool support);

  /// Tells the WebView to enable JavaScript execution.
  void setJavaScriptEnabled(bool flag);

  /// Sets the WebView's user-agent string.
  void setUserAgentString(String? userAgentString);

  /// Sets whether the WebView requires a user gesture to play media.
  void setMediaPlaybackRequiresUserGesture(bool require);

  /// Sets whether the WebView should support zooming using its on-screen zoom
  /// controls and gestures.
  void setSupportZoom(bool support);

  /// Sets whether the WebView loads pages in overview mode, that is, zooms out
  /// the content to fit on screen by width.
  void setLoadWithOverviewMode(bool overview);

  /// Sets whether the WebView should enable support for the "viewport" HTML
  /// meta tag or should use a wide viewport.
  void setUseWideViewPort(bool use);

  /// Sets whether the WebView should display on-screen zoom controls when using
  /// the built-in zoom mechanisms.
  void setDisplayZoomControls(bool enabled);

  /// Sets whether the WebView should display on-screen zoom controls when using
  /// the built-in zoom mechanisms.
  void setBuiltInZoomControls(bool enabled);

  /// Enables or disables file access within WebView.
  void setAllowFileAccess(bool enabled);

  /// Enables or disables content URL access within WebView.
  void setAllowContentAccess(bool enabled);

  /// Sets whether Geolocation is enabled within WebView.
  void setGeolocationEnabled(bool enabled);

  /// Sets the text zoom of the page in percent.
  void setTextZoom(int textZoom);

  /// Gets the WebView's user-agent string.
  String getUserAgentString();
}

/// A JavaScript interface for exposing Javascript callbacks to Dart.
///
/// This is a custom class for the wrapper that is annotated with
/// [JavascriptInterface](https://developer.android.com/reference/android/webkit/JavascriptInterface).
@ProxyApi()
abstract class JavaScriptChannel {
  // ignore: avoid_unused_constructor_parameters
  JavaScriptChannel();

  late final String channelName;

  /// Handles callbacks messages from JavaScript.
  late void Function(String message) postMessage;
}

/// Receives various notifications and requests from a `WebView`.
///
/// See https://developer.android.com/reference/android/webkit/WebViewClient.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.webkit.WebViewClient',
  ),
)
abstract class WebViewClient {
  WebViewClient();

  /// Notify the host application that a page has started loading.
  late void Function(WebView webView, String url)? onPageStarted;

  /// Notify the host application that a page has finished loading.
  late void Function(WebView webView, String url)? onPageFinished;

  /// Notify the host application that an HTTP error has been received from the
  /// server while loading a resource.
  late void Function(
    WebView webView,
    WebResourceRequest request,
    WebResourceResponse response,
  )? onReceivedHttpError;

  /// Report web resource loading error to the host application.
  late void Function(
    WebView webView,
    WebResourceRequest request,
    WebResourceError error,
  )? onReceivedRequestError;

  /// Report web resource loading error to the host application.
  late void Function(
    WebView webView,
    WebResourceRequest request,
    WebResourceErrorCompat error,
  )? onReceivedRequestErrorCompat;

  /// Report an error to the host application.
  late void Function(
    WebView webView,
    int errorCode,
    String description,
    String failingUrl,
  )? onReceivedError;

  /// Give the host application a chance to take control when a URL is about to
  /// be loaded in the current WebView.
  late void Function(
    WebView webView,
    WebResourceRequest request,
  )? requestLoading;

  /// Give the host application a chance to take control when a URL is about to
  /// be loaded in the current WebView.
  late void Function(WebView webView, String url)? urlLoading;

  /// Notify the host application to update its visited links database.
  late void Function(
    WebView webView,
    String url,
    bool isReload,
  )? doUpdateVisitedHistory;

  /// Notifies the host application that the WebView received an HTTP
  /// authentication request.
  late void Function(
    WebView webView,
    HttpAuthHandler handler,
    String host,
    String realm,
  )? onReceivedHttpAuthRequest;

  /// Ask the host application if the browser should resend data as the
  /// requested page was a result of a POST.
  void Function(
    WebView view,
    AndroidMessage dontResend,
    AndroidMessage resend,
  )? onFormResubmission;

  /// Notify the host application that the WebView will load the resource
  /// specified by the given url.
  void Function(WebView view, String url)? onLoadResource;

  /// Notify the host application that WebView content left over from previous
  /// page navigations will no longer be drawn.
  void Function(WebView view, String url)? onPageCommitVisible;

  /// Notify the host application to handle a SSL client certificate request.
  void Function(
    WebView view,
    ClientCertRequest request,
  )? onReceivedClientCertRequest;

  /// Notify the host application that a request to automatically log in the
  /// user has been processed.
  void Function(
    WebView view,
    String realm,
    String? account,
    String args,
  )? onReceivedLoginRequest;

  /// Notifies the host application that an SSL error occurred while loading a
  /// resource.
  void Function(
    WebView view,
    SslErrorHandler handler,
    SslError error,
  )? onReceivedSslError;

  /// Notify the host application that the scale applied to the WebView has
  /// changed.
  void Function(WebView view, double oldScale, double newScale)? onScaleChanged;

  /// Sets the required synchronous return value for the Java method,
  /// `WebViewClient.shouldOverrideUrlLoading(...)`.
  ///
  /// The Java method, `WebViewClient.shouldOverrideUrlLoading(...)`, requires
  /// a boolean to be returned and this method sets the returned value for all
  /// calls to the Java method.
  ///
  /// Setting this to true causes the current [WebView] to abort loading any URL
  /// received by [requestLoading] or [urlLoading], while setting this to false
  /// causes the [WebView] to continue loading a URL as usual.
  ///
  /// Defaults to false.
  void setSynchronousReturnValueForShouldOverrideUrlLoading(bool value);
}

/// Handles notifications that a file should be downloaded.
///
/// See https://developer.android.com/reference/android/webkit/DownloadListener.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.webkit.DownloadListener',
  ),
)
abstract class DownloadListener {
  DownloadListener();

  /// Notify the host application that a file should be downloaded.
  late void Function(
    String url,
    String userAgent,
    String contentDisposition,
    String mimetype,
    int contentLength,
  ) onDownloadStart;
}

/// Handles notification of JavaScript dialogs, favicons, titles, and the
/// progress.
///
/// See https://developer.android.com/reference/android/webkit/WebChromeClient.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'io.flutter.plugins.webviewflutter.WebChromeClientProxyApi.WebChromeClientImpl',
  ),
)
abstract class WebChromeClient {
  WebChromeClient();

  /// Tell the host application the current progress of loading a page.
  late void Function(WebView webView, int progress)? onProgressChanged;

  /// Tell the client to show a file chooser.
  @async
  late List<String> Function(
    WebView webView,
    FileChooserParams params,
  ) onShowFileChooser;

  /// Notify the host application that web content is requesting permission to
  /// access the specified resources and the permission currently isn't granted
  /// or denied.
  late void Function(PermissionRequest request)? onPermissionRequest;

  /// Callback to Dart function `WebChromeClient.onShowCustomView`.
  late void Function(
    View view,
    CustomViewCallback callback,
  )? onShowCustomView;

  /// Notify the host application that the current page has entered full screen
  /// mode.
  late void Function()? onHideCustomView;

  /// Notify the host application that web content from the specified origin is
  /// attempting to use the Geolocation API, but no permission state is
  /// currently set for that origin.
  late void Function(
    String origin,
    GeolocationPermissionsCallback callback,
  )? onGeolocationPermissionsShowPrompt;

  /// Notify the host application that a request for Geolocation permissions,
  /// made with a previous call to `onGeolocationPermissionsShowPrompt` has been
  /// canceled.
  late void Function()? onGeolocationPermissionsHidePrompt;

  /// Report a JavaScript console message to the host application.
  late void Function(ConsoleMessage message)? onConsoleMessage;

  /// Notify the host application that the web page wants to display a
  /// JavaScript `alert()` dialog.
  @async
  late void Function(WebView webView, String url, String message)? onJsAlert;

  /// Notify the host application that the web page wants to display a
  /// JavaScript `confirm()` dialog.
  @async
  late bool Function(WebView webView, String url, String message) onJsConfirm;

  /// Notify the host application that the web page wants to display a
  /// JavaScript `prompt()` dialog.
  @async
  late String? Function(
    WebView webView,
    String url,
    String message,
    String defaultValue,
  )? onJsPrompt;

  /// Sets the required synchronous return value for the Java method,
  /// `WebChromeClient.onShowFileChooser(...)`.
  ///
  /// The Java method, `WebChromeClient.onShowFileChooser(...)`, requires
  /// a boolean to be returned and this method sets the returned value for all
  /// calls to the Java method.
  ///
  /// Setting this to true indicates that all file chooser requests should be
  /// handled by `onShowFileChooser` and the returned list of Strings will be
  /// returned to the WebView. Otherwise, the client will use the default
  /// handling and the returned value in `onShowFileChooser` will be ignored.
  ///
  /// Requires `onShowFileChooser` to be nonnull.
  ///
  /// Defaults to false.
  void setSynchronousReturnValueForOnShowFileChooser(bool value);

  /// Sets the required synchronous return value for the Java method,
  /// `WebChromeClient.onConsoleMessage(...)`.
  ///
  /// The Java method, `WebChromeClient.onConsoleMessage(...)`, requires
  /// a boolean to be returned and this method sets the returned value for all
  /// calls to the Java method.
  ///
  /// Setting this to true indicates that the client is handling all console
  /// messages.
  ///
  /// Requires `onConsoleMessage` to be nonnull.
  ///
  /// Defaults to false.
  void setSynchronousReturnValueForOnConsoleMessage(bool value);

  /// Sets the required synchronous return value for the Java method,
  /// `WebChromeClient.onJsAlert(...)`.
  ///
  /// The Java method, `WebChromeClient.onJsAlert(...)`, requires a boolean to
  /// be returned and this method sets the returned value for all calls to the
  /// Java method.
  ///
  /// Setting this to true indicates that the client is handling all console
  /// messages.
  ///
  /// Requires `onJsAlert` to be nonnull.
  ///
  /// Defaults to false.
  void setSynchronousReturnValueForOnJsAlert(bool value);

  /// Sets the required synchronous return value for the Java method,
  /// `WebChromeClient.onJsConfirm(...)`.
  ///
  /// The Java method, `WebChromeClient.onJsConfirm(...)`, requires a boolean to
  /// be returned and this method sets the returned value for all calls to the
  /// Java method.
  ///
  /// Setting this to true indicates that the client is handling all console
  /// messages.
  ///
  /// Requires `onJsConfirm` to be nonnull.
  ///
  /// Defaults to false.
  void setSynchronousReturnValueForOnJsConfirm(bool value);

  /// Sets the required synchronous return value for the Java method,
  /// `WebChromeClient.onJsPrompt(...)`.
  ///
  /// The Java method, `WebChromeClient.onJsPrompt(...)`, requires a boolean to
  /// be returned and this method sets the returned value for all calls to the
  /// Java method.
  ///
  /// Setting this to true indicates that the client is handling all console
  /// messages.
  ///
  /// Requires `onJsPrompt` to be nonnull.
  ///
  /// Defaults to false.
  void setSynchronousReturnValueForOnJsPrompt(bool value);
}

/// Provides access to the assets registered as part of the App bundle.
///
/// Convenience class for accessing Flutter asset resources.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'io.flutter.plugins.webviewflutter.FlutterAssetManager',
  ),
)
abstract class FlutterAssetManager {
  /// The global instance of the `FlutterAssetManager`.
  @static
  late FlutterAssetManager instance;

  /// Returns a String array of all the assets at the given path.
  ///
  /// Throws an IOException in case I/O operations were interrupted.
  List<String> list(String path);

  /// Gets the relative file path to the Flutter asset with the given name, including the file's
  /// extension, e.g., "myImage.jpg".
  ///
  /// The returned file path is relative to the Android app's standard asset's
  /// directory. Therefore, the returned path is appropriate to pass to
  /// Android's AssetManager, but the path is not appropriate to load as an
  /// absolute path.
  String getAssetFilePathByName(String name);
}

/// This class is used to manage the JavaScript storage APIs provided by the
/// WebView.
///
/// See https://developer.android.com/reference/android/webkit/WebStorage.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.webkit.WebStorage',
  ),
)
abstract class WebStorage {
  @static
  late WebStorage instance;

  /// Clears all storage currently being used by the JavaScript storage APIs.
  void deleteAllData();
}

/// Parameters used in the `WebChromeClient.onShowFileChooser` method.
///
/// See https://developer.android.com/reference/android/webkit/WebChromeClient.FileChooserParams.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.webkit.WebChromeClient.FileChooserParams',
  ),
)
abstract class FileChooserParams {
  /// Preference for a live media captured value (e.g. Camera, Microphone).
  late bool isCaptureEnabled;

  /// An array of acceptable MIME types.
  late List<String> acceptTypes;

  /// File chooser mode.
  late FileChooserMode mode;

  /// File name of a default selection if specified, or null.
  late String? filenameHint;
}

/// This class defines a permission request and is used when web content
/// requests access to protected resources.
///
/// See https://developer.android.com/reference/android/webkit/PermissionRequest.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.webkit.PermissionRequest',
  ),
)
abstract class PermissionRequest {
  late List<String> resources;

  /// Call this method to grant origin the permission to access the given
  /// resources.
  void grant(List<String> resources);

  /// Call this method to deny the request.
  void deny();
}

/// A callback interface used by the host application to notify the current page
/// that its custom view has been dismissed.
///
/// See https://developer.android.com/reference/android/webkit/WebChromeClient.CustomViewCallback.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.webkit.WebChromeClient.CustomViewCallback',
  ),
)
abstract class CustomViewCallback {
  /// Invoked when the host application dismisses the custom view.
  void onCustomViewHidden();
}

/// This class represents the basic building block for user interface
/// components.
///
/// See https://developer.android.com/reference/android/view/View.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.view.View',
  ),
)
abstract class View {
  /// Set the scrolled position of your view.
  void scrollTo(int x, int y);

  /// Move the scrolled position of your view.
  void scrollBy(int x, int y);

  /// Return the scrolled position of this view.
  WebViewPoint getScrollPosition();

  /// Define whether the vertical scrollbar should be drawn or not.
  ///
  /// The scrollbar is not drawn by default.
  void setVerticalScrollBarEnabled(bool enabled);

  /// Define whether the horizontal scrollbar should be drawn or not.
  ///
  /// The scrollbar is not drawn by default.
  void setHorizontalScrollBarEnabled(bool enabled);

  /// Set the over-scroll mode for this view.
  void setOverScrollMode(OverScrollMode mode);
}

/// A callback interface used by the host application to set the Geolocation
/// permission state for an origin.
///
/// See https://developer.android.com/reference/android/webkit/GeolocationPermissions.Callback.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.webkit.GeolocationPermissions.Callback',
  ),
)
abstract class GeolocationPermissionsCallback {
  /// Sets the Geolocation permission state for the supplied origin.
  void invoke(String origin, bool allow, bool retain);
}

/// Represents a request for HTTP authentication.
///
/// See https://developer.android.com/reference/android/webkit/HttpAuthHandler.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.webkit.HttpAuthHandler',
  ),
)
abstract class HttpAuthHandler {
  /// Gets whether the credentials stored for the current host (i.e. the host
  /// for which `WebViewClient.onReceivedHttpAuthRequest` was called) are
  /// suitable for use.
  bool useHttpAuthUsernamePassword();

  /// Instructs the WebView to cancel the authentication request..
  void cancel();

  /// Instructs the WebView to proceed with the authentication with the given
  /// credentials.
  void proceed(String username, String password);
}

/// Defines a message containing a description and arbitrary data object that
/// can be sent to a `Handler`.
///
/// See https://developer.android.com/reference/android/os/Message.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(fullClassName: 'android.os.Message'),
)
abstract class AndroidMessage {
  /// Sends this message to the Android native `Handler` specified by
  /// getTarget().
  ///
  /// Throws a null pointer exception if this field has not been set.
  void sendToTarget();
}

/// Defines a message containing a description and arbitrary data object that
/// can be sent to a `Handler`.
///
/// See https://developer.android.com/reference/android/webkit/ClientCertRequest.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.webkit.ClientCertRequest',
  ),
)
abstract class ClientCertRequest {
  /// Cancel this request.
  void cancel();

  /// Ignore the request for now.
  void ignore();

  /// Proceed with the specified private key and client certificate chain.
  void proceed(PrivateKey privateKey, List<X509Certificate> chain);
}

/// A private key.
///
/// The purpose of this interface is to group (and provide type safety for) all
/// private key interfaces.
///
/// See https://developer.android.com/reference/java/security/PrivateKey.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'java.security.PrivateKey',
  ),
)
abstract class PrivateKey {}

/// Abstract class for X.509 certificates.
///
/// This provides a standard way to access all the attributes of an X.509
/// certificate.
///
/// See https://developer.android.com/reference/java/security/cert/X509Certificate.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'java.security.cert.X509Certificate',
  ),
)
abstract class X509Certificate extends Certificate {}

/// Represents a request for handling an SSL error.
///
/// See https://developer.android.com/reference/android/webkit/SslErrorHandler.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.webkit.SslErrorHandler',
  ),
)
abstract class SslErrorHandler {
  /// Instructs the WebView that encountered the SSL certificate error to
  /// terminate communication with the server.
  void cancel();

  /// Instructs the WebView that encountered the SSL certificate error to ignore
  /// the error and continue communicating with the server.
  void proceed();
}

/// This class represents a set of one or more SSL errors and the associated SSL
/// certificate.
///
/// See https://developer.android.com/reference/android/net/http/SslError.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.net.http.SslError',
  ),
)
abstract class SslError {
  /// Gets the SSL certificate associated with this object.
  late SslCertificate certificate;

  /// Gets the URL associated with this object.
  late String url;

  /// Gets the most severe SSL error in this object's set of errors.
  SslErrorType getPrimaryError();

  /// Determines whether this object includes the supplied error.
  bool hasError(SslErrorType error);
}

/// A distinguished name helper class.
///
/// A 3-tuple of:
/// the most specific common name (CN)
/// the most specific organization (O)
/// the most specific organizational unit (OU)
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.net.http.SslCertificate.DName',
  ),
)
abstract class SslCertificateDName {
  /// The most specific Common-name (CN) component of this name.
  String getCName();

  /// The distinguished name (normally includes CN, O, and OU names).
  String getDName();

  /// The most specific Organization (O) component of this name.
  String getOName();

  /// The most specific Organizational Unit (OU) component of this name.
  String getUName();
}

/// SSL certificate info (certificate details) class.
///
/// See https://developer.android.com/reference/android/net/http/SslCertificate.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'android.net.http.SslCertificate',
  ),
)
abstract class SslCertificate {
  /// Issued-by distinguished name or null if none has been set.
  SslCertificateDName? getIssuedBy();

  /// Issued-to distinguished name or null if none has been set.
  SslCertificateDName? getIssuedTo();

  /// Not-after date from the certificate validity period or null if none has been
  /// set.
  int? getValidNotAfterMsSinceEpoch();

  /// Not-before date from the certificate validity period or null if none has
  /// been set.
  int? getValidNotBeforeMsSinceEpoch();

  /// The X509Certificate used to create this SslCertificate or null if no
  /// certificate was provided.
  ///
  /// Always returns null on Android versions below Q.
  X509Certificate? getX509Certificate();
}

/// Abstract class for managing a variety of identity certificates.
///
/// See https://developer.android.com/reference/java/security/cert/Certificate.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'java.security.cert.Certificate',
  ),
)
abstract class Certificate {
  /// The encoded form of this certificate.
  Uint8List getEncoded();
}
