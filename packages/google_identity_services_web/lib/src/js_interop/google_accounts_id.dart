// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Authentication. API reference:
// https://developers.google.com/identity/gsi/web/reference/js-reference

// ignore_for_file: non_constant_identifier_names
// * non_constant_identifier_names required to be able to use the same parameter
//   names as the underlying JS library.

import 'dart:js_interop';

import 'shared.dart';

/// Binding to the `google.accounts.id` JS global.
///
/// See: https://developers.google.com/identity/gsi/web/reference/js-reference
@JS('google.accounts.id')
external GoogleAccountsId get id;

/// The Dart definition of the `google.accounts.id` global.
extension type GoogleAccountsId._(JSObject _) implements JSObject {
  /// An undocumented method.
  ///
  /// Try it with 'debug'.
  void setLogLevel(String level) => _setLogLevel(level.toJS);
  @JS('setLogLevel')
  external void _setLogLevel(JSString level);

  /// Initializes the Sign In With Google client based on [IdConfiguration].
  ///
  /// The `initialize` method creates a Sign In With Google client instance that
  /// can be implicitly used by all modules in the same web page.
  ///
  /// * You only need to call the `initialize` method once even if you use
  ///   multiple modules (like One Tap, Personalized button, revocation, etc.) in
  ///   the same web page.
  /// * If you do call the google.accounts.id.initialize method multiple times,
  ///   only the configurations in the last call will be remembered and used.
  ///
  /// You actually reset the configurations whenever you call the `initialize`
  /// method, and all subsequent methods in the same web page will use the new
  /// configurations immediately.
  ///
  /// WARNING: The `initialize` method should be called only once, even if you
  /// use both One Tap and button in the same web page.
  ///
  /// Method: google.accounts.id.initialize
  /// https://developers.google.com/identity/gsi/web/reference/js-reference#google.accounts.id.initialize
  external void initialize(IdConfiguration idConfiguration);

  /// The `prompt` method displays the One Tap prompt or the browser native
  /// credential manager after the [initialize] method is invoked.
  ///
  /// Normally, the `prompt` method is called on page load. Due to the session
  /// status and user settings on the Google side, the One Tap prompt UI might
  /// not be displayed. To get notified on the UI status for different moments,
  /// pass a [PromptMomentListenerFn] to receive UI status notifications.
  ///
  /// Notifications are fired on the following moments:
  ///
  /// * Display moment: This occurs after the `prompt` method is called. The
  ///   notification contains a boolean value to indicate whether the UI is
  ///   displayed or not.
  /// * Skipped moment: This occurs when the One Tap prompt is closed by an auto
  ///   cancel, a manual cancel, or when Google fails to issue a credential, such
  ///   as when the selected session has signed out of Google.
  ///   In these cases, we recommend that you continue on to the next identity
  ///   providers, if there are any.
  /// * Dismissed moment: This occurs when Google successfully retrieves a
  ///   credential or a user wants to stop the credential retrieval flow. For
  ///   example, when the user begins to input their username and password in
  ///   your login dialog, you can call the [cancel] method to close the One Tap
  ///   prompt and trigger a dismissed moment.
  ///
  ///   WARNING: When on a dismissed moment, do not try any of the next identity
  ///   providers.
  ///
  /// Method: google.accounts.id.prompt
  /// https://developers.google.com/identity/gsi/web/reference/js-reference#google.accounts.id.prompt
  void prompt([PromptMomentListenerFn? momentListener]) {
    if (momentListener == null) {
      return _prompt();
    }
    return _promptWithListener(momentListener.toJS);
  }

  @JS('prompt')
  external void _prompt();
  @JS('prompt')
  external void _promptWithListener(JSFunction momentListener);

  /// Renders a Sign In With Google button in your web page.
  ///
  /// Method: google.accounts.id.renderButton
  /// https://developers.google.com/identity/gsi/web/reference/js-reference#google.accounts.id.renderButton
  void renderButton(
    Object parent, [
    GsiButtonConfiguration? options,
  ]) {
    assert(parent is JSObject,
        'parent must be a JSObject. Use package:web to retrieve/create one.');
    parent as JSObject;
    if (options == null) {
      return _renderButton(parent);
    }
    return _renderButtonWithOptions(parent, options);
  }

