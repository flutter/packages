// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';

/// A superclass of generator classes.
///
/// This provides the structure that is common across generators for different languages.
abstract class Generator<T> {
  /// Generates files for specified language with specified [languageOptions]
  void generate(T languageOptions, Root root, StringSink sink);
}
