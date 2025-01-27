// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:web/web.dart';

/// Convenience method to create a new [HTMLDivElement] element.
HTMLDivElement createDivElement() {
  return document.createElement('div') as HTMLDivElement;
}
