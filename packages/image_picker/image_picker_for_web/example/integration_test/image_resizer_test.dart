// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_for_web/src/image_resizer.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:integration_test/integration_test.dart';
import 'package:web/web.dart' as web;

//This is a sample 10x10 png image
const String pngFileBase64Contents =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKAQMAAAC3/F3+AAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAABlBMVEXqQzX+/v6lfubTAAAAAWJLR0QB/wIt3gAAAAlwSFlzAAAHEwAABxMBziAPCAAAAAd0SU1FB+UJHgsdDM0ErZoAAAALSURBVAjXY2DABwAAHgABboVHMgAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAyMS0wOS0zMFQxMToyOToxMi0wNDowMHCDC24AAAAldEVYdGRhdGU6bW9kaWZ5ADIwMjEtMDktMzBUMTE6Mjk6MTItMDQ6MDAB3rPSAAAAAElFTkSuQmCC';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Under test...
  late ImageResizer imageResizer;
  late XFile pngFile;
  setUp(() {
    imageResizer = ImageResizer();
    final web.Blob pngHtmlFile = _base64ToBlob(pngFileBase64Contents);
    pngFile = XFile(web.URL.createObjectURL(pngHtmlFile),
        name: 'pngImage.png', mimeType: 'image/png');
  });

  testWidgets('image is loaded correctly ', (WidgetTester tester) async {
    final web.HTMLImageElement imageElement =
        await imageResizer.loadImage(pngFile.path);
    expect(imageElement.width, 10);
    expect(imageElement.height, 10);
  });

  testWidgets(
      "canvas is loaded with image's width and height when max width and max height are null",
      (WidgetTester widgetTester) async {
    final web.HTMLImageElement imageElement =
        await imageResizer.loadImage(pngFile.path);
    final web.HTMLCanvasElement canvas =
        imageResizer.resizeImageElement(imageElement, null, null);
    expect(canvas.width, imageElement.width);
    expect(canvas.height, imageElement.height);
  });

  testWidgets(
      'canvas size is scaled when max width and max height are not null',
      (WidgetTester widgetTester) async {
    final web.HTMLImageElement imageElement =
        await imageResizer.loadImage(pngFile.path);
    final web.HTMLCanvasElement canvas =
        imageResizer.resizeImageElement(imageElement, 8, 8);
    expect(canvas.width, 8);
    expect(canvas.height, 8);
  });

  testWidgets('resized image is returned after converting canvas to file',
      (WidgetTester widgetTester) async {
    final web.HTMLImageElement imageElement =
        await imageResizer.loadImage(pngFile.path);
    final web.HTMLCanvasElement canvas =
        imageResizer.resizeImageElement(imageElement, null, null);
    final XFile resizedImage =
        await imageResizer.writeCanvasToFile(pngFile, canvas, null);
    expect(resizedImage.name, 'scaled_${pngFile.name}');
  });

  testWidgets('image is scaled when maxWidth is set',
      (WidgetTester tester) async {
    final XFile scaledImage =
        await imageResizer.resizeImageIfNeeded(pngFile, 5, null, null);
    expect(scaledImage.name, 'scaled_${pngFile.name}');
    final Size scaledImageSize = await _getImageSize(scaledImage);
    expect(scaledImageSize, const Size(5, 5));
  });

  testWidgets('image is scaled when maxHeight is set',
      (WidgetTester tester) async {
    final XFile scaledImage =
        await imageResizer.resizeImageIfNeeded(pngFile, null, 6, null);
    expect(scaledImage.name, 'scaled_${pngFile.name}');
    final Size scaledImageSize = await _getImageSize(scaledImage);
    expect(scaledImageSize, const Size(6, 6));
  });

  testWidgets('image is scaled when imageQuality is set',
      (WidgetTester tester) async {
    final XFile scaledImage =
        await imageResizer.resizeImageIfNeeded(pngFile, null, null, 89);
    expect(scaledImage.name, 'scaled_${pngFile.name}');
  });

  testWidgets('image is scaled when maxWidth,maxHeight,imageQuality are set',
      (WidgetTester tester) async {
    final XFile scaledImage =
        await imageResizer.resizeImageIfNeeded(pngFile, 3, 4, 89);
    expect(scaledImage.name, 'scaled_${pngFile.name}');
  });

  testWidgets('image is not scaled when maxWidth,maxHeight, is set',
      (WidgetTester tester) async {
    final XFile scaledImage =
        await imageResizer.resizeImageIfNeeded(pngFile, null, null, null);
    expect(scaledImage.name, pngFile.name);
  });
}

Future<Size> _getImageSize(XFile file) async {
  final Completer<Size> completer = Completer<Size>();
  final web.HTMLImageElement image = web.HTMLImageElement();
  image
    ..onLoad.listen((web.Event event) {
      completer.complete(Size(image.width.toDouble(), image.height.toDouble()));
    })
    ..onError.listen((web.Event event) {
      completer.complete(Size.zero);
    })
    ..src = file.path;
  return completer.future;
}

web.Blob _base64ToBlob(String data) {
  final List<String> arr = data.split(',');
  final String bstr = web.window.atob(arr[1]);
  int n = bstr.length;
  final Uint8List u8arr = Uint8List(n);

  while (n >= 1) {
    u8arr[n - 1] = bstr.codeUnitAt(n - 1);
    n--;
  }

  return web.Blob(<JSUint8Array>[u8arr.toJS].toJS);
}
