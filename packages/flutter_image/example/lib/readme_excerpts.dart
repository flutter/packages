// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_image/flutter_image.dart';

/// Demonstrates loading an image for the README.
Image networkImageWithRetry() {
// #docregion NetworkImageWithRetry
  const Image avatar = Image(
    image: NetworkImageWithRetry('http://example.com/avatars/123.jpg'),
  );
// #enddocregion NetworkImageWithRetry

  return avatar;
}
