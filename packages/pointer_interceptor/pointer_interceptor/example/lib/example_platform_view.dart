// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class ExamplePlatformView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRect(child: Center(child: Text('platform view')));
  }
}