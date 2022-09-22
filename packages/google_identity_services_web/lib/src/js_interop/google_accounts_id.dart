// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Authentication. API reference:
// https://developers.google.com/identity/gsi/web/reference/js-reference

// ignore_for_file: non_constant_identifier_names
// * non_constant_identifier_names required to be able to use the same parameter
//   names as the underlying library.

@JS('google.accounts.id')
library id;

import 'package:js/js.dart';

import 'shared.dart';

/// An undocumented method. Try with 'debug'.
@JS()
external SetLogLevelFn get setLogLevel;
///
typedef SetLogLevelFn = void Function(String level);

/*
// Method: google.accounts.id.initialize
// https://developers.google.com/identity/gsi/web/reference/js-reference#google.accounts.id.initialize
*/

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
@JS()
external InitializeFn get initialize;

/// The type of the [initialize] function.
typedef InitializeFn = void Function(IdConfiguration idConfiguration);

/*
// Data type: IdConfiguration
// https://developers.google.com/identity/gsi/web/reference/js-reference#IdConfiguration
*/

/// The configuration object for the [initialize] method.
@JS()
@anonymous
@staticInterop
abstract class IdConfiguration {
  /// Constructs a IdConfiguration object in JavaScript.
  ///
  /// The following properties need to be manually wrapped in [allowInterop]
  /// before being passed to this constructor: [callback], [native_callback],
  /// and [intermediate_iframe_close_callback].
  external factory IdConfiguration({
    required String client_id,
    bool? auto_select,
    CallbackFn? callback,
    Uri? login_uri,
    NativeCallbackFn? native_callback,
    bool? cancel_on_tap_outside,
    String? prompt_parent_id,
    String? nonce,
    String? context,
    String? state_cookie_domain,
    UxMode? ux_mode,
    List<String>? allowed_parent_origin,
    Function? intermediate_iframe_close_callback,
    bool? itp_support,
  });
}

/*
// Method: google.accounts.id.prompt
// https://developers.google.com/identity/gsi/web/reference/js-reference#google.accounts.id.prompt
*/

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
@JS()
external PromptFn get prompt;

/// The type of the [prompt] function.
///
/// The [momentListener] parameter must be manually wrapped in [allowInterop]
/// before being passed to the [prompt] function.
typedef PromptFn = void Function(PromptMomentListenerFn? momentListener);

/// The type of the function that can be passed to [prompt] to listen for [PromptMomentNotification]s.
typedef PromptMomentListenerFn = void Function(PromptMomentNotification moment);

/*
// Data type: PromptMomentNotification
// https://developers.google.com/identity/gsi/web/reference/js-reference#PromptMomentNotification
*/

/// A moment (status) notification from the [prompt] method.
@JS()
@staticInterop
abstract class PromptMomentNotification {}

/// The methods of the [PromptMomentNotification] data type:
extension PromptMomentNotificationExtension on PromptMomentNotification {
  /// Is this notification for a display moment?
  external bool isDisplayMoment();
  /// Is this notification for a display moment, and the UI is displayed?
  external bool isDisplayed();
  /// Is this notification for a display moment, and the UI isn't displayed?
  external bool isNotDisplayed();
  /// The detailed reason why the UI isn't displayed.
  external String getNotDisplayedReason(); // todo: migrate Strings to enum
  /// Is this notification for a skipped moment?
  external bool isSkippedMoment();
  /// The detailed reason for the skipped moment.
  external String getSkippedReason();
  /// Is this notification for a dismissed moment?
  external bool isDismissedMoment();
  /// The detailed reason for the dismissal.
  external String getDismissedReason();
  /// The moment type.
  external String getMomentType();
}

/*
// Data type: CredentialResponse
// https://developers.google.com/identity/gsi/web/reference/js-reference#CredentialResponse
*/

/// The object passed as the parameter of your [CallbackFn].
@JS()
@staticInterop
abstract class CredentialResponse {}

/// The fields that are contained in the credential response object.
extension CredentialResponseExtension on CredentialResponse {
  /// This field is the ID token as a base64-encoded JSON Web Token (JWT)
  /// string.
  ///
  /// See more: https://developers.google.com/identity/gsi/web/reference/js-reference#credential
  external String get credential;
  /// This field sets how the credential was selected.
  ///
  /// The type of button used along with the session and consent state are used
  /// to set the value.
  ///
  /// See more: https://developers.google.com/identity/gsi/web/reference/js-reference#select_by
  external String get select_by; // Convert to enum
}

/// The type of the `callback` used to create an [IdConfiguration].
///
/// Describes a JavaScript function that handles ID tokens from
/// [CredentialResponse]s.
///
/// Google One Tap and the Sign In With Google button popup UX mode use this
/// attribute.
typedef CallbackFn = void Function(CredentialResponse credentialResponse);

