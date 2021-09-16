// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:rfw/formats.dart';

void main(List<String> arguments) {
  if (arguments.length != 2) {
    print('usage: dart encode.dart source.rfwtxt output.rfw');
    exit(1);
  }
  File(arguments[1]).writeAsBytesSync(
    encodeLibraryBlob(
      parseLibraryFile(File(arguments[0]).readAsStringSync()),
    ),
  );
}
