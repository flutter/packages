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
  failure,

  /// The URL was not launched because it is not invalid URL
  invalidUrl,

  /// The URL did not load successfully in the SFSafariViewController.
  failedToLoad,
}

class LaunchResultDetails {
  LaunchResultDetails({
    required this.result,
    this.errorMessage,
    this.errorDetails,
  });

  /// The result of the launch attempt.
  final LaunchResult result;

  /// A system-provided error message, if any.
  final String? errorMessage;

  /// A system-provided error details, if any.
  final String? errorDetails;
}

@HostApi()
abstract class UrlLauncherApi {
  /// Returns true if the URL can definitely be launched.
  @ObjCSelector('canLaunchURL:')
  LaunchResultDetails canLaunchUrl(String url);

  /// Opens the URL externally, returning true if successful.
  @async
  @ObjCSelector('launchURL:universalLinksOnly:')
  LaunchResultDetails launchUrl(String url, bool universalLinksOnly);

  /// Opens the URL in an in-app SFSafariViewController, returning true
  /// when it has loaded successfully.
  @async
  @ObjCSelector('openSafariViewControllerWithURL:')
  LaunchResultDetails openUrlInSafariViewController(String url);

  /// Closes the view controller opened by [openUrlInSafariViewController].
  void closeSafariViewController();
}
