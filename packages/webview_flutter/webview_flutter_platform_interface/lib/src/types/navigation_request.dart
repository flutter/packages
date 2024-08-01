// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'navigation_type.dart';

/// Defines the parameters of the pending navigation callback.
class NavigationRequest {
  /// Creates a [NavigationRequest].
  const NavigationRequest({
    required this.url,
    required this.isMainFrame,
    required this.navigationType,
  });

  /// The URL of the pending navigation request.
  final String url;

  /// Indicates whether the request was made in the web site's main frame or a subframe.
  final bool isMainFrame;

  /// An object that contains information about an action that causes navigation
  /// to occur.
  final NavigationType navigationType;
}
