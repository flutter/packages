// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../common/instance_manager.dart';
import '../common/web_kit.g.dart';
import '../foundation/foundation.dart';
import '../ui_kit/ui_kit.dart';
import '../ui_kit/ui_kit_api_impls.dart';
import 'web_kit.dart';

export '../common/web_kit.g.dart'
    show WKMediaCaptureType, WKNavigationType, WKPermissionDecision;

Iterable<WKWebsiteDataTypeEnumData> _toWKWebsiteDataTypeEnumData(
    Iterable<WKWebsiteDataType> types) {
  return types.map<WKWebsiteDataTypeEnumData>((WKWebsiteDataType type) {
    late final WKWebsiteDataTypeEnum value;
    switch (type) {
      case WKWebsiteDataType.cookies:
        value = WKWebsiteDataTypeEnum.cookies;
      case WKWebsiteDataType.memoryCache:
        value = WKWebsiteDataTypeEnum.memoryCache;
      case WKWebsiteDataType.diskCache:
        value = WKWebsiteDataTypeEnum.diskCache;
      case WKWebsiteDataType.offlineWebApplicationCache:
        value = WKWebsiteDataTypeEnum.offlineWebApplicationCache;
      case WKWebsiteDataType.localStorage:
        value = WKWebsiteDataTypeEnum.localStorage;
      case WKWebsiteDataType.sessionStorage:
        value = WKWebsiteDataTypeEnum.sessionStorage;
      case WKWebsiteDataType.webSQLDatabases:
        value = WKWebsiteDataTypeEnum.webSQLDatabases;
      case WKWebsiteDataType.indexedDBDatabases:
        value = WKWebsiteDataTypeEnum.indexedDBDatabases;
    }

    return WKWebsiteDataTypeEnumData(value: value);
  });
}

extension _NSHttpCookieConverter on NSHttpCookie {
  NSHttpCookieData toNSHttpCookieData() {
    final Iterable<NSHttpCookiePropertyKey> keys = properties.keys;
    return NSHttpCookieData(
      propertyKeys: keys.map<NSHttpCookiePropertyKeyEnumData>(
        (NSHttpCookiePropertyKey key) {
          return key.toNSHttpCookiePropertyKeyEnumData();
        },
      ).toList(),
      propertyValues: keys
          .map<Object>((NSHttpCookiePropertyKey key) => properties[key]!)
          .toList(),
    );
  }
}

extension _WKNavigationActionPolicyConverter on WKNavigationActionPolicy {
  WKNavigationActionPolicyEnumData toWKNavigationActionPolicyEnumData() {
    return WKNavigationActionPolicyEnumData(
      value: WKNavigationActionPolicyEnum.values.firstWhere(
        (WKNavigationActionPolicyEnum element) => element.name == name,
      ),
    );
  }
}

extension _WKNavigationResponsePolicyConverter on WKNavigationResponsePolicy {
  WKNavigationResponsePolicyEnum toWKNavigationResponsePolicyEnumData() {
    return WKNavigationResponsePolicyEnum.values.firstWhere(
      (WKNavigationResponsePolicyEnum element) => element.name == name,
    );
  }
}

extension _NSHttpCookiePropertyKeyConverter on NSHttpCookiePropertyKey {
  NSHttpCookiePropertyKeyEnumData toNSHttpCookiePropertyKeyEnumData() {
    late final NSHttpCookiePropertyKeyEnum value;
    switch (this) {
      case NSHttpCookiePropertyKey.comment:
        value = NSHttpCookiePropertyKeyEnum.comment;
      case NSHttpCookiePropertyKey.commentUrl:
        value = NSHttpCookiePropertyKeyEnum.commentUrl;
      case NSHttpCookiePropertyKey.discard:
        value = NSHttpCookiePropertyKeyEnum.discard;
      case NSHttpCookiePropertyKey.domain:
        value = NSHttpCookiePropertyKeyEnum.domain;
      case NSHttpCookiePropertyKey.expires:
        value = NSHttpCookiePropertyKeyEnum.expires;
      case NSHttpCookiePropertyKey.maximumAge:
        value = NSHttpCookiePropertyKeyEnum.maximumAge;
      case NSHttpCookiePropertyKey.name:
        value = NSHttpCookiePropertyKeyEnum.name;
      case NSHttpCookiePropertyKey.originUrl:
        value = NSHttpCookiePropertyKeyEnum.originUrl;
      case NSHttpCookiePropertyKey.path:
        value = NSHttpCookiePropertyKeyEnum.path;
      case NSHttpCookiePropertyKey.port:
        value = NSHttpCookiePropertyKeyEnum.port;
      case NSHttpCookiePropertyKey.sameSitePolicy:
        value = NSHttpCookiePropertyKeyEnum.sameSitePolicy;
      case NSHttpCookiePropertyKey.secure:
        value = NSHttpCookiePropertyKeyEnum.secure;
      case NSHttpCookiePropertyKey.value:
        value = NSHttpCookiePropertyKeyEnum.value;
      case NSHttpCookiePropertyKey.version:
        value = NSHttpCookiePropertyKeyEnum.version;
    }

    return NSHttpCookiePropertyKeyEnumData(value: value);
  }
}

