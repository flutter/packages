// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:typed_data';

import 'package:args/args.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

final ArgParser argParser = ArgParser()
  ..addOption(
    'libtessellator',
    help: 'The path to a libtessellator dynamic library',
    valueHelp: 'path/to/libtessellator.dylib',
    hide: true,
  )
  ..addOption(
    'libpathops',
    help: 'The path to a libpathops dynamic library',
    valueHelp: 'path/to/libpath_ops.dylib',
    hide: true,
  )
  ..addFlag(
    'tessellate',
    help: 'Convert path fills into a tessellated shape. This will improve '
        'raster times at the cost of slightly larger file sizes.',
  )
  ..addFlag(
    'optimize-masks',
    help: 'Allows for masking optimizer to be enabled or disabled',
    defaultsTo: true,
  )
  ..addFlag(
    'optimize-clips',
    help: 'Allows for clipping optimizer to be enabled or disabled',
    defaultsTo: true,
  )
  ..addFlag(
    'optimize-overdraw',
    help: 'Allows for overdraw optimizer to be enabled or disabled',
    defaultsTo: true,
  )
  ..addOption('input',
      abbr: 'i',
      help: 'The path to a file containing a single SVG',
      mandatory: true)
  ..addOption(
    'output',
    abbr: 'o',
    help:
        'The path to a file where the resulting vector_graphic will be written.\n'
        'If not provided, defaults to <input-file>.vg',
  );

void loadPathOpsIfNeeded(ArgResults results) {
  if (results['optimize-masks'] == true ||
      results['optimize-clips'] == true ||
      results['optimize-overdraw'] == true) {
    if (results.wasParsed('libpathops')) {
      initializeLibPathOps(results['libpathops'] as String);
    } else {
      if (!initializePathOpsFromFlutterCache()) {
        exit(1);
      }
    }
  }
}

Future<void> main(List<String> args) async {
  final ArgResults results;
  try {
    results = argParser.parse(args);
  } on FormatException catch (err) {
    print(err.message);
    print(argParser.usage);
    exit(1);
  }

  if (results['tessellate'] == true) {
    if (results.wasParsed('libtessellator')) {
      initializeLibTesselator(results['libtessellator'] as String);
    } else {
      if (!initializeTessellatorFromFlutterCache()) {
        exit(1);
      }
    }
  }

  loadPathOpsIfNeeded(results);

  final String inputFilePath = results['input'] as String;
  final String xml = File(inputFilePath).readAsStringSync();
  final File outputFile =
      File(results['output'] as String? ?? '$inputFilePath.vg');

  bool maskingOptimizerEnabled = true;
  bool clippingOptimizerEnabled = true;
  bool overdrawOptimizerEnabled = true;

  if (results['optimize-masks'] == false) {
    maskingOptimizerEnabled = false;
  }

  if (results['optimize-clips'] == false) {
    clippingOptimizerEnabled = false;
  }

  if (results['optimize-overdraw'] == false) {
    overdrawOptimizerEnabled = false;
  }

  final Uint8List bytes = await encodeSvg(
      xml: xml,
      debugName: args[0],
      enableMaskingOptimizer: maskingOptimizerEnabled,
      enableClippingOptimizer: clippingOptimizerEnabled,
      enableOverdrawOptimizer: overdrawOptimizerEnabled);

  outputFile.writeAsBytesSync(bytes);
}