  @JS('renderButton')
  external void _renderButton(JSObject parent);
  @JS('renderButton')
  external void _renderButtonWithOptions(
      JSObject parent, GsiButtonConfiguration options);

  /// Record when the user signs out of your website in cookies.
  ///
  /// This prevents a UX dead loop.
  ///
  /// Method: google.accounts.id.disableAutoselect
  /// https://developers.google.com/identity/gsi/web/reference/js-reference#google.accounts.id.disableAutoSelect
  external void disableAutoSelect();

  /// A wrapper for the `store` method of the browser's native credential manager API.
  ///
  /// It can only be used to store a Password [Credential].
  ///
  /// See: https://developer.mozilla.org/en-US/docs/Web/API/CredentialsContainer/store
  ///
  /// Method: google.accounts.id.storeCredential
  /// https://developers.google.com/identity/gsi/web/reference/js-reference#google.accounts.id.storeCredential
  void storeCredential(Credential credential, [VoidFn? callback]) {
    if (callback == null) {
      return _jsStoreCredential(credential);
    }
    return _jsStoreCredentialWithCallback(credential, callback.toJS);
  }

  @JS('storeCredential')
  external void _jsStoreCredential(Credential credential);
  @JS('storeCredential')
  external void _jsStoreCredentialWithCallback(
      Credential credential, JSFunction callback);

  /// Cancels the One Tap flow.
  ///
  /// You can cancel the One Tap flow if you remove the prompt from the relying
  /// party DOM. The cancel operation is ignored if a credential is already
  /// selected.
  ///
  /// Method: google.accounts.id.cancel
  /// https://developers.google.com/identity/gsi/web/reference/js-reference#google.accounts.id.cancel
  external void cancel();

  /// Revokes the OAuth grant used to share the ID token for the specified user.
  ///
  /// [hint] is the email address or unique ID of the user's Google Account. The
  /// ID is the `sub` property of the [CredentialResponse.credential] payload.
  ///
  /// The optional [callback] is a function that gets called to report on the
  /// success of the revocation call. It must be a Dart function and not a JS
  /// function.
  ///
  /// Method: google.accounts.id.revoke
  /// https://developers.google.com/identity/gsi/web/reference/js-reference#google.accounts.id.revoke
  void revoke(String hint, [RevocationResponseHandlerFn? callback]) {
    if (callback == null) {
      return _revoke(hint.toJS);
    }
    return _revokeWithCallback(hint.toJS, callback.toJS);
  }

  @JS('revoke')
  external void _revoke(JSString hint);
  @JS('revoke')
  external void _revokeWithCallback(JSString hint, JSFunction callback);
}

