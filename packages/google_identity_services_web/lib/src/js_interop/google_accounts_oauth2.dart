// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Authorization. API reference:
// https://developers.google.com/identity/oauth2/web/reference/js-reference

// ignore_for_file: non_constant_identifier_names
// * non_constant_identifier_names required to be able to use the same parameter
//   names as the underlying library.

import 'dart:js_interop';

import 'shared.dart';

/// Binding to the `google.accounts.oauth2` JS global.
///
/// See: https://developers.google.com/identity/oauth2/web/reference/js-reference
@JS('google.accounts.oauth2')
external GoogleAccountsOauth2 get oauth2;

/// The Dart definition of the `google.accounts.oauth2` global.
extension type GoogleAccountsOauth2._(JSObject _) implements JSObject {
  /// Initializes and returns a code client, with the passed-in [config].
  ///
  /// Method: google.accounts.oauth2.initCodeClient
  /// https://developers.google.com/identity/oauth2/web/reference/js-reference#google.accounts.oauth2.initCodeClient
  external CodeClient initCodeClient(CodeClientConfig config);

  /// Initializes and returns a token client, with the passed-in [config].
  ///
  /// Method: google.accounts.oauth2.initTokenClient
  /// https://developers.google.com/identity/oauth2/web/reference/js-reference#google.accounts.oauth2.initTokenClient
  external TokenClient initTokenClient(TokenClientConfig config);

  // Method: google.accounts.oauth2.hasGrantedAllScopes
  // https://developers.google.com/identity/oauth2/web/reference/js-reference#google.accounts.oauth2.hasGrantedAllScopes
  @JS('hasGrantedAllScopes')
  external bool _hasGrantedScope(TokenResponse token, JSString scope);

  /// Checks if hte user has granted **all** the specified [scopes].
  ///
  /// [scopes] is a space-separated list of scope names.
  ///
  /// Method: google.accounts.oauth2.hasGrantedAllScopes
  /// https://developers.google.com/identity/oauth2/web/reference/js-reference#google.accounts.oauth2.hasGrantedAllScopes
  bool hasGrantedAllScopes(TokenResponse tokenResponse, List<String> scopes) {
    return scopes
        .every((String scope) => _hasGrantedScope(tokenResponse, scope.toJS));
  }

  /// Checks if hte user has granted **all** the specified [scopes].
  ///
  /// [scopes] is a space-separated list of scope names.
  ///
  /// Method: google.accounts.oauth2.hasGrantedAllScopes
  /// https://developers.google.com/identity/oauth2/web/reference/js-reference#google.accounts.oauth2.hasGrantedAllScopes
  bool hasGrantedAnyScopes(TokenResponse tokenResponse, List<String> scopes) {
    return scopes
        .any((String scope) => _hasGrantedScope(tokenResponse, scope.toJS));
  }

  /// Revokes all of the scopes that the user granted to the app.
  ///
  /// A valid [accessToken] is required to revoke permissions.
  ///
  /// The [done] callback is called once the revoke action is done. It must be
  /// a Dart function and not a JS function.
  ///
  /// Method: google.accounts.oauth2.revoke
  /// https://developers.google.com/identity/oauth2/web/reference/js-reference#google.accounts.oauth2.revoke
  void revoke(
    String accessToken, [
    RevokeTokenDoneFn? done,
  ]) {
    if (done == null) {
      return _revoke(accessToken.toJS);
    }
    return _revokeWithDone(accessToken.toJS, done.toJS);
  }

  @JS('revoke')
  external void _revoke(JSString accessToken);
  @JS('revoke')
  external void _revokeWithDone(JSString accessToken, JSFunction done);
}

