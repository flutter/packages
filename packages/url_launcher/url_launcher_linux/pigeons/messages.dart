// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  gobjectHeaderOut: 'linux/messages.g.h',
  gobjectSourceOut: 'linux/messages.g.cc',
  gobjectOptions: GObjectOptions(module: 'Ful'),
  copyrightHeader: 'pigeons/copyright.txt',
))
@HostApi()
abstract class UrlLauncherApi {
  /// Returns true if the URL can definitely be launched.
  bool canLaunchUrl(String url);

  /// Opens the URL externally, returning an error string on failure.
  String? launchUrl(String url);
}
