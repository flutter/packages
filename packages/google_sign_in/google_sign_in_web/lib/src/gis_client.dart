// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';
import 'dart:js_interop';

// TODO(dit): Split `id` and `oauth2` "services" for mocking. https://github.com/flutter/flutter/issues/120657
import 'package:google_identity_services_web/id.dart';
import 'package:google_identity_services_web/oauth2.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:web/web.dart' as web;

import 'button_configuration.dart'
    show GSIButtonConfiguration, convertButtonConfiguration;
import 'people.dart' as people;
import 'utils.dart' as utils;

/// A client to hide (most) of the interaction with the GIS SDK from the plugin.
///
/// (Overridable for testing)
class GisSdkClient {
  /// Create a GisSdkClient object.
  GisSdkClient({
    required List<String> initialScopes,
    required String clientId,
    required StreamController<GoogleSignInUserData?> userDataController,
    bool loggingEnabled = false,
    String? hostedDomain,
  })  : _initialScopes = initialScopes,
        _loggingEnabled = loggingEnabled,
        _userDataEventsController = userDataController {
    if (_loggingEnabled) {
      id.setLogLevel('debug');
    }
    // Configure the Stream objects that are going to be used by the clients.
    _configureStreams();

    // Initialize the SDK clients we need.
    _initializeIdClient(
      clientId,
      onResponse: _onCredentialResponse,
      hostedDomain: hostedDomain,
      useFedCM: true,
    );

    _tokenClient = _initializeTokenClient(
      clientId,
      hostedDomain: hostedDomain,
      onResponse: _onTokenResponse,
      onError: _onTokenError,
    );

    if (initialScopes.isNotEmpty) {
      _codeClient = _initializeCodeClient(
        clientId,
        hostedDomain: hostedDomain,
        onResponse: _onCodeResponse,
        onError: _onCodeError,
        scopes: initialScopes,
      );
    }
  }

  void _logIfEnabled(String message, [List<Object?>? more]) {
    if (_loggingEnabled) {
      final String log =
          <Object?>['[google_sign_in_web]', message, ...?more].join(' ');
      web.console.info(log.toJS);
    }
  }

  // Configure the credential (authentication) and token (authorization) response streams.
  void _configureStreams() {
    _tokenResponses = StreamController<TokenResponse>.broadcast();
    _credentialResponses = StreamController<CredentialResponse>.broadcast();
    _codeResponses = StreamController<CodeResponse>.broadcast();

    _tokenResponses.stream.listen((TokenResponse response) {
      _lastTokenResponse = response;
      _lastTokenResponseExpiration =
          DateTime.now().add(Duration(seconds: response.expires_in!));
    }, onError: (Object error) {
      _logIfEnabled('Error on TokenResponse:', <Object>[error.toString()]);
      _lastTokenResponse = null;
    });

    _codeResponses.stream.listen((CodeResponse response) {
      _lastCodeResponse = response;
    }, onError: (Object error) {
      _logIfEnabled('Error on CodeResponse:', <Object>[error.toString()]);
      _lastCodeResponse = null;
    });

    _credentialResponses.stream.listen((CredentialResponse response) {
      _lastCredentialResponse = response;
    }, onError: (Object error) {
      _logIfEnabled('Error on CredentialResponse:', <Object>[error.toString()]);
      _lastCredentialResponse = null;
    });

    // In the future, the userDataEvents could propagate null userDataEvents too.
    _credentialResponses.stream
        .map(utils.gisResponsesToUserData)
        .handleError(_cleanCredentialResponsesStreamErrors)
        .forEach(_userDataEventsController.add);
  }

  // This function handles the errors that on the _credentialResponses Stream.
  //
  // Most of the time, these errors are part of the flow (like when One Tap UX
  // cannot be rendered), and the stream of userDataEvents doesn't care about
  // them.
  //
  // (This has been separated to a function so the _configureStreams formatting
  // looks a little bit better)
  void _cleanCredentialResponsesStreamErrors(Object error) {
    _logIfEnabled(
      'Removing error from `userDataEvents`:',
      <Object>[error.toString()],
    );
  }

  // Initializes the `id` SDK for the silent-sign in (authentication) client.
  void _initializeIdClient(
    String clientId, {
    required CallbackFn onResponse,
    String? hostedDomain,
    bool? useFedCM,
  }) {
    // Initialize `id` for the silent-sign in code.
    final IdConfiguration idConfig = IdConfiguration(
      client_id: clientId,
      callback: onResponse,
      cancel_on_tap_outside: false,
      auto_select: true, // Attempt to sign-in silently.
      hd: hostedDomain,
      use_fedcm_for_prompt:
          useFedCM, // Use the native browser prompt, when available.
    );
    id.initialize(idConfig);
  }

