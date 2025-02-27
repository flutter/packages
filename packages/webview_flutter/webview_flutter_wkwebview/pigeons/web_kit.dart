// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_unused_constructor_parameters

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/common/web_kit.g.dart',
    copyrightHeader: 'pigeons/copyright.txt',
    swiftOut:
        'darwin/webview_flutter_wkwebview/Sources/webview_flutter_wkwebview/WebKitLibrary.g.swift',
  ),
)

/// The values that can be returned in a change dictionary.
///
/// See https://developer.apple.com/documentation/foundation/nskeyvalueobservingoptions.
enum KeyValueObservingOptions {
  /// Indicates that the change dictionary should provide the new attribute
  /// value, if applicable.
  newValue,

  /// Indicates that the change dictionary should contain the old attribute
  /// value, if applicable.
  oldValue,

  /// If specified, a notification should be sent to the observer immediately,
  /// before the observer registration method even returns.
  initialValue,

  /// Whether separate notifications should be sent to the observer before and
  /// after each change, instead of a single notification after the change.
  priorNotification,
}

/// The kinds of changes that can be observed.
///
/// See https://developer.apple.com/documentation/foundation/nskeyvaluechange.
enum KeyValueChange {
  /// Indicates that the value of the observed key path was set to a new value.
  setting,

  /// Indicates that an object has been inserted into the to-many relationship
  /// that is being observed.
  insertion,

  /// Indicates that an object has been removed from the to-many relationship
  /// that is being observed.
  removal,

  /// Indicates that an object has been replaced in the to-many relationship
  /// that is being observed.
  replacement,

  /// The value is not recognized by the wrapper.
  unknown,
}

/// The keys that can appear in the change dictionary.
///
/// See https://developer.apple.com/documentation/foundation/nskeyvaluechangekey.
enum KeyValueChangeKey {
  /// If the value of the `KeyValueChangeKey.kind` entry is
  /// `KeyValueChange.insertion`, `KeyValueChange.removal`, or
  /// `KeyValueChange.replacement`, the value of this key is a Set object that
  /// contains the indexes of the inserted, removed, or replaced objects.
  indexes,

  /// An object that contains a value corresponding to one of the
  /// `KeyValueChange` enum, indicating what sort of change has occurred.
  kind,

  /// If the value of the `KeyValueChange.kind` entry is
  /// `KeyValueChange.setting, and `KeyValueObservingOptions.newValue` was
  /// specified when the observer was registered, the value of this key is the
  /// new value for the attribute.
  newValue,

  /// If the `KeyValueObservingOptions.priorNotification` option was specified
  /// when the observer was registered this notification is sent prior to a
  /// change.
  notificationIsPrior,

  /// If the value of the `KeyValueChange.kind` entry is
  /// `KeyValueChange.setting`, and `KeyValueObservingOptions.old` was specified
  /// when the observer was registered, the value of this key is the value
  /// before the attribute was changed.
  oldValue,

  /// The value is not recognized by the wrapper.
  unknown,
}

/// Constants for the times at which to inject script content into a webpage.
///
/// See https://developer.apple.com/documentation/webkit/wkuserscriptinjectiontime.
enum UserScriptInjectionTime {
  /// A constant to inject the script after the creation of the webpage’s
  /// document element, but before loading any other content.
  atDocumentStart,

  /// A constant to inject the script after the document finishes loading, but
  /// before loading any other subresources.
  atDocumentEnd,

  /// The value is not recognized by the wrapper.
  unknown,
}

/// The media types that require a user gesture to begin playing.
///
/// See https://developer.apple.com/documentation/webkit/wkaudiovisualmediatypes.
enum AudiovisualMediaType {
  /// No media types require a user gesture to begin playing.
  none,

  /// Media types that contain audio require a user gesture to begin playing.
  audio,

  /// Media types that contain video require a user gesture to begin playing.
  video,

  /// All media types require a user gesture to begin playing.
  all,
}

/// A `WKWebsiteDataRecord` object includes these constants in its dataTypes
/// property.
///
/// See https://developer.apple.com/documentation/webkit/wkwebsitedatarecord/data_store_record_types.
enum WebsiteDataType {
  /// Cookies.
  cookies,

  /// In-memory caches.
  memoryCache,

  /// On-disk caches.
  diskCache,

  /// HTML offline web app caches.
  offlineWebApplicationCache,

