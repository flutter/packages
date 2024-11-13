// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:example/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_macos/image_picker_macos.dart';
import 'package:image_picker_macos/src/messages.g.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:integration_test/integration_test.dart';

ImagePickerMacOS get requireMacOSImplementation {
  final ImagePickerPlatform imagePickerImplementation =
      ImagePickerPlatform.instance;
  if (imagePickerImplementation is! ImagePickerMacOS) {
    fail('Expected the implementation to be $ImagePickerMacOS');
  }
  return imagePickerImplementation;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('example', () {
    testWidgets(
      'Pressing the PHPicker toggle button updates it correctly',
      (WidgetTester tester) async {
        final ImagePickerMacOS imagePickerImplementation =
            requireMacOSImplementation;
        expect(imagePickerImplementation.useMacOSPHPicker, false,
            reason: 'The default is to not using PHPicker');

        await tester.pumpWidget(const MyApp());
        final Finder togglePHPickerFinder =
            find.byTooltip('toggle macOS PHPPicker');
        expect(togglePHPickerFinder, findsOneWidget);

        await tester.tap(togglePHPickerFinder);
        expect(imagePickerImplementation.useMacOSPHPicker, true,
            reason: 'Pressing the toggle button should update it correctly');

        await tester.tap(togglePHPickerFinder);
        expect(imagePickerImplementation.useMacOSPHPicker, false,
            reason: 'Pressing the toggle button should update it correctly');
      },
    );
    testWidgets(
      'multi-video selection is not implemented',
      (WidgetTester tester) async {
        final ImagePickerApi hostApi = ImagePickerApi();
        await expectLater(
          hostApi.pickVideos(GeneralOptions(limit: 2)),
          throwsA(predicate<PlatformException>(
            (PlatformException e) =>
                e.code == 'UNIMPLEMENTED' &&
                e.message == 'Multi-video selection is not implemented',
          )),
        );
      },
    );
  });
}
