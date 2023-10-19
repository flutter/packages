// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  swiftOut: 'ios/Classes/messages.g.swift',
  copyrightHeader: 'pigeons/copyright.txt',
))

/// Possible outcomes of launching a URL.
enum LaunchResult {
  /// The URL was successfully launched.
  success,

  /// The URL could not be launched
  failedToLoad,

  /// The URL was not launched because it is not invalid URL
  invalidUrl,
}

@HostApi()
abstract class UrlLauncherApi {
  /// Returns true if the URL can definitely be launched.
  @ObjCSelector('canLaunchURL:')
  LaunchResult canLaunchUrl(String url);

  /// Opens the URL externally, returning true if successful.
  @async
  @ObjCSelector('launchURL:universalLinksOnly:')
  LaunchResult launchUrl(String url, bool universalLinksOnly);

  /// Opens the URL in an in-app SFSafariViewController, returning true
  /// when it has loaded successfully.
  @async
  @ObjCSelector('openSafariViewControllerWithURL:')
  LaunchResult openUrlInSafariViewController(String url);

  /// Closes the view controller opened by [openUrlInSafariViewController].
  void closeSafariViewController();
}