  /// HTML local storage.
  localStorage,

  /// HTML session storage.
  sessionStorage,

  /// WebSQL databases.
  webSQLDatabases,

  /// IndexedDB databases.
  indexedDBDatabases,
}

/// Constants that indicate whether to allow or cancel navigation to a webpage
/// from an action.
///
/// See https://developer.apple.com/documentation/webkit/wknavigationactionpolicy.
enum NavigationActionPolicy {
  /// Allow the navigation to continue.
  allow,

  /// Cancel the navigation.
  cancel,

  /// Allow the download to proceed.
  download,
}

/// Constants that indicate whether to allow or cancel navigation to a webpage
/// from a response.
///
/// See https://developer.apple.com/documentation/webkit/wknavigationresponsepolicy.
enum NavigationResponsePolicy {
  /// Allow the navigation to continue.
  allow,

  /// Cancel the navigation.
  cancel,

  /// Allow the download to proceed.
  download,
}

/// Constants that define the supported keys in a cookie attributes dictionary.
///
/// See https://developer.apple.com/documentation/foundation/httpcookiepropertykey.
enum HttpCookiePropertyKey {
  /// A String object containing the comment for the cookie.
  comment,

  /// An Uri object or String object containing the comment URL for the cookie.
  commentUrl,

  /// Aa String object stating whether the cookie should be discarded at the end
  /// of the session.
  discard,

  /// An String object containing the domain for the cookie.
  domain,

  /// An Date object or String object specifying the expiration date for the
  /// cookie.
  expires,

  /// An String object containing an integer value stating how long in seconds
  /// the cookie should be kept, at most.
  maximumAge,

  /// An String object containing the name of the cookie (required).
  name,

  /// A URL or String object containing the URL that set this cookie.
  originUrl,

  /// A String object containing the path for the cookie.
  path,

  /// An String object containing comma-separated integer values specifying the
  /// ports for the cookie.
  port,

  /// A string indicating the same-site policy for the cookie.
  sameSitePolicy,

  /// A String object indicating that the cookie should be transmitted only over
  /// secure channels.
  secure,

  /// A String object containing the value of the cookie.
  value,

  /// A String object that specifies the version of the cookie.
  version,

  /// The value is not recognized by the wrapper.
  unknown,
}

/// The type of action that triggered the navigation.
///
/// See https://developer.apple.com/documentation/webkit/wknavigationtype.
enum NavigationType {
  /// A link activation.
  linkActivated,

  /// A request to submit a form.
  formSubmitted,

  /// A request for the frame’s next or previous item.
  backForward,

  /// A request to reload the webpage.
  reload,

  /// A request to resubmit a form.
  formResubmitted,

  /// A navigation request that originates for some other reason.
  other,

  /// The value is not recognized by the wrapper.
  unknown,
}

/// Possible permission decisions for device resource access.
///
/// See https://developer.apple.com/documentation/webkit/wkpermissiondecision.
enum PermissionDecision {
  /// Deny permission for the requested resource.
  deny,

  /// Deny permission for the requested resource.
  grant,

  /// Prompt the user for permission for the requested resource.
  prompt,
}

/// List of the types of media devices that can capture audio, video, or both.
///
/// See https://developer.apple.com/documentation/webkit/wkmediacapturetype.
enum MediaCaptureType {
  /// A media device that can capture video.
  camera,

  /// A media device or devices that can capture audio and video.
  cameraAndMicrophone,

  /// A media device that can capture audio.
  microphone,

  /// The value is not recognized by the wrapper.
  unknown,
}

/// Responses to an authentication challenge.
///
/// See https://developer.apple.com/documentation/foundation/urlsession/authchallengedisposition.
enum UrlSessionAuthChallengeDisposition {
  /// Use the specified credential, which may be nil.
  useCredential,

  /// Use the default handling for the challenge as though this delegate method
  /// were not implemented.
  performDefaultHandling,

  /// Cancel the entire request.
  cancelAuthenticationChallenge,

  /// Reject this challenge, and call the authentication delegate method again
  /// with the next authentication protection space.
  rejectProtectionSpace,

  /// The value is not recognized by the wrapper.
  unknown,
}

/// Specifies how long a credential will be kept.
///
/// See https://developer.apple.com/documentation/foundation/nsurlcredentialpersistence.
enum UrlCredentialPersistence {
  /// The credential should not be stored.
  none,