extension _WKUserScriptInjectionTimeConverter on WKUserScriptInjectionTime {
  WKUserScriptInjectionTimeEnumData toWKUserScriptInjectionTimeEnumData() {
    late final WKUserScriptInjectionTimeEnum value;
    switch (this) {
      case WKUserScriptInjectionTime.atDocumentStart:
        value = WKUserScriptInjectionTimeEnum.atDocumentStart;
      case WKUserScriptInjectionTime.atDocumentEnd:
        value = WKUserScriptInjectionTimeEnum.atDocumentEnd;
    }

    return WKUserScriptInjectionTimeEnumData(value: value);
  }
}

Iterable<WKAudiovisualMediaTypeEnumData> _toWKAudiovisualMediaTypeEnumData(
  Iterable<WKAudiovisualMediaType> types,
) {
  return types
      .map<WKAudiovisualMediaTypeEnumData>((WKAudiovisualMediaType type) {
    late final WKAudiovisualMediaTypeEnum value;
    switch (type) {
      case WKAudiovisualMediaType.none:
        value = WKAudiovisualMediaTypeEnum.none;
      case WKAudiovisualMediaType.audio:
        value = WKAudiovisualMediaTypeEnum.audio;
      case WKAudiovisualMediaType.video:
        value = WKAudiovisualMediaTypeEnum.video;
      case WKAudiovisualMediaType.all:
        value = WKAudiovisualMediaTypeEnum.all;
    }

    return WKAudiovisualMediaTypeEnumData(value: value);
  });
}

extension _NavigationActionDataConverter on WKNavigationActionData {
  WKNavigationAction toNavigationAction() {
    return WKNavigationAction(
      request: request.toNSUrlRequest(),
      targetFrame: targetFrame.toWKFrameInfo(),
      navigationType: navigationType,
    );
  }
}

extension _NavigationResponseDataConverter on WKNavigationResponseData {
  WKNavigationResponse toNavigationResponse() {
    return WKNavigationResponse(
        response: response.toNSUrlResponse(), forMainFrame: forMainFrame);
  }
}

extension _WKFrameInfoDataConverter on WKFrameInfoData {
  WKFrameInfo toWKFrameInfo() {
    return WKFrameInfo(
      isMainFrame: isMainFrame,
      request: request.toNSUrlRequest(),
    );
  }
}

extension _NSUrlRequestDataConverter on NSUrlRequestData {
  NSUrlRequest toNSUrlRequest() {
    return NSUrlRequest(
      url: url,
      httpBody: httpBody,
      httpMethod: httpMethod,
      allHttpHeaderFields: allHttpHeaderFields.cast(),
    );
  }
}

extension _NSUrlResponseDataConverter on NSHttpUrlResponseData {
  NSHttpUrlResponse toNSUrlResponse() {
    return NSHttpUrlResponse(statusCode: statusCode);
  }
}

extension _WKNSErrorDataConverter on NSErrorData {
  NSError toNSError() {
    return NSError(
      domain: domain,
      code: code,
      userInfo: userInfo?.cast<String, Object?>() ?? <String, Object?>{},
    );
  }
}

extension _WKScriptMessageDataConverter on WKScriptMessageData {
  WKScriptMessage toWKScriptMessage() {
    return WKScriptMessage(name: name, body: body);
  }
}

extension _WKUserScriptConverter on WKUserScript {
  WKUserScriptData toWKUserScriptData() {
    return WKUserScriptData(
      source: source,
      injectionTime: injectionTime.toWKUserScriptInjectionTimeEnumData(),
      isMainFrameOnly: isMainFrameOnly,
    );
  }
}

extension _NSUrlRequestConverter on NSUrlRequest {
  NSUrlRequestData toNSUrlRequestData() {
    return NSUrlRequestData(
      url: url,
      httpMethod: httpMethod,
      httpBody: httpBody,
      allHttpHeaderFields: allHttpHeaderFields,
    );
  }
}

extension _WKSecurityOriginConverter on WKSecurityOriginData {
  WKSecurityOrigin toWKSecurityOrigin() {
    return WKSecurityOrigin(host: host, port: port, protocol: protocol);
  }
}

