// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_example/readme_excerpts.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    ImagePickerPlatform.instance = FakeImagePicker();
    CrossFilePlatform.instance = FakeCrossFile();
  });

  test('sanity check readmePickExample', () async {
    // Ensure that the snippet code runs successfully.
    final List<XFile?> results = await readmePickExample();
    // It should demonstrate a variety of calls.
    expect(results.length, greaterThan(4));
    // And the calls should all be different. This works since each fake call
    // returns a different result.
    expect(results.map((XFile? file) => file?.uri).toSet().length, results.length);
  });

  test('sanity check getLostData', () async {
    // Ensure that the snippet code runs successfully.
    await getLostData();
  });
}

base class FakeImagePicker extends ImagePickerPlatform {
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    return XFile.fileSystem(path: source == ImageSource.camera ? 'cameraImage' : 'galleryImage');
  }

  @override
  Future<LostDataResponse> getLostData() async {
    return const LostDataResponse.empty();
  }

  @override
  Future<List<XFile>> pickMultiImage({
    MultiImagePickerOptions options = const MultiImagePickerOptions(),
  }) async {
    return <XFile>[XFile.fileSystem(path: 'multiImage')];
  }

  @override
  Future<List<XFile>> pickMedia({required MediaPickerOptions options}) async {
    return options.allowMultiple
        ? <XFile>[XFile.fileSystem(path: 'medias'), XFile.fileSystem(path: 'medias')]
        : <XFile>[XFile.fileSystem(path: 'media')];
  }

  @override
  Future<XFile?> pickVideo({
    required ImageSource source,
    VideoPickerOptions options = const VideoPickerOptions(),
  }) async {
    return XFile.fileSystem(path: source == ImageSource.camera ? 'cameraVideo' : 'galleryVideo');
  }
}

final class FakeCrossFile extends CrossFilePlatform {}
