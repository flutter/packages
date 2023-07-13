// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_example/readme_excerpts.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    ImagePickerPlatform.instance = FakeImagePicker();
  });

  test('sanity check readmePickExample', () async {
    // Ensure that the snippet code runs successfully.
    final List<XFile?> results = await readmePickExample();
    // It should demonstrate a variety of calls.
    expect(results.length, greaterThan(4));
    // And the calls should all be different. This works since each fake call
    // returns a different result.
    expect(results.map((XFile? file) => file?.path).toSet().length,
        results.length);
  });

  test('sanity check getLostData', () async {
    // Ensure that the snippet code runs successfully.
    await getLostData();
  });
}

class FakeImagePicker extends ImagePickerPlatform {
  @override
  Future<XFile?> getImageFromSource(
      {required ImageSource source,
      ImagePickerOptions options = const ImagePickerOptions()}) async {
    return XFile(source == ImageSource.camera ? 'cameraImage' : 'galleryImage');
  }

  @override
  Future<LostDataResponse> getLostData() async {
    return LostDataResponse.empty();
  }

  @override
  Future<List<XFile>> getMultiImageWithOptions(
      {MultiImagePickerOptions options =
          const MultiImagePickerOptions()}) async {
    return <XFile>[XFile('multiImage')];
  }

  @override
  Future<List<XFile>> getMedia({required MediaOptions options}) async {
    return options.allowMultiple
        ? <XFile>[XFile('medias'), XFile('medias')]
        : <XFile>[XFile('media')];
  }

  @override
  Future<XFile?> getVideo(
      {required ImageSource source,
      CameraDevice preferredCameraDevice = CameraDevice.rear,
      Duration? maxDuration}) async {
    return XFile(source == ImageSource.camera ? 'cameraVideo' : 'galleryVideo');
  }
}
