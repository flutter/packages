// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

/// The mobile implementation of the PointerInterceptor widget.
/// A Widget that prevents clicks from being swallowed by HtmlViewElements.
class PointerInterceptor extends StatelessWidget {
  /// Create a `PointerInterceptor` around a `child`.
  const PointerInterceptor({@required this.child, this.debug = false, Key key}) : super(key: key);

  /// The Widget that is being wrapped by this PointerInterceptor.
  /// It needs to be properly sized (like a Button).
  final Widget child;

  /// Render the view with a semi-transparent red background, for debug purposes.
  /// This is useful when rendering this as a "layout" widget, like the root element
  /// of a sidebar.
  final bool debug;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