/// The configuration object for the [initialize] method.
///
/// Data type: IdConfiguration
/// https://developers.google.com/identity/gsi/web/reference/js-reference#IdConfiguration
extension type IdConfiguration._(JSObject _) implements JSObject {
  /// Constructs a IdConfiguration object in JavaScript.
  factory IdConfiguration({
    /// Your application's client ID, which is found and created in the Google
    /// Developers Console.
    required String client_id,

    /// Determines if an ID token is automatically returned without any user
    /// interaction when there's only one Google session that has approved your
    /// app before. The default value is `false`.
    bool? auto_select,

    /// The function that handles the ID token returned from the One Tap prompt
    /// or the pop-up window. This attribute is required if Google One Tap or
    /// the Sign In With Google button `popup` UX mode is used.
    CallbackFn? callback,

    /// This attribute is the URI of your login endpoint. May be omitted if the
    /// current page is your login page, in which case the credential is posted
    /// to this page by default.
    ///
    /// The ID token credential response is posted to your login endpoint when
    /// a user clicks on the Sign In With Google button and `redirect` UX mode
    /// is used.
    ///
    /// Your login endpoint must handle POST requests containing a credential
    /// key with an ID token value in the body.
    Uri? login_uri,

    /// The function that handles the password credential returned from the
    /// browser's native credential manager.
    NativeCallbackFn? native_callback,

    /// Whether or not to cancel the One Tap request if a user clicks outside
    /// the prompt. The default value is `true`.
    bool? cancel_on_tap_outside,

    /// The DOM ID of the container element. If it's not set, the One Tap prompt
    /// is displayed in the top-right corner of the window.
    String? prompt_parent_id,

    /// A random string used by the ID token to prevent replay attacks.
    ///
    /// Nonce length is limited to the maximum JWT size supported by your
    /// environment, and individual browser and server HTTP size constraints.
    String? nonce,

    /// Changes the text of the title and messages in the One Tap prompt.
    OneTapContext? context,

    /// If you need to display One Tap in the parent domain and its subdomains,
    /// pass the parent domain to this field so that a single shared-state
    /// cookie is used.
    ///
    /// See: https://developers.google.com/identity/gsi/web/guides/subdomains
    String? state_cookie_domain,

    /// Set the UX flow used by the Sign In With Google button. The default
    /// value is `popup`. **This attribute has no impact on the OneTap UX.**
    UxMode? ux_mode,

    /// The origins that are allowed to embed the intermediate iframe. One Tap
    /// will run in the intermediate iframe mode if this field presents.
    ///
    /// Wildcard prefixes are also supported. Wildcard domains must begin with
    /// a secure `https://` scheme, otherwise they'll be considered invalid.
    List<String>? allowed_parent_origin,

    /// Overrides the default intermediate iframe behavior when users manually
    /// close One Tap by tapping on the 'X' button in the One Tap UI. The
    /// default behavior is to remove the intermediate iframe from the DOM
    /// immediately.
    ///
    /// The `intermediate_iframe_close_callback` field takes effect only in
    /// intermediate iframe mode. And it has impact only to the intermediate
    /// iframe, instead of the One Tap iframe. The One Tap UI is removed before
    /// the callback is invoked.
    VoidFn? intermediate_iframe_close_callback,

    /// Determines if the upgraded One Tap UX should be enabled on browsers
    /// that support Intelligent Tracking Prevention (ITP). The default value
    /// is false.
    ///
    /// See: https://developers.google.com/identity/gsi/web/guides/features#upgraded_ux_on_itp_browsers
    bool? itp_support,

    /// If your application knows in advance which user should be signed-in, it
    /// can provide a login hint to Google.
    ///
    /// When successful, account selection is skipped. Accepted values are:
    ///   * an email address or
    ///   * an ID token sub field value.
    ///
    /// For more information, see:
    ///   * https://developers.google.com/identity/protocols/oauth2/openid-connect#authenticationuriparameters
    String? login_hint,

    /// When a user has multiple accounts and should only sign-in with their
    /// Workspace account use this to provide a domain name hint to Google.
    ///
    /// When successful, user accounts displayed during account selection are
    /// limited to the provided domain.
    ///
    /// A wildcard value: `*` offers only Workspace accounts to the user and
    /// excludes consumer accounts (user@gmail.com) during account selection.
    ///
    /// For more information, see:
    ///   * https://developers.google.com/identity/protocols/oauth2/openid-connect#authenticationuriparameters
    String? hd,

    /// Allow the browser to control user sign-in prompts and mediate the
    /// sign-in flow between your website and Google. Defaults to false.
    bool? use_fedcm_for_prompt,
  }) {
    return IdConfiguration._toJS(
      client_id: client_id.toJS,
      auto_select: auto_select?.toJS,
      callback: callback?.toJS,
      login_uri: login_uri?.toString().toJS,
      native_callback: native_callback?.toJS,
      cancel_on_tap_outside: cancel_on_tap_outside?.toJS,
      prompt_parent_id: prompt_parent_id?.toJS,
      nonce: nonce?.toJS,
      context: context?.toString().toJS,
      state_cookie_domain: state_cookie_domain?.toJS,
      ux_mode: ux_mode?.toString().toJS,
      allowed_parent_origin:
          allowed_parent_origin?.map((String s) => s.toJS).toList().toJS,
      intermediate_iframe_close_callback:
          intermediate_iframe_close_callback?.toJS,
      itp_support: itp_support?.toJS,
      login_hint: login_hint?.toJS,
      hd: hd?.toJS,
      use_fedcm_for_prompt: use_fedcm_for_prompt?.toJS,
    );
  }

  // `IdConfiguration`'s external factory, defined as JSTypes. This is the actual JS-interop bit.
  external factory IdConfiguration._toJS({
    JSString? client_id,
    JSBoolean? auto_select,
    JSFunction? callback,
    JSString? login_uri,
    JSFunction? native_callback,
    JSBoolean? cancel_on_tap_outside,
    JSString? prompt_parent_id,
    JSString? nonce,
    JSString? context,
    JSString? state_cookie_domain,
    JSString? ux_mode,
    JSArray<JSString>? allowed_parent_origin,
    JSFunction? intermediate_iframe_close_callback,
    JSBoolean? itp_support,
    JSString? login_hint,
    JSString? hd,
    JSBoolean? use_fedcm_for_prompt,
  });
}