/// Handles initialization of Flutter APIs for WebKit.
class WebKitFlutterApis {
  /// Constructs a [WebKitFlutterApis].
  @visibleForTesting
  WebKitFlutterApis({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  })  : _binaryMessenger = binaryMessenger,
        navigationDelegate = WKNavigationDelegateFlutterApiImpl(
          instanceManager: instanceManager,
        ),
        scriptMessageHandler = WKScriptMessageHandlerFlutterApiImpl(
          instanceManager: instanceManager,
        ),
        uiDelegate = WKUIDelegateFlutterApiImpl(
          instanceManager: instanceManager,
        ),
        webViewConfiguration = WKWebViewConfigurationFlutterApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
        uiScrollViewDelegate = UIScrollViewDelegateFlutterApiImpl(
          instanceManager: instanceManager,
        );

  static WebKitFlutterApis _instance = WebKitFlutterApis();

  /// Sets the global instance containing the Flutter Apis for the WebKit library.
  @visibleForTesting
  static set instance(WebKitFlutterApis instance) {
    _instance = instance;
  }

  /// Global instance containing the Flutter Apis for the WebKit library.
  static WebKitFlutterApis get instance {
    return _instance;
  }

  final BinaryMessenger? _binaryMessenger;
  bool _hasBeenSetUp = false;

  /// Flutter Api for [WKNavigationDelegate].
  @visibleForTesting
  final WKNavigationDelegateFlutterApiImpl navigationDelegate;

  /// Flutter Api for [WKScriptMessageHandler].
  @visibleForTesting
  final WKScriptMessageHandlerFlutterApiImpl scriptMessageHandler;

  /// Flutter Api for [WKUIDelegate].
  @visibleForTesting
  final WKUIDelegateFlutterApiImpl uiDelegate;

  /// Flutter Api for [WKWebViewConfiguration].
  @visibleForTesting
  final WKWebViewConfigurationFlutterApiImpl webViewConfiguration;

  /// Flutter Api for [UIScrollViewDelegate].
  @visibleForTesting
  final UIScrollViewDelegateFlutterApiImpl uiScrollViewDelegate;

  /// Ensures all the Flutter APIs have been set up to receive calls from native code.
  void ensureSetUp() {
    if (!_hasBeenSetUp) {
      WKNavigationDelegateFlutterApi.setUp(
        navigationDelegate,
        binaryMessenger: _binaryMessenger,
      );
      WKScriptMessageHandlerFlutterApi.setUp(
        scriptMessageHandler,
        binaryMessenger: _binaryMessenger,
      );
      WKUIDelegateFlutterApi.setUp(
        uiDelegate,
        binaryMessenger: _binaryMessenger,
      );
      WKWebViewConfigurationFlutterApi.setUp(
        webViewConfiguration,
        binaryMessenger: _binaryMessenger,
      );
      UIScrollViewDelegateFlutterApi.setUp(uiScrollViewDelegate,
          binaryMessenger: _binaryMessenger);
      _hasBeenSetUp = true;
    }
  }
}

/// Host api implementation for [WKWebSiteDataStore].
class WKWebsiteDataStoreHostApiImpl extends WKWebsiteDataStoreHostApi {
  /// Constructs a [WebsiteDataStoreHostApiImpl].
  WKWebsiteDataStoreHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? NSObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  /// Sends binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with Objective-C objects.
  final InstanceManager instanceManager;

  /// Calls [createFromWebViewConfiguration] with the ids of the provided object instances.
  Future<void> createFromWebViewConfigurationForInstances(
    WKWebsiteDataStore instance,
    WKWebViewConfiguration configuration,
  ) {
    return createFromWebViewConfiguration(
      instanceManager.addDartCreatedInstance(instance),
      instanceManager.getIdentifier(configuration)!,
    );
  }

  /// Calls [createDefaultDataStore] with the ids of the provided object instances.
  Future<void> createDefaultDataStoreForInstances(
    WKWebsiteDataStore instance,
  ) {
    return createDefaultDataStore(
      instanceManager.addDartCreatedInstance(instance),
    );
  }

  /// Calls [removeDataOfTypes] with the ids of the provided object instances.
  Future<bool> removeDataOfTypesForInstances(
    WKWebsiteDataStore instance,
    Set<WKWebsiteDataType> dataTypes, {
    required double secondsModifiedSinceEpoch,
  }) {
    return removeDataOfTypes(
      instanceManager.getIdentifier(instance)!,
      _toWKWebsiteDataTypeEnumData(dataTypes).toList(),
      secondsModifiedSinceEpoch,
    );
  }
}

/// Host api implementation for [WKScriptMessageHandler].
class WKScriptMessageHandlerHostApiImpl extends WKScriptMessageHandlerHostApi {
  /// Constructs a [WKScriptMessageHandlerHostApiImpl].
  WKScriptMessageHandlerHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? NSObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  /// Sends binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with Objective-C objects.
  final InstanceManager instanceManager;

  /// Calls [create] with the ids of the provided object instances.
  Future<void> createForInstances(WKScriptMessageHandler instance) {
    return create(instanceManager.addDartCreatedInstance(instance));
  }
}

