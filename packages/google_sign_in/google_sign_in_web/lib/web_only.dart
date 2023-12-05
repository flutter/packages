// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// This library exposes web-only methods of [GoogleSignInPlatform.instance].
///
/// The exported methods will assert that the [GoogleSignInPlatform.instance]
/// is an instance of class [GoogleSignInPlugin] (the web implementation of
/// `google_sign_in` provided by this package).
library web_only;

import 'package:flutter/widgets.dart' show Widget;
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart'
    show GoogleSignInPlatform;

import 'google_sign_in_web.dart' show GoogleSignInPlugin;
import 'src/button_configuration.dart' show GSIButtonConfiguration;

// Export the configuration types for the renderButton method.
export 'src/button_configuration.dart'
    show
        GSIButtonConfiguration,
        GSIButtonLogoAlignment,
        GSIButtonShape,
        GSIButtonSize,
        GSIButtonText,
        GSIButtonTheme,
        GSIButtonType;

// Asserts that the instance of the platform is for the web.
GoogleSignInPlugin get _plugin {
  assert(GoogleSignInPlatform.instance is GoogleSignInPlugin,
      'The current GoogleSignInPlatform instance is not for web.');

  return GoogleSignInPlatform.instance as GoogleSignInPlugin;
}

/// Render the GIS Sign-In Button widget with [configuration].
Widget renderButton({GSIButtonConfiguration? configuration}) {
  return _plugin.renderButton(configuration: configuration);
}

/// Requests server auth code from the GIS Client.
///
/// See: https://developers.google.com/identity/oauth2/web/guides/use-code-model
Future<String?> requestServerAuthCode() async {
  return _plugin.requestServerAuthCode();
}
