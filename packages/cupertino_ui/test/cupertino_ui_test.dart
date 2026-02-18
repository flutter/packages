// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Cupertino library is exported', (WidgetTester tester) async {
    await tester.pumpWidget(const CupertinoApp(home: SizedBox.shrink()));
  });
}
