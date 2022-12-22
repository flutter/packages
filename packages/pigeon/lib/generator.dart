// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';
import 'generator_tools.dart';

/// A Super class of generator classes.
///
/// This is meant to provide structure and direction for future generator work.
abstract class Generator<T> {
  /// Instantiates a Generator.
  const Generator();

  /// Generates files for specified language with specified [languageOptions]
  ///
  /// This method, when overridden, should follow a generic structure that is currently:
  /// 1. Create Indent
  /// 2. Write File Headers
  /// 3. Generate File
  void generate(
    T languageOptions,
    Root root,
    StringSink sink,
  );

  /// Adds specified file headers.
  void writeFileHeaders(
    T languageOptions,
    Root root,
    StringSink sink,
    Indent indent,
  );
}
