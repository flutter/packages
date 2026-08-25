// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

void main() {
  test('remove is forwarded to the implementation', () async {
    final documentStartJavaScript = ExtendsPlatformDocumentStartJavaScriptRegistration();

    await documentStartJavaScript.remove();

    expect(documentStartJavaScript.removeCallCount, 1);
  });
}

class ExtendsPlatformDocumentStartJavaScriptRegistration
    extends PlatformDocumentStartJavaScriptRegistration {
  int removeCallCount = 0;

  @override
  Future<void> remove() async {
    removeCallCount += 1;
  }
}