  /// The credential should be stored only for this session.
  forSession,

  /// The credential should be stored in the keychain.
  permanent,

  /// The credential should be stored permanently in the keychain, and in
  /// addition should be distributed to other devices based on the owning Apple
  /// ID.
  synchronizable,
}

/// A URL load request that is independent of protocol or URL scheme.
///
/// See https://developer.apple.com/documentation/foundation/urlrequest.
@ProxyApi(swiftOptions: SwiftProxyApiOptions(name: 'URLRequestWrapper'))
abstract class URLRequest extends NSObject {
  URLRequest(String url);

  /// The URL being requested.
  String? getUrl();

  /// The HTTP request method.
  void setHttpMethod(String? method);

  /// The HTTP request method.
  String? getHttpMethod();

  /// The request body.
  void setHttpBody(Uint8List? body);

  /// The request body.
  Uint8List? getHttpBody();

  /// A dictionary containing all of the HTTP header fields for a request.
  void setAllHttpHeaderFields(Map<String, String>? fields);

  /// A dictionary containing all of the HTTP header fields for a request.
  Map<String, String>? getAllHttpHeaderFields();
}

/// The metadata associated with the response to an HTTP protocol URL load
/// request.
///
/// See https://developer.apple.com/documentation/foundation/httpurlresponse.
@ProxyApi()
abstract class HTTPURLResponse extends URLResponse {
  /// The response’s HTTP status code.
  late int statusCode;
}

/// The metadata associated with the response to a URL load request, independent
/// of protocol and URL scheme.
///
/// See https://developer.apple.com/documentation/foundation/urlresponse.
@ProxyApi()
abstract class URLResponse extends NSObject {}

/// A script that the web view injects into a webpage.
///
/// See https://developer.apple.com/documentation/webkit/wkuserscript.
@ProxyApi(swiftOptions: SwiftProxyApiOptions(import: 'WebKit'))
abstract class WKUserScript extends NSObject {
  /// Creates a user script object that contains the specified source code and
  /// attributes.
  WKUserScript();

  /// The script’s source code.
  late String source;

  /// The time at which to inject the script into the webpage.
  late UserScriptInjectionTime injectionTime;

  /// A Boolean value that indicates whether to inject the script into the main
  /// frame or all frames.
  late bool isForMainFrameOnly;
}

/// An object that contains information about an action that causes navigation
/// to occur.
///
/// See https://developer.apple.com/documentation/webkit/wknavigationaction.
@ProxyApi(swiftOptions: SwiftProxyApiOptions(import: 'WebKit'))
abstract class WKNavigationAction extends NSObject {
  /// The URL request object associated with the navigation action.
  late URLRequest request;

  /// The frame in which to display the new content.
  ///
  /// If the target of the navigation is a new window, this property is nil.
  late WKFrameInfo? targetFrame;

  /// The type of action that triggered the navigation.
  late NavigationType navigationType;
}

/// An object that contains the response to a navigation request, and which you
/// use to make navigation-related policy decisions.
///
/// See https://developer.apple.com/documentation/webkit/wknavigationresponse.
@ProxyApi(swiftOptions: SwiftProxyApiOptions(import: 'WebKit'))
abstract class WKNavigationResponse extends NSObject {
  /// The frame’s response.
  late URLResponse response;

  /// A Boolean value that indicates whether the response targets the web view’s
  /// main frame.
  late bool isForMainFrame;
}

/// An object that contains information about a frame on a webpage.
///
/// See https://developer.apple.com/documentation/webkit/wkframeinfo.
@ProxyApi(swiftOptions: SwiftProxyApiOptions(import: 'WebKit'))
abstract class WKFrameInfo extends NSObject {
  /// A Boolean value indicating whether the frame is the web site's main frame
  /// or a subframe.
  late bool isMainFrame;

  /// The frame’s current request.
  late URLRequest request;
}

/// Information about an error condition including a domain, a domain-specific
/// error code, and application-specific information.
///
/// See https://developer.apple.com/documentation/foundation/nserror.
@ProxyApi()
abstract class NSError extends NSObject {
  /// The error code.
  late int code;

  /// A string containing the error domain.
  late String domain;

  /// The user info dictionary.
  late Map<String, Object?> userInfo;
}

