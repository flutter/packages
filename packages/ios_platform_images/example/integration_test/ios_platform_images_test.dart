// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ios_platform_images/ios_platform_images.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('resolves URL', (WidgetTester _) async {
    final String? path = await IosPlatformImages.resolveURL('textfile');
    expect(Uri.parse(path!).scheme, 'file');
    expect(path.contains('Runner.app'), isTrue);
  });

  testWidgets('loads image', (WidgetTester _) async {
    final Completer<bool> successCompleter = Completer<bool>();
    final ImageProvider<Object> provider = IosPlatformImages.load('flutter');
    final ImageStream imageStream = provider.resolve(ImageConfiguration.empty);
    imageStream.addListener(
        ImageStreamListener((ImageInfo image, bool synchronousCall) {
      successCompleter.complete(true);
    }, onError: (Object e, StackTrace? _) {
      successCompleter.complete(false);
    }));

    final bool succeeded = await successCompleter.future;
    expect(succeeded, true);
  });
}
