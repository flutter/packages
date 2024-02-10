// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:local_auth_platform_interface/types/auth_messages.dart';

import 'constant_auth_messages.dart';

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
      'lockOut': lockOut ?? lockOutMessage,
      'goToSetting': goToSettingsButton ?? goToSettingsMessage,
      'goToSettingDescriptionMacOS':
          goToSettingsDescription ?? goToSettingsDescriptionMessage,
      'okButton': cancelButton ?? okButtonMessage,
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
