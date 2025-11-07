// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Defines the over-scroll behavior of a WebView.
enum WebViewOverScrollMode {
  /// Always allow a user to over-scroll the WebView.
  always,

  /// Allow a user to over-scroll the WebView only if the content is larger than
  /// the viewport.
  ifContentScrolls,

  /// Never allow a user to over-scroll the WebView.
  never,
}