/// Flutter api implementation for [WKScriptMessageHandler].
class WKScriptMessageHandlerFlutterApiImpl
    extends WKScriptMessageHandlerFlutterApi {
  /// Constructs a [WKScriptMessageHandlerFlutterApiImpl].
  WKScriptMessageHandlerFlutterApiImpl({InstanceManager? instanceManager})
      : instanceManager = instanceManager ?? NSObject.globalInstanceManager;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager instanceManager;

  WKScriptMessageHandler _getHandler(int identifier) {
    return instanceManager.getInstanceWithWeakReference(identifier)!;
  }

  @override
  void didReceiveScriptMessage(
    int identifier,
    int userContentControllerIdentifier,
    WKScriptMessageData message,
  ) {
    _getHandler(identifier).didReceiveScriptMessage(
      instanceManager.getInstanceWithWeakReference(
        userContentControllerIdentifier,
      )! as WKUserContentController,
      message.toWKScriptMessage(),
    );
  }
}

/// Host api implementation for [WKPreferences].
class WKPreferencesHostApiImpl extends WKPreferencesHostApi {
  /// Constructs a [WKPreferencesHostApiImpl].
  WKPreferencesHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? NSObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  /// Sends binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with Objective-C objects.
  final InstanceManager instanceManager;

  /// Calls [createFromWebViewConfiguration] with the ids of the provided object instances.
  Future<void> createFromWebViewConfigurationForInstances(
    WKPreferences instance,
    WKWebViewConfiguration configuration,
  ) {
    return createFromWebViewConfiguration(
      instanceManager.addDartCreatedInstance(instance),
      instanceManager.getIdentifier(configuration)!,
    );
  }

  /// Calls [setJavaScriptEnabled] with the ids of the provided object instances.
  Future<void> setJavaScriptEnabledForInstances(
    WKPreferences instance,
    bool enabled,
  ) {
    return setJavaScriptEnabled(
      instanceManager.getIdentifier(instance)!,
      enabled,
    );
  }
}

/// Host api implementation for [WKHttpCookieStore].
class WKHttpCookieStoreHostApiImpl extends WKHttpCookieStoreHostApi {
  /// Constructs a [WKHttpCookieStoreHostApiImpl].
  WKHttpCookieStoreHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? NSObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  /// Sends binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with Objective-C objects.
  final InstanceManager instanceManager;

  /// Calls [createFromWebsiteDataStore] with the ids of the provided object instances.
  Future<void> createFromWebsiteDataStoreForInstances(
    WKHttpCookieStore instance,
    WKWebsiteDataStore dataStore,
  ) {
    return createFromWebsiteDataStore(
      instanceManager.addDartCreatedInstance(instance),
      instanceManager.getIdentifier(dataStore)!,
    );
  }

  /// Calls [setCookie] with the ids of the provided object instances.
  Future<void> setCookieForInstances(
    WKHttpCookieStore instance,
    NSHttpCookie cookie,
  ) {
    return setCookie(
      instanceManager.getIdentifier(instance)!,
      cookie.toNSHttpCookieData(),
    );
  }
}

/// Host api implementation for [WKUserContentController].
class WKUserContentControllerHostApiImpl
    extends WKUserContentControllerHostApi {
  /// Constructs a [WKUserContentControllerHostApiImpl].
  WKUserContentControllerHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? NSObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  /// Sends binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with Objective-C objects.
  final InstanceManager instanceManager;

  /// Calls [createFromWebViewConfiguration] with the ids of the provided object instances.
  Future<void> createFromWebViewConfigurationForInstances(
    WKUserContentController instance,
    WKWebViewConfiguration configuration,
  ) {
    return createFromWebViewConfiguration(
      instanceManager.addDartCreatedInstance(instance),
      instanceManager.getIdentifier(configuration)!,
    );
  }

  /// Calls [addScriptMessageHandler] with the ids of the provided object instances.
  Future<void> addScriptMessageHandlerForInstances(
    WKUserContentController instance,
    WKScriptMessageHandler handler,
    String name,
  ) {
    return addScriptMessageHandler(
      instanceManager.getIdentifier(instance)!,
      instanceManager.getIdentifier(handler)!,
      name,
    );
  }

  /// Calls [removeScriptMessageHandler] with the ids of the provided object instances.
  Future<void> removeScriptMessageHandlerForInstances(
    WKUserContentController instance,
    String name,
  ) {
    return removeScriptMessageHandler(
      instanceManager.getIdentifier(instance)!,
      name,
    );
  }

  /// Calls [removeAllScriptMessageHandlers] with the ids of the provided object instances.
  Future<void> removeAllScriptMessageHandlersForInstances(
    WKUserContentController instance,
  ) {
    return removeAllScriptMessageHandlers(
      instanceManager.getIdentifier(instance)!,
    );
  }

  /// Calls [addUserScript] with the ids of the provided object instances.
  Future<void> addUserScriptForInstances(
    WKUserContentController instance,
    WKUserScript userScript,
  ) {
    return addUserScript(
      instanceManager.getIdentifier(instance)!,
      userScript.toWKUserScriptData(),
    );
  }

  /// Calls [removeAllUserScripts] with the ids of the provided object instances.
  Future<void> removeAllUserScriptsForInstances(
    WKUserContentController instance,
  ) {
    return removeAllUserScripts(instanceManager.getIdentifier(instance)!);
  }
}

