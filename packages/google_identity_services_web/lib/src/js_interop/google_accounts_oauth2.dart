// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Authorization. API reference:
// https://developers.google.com/identity/oauth2/web/reference/js-reference

// ignore_for_file: non_constant_identifier_names
// * non_constant_identifier_names required to be able to use the same parameter
//   names as the underlying library.

@JS('google.accounts.oauth2')
library oauth2;

import 'package:js/js.dart';

import 'shared.dart';

// Code Client

/*
// Method: google.accounts.oauth2.initCodeClient
// https://developers.google.com/identity/oauth2/web/reference/js-reference#google.accounts.oauth2.initCodeClient
*/

/// The initCodeClient method initializes and returns a code client, with the
/// passed-in [config].
@JS()
external InitCodeClientFn get initCodeClient;

/// The type of the [initCodeClient] function.
typedef InitCodeClientFn = CodeClient Function(CodeClientConfig config);

/*
// Data type: CodeClientConfig
// https://developers.google.com/identity/oauth2/web/reference/js-reference#CodeClientConfig
*/

/// The configuration object for the [initCodeClient] method.
@JS()
@anonymous
@staticInterop
abstract class CodeClientConfig {
  /// Constructs a CodeClientConfig object in JavaScript.
  ///
  /// The [callback] property must be wrapped in [allowInterop] before it's
  /// passed to this constructor.
  external factory CodeClientConfig({
    required String client_id,
    required String scope,
    String? redirect_uri,
    bool? auto_select,
    CodeClientCallbackFn? callback,
    String? state,
    bool? enable_serial_consent,
    String? hint,
    String? hosted_domain,
    UxMode? ux_mode,
    bool? select_account,
  });
}

/*
// Data type: CodeClient
// https://developers.google.com/identity/oauth2/web/reference/js-reference#CodeClient
*/

/// A client that can start the OAuth 2.0 Code UX flow.
///
/// See: https://developers.google.com/identity/oauth2/web/guides/use-code-model
@JS()
@staticInterop
abstract class CodeClient {}

/// The methods available on the [CodeClient].
extension CodeClientExtension on CodeClient {
  /// Starts the OAuth 2.0 Code UX flow.
  external void requestCode();
}

/*
// Data type: CodeResponse
// https://developers.google.com/identity/oauth2/web/reference/js-reference#CodeResponse
*/

/// The object passed as the parameter of your [CodeClientCallbackFn].
@JS()
@staticInterop
abstract class CodeResponse {}

/// The fields that are contained in the code response object.
extension CodeResponseExtension on CodeResponse {
  /// The authorization code of a successful token response.
  external String get code;

  /// A space-delimited list of scopes that are approved by the user.
  external String get scope;

  /// The string value that your application uses to maintain state between your
  /// authorization request and the response.
  external String get state;

  /// A single ASCII error code.
  external String? get error;

  /// Human-readable ASCII text providing additional information, used to assist
  /// the client developer in understanding the error that occurred.
  external String? get error_description;

  /// A URI identifying a human-readable web page with information about the
  /// error, used to provide the client developer with additional information
  /// about the error.
  external String? get error_uri;
}

/// The type of the `callback` function passed to [CodeClientConfig].
typedef CodeClientCallbackFn = void Function(CodeResponse response);

// Token Client

/*
// Method: google.accounts.oauth2.initTokenClient
// https://developers.google.com/identity/oauth2/web/reference/js-reference#google.accounts.oauth2.initTokenClient
*/

/// The initCodeClient method initializes and returns a code client, with the
/// passed-in [config].
@JS()
external InitTokenClientFn get initTokenClient;

/// The type of the [initCodeClient] function.
typedef InitTokenClientFn = TokenClient Function(TokenClientConfig config);

/*
// Data type: TokenClientConfig
// https://developers.google.com/identity/oauth2/web/reference/js-reference#TokenClientConfig
*/

/// The configuration object for the [initTokenClient] method.
@JS()
@anonymous
@staticInterop
abstract class TokenClientConfig {
  /// Constructs a TokenClientConfig object in JavaScript.
  ///
  /// The [callback] property must be wrapped in [allowInterop] before it's
  /// passed to this constructor.
  external factory TokenClientConfig({
    required String client_id,
    required TokenClientCallbackFn? callback,
    required String scope,
    String? prompt,
    bool? enable_serial_consent,
    String? hint,
    String? hosted_domain,
    String? state,
  });
}

/*
// Data type: TokenClient
// https://developers.google.com/identity/oauth2/web/reference/js-reference#TokenClient
*/

/// A client that can start the OAuth 2.0 Token UX flow.
///
/// See: https://developers.google.com/identity/oauth2/web/guides/use-token-model
@JS()
@staticInterop
abstract class TokenClient {}

/// The methods available on the [TokenClient].
extension TokenClientExtension on TokenClient {
  /// Starts the OAuth 2.0 Code UX flow.
  external void requestAccessToken([
    OverridableTokenClientConfig overrideConfig,
  ]);
}

