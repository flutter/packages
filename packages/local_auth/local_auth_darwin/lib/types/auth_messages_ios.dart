// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:local_auth_platform_interface/types/auth_messages.dart';

/// Class wrapping all authentication messages needed on iOS.
/// Provides default values for all messages.
@immutable
class IOSAuthMessages extends AuthMessages {
  /// Constructs a new instance.
  const IOSAuthMessages({this.cancelButton, this.localizedFallbackTitle});

  /// Message shown on a button that the user can click to leave the current
  /// dialog.
  /// Maximum 30 characters.
  final String? cancelButton;

  /// The localized title for the fallback button in the dialog presented to
  /// the user during authentication.
  ///
  /// Set this to an empty string to hide the fallback button.
  final String? localizedFallbackTitle;

  @override
  Map<String, String> get args {
    return <String, String>{
      'okButton': cancelButton ?? iOSCancelButton,
      if (localizedFallbackTitle != null)
        'localizedFallbackTitle': localizedFallbackTitle!,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IOSAuthMessages &&
          runtimeType == other.runtimeType &&
          cancelButton == other.cancelButton &&
          localizedFallbackTitle == other.localizedFallbackTitle;

  @override
  int get hashCode =>
      Object.hash(super.hashCode, cancelButton, localizedFallbackTitle);
}

// Default Strings for IOSAuthMessages plugin. Currently supports English.
// Intl.message must be string literals.

/// Message shown on a button that the user can click to leave the current
/// dialog.
String get iOSCancelButton => Intl.message(
  'OK',
  desc:
      'Message showed on a button that the user can click to leave the '
      'current dialog. Maximum 30 characters.',
);
