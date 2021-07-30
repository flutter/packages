// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dart_ui_web_shim/ui.dart' as ui;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('platformViewRegistry', () {
    test('registerViewFactory always returns false in the VM', () {
      final bool result =
          ui.platformViewRegistry.registerViewFactory('key', (int id) {});
      expect(result, isFalse);
    });
  });

  group('webOnlyAssetManager', () {
    test('asset always returns empty string in the VM', () {
      final String result = ui.webOnlyAssetManager.getAssetUrl('anything');
      expect(result, '');
    });
  });

  test('Tell the user where to find more tests', () {
    print('---');
    print('This package also uses integration_test for its web tests.');
    print('See `example/README.md` for more info.');
    print('---');
  });
}