/*
// Method: google.accounts.id.renderButton
// https://developers.google.com/identity/gsi/web/reference/js-reference#google.accounts.id.renderButton
//
// Data type: GsiButtonConfiguration
// https://developers.google.com/identity/gsi/web/reference/js-reference#GsiButtonConfiguration
//
// TODO: Implement renderButton and its options?
*/

/*
// Data type: Credential
// https://developers.google.com/identity/gsi/web/reference/js-reference#type-Credential
*/

/// The object passed to the [NativeCallbackFn]. Represents a PasswordCredential
/// that was returned by the Browser.
///
/// `Credential` objects can also be programmatically created to be stored
/// in the browser through the [storeCredential] method.
///
/// See also: https://developer.mozilla.org/en-US/docs/Web/API/PasswordCredential/PasswordCredential
@JS()
@anonymous
@staticInterop
abstract class Credential {
  ///
  external factory Credential({
    required String id,
    required String password,
  });
}

/// The fields that are contained in the [Credential] object.
extension CredentialExtension on Credential {
  /// Identifies the user.
  external String get id;
  /// The password.
  external String get password;
}

/// The type of the `native_callback` used to create an [IdConfiguration].
///
/// Describes a JavaScript function that handles password [Credential]s coming
/// from the native Credential manager of the user's browser.
typedef NativeCallbackFn = void Function(Credential credential);

/*
// Method: google.accounts.id.disableAutoselect
// https://developers.google.com/identity/gsi/web/reference/js-reference#google.accounts.id.disableAutoSelect
*/

/// When the user signs out of your website, you need to call this method to
/// record the status in cookies.
///
/// This prevents a UX dead loop.
@JS()
external VoidFn get disableAutoSelect;

/*
// Method: google.accounts.id.storeCredential
// https://developers.google.com/identity/gsi/web/reference/js-reference#google.accounts.id.storeCredential
*/

/// This method is a simple wrapper for the `store` method of the browser's
/// native credential manager API.
///
/// It can only be used to store a Password [Credential].
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/CredentialsContainer/store
@JS()
external StoreCredentialFn get storeCredential;

/// The type of the [storeCredential] function.
///
/// The [callback] parameter must be manually wrapped in [allowInterop]
/// before being passed to the [storeCredential] function.
// TODO: What's the type of the callback function??? VoidFn?
typedef StoreCredentialFn = void Function(Credential credential, Function? callback);

/*
// Method: google.accounts.id.cancel
// https://developers.google.com/identity/gsi/web/reference/js-reference#google.accounts.id.cancel
*/

/// You can cancel the One Tap flow if you remove the prompt from the relying
/// party DOM. The cancel operation is ignored if a credential is already
/// selected.
@JS()
external VoidFn get cancel;

/*
// Library load callback: onGoogleLibraryLoad
// https://developers.google.com/identity/gsi/web/reference/js-reference#onGoogleLibraryLoad
// See: `load_callback.dart` and `loader.dart`
*/

/*
// Method: google.accounts.id.revoke
// https://developers.google.com/identity/gsi/web/reference/js-reference#google.accounts.id.revoke
*/

/// The `revoke` method revokes the OAuth grant used to share the ID token for
/// the specified user.
@JS()
external RevokeFn get revoke;

/// The type of the [revoke] function.
///
/// [hint] is the email address or unique ID of the user's Google Account. The
/// ID is the `sub` property of the [CredentialResponse.credential] payload.
///
/// The optional [callback] is a function that gets called to report on the
/// success of the revocation call.
///
/// The [callback] parameter must be manually wrapped in [allowInterop]
/// before being passed to the [revoke] function.
typedef RevokeFn = void Function(String hint, RevocationResponseHandlerFn? callback);

/// The type of the `callback` function passed to [revoke], to be notified of
/// the success of the revocation operation.
typedef RevocationResponseHandlerFn = void Function(RevocationResponse revocationResponse);

/*
// Data type: RevocationResponse
// https://developers.google.com/identity/gsi/web/reference/js-reference#RevocationResponse
*/

/// The parameter passed to the optional [RevocationResponseHandlerFn]
/// `callback` of the [revoke] function.
@JS()
@staticInterop
abstract class RevocationResponse {}

/// The fields that are contained in the [RevocationResponse] object.
extension RevocationResponseExtension on RevocationResponse {
  /// This field is a boolean value set to true if the revoke method call
  /// succeeded or false on failure.
  external bool get successful;
  /// This field is a string value and contains a detailed error message if the
  /// revoke method call failed, it is undefined on success.
  external String? get error;
}
