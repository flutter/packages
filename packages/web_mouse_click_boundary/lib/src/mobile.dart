// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

/// The mobile implementation of the MouseClickBoundary widget.
/// A Widget that prevents clicks from being swallowed by HtmlViewElements.
class MouseClickBoundary extends StatelessWidget {
  /// Create a `MouseClickBoundary` around a `child`.
  const MouseClickBoundary({@required this.child, this.clickable = false, Key key}) : super(key: key);

  /// The Widget that is being wrapped by this MouseClickBoundary.
  /// It needs to be properly sized (like a Button).
  final Widget child;

  /// The clickability status of the wrapped child. 
  /// This is needed in Web to render the correct mouse cursor on wrapped children.
  final bool clickable;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
