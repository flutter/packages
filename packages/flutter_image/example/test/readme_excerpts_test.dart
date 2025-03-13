// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_image/flutter_image.dart';
import 'package:flutter_image_example/readme_excerpts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('networkImageWithRetry returns an Image with NetworkImageWithRetry', () {
    // Ensure that the snippet code runs successfully.
    final Image result = networkImageWithRetry();

    // It should have a image property of the right type.
    expect(result.image, isInstanceOf<NetworkImageWithRetry>());
    // And the NetworkImageWithRetry should have a url property.
    final NetworkImageWithRetry networkImage =
        result.image as NetworkImageWithRetry;
    expect(networkImage.url, equals('http://example.com/avatars/123.jpg'));
  });
}
