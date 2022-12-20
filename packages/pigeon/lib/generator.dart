// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'ast.dart';
import 'pigeon_lib.dart';

/// A generator that will write code to a sink based on the contents of [PigeonOptions].
abstract class Generator {
  /// Constructor for Generator.
  const Generator(
      // {
      //   required this.pigeonOptions,
      //   required this.sink,
      //   required this.root,
      // }
      );

  // /// Options for any generator being called.
  // final PigeonOptions pigeonOptions;

  // /// Just to make sure everything is included.
  // final StringSink sink;

  // /// Trees can't grow without em.
  // final Root root;

  /// Returns an [IOSink] instance to be written to if the [Generator] should
  /// generate.  If it returns `null`, the [Generator] will be skipped.
  IOSink? shouldGenerate(PigeonOptions options);

  /// Write the generated code described in [root] to [sink] using the
  /// [options].
  void generate(StringSink sink, PigeonOptions options, Root root);

  /// Generates errors that would only be appropriate for this [Generator]. For
  /// example, maybe a certain feature isn't implemented in a [Generator] yet.
  List<Error> validate(PigeonOptions options, Root root);

  // /// Method for generation of pigeon files.
  // void generate() {
  //   //write headers
  //   //write imports
  //   //write enums (loop)
  //   //write classes (loop)
  //   //write apis (loop)
  // }

  // /// Writes file header.
  // void writeHeader() {
  //   //
  // }

  // /// Writes import statements.
  // void writeImports() {
  //   //
  // }

  // /// Writes an Enum.
  // void writeEnum() {
  //   //
  // }

  // /// Writes a class.
  // void writeClass() {
  //   //
  // }

  // /// Writes the encode (or toList) method for a class.
  // void writeEncode() {
  //   //
  // }

  // /// Writes the decode (or fromList) method for a class.
  // void writeDecode() {
  //   //
  // }

  // /// Writes an api.
  // void writeApi() {
  //   // if host api
  //   // write host api
  //   // else
  //   // write flutter api
  // }
}
