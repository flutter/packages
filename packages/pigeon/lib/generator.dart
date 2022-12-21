// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';

/// A Super class of generator classes.
///
/// This is meant to provide structure and direction for future generator work.
abstract class Generator<T> {
  /// Instantiates a Generator.
  const Generator({
    required this.languageOptions,
    required this.root,
    required this.sink,
  });

  ///
  final T languageOptions;

  ///
  final Root root;

  ///
  final StringSink sink;

  /// Generates files for specified language with specified [languageOptions]
  void generate();
}
