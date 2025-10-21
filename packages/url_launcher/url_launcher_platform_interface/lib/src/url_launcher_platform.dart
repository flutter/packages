// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../link.dart';
import '../method_channel_url_launcher.dart';
import '../url_launcher_platform_interface.dart';
import 'types.dart';

/// The interface that implementations of url_launcher must implement.
///
/// Platform implementations should extend this class rather than implement it as `url_launcher`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [UrlLauncherPlatform] methods.
abstract class UrlLauncherPlatform extends PlatformInterface {
  /// Constructs a UrlLauncherPlatform.
  UrlLauncherPlatform() : super(token: _token);

  static final Object _token = Object();

  static UrlLauncherPlatform _instance = MethodChannelUrlLauncher();

  /// The default instance of [UrlLauncherPlatform] to use.
  ///
  /// Defaults to [MethodChannelUrlLauncher].
  static UrlLauncherPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [UrlLauncherPlatform] when they register themselves.
  // TODO(amirh): Extract common platform interface logic.
  // https://github.com/flutter/flutter/issues/43368
  static set instance(UrlLauncherPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// The delegate used by the Link widget to build itself.
  LinkDelegate? get linkDelegate;

  /// Returns `true` if this platform is able to launch [url].
  Future<bool> canLaunch(String url) {
    throw UnimplementedError('canLaunch() has not been implemented.');
  }

  /// Passes [url] to the underlying platform for handling.
  ///
  /// Returns `true` if the given [url] was successfully launched.
  ///
  /// For documentation on the other arguments, see the `launch` documentation
  /// in `package:url_launcher/url_launcher.dart`.
  Future<bool> launch(
    String url, {
    required bool useSafariVC,
    required bool useWebView,
    required bool enableJavaScript,
    required bool enableDomStorage,
    required bool universalLinksOnly,
    required Map<String, String> headers,
    String? webOnlyWindowName,
  }) {
    throw UnimplementedError('launch() has not been implemented.');
  }

  /// Passes [url] to the underlying platform for handling.
  ///
  /// Returns `true` if the given [url] was successfully launched.
  Future<bool> launchUrl(String url, LaunchOptions options) {
    final bool isWebURL = url.startsWith('http:') || url.startsWith('https:');
    final bool useWebView =
        options.mode == PreferredLaunchMode.inAppWebView ||
        options.mode == PreferredLaunchMode.inAppBrowserView ||
        (isWebURL && options.mode == PreferredLaunchMode.platformDefault);

    return launch(
      url,
      useSafariVC: useWebView,
      useWebView: useWebView,
      enableJavaScript: options.webViewConfiguration.enableJavaScript,
      enableDomStorage: options.webViewConfiguration.enableDomStorage,
      universalLinksOnly:
          options.mode == PreferredLaunchMode.externalNonBrowserApplication,
      headers: options.webViewConfiguration.headers,
      webOnlyWindowName: options.webOnlyWindowName,
    );
  }

  /// Closes the web view, if one was opened earlier by [launchUrl].
  ///
  /// This will only work if the launch mode (the actual launch mode used,
  /// not the requested launch mode, which may not match if [supportsMode] is
  /// false for the requested mode) was one for which [supportsCloseForMode]
  /// returns true.
  Future<void> closeWebView() {
    throw UnimplementedError('closeWebView() has not been implemented.');
  }

  /// Returns true if the given launch mode is supported by the current
  /// implementation.
  ///
  /// Clients are not required to query this, as implementations are strongly
  /// encouraged to automatically fall back to other modes if a launch is
  /// requested using an unsupported mode (matching historical behavior of the
  /// plugin, and thus maximizing compatibility with existing code).
  Future<bool> supportsMode(PreferredLaunchMode mode) {
    return Future<bool>.value(mode == PreferredLaunchMode.platformDefault);
  }

  /// Returns true if the given launch mode can be closed with [closeWebView].
  Future<bool> supportsCloseForMode(PreferredLaunchMode mode) {
    // This is the historical documented behavior, so default to that for
    // compatibility.
    return Future<bool>.value(mode == PreferredLaunchMode.inAppWebView);
  }
}
