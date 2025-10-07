// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui_web' as ui_web;

import 'package:flutter/foundation.dart' show kDebugMode, visibleForTesting;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:google_identity_services_web/loader.dart' as loader;
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:web/web.dart' as web;

import 'src/button_configuration.dart' show GSIButtonConfiguration;
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
  /// For tests, the plugin can skip its loading process with [debugOverrideLoader],
  /// and the implementation of the underlying GIS SDK client through [debugOverrideGisSdkClient].
  GoogleSignInPlugin({
    @visibleForTesting bool debugOverrideLoader = false,
    @visibleForTesting GisSdkClient? debugOverrideGisSdkClient,
    @visibleForTesting
    StreamController<AuthenticationEvent>? debugAuthenticationController,
  }) : _gisSdkClient = debugOverrideGisSdkClient,
       _authenticationController =
           debugAuthenticationController ??
           StreamController<AuthenticationEvent>.broadcast() {
    autoDetectedClientId = web.document
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
  Completer<void>? _initCalled;

  // A StreamController to communicate status changes from the GisSdkClient.
  final StreamController<AuthenticationEvent> _authenticationController;

  // The instance of [GisSdkClient] backing the plugin.
  GisSdkClient? _gisSdkClient;

  // A convenience getter to avoid using ! when accessing _gisSdkClient, and
  // providing a slightly better error message when it is Null.
  GisSdkClient get _gisClient {
    assert(
      _gisSdkClient != null,
      'GIS Client not initialized. '
      'GoogleSignInPlugin::init() or GoogleSignInPlugin::initWithParams() '
      'must be called before any other method in this plugin.',
    );
    return _gisSdkClient!;
  }

  // This method throws if init or initWithParams hasn't been called at some
  // point in the past. It is used by the [initialized] getter to ensure that
  // users can't await on a Future that will never resolve.
  void _assertIsInitCalled() {
    if (_initCalled == null) {
      throw StateError(
        'GoogleSignInPlugin::init() or GoogleSignInPlugin::initWithParams() '
        'must be called before any other method in this plugin.',
      );
    }
  }

  /// A future that resolves when the plugin is fully initialized.
  ///
  /// This ensures that the SDK has been loaded, and that the `init` method
  /// has finished running.
  @visibleForTesting
  Future<void> get initialized {
    _assertIsInitCalled();
    return Future.wait<void>(<Future<void>>[
      _jsSdkLoadedFuture,
      _initCalled!.future,
    ]);
  }

  /// Stores the client ID if it was set in a meta-tag of the page.
  @visibleForTesting
  late String? autoDetectedClientId;

  /// Factory method that initializes the plugin with [GoogleSignInPlatform].
  static void registerWith(Registrar registrar) {
    GoogleSignInPlatform.instance = GoogleSignInPlugin();
  }

  @override
  Future<void> init(InitParameters params) async {
    final String? appClientId = params.clientId ?? autoDetectedClientId;
    assert(
      appClientId != null,
      'ClientID not set. Either set it on a '
      '<meta name="google-signin-client_id" content="CLIENT_ID" /> tag,'
      ' or pass clientId when initializing GoogleSignIn',
    );

    assert(
      params.serverClientId == null,
      'serverClientId is not supported on Web.',
    );

    _initCalled = Completer<void>();

    await _jsSdkLoadedFuture;

    _gisSdkClient ??= GisSdkClient(
      clientId: appClientId!,
      nonce: params.nonce,
      hostedDomain: params.hostedDomain,
      authenticationController: _authenticationController,
      loggingEnabled: kDebugMode,
    );

    _initCalled!.complete(); // Signal that `init` is fully done.
  }

  @override
  Future<AuthenticationResults?>? attemptLightweightAuthentication(
    AttemptLightweightAuthenticationParameters params,
  ) {
    initialized.then((void value) {
      _gisClient.requestOneTap();
    });
    // One tap does not necessarily return immediately, and may never return,
    // so clients should not await it. Return null to signal that.
    return null;
  }

  @override
  bool supportsAuthenticate() => false;

  @override
  bool authorizationRequiresUserInteraction() => true;

  @override
  Future<AuthenticationResults> authenticate(
    AuthenticateParameters params,
  ) async {
    throw UnimplementedError(
      'authenticate is not supported on the web. '
      'Instead, use renderButton to create a sign-in widget.',
    );
  }

  @override
  Future<void> signOut(SignOutParams params) async {
    await initialized;

    await _gisClient.signOut();
  }

  @override
  Future<void> disconnect(DisconnectParams params) async {
    await initialized;

    await _gisClient.disconnect();
  }

  @override
  Future<ClientAuthorizationTokenData?> clientAuthorizationTokensForScopes(
    ClientAuthorizationTokensForScopesParameters params,
  ) async {
    await initialized;
    _validateScopes(params.request.scopes);

    final String? token = await _gisClient.requestScopes(
      params.request.scopes,
      promptIfUnauthorized: params.request.promptIfUnauthorized,
      userHint: params.request.userId,
    );
    return token == null
        ? null
        : ClientAuthorizationTokenData(accessToken: token);
  }

  @override
  Future<ServerAuthorizationTokenData?> serverAuthorizationTokensForScopes(
    ServerAuthorizationTokensForScopesParameters params,
  ) async {
    await initialized;
    _validateScopes(params.request.scopes);

    // There is no way to know whether the flow will prompt in advance, so
    // always return null if prompting isn't allowed.
    if (!params.request.promptIfUnauthorized) {
      return null;
    }

    final String? code = await _gisClient.requestServerAuthCode(params.request);
    return code == null
        ? null
        : ServerAuthorizationTokenData(serverAuthCode: code);
  }

  void _validateScopes(List<String> scopes) {
    // Scope lists are space-delimited in the underlying implementation, so
    // scopes must not contain any spaces.
    // https://developers.google.com/identity/protocols/oauth2/javascript-implicit-flow#redirecting
    assert(
      !scopes.any((String scope) => scope.contains(' ')),
      "OAuth 2.0 Scopes for Google APIs can't contain spaces. "
      'Check https://developers.google.com/identity/protocols/googlescopes '
      'for a list of valid OAuth 2.0 scopes.',
    );
  }

  @override
  Future<void> clearAuthorizationToken(
    ClearAuthorizationTokenParams params,
  ) async {
    await initialized;
    return _gisClient.clearAuthorizationToken(params.accessToken);
  }

  @override
  Stream<AuthenticationEvent> get authenticationEvents =>
      _authenticationController.stream;

  // --------

  // Register a factory for the Button HtmlElementView.
  void _registerButtonFactory() {
    ui_web.platformViewRegistry.registerViewFactory('gsi_login_button', (
      int viewId,
    ) {
      final web.Element element = web.document.createElement('div');
      element.setAttribute(
        'style',
        'width: 100%; height: 100%; overflow: hidden; display: flex; flex-wrap: wrap; align-content: center; justify-content: center;',
      );
      element.id = 'sign_in_button_$viewId';
      return element;
    });
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
            onElementCreated: (Object element) {
              _gisClient.renderButton(element, config);
            },
          );
        }
        return const Text('Getting ready');
      },
    );
  }
}