  // Handle a "normal" credential (authentication) response.
  //
  // (Normal doesn't mean successful, this might contain `error` information.)
  void _onCredentialResponse(CredentialResponse response) {
    if (response.error != null) {
      _credentialResponses.addError(response.error!);
    } else {
      _credentialResponses.add(response);
    }
  }

  // Creates a `oauth2.TokenClient` used for authorization (scope) requests.
  TokenClient _initializeTokenClient(
    String clientId, {
    String? hostedDomain,
    required TokenClientCallbackFn onResponse,
    required ErrorCallbackFn onError,
  }) {
    // Create a Token Client for authorization calls.
    final TokenClientConfig tokenConfig = TokenClientConfig(
      client_id: clientId,
      hd: hostedDomain,
      callback: _onTokenResponse,
      error_callback: _onTokenError,
      // This is here only to satisfy the initialization of the JS TokenClient.
      // In reality, `scope` is always overridden when calling `requestScopes`
      // (or the deprecated `signIn`) through an [OverridableTokenClientConfig]
      // object.
      scope: <String>[' '], // Fake (but non-empty) list of scopes.
    );
    return oauth2.initTokenClient(tokenConfig);
  }

  // Handle a "normal" token (authorization) response.
  //
  // (Normal doesn't mean successful, this might contain `error` information.)
  void _onTokenResponse(TokenResponse response) {
    if (response.error != null) {
      _tokenResponses.addError(response.error!);
    } else {
      _tokenResponses.add(response);
    }
  }

  // Handle a "not-directly-related-to-authorization" error.
  //
  // Token clients have an additional `error_callback` for miscellaneous
  // errors, like "popup couldn't open" or "popup closed by user".
  void _onTokenError(GoogleIdentityServicesError? error) {
    if (error != null) {
      _tokenResponses.addError(error.type);
    }
  }

// Creates a `oauth2.CodeClient` used for authorization (scope) requests.
  CodeClient _initializeCodeClient(
    String clientId, {
    String? hostedDomain,
    required List<String> scopes,
    required CodeClientCallbackFn onResponse,
    required ErrorCallbackFn onError,
  }) {
    // Create a Token Client for authorization calls.
    final CodeClientConfig codeConfig = CodeClientConfig(
      client_id: clientId,
      hd: hostedDomain,
      callback: _onCodeResponse,
      error_callback: _onCodeError,
      scope: scopes,
      select_account: true,
      ux_mode: UxMode.popup,
    );
    return oauth2.initCodeClient(codeConfig);
  }

  void _onCodeResponse(CodeResponse response) {
    if (response.error != null) {
      _codeResponses.addError(response.error!);
    } else {
      _codeResponses.add(response);
    }
  }

  void _onCodeError(GoogleIdentityServicesError? error) {
    if (error != null) {
      _codeResponses.addError(error.type);
    }
  }

  /// Attempts to sign-in the user using the OneTap UX flow.
  ///
  /// If the user consents, to OneTap, the [GoogleSignInUserData] will be
  /// generated from a proper [CredentialResponse], which contains `idToken`.
  /// Else, it'll be synthesized by a request to the People API later, and the
  /// `idToken` will be null.
  Future<GoogleSignInUserData?> signInSilently() async {
    final Completer<GoogleSignInUserData?> userDataCompleter =
        Completer<GoogleSignInUserData?>();

    // Ask the SDK to render the OneClick sign-in.
    //
    // And also handle its "moments".
    id.prompt((PromptMomentNotification moment) {
      _onPromptMoment(moment, userDataCompleter);
    });

    return userDataCompleter.future;
  }

  // Handles "prompt moments" of the OneClick card UI.
  //
  // See: https://developers.google.com/identity/gsi/web/guides/receive-notifications-prompt-ui-status
  Future<void> _onPromptMoment(
    PromptMomentNotification moment,
    Completer<GoogleSignInUserData?> completer,
  ) async {
    if (completer.isCompleted) {
      return; // Skip once the moment has been handled.
    }

    if (moment.isDismissedMoment() &&
        moment.getDismissedReason() ==
            MomentDismissedReason.credential_returned) {
      // Kick this part of the handler to the bottom of the JS event queue, so
      // the _credentialResponses stream has time to propagate its last value,
      // and we can use _lastCredentialResponse.
      return Future<void>.delayed(Duration.zero, () {
        completer
            .complete(utils.gisResponsesToUserData(_lastCredentialResponse));
      });
    }

    // In any other 'failed' moments, return null and add an error to the stream.
    if (moment.isNotDisplayed() ||
        moment.isSkippedMoment() ||
        moment.isDismissedMoment()) {
      final String reason = moment.getNotDisplayedReason()?.toString() ??
          moment.getSkippedReason()?.toString() ??
          moment.getDismissedReason()?.toString() ??
          'unknown_error';

      _credentialResponses.addError(reason);
      completer.complete(null);
    }
  }

