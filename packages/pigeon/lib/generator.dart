// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';

/// A Super class of generator classes.
///
/// This is meant to provide structure and direction for future generator work.
abstract class Generator<T> {
  /// Instantiates a Generator.
  const Generator();

  /// Generates files for specified language with specified [languageOptions]
  void generate(T languageOptions, Root root, StringSink sink);
}