/// An object that encapsulates a message sent by JavaScript code from a
/// webpage.
///
/// See https://developer.apple.com/documentation/webkit/wkscriptmessage.
@ProxyApi(swiftOptions: SwiftProxyApiOptions(import: 'WebKit'))
abstract class WKScriptMessage extends NSObject {
  /// The name of the message handler to which the message is sent.
  late String name;

  /// The body of the message.
  late Object? body;
}

/// An object that identifies the origin of a particular resource.
///
/// See https://developer.apple.com/documentation/webkit/wksecurityorigin.
@ProxyApi(swiftOptions: SwiftProxyApiOptions(import: 'WebKit'))
abstract class WKSecurityOrigin extends NSObject {
  /// The security origin’s host.
  late String host;

  /// The security origin's port.
  late int port;

  /// The security origin's protocol.
  late String securityProtocol;
}

/// A representation of an HTTP cookie.
///
/// See https://developer.apple.com/documentation/foundation/httpcookie.
@ProxyApi()
abstract class HTTPCookie extends NSObject {
  HTTPCookie(Map<HttpCookiePropertyKey, Object> properties);

  /// The cookie’s properties.
  Map<HttpCookiePropertyKey, Object>? getProperties();
}

/// Response object used to return multiple values to an auth challenge received
/// by a `WKNavigationDelegate` auth challenge.
///
/// The `webView(_:didReceive:completionHandler:)` method in
/// `WKNavigationDelegate` responds with a completion handler that takes two
/// values. The wrapper returns this class instead to handle this scenario.
@ProxyApi()
abstract class AuthenticationChallengeResponse {
  AuthenticationChallengeResponse();

  /// The option to use to handle the challenge.
  late UrlSessionAuthChallengeDisposition disposition;

  /// The credential to use for authentication when the disposition parameter
  /// contains the value URLSession.AuthChallengeDisposition.useCredential.
  late URLCredential? credential;
}

/// An object that manages cookies, disk and memory caches, and other types of
/// data for a web view.
///
/// See https://developer.apple.com/documentation/webkit/wkwebsitedatastore.
@ProxyApi(swiftOptions: SwiftProxyApiOptions(import: 'WebKit'))
abstract class WKWebsiteDataStore extends NSObject {
  /// The default data store, which stores data persistently to disk.
  @static
  late WKWebsiteDataStore defaultDataStore;

  /// The object that manages the HTTP cookies for your website.
  @attached
  late WKHTTPCookieStore httpCookieStore;

  /// Removes the specified types of website data from one or more data records.
  @async
  bool removeDataOfTypes(
    List<WebsiteDataType> dataTypes,
    double modificationTimeInSecondsSinceEpoch,
  );
}

/// An object that manages the content for a rectangular area on the screen.
///
/// See https://developer.apple.com/documentation/uikit/uiview.
@ProxyApi(
  swiftOptions: SwiftProxyApiOptions(import: 'UIKit', supportsMacos: false),
)
abstract class UIView extends NSObject {
  /// The view’s background color.
  void setBackgroundColor(int? value);

  /// A Boolean value that determines whether the view is opaque.
  void setOpaque(bool opaque);
}

/// A view that allows the scrolling and zooming of its contained views.
///
/// See https://developer.apple.com/documentation/uikit/uiscrollview.
@ProxyApi(
  swiftOptions: SwiftProxyApiOptions(import: 'UIKit', supportsMacos: false),
)
abstract class UIScrollView extends UIView {
  /// The point at which the origin of the content view is offset from the
  /// origin of the scroll view.
  List<double> getContentOffset();

  /// Move the scrolled position of your view.
  ///
  /// Convenience method to synchronize change to the x and y scroll position.
  void scrollBy(double x, double y);

  /// The point at which the origin of the content view is offset from the
  /// origin of the scroll view.
  void setContentOffset(double x, double y);

  /// The delegate of the scroll view.
  void setDelegate(UIScrollViewDelegate? delegate);

  /// Whether the scroll view bounces past the edge of content and back again.
  void setBounces(bool value);

  /// Whether the scroll view bounces when it reaches the ends of its horizontal
  /// axis.
  void setBouncesHorizontally(bool value);

  /// Whether the scroll view bounces when it reaches the ends of its vertical
  /// axis.
  void setBouncesVertically(bool value);

  /// Whether bouncing always occurs when vertical scrolling reaches the end of
  /// the content.
  ///
  /// If the value of this property is true and `bouncesVertically` is true, the
  /// scroll view allows vertical dragging even if the content is smaller than
  /// the bounds of the scroll view.
  void setAlwaysBounceVertical(bool value);

