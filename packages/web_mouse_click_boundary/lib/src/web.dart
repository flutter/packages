// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/widgets.dart';

import 'shim/dart_ui.dart' as ui;

const String _static = '__somethingRandom__';
const String _clickable = '__somethingClickable__';

/// The mobile implementation of the MouseClickBoundary widget.
/// A Widget that prevents clicks from being swallowed by HtmlViewElements.
class MouseClickBoundary extends StatelessWidget {
  /// Creates a MouseClickBoundary for the web.
  /// If the underlying viewFactories are not registered yet, it registers them.
  MouseClickBoundary({@required this.child, this.clickable = false, Key key}) : super(key: key) {
    if (!_registered) {
      _register();
    }
  }

  /// The Widget that is being wrapped by this MouseClickBoundary.
  /// It needs to be properly sized (like a Button).
  final Widget child;

  /// The clickability status of the wrapped child. 
  /// This is needed in Web to render the correct mouse cursor on wrapped children.
  final bool clickable;

  // Keeps track if this widget has already registered its view factories or not.
  static bool _registered = false;

  // Registers the view factories for the boundary widgets.
  static void _register() {
    assert(!_registered);
    ui.platformViewRegistry.registerViewFactory(_static,
        (int viewId) {
      final html.Element wrapper = html.DivElement()
        ..style.backgroundColor = 'rgba(255, 0, 255, .5)';

      return wrapper;
    });
    ui.platformViewRegistry.registerViewFactory(_clickable,
        (int viewId) {
      final html.Element wrapper = html.DivElement()
        ..style.cursor = 'pointer'
        ..style.backgroundColor = 'rgba(255, 255, 0, .5)';

      return wrapper;
    });
    _registered = true;
  }

  @override
  Widget build(BuildContext context) {
    final String viewType = clickable ? _clickable : _static;
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