/// The configuration object for the [initCodeClient] method.
///
/// Data type: CodeClientConfig
/// https://developers.google.com/identity/oauth2/web/reference/js-reference#CodeClientConfig
extension type CodeClientConfig._(JSObject _) implements JSObject {
  /// Constructs a CodeClientConfig object in JavaScript.
  ///
  /// The [callback] property must be a Dart function and not a JS function.
  factory CodeClientConfig({
    required String client_id,
    required List<String> scope,
    bool? include_granted_scopes,
    Uri? redirect_uri,
    CodeClientCallbackFn? callback,
    String? state,
    bool? enable_granular_consent,
    @Deprecated('Use `enable_granular_consent` instead.')
    bool? enable_serial_consent,
    String? login_hint,
    String? hd,
    UxMode? ux_mode,
    bool? select_account,
    ErrorCallbackFn? error_callback,
  }) {
    assert(scope.isNotEmpty);
    return CodeClientConfig._toJS(
      client_id: client_id.toJS,
      scope: scope.join(' ').toJS,
      include_granted_scopes: include_granted_scopes?.toJS,
      redirect_uri: redirect_uri?.toString().toJS,
      callback: callback?.toJS,
      state: state?.toJS,
      enable_granular_consent: enable_granular_consent?.toJS,
      enable_serial_consent: enable_serial_consent?.toJS,
      login_hint: login_hint?.toJS,
      hd: hd?.toJS,
      ux_mode: ux_mode.toString().toJS,
      select_account: select_account?.toJS,
      error_callback: error_callback?.toJS,
    );
  }

  external factory CodeClientConfig._toJS({
    JSString? client_id,
    JSString? scope,
    JSBoolean? include_granted_scopes,
    JSString? redirect_uri,
    JSFunction? callback,
    JSString? state,
    JSBoolean? enable_granular_consent,
    JSBoolean? enable_serial_consent,
    JSString? login_hint,
    JSString? hd,
    JSString? ux_mode,
    JSBoolean? select_account,
    JSFunction? error_callback,
  });
}

/// A client that can start the OAuth 2.0 Code UX flow.
///
/// See: https://developers.google.com/identity/oauth2/web/guides/use-code-model
///
/// Data type: CodeClient
/// https://developers.google.com/identity/oauth2/web/reference/js-reference#CodeClient
extension type CodeClient._(JSObject _) implements JSObject {
  /// Starts the OAuth 2.0 Code UX flow.
  external void requestCode();
}

/// The object passed as the parameter of your [CodeClientCallbackFn].
///
/// Data type: CodeResponse
/// https://developers.google.com/identity/oauth2/web/reference/js-reference#CodeResponse
extension type CodeResponse._(JSObject _) implements JSObject {
  /// The authorization code of a successful token response.
  String? get code => _code?.toDart;
  @JS('code')
  external JSString? get _code;

  /// A list of scopes that are approved by the user.
  List<String> get scope => _scope?.toDart.split(' ') ?? List<String>.empty();
  @JS('scope')
  external JSString? get _scope;

  /// The string value that your application uses to maintain state between your
  /// authorization request and the response.
  String? get state => _state?.toDart;
  @JS('state')
  external JSString? get _state;

  /// A single ASCII error code.
  String? get error => _error?.toDart;
  @JS('error')
  external JSString? get _error;

  /// Human-readable ASCII text providing additional information, used to assist
  /// the client developer in understanding the error that occurred.
  String? get error_description => _error_description?.toDart;
  @JS('error_description')
  external JSString? get _error_description;

  /// A URI identifying a human-readable web page with information about the
  /// error, used to provide the client developer with additional information
  /// about the error.
  String? get error_uri => _error_uri?.toDart;
  @JS('error_uri')
  external JSString? get _error_uri;
}

/// The type of the `callback` function passed to [CodeClientConfig].
typedef CodeClientCallbackFn = void Function(CodeResponse response);

/// The configuration object for the [initTokenClient] method.
///
/// Data type: TokenClientConfig
/// https://developers.google.com/identity/oauth2/web/reference/js-reference#TokenClientConfig
extension type TokenClientConfig._(JSObject _) implements JSObject {
  /// Constructs a TokenClientConfig object in JavaScript.
  ///
  /// The [callback] property must be a Dart function and not a JS function.
  factory TokenClientConfig({
    required String client_id,
    required TokenClientCallbackFn callback,
    required List<String> scope,
    bool? include_granted_scopes,
    String? prompt,
    bool? enable_granular_consent,
    @Deprecated('Use `enable_granular_consent` instead.')
    bool? enable_serial_consent,
    String? login_hint,
    String? hd,
    String? state,
    ErrorCallbackFn? error_callback,
  }) {
    assert(scope.isNotEmpty);
    return TokenClientConfig._toJS(
      client_id: client_id.toJS,
      callback: callback.toJS,
      scope: scope.join(' ').toJS,
      include_granted_scopes: include_granted_scopes?.toJS,
      prompt: prompt?.toJS,
      enable_granular_consent: enable_granular_consent?.toJS,
      enable_serial_consent: enable_serial_consent?.toJS,
      login_hint: login_hint?.toJS,
      hd: hd?.toJS,
      state: state?.toJS,
      error_callback: error_callback?.toJS,
    );
  }

