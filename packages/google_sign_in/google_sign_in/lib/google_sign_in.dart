// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

import 'src/event_types.dart';
import 'src/identity_types.dart';
import 'src/token_types.dart';

export 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart'
    show GoogleSignInException, GoogleSignInExceptionCode;
export 'src/event_types.dart';
export 'src/identity_types.dart';
export 'src/token_types.dart';
export 'widgets.dart';

/// Represents a signed-in Google account, providing account information as well
/// as utilities for obtaining authentication and authorization tokens.
///
/// Although the API of the plugin is structured to allow for the possibility
/// of multiple signed in users, the underlying Google Sign In SDKs on each
/// platform do not all currently support multiple users in practice. For best
/// cross-platform results, clients should not call [authenticate] to obtain a
/// new [GoogleSignInAccount] instance until after a call to [signOut].
@immutable
class GoogleSignInAccount implements GoogleIdentity {
  GoogleSignInAccount._(
    GoogleSignInUserData userData,
    AuthenticationTokenData tokenData,
  ) : displayName = userData.displayName,
      email = userData.email,
      id = userData.id,
      photoUrl = userData.photoUrl,
      _authenticationTokens = tokenData;

  @override
  final String? displayName;

  @override
  final String email;

  @override
  final String id;

  @override
  final String? photoUrl;

  final AuthenticationTokenData _authenticationTokens;

  /// Returns authentication tokens for this account.
  ///
  /// This returns the authentication information that was returned at the time
  /// of the initial authentication.
  ///
  /// Clients are strongly encouraged to use this information immediately after
  /// authentication, as tokens are subject to expiration, and obtaining new
  /// tokens requires re-authenticating.
  GoogleSignInAuthentication get authentication {
    return GoogleSignInAuthentication(idToken: _authenticationTokens.idToken);
  }

  /// Returns a client that can be used to request authorization tokens for
  /// this user.
  GoogleSignInAuthorizationClient get authorizationClient {
    return GoogleSignInAuthorizationClient._(this);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! GoogleSignInAccount) {
      return false;
    }
    final GoogleSignInAccount otherAccount = other;
    return displayName == otherAccount.displayName &&
        email == otherAccount.email &&
        id == otherAccount.id &&
        photoUrl == otherAccount.photoUrl &&
        _authenticationTokens.idToken ==
            otherAccount._authenticationTokens.idToken;
  }

  @override
  int get hashCode => Object.hash(
    displayName,
    email,
    id,
    photoUrl,
    _authenticationTokens.idToken,
  );

  @override
  String toString() {
    final Map<String, dynamic> data = <String, dynamic>{
      'displayName': displayName,
      'email': email,
      'id': id,
      'photoUrl': photoUrl,
    };
    return 'GoogleSignInAccount:$data';
  }
}

/// A utility for requesting authorization tokens.
///
/// If the instance was obtained from a [GoogleSignInAccount], any requests
/// issued by this client will be for tokens for that account.
///
/// If the instance was obtained directly from [GoogleSignIn], the request will
/// not be limited to a specific user, and the behavior will depend on the
/// platform and the current application state. Examples include:
/// - If there is an active authentication session in the application already,
///   the authorization tokens may be associated for that user.
/// - If no user has been authenticated, this may trigger a combined
///   authentication+authorization flow. In that case, whether
///   [GoogleSignIn]'s authenticationEvents stream will be informed of the
///   authentication depends on the platform implementation. You should not
///   assume the user information or authenication tokens will be available in
///   this case.
class GoogleSignInAuthorizationClient {
  GoogleSignInAuthorizationClient._(GoogleIdentity? user)
    : _userId = user?.id,
      _userEmail = user?.email;

  final String? _userId;
  final String? _userEmail;

  /// Requests client authorization tokens if they can be returned without user
  /// interaction.
  ///
  /// If authorization would require user interaction, this returns null, in
  /// which case [authorizeScopes] should be used instead.
  ///
  /// In rare cases, this can return tokens that are no longer valid. See
  /// [clearAuthorizationToken] for details.
  Future<GoogleSignInClientAuthorization?> authorizationForScopes(
    List<String> scopes,
  ) async {
    return _authorizeClient(scopes, promptIfUnauthorized: false);
  }

