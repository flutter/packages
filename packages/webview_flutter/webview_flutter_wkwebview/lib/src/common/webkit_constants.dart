// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'web_kit.g.dart';

/// Possible error values that WebKit APIs can return.
///
/// See https://developer.apple.com/documentation/webkit/wkerrorcode.
class WKErrorCode {
  WKErrorCode._();

  /// Indicates an unknown issue occurred.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkerrorcode/wkerrorunknown.
  static const int unknown = 1;

  /// Indicates the web process that contains the content is no longer running.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkerrorcode/wkerrorwebcontentprocessterminated.
  static const int webContentProcessTerminated = 2;

  /// Indicates the web view was invalidated.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkerrorcode/wkerrorwebviewinvalidated.
  static const int webViewInvalidated = 3;

  /// Indicates a JavaScript exception occurred.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkerrorcode/wkerrorjavascriptexceptionoccurred.
  static const int javaScriptExceptionOccurred = 4;

  /// Indicates the result of JavaScript execution could not be returned.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkerrorcode/wkerrorjavascriptresulttypeisunsupported.
  static const int javaScriptResultTypeIsUnsupported = 5;
}

/// Keys that may exist in the user info map of `NSError`.
class NSErrorUserInfoKey {
  NSErrorUserInfoKey._();

  /// The corresponding value is a localized string representation of the error
  /// that, if present, will be returned by [NSError.localizedDescription].
  ///
  /// See https://developer.apple.com/documentation/foundation/nslocalizeddescriptionkey.
  static const String NSLocalizedDescription = 'NSLocalizedDescription';

  /// The URL which caused a load to fail.
  ///
  /// See https://developer.apple.com/documentation/foundation/nsurlerrorfailingurlstringerrorkey?language=objc.
  static const String NSURLErrorFailingURLStringError =
      'NSErrorFailingURLStringKey';
}

/// The authentication method used by the receiver.
class NSUrlAuthenticationMethod {
  /// Use the default authentication method for a protocol.
  static const String default_ = 'NSURLAuthenticationMethodDefault';

  /// Use HTML form authentication for this protection space.
  static const String htmlForm = 'NSURLAuthenticationMethodHTMLForm';

  /// Use HTTP basic authentication for this protection space.
  static const String httpBasic = 'NSURLAuthenticationMethodHTTPBasic';

  /// Use HTTP digest authentication for this protection space.
  static const String httpDigest = 'NSURLAuthenticationMethodHTTPDigest';

  /// Use NTLM authentication for this protection space.
  static const String httpNtlm = 'NSURLAuthenticationMethodNTLM';

  /// Perform server trust authentication (certificate validation) for this
  /// protection space.
  static const String serverTrust = 'NSURLAuthenticationMethodServerTrust';
}
