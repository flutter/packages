// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:vector_graphics_compiler/src/svg/colors.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

import 'util/isolate_processor.dart';

final ArgParser argParser = ArgParser()
  ..addOption(
    'current-color',
    help: 'The value (in ARGB format or a named SVG color) of the '
        '"currentColor" attribute.',
    valueHelp: '0xFF000000',
    defaultsTo: '0xFF000000',
  )
  ..addOption(
    'font-size',
    help: 'The basis for font size based values (i.e. em, ex).',
    valueHelp: '14',
    defaultsTo: '14',
  )
  ..addOption(
    'x-height',
    help: 'The x-height or corpus size of the font. If unspecified, defaults '
        'to half of font-size.',
    valueHelp: '7',
  )
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
  ..addOption(
    'input-dir',
    help: 'The path to a directory containing one or more SVGs. '
        'Only includes files that end with .svg. '
        'Cannot be combined with --input or --output.',
  )
  ..addOption(
    'out-dir',
    help: 'The output directory  path '
        'use it with --input-dir to specific the output dirictory',
  )
  ..addOption(
    'input',
    abbr: 'i',
    help: 'The path to a file containing a single SVG',
  )
  ..addOption('concurrency',
      abbr: 'k',
      help: 'The maximum number of SVG processing isolates to spawn at once. '
          'If not provided, defaults to the number of cores.')
  ..addFlag('dump-debug',
      help:
          'Dump a human readable debugging format alongside the compiled asset',
      hide: true)
  ..addOption(
    'output',
    abbr: 'o',
    help:
        'The path to a file where the resulting vector_graphic will be written.\n'
        'If not provided, defaults to <input-file>.vec',
  )
  ..addFlag('use-half-precision-control-points',
      help:
          'Convert path control points into  IEEE 754-2008 half precision floating point values.\n'
          'This reduces file size at the cost of lost precision at larger values.');

void validateOptions(ArgResults results) {
  if (results.wasParsed('input-dir') &&
      (results.wasParsed('input') || results.wasParsed('output'))) {
    print(
        '--input-dir cannot be combined with --input and/or --output options.');
    exit(1);
  }
  if (!results.wasParsed('input') && !results.wasParsed('input-dir')) {
    print('One of --input or --input-dir must be specified.');
    exit(1);
  }
}

SvgTheme _parseTheme(ArgResults results) {
  Color? currentColor = namedColors[results['current-color']];
  if (currentColor == null) {
    final int? argbValue = int.tryParse(results['current-color'] as String);
    currentColor = Color(argbValue ?? 0xFF000000);
  }
  return SvgTheme(
    currentColor: currentColor,
    fontSize: double.tryParse(results['font-size'] as String) ?? 14,
    xHeight: results.wasParsed('x-height')
        ? double.tryParse(results['x-height'] as String)
        : null,
  );
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
  validateOptions(results);

  final List<Pair> pairs = <Pair>[];
  if (results.wasParsed('input-dir')) {
    final Directory directory = Directory(results['input-dir'] as String);
    if (!directory.existsSync()) {
      print('input-dir ${directory.path} does not exist.');
      exit(1);
    }
    for (final File file
        in directory.listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.svg')) {
        continue;
      }

      String outputPath = '${file.path}.vec';

      // to specfic the output directory when parse multi svg
      if (results.wasParsed('out-dir')) {
        final Directory outDir = Directory(results['out-dir'] as String);
        //to add the output dirctory if it exist
        if (!outDir.existsSync()) {
          outDir.createSync();
        }
        outputPath = p.join(outDir.path, '${p.basename(file.path)}.vec');
      }

      pairs.add(Pair(file.path, outputPath));
    }
  } else {
    final String inputFilePath = results['input'] as String;
    final String outputFilePath =
        results['output'] as String? ?? '$inputFilePath.vec';
    pairs.add(Pair(inputFilePath, outputFilePath));
  }

  final bool maskingOptimizerEnabled = results['optimize-masks'] == true;
  final bool clippingOptimizerEnabled = results['optimize-clips'] == true;
  final bool overdrawOptimizerEnabled = results['optimize-overdraw'] == true;
  final bool tessellate = results['tessellate'] == true;
  final bool dumpDebug = results['dump-debug'] == true;
  final bool useHalfPrecisionControlPoints =
      results['use-half-precision-control-points'] == true;
  final int concurrency;
  if (results.wasParsed('concurrency')) {
    concurrency = int.parse(results['concurrency'] as String);
  } else {
    concurrency = Platform.numberOfProcessors;
  }

  final IsolateProcessor processor = IsolateProcessor(
    results['libpathops'] as String?,
    results['libtessellator'] as String?,
    concurrency,
  );
  if (!await processor.process(
    pairs,
    theme: _parseTheme(results),
    maskingOptimizerEnabled: maskingOptimizerEnabled,
    clippingOptimizerEnabled: clippingOptimizerEnabled,
    overdrawOptimizerEnabled: overdrawOptimizerEnabled,
    tessellate: tessellate,
    dumpDebug: dumpDebug,
    useHalfPrecisionControlPoints: useHalfPrecisionControlPoints,
  )) {
    exit(1);
  }
}