  /// Requests that the user authorize the given scopes, and either returns the
  /// resulting client authorization tokens, or throws an exception with failure
  /// details.
  ///
  /// This should only be called from a context where user interaction is
  /// allowed (for example, while the app is foregrounded on mobile), and if
  /// [GoogleSignIn.authorizationRequiresUserInteraction] returns true this
  /// should only be called from an user interaction handler.
  ///
  /// In rare cases, this can return tokens that are no longer valid. See
  /// [clearAuthorizationToken] for details.
  Future<GoogleSignInClientAuthorization> authorizeScopes(
    List<String> scopes,
  ) async {
    final GoogleSignInClientAuthorization? authz = await _authorizeClient(
      scopes,
      promptIfUnauthorized: true,
    );
    // The platform interface documents that null should only be returned for
    // cases where prompting isn't requested, so if this happens it's a bug
    // in the platform implementation.
    if (authz == null) {
      throw const GoogleSignInException(
        code: GoogleSignInExceptionCode.unknownError,
        description: 'Platform returned null unexpectedly.',
      );
    }
    return authz;
  }

  /// Convenience method returning a `<String, String>` map of HTML
  /// authorization headers, containing the access token for the given scopes.
  ///
  /// Returns null if the given scopes are not authorized, or there is no
  /// unexpired authorization token available, and [promptIfNecessary] is false.
  ///
  /// In rare cases, this can return tokens that are no longer valid. See
  /// [clearAuthorizationToken] for details.
  ///
  /// See also https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Authorization.
  Future<Map<String, String>?> authorizationHeaders(
    List<String> scopes, {
    bool promptIfNecessary = false,
  }) async {
    final GoogleSignInClientAuthorization? authz =
        await authorizationForScopes(scopes) ??
        (promptIfNecessary ? await authorizeScopes(scopes) : null);
    if (authz == null) {
      return null;
    }
    return <String, String>{
      'Authorization': 'Bearer ${authz.accessToken}',
      'X-Goog-AuthUser': '0',
    };
  }

  /// Requests that the user authorize the given scopes for server use.
  ///
  /// In addition to throwing an exception for authorization failures, this can
  /// return null if the server authorization tokens are not available. For
  /// intance, some platforms only provide a valid server auth token on initial
  /// login. Clients requiring a server auth token should not rely on being able
  /// to re-request server auth tokens at arbitrary times, and should instead
  /// store the token when it is first available, and manage refreshes on
  /// the server side using that token.
  ///
  /// This should only be called from a context where user interaction is
  /// allowed (for example, while the app is foregrounded on mobile), and if
  /// [GoogleSignIn.authorizationRequiresUserInteraction] returns true this
  /// should only be called from an user interaction handler.
  ///
  /// In rare cases, this can return tokens that are no longer valid. See
  /// [clearAuthorizationToken] for details.
  Future<GoogleSignInServerAuthorization?> authorizeServer(
    List<String> scopes,
  ) async {
    final ServerAuthorizationTokenData? tokens = await GoogleSignInPlatform
        .instance
        .serverAuthorizationTokensForScopes(
          ServerAuthorizationTokensForScopesParameters(
            request: AuthorizationRequestDetails(
              scopes: scopes,
              userId: _userId,
              email: _userEmail,
              promptIfUnauthorized: true,
            ),
          ),
        );
    return tokens == null
        ? null
        : GoogleSignInServerAuthorization(
          serverAuthCode: tokens.serverAuthCode,
        );
  }

  /// Removes the given [accessToken] from any local authorization caches.
  ///
  /// This should be called if using an access token results in an invalid token
  /// response from the target API, followed by re-requsting authorization.
  ///
  /// A token can be invalidated by, for example, a user removing an
  /// application's authorization from outside of the application:
  /// https://support.google.com/accounts/answer/13533235.
  Future<void> clearAuthorizationToken({required String accessToken}) {
    return GoogleSignInPlatform.instance.clearAuthorizationToken(
      ClearAuthorizationTokenParams(accessToken: accessToken),
    );
  }

