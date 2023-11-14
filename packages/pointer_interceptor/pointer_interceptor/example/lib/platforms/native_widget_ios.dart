// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget representing an underlying platform view
class NativeWidget extends StatelessWidget {
  /// Constructor
  const NativeWidget({super.key, required this.onClick});

  /// A function to run when the element is clicked
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
