// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/material_state/material_state_color.snippet.0.dart'
    as example;

void main() {
  test(
    'MyColor const MaterialStateColor resolves default and pressed colors',
    () {
      const example.MyColor color = example.MyColor();

      expect(color.toARGB32(), 0xcafefeed);
      expect(color.resolve(<WidgetState>{}), const Color(0xcafefeed));
      expect(
        color.resolve(<WidgetState>{WidgetState.pressed}),
        const Color(0xdeadbeef),
      );
    },
  );
}