  Future<GoogleSignInClientAuthorization?> _authorizeClient(
    List<String> scopes, {
    required bool promptIfUnauthorized,
  }) async {
    final ClientAuthorizationTokenData? tokens = await GoogleSignInPlatform
        .instance
        .clientAuthorizationTokensForScopes(
          ClientAuthorizationTokensForScopesParameters(
            request: AuthorizationRequestDetails(
              scopes: scopes,
              userId: _userId,
              email: _userEmail,
              promptIfUnauthorized: promptIfUnauthorized,
            ),
          ),
        );
    return tokens == null
        ? null
        : GoogleSignInClientAuthorization(accessToken: tokens.accessToken);
  }
}

/// GoogleSignIn allows you to authenticate Google users.
class GoogleSignIn {
  GoogleSignIn._();

  /// Returns the single [GoogleSignIn] instance.
  ///
  /// [initialize] must be called on this instance exactly once, and its future
  /// allowed to complete, before any other methods on the object are called.
  static final GoogleSignIn instance = GoogleSignIn._();

  /// Initializes the sign in manager with the given configuration.
  ///
  /// Clients must call this method exactly once, and wait for its future to
  /// complete, before calling any other methods on this object. Calling other
  /// methods without waiting for this method to return, or calling this method
  /// more than once, will result in undefined behavior.
  ///
  /// [clientId] is the identifier for your client application, as provided by
  /// the Google Sign In server configuration, if any. This does not need to be
  /// provided on platforms that do not require a client identifier, or if it is
  /// provided via application-level configuration files. See the README for
  /// details. If provided, it will take precedence over any value in a
  /// configuration file.
  ///
  /// [serverClientId] is the identifier for your application's server-side
  /// component, as provided by the Google Sign In server configuration, if any.
  /// Depending on the platform, this value may be unused, optional, or
  /// required. See the README for details. If provided, it will take precedence
  /// over any value in a configuration file.
  ///
  /// If provided, [nonce] will be passed as part of any authentication
  /// requests, to allow additional validation of the resulting ID token.
  ///
  /// If provided, [hostedDomain] restricts account selection to accounts in
  /// that domain.
  Future<void> initialize({
    String? clientId,
    String? serverClientId,
    String? nonce,
    String? hostedDomain,
  }) async {
    await GoogleSignInPlatform.instance.init(
      InitParameters(
        clientId: clientId,
        serverClientId: serverClientId,
        nonce: nonce,
        hostedDomain: hostedDomain,
      ),
    );

    final Stream<AuthenticationEvent>? platformAuthEvents =
        GoogleSignInPlatform.instance.authenticationEvents;
    if (platformAuthEvents == null) {
      _createAuthenticationStreamEvents = true;
    } else {
      unawaited(platformAuthEvents.forEach(_translateAuthenticationEvent));
    }
  }

  /// Converts [event] into a corresponding event using the app-facing package
  /// types.
  ///
  /// The platform interface types are intentionally not exposed to clients to
  /// avoid platform interface package changes immediately transferring to the
  /// public API without being able to control how they are exposed.
  ///
  /// This uses a convert-and-add approach rather than `map` so that new types
  /// that don't have handlers yet can be dropped rather than causing errors.
  void _translateAuthenticationEvent(AuthenticationEvent event) {
    switch (event) {
      case AuthenticationEventSignIn():
        _authenticationStreamController.add(
          GoogleSignInAuthenticationEventSignIn(
            user: GoogleSignInAccount._(event.user, event.authenticationTokens),
          ),
        );
      case AuthenticationEventSignOut():
        _authenticationStreamController.add(
          GoogleSignInAuthenticationEventSignOut(),
        );
      case AuthenticationEventException():
        _authenticationStreamController.addError(event.exception);
    }
  }

  /// Subscribe to this stream to be notified when sign in (authentication) and
  /// sign out events happen.
  Stream<GoogleSignInAuthenticationEvent> get authenticationEvents {
    return _authenticationStreamController.stream;
  }

  final StreamController<GoogleSignInAuthenticationEvent>
  _authenticationStreamController =
      StreamController<GoogleSignInAuthenticationEvent>.broadcast();

  // Whether this package is responsible for creating stream events from
  // authentication calls. This is true iff the platform instance returns null
  // for authenticationEvents.
  bool _createAuthenticationStreamEvents = false;