/// The type of the function that can be passed to [prompt] to listen for [PromptMomentNotification]s.
typedef PromptMomentListenerFn = void Function(PromptMomentNotification moment);

/// A moment (status) notification from the [prompt] method.
///
/// Data type: PromptMomentNotification
/// https://developers.google.com/identity/gsi/web/reference/js-reference#PromptMomentNotification
extension type PromptMomentNotification._(JSObject _) implements JSObject {
  /// Is this notification for a display moment?
  bool isDisplayMoment() => _isDisplayMoment().toDart;
  @JS('isDisplayMoment')
  external JSBoolean _isDisplayMoment();

  /// Is this notification for a display moment, and the UI is displayed?
  bool isDisplayed() => _isDisplayed().toDart;
  @JS('isDisplayed')
  external JSBoolean _isDisplayed();

  /// Is this notification for a display moment, and the UI isn't displayed?
  bool isNotDisplayed() => _isNotDisplayed().toDart;
  @JS('isNotDisplayed')
  external JSBoolean _isNotDisplayed();

  /// Is this notification for a skipped moment?
  bool isSkippedMoment() => _isSkippedMoment().toDart;
  @JS('isSkippedMoment')
  external JSBoolean _isSkippedMoment();

  /// Is this notification for a dismissed moment?
  bool isDismissedMoment() => _isDismissedMoment().toDart;
  @JS('isDismissedMoment')
  external JSBoolean _isDismissedMoment();

  /// The moment type.
  MomentType getMomentType() =>
      MomentType.values.byName(_getMomentType().toDart);
  @JS('getMomentType')
  external JSString _getMomentType();

  /// The detailed reason why the UI isn't displayed.
  MomentNotDisplayedReason? getNotDisplayedReason() => maybeEnum(
      _getNotDisplayedReason()?.toDart, MomentNotDisplayedReason.values);
  @JS('getNotDisplayedReason')
  external JSString? _getNotDisplayedReason();

  /// The detailed reason for the skipped moment.
  MomentSkippedReason? getSkippedReason() =>
      maybeEnum(_getSkippedReason()?.toDart, MomentSkippedReason.values);
  @JS('getSkippedReason')
  external JSString? _getSkippedReason();

  /// The detailed reason for the dismissal.
  MomentDismissedReason? getDismissedReason() =>
      maybeEnum(_getDismissedReason()?.toDart, MomentDismissedReason.values);
  @JS('getDismissedReason')
  external JSString? _getDismissedReason();
}

/// The object passed as the parameter of your [CallbackFn].
///
/// Data type: CredentialResponse
/// https://developers.google.com/identity/gsi/web/reference/js-reference#CredentialResponse
extension type CredentialResponse._(JSObject _) implements JSObject {
  /// The ClientID for this Credential.
  String? get client_id => _client_id?.toDart;
  @JS('client_id')
  external JSString? get _client_id;

  /// Error while signing in.
  String? get error => _error?.toDart;
  @JS('error')
  external JSString? get _error;

  /// Details of the error while signing in.
  String? get error_detail => _error_detail?.toDart;
  @JS('error_detail')
  external JSString? get _error_detail;

  /// This field is the ID token as a base64-encoded JSON Web Token (JWT)
  /// string.
  ///
  /// See more: https://developers.google.com/identity/gsi/web/reference/js-reference#credential
  String? get credential => _credential?.toDart;
  @JS('credential')
  external JSString? get _credential;

  /// This field sets how the credential was selected.
  ///
  /// The type of button used along with the session and consent state are used
  /// to set the value.
  ///
  /// See more: https://developers.google.com/identity/gsi/web/reference/js-reference#select_by
  CredentialSelectBy? get select_by =>
      maybeEnum(_select_by?.toDart, CredentialSelectBy.values);
  @JS('select_by')
  external JSString? get _select_by;
}

/// The type of the `callback` used to create an [IdConfiguration].
///
/// Describes a JavaScript function that handles ID tokens from
/// [CredentialResponse]s.
///
/// Google One Tap and the Sign In With Google button popup UX mode use this
/// attribute.
typedef CallbackFn = void Function(CredentialResponse credentialResponse);

