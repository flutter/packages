// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:local_auth_platform_interface/types/auth_messages.dart';

/// Android side authentication messages.
///
/// Provides default values for all messages.
@immutable
class AndroidAuthMessages extends AuthMessages {
  /// Constructs a new instance.
  const AndroidAuthMessages({
    this.signInHint,
    this.cancelButton,
    this.signInTitle,
  });

  /// Hint message advising the user how to authenticate.
  /// Maximum 60 characters.
  final String? signInHint;

  /// Message shown on a button that the user can click to leave the
  /// current dialog.
  /// Maximum 30 characters.
  final String? cancelButton;

  /// Message shown as a title in a dialog which indicates the user
  /// that they need to scan biometric to continue.
  /// Maximum 60 characters.
  final String? signInTitle;

  @override
  Map<String, String> get args {
    return <String, String>{
      // This legacy key is kept for backwards compatibility.
      'biometricHint': signInHint ?? androidSignInHint,
      'cancelButton': cancelButton ?? androidCancelButton,
      'signInTitle': signInTitle ?? androidSignInTitle,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AndroidAuthMessages &&
          runtimeType == other.runtimeType &&
          signInHint == other.signInHint &&
          cancelButton == other.cancelButton &&
          signInTitle == other.signInTitle;

  @override
  int get hashCode =>
      Object.hash(super.hashCode, signInHint, cancelButton, signInTitle);
}

// Default strings for AndroidAuthMessages. Currently supports English.
// Intl.message must be string literals.

/// Hint message advising the user how to authenticate .
String get androidSignInHint => Intl.message(
  'Verify identity',
  desc:
      'Hint message advising the user how to authenticate. '
      'Maximum 60 characters.',
);

/// Message shown on a button that the user can click to leave the
/// current dialog.
String get androidCancelButton => Intl.message(
  'Cancel',
  desc:
      'Message shown on a button that the user can click to leave the '
      'current dialog. Maximum 30 characters.',
);

/// Message shown as a title in a dialog which indicates the user
/// that they need to scan biometric to continue.
String get androidSignInTitle => Intl.message(
  'Authentication required',
  desc:
      'Message shown as a title in a dialog which indicates the user '
      'that they need to scan biometric to continue. Maximum 60 characters.',
);
