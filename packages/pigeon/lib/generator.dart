// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'ast.dart';
import 'pigeon_lib.dart' show Error, PigeonOptions;

/// A generator that will write code to a sink based on the contents of [PigeonOptions].
abstract class Generator {
  /// Constructor for Generator.
  Generator();

  /// Returns an [IOSink] instance to be written to if the [Generator] should
  /// generate.  If it returns `null`, the [Generator] will be skipped.
  IOSink? shouldGenerate(PigeonOptions options);

  /// Write the generated code described in [root] to [sink] using the
  /// [options].
  void generate(StringSink sink, PigeonOptions options, Root root);

  /// Generates errors that would only be appropriate for this [Generator]. For
  /// example, maybe a certain feature isn't implemented in a [Generator] yet.
  List<Error> validate(PigeonOptions options, Root root);
}