/// Host api implementation for [WKWebViewConfiguration].
class WKWebViewConfigurationHostApiImpl extends WKWebViewConfigurationHostApi {
  /// Constructs a [WKWebViewConfigurationHostApiImpl].
  WKWebViewConfigurationHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? NSObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  /// Sends binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with Objective-C objects.
  final InstanceManager instanceManager;

  /// Calls [create] with the ids of the provided object instances.
  Future<void> createForInstances(WKWebViewConfiguration instance) {
    return create(instanceManager.addDartCreatedInstance(instance));
  }

  /// Calls [createFromWebView] with the ids of the provided object instances.
  Future<void> createFromWebViewForInstances(
    WKWebViewConfiguration instance,
    WKWebView webView,
  ) {
    return createFromWebView(
      instanceManager.addDartCreatedInstance(instance),
      instanceManager.getIdentifier(webView)!,
    );
  }

  /// Calls [setAllowsInlineMediaPlayback] with the ids of the provided object instances.
  Future<void> setAllowsInlineMediaPlaybackForInstances(
    WKWebViewConfiguration instance,
    bool allow,
  ) {
    return setAllowsInlineMediaPlayback(
      instanceManager.getIdentifier(instance)!,
      allow,
    );
  }

  /// Calls [setLimitsNavigationsToAppBoundDomains] with the ids of the provided object instances.
  Future<void> setLimitsNavigationsToAppBoundDomainsForInstances(
    WKWebViewConfiguration instance,
    bool limit,
  ) {
    return setLimitsNavigationsToAppBoundDomains(
      instanceManager.getIdentifier(instance)!,
      limit,
    );
  }

  /// Calls [setMediaTypesRequiringUserActionForPlayback] with the ids of the provided object instances.
  Future<void> setMediaTypesRequiringUserActionForPlaybackForInstances(
    WKWebViewConfiguration instance,
    Set<WKAudiovisualMediaType> types,
  ) {
    return setMediaTypesRequiringUserActionForPlayback(
      instanceManager.getIdentifier(instance)!,
      _toWKAudiovisualMediaTypeEnumData(types).toList(),
    );
  }
}

/// Flutter api implementation for [WKWebViewConfiguration].
@immutable
class WKWebViewConfigurationFlutterApiImpl
    extends WKWebViewConfigurationFlutterApi {
  /// Constructs a [WKWebViewConfigurationFlutterApiImpl].
  WKWebViewConfigurationFlutterApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  }) : instanceManager = instanceManager ?? NSObject.globalInstanceManager;

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager instanceManager;

  @override
  void create(int identifier) {
    instanceManager.addHostCreatedInstance(
      WKWebViewConfiguration.detached(
        binaryMessenger: binaryMessenger,
        instanceManager: instanceManager,
      ),
      identifier,
    );
  }
}

/// Host api implementation for [WKUIDelegate].
class WKUIDelegateHostApiImpl extends WKUIDelegateHostApi {
  /// Constructs a [WKUIDelegateHostApiImpl].
  WKUIDelegateHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? NSObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  /// Sends binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with Objective-C objects.
  final InstanceManager instanceManager;

  /// Calls [create] with the ids of the provided object instances.
  Future<void> createForInstances(WKUIDelegate instance) async {
    return create(instanceManager.addDartCreatedInstance(instance));
  }
}

/// Flutter api implementation for [WKUIDelegate].
class WKUIDelegateFlutterApiImpl extends WKUIDelegateFlutterApi {
  /// Constructs a [WKUIDelegateFlutterApiImpl].
  WKUIDelegateFlutterApiImpl({InstanceManager? instanceManager})
      : instanceManager = instanceManager ?? NSObject.globalInstanceManager;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager instanceManager;

  WKUIDelegate _getDelegate(int identifier) {
    return instanceManager.getInstanceWithWeakReference(identifier)!;
  }

  @override
  void onCreateWebView(
    int identifier,
    int webViewIdentifier,
    int configurationIdentifier,
    WKNavigationActionData navigationAction,
  ) {
    final void Function(WKWebView, WKWebViewConfiguration, WKNavigationAction)?
        function = _getDelegate(identifier).onCreateWebView;
    function?.call(
      instanceManager.getInstanceWithWeakReference(webViewIdentifier)!
          as WKWebView,
      instanceManager.getInstanceWithWeakReference(configurationIdentifier)!
          as WKWebViewConfiguration,
      navigationAction.toNavigationAction(),
    );
  }

