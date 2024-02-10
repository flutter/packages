// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:intl/intl.dart';

// Default Strings for IOSAuthMessages and MacOSAuthMessages plugin.
// Currently supports English. Intl.message must be string literals.

/// Message shown on a button that the user can click to go to settings pages
/// from the current dialog.
String get goToSettingsMessage {
  return Intl.message(
    'Go to settings',
    desc: 'Message shown on a button that the user can click to go to '
        'settings pages from the current dialog. Maximum 30 characters.',
  );
}

/// Message advising the user to re-enable biometrics on their device.
/// It shows in a dialog on macOS.
String get lockOutMessage {
  return Intl.message(
    'Biometric authentication is disabled. Please lock and unlock your screen '
    'to enable it.',
    desc: 'Message advising the user to re-enable biometrics on their device.',
  );
}

/// Message advising the user to go to the settings and configure Biometrics
/// for their device.
String get goToSettingsDescriptionMessage {
  return Intl.message(
    'Biometric authentication is not set up on your device. Please either '
    'enable Touch ID or Face ID on your device.',
    desc: 'Message advising the user to go to the settings and configure '
        'Biometrics for their device.',
  );
}

/// Message shown on a button that the user can click to leave the current
/// dialog.
String get okButtonMessage {
  return Intl.message(
    'OK',
    desc: 'Message showed on a button that the user can click to leave the '
        'current dialog. Maximum 30 characters.',
  );
}
