// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// An object containing the data used to request ads from the server.
class AdsRequest {
  /// Creates an [AdsRequest].
  AdsRequest({required this.adTagUrl});

  /// The URL from which ads will be requested.
  final String adTagUrl;
}