/*
// Data type: OverridableTokenClientConfig
// https://developers.google.com/identity/oauth2/web/reference/js-reference#OverridableTokenClientConfig
*/

/// The overridable configuration object for the
/// [TokenClientExtension.requestAccessToken] method.
@JS()
@anonymous
@staticInterop
abstract class OverridableTokenClientConfig {
  /// Constructs an OverridableTokenClientConfig object in JavaScript.
  ///
  /// The [callback] property must be wrapped in [allowInterop] before it's
  /// passed to this constructor.
  external factory OverridableTokenClientConfig({
    /// A space-delimited, case-sensitive list of prompts to present the user.
    ///
    /// See `prompt` in [TokenClientConfig].
    String? prompt,

    /// For clients created before 2019, when set to `false`, disables "more
    /// granular Google Account permissions".
    ///
    /// This setting has no effect in newer clients.
    ///
    /// See: https://developers.googleblog.com/2018/10/more-granular-google-account.html
    bool? enable_serial_consent,

    /// When your app knows which user it is trying to authenticate, it can
    /// provide this parameter as a hint to the authentication server. Passing
    /// this hint suppresses the account chooser and either pre-fills the email
    /// box on the sign-in form, or selects the proper session (if the user is
    /// using multiple sign-in), which can help you avoid problems that occur if
    /// your app logs in the wrong user account.
    ///
    /// The value can be either an email address or the `sub` string, which is
    /// equivalent to the user's Google ID.
    ///
    /// About Multiple Sign-in: https://support.google.com/accounts/answer/1721977
    String? hint,

    /// **Not recommended.** Specifies any string value that your application
    /// uses to maintain state between your authorization request and the
    /// authorization server's response.
    String? state,
  });
}

/*
// Data type: TokenResponse
// https://developers.google.com/identity/oauth2/web/reference/js-reference#TokenResponse
*/

/// The object passed as the parameter of your [TokenClientCallbackFn].
@JS()
@staticInterop
abstract class TokenResponse {}

/// The fields that are contained in the code response object.
extension TokenResponseExtension on TokenResponse {
  /// The access token of a successful token response.
  external String get access_token;

  /// The lifetime in seconds of the access token.
  external int get expires_in;

  /// The hosted domain the signed-in user belongs to.
  external String get hd;

  /// The prompt value that was used from the possible list of values specified
  /// by [TokenClientConfig] or [OverridableTokenClientConfig].
  external String get prompt;

  /// The type of the token issued.
  external String get token_type;

  /// A space-delimited list of scopes that are approved by the user.
  external String get scope;

  /// The string value that your application uses to maintain state between your
  /// authorization request and the response.
  external String get state;

  /// A single ASCII error code.
  external String? get error;

  /// Human-readable ASCII text providing additional information, used to assist
  /// the client developer in understanding the error that occurred.
  external String? get error_description;

  /// A URI identifying a human-readable web page with information about the
  /// error, used to provide the client developer with additional information
  /// about the error.
  external String? get error_uri;
}

/// The type of the `callback` function passed to [TokenClientConfig].
typedef TokenClientCallbackFn = void Function(TokenResponse response);

/*
// Method: google.accounts.oauth2.hasGrantedAllScopes
// https://developers.google.com/identity/oauth2/web/reference/js-reference#google.accounts.oauth2.hasGrantedAllScopes
*/

/// Checks if the user granted **all** the specified scopes.
@JS()
external HasGrantedScopesFn get hasGrantedAllScopes;

/*
// Method: google.accounts.oauth2.hasGrantedAnyScopes
// https://developers.google.com/identity/oauth2/web/reference/js-reference#google.accounts.oauth2.hasGrantedAnyScopes
*/

/// Checks if the user granted **any** of the specified scopes.
@JS()
external HasGrantedScopesFn get hasGrantedAnyScopes;

/// The signature for functions that check if any/all scopes have been granted.
///
/// Used by [hasGrantedAllScopes] and [hasGrantedAnyScope].
typedef HasGrantedScopesFn = bool Function(
  TokenResponse tokenResponse,
  String firstScope, [
  String? scope2,
  String? scope3,
  String? scope4,
  String? scope5,
  String? scope6,
  String? scope7,
  String? scope8,
  String? scope9,
  String? scope10,
]);

/*
// Method: google.accounts.oauth2.revoke
// https://developers.google.com/identity/oauth2/web/reference/js-reference#google.accounts.oauth2.revoke
*/

/// The [revokeToken] method revokes all of the scopes that the user granted to
/// the app. A valid access token is required to revoke the permission.
///
/// The `done` callback is called once the revoke action is done.
@JS('revoke')
external RevokeTokenFn get revokeToken;

/// The signature of the [revokeToken] function.
///
/// The (optional) [done] parameter must be manually wrapped in [allowInterop]
/// before being passed to the [revokeToken] function.
typedef RevokeTokenFn = void Function(
  String accessToken, [
  RevokeTokenDoneFn? done,
]);

/// The signature of the `done` function for [revokeToken].
///
/// Work in progress here: b/248628502
typedef RevokeTokenDoneFn = void Function(String jsonError);
