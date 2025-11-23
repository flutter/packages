// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// Stub for the web-only renderButton method, since google_sign_in_web has to
/// be behind a conditional import.
Widget renderButton() {
  throw StateError('This should only be called on web');
}
