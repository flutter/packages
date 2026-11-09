// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Demonstrates using an XFile result as an [Image] source, for the README.
Image getImageFromResultExample(XFile capturedImage) {
  // #docregion ImageFromXFile
  final Image image;
  if (kIsWeb) {
    image = Image.network(capturedImage.uri);
  } else {
    image = Image.file(File.fromUri(Uri.parse(capturedImage.uri)));
  }
  // #enddocregion ImageFromXFile
  return image;
}