  /// Whether bouncing always occurs when horizontal scrolling reaches the end
  /// of the content view.
  ///
  /// If the value of this property is true and `bouncesHorizontally` is true,
  /// the scroll view allows horizontal dragging even if the content is smaller
  /// than the bounds of the scroll view.
  void setAlwaysBounceHorizontal(bool value);
}

/// A collection of properties that you use to initialize a web view..
///
/// See https://developer.apple.com/documentation/webkit/wkwebviewconfiguration.
@ProxyApi(swiftOptions: SwiftProxyApiOptions(import: 'WebKit'))
abstract class WKWebViewConfiguration extends NSObject {
  WKWebViewConfiguration();

  /// The object that coordinates interactions between your app’s native code
  /// and the webpage’s scripts and other content.
  void setUserContentController(WKUserContentController controller);

  /// The object that coordinates interactions between your app’s native code
  /// and the webpage’s scripts and other content.
  WKUserContentController getUserContentController();

  /// The object you use to get and set the site’s cookies and to track the
  /// cached data objects.
  void setWebsiteDataStore(WKWebsiteDataStore dataStore);

  /// The object you use to get and set the site’s cookies and to track the
  /// cached data objects.
  WKWebsiteDataStore getWebsiteDataStore();

  /// The object that manages the preference-related settings for the web view.
  void setPreferences(WKPreferences preferences);

  /// The object that manages the preference-related settings for the web view.
  WKPreferences getPreferences();

  /// A Boolean value that indicates whether HTML5 videos play inline or use the
  /// native full-screen controller.
  void setAllowsInlineMediaPlayback(bool allow);

  /// A Boolean value that indicates whether the web view limits navigation to
  /// pages within the app’s domain.
  void setLimitsNavigationsToAppBoundDomains(bool limit);

  /// The media types that require a user gesture to begin playing.
  void setMediaTypesRequiringUserActionForPlayback(AudiovisualMediaType type);

  /// The default preferences to use when loading and rendering content.
  WKWebpagePreferences getDefaultWebpagePreferences();
}

/// An object for managing interactions between JavaScript code and your web
/// view, and for filtering content in your web view.
///
/// See https://developer.apple.com/documentation/webkit/wkusercontentcontroller.
@ProxyApi(swiftOptions: SwiftProxyApiOptions(import: 'WebKit'))
abstract class WKUserContentController extends NSObject {
  /// Installs a message handler that you can call from your JavaScript code.
  void addScriptMessageHandler(WKScriptMessageHandler handler, String name);

  /// Uninstalls the custom message handler with the specified name from your
  /// JavaScript code.
  void removeScriptMessageHandler(String name);

  /// Uninstalls all custom message handlers associated with the user content
  /// controller.
  void removeAllScriptMessageHandlers();

  /// Injects the specified script into the webpage’s content.
  void addUserScript(WKUserScript userScript);

  /// Removes all user scripts from the web view.
  void removeAllUserScripts();
}

/// An object that encapsulates the standard behaviors to apply to websites.
///
/// See https://developer.apple.com/documentation/webkit/wkpreferences.
@ProxyApi(swiftOptions: SwiftProxyApiOptions(import: 'WebKit'))
abstract class WKPreferences extends NSObject {
  /// A Boolean value that indicates whether JavaScript is enabled.
  void setJavaScriptEnabled(bool enabled);
}

/// An interface for receiving messages from JavaScript code running in a webpage.
///
/// See https://developer.apple.com/documentation/webkit/wkscriptmessagehandler.
@ProxyApi(swiftOptions: SwiftProxyApiOptions(import: 'WebKit'))
abstract class WKScriptMessageHandler extends NSObject {
  WKScriptMessageHandler();

  /// Tells the handler that a webpage sent a script message.
  late void Function(
    WKUserContentController controller,
    WKScriptMessage message,
  ) didReceiveScriptMessage;
}

/// Methods for accepting or rejecting navigation changes, and for tracking the
/// progress of navigation requests.
///
/// See https://developer.apple.com/documentation/webkit/wknavigationdelegate.
@ProxyApi(swiftOptions: SwiftProxyApiOptions(import: 'WebKit'))
abstract class WKNavigationDelegate extends NSObject {
  WKNavigationDelegate();

