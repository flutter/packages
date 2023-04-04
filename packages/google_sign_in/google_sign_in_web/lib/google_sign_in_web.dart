// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show visibleForTesting, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:google_identity_services_web/loader.dart' as loader;
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

import 'src/button_configuration.dart' show GSIButtonConfiguration;
import 'src/dom.dart';
import 'src/flexible_size_html_element_view.dart';
import 'src/gis_client.dart';

// Export the configuration types for the renderButton method.
export 'src/button_configuration.dart'
    show
        GSIButtonConfiguration,
        GSIButtonLogoAlignment,
        GSIButtonShape,
        GSIButtonSize,
        GSIButtonText,
        GSIButtonTheme,
        GSIButtonType;

/// The `name` of the meta-tag to define a ClientID in HTML.
const String clientIdMetaName = 'google-signin-client_id';

/// The selector used to find the meta-tag that defines a ClientID in HTML.
const String clientIdMetaSelector = 'meta[name=$clientIdMetaName]';

/// The attribute name that stores the Client ID in the meta-tag that defines a Client ID in HTML.
const String clientIdAttributeName = 'content';

/// Implementation of the google_sign_in plugin for Web.
class GoogleSignInPlugin extends GoogleSignInPlatform {
  /// Constructs the plugin immediately and begins initializing it in the
  /// background.
  ///
  /// The plugin is completely initialized when [initialized] completed.
  ///
  /// For tests, the plugin can skip its loading process with [debugOverrideLoader],
  /// and the implementation of the underlying GIS SDK client through [debugOverrideGisSdkClient].
  GoogleSignInPlugin({
    @visibleForTesting
        bool debugOverrideLoader = false,
    @visibleForTesting
        GisSdkClient? debugOverrideGisSdkClient,
    @visibleForTesting
        StreamController<GoogleSignInUserData?>?
            debugOverrideUserDataController,
  })  : _gisClient = debugOverrideGisSdkClient,
        _userDataController = debugOverrideUserDataController ??
            StreamController<GoogleSignInUserData?>.broadcast() {
    autoDetectedClientId = html
        .querySelector(clientIdMetaSelector)
        ?.getAttribute(clientIdAttributeName);

    _registerButtonFactory();

    if (debugOverrideLoader) {
      _jsSdkLoadedFuture = Future<bool>.value(true);
    } else {
      _jsSdkLoadedFuture = loader.loadWebSdk();
    }
  }

  // A future that completes when the JS loader is done.
  late Future<void> _jsSdkLoadedFuture;
  // A future that completes when the `init` call is done.
  final Completer<void> _initDone = Completer<void>();
  // A (synchronous) marker to assert that `init` has been called.
  bool _isInitCalled = false;

  // A StreamController to communicate status changes from the GisSdkClient.
  final StreamController<GoogleSignInUserData?> _userDataController;

  // The instance of [GisSdkClient] backing the plugin.
  GisSdkClient? _gisClient;

  // This method throws if init or initWithParams hasn't been called at some
  // point in the past. It is used by the [initialized] getter to ensure that
  // users can't await on a Future that will never resolve.
  void _assertIsInitCalled() {
    if (!_isInitCalled) {
      throw StateError(
        'GoogleSignInPlugin::init() or GoogleSignInPlugin::initWithParams() '
        'must be called before any other method in this plugin.',
      );
    }
  }

  /// A future that resolves when the SDK has been correctly loaded.
  @visibleForTesting
  Future<void> get initialized {
    _assertIsInitCalled();
    return Future.wait<void>(
        <Future<void>>[_jsSdkLoadedFuture, _initDone.future]);
  }

  /// Stores the client ID if it was set in a meta-tag of the page.
  @visibleForTesting
  late String? autoDetectedClientId;

  /// Factory method that initializes the plugin with [GoogleSignInPlatform].
  static void registerWith(Registrar registrar) {
    GoogleSignInPlatform.instance = GoogleSignInPlugin();
  }

  @override
  Future<void> init({
    List<String> scopes = const <String>[],
    SignInOption signInOption = SignInOption.standard,
    String? hostedDomain,
    String? clientId,
  }) {
    return initWithParams(SignInInitParameters(
      scopes: scopes,
      signInOption: signInOption,
      hostedDomain: hostedDomain,
      clientId: clientId,
    ));
  }

