// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

export 'platforms/native_widget_ios.dart'
    if (dart.library.html) 'platforms/native_widget_web.dart';