  /// Attempts to sign in a previously authenticated user with minimal
  /// interaction.
  ///
  /// The amount of allowable UI is up to the platform to determine, but it
  /// should be minimal. Possible examples include FedCM on the web, and One Tap
  /// on Android. Platforms may even show no UI, and only sign in if a previous
  /// sign-in is being restored. This method is intended to be called as soon
  /// as the application needs to know if the user is signed in, often at
  /// initial launch.
  ///
  /// Use [authenticate] instead to trigger a full interactive sign in process.
  ///
  /// There are two possible return modes:
  /// - If a Future is returned, applications could reasonably `await` that
  ///   future before deciding whether to display UI in a signed in or signed
  ///   out mode. For example, a platform where this method only restores
  ///   existing sign-ins would return a future, as either way it will resolve
  ///   quickly.
  /// - If null is returned, applications must rely on [authenticationEvents] to
  ///   know when a sign-in occurs, and cannot rely on receiving a notification
  ///   that this call has *not* resulted in a sign-in in any reasonable amount
  ///   of time. In this mode, applications should assume a signed out mode
  ///   until/unless a sign-in event arrives on the stream. FedCM on the web
  ///   would be an example of this mode.
  ///
  /// If a Future is returned, it resolves to an instance of
  /// [GoogleSignInAccount] for a successful sign in or null if the attempt
  /// implicitly did not result in any authentication. A [GoogleSignInException]
  /// will be thrown if there was a failure (such as a client configuration
  /// error). By default, this will not throw any of the following:
  /// - [GoogleSignInExceptionCode.canceled]
  /// - [GoogleSignInExceptionCode.interrupted]
  /// - [GoogleSignInExceptionCode.uiUnavailable]
  /// and will instead return null in those cases. To receive exceptions
  /// for those cases instead, set [reportAllExceptions] to true.
  Future<GoogleSignInAccount?>? attemptLightweightAuthentication({
    bool reportAllExceptions = false,
  }) {
    try {
      final Future<AuthenticationResults?>? future = GoogleSignInPlatform
          .instance
          .attemptLightweightAuthentication(
            const AttemptLightweightAuthenticationParameters(),
          );
      if (future == null) {
        return null;
      }
      return _resolveLightweightAuthenticationAttempt(
        future,
        reportAllExceptions: reportAllExceptions,
      );
    } catch (e, stack) {
      if (e is GoogleSignInException) {
        if (_createAuthenticationStreamEvents) {
          _authenticationStreamController.addError(e, stack);
        }

        // For exceptions that should not be reported out, just return null.
        if (!_shouldRethrowLightweightAuthenticationException(
          e,
          reportAllExceptions: reportAllExceptions,
        )) {
          return Future<GoogleSignInAccount?>.value();
        }
      }
      return Future<GoogleSignInAccount?>.error(e, stack);
    }
  }

  /// Resolves a future from the platform implementation's
  /// attemptLightweightAuthentication.
  ///
  /// This is a separate method from [attemptLightweightAuthentication] to allow
  /// using async/await, since [attemptLightweightAuthentication] can't use
  /// async without losing the ability to return a null future.
  Future<GoogleSignInAccount?> _resolveLightweightAuthenticationAttempt(
    Future<AuthenticationResults?> future, {
    required bool reportAllExceptions,
  }) async {
    try {
      final AuthenticationResults? result = await future;
      if (result == null) {
        return null;
      }

      final GoogleSignInAccount account = GoogleSignInAccount._(
        result.user,
        result.authenticationTokens,
      );
      if (_createAuthenticationStreamEvents) {
        _authenticationStreamController.add(
          GoogleSignInAuthenticationEventSignIn(user: account),
        );
      }
      return account;
    } on GoogleSignInException catch (e, stack) {
      if (_createAuthenticationStreamEvents) {
        _authenticationStreamController.addError(e, stack);
      }

      if (_shouldRethrowLightweightAuthenticationException(
        e,
        reportAllExceptions: reportAllExceptions,
      )) {
        rethrow;
      }
      return null;
    }
  }

