// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/widgets.dart';

import 'shim/dart_ui.dart' as ui;

const String _viewType = '__webPointerInterceptorViewType__';
const String _debug = 'debug__';

String _getViewType({bool debug = false}) {
  return debug ? _viewType + _debug : _viewType;
}

void _registerWrapper({bool debug = false}) {
  final String viewType = _getViewType(debug: debug);

  ui.platformViewRegistry.registerViewFactory(viewType,
      (int viewId) {
    final html.Element wrapper = html.DivElement();
    if (debug) {
      wrapper.style.backgroundColor = 'rgba(255, 0, 0, .5)';
    }
    return wrapper;
  });
}

/// The mobile implementation of the PointerInterceptor widget.
/// A Widget that prevents clicks from being swallowed by HtmlViewElements.
class PointerInterceptor extends StatelessWidget {
  /// Creates a PointerInterceptor for the web.
  /// If the underlying viewFactories are not registered yet, it registers them.
  PointerInterceptor({@required this.child, this.debug = false, Key key}) : super(key: key) {
    if (!_registered) {
      _register();
    }
  }

  /// The Widget that is being wrapped by this PointerInterceptor.
  /// It needs to be properly sized (like a Button).
  final Widget child;

  /// Render the view with a semi-transparent red background, for debug purposes.
  /// This is useful when rendering this as a "layout" widget, like the root child
  /// of a sidebar.
  final bool debug;

  // Keeps track if this widget has already registered its view factories or not.
  static bool _registered = false;

  // Registers the view factories for the boundary widgets.
  static void _register() {
    assert(!_registered);

    _registerWrapper();
    _registerWrapper(debug: true);

    _registered = true;
  }

  @override
  Widget build(BuildContext context) {
    final String viewType = _getViewType(debug: debug);
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: HtmlElementView(viewType: viewType,),
        ),
        child,
      ],
    );
  }
}
