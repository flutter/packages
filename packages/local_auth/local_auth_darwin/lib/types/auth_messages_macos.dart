// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:local_auth_platform_interface/types/auth_messages.dart';

/// Class wrapping all authentication messages needed on macOS.
/// Provides default values for all messages.
@immutable
class MacOSAuthMessages extends AuthMessages {
  /// Constructs a new instance.
  const MacOSAuthMessages({
    this.lockOut,
    this.goToSettingsButton,
    this.goToSettingsDescription,
    this.cancelButton,
    this.localizedFallbackTitle,
  });

  /// Message advising the user to re-enable biometrics on their device.
  final String? lockOut;

  /// Message shown on a button that the user can click to go to settings pages
  /// from the current dialog.
  /// Maximum 30 characters.
  final String? goToSettingsButton;

  /// Message advising the user to go to the settings and configure Biometrics
  /// for their device.
  final String? goToSettingsDescription;

  /// Message shown on a button that the user can click to leave the current
  /// dialog.
  /// Maximum 30 characters.
  final String? cancelButton;

  /// The localized title for the fallback button in the dialog presented to
  /// the user during authentication.
  final String? localizedFallbackTitle;

  @override
  Map<String, String> get args {
    return <String, String>{
      'lockOut': lockOut ?? macOSLockOut,
      'goToSetting': goToSettingsButton ?? macOSGoToSettings,
      'goToSettingDescriptionMacOS':
          goToSettingsDescription ?? macOSGoToSettingsDescription,
      'okButton': cancelButton ?? macOSOkButton,
      if (localizedFallbackTitle != null)
        'localizedFallbackTitle': localizedFallbackTitle!,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MacOSAuthMessages &&
          runtimeType == other.runtimeType &&
          lockOut == other.lockOut &&
          goToSettingsButton == other.goToSettingsButton &&
          goToSettingsDescription == other.goToSettingsDescription &&
          cancelButton == other.cancelButton &&
          localizedFallbackTitle == other.localizedFallbackTitle;

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        lockOut,
        goToSettingsButton,
        goToSettingsDescription,
        cancelButton,
        localizedFallbackTitle,
      );
}

// Default Strings for MacOSAuthMessages plugin. Currently supports English.
// Intl.message must be string literals.

/// Message shown on a button that the user can click to go to settings pages
/// from the current dialog.
String get macOSGoToSettings => Intl.message('Go to settings',
    desc: 'Message shown on a button that the user can click to go to '
        'settings pages from the current dialog. Maximum 30 characters.');

/// Message advising the user to re-enable biometrics on their device.
/// It shows in a dialog on macOS.
String get macOSLockOut => Intl.message(
    'Biometric authentication is disabled. Please restart your computer and try again.',
    desc: 'Message advising the user to re-enable biometrics on their device.');

/// Message advising the user to go to the settings and configure Biometrics
/// for their device.
String get macOSGoToSettingsDescription => Intl.message(
    'Biometric authentication is not set up on your device. Please enable '
    'Touch ID on your computer in the Settings app.',
    desc:
        'Message advising the user to go to the settings and configure Biometrics '
        'for their device.');

/// Message shown on a button that the user can click to leave the current
/// dialog.
String get macOSOkButton => Intl.message('OK',
    desc: 'Message showed on a button that the user can click to leave the '
        'current dialog. Maximum 30 characters.');
