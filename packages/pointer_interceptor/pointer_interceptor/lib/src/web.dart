// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import '../pointer_interceptor.dart';

const String _viewType = '__webPointerInterceptorViewType__';
const String _debug = 'debug__';

// Computes a "view type" for different configurations of the widget.
String _getViewType({bool debug = false}) {
  return debug ? _viewType + _debug : _viewType;
}

/// The web implementation of the `PointerInterceptor` widget.
///
/// A `Widget` that prevents clicks from being swallowed by [HtmlElementView]s.
class PointerInterceptor extends PointerInterceptorPlatform {
  /// Register the plugin
  static void registerWith() {
    PointerInterceptorPlatform.instance = PointerInterceptor();
  }

  @override
  Widget buildWidget(
      {required Widget child,
        bool intercepting = true,
        bool debug = false,
        Key? key}) {

    final String viewType = _getViewType(debug: debug);

    if (!intercepting) {
      return child;
    }

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Positioned.fill(
          child: HtmlElementView(
            viewType: viewType,
          ),
        ),
        child,
      ],
    );
  }
}
