// Copyright 2013 The Flutter Authors
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
import 'utils.dart' as utils;

/// A client to hide (most) of the interaction with the GIS SDK from the plugin.
///
/// (Overridable for testing)
class GisSdkClient {
  /// Create a GisSdkClient object.
  GisSdkClient({
    required String clientId,
    required StreamController<AuthenticationEvent?> authenticationController,
    bool loggingEnabled = false,
    String? nonce,
    String? hostedDomain,
  }) : _clientId = clientId,
       _hostedDomain = hostedDomain,
       _loggingEnabled = loggingEnabled,
       _authenticationController = authenticationController {
    if (_loggingEnabled) {
      id.setLogLevel('debug');
    }
    _configureAuthenticationStream();

    // Initialize the authentication SDK client. Authorization clients will be
    // created as one-offs as needed.
    _initializeIdClient(
      clientId,
      onResponse: _onCredentialResponse,
      nonce: nonce,
      hostedDomain: hostedDomain,
      useFedCM: true,
    );
  }

  void _logIfEnabled(String message, [List<Object?>? more]) {
    if (_loggingEnabled) {
      final String log = <Object?>[
        '[google_sign_in_web]',
        message,
        ...?more,
      ].join(' ');
      web.console.info(log.toJS);
    }
  }

  // Configure the credential (authentication) response stream.
  void _configureAuthenticationStream() {
    _credentialResponses = StreamController<CredentialResponse>.broadcast();

    // In the future, the userDataEvents could propagate null userDataEvents too.
    _credentialResponses.stream
        .map(utils.gisResponsesToAuthenticationEvent)
        .handleError(_convertCredentialResponsesStreamErrors)
        .forEach(_authenticationController.add);
  }

  // This function handles the errors that on the _credentialResponses Stream.
  //
  // (This has been separated to a function so the _configureStreams formatting
  // looks a little bit better)
  void _convertCredentialResponsesStreamErrors(Object error) {
    _logIfEnabled('Error on CredentialResponse:', <Object>[error.toString()]);
    if (error is GoogleSignInException) {
      _authenticationController.add(AuthenticationEventException(error));
    } else {
      _authenticationController.add(
        AuthenticationEventException(
          GoogleSignInException(
            code: GoogleSignInExceptionCode.unknownError,
            description: error.toString(),
          ),
        ),
      );
    }
  }