  /// Calls `id.renderButton` on [parent] with the given [options].
  Future<void> renderButton(
    Object parent,
    GSIButtonConfiguration options,
  ) async {
    return id.renderButton(parent, convertButtonConfiguration(options));
  }

  /// Requests a server auth code per:
  /// https://developers.google.com/identity/oauth2/web/guides/use-code-model#initialize_a_code_client
  Future<String?> requestServerAuthCode() async {
    // TODO(dit): Enable granular authorization, https://github.com/flutter/flutter/issues/139406
    assert(_codeClient != null,
        'CodeClient not initialized correctly. Ensure the `scopes` list passed to `init()` or `initWithParams()` is not empty!');
    if (_codeClient == null) {
      return null;
    }
    _codeClient!.requestCode();
    final CodeResponse response = await _codeResponses.stream.first;
    return response.code;
  }

  // TODO(dit): Clean this up. https://github.com/flutter/flutter/issues/137727
  //
  /// Starts an oauth2 "implicit" flow to authorize requests.
  ///
  /// The new GIS SDK does not return user authentication from this flow, so:
  ///   * If [_lastCredentialResponse] is **not** null (the user has successfully
  ///     `signInSilently`), we return that after this method completes.
  ///   * If [_lastCredentialResponse] is null, we add [people.scopes] to the
  ///     [_initialScopes], so we can retrieve User Profile information back
  ///     from the People API (without idToken). See [people.requestUserData].
  @Deprecated(
      'Use `renderButton` instead. See: https://pub.dev/packages/google_sign_in_web#migrating-to-v011-and-v012-google-identity-services')
  Future<GoogleSignInUserData?> signIn() async {
    // Warn users that this method will be removed.
    web.console.warn(
        'The google_sign_in plugin `signIn` method is deprecated on the web, and will be removed in Q2 2024. Please use `renderButton` instead. See: '
                'https://pub.dev/packages/google_sign_in_web#migrating-to-v011-and-v012-google-identity-services'
            .toJS);
    // If we already know the user, use their `email` as a `hint`, so they don't
    // have to pick their user again in the Authorization popup.
    final GoogleSignInUserData? knownUser =
        utils.gisResponsesToUserData(_lastCredentialResponse);
    // This toggles a popup, so `signIn` *must* be called with
    // user activation.
    _tokenClient.requestAccessToken(OverridableTokenClientConfig(
      prompt: knownUser == null ? 'select_account' : '',
      login_hint: knownUser?.email,
      scope: <String>[
        ..._initialScopes,
        // If the user hasn't gone through the auth process,
        // the plugin will attempt to `requestUserData` after,
        // so we need extra scopes to retrieve that info.
        if (_lastCredentialResponse == null) ...people.scopes,
      ],
    ));

    await _tokenResponses.stream.first;

    return _computeUserDataForLastToken();
  }

  // This function returns the currently signed-in [GoogleSignInUserData].
  //
  // It'll do a request to the People API (if needed).
  //
  // TODO(dit): Clean this up. https://github.com/flutter/flutter/issues/137727
  Future<GoogleSignInUserData?> _computeUserDataForLastToken() async {
    // If the user hasn't authenticated, request their basic profile info
    // from the People API.
    //
    // This synthetic response will *not* contain an `idToken` field.
    if (_lastCredentialResponse == null && _requestedUserData == null) {
      assert(_lastTokenResponse != null);
      _requestedUserData = await people.requestUserData(_lastTokenResponse!);
    }
    // Complete user data either with the _lastCredentialResponse seen,
    // or the synthetic _requestedUserData from above.
    return utils.gisResponsesToUserData(_lastCredentialResponse) ??
        _requestedUserData;
  }

  /// Returns a [GoogleSignInTokenData] from the latest seen responses.
  GoogleSignInTokenData getTokens() {
    return utils.gisResponsesToTokenData(
      _lastCredentialResponse,
      _lastTokenResponse,
      _lastCodeResponse,
    );
  }

