// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library web_mouse_click_boundary;

export 'src/mobile.dart'
  if (dart.library.html) 'src/web.dart';
