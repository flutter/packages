// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_android_camerax/src/preview_view_preview.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('creates a new platform view when the PreviewView changes', (
    WidgetTester tester,
  ) async {
    final createdPreviewViewIds = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform_views, (
      MethodCall call,
    ) async {
      if (call.method == 'create') {
        final args = call.arguments as Map<Object?, Object?>;
        createdPreviewViewIds.add(
          const StandardMessageCodec().decodeMessage(
            ByteData.sublistView(args['params']! as Uint8List),
          ),
        );
      }
      return null;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform_views,
        null,
      ),
    );

    Widget preview(int id) => Directionality(
      textDirection: TextDirection.ltr,
      child: PreviewViewPreview(
        previewViewId: id,
        initialDeviceOrientation: DeviceOrientation.portraitUp,
        deviceOrientationStream: const Stream<DeviceOrientation>.empty(),
      ),
    );

    await tester.pumpWidget(preview(1));
    await tester.pump();
    await tester.pumpWidget(preview(2));
    await tester.pump();

    expect(createdPreviewViewIds, <Object?>[1, 2]);
  });
}
