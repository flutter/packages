// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// Defines the parameters of the web resource request from the associated response.
@immutable
class WebResourceRequest {
  /// Used by the platform implementation to create a new [WebResourceRequest].
  const WebResourceRequest({
    required this.url,
    required this.isForMainFrame
  });

  /// The URL for which the resource request was made.
  final String url;

  /// Indicates whether the request was made in the web site's main frame or a subframe.
  final bool isForMainFrame;
}
