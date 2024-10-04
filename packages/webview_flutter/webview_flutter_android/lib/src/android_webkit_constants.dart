// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'android_webkit.g.dart';

/// Class constants for [PermissionRequest].
///
/// Since the Dart [PermissionRequest] is generated, the constants for the class
/// are added here.
class PermissionRequestConstants {
  /// Resource belongs to audio capture device, like microphone.
  ///
  /// See https://developer.android.com/reference/android/webkit/PermissionRequest#RESOURCE_AUDIO_CAPTURE.
  static const String audioCapture = 'android.webkit.resource.AUDIO_CAPTURE';

  /// Resource will allow sysex messages to be sent to or received from MIDI
  /// devices.
  ///
  /// See https://developer.android.com/reference/android/webkit/PermissionRequest#RESOURCE_MIDI_SYSEX.
  static const String midiSysex = 'android.webkit.resource.MIDI_SYSEX';

  /// Resource belongs to video capture device, like camera.
  ///
  /// See https://developer.android.com/reference/android/webkit/PermissionRequest#RESOURCE_VIDEO_CAPTURE.
  static const String videoCapture = 'android.webkit.resource.VIDEO_CAPTURE';

  /// Resource belongs to protected media identifier.
  ///
  /// See https://developer.android.com/reference/android/webkit/PermissionRequest#RESOURCE_VIDEO_CAPTURE.
  static const String protectedMediaId =
      'android.webkit.resource.PROTECTED_MEDIA_ID';
}

/// Class constants for [WebViewClient].
///
/// Since the Dart [WebViewClient] is generated, the constants for the class
/// are added here.
class WebViewClientConstants {
  /// User authentication failed on server.
  ///
  /// See https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_AUTHENTICATION
  static const int errorAuthentication = -4;

  /// Malformed URL.
  ///
  /// See https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_BAD_URL
  static const int errorBadUrl = -12;

  /// Failed to connect to the server.
  ///
  /// See https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_CONNECT
  static const int errorConnect = -6;

  /// Failed to perform SSL handshake.
  ///
  /// See https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_FAILED_SSL_HANDSHAKE
  static const int errorFailedSslHandshake = -11;

  /// Generic file error.
  ///
  /// See https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_FILE
  static const int errorFile = -13;

  /// File not found.
  ///
  /// See https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_FILE_NOT_FOUND
  static const int errorFileNotFound = -14;

  /// Server or proxy hostname lookup failed.
  ///
  /// See https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_HOST_LOOKUP
  static const int errorHostLookup = -2;

  /// Failed to read or write to the server.
  ///
  /// See https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_IO
  static const int errorIO = -7;

  /// User authentication failed on proxy.
  ///
  /// See https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_PROXY_AUTHENTICATION
  static const int errorProxyAuthentication = -5;

  /// Too many redirects.
  ///
  /// See https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_REDIRECT_LOOP
  static const int errorRedirectLoop = -9;

  /// Connection timed out.
  ///
  /// See https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_TIMEOUT
  static const int errorTimeout = -8;

  /// Too many requests during this load.
  ///
  /// See https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_TOO_MANY_REQUESTS
  static const int errorTooManyRequests = -15;

  /// Generic error.
  ///
  /// See https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_UNKNOWN
  static const int errorUnknown = -1;

  /// Resource load was canceled by Safe Browsing.
  ///
  /// See https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_UNSAFE_RESOURCE
  static const int errorUnsafeResource = -16;

  /// Unsupported authentication scheme (not basic or digest).
  ///
  /// See https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_UNSUPPORTED_AUTH_SCHEME
  static const int errorUnsupportedAuthScheme = -3;

  /// Unsupported URI scheme.
  ///
  /// See https://developer.android.com/reference/android/webkit/WebViewClient#ERROR_UNSUPPORTED_SCHEME
  static const int errorUnsupportedScheme = -10;
}