  /// Tells the delegate that navigation is complete.
  late void Function(WKWebView webView, String? url)? didFinishNavigation;

  /// Tells the delegate that navigation from the main frame has started.
  late void Function(
    WKWebView webView,
    String? url,
  )? didStartProvisionalNavigation;

  /// Asks the delegate for permission to navigate to new content based on the
  /// specified action information.
  @async
  late NavigationActionPolicy Function(
    WKWebView webView,
    WKNavigationAction navigationAction,
  ) decidePolicyForNavigationAction;

  /// Asks the delegate for permission to navigate to new content after the
  /// response to the navigation request is known.
  @async
  late NavigationResponsePolicy Function(
    WKWebView webView,
    WKNavigationResponse navigationResponse,
  ) decidePolicyForNavigationResponse;

  /// Tells the delegate that an error occurred during navigation.
  void Function(WKWebView webView, NSError error)? didFailNavigation;

  /// Tells the delegate that an error occurred during the early navigation
  /// process.
  void Function(WKWebView webView, NSError error)? didFailProvisionalNavigation;

  /// Tells the delegate that the web view’s content process was terminated.
  void Function(WKWebView webView)? webViewWebContentProcessDidTerminate;

  // TODO(bparrishMines): This method should return an
  // `AuthenticationChallengeResponse` once the cause of
  // https://github.com/flutter/flutter/issues/162437 can be found and fixed.
  /// Asks the delegate to respond to an authentication challenge.
  ///
  /// This return value expects a List with:
  ///
  /// 1. `UrlSessionAuthChallengeDisposition`
  /// 2. A nullable map to instantiate a `URLCredential`. The map structure is
  /// [
  ///   "user": "<nonnull String username>",
  ///   "password": "<nonnull String user password>",
  ///   "persistence": <nonnull enum value of `UrlCredentialPersistence`>,
  /// ]
  @async
  late List<Object?> Function(
    WKWebView webView,
    URLAuthenticationChallenge challenge,
  ) didReceiveAuthenticationChallenge;
}

/// The root class of most Objective-C class hierarchies, from which subclasses
/// inherit a basic interface to the runtime system and the ability to behave as
/// Objective-C objects.
///
/// See https://developer.apple.com/documentation/objectivec/nsobject.
@ProxyApi()
abstract class NSObject {
  NSObject();

  /// Informs the observing object when the value at the specified key path
  /// relative to the observed object has changed.
  late void Function(
    String? keyPath,
    NSObject? object,
    Map<KeyValueChangeKey, Object?>? change,
  )? observeValue;

  /// Registers the observer object to receive KVO notifications for the key
  /// path relative to the object receiving this message.
  void addObserver(
    NSObject observer,
    String keyPath,
    List<KeyValueObservingOptions> options,
  );

  /// Stops the observer object from receiving change notifications for the
  /// property specified by the key path relative to the object receiving this
  /// message.
  void removeObserver(NSObject observer, String keyPath);
}

/// An object that displays interactive web content, such as for an in-app
/// browser.
///
/// See https://developer.apple.com/documentation/webkit/wkwebview.
@ProxyApi(
  swiftOptions: SwiftProxyApiOptions(
    import: 'WebKit',
    name: 'WKWebView',
    supportsMacos: false,
  ),
)
abstract class UIViewWKWebView extends UIView implements WKWebView {
  UIViewWKWebView(WKWebViewConfiguration initialConfiguration);

  /// The object that contains the configuration details for the web view.
  @attached
  late WKWebViewConfiguration configuration;

  /// The scroll view associated with the web view.
  @attached
  late UIScrollView scrollView;

  /// The object you use to integrate custom user interface elements, such as
  /// contextual menus or panels, into web view interactions.
  void setUIDelegate(WKUIDelegate delegate);

  /// The object you use to manage navigation behavior for the web view.
  void setNavigationDelegate(WKNavigationDelegate delegate);

  /// The URL for the current webpage.
  String? getUrl();

  /// An estimate of what fraction of the current navigation has been loaded.
  double getEstimatedProgress();

  /// Loads the web content that the specified URL request object references and
  /// navigates to that content.
  void load(URLRequest request);

  /// Loads the contents of the specified HTML string and navigates to it.
  void loadHtmlString(String string, String? baseUrl);

  /// Loads the web content from the specified file and navigates to it.
  void loadFileUrl(String url, String readAccessUrl);

