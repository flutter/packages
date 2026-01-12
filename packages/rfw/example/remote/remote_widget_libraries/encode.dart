// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is hand-formatted.

import 'dart:io';

import 'package:rfw/formats.dart';

void main() {
  final String counterApp1 = File('counter_app1.rfwtxt').readAsStringSync();
  File('counter_app1.rfw').writeAsBytesSync(encodeLibraryBlob(parseLibraryFile(counterApp1)));
  final String counterApp2 = File('counter_app2.rfwtxt').readAsStringSync();
  File('counter_app2.rfw').writeAsBytesSync(encodeLibraryBlob(parseLibraryFile(counterApp2)));
}
