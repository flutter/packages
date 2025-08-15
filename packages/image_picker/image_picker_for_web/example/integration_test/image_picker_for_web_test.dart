// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web/web.dart' as web;

const String expectedStringContents = 'Hello, world!';
const String otherStringContents = 'Hello again, world!';
final Uint8List bytes = const Utf8Encoder().convert(expectedStringContents);
final Uint8List otherBytes = const Utf8Encoder().convert(otherStringContents);
// TODO(dit): When web:0.6.0 lands, move `type` to the [web.FilePropertyBag] constructor.
// See: https://github.com/dart-lang/web/pull/197
final web.FilePropertyBag options = web.FilePropertyBag(
  lastModified: DateTime.utc(2017, 12, 13).millisecondsSinceEpoch,
)..type = 'text/plain';

final web.File textFile =
    web.File(<JSUint8Array>[bytes.toJS].toJS, 'hello.txt', options);
final web.File secondTextFile =
    web.File(<JSUint8Array>[otherBytes.toJS].toJS, 'secondFile.txt');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Under test...
  late ImagePickerPlugin plugin;

  setUp(() {
    plugin = ImagePickerPlugin();
  });

  testWidgets('getImageFromSource can select a file', (
    WidgetTester _,
  ) async {
    final web.HTMLInputElement mockInput = web.HTMLInputElement()
      ..type = 'file';
    final ImagePickerPluginTestOverrides overrides =
        ImagePickerPluginTestOverrides()
          ..createInputElement = ((_, __) => mockInput)
          ..getMultipleFilesFromInput = ((_) => <web.File>[textFile]);

    final ImagePickerPlugin plugin = ImagePickerPlugin(overrides: overrides);

    // Init the pick file dialog...
    final Future<XFile?> image = plugin.getImageFromSource(
      source: ImageSource.camera,
    );

    expect(
        web.document.querySelector('flt-image-picker-inputs')?.children.length,
        isNonZero);

    // Mock the browser behavior of selecting a file...
    mockInput.dispatchEvent(web.Event('change'));

    // Now the file should be available
    expect(image, completes);

    // And readable
    final XFile? file = await image;
    expect(file, isNotNull);
    expect(file!.readAsBytes(), completion(isNotEmpty));
    expect(file.name, textFile.name);
    expect(file.length(), completion(textFile.size));
    expect(file.mimeType, textFile.type);
    expect(
        file.lastModified(),
        completion(
          DateTime.fromMillisecondsSinceEpoch(textFile.lastModified),
        ));
    expect(
        web.document.querySelector('flt-image-picker-inputs')?.children.length,
        isZero);
  });

  testWidgets('getMultiImageWithOptions can select multiple files', (
    WidgetTester _,
  ) async {
    final web.HTMLInputElement mockInput = web.HTMLInputElement()
      ..type = 'file';

    final ImagePickerPluginTestOverrides overrides =
        ImagePickerPluginTestOverrides()
          ..createInputElement = ((_, __) => mockInput)
          ..getMultipleFilesFromInput =
              ((_) => <web.File>[textFile, secondTextFile]);

    final ImagePickerPlugin plugin = ImagePickerPlugin(overrides: overrides);

    // Init the pick file dialog...
    final Future<List<XFile>> files = plugin.getMultiImageWithOptions();

    // Mock the browser behavior of selecting a file...
    mockInput.dispatchEvent(web.Event('change'));

    // Now the file should be available
    expect(files, completes);

    // And readable
    expect((await files).first.readAsBytes(), completion(isNotEmpty));

    // Peek into the second file...
    final XFile secondFile = (await files).elementAt(1);
    expect(secondFile.readAsBytes(), completion(isNotEmpty));
    expect(secondFile.name, secondTextFile.name);
    expect(secondFile.length(), completion(secondTextFile.size));
  });

  testWidgets('getMedia can select multiple files', (WidgetTester _) async {
    final web.HTMLInputElement mockInput = web.HTMLInputElement()
      ..type = 'file';

    final ImagePickerPluginTestOverrides overrides =
        ImagePickerPluginTestOverrides()
          ..createInputElement = ((_, __) => mockInput)
          ..getMultipleFilesFromInput =
              ((_) => <web.File>[textFile, secondTextFile]);

    final ImagePickerPlugin plugin = ImagePickerPlugin(overrides: overrides);

    // Init the pick file dialog...
    final Future<List<XFile>> files =
        plugin.getMedia(options: const MediaOptions(allowMultiple: true));

    // Mock the browser behavior of selecting a file...
    mockInput.dispatchEvent(web.Event('change'));

    // Now the file should be available
    expect(files, completes);

    // And readable
    expect((await files).first.readAsBytes(), completion(isNotEmpty));

    // Peek into the second file...
    final XFile secondFile = (await files).elementAt(1);
    expect(secondFile.readAsBytes(), completion(isNotEmpty));
    expect(secondFile.name, secondTextFile.name);
    expect(secondFile.length(), completion(secondTextFile.size));
  });

  group('cancel event', () {
    late web.HTMLInputElement mockInput;
    late ImagePickerPluginTestOverrides overrides;
    late ImagePickerPlugin plugin;

    setUp(() {
      mockInput = web.HTMLInputElement()..type = 'file';
      overrides = ImagePickerPluginTestOverrides()
        ..createInputElement = ((_, __) => mockInput)
        ..getMultipleFilesFromInput = ((_) => <web.File>[textFile]);
      plugin = ImagePickerPlugin(overrides: overrides);
    });

    void mockCancel() {
      mockInput.dispatchEvent(web.Event('cancel'));
    }

    testWidgets('getFiles - returns empty list', (WidgetTester _) async {
      final Future<List<XFile>> files = plugin.getFiles();
      mockCancel();

      expect(files, completes);
      expect(await files, isEmpty);
    });

    testWidgets('getMedia - returns empty list', (WidgetTester _) async {
      final Future<List<XFile>?> files = plugin.getMedia(
          options: const MediaOptions(
        allowMultiple: true,
      ));
      mockCancel();

      expect(files, completes);
      expect(await files, isEmpty);
    });

    testWidgets('getMultiImageWithOptions - returns empty list', (
      WidgetTester _,
    ) async {
      final Future<List<XFile>?> files = plugin.getMultiImageWithOptions();
      mockCancel();

      expect(files, completes);
      expect(await files, isEmpty);
    });

    testWidgets('getImageFromSource - returns null', (WidgetTester _) async {
      final Future<XFile?> file = plugin.getImageFromSource(
        source: ImageSource.gallery,
      );
      mockCancel();

      expect(file, completes);
      expect(await file, isNull);
    });

    testWidgets('getVideo - returns null', (WidgetTester _) async {
      final Future<XFile?> file = plugin.getVideo(
        source: ImageSource.gallery,
      );
      mockCancel();

      expect(file, completes);
      expect(await file, isNull);
    });
  });

  testWidgets('computeCaptureAttribute', (WidgetTester tester) async {
    expect(
      plugin.computeCaptureAttribute(ImageSource.gallery, CameraDevice.front),
      isNull,
    );
    expect(
      plugin.computeCaptureAttribute(ImageSource.gallery, CameraDevice.rear),
      isNull,
    );
    expect(
      plugin.computeCaptureAttribute(ImageSource.camera, CameraDevice.front),
      'user',
    );
    expect(
      plugin.computeCaptureAttribute(ImageSource.camera, CameraDevice.rear),
      'environment',
    );
  });

  group('createInputElement', () {
    testWidgets('accept: any, capture: null', (WidgetTester tester) async {
      final web.Element input = plugin.createInputElement('any', null);

      expect(input.getAttribute('accept'), 'any');
      expect(input.hasAttribute('capture'), false);
      expect(input.hasAttribute('multiple'), false);
    });

    testWidgets('accept: any, capture: something', (WidgetTester tester) async {
      final web.Element input = plugin.createInputElement('any', 'something');

      expect(input.getAttribute('accept'), 'any');
      expect(input.getAttribute('capture'), 'something');
      expect(input.hasAttribute('multiple'), false);
    });

    testWidgets('accept: any, capture: null, multi: true',
        (WidgetTester tester) async {
      final web.Element input =
          plugin.createInputElement('any', null, multiple: true);

      expect(input.getAttribute('accept'), 'any');
      expect(input.hasAttribute('capture'), false);
      expect(input.hasAttribute('multiple'), true);
    });

    testWidgets('accept: any, capture: something, multi: true',
        (WidgetTester tester) async {
      final web.Element input =
          plugin.createInputElement('any', 'something', multiple: true);

      expect(input.getAttribute('accept'), 'any');
      expect(input.getAttribute('capture'), 'something');
      expect(input.hasAttribute('multiple'), true);
    });
  });

  group('Deprecated methods', () {
    late web.HTMLInputElement mockInput;
    late ImagePickerPluginTestOverrides overrides;
    late ImagePickerPlugin plugin;

    setUp(() {
      mockInput = web.HTMLInputElement()..type = 'file';
      overrides = ImagePickerPluginTestOverrides()
        ..createInputElement = ((_, __) => mockInput)
        ..getMultipleFilesFromInput = ((_) => <web.File>[textFile]);
      plugin = ImagePickerPlugin(overrides: overrides);
    });

    void mockCancel() {
      mockInput.dispatchEvent(web.Event('cancel'));
    }

    void mockChange() {
      mockInput.dispatchEvent(web.Event('change'));
    }

    group('getImage', () {
      testWidgets('can select a file', (WidgetTester _) async {
        // ignore: deprecated_member_use
        final Future<XFile?> image = plugin.getImage(
          source: ImageSource.camera,
        );

        // Mock the browser behavior when selecting a file...
        mockChange();

        // Now the file should be available
        expect(image, completes);

        // And readable
        final XFile? file = await image;
        expect(file, isNotNull);
        expect(file!.readAsBytes(), completion(isNotEmpty));
        expect(file.name, textFile.name);
        expect(file.length(), completion(textFile.size));
        expect(file.mimeType, textFile.type);
        expect(
            file.lastModified(),
            completion(
              DateTime.fromMillisecondsSinceEpoch(textFile.lastModified),
            ));
      });

      testWidgets('returns null when canceled', (WidgetTester _) async {
        // ignore: deprecated_member_use
        final Future<XFile?> file = plugin.getImage(
          source: ImageSource.gallery,
        );
        mockCancel();

        expect(file, completes);
        expect(await file, isNull);
      });
    });

    group('getMultiImage', () {
      testWidgets('can select multiple files', (WidgetTester _) async {
        // Override the returned files...
        overrides.getMultipleFilesFromInput =
            (_) => <web.File>[textFile, secondTextFile];

        // ignore: deprecated_member_use
        final Future<List<XFile>> files = plugin.getMultiImage();

        // Mock the browser behavior of selecting a file...
        mockChange();

        // Now the file should be available
        expect(files, completes);

        // And readable
        expect((await files).first.readAsBytes(), completion(isNotEmpty));

        // Peek into the second file...
        final XFile secondFile = (await files).elementAt(1);
        expect(secondFile.readAsBytes(), completion(isNotEmpty));
        expect(secondFile.name, secondTextFile.name);
        expect(secondFile.length(), completion(secondTextFile.size));
      });

      testWidgets('returns an empty list when canceled', (
        WidgetTester _,
      ) async {
        // ignore: deprecated_member_use
        final Future<List<XFile>?> files = plugin.getMultiImage();
        mockCancel();

        expect(files, completes);
        expect(await files, isEmpty);
      });
    });
  });
}