  @override
  Future<WKPermissionDecisionData> requestMediaCapturePermission(
    int identifier,
    int webViewIdentifier,
    WKSecurityOriginData origin,
    WKFrameInfoData frame,
    WKMediaCaptureTypeData type,
  ) async {
    final WKUIDelegate instance =
        instanceManager.getInstanceWithWeakReference(identifier)!;

    late final WKPermissionDecision decision;
    if (instance.requestMediaCapturePermission != null) {
      decision = await instance.requestMediaCapturePermission!(
        instance,
        instanceManager.getInstanceWithWeakReference(webViewIdentifier)!
            as WKWebView,
        origin.toWKSecurityOrigin(),
        frame.toWKFrameInfo(),
        type.value,
      );
    } else {
      // The default response for iOS is to prompt. See
      // https://developer.apple.com/documentation/webkit/wkuidelegate/3763087-webview?language=objc
      decision = WKPermissionDecision.prompt;
    }

    return WKPermissionDecisionData(value: decision);
  }

  @override
  Future<void> runJavaScriptAlertPanel(
      int identifier, String message, WKFrameInfoData frame) {
    final WKUIDelegate instance =
        instanceManager.getInstanceWithWeakReference(identifier)!;
    return instance.runJavaScriptAlertDialog!
        .call(message, frame.toWKFrameInfo());
  }

  @override
  Future<bool> runJavaScriptConfirmPanel(
      int identifier, String message, WKFrameInfoData frame) {
    final WKUIDelegate instance =
        instanceManager.getInstanceWithWeakReference(identifier)!;
    return instance.runJavaScriptConfirmDialog!
        .call(message, frame.toWKFrameInfo());
  }

  @override
  Future<String> runJavaScriptTextInputPanel(int identifier, String prompt,
      String defaultText, WKFrameInfoData frame) {
    final WKUIDelegate instance =
        instanceManager.getInstanceWithWeakReference(identifier)!;
    return instance.runJavaScriptTextInputDialog!
        .call(prompt, defaultText, frame.toWKFrameInfo());
  }
}

/// Host api implementation for [WKNavigationDelegate].
class WKNavigationDelegateHostApiImpl extends WKNavigationDelegateHostApi {
  /// Constructs a [WKNavigationDelegateHostApiImpl].
  WKNavigationDelegateHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? NSObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  /// Sends binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with Objective-C objects.
  final InstanceManager instanceManager;

  /// Calls [create] with the ids of the provided object instances.
  Future<void> createForInstances(WKNavigationDelegate instance) async {
    return create(instanceManager.addDartCreatedInstance(instance));
  }
}

