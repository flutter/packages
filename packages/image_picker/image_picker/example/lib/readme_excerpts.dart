// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Example function for README demonstration of various pick* calls.
Future<List<XFile?>> readmePickExample() async {
  // #docregion Pick
  final ImagePicker picker = ImagePicker();
  // Pick an image.
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  // Capture a photo.
  final XFile? photo = await picker.pickImage(source: ImageSource.camera);
  // Pick a video.
  final XFile? galleryVideo =
      await picker.pickVideo(source: ImageSource.gallery);
  // Capture a video.
  final XFile? cameraVideo = await picker.pickVideo(source: ImageSource.camera);
  // Pick multiple images.
  final List<XFile> images = await picker.pickMultiImage();
  // #enddocregion Pick

  // Return everything for the sanity check test.
  return <XFile?>[
    image,
    photo,
    galleryVideo,
    cameraVideo,
    if (images.isEmpty) null else images.first
  ];
}

/// Example function for README demonstration of getting lost data.
// #docregion LostData
Future<void> getLostData() async {
  final ImagePicker picker = ImagePicker();
  final LostDataResponse response = await picker.retrieveLostData();
  if (response.isEmpty) {
    return;
  }
  final List<XFile>? files = response.files;
  if (files != null) {
    _handleLostFiles(files);
  } else {
    _handleError(response.exception);
  }
}
// #enddocregion LostData

// Stubs for the getLostData function.
void _handleLostFiles(List<XFile> file) {}
void _handleError(PlatformException? exception) {}
