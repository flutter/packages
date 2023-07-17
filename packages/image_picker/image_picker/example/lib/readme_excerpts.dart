// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
// #docregion CameraDelegate
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
// #enddocregion CameraDelegate

/// Example of a camera delegate
// #docregion CameraDelegate
class MyCameraDelegate extends ImagePickerCameraDelegate {
  @override
  Future<XFile?> takePhoto(
      {ImagePickerCameraDelegateOptions options =
          const ImagePickerCameraDelegateOptions()}) async {
    return _takeAPhoto(options.preferredCameraDevice);
  }

  @override
  Future<XFile?> takeVideo(
      {ImagePickerCameraDelegateOptions options =
          const ImagePickerCameraDelegateOptions()}) async {
    return _takeAVideo(options.preferredCameraDevice);
  }
}
// #enddocregion CameraDelegate

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
  // Pick singe image or video.
  final XFile? media = await picker.pickMedia();
  // Pick multiple images and videos.
  final List<XFile> medias = await picker.pickMultipleMedia();
  // #enddocregion Pick

  // Return everything for the sanity check test.
  return <XFile?>[
    image,
    photo,
    galleryVideo,
    cameraVideo,
    if (images.isEmpty) null else images.first,
    media,
    if (medias.isEmpty) null else medias.first,
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

/// Example of camera delegate setup.
// #docregion CameraDelegate
void setUpCameraDelegate() {
  final ImagePickerPlatform instance = ImagePickerPlatform.instance;
  if (instance is CameraDelegatingImagePickerPlatform) {
    instance.cameraDelegate = MyCameraDelegate();
  }
}
// #enddocregion CameraDelegate

// Stubs for the getLostData function.
void _handleLostFiles(List<XFile> file) {}
void _handleError(PlatformException? exception) {}

// Stubs for MyCameraDelegate.
Future<XFile?> _takeAPhoto(CameraDevice device) async => null;
Future<XFile?> _takeAVideo(CameraDevice device) async => null;