  external factory TokenClientConfig._toJS({
    JSString? client_id,
    JSFunction? callback,
    JSString? scope,
    JSBoolean? include_granted_scopes,
    JSString? prompt,
    JSBoolean? enable_granular_consent,
    JSBoolean? enable_serial_consent,
    JSString? login_hint,
    JSString? hd,
    JSString? state,
    JSFunction? error_callback,
  });
}

/// A client that can start the OAuth 2.0 Token UX flow.
///
/// See: https://developers.google.com/identity/oauth2/web/guides/use-token-model
///
/// Data type: TokenClient
/// https://developers.google.com/identity/oauth2/web/reference/js-reference#TokenClient
extension type TokenClient._(JSObject _) implements JSObject {
  /// Starts the OAuth 2.0 Code UX flow.
  void requestAccessToken([
    OverridableTokenClientConfig? overrideConfig,
  ]) {
    if (overrideConfig == null) {
      return _requestAccessToken();
    }
    return _requestAccessTokenWithConfig(overrideConfig);
  }

  @JS('requestAccessToken')
  external void _requestAccessToken();
  @JS('requestAccessToken')
  external void _requestAccessTokenWithConfig(
      OverridableTokenClientConfig config);
}

/// The overridable configuration object for the [TokenClientExtension.requestAccessToken] method.
///
/// Data type: OverridableTokenClientConfig
/// https://developers.google.com/identity/oauth2/web/reference/js-reference#OverridableTokenClientConfig
extension type OverridableTokenClientConfig._(JSObject _) implements JSObject {
  /// Constructs an OverridableTokenClientConfig object in JavaScript.
  factory OverridableTokenClientConfig({
    /// A list of scopes that identify the resources that your application could
    /// access on the user's behalf. These values inform the consent screen that
    /// Google displays to the user.
    // b/251971390
    List<String>? scope,

    /// Enables applications to use incremental authorization to request access
    /// to additional scopes in context. If you set this parameter's value to
    /// `false` and the authorization request is granted, then the new access
    /// token will only cover any scopes to which the `scope` requested in this
    /// [OverridableTokenClientConfig].
    bool? include_granted_scopes,

    /// A space-delimited, case-sensitive list of prompts to present the user.
    ///
    /// See `prompt` in [TokenClientConfig].
    String? prompt,

    /// If set to false, "more granular Google Account permissions" would be
    /// disabled for OAuth client IDs created before 2019. If both
    /// `enable_granular_consent` and `enable_serial_consent` are set, only
    /// `enable_granular_consent` value would take effect and
    /// `enable_serial_consent` value would be ignored.
    ///
    /// No effect for newer OAuth client IDs, since more granular permissions is
    /// always enabled for them.
    bool? enable_granular_consent,

    /// This has the same effect as `enable_granular_consent`. Existing
    /// applications that use `enable_serial_consent` can continue to do so, but
    /// you are encouraged to update your code to use `enable_granular_consent`
    /// in your next application update.
    ///
    /// See: https://developers.googleblog.com/2018/10/more-granular-google-account.html
    @Deprecated('Use `enable_granular_consent` instead.')
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
    String? login_hint,

    /// **Not recommended.** Specifies any string value that your application
    /// uses to maintain state between your authorization request and the
    /// authorization server's response.
    String? state,
  }) {
    assert(scope == null || scope.isNotEmpty);
    return OverridableTokenClientConfig._toJS(
      scope: scope?.join(' ').toJS,
      include_granted_scopes: include_granted_scopes?.toJS,
      prompt: prompt?.toJS,
      enable_granular_consent: enable_granular_consent?.toJS,
      enable_serial_consent: enable_serial_consent?.toJS,
      login_hint: login_hint?.toJS,
      state: state?.toJS,
    );
  }

