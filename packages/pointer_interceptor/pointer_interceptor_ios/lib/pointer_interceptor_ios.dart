// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pointer_interceptor_platform_interface/pointer_interceptor_platform_interface.dart';

/// The iOS implementation of the [PointerInterceptorPlatform].
class PointerInterceptorIOS extends PointerInterceptorPlatform {
  /// Register plugin as iOS version.
  static void registerWith() {
    PointerInterceptorPlatform.instance = PointerInterceptorIOS();
  }

  @override
  Widget buildWidget({required Widget child, bool debug = false, Key? key}) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Positioned.fill(
          child: UiKitView(
            viewType: 'plugins.flutter.dev/pointer_interceptor_ios',
            creationParams: <String, bool>{'debug': debug},
            creationParamsCodec: const StandardMessageCodec(),
          ),
        ),
        child,
      ],
    );
  }
}
