// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui_web' as ui_web;

import 'package:flutter/foundation.dart' show kDebugMode, visibleForTesting;
import 'package:flutter_web_plugins/flutter_web_plugins.dart' show Registrar;
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:web/web.dart' as html;

import 'src/link.dart';

const Set<String> _safariTargetTopSchemes = <String>{
  'mailto',
  'tel',
  'sms',
};
String? _getUrlScheme(String url) => Uri.tryParse(url)?.scheme;

bool _isSafariTargetTopScheme(String? scheme) =>
    _safariTargetTopSchemes.contains(scheme);

// The set of schemes that are explicitly disallowed by the plugin.
const Set<String> _disallowedSchemes = <String>{
  'javascript',
};
bool _isDisallowedScheme(String? scheme) => _disallowedSchemes.contains(scheme);

bool _navigatorIsSafari(html.Navigator navigator) =>
    navigator.userAgent.contains('Safari') &&
    !navigator.userAgent.contains('Chrome');

/// The web implementation of [UrlLauncherPlatform].
///
/// This class implements the `package:url_launcher` functionality for the web.
class UrlLauncherPlugin extends UrlLauncherPlatform {
  /// A constructor that allows tests to override the window object used by the plugin.
  UrlLauncherPlugin({@visibleForTesting html.Window? debugWindow})
      : _window = debugWindow ?? html.window {
    _isSafari = _navigatorIsSafari(_window.navigator);
  }

  final html.Window _window;
  bool _isSafari = false;

  // The set of schemes that can be handled by the plugin.
  static final Set<String> _supportedSchemes = <String>{
    'http',
    'https',
  }.union(_safariTargetTopSchemes);

  /// Registers this class as the default instance of [UrlLauncherPlatform].
  static void registerWith(Registrar registrar) {
    UrlLauncherPlatform.instance = UrlLauncherPlugin();
    ui_web.platformViewRegistry
        .registerViewFactory(linkViewType, linkViewFactory, isVisible: false);
  }

  @override
  LinkDelegate get linkDelegate {
    return (LinkInfo linkInfo) => WebLinkDelegate(linkInfo);
  }

  /// Opens the given [url] in the specified [webOnlyWindowName].
  ///
  /// Always returns `true`, except for disallowed schemes. Because `noopener`
  /// is used as a window feature, it can not be detected if the window was
  /// opened successfully.
  /// See https://html.spec.whatwg.org/multipage/nav-history-apis.html#window-open-steps.
  @visibleForTesting
  bool openNewWindow(String url, {String? webOnlyWindowName}) {
    final String? scheme = _getUrlScheme(url);
    // Actively disallow opening some schemes, like javascript.
    // See https://github.com/flutter/flutter/issues/136657
    if (_isDisallowedScheme(scheme)) {
      if (kDebugMode) {
        print('Disallowed URL with scheme: $scheme');
      }
      return false;
    }
    // Some schemes need to be opened on the _top window context on Safari.
    // See https://github.com/flutter/flutter/issues/51461
    final String target = webOnlyWindowName ??
        ((_isSafari && _isSafariTargetTopScheme(scheme)) ? '_top' : '');

    _window.open(url, target, 'noopener,noreferrer');

    return true;
  }

  @override
  Future<bool> canLaunch(String url) {
    return Future<bool>.value(_supportedSchemes.contains(_getUrlScheme(url)));
  }

  @override
  Future<bool> launch(
    String url, {
    bool useSafariVC = false,
    bool useWebView = false,
    bool enableJavaScript = false,
    bool enableDomStorage = false,
    bool universalLinksOnly = false,
    Map<String, String> headers = const <String, String>{},
    String? webOnlyWindowName,
  }) async {
    return launchUrl(url, LaunchOptions(webOnlyWindowName: webOnlyWindowName));
  }

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    final String? windowName = options.webOnlyWindowName;
    return openNewWindow(url, webOnlyWindowName: windowName);
  }

  @override
  Future<bool> supportsMode(PreferredLaunchMode mode) async {
    // Web doesn't allow any control over the destination beyond
    // webOnlyWindowName, so don't claim support for any mode beyond default.
    return mode == PreferredLaunchMode.platformDefault;
  }

  @override
  Future<bool> supportsCloseForMode(PreferredLaunchMode mode) async {
    // No supported mode is closeable.
    return false;
  }
}
