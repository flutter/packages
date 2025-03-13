// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

/// Demonstrates creating an Image widget from an XFile's path.
Image getImageFromPath(XFile pickedFile) {
  final Image image;

// #docregion ImageFromPath
  if (kIsWeb) {
    image = Image.network(pickedFile.path);
  } else {
    image = Image.file(File(pickedFile.path));
  }
// #enddocregion ImageFromPath

  return image;
}

/// Demonstrates creating an Image widget from an XFile's bytes.
Future<Image> getImageFromBytes(XFile pickedFile) async {
  final Image image;

// #docregion ImageFromBytes
  image = Image.memory(await pickedFile.readAsBytes());
// #enddocregion ImageFromBytes

  return image;
}
