// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/rfw_extension.dart';

void main() {
  runApp(const ProviderScope(child: RfwDevToolsExtension()));
}