  @override
  Future<void> initWithParams(SignInInitParameters params) async {
    final String? appClientId = params.clientId ?? autoDetectedClientId;
    assert(
        appClientId != null,
        'ClientID not set. Either set it on a '
        '<meta name="google-signin-client_id" content="CLIENT_ID" /> tag,'
        ' or pass clientId when initializing GoogleSignIn');

    assert(params.serverClientId == null,
        'serverClientId is not supported on Web.');

    assert(
        !params.scopes.any((String scope) => scope.contains(' ')),
        "OAuth 2.0 Scopes for Google APIs can't contain spaces. "
        'Check https://developers.google.com/identity/protocols/googlescopes '
        'for a list of valid OAuth 2.0 scopes.');

    _isInitCalled = true; // Mark `init` ASAP before going async.

    await _jsSdkLoadedFuture;

    _gisClient ??= GisSdkClient(
      clientId: appClientId!,
      hostedDomain: params.hostedDomain,
      initialScopes: List<String>.from(params.scopes),
      userDataController: _userDataController,
      loggingEnabled: kDebugMode,
    );

    _initDone.complete(); // Signal that `init` is fully done.
  }

  // Register a factory for the Button HtmlElementView.
  void _registerButtonFactory() {
    // ignore: avoid_dynamic_calls, undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'gsi_login_button',
      (int viewId) {
        final DomElement element = createDomElement('div');
        element.setAttribute('style',
            'width: 100%; height: 100%; overflow: hidden; display: flex; flex-wrap: wrap; align-content: center; justify-content: center;');
        element.id = 'sign_in_button_$viewId';
        return element;
      },
    );
  }

  /// Render the GSI button web experience.
  Widget renderButton({GSIButtonConfiguration? configuration}) {
    final GSIButtonConfiguration config =
        configuration ?? GSIButtonConfiguration();
    return FutureBuilder<void>(
      key: Key(config.hashCode.toString()),
      future: initialized,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.hasData) {
          return FlexHtmlElementView(
              viewType: 'gsi_login_button',
              onPlatformViewCreated: (int viewId) {
                final DomElement? element =
                    domDocument.querySelector('#sign_in_button_$viewId');
                assert(element != null,
                    'Cannot render GSI button. DOM is not ready!');
                _gisClient!.renderButton(element!, config);
              });
        }
        return const Text('Getting ready');
      },
    );
  }

  @override
  Future<GoogleSignInUserData?> signInSilently() async {
    await initialized;

    // The new user is being injected from the `userDataEvents` Stream.
    return _gisClient!.signInSilently();
  }

  @override
  Future<GoogleSignInUserData?> signIn() async {
    await initialized;

    // This method mainly does oauth2 authorization, which happens to also do
    // authentication if needed. However, the authentication information is not
    // returned anymore.
    //
    // This method will synthesize authentication information from the People API
    // if needed (or use the last identity seen from signInSilently).
    try {
      return _gisClient!.signIn();
    } catch (reason) {
      throw PlatformException(
        code: reason.toString(),
        message: 'Exception raised from signIn',
        details:
            'https://developers.google.com/identity/oauth2/web/guides/error',
      );
    }
  }

  @override
  Future<GoogleSignInTokenData> getTokens({
    required String email,
    bool? shouldRecoverAuth,
  }) async {
    await initialized;

    return _gisClient!.getTokens();
  }

  @override
  Future<void> signOut() async {
    await initialized;

    _gisClient!.signOut();
  }

  @override
  Future<void> disconnect() async {
    await initialized;

    _gisClient!.disconnect();
  }

  @override
  Future<bool> isSignedIn() async {
    await initialized;

    return _gisClient!.isSignedIn();
  }

  @override
  Future<void> clearAuthCache({required String token}) async {
    await initialized;

    _gisClient!.clearAuthCache();
  }

  @override
  Future<bool> requestScopes(List<String> scopes) async {
    await initialized;

    return _gisClient!.requestScopes(scopes);
  }

  @override
  Future<bool> canAccessScopes(List<String> scopes,
      {String? accessToken}) async {
    await initialized;

    return _gisClient!.canAccessScopes(scopes, accessToken);
  }

  @override
  Stream<GoogleSignInUserData?>? get userDataEvents =>
      _userDataController.stream;
}
