// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:pointer_interceptor_platform_interface/pointer_interceptor_platform_interface.dart';
import 'package:web/web.dart' as web;

/// The web implementation of the `PointerInterceptor` widget.
///
/// A `Widget` that prevents clicks from being swallowed by [HtmlElementView]s.
class PointerInterceptorWeb extends PointerInterceptorPlatform {
  /// Register the plugin
  static void registerWith(Registrar? registrar) {
    PointerInterceptorPlatform.instance = PointerInterceptorWeb();
  }

  // Slightly modify the created `element` (for `debug` mode).
  void _debugOnElementCreated(web.HTMLElement element) {
    element
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.backgroundColor = 'rgba(255, 0, 0, .5)';
  }

  @override
  Widget buildWidget({
    required Widget child,
    bool debug = false,
    bool intercepting = true,
    Key? key,
  }) {
    if (!intercepting) {
      return child;
    }
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Positioned.fill(
          child: HtmlElementView.fromTagName(
            tagName: 'div',
            isVisible: false,
            onElementCreated: (Object element) {
              element as web.HTMLElement;
              if (debug) {
                _debugOnElementCreated(element);
              }

              // Prevent the default action of `mousedown` events to avoid
              // input focus loss.
              element.addEventListener(
                'mousedown',
                (web.Event event) {
                  event.preventDefault();
                }.toJS,
              );
            },
          ),
        ),
        child,
      ],
    );
  }
}