/// Flutter api implementation for [WKNavigationDelegate].
class WKNavigationDelegateFlutterApiImpl
    extends WKNavigationDelegateFlutterApi {
  /// Constructs a [WKNavigationDelegateFlutterApiImpl].
  WKNavigationDelegateFlutterApiImpl({InstanceManager? instanceManager})
      : instanceManager = instanceManager ?? NSObject.globalInstanceManager;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager instanceManager;

  WKNavigationDelegate _getDelegate(int identifier) {
    return instanceManager.getInstanceWithWeakReference(identifier)!;
  }

  @override
  void didFinishNavigation(
    int identifier,
    int webViewIdentifier,
    String? url,
  ) {
    final void Function(WKWebView, String?)? function =
        _getDelegate(identifier).didFinishNavigation;
    function?.call(
      instanceManager.getInstanceWithWeakReference(webViewIdentifier)!
          as WKWebView,
      url,
    );
  }

  @override
  Future<WKNavigationActionPolicyEnumData> decidePolicyForNavigationAction(
    int identifier,
    int webViewIdentifier,
    WKNavigationActionData navigationAction,
  ) async {
    final Future<WKNavigationActionPolicy> Function(
      WKWebView,
      WKNavigationAction navigationAction,
    )? function = _getDelegate(identifier).decidePolicyForNavigationAction;

    if (function == null) {
      return WKNavigationActionPolicyEnumData(
        value: WKNavigationActionPolicyEnum.allow,
      );
    }

    final WKNavigationActionPolicy policy = await function(
      instanceManager.getInstanceWithWeakReference(webViewIdentifier)!
          as WKWebView,
      navigationAction.toNavigationAction(),
    );
    return policy.toWKNavigationActionPolicyEnumData();
  }

  @override
  void didFailNavigation(
    int identifier,
    int webViewIdentifier,
    NSErrorData error,
  ) {
    final void Function(WKWebView, NSError)? function =
        _getDelegate(identifier).didFailNavigation;
    function?.call(
      instanceManager.getInstanceWithWeakReference(webViewIdentifier)!
          as WKWebView,
      error.toNSError(),
    );
  }

  @override
  void didFailProvisionalNavigation(
    int identifier,
    int webViewIdentifier,
    NSErrorData error,
  ) {
    final void Function(WKWebView, NSError)? function =
        _getDelegate(identifier).didFailProvisionalNavigation;
    function?.call(
      instanceManager.getInstanceWithWeakReference(webViewIdentifier)!
          as WKWebView,
      error.toNSError(),
    );
  }

  @override
  void didStartProvisionalNavigation(
    int identifier,
    int webViewIdentifier,
    String? url,
  ) {
    final void Function(WKWebView, String?)? function =
        _getDelegate(identifier).didStartProvisionalNavigation;
    function?.call(
      instanceManager.getInstanceWithWeakReference(webViewIdentifier)!
          as WKWebView,
      url,
    );
  }

  @override
  Future<WKNavigationResponsePolicyEnum> decidePolicyForNavigationResponse(
    int identifier,
    int webViewIdentifier,
    WKNavigationResponseData navigationResponse,
  ) async {
    final Future<WKNavigationResponsePolicy> Function(
      WKWebView,
      WKNavigationResponse navigationResponse,
    )? function = _getDelegate(identifier).decidePolicyForNavigationResponse;

    if (function == null) {
      return WKNavigationResponsePolicyEnum.allow;
    }

    final WKNavigationResponsePolicy policy = await function(
      instanceManager.getInstanceWithWeakReference(webViewIdentifier)!
          as WKWebView,
      navigationResponse.toNavigationResponse(),
    );
    return policy.toWKNavigationResponsePolicyEnumData();
  }

  @override
  void webViewWebContentProcessDidTerminate(
    int identifier,
    int webViewIdentifier,
  ) {
    final void Function(WKWebView)? function =
        _getDelegate(identifier).webViewWebContentProcessDidTerminate;
    function?.call(
      instanceManager.getInstanceWithWeakReference(webViewIdentifier)!
          as WKWebView,
    );
  }

  @override
  Future<AuthenticationChallengeResponse> didReceiveAuthenticationChallenge(
    int identifier,
    int webViewIdentifier,
    int challengeIdentifier,
  ) async {
    final void Function(
      WKWebView webView,
      NSUrlAuthenticationChallenge challenge,
      void Function(
        NSUrlSessionAuthChallengeDisposition disposition,
        NSUrlCredential? credential,
      ),
    )? function = _getDelegate(identifier).didReceiveAuthenticationChallenge;

    if (function == null) {
      return AuthenticationChallengeResponse(
        disposition: NSUrlSessionAuthChallengeDisposition.rejectProtectionSpace,
      );
    }

    final Completer<AuthenticationChallengeResponse> responseCompleter =
        Completer<AuthenticationChallengeResponse>();

    function.call(
      instanceManager.getInstanceWithWeakReference(webViewIdentifier)!
          as WKWebView,
      instanceManager.getInstanceWithWeakReference(challengeIdentifier)!
          as NSUrlAuthenticationChallenge,
      (
        NSUrlSessionAuthChallengeDisposition disposition,
        NSUrlCredential? credential,
      ) {
        responseCompleter.complete(
          AuthenticationChallengeResponse(
            disposition: disposition,
            credentialIdentifier: credential != null
                ? instanceManager.getIdentifier(credential)
                : null,
          ),
        );
      },
    );

    return responseCompleter.future;
  }
}

/// Host api implementation for [WKWebView].
class WKWebViewHostApiImpl extends WKWebViewHostApi {
  /// Constructs a [WKWebViewHostApiImpl].
  WKWebViewHostApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? NSObject.globalInstanceManager,
        super(binaryMessenger: binaryMessenger);

  /// Sends binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with Objective-C objects.
  final InstanceManager instanceManager;

  /// Calls [create] with the ids of the provided object instances.
  Future<void> createForInstances(
    WKWebView instance,
    WKWebViewConfiguration configuration,
  ) {
    return create(
      instanceManager.addDartCreatedInstance(instance),
      instanceManager.getIdentifier(configuration)!,
    );
  }

  /// Calls [loadRequest] with the ids of the provided object instances.
  Future<void> loadRequestForInstances(
    WKWebView webView,
    NSUrlRequest request,
  ) {
    return loadRequest(
      instanceManager.getIdentifier(webView)!,
      request.toNSUrlRequestData(),
    );
  }

  /// Calls [loadHtmlString] with the ids of the provided object instances.
  Future<void> loadHtmlStringForInstances(
    WKWebView instance,
    String string,
    String? baseUrl,
  ) {
    return loadHtmlString(
      instanceManager.getIdentifier(instance)!,
      string,
      baseUrl,
    );
  }