  // Initializes the `id` SDK for the silent-sign in (authentication) client.
  void _initializeIdClient(
    String clientId, {
    required CallbackFn onResponse,
    String? nonce,
    String? hostedDomain,
    bool? useFedCM,
  }) {
    // Initialize `id` for the silent-sign in code.
    final idConfig = IdConfiguration(
      client_id: clientId,
      callback: onResponse,
      cancel_on_tap_outside: false,
      auto_select: true, // Attempt to sign-in silently.
      nonce: nonce,
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
    final String? error = response.error;
    if (error != null) {
      _credentialResponses.addError(error);
    } else {
      _credentialResponses.add(response);
    }
  }

  // Creates a `oauth2.TokenClient` used for authorization (scope) requests.
  TokenClient _initializeTokenClient(
    String clientId, {
    required List<String> scopes,
    String? userHint,
    String? hostedDomain,
    required TokenClientCallbackFn onResponse,
    required ErrorCallbackFn onError,
  }) {
    // Create a Token Client for authorization calls.
    final tokenConfig = TokenClientConfig(
      prompt: userHint == null ? '' : 'select_account',
      client_id: clientId,
      login_hint: userHint,
      hd: hostedDomain,
      callback: onResponse,
      error_callback: onError,
      scope: scopes,
    );
    return oauth2.initTokenClient(tokenConfig);
  }

  // Creates a `oauth2.CodeClient` used for authorization (scope) requests.
  CodeClient _initializeCodeClient({
    String? userHint,
    required List<String> scopes,
    required CodeClientCallbackFn onResponse,
    required ErrorCallbackFn onError,
  }) {
    // Create a Token Client for authorization calls.
    final codeConfig = CodeClientConfig(
      client_id: _clientId,
      login_hint: userHint,
      hd: _hostedDomain,
      callback: onResponse,
      error_callback: onError,
      scope: scopes,
      select_account: userHint == null,
      include_granted_scopes: true,
      ux_mode: UxMode.popup,
    );
    return oauth2.initCodeClient(codeConfig);
  }

  /// Attempts to sign-in the user using the OneTap UX flow.
  void requestOneTap() {
    // Ask the SDK to render the OneClick sign-in.
    //
    // And also handle its "moments".
    id.prompt(_onPromptMoment);
  }

  // Handles "prompt moments" of the OneClick card UI.
  //
  // See: https://developers.google.com/identity/gsi/web/guides/receive-notifications-prompt-ui-status
  Future<void> _onPromptMoment(PromptMomentNotification moment) async {
    if (moment.isDismissedMoment()) {
      final MomentDismissedReason? reason = moment.getDismissedReason();
      switch (reason) {
        case MomentDismissedReason.credential_returned:
          // Nothing to do here, as the success handler will run.
          break;
        case MomentDismissedReason.cancel_called:
          _credentialResponses.addError(
            const GoogleSignInException(
              code: GoogleSignInExceptionCode.canceled,
            ),
          );
        case MomentDismissedReason.flow_restarted:
          // Ignore, as this is not a final state.
          break;
        case MomentDismissedReason.unknown_reason:
        case null:
          _credentialResponses.addError(
            GoogleSignInException(
              code: GoogleSignInExceptionCode.unknownError,
              description: 'dismissed: $reason',
            ),
          );
      }
      return;
    }

    if (moment.isSkippedMoment()) {
      // getSkippedReason is not used in the exception details here, per
      // https://developers.google.com/identity/gsi/web/guides/fedcm-migration
      _credentialResponses.addError(
        const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
      );
    }

    // isNotDisplayed is intentionally ignored, per
    // https://developers.google.com/identity/gsi/web/guides/fedcm-migration
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
  Future<String?> requestServerAuthCode(
    AuthorizationRequestDetails request,
  ) async {
    final completer = Completer<(String? code, Exception? e)>();
    final CodeClient codeClient = _initializeCodeClient(
      userHint: request.userId,
      onResponse: (CodeResponse response) {
        final String? error = response.error;
        if (error == null) {
          completer.complete((response.code, null));
        } else {
          completer.complete((
            null,
            GoogleSignInException(
              code: GoogleSignInExceptionCode.unknownError,
              description: response.error_description,
              details: 'code: $error',
            ),
          ));
        }
      },
      onError: (GoogleIdentityServicesError? error) {
        completer.complete((null, _exceptionForGisError(error)));
      },
      scopes: request.scopes,
    );

    codeClient.requestCode();
    final (String? code, Exception? e) = await completer.future;
    if (e != null) {
      throw e;
    }
    return code;
  }

  /// Revokes the current authentication.
  Future<void> signOut() async {
    _lastClientAuthorizationByUser.clear();
    id.disableAutoSelect();
    _authenticationController.add(AuthenticationEventSignOut());
  }

  /// Revokes all cached authorization tokens.
  Future<void> disconnect() async {
    _lastClientAuthorizationByUser.values
        .map(((TokenResponse?, DateTime?) auth) => auth.$1?.access_token)
        .nonNulls
        .forEach(oauth2.revoke);
    _lastClientAuthorizationByUser.clear();
    await signOut();
  }

  /// Clears the authorization cache for the given [token].
  void clearAuthorizationToken(String token) {
    _lastClientAuthorizationByUser.removeWhere(
      (String? key, (TokenResponse tokenResponse, DateTime expiration) value) =>
          value.$1.access_token == token,
    );
  }

  /// Requests the given list of [scopes], and returns the resulting
  /// authorization token if successful.
  ///
  /// Keeps the previously granted scopes.
  Future<String?> requestScopes(
    List<String> scopes, {
    required bool promptIfUnauthorized,
    String? userHint,
  }) async {
    // If there's a usable cached token, return that.
    final (TokenResponse? cachedResponse, DateTime? cacheExpiration) =
        _lastClientAuthorizationByUser[userHint] ?? (null, null);
    if (cachedResponse != null) {
      final bool isTokenValid =
          cacheExpiration?.isAfter(DateTime.now()) ?? false;
      if (isTokenValid && oauth2.hasGrantedAllScopes(cachedResponse, scopes)) {
        return cachedResponse.access_token;
      }
    }

    if (!promptIfUnauthorized) {
      return null;
    }

    final completer = Completer<(String? token, Exception? e)>();
    final TokenClient tokenClient = _initializeTokenClient(
      _clientId,
      scopes: scopes,
      userHint: userHint,
      hostedDomain: _hostedDomain,
      onResponse: (TokenResponse response) {
        final String? error = response.error;
        if (error == null) {
          final String? token = response.access_token;
          if (token == null) {
            _lastClientAuthorizationByUser.remove(userHint);
          } else {
            final DateTime expiration = DateTime.now().add(
              Duration(seconds: response.expires_in!),
            );
            _lastClientAuthorizationByUser[userHint] = (response, expiration);
          }
          completer.complete((response.access_token, null));
        } else {
          _lastClientAuthorizationByUser.remove(userHint);
          completer.complete((
            null,
            GoogleSignInException(
              code: GoogleSignInExceptionCode.unknownError,
              description: response.error_description,
              details: 'code: $error',
            ),
          ));
        }
      },
      onError: (GoogleIdentityServicesError? error) {
        _lastClientAuthorizationByUser.remove(userHint);
        completer.complete((null, _exceptionForGisError(error)));
      },
    );
    tokenClient.requestAccessToken();

    final (String? token, Exception? e) = await completer.future;
    if (e != null) {
      throw e;
    }
    return token;
  }

  GoogleSignInException _exceptionForGisError(
    GoogleIdentityServicesError? error,
  ) {
    final GoogleSignInExceptionCode code;
    switch (error?.type) {
      case GoogleIdentityServicesErrorType.missing_required_parameter:
        code = GoogleSignInExceptionCode.clientConfigurationError;
      case GoogleIdentityServicesErrorType.popup_closed:
        code = GoogleSignInExceptionCode.canceled;
      case GoogleIdentityServicesErrorType.popup_failed_to_open:
        code = GoogleSignInExceptionCode.uiUnavailable;
      case GoogleIdentityServicesErrorType.unknown:
      case null:
        code = GoogleSignInExceptionCode.unknownError;
    }
    return GoogleSignInException(
      code: code,
      description: error?.message ?? 'SDK returned no error details',
    );
  }

  final bool _loggingEnabled;

  // The identifier of this web client.
  final String _clientId;

  /// The domain to restrict logins to.
  final String? _hostedDomain;

  // Stream of credential responses from sign-in events.
  late StreamController<CredentialResponse> _credentialResponses;

  // The last client authorization token responses, keyed by the user ID the
  // authorization was requested for. A nil key stores the last authorization
  // request that was not associated with a known user (i.e., no user ID hint
  // was provided with the request).
  final Map<String?, (TokenResponse tokenResponse, DateTime expiration)>
  _lastClientAuthorizationByUser =
      <String?, (TokenResponse tokenResponse, DateTime expiration)>{};

  /// The StreamController onto which the GIS Client propagates user authentication events.
  ///
  /// This is provided by the implementation of the plugin.
  final StreamController<AuthenticationEvent?> _authenticationController;
}
