// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  swiftOut: 'ios/url_launcher_ios/Sources/url_launcher_ios/messages.g.swift',
  copyrightHeader: 'pigeons/copyright.txt',
))

/// Possible outcomes of launching a URL.
enum LaunchResult {
  /// The URL was successfully launched (or could be, for `canLaunchUrl`).
  success,

  /// There was no handler available for the URL.
  failure,

  /// The URL could not be launched because it is invalid.
  invalidUrl,
}

/// Possible outcomes of handling a URL within the application.
enum InAppLoadResult {
  /// The URL was successfully loaded.
  success,

  /// The URL did not load successfully.
  failedToLoad,

  /// The URL could not be launched because it is invalid.
  invalidUrl,
}

@HostApi()
abstract class UrlLauncherApi {
  /// Checks whether a URL can be loaded.
  @ObjCSelector('canLaunchURL:')
  LaunchResult canLaunchUrl(String url);

  /// Opens the URL externally, returning the status of launching it.
  @async
  @ObjCSelector('launchURL:universalLinksOnly:')
  LaunchResult launchUrl(String url, bool universalLinksOnly);

  /// Opens the URL in an in-app SFSafariViewController, returning the results
  /// of loading it.
  @async
  @ObjCSelector('openSafariViewControllerWithURL:')
  InAppLoadResult openUrlInSafariViewController(String url);

  /// Closes the view controller opened by [openUrlInSafariViewController].
  void closeSafariViewController();
}