/// The configuration object for the [renderButton] method.
///
/// Data type: GsiButtonConfiguration
/// https://developers.google.com/identity/gsi/web/reference/js-reference#GsiButtonConfiguration
extension type GsiButtonConfiguration._(JSObject _) implements JSObject {
  /// Constructs an options object for the [renderButton] method.
  factory GsiButtonConfiguration({
    /// The button type.
    ButtonType? type,

    /// The button theme.
    ButtonTheme? theme,

    /// The button size.
    ButtonSize? size,

    /// The button text.
    ButtonText? text,

    /// The button shape.
    ButtonShape? shape,

    /// The Google logo alignment in the button.
    ButtonLogoAlignment? logo_alignment,

    /// The minimum button width, in pixels.
    ///
    /// The maximum width is 400 pixels.
    double? width,

    /// The pre-set locale of the button text.
    ///
    /// If not set, the browser's default locale or the Google session user's
    /// preference is used.
    String? locale,

    /// A function to be called when the button is clicked.
    GsiButtonClickListenerFn? click_listener,
  }) {
    return GsiButtonConfiguration._toJS(
      type: type.toString().toJS,
      theme: theme.toString().toJS,
      size: size.toString().toJS,
      text: text?.toString().toJS,
      shape: shape?.toString().toJS,
      logo_alignment: logo_alignment?.toString().toJS,
      width: width?.toJS,
      locale: locale?.toJS,
      click_listener: click_listener?.toJS,
    );
  }

  // `GsiButtonConfiguration`'s external factory, defined as JSTypes.
  external factory GsiButtonConfiguration._toJS({
    JSString? type,
    JSString? theme,
    JSString? size,
    JSString? text,
    JSString? shape,
    JSString? logo_alignment,
    JSNumber? width,
    JSString? locale,
    JSFunction? click_listener,
  });
}

/// The object passed as an optional parameter to `click_listener` function.
extension type GsiButtonData._(JSObject _) implements JSObject {
  /// Nonce
  String? get nonce => _nonce?.toDart;
  @JS('nonce')
  external JSString? get _nonce;

  /// State
  String? get state => _state?.toDart;
  @JS('state')
  external JSString? get _state;
}

/// The type of the [GsiButtonConfiguration] `click_listener` function.
typedef GsiButtonClickListenerFn = void Function(GsiButtonData? gsiButtonData);

/// The object passed to the [NativeCallbackFn]. Represents a PasswordCredential
/// that was returned by the Browser.
///
/// `Credential` objects can also be programmatically created to be stored
/// in the browser through the [storeCredential] method.
///
/// See also: https://developer.mozilla.org/en-US/docs/Web/API/PasswordCredential/PasswordCredential
///
/// Data type: Credential
/// https://developers.google.com/identity/gsi/web/reference/js-reference#type-Credential
extension type Credential._(JSObject _) implements JSObject {
  ///
  factory Credential({
    required String id,
    required String password,
  }) =>
      Credential._toJS(
        id: id.toJS,
        password: password.toJS,
      );

  external factory Credential._toJS({
    JSString id,
    JSString password,
  });
}

/// The fields that are contained in the [Credential] object.
extension CredentialExtension on Credential {
  /// Identifies the user.
  String? get id => _id.toDart;
  @JS('id')
  external JSString get _id;

  /// The password.
  String? get password => _password.toDart;
  @JS('password')
  external JSString get _password;
}

/// The type of the `native_callback` used to create an [IdConfiguration].
///
/// Describes a JavaScript function that handles password [Credential]s coming
/// from the native Credential manager of the user's browser.
typedef NativeCallbackFn = void Function(Credential credential);

/*
// Library load callback: onGoogleLibraryLoad
// https://developers.google.com/identity/gsi/web/reference/js-reference#onGoogleLibraryLoad
// See: `load_callback.dart` and `loader.dart`
*/

/// The type of the `callback` function passed to [revoke], to be notified of
/// the success of the revocation operation.
typedef RevocationResponseHandlerFn = void Function(
  RevocationResponse revocationResponse,
);

/// The parameter passed to the `callback` of the [revoke] function.
///
/// Data type: RevocationResponse
/// https://developers.google.com/identity/gsi/web/reference/js-reference#RevocationResponse
extension type RevocationResponse._(JSObject _) implements JSObject {
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
}
