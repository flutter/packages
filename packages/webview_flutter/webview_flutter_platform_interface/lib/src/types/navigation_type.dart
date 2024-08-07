// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// An object that contains information about an action that causes navigation
/// to occur.
enum NavigationType {
  /// A link activation.
  ///
  /// See [WKNavigationType.linkActivated]
  linkActivated,

  /// A request to submit a form.
  ///
  /// See [WKNavigationType.linkActivated]
  submitted,

  /// A request for the frame’s next or previous item.
  ///
  /// See [WKNavigationType.linkActivated]
  backForward,

  /// A request to reload the webpage.
  ///
  /// See [WKNavigationType.linkActivated]
  reload,

  /// A request to resubmit a form.
  ///
  /// See [WKNavigationType.linkActivated]
  formResubmitted,

  /// A navigation request that originates for some other reason.
  ///
  /// See [WKNavigationType.other]
  other,

  /// An unknown navigation type (default value for non-wkwebview).
  ///
  /// See [WKNavigationType.unknown]
  unknown,
}