  /// Convenience method to load a Flutter asset.
  void loadFlutterAsset(String key);

  /// A Boolean value that indicates whether there is a valid back item in the
  /// back-forward list.
  bool canGoBack();

  /// A Boolean value that indicates whether there is a valid forward item in
  /// the back-forward list.
  bool canGoForward();

  /// Navigates to the back item in the back-forward list.
  void goBack();

  /// Navigates to the forward item in the back-forward list.
  void goForward();

  /// Reloads the current webpage.
  void reload();

  /// The page title.
  String? getTitle();

  /// A Boolean value that indicates whether horizontal swipe gestures trigger
  /// backward and forward page navigation.
  void setAllowsBackForwardNavigationGestures(bool allow);

  /// The custom user agent string.
  void setCustomUserAgent(String? userAgent);

  /// Evaluates the specified JavaScript string.
  @async
  Object? evaluateJavaScript(String javaScriptString);

  /// A Boolean value that indicates whether you can inspect the view with
  /// Safari Web Inspector.
  void setInspectable(bool inspectable);

  /// The custom user agent string.
  String? getCustomUserAgent();
}

/// An object that displays interactive web content, such as for an in-app
/// browser.
///
/// See https://developer.apple.com/documentation/webkit/wkwebview.
@ProxyApi(
  swiftOptions: SwiftProxyApiOptions(
    import: 'WebKit',
    name: 'WKWebView',
    supportsIos: false,
  ),
)
abstract class NSViewWKWebView extends NSObject implements WKWebView {
  NSViewWKWebView(WKWebViewConfiguration initialConfiguration);

  /// The object that contains the configuration details for the web view.
  @attached
  late WKWebViewConfiguration configuration;

  /// The object you use to integrate custom user interface elements, such as
  /// contextual menus or panels, into web view interactions.
  void setUIDelegate(WKUIDelegate delegate);

  /// The object you use to manage navigation behavior for the web view.
  void setNavigationDelegate(WKNavigationDelegate delegate);

  /// The URL for the current webpage.
  String? getUrl();

  /// An estimate of what fraction of the current navigation has been loaded.
  double getEstimatedProgress();

  /// Loads the web content that the specified URL request object references and
  /// navigates to that content.
  void load(URLRequest request);

  /// Loads the contents of the specified HTML string and navigates to it.
  void loadHtmlString(String string, String? baseUrl);

  /// Loads the web content from the specified file and navigates to it.
  void loadFileUrl(String url, String readAccessUrl);

  /// Convenience method to load a Flutter asset.
  void loadFlutterAsset(String key);

  /// A Boolean value that indicates whether there is a valid back item in the
  /// back-forward list.
  bool canGoBack();

  /// A Boolean value that indicates whether there is a valid forward item in
  /// the back-forward list.
  bool canGoForward();

  /// Navigates to the back item in the back-forward list.
  void goBack();

  /// Navigates to the forward item in the back-forward list.
  void goForward();

  /// Reloads the current webpage.
  void reload();

  /// The page title.
  String? getTitle();

  /// A Boolean value that indicates whether horizontal swipe gestures trigger
  /// backward and forward page navigation.
  void setAllowsBackForwardNavigationGestures(bool allow);

  /// The custom user agent string.
  void setCustomUserAgent(String? userAgent);

  /// Evaluates the specified JavaScript string.
  @async
  Object? evaluateJavaScript(String javaScriptString);

  /// A Boolean value that indicates whether you can inspect the view with
  /// Safari Web Inspector.
  void setInspectable(bool inspectable);

  /// The custom user agent string.
  String? getCustomUserAgent();
}

/// An object that displays interactive web content, such as for an in-app
/// browser.
///
/// See https://developer.apple.com/documentation/webkit/wkwebview.
@ProxyApi(
  swiftOptions: SwiftProxyApiOptions(
    import: 'WebKit',
    name: 'WKWebView',
  ),
)
abstract class WKWebView extends NSObject {}

/// The methods for presenting native user interface elements on behalf of a
/// webpage.
///
/// See https://developer.apple.com/documentation/webkit/wkuidelegate.
@ProxyApi(swiftOptions: SwiftProxyApiOptions(import: 'WebKit'))
abstract class WKUIDelegate extends NSObject {
  WKUIDelegate();

