// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_linux/image_picker_linux.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ImagePickerLinux plugin;
  late FakeFileSelectorPlatform mockFileSelectorPlatform;

  setUp(() {
    CrossFilePlatform.instance = FakeCrossFile();
    plugin = ImagePickerLinux();
    ImagePickerLinux.fileSelector = mockFileSelectorPlatform = FakeFileSelectorPlatform();
  });

  test('registered instance', () {
    ImagePickerLinux.registerWith();
    expect(ImagePickerPlatform.instance, isA<ImagePickerLinux>());
  });

  group('images', () {
    test('pickImage passes the accepted type groups correctly', () async {
      late final List<XTypeGroup>? acceptedTypeGroups;
      mockFileSelectorPlatform.onOpenFile = ({required OpenFileDialogOptions options}) async {
        acceptedTypeGroups = options.acceptedTypeGroups;
        return null;
      };

      await plugin.pickImage(source: ImageSource.gallery);

      expect(acceptedTypeGroups?.single.mimeTypes, <String>['image/*']);
    });

    test('pickImage calls delegate when source is camera', () async {
      final file = FileSystemXFile('/tmp/foo');
      plugin.cameraDelegate = FakeCameraDelegate(result: file);
      expect(await plugin.pickImage(source: ImageSource.camera), file);
    });

    test('pickImage throws StateError when source is camera with no delegate', () async {
      await expectLater(plugin.pickImage(source: ImageSource.camera), throwsStateError);
    });

    test('pickMultiImage passes the accepted type groups correctly', () async {
      late final List<XTypeGroup>? acceptedTypeGroups;
      mockFileSelectorPlatform.onOpenFiles = ({required OpenFilesDialogOptions options}) async {
        acceptedTypeGroups = options.acceptedTypeGroups;
        return <XFile>[];
      };

      await plugin.pickMultiImage();

      expect(acceptedTypeGroups?.single.mimeTypes, <String>['image/*']);
    });
  });

  group('videos', () {
    test('pickVideo passes the accepted type groups correctly', () async {
      late final List<XTypeGroup>? acceptedTypeGroups;
      mockFileSelectorPlatform.onOpenFile = ({required OpenFileDialogOptions options}) async {
        acceptedTypeGroups = options.acceptedTypeGroups;
        return null;
      };

      await plugin.pickVideo(source: ImageSource.gallery);

      expect(acceptedTypeGroups?.single.mimeTypes, <String>['video/*']);
    });

    test('pickVideo calls delegate when source is camera', () async {
      final file = FileSystemXFile('/tmp/foo');
      plugin.cameraDelegate = FakeCameraDelegate(result: file);
      expect(await plugin.pickVideo(source: ImageSource.camera), file);
    });

    test('pickVideo throws StateError when source is camera with no delegate', () async {
      await expectLater(plugin.pickVideo(source: ImageSource.camera), throwsStateError);
    });

    test('pickMultiVideo passes the accepted type groups correctly', () async {
      late final List<XTypeGroup>? acceptedTypeGroups;
      mockFileSelectorPlatform.onOpenFiles = ({required OpenFilesDialogOptions options}) async {
        acceptedTypeGroups = options.acceptedTypeGroups;
        return <XFile>[];
      };

      await plugin.pickMultiVideo();

      expect(acceptedTypeGroups?.single.mimeTypes, <String>['video/*']);
    });
  });

  group('media', () {
    test('pickMedia passes the accepted type groups correctly', () async {
      late final List<XTypeGroup>? acceptedTypeGroups;
      mockFileSelectorPlatform.onOpenFiles = ({required OpenFilesDialogOptions options}) async {
        acceptedTypeGroups = options.acceptedTypeGroups;
        return <XFile>[];
      };

      await plugin.pickMedia(options: const MediaPickerOptions(allowMultiple: true));

      expect(acceptedTypeGroups?.single.mimeTypes, <String>['image/*', 'video/*']);
    });

    test('multiple media handles an empty path response gracefully', () async {
      mockFileSelectorPlatform.onOpenFiles = ({required OpenFilesDialogOptions options}) async =>
          <XFile>[];
      expect(
        await plugin.pickMedia(options: const MediaPickerOptions(allowMultiple: true)),
        <String>[],
      );
    });

    test('single media handles an empty path response gracefully', () async {
      mockFileSelectorPlatform.onOpenFile = ({required OpenFileDialogOptions options}) async =>
          null;
      expect(
        await plugin.pickMedia(options: const MediaPickerOptions(allowMultiple: false)),
        <String>[],
      );
    });
  });
}

final class FakeCameraDelegate extends ImagePickerCameraDelegate {
  FakeCameraDelegate({this.result});

  XFile? result;

  @override
  Future<XFile?> takePhoto({ImagePickerOptions options = const ImagePickerOptions()}) async {
    return result;
  }

  @override
  Future<XFile?> takeVideo({VideoPickerOptions options = const VideoPickerOptions()}) async {
    return result;
  }
}

final class FakeCrossFile extends CrossFilePlatform {}

final class FakeFileSelectorPlatform extends FileSelectorPlatform {
  FakeFileSelectorPlatform();

  late Future<XFile?> Function({required OpenFileDialogOptions options}) onOpenFile;
  late Future<List<XFile>> Function({required OpenFilesDialogOptions options}) onOpenFiles;

  @override
  Future<XFile?> openFile({OpenFileDialogOptions options = const OpenFileDialogOptions()}) =>
      onOpenFile(options: options);

  @override
  Future<List<XFile>> openFiles({
    OpenFilesDialogOptions options = const OpenFilesDialogOptions(),
  }) => onOpenFiles(options: options);
}
