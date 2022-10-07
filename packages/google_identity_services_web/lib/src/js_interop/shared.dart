// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Attempts to retrieve an enum value from [haystack] if [needle] is not null.
T? maybeEnum<T extends Enum>(String? needle, List<T> haystack) {
  if (needle == null) {
    return null;
  }
  return haystack.byName(needle);
}

/// The type of several functions from the library, that don't receive
/// parameters nor return anything.
typedef VoidFn = void Function();

/*
// Enum: UX Mode
// https://developers.google.com/identity/gsi/web/reference/js-reference#ux_mode
// Used both by `oauth2.initCodeClient` and `id.initialize`.
*/

/// Use this enum to set the UX flow used by the Sign In With Google button.
/// The default value is [popup].
///
/// This attribute has no impact on the OneTap UX.
enum UxMode {
  /// Performs sign-in UX flow in a pop-up window.
  popup('popup'),

  /// Performs sign-in UX flow by a full page redirection.
  redirect('redirect');

  ///
  const UxMode(String uxMode) : _uxMode = uxMode;
  final String _uxMode;

  @override
  String toString() => _uxMode;
}

/// Changes the text of the title and messages in the One Tap prompt.
enum OneTapContext {
  /// "Sign in with Google"
  signin('signin'),

  /// "Sign up with Google"
  signup('signup'),

  /// "Use with Google"
  use('use');

  ///
  const OneTapContext(String context) : _context = context;
  final String _context;

  @override
  String toString() => _context;
}

/// The detailed reason why the OneTap UI isn't displayed.
enum MomentNotDisplayedReason {
  /// Browser not supported.
  ///
  /// See https://developers.google.com/identity/gsi/web/guides/supported-browsers
  browser_not_supported('browser_not_supported'),

  /// Invalid Client.
  ///
  /// See https://developers.google.com/identity/gsi/web/guides/get-google-api-clientid
  invalid_client('invalid_client'),

  /// Missing client_id.
  ///
  /// See https://developers.google.com/identity/gsi/web/guides/get-google-api-clientid
  missing_client_id('missing_client_id'),

  /// The user has opted out, or they aren't signed in to a Google account.
  ///
  /// https://developers.google.com/identity/gsi/web/guides/features
  opt_out_or_no_session('opt_out_or_no_session'),

  /// Google One Tap can only be displayed in HTTPS domains.
  ///
  /// See https://developers.google.com/identity/gsi/web/guides/get-google-api-clientid
  secure_http_required('secure_http_required'),

  /// The user has previously closed the OneTap card.
  ///
  /// See https://developers.google.com/identity/gsi/web/guides/features#exponential_cooldown
  suppressed_by_user('suppressed_by_user'),

  /// The current `origin` is not associated with the Client ID.
  ///
  /// See https://developers.google.com/identity/gsi/web/guides/get-google-api-clientid
  unregistered_origin('unregistered_origin'),

  /// Unknown reason
  unknown_reason('unknown_reason');

  ///
  const MomentNotDisplayedReason(String reason) : _reason = reason;
  final String _reason;

  @override
  String toString() => _reason;
}

/// The detailed reason for the skipped moment.
enum MomentSkippedReason {
  /// auto_cancel
  auto_cancel('auto_cancel'),

  /// user_cancel
  user_cancel('user_cancel'),

  /// tap_outside
  tap_outside('tap_outside'),

  /// issuing_failed
  issuing_failed('issuing_failed');

  ///
  const MomentSkippedReason(String reason) : _reason = reason;
  final String _reason;

  @override
  String toString() => _reason;
}

/// The detailed reason for the dismissal.
enum MomentDismissedReason {
  /// credential_returned
  credential_returned('credential_returned'),

  /// cancel_called
  cancel_called('cancel_called'),

  /// flow_restarted
  flow_restarted('flow_restarted');

  ///
  const MomentDismissedReason(String reason) : _reason = reason;
  final String _reason;

  @override
  String toString() => _reason;
}

/// The moment type.
enum MomentType {
  /// Display moment
  display('display'),

  /// Skipped moment
  skipped('skipped'),

  /// Dismissed moment
  dismissed('dismissed');

  ///
  const MomentType(String type) : _type = type;
  final String _type;

  @override
  String toString() => _type;
}

/// Represents how a credential was selected.
enum CredentialSelectBy {
  /// Automatic sign-in of a user with an existing session who had previously
  /// granted consent to share credentials.
  auto('auto'),

  /// A user with an existing session who had previously granted consent
  /// pressed the One Tap 'Continue as' button to share credentials.
  user('user'),

  /// A user with an existing session pressed the One Tap 'Continue as' button
  /// to grant consent and share credentials. Applies only to Chrome v75 and
  /// higher.
  user_1tap('user_1tap'),

  /// A user without an existing session pressed the One Tap 'Continue as'
  /// button to select an account and then pressed the Confirm button in a
  /// pop-up window to grant consent and share credentials. Applies to
  /// non-Chromium based browsers.
  user_2tap('user_2tap'),

  /// A user with an existing session who previously granted consent pressed
  /// the Sign In With Google button and selected a Google Account from
  /// 'Choose an Account' to share credentials.
  btn('btn'),

  /// A user with an existing session pressed the Sign In With Google button
  /// and pressed the Confirm button to grant consent and share credentials.
  btn_confirm('btn_confirm'),

  /// A user without an existing session who previously granted consent
  /// pressed the Sign In With Google button to select a Google Account and
  /// share credentials.
  btn_add_session('btn_add_session'),

  /// A user without an existing session first pressed the Sign In With Google
  /// button to select a Google Account and then pressed the Confirm button to
  /// consent and share credentials.
  btn_confirm_add_session('btn_confirm_add_session');

  ///
  const CredentialSelectBy(String selectBy) : _selectBy = selectBy;
  final String _selectBy;

  @override
  String toString() => _selectBy;
}