  /// Revokes the current authentication.
  Future<void> signOut() async {
    await clearAuthCache();
    id.disableAutoSelect();
  }

  /// Revokes the current authorization and authentication.
  Future<void> disconnect() async {
    if (_lastTokenResponse != null) {
      oauth2.revoke(_lastTokenResponse!.access_token!);
    }
    await signOut();
  }

  /// Returns true if the client has recognized this user before, and the last-seen
  /// credential is not expired.
  Future<bool> isSignedIn() async {
    bool isSignedIn = false;
    if (_lastCredentialResponse != null) {
      final DateTime? expiration = utils
          .getCredentialResponseExpirationTimestamp(_lastCredentialResponse);
      // All Google ID Tokens provide an "exp" date. If the method above cannot
      // extract `expiration`, it's because `_lastCredentialResponse`'s contents
      // are unexpected (or wrong) in any way.
      //
      // Users are considered to be signedIn when the last CredentialResponse
      // exists and has an expiration date in the future.
      //
      // Users are not signed in in any other case.
      //
      // See: https://developers.google.com/identity/openid-connect/openid-connect#an-id-tokens-payload
      isSignedIn = expiration?.isAfter(DateTime.now()) ?? false;
    }

    return isSignedIn || _requestedUserData != null;
  }

  /// Clears all the cached results from authentication and authorization.
  Future<void> clearAuthCache() async {
    _lastCredentialResponse = null;
    _lastTokenResponse = null;
    _requestedUserData = null;
    _lastCodeResponse = null;
  }

  /// Requests the list of [scopes] passed in to the client.
  ///
  /// Keeps the previously granted scopes.
  Future<bool> requestScopes(List<String> scopes) async {
    // If we already know the user, use their `email` as a `hint`, so they don't
    // have to pick their user again in the Authorization popup.
    final GoogleSignInUserData? knownUser =
        utils.gisResponsesToUserData(_lastCredentialResponse);

    _tokenClient.requestAccessToken(OverridableTokenClientConfig(
      prompt: knownUser == null ? 'select_account' : '',
      login_hint: knownUser?.email,
      scope: scopes,
      include_granted_scopes: true,
    ));

    await _tokenResponses.stream.first;

    return oauth2.hasGrantedAllScopes(_lastTokenResponse!, scopes);
  }

  /// Checks if the passed-in `accessToken` can access all `scopes`.
  ///
  /// This validates that the `accessToken` is the same as the last seen
  /// token response, that the token is not expired, then uses that response to
  /// check if permissions are still granted.
  Future<bool> canAccessScopes(List<String> scopes, String? accessToken) async {
    if (accessToken != null && _lastTokenResponse != null) {
      if (accessToken == _lastTokenResponse!.access_token) {
        final bool isTokenValid =
            _lastTokenResponseExpiration?.isAfter(DateTime.now()) ?? false;
        return isTokenValid &&
            oauth2.hasGrantedAllScopes(_lastTokenResponse!, scopes);
      }
    }
    return false;
  }

  final bool _loggingEnabled;

  // The scopes initially requested by the developer.
  //
  // We store this because we might need to add more at `signIn`. If the user
  // doesn't `silentSignIn`, we expand this list to consult the People API to
  // return some basic Authentication information.
  final List<String> _initialScopes;

  // The Google Identity Services client for oauth requests.
  late TokenClient _tokenClient;
  // CodeClient will not be created if `initialScopes` is empty.
  CodeClient? _codeClient;

  // Streams of credential and token responses.
  late StreamController<CredentialResponse> _credentialResponses;
  late StreamController<TokenResponse> _tokenResponses;
  late StreamController<CodeResponse> _codeResponses;

  // The last-seen credential and token responses
  CredentialResponse? _lastCredentialResponse;
  TokenResponse? _lastTokenResponse;
  // Expiration timestamp for the lastTokenResponse, which only has an `expires_in` field.
  DateTime? _lastTokenResponseExpiration;
  CodeResponse? _lastCodeResponse;

  /// The StreamController onto which the GIS Client propagates user authentication events.
  ///
  /// This is provided by the implementation of the plugin.
  final StreamController<GoogleSignInUserData?> _userDataEventsController;

  // If the user *authenticates* (signs in) through oauth2, the SDK doesn't return
  // identity information anymore, so we synthesize it by calling the PeopleAPI
  // (if needed)
  //
  // (This is a synthetic _lastCredentialResponse)
  //
  // TODO(dit): Clean this up. https://github.com/flutter/flutter/issues/137727
  GoogleSignInUserData? _requestedUserData;
}
