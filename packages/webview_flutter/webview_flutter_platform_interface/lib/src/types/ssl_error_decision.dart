// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A decision on how to handle an SSL error
enum SslErrorDecision {
  /// Prevent the request
  cancel,

  /// Proceed with the request
  proceed,
}
