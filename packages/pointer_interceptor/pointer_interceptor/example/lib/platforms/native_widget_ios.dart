// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget representing an underlying platform view.
class NativeWidget extends StatelessWidget {
  /// Constructor
  const NativeWidget({super.key, required this.onClick});

  /// Placeholder param to allow web example to work -
  /// onClick functionality for iOS is in the PlatformView
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    const String viewType = 'dummy_platform_view';
    final Map<String, dynamic> creationParams = <String, dynamic>{};

    return UiKitView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