  external factory OverridableTokenClientConfig._toJS({
    JSString? scope,
    JSBoolean? include_granted_scopes,
    JSString? prompt,
    JSBoolean? enable_granular_consent,
    JSBoolean? enable_serial_consent,
    JSString? login_hint,
    JSString? state,
  });
}

/// The object passed as the parameter of your [TokenClientCallbackFn].
///
/// Data type: TokenResponse
/// https://developers.google.com/identity/oauth2/web/reference/js-reference#TokenResponse
extension type TokenResponse._(JSObject _) implements JSObject {
  /// The access token of a successful token response.
  String? get access_token => _access_token?.toDart;
  @JS('access_token')
  external JSString? get _access_token;

  /// The lifetime in seconds of the access token.
  int? get expires_in => _expires_in?.toDartInt;
  @JS('expires_in')
  external JSNumber? get _expires_in;

  /// The hosted domain the signed-in user belongs to.
  String? get hd => _hd?.toDart;
  @JS('hd')
  external JSString? get _hd;

  /// The prompt value that was used from the possible list of values specified
  /// by [TokenClientConfig] or [OverridableTokenClientConfig].
  String? get prompt => _prompt?.toDart;
  @JS('prompt')
  external JSString? get _prompt;

  /// The type of the token issued.
  String? get token_type => _token_type?.toDart;
  @JS('token_type')
  external JSString? get _token_type;

  /// A list of scopes that are approved by the user.
  List<String> get scope => _scope?.toDart.split(' ') ?? List<String>.empty();
  @JS('scope')
  external JSString? get _scope;

  /// The string value that your application uses to maintain state between your
  /// authorization request and the response.
  String? get state => _state?.toDart;
  @JS('state')
  external JSString? get _state;

  /// A single ASCII error code.
  String? get error => _error?.toDart;
  @JS('error')
  external JSString? get _error;

  /// Human-readable ASCII text providing additional information, used to assist
  /// the client developer in understanding the error that occurred.
  String? get error_description => _error_description?.toDart;
  @JS('error_description')
  external JSString? get _error_description;

  /// A URI identifying a human-readable web page with information about the
  /// error, used to provide the client developer with additional information
  /// about the error.
  String? get error_uri => _error_uri?.toDart;
  @JS('error_uri')
  external JSString? get _error_uri;
}

/// The type of the `callback` function passed to [TokenClientConfig].
typedef TokenClientCallbackFn = void Function(TokenResponse response);

/// The type of the `error_callback` in both oauth2 initXClient calls.
typedef ErrorCallbackFn = void Function(GoogleIdentityServicesError? error);

/// An error returned by `initTokenClient` or `initDataClient`.
extension type GoogleIdentityServicesError._(JSObject _) implements JSObject {
  /// The type of error
  GoogleIdentityServicesErrorType get type =>
      GoogleIdentityServicesErrorType.values.byName(_type.toDart);
  @JS('type')
  external JSString get _type;

  /// A human-readable description of the error `type`.
  ///
  /// (Undocumented)
  String? get message => _message?.toDart;
  @JS('message')
  external JSString? get _message;
}

/// The signature of the `done` function for [revoke].
typedef RevokeTokenDoneFn = void Function(TokenRevocationResponse response);

/// The parameter passed to the `callback` of the [revoke] function.
///
/// Data type: RevocationResponse
/// https://developers.google.com/identity/oauth2/web/reference/js-reference#TokenResponse
extension type TokenRevocationResponse._(JSObject _) implements JSObject {
  /// This field is a boolean value set to true if the revoke method call
  /// succeeded or false on failure.
  bool get successful => _successful.toDart;
  @JS('successful')
  external JSBoolean get _successful;

  /// This field is a string value and contains a detailed error message if the
  /// revoke method call failed, it is undefined on success.
  String? get error => _error?.toDart;
  @JS('error')
  external JSString? get _error;

  /// The description of the error.
  String? get error_description => _error_description?.toDart;
  @JS('error_description')
  external JSString? get _error_description;
}