  /// Calls [loadFileUrl] with the ids of the provided object instances.
  Future<void> loadFileUrlForInstances(
    WKWebView instance,
    String url,
    String readAccessUrl,
  ) {
    return loadFileUrl(
      instanceManager.getIdentifier(instance)!,
      url,
      readAccessUrl,
    );
  }

  /// Calls [loadFlutterAsset] with the ids of the provided object instances.
  Future<void> loadFlutterAssetForInstances(WKWebView instance, String key) {
    return loadFlutterAsset(
      instanceManager.getIdentifier(instance)!,
      key,
    );
  }

  /// Calls [canGoBack] with the ids of the provided object instances.
  Future<bool> canGoBackForInstances(WKWebView instance) {
    return canGoBack(instanceManager.getIdentifier(instance)!);
  }

  /// Calls [canGoForward] with the ids of the provided object instances.
  Future<bool> canGoForwardForInstances(WKWebView instance) {
    return canGoForward(instanceManager.getIdentifier(instance)!);
  }

  /// Calls [goBack] with the ids of the provided object instances.
  Future<void> goBackForInstances(WKWebView instance) {
    return goBack(instanceManager.getIdentifier(instance)!);
  }

  /// Calls [goForward] with the ids of the provided object instances.
  Future<void> goForwardForInstances(WKWebView instance) {
    return goForward(instanceManager.getIdentifier(instance)!);
  }

  /// Calls [reload] with the ids of the provided object instances.
  Future<void> reloadForInstances(WKWebView instance) {
    return reload(instanceManager.getIdentifier(instance)!);
  }

  /// Calls [getUrl] with the ids of the provided object instances.
  Future<String?> getUrlForInstances(WKWebView instance) {
    return getUrl(instanceManager.getIdentifier(instance)!);
  }

  /// Calls [getTitle] with the ids of the provided object instances.
  Future<String?> getTitleForInstances(WKWebView instance) {
    return getTitle(instanceManager.getIdentifier(instance)!);
  }

  /// Calls [getEstimatedProgress] with the ids of the provided object instances.
  Future<double> getEstimatedProgressForInstances(WKWebView instance) {
    return getEstimatedProgress(instanceManager.getIdentifier(instance)!);
  }

  /// Calls [setAllowsBackForwardNavigationGestures] with the ids of the provided object instances.
  Future<void> setAllowsBackForwardNavigationGesturesForInstances(
    WKWebView instance,
    bool allow,
  ) {
    return setAllowsBackForwardNavigationGestures(
      instanceManager.getIdentifier(instance)!,
      allow,
    );
  }

  /// Calls [setCustomUserAgent] with the ids of the provided object instances.
  Future<void> setCustomUserAgentForInstances(
    WKWebView instance,
    String? userAgent,
  ) {
    return setCustomUserAgent(
      instanceManager.getIdentifier(instance)!,
      userAgent,
    );
  }

  /// Calls [evaluateJavaScript] with the ids of the provided object instances.
  Future<Object?> evaluateJavaScriptForInstances(
    WKWebView instance,
    String javaScriptString,
  ) async {
    try {
      final Object? result = await evaluateJavaScript(
        instanceManager.getIdentifier(instance)!,
        javaScriptString,
      );
      return result;
    } on PlatformException catch (exception) {
      if (exception.details is! NSErrorData) {
        rethrow;
      }

      throw PlatformException(
        code: exception.code,
        message: exception.message,
        stacktrace: exception.stacktrace,
        details: (exception.details as NSErrorData).toNSError(),
      );
    }
  }

  /// Calls [setInspectable] with the ids of the provided object instances.
  Future<void> setInspectableForInstances(
    WKWebView instance,
    bool inspectable,
  ) async {
    return setInspectable(
      instanceManager.getIdentifier(instance)!,
      inspectable,
    );
  }

  /// Calls [getCustomUserAgent] with the ids of the provided object instances.
  Future<String?> getCustomUserAgentForInstances(WKWebView instance) {
    return getCustomUserAgent(instanceManager.getIdentifier(instance)!);
  }

  /// Calls [setNavigationDelegate] with the ids of the provided object instances.
  Future<void> setNavigationDelegateForInstances(
    WKWebView instance,
    WKNavigationDelegate? delegate,
  ) {
    return setNavigationDelegate(
      instanceManager.getIdentifier(instance)!,
      delegate != null ? instanceManager.getIdentifier(delegate)! : null,
    );
  }

  /// Calls [setUIDelegate] with the ids of the provided object instances.
  Future<void> setUIDelegateForInstances(
    WKWebView instance,
    WKUIDelegate? delegate,
  ) {
    return setUIDelegate(
      instanceManager.getIdentifier(instance)!,
      delegate != null ? instanceManager.getIdentifier(delegate)! : null,
    );
  }
}