  /// Creates a new web view.
  void Function(
    WKWebView webView,
    WKWebViewConfiguration configuration,
    WKNavigationAction navigationAction,
  )? onCreateWebView;

  /// Determines whether a web resource, which the security origin object
  /// describes, can access to the device’s microphone audio and camera video.
  @async
  late PermissionDecision Function(
    WKWebView webView,
    WKSecurityOrigin origin,
    WKFrameInfo frame,
    MediaCaptureType type,
  ) requestMediaCapturePermission;

  /// Displays a JavaScript alert panel.
  @async
  void Function(
    WKWebView webView,
    String message,
    WKFrameInfo frame,
  )? runJavaScriptAlertPanel;

  /// Displays a JavaScript confirm panel.
  @async
  late bool Function(
    WKWebView webView,
    String message,
    WKFrameInfo frame,
  ) runJavaScriptConfirmPanel;

  /// Displays a JavaScript text input panel.
  @async
  String? Function(
    WKWebView webView,
    String prompt,
    String? defaultText,
    WKFrameInfo frame,
  )? runJavaScriptTextInputPanel;
}

/// An object that manages the HTTP cookies associated with a particular web
/// view.
///
/// See https://developer.apple.com/documentation/webkit/wkhttpcookiestore.
@ProxyApi(swiftOptions: SwiftProxyApiOptions(import: 'WebKit'))
abstract class WKHTTPCookieStore extends NSObject {
  /// Sets a cookie policy that indicates whether the cookie store allows cookie
  /// storage.
  @async
  void setCookie(HTTPCookie cookie);
}

/// The interface for the delegate of a scroll view.
///
/// See https://developer.apple.com/documentation/uikit/uiscrollviewdelegate.
@ProxyApi(
  swiftOptions: SwiftProxyApiOptions(import: 'UIKit', supportsMacos: false),
)
abstract class UIScrollViewDelegate extends NSObject {
  UIScrollViewDelegate();

  /// Tells the delegate when the user scrolls the content view within the
  /// scroll view.
  ///
  /// Note that this is a convenient method that includes the `contentOffset` of
  /// the `scrollView`.
  void Function(
    UIScrollView scrollView,
    double x,
    double y,
  )? scrollViewDidScroll;
}

/// An authentication credential consisting of information specific to the type
/// of credential and the type of persistent storage to use, if any.
///
/// See https://developer.apple.com/documentation/foundation/urlcredential.
@ProxyApi()
abstract class URLCredential extends NSObject {
  /// Creates a URL credential instance for internet password authentication
  /// with a given user name and password, using a given persistence setting.
  URLCredential.withUser(
    String user,
    String password,
    UrlCredentialPersistence persistence,
  );
}

/// A server or an area on a server, commonly referred to as a realm, that
/// requires authentication.
///
/// See https://developer.apple.com/documentation/foundation/urlprotectionspace.
@ProxyApi()
abstract class URLProtectionSpace extends NSObject {
  /// The receiver’s host.
  late String host;

  /// The receiver’s port.
  late int port;

  /// The receiver’s authentication realm.
  late String? realm;

  /// The authentication method used by the receiver.
  late String? authenticationMethod;
}

/// A challenge from a server requiring authentication from the client.
///
/// See https://developer.apple.com/documentation/foundation/urlauthenticationchallenge.
@ProxyApi()
abstract class URLAuthenticationChallenge extends NSObject {
  /// The receiver’s protection space.
  URLProtectionSpace getProtectionSpace();
}

/// A value that identifies the location of a resource, such as an item on a
/// remote server or the path to a local file.
///
/// See https://developer.apple.com/documentation/foundation/url.
@ProxyApi(swiftOptions: SwiftProxyApiOptions(name: 'URL'))
abstract class URL extends NSObject {
  /// The absolute string for the URL.
  String getAbsoluteString();
}

/// An object that specifies the behaviors to use when loading and rendering
/// page content.
///
/// See https://developer.apple.com/documentation/webkit/wkwebpagepreferences.
@ProxyApi(
  swiftOptions: SwiftProxyApiOptions(
    import: 'WebKit',
    minIosApi: '13.0.0',
    minMacosApi: '10.15.0',
  ),
)
abstract class WKWebpagePreferences extends NSObject {
  /// A Boolean value that indicates whether JavaScript from web content is
  /// allowed to run.
  void setAllowsContentJavaScript(bool allow);
}
