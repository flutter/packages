// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'src/types.dart';

export 'src/types.dart';

/// The interface that implementations of google_sign_in must implement.
///
/// Platform implementations that live in a separate package should extend this
/// class rather than implement it as `google_sign_in` does not consider newly
/// added methods to be breaking changes. Extending this class (using `extends`)
/// ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by
/// newly added [GoogleSignInPlatform] methods.
abstract class GoogleSignInPlatform extends PlatformInterface {
  /// Constructs a GoogleSignInPlatform.
  GoogleSignInPlatform() : super(token: _token);

  static final Object _token = Object();

  /// The instance of [GoogleSignInPlatform] to use.
  ///
  /// Platform-implementations should override this with their own
  /// platform-specific class that extends [GoogleSignInPlatform] when they
  /// register themselves.
  ///
  /// Defaults to [MethodChannelGoogleSignIn].
  static GoogleSignInPlatform get instance => _instance;

  static GoogleSignInPlatform _instance = _PlaceholderImplementation();

  static set instance(GoogleSignInPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Initializes the plugin with specified [params]. You must call this method
  /// before calling other methods.
  ///
  /// See:
  ///
  /// * [InitParameters]
  Future<void> init(InitParameters params);

  /// Attempts to sign in without an explicit user intent.
  ///
  /// This is intended to support the use case where the user might be expected
  /// to be signed in, but hasn't explicitly requested sign in, such as when
  /// launching an application that is intended to be used while signed in.
  ///
  /// This may be silent, or may show minimal UI, depending on the platform and
  /// the context.
  Future<AuthenticationResults?>? attemptLightweightAuthentication(
    AttemptLightweightAuthenticationParameters params,
  );

  /// Returns true if the platform implementation supports the [authenticate]
  /// method.
  ///
  /// The default is true, but platforms that cannot support [authenticate] can
  /// override this to return false, throw [UnsupportedError] from
  /// [authenticate], and provide a different, platform-specific authentication
  /// flow.
  bool supportsAuthenticate();

  /// Signs in with explicit user intent.
  ///
  /// This is intended to support the use case where the user has expressed
  /// an explicit intent to sign in.
  Future<AuthenticationResults> authenticate(AuthenticateParameters params);

  /// Whether or not authorization calls that could show UI must be called from
  /// a user interaction, such as a button press, on the current platform.
  ///
  /// Platforms that can fail to show UI without an active user interaction,
  /// such as a web implementations that uses popups, should return false.
  bool authorizationRequiresUserInteraction();

  /// Returns the tokens used to authenticate other API calls from a client.
  ///
  /// This should only return null if prompting would be necessary but [params]
  /// do not allow it, otherwise any failure should return an error.
  Future<ClientAuthorizationTokenData?> clientAuthorizationTokensForScopes(
    ClientAuthorizationTokensForScopesParameters params,
  );

  /// Returns the tokens used to authenticate other API calls from a server.
  ///
  /// This should only return null if prompting would be necessary but [params]
  /// do not allow it, otherwise any failure should return an error.
  Future<ServerAuthorizationTokenData?> serverAuthorizationTokensForScopes(
    ServerAuthorizationTokensForScopesParameters params,
  );

  /// Clears any token cache for the given access token.
  Future<void> clearAuthorizationToken(ClearAuthorizationTokenParams params) {
    throw UnimplementedError(
      'clearAuthorizationToken() has not been implemented.',
    );
  }

  /// Signs out previously signed in accounts.
  Future<void> signOut(SignOutParams params);

  /// Revokes all of the scopes that all signed in users granted, and then signs
  /// them out.
  Future<void> disconnect(DisconnectParams params);

  /// Returns a stream of authentication events.
  ///
  /// If this is not overridden, the app-facing package will assume that the
  /// futures returned by [attemptLightweightAuthentication], [authenticate],
  /// and [signOut] are the only sources of authentication-related events.
  /// Implementations that have other sources should override this and provide
  /// a stream with all authentication and sign-out events.
  /// These will normally come from asynchronous flows, like the authenticate
  /// and signOut methods, as well as potentially from platform-specific methods
  /// (such as the Google Sign-In Button Widget from the Web implementation).
  ///
  /// Implementations should never intentionally call `addError` for this
  /// stream, and should instead use AuthenticationEventException. This is to
  /// ensure via the type system that implementations are always sending
  /// [GoogleSignInException] for know failure cases.
  Stream<AuthenticationEvent>? get authenticationEvents => null;
}

/// An implementation of GoogleSignInPlatform that throws unimplemented errors,
/// to use as a default instance if no platform implementation has been
/// registered.
class _PlaceholderImplementation extends GoogleSignInPlatform {
  @override
  Future<void> init(InitParameters params) {
    throw UnimplementedError();
  }

  @override
  Future<AuthenticationResults?> attemptLightweightAuthentication(
    AttemptLightweightAuthenticationParameters params,
  ) {
    throw UnimplementedError();
  }

  @override
  bool supportsAuthenticate() {
    throw UnimplementedError();
  }

  @override
  Future<AuthenticationResults> authenticate(AuthenticateParameters params) {
    throw UnimplementedError();
  }

  @override
  bool authorizationRequiresUserInteraction() {
    throw UnimplementedError();
  }

  @override
  Future<ClientAuthorizationTokenData?> clientAuthorizationTokensForScopes(
    ClientAuthorizationTokensForScopesParameters params,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<ServerAuthorizationTokenData?> serverAuthorizationTokensForScopes(
    ServerAuthorizationTokensForScopesParameters params,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> clearAuthorizationToken(ClearAuthorizationTokenParams params) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut(SignOutParams params) {
    throw UnimplementedError();
  }

  @override
  Future<void> disconnect(DisconnectParams params) {
    throw UnimplementedError();
  }
}