  bool _shouldRethrowLightweightAuthenticationException(
    GoogleSignInException e, {
    required bool reportAllExceptions,
  }) {
    if (reportAllExceptions) {
      return true;
    }
    switch (e.code) {
      case GoogleSignInExceptionCode.canceled:
      case GoogleSignInExceptionCode.interrupted:
      case GoogleSignInExceptionCode.uiUnavailable:
        return false;
      // Only specific types are ignored, everything else should rethrow.
      // ignore: no_default_cases
      default:
        return true;
    }
  }

  /// Whether or not the current platform supports the [authenticate] method.
  ///
  /// If this returns false, [authenticate] will throw an [UnsupportedError] if
  /// called. See the platform-specific documentation for the package to
  /// determine how authentication is handled. For instance, the platform may
  /// provide platform-controlled sign-in UI elements that must be used instead
  /// of application-specific UI.
  bool supportsAuthenticate() =>
      GoogleSignInPlatform.instance.supportsAuthenticate();

  /// Whether or not authorization calls that could show UI must be called from
  /// a user interaction, such as a button press, on the current platform.
  ///
  /// For instance, this would return true on web if the sign in SDK uses popups
  /// in its flow, since browsers may block popups that are not triggered
  /// within the context of a user interaction.
  bool authorizationRequiresUserInteraction() =>
      GoogleSignInPlatform.instance.authorizationRequiresUserInteraction();

  /// Starts an interactive sign-in process.
  ///
  /// Returns a [GoogleSignInAccount] with valid authentication tokens for a
  /// successful sign in, or throws a [GoogleSignInException] for any other
  /// outcome, with details in the exception.
  ///
  /// If you will immediately be requesting authorization tokens, you can pass
  /// [scopeHint] to indicate a preference for a combined
  /// authentication+authorization flow on platforms that support it. Best
  /// practice for Google Sign In flows is to separate authentication and
  /// authorization, so not all platforms support a combined flow, and those
  /// that do not will ignore [scopeHint]. You should always assume that
  /// [GoogleSignInAuthorizationClient.authorizationForScopes] could return null
  /// even if you pass a [scopeHint] here.
  Future<GoogleSignInAccount> authenticate({
    List<String> scopeHint = const <String>[],
  }) async {
    try {
      final AuthenticationResults result = await GoogleSignInPlatform.instance
          .authenticate(AuthenticateParameters(scopeHint: scopeHint));
      final GoogleSignInAccount account = GoogleSignInAccount._(
        result.user,
        result.authenticationTokens,
      );
      if (_createAuthenticationStreamEvents) {
        _authenticationStreamController.add(
          GoogleSignInAuthenticationEventSignIn(user: account),
        );
      }
      return account;
    } on GoogleSignInException catch (e, stack) {
      if (_createAuthenticationStreamEvents) {
        _authenticationStreamController.addError(e, stack);
      }
      rethrow;
    }
  }

  /// Returns a client that can be used to request authorization tokens for
  /// some user.
  ///
  /// In most cases, authorization tokens should be obtained via
  /// [GoogleSignInAccount.authorizationClient] rather than this method, as this
  /// will provied only authorization tokens, without any corresponding user
  /// information or authentication tokens.
  ///
  /// See [GoogleSignInAuthorizationClient] for details.
  GoogleSignInAuthorizationClient get authorizationClient {
    return GoogleSignInAuthorizationClient._(null);
  }

  /// Signs out any currently signed in user(s).
  Future<void> signOut() {
    if (_createAuthenticationStreamEvents) {
      _authenticationStreamController.add(
        GoogleSignInAuthenticationEventSignOut(),
      );
    }
    return GoogleSignInPlatform.instance.signOut(const SignOutParams());
  }

  /// Disconnects any currently authorized users from the app, revoking previous
  /// authorization.
  Future<void> disconnect() async {
    // Disconnecting also signs out, so synthesize a sign-out if necessary.
    if (_createAuthenticationStreamEvents) {
      _authenticationStreamController.add(
        GoogleSignInAuthenticationEventSignOut(),
      );
    }
    // TODO(stuartmorgan): Consider making a per-user disconnect option once
    //  the Android implementation is available so that we can see how it is
    //  structured. In practice, currently the plugin only fully supports a
    //  single user at a time, so the distinction is mostly theoretical for now.
    await GoogleSignInPlatform.instance.disconnect(const DisconnectParams());
  }
}
