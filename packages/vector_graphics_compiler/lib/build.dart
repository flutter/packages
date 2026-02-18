// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:data_assets/data_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:path/path.dart' as p;

import 'src/util/isolate_processor.dart';
import 'vector_graphics_compiler.dart';

/// The magic prefix to prevent accidental non-const loading.
const magicPrefix = 'svg1234:';

/// Helper to add svg
Future<void> addSvg(
  BuildInput input,
  BuildOutputBuilder output, {
  required String file,
  Options options = const Options(),

  /// Whether this asset should be treeshaken if it's not used. Means that it
  /// can only be loaded by the [ConstAssetBytesLoader] which knows about the
  /// magic prefix to prevent accidental treeshaking.
  required bool treeshakeable,
}) async {
  final String prefix = treeshakeable ? magicPrefix : '';
  // If we are linking, then do the compilation there, as we can compile all SVGs at once
  if (input.config.linkingEnabled) {
    output.assets.data.add(
      DataAsset(
        package: input.packageName,
        name: prefix + file,
        file: input.packageRoot.resolve(file),
      ),
      routing: const ToLinkHook('vector_graphics_compiler'),
    );
  } else {
    // If we are not linking, then do the compilation here
    final Map<String, IOPair> pairs = await _compileSvgs(options, {
      prefix + file: input.packageRoot.resolve(file),
    }, input.outputDirectory);
    for (final MapEntry<String, IOPair>(
          key: String name,
          value: IOPair(output: String outputPath),
        )
        in pairs.entries) {
      output.assets.data.add(
        DataAsset(
          package: input.packageName,
          name: name,
          file: Uri.file(outputPath),
        ),
      );
    }
  }
}

/// Helper to build svgs
Future<void> compileSvgs(
  LinkInput input,
  LinkOutputBuilder output, {
  required Map<String, Uri> nameToFile,
  Options options = const Options(),
}) async {
  final Map<String, IOPair> pairs = await _compileSvgs(
    options,
    nameToFile,
    input.outputDirectory,
  );
  for (final MapEntry<String, IOPair>(
        key: String name,
        value: IOPair(output: String outputPath),
      )
      in pairs.entries) {
    output.assets.data.add(
      DataAsset(
        package: input.packageName,
        name: name,
        file: Uri.file(outputPath),
      ),
    );
  }
}

Future<Map<String, IOPair>> _compileSvgs(
  Options options,
  Map<String, Uri> nameToFile,
  Uri outputDirectory,
) async {
  final processor = IsolateProcessor(
    options.libpathops,
    options.libtessellator,
    options.concurrency ?? Platform.numberOfProcessors,
  );

  final Map<String, IOPair> pairs = nameToFile.map(
    (String name, Uri file) => MapEntry<String, IOPair>(
      name,
      IOPair(
        file.path,
        '${p.join(outputDirectory.path, p.basenameWithoutExtension(file.path))}.vec',
      ),
    ),
  );
  if (!await processor.process(
    pairs.values,
    maskingOptimizerEnabled: options.maskingOptimizerEnabled,
    clippingOptimizerEnabled: options.clippingOptimizerEnabled,
    overdrawOptimizerEnabled: options.overdrawOptimizerEnabled,
    tessellate: options.tessellate,
    dumpDebug: options.dumpDebug,
    useHalfPrecisionControlPoints: options.useHalfPrecisionControlPoints,
    theme: options.theme,
  )) {
    throw ArgumentError(
      'Did not succeed for ${pairs.map((String name, IOPair e) => MapEntry<String, String>(name, '$name: ${e.input} -> ${e.output}')).values}',
    );
  }
  return pairs;
}

/// Options for the processor.
class Options {
  /// Create new options for the svg processor.
  const Options({
    this.inputFilePath,
    this.outputFilePath,
    this.inputDirPath,
    this.outputDirPath,
    this.theme = const SvgTheme(),
    this.maskingOptimizerEnabled = true,
    this.clippingOptimizerEnabled = true,
    this.overdrawOptimizerEnabled = true,
    this.tessellate = false,
    this.dumpDebug = false,
    this.useHalfPrecisionControlPoints = false,
    this.libpathops,
    this.libtessellator,
    this.concurrency,
  });

  /// The path to a file containing a single SVG.
  final String? inputFilePath;

  /// The path to a file where the resulting vector_graphic will be written.
  ///
  /// If not provided, defaults to `<input-file>.vec`.
  final String? outputFilePath;

  /// The path to a directory containing one or more SVGs.
  ///
  /// Only includes files that end with `.svg`. Cannot be combined with `inputFilePath` or `outputFilePath`.
  final String? inputDirPath;

  /// The output directory path.
  ///
  /// Use it with `inputDirPath` to specify the output directory.
  final String? outputDirPath;

  /// The basis for font size based values (i.e. em, ex) and the value of the 'currentColor' attribute.
  final SvgTheme theme;

  /// Allows for the masking optimizer to be enabled or disabled.
  final bool maskingOptimizerEnabled;

  /// Allows for the clipping optimizer to be enabled or disabled.
  final bool clippingOptimizerEnabled;

  /// Allows for the overdraw optimizer to be enabled or disabled.
  final bool overdrawOptimizerEnabled;

  /// Converts path fills into a tessellated shape.
  ///
  /// This will improve raster times at the cost of slightly larger file sizes.
  final bool tessellate;

  /// Dumps a human-readable debugging format alongside the compiled asset.
  final bool dumpDebug;

  /// Converts path control points into IEEE 754-2008 half-precision floating-point values.
  ///
  /// This reduces file size at the cost of lost precision at larger values.
  final bool useHalfPrecisionControlPoints;

  /// The path to a `libpathops` dynamic library.
  final String? libpathops;

  /// The path to a `libtessellator` dynamic library.
  final String? libtessellator;

  /// The maximum number of SVG processing isolates to spawn at once.
  ///
  /// If not provided, defaults to the number of cores.
  final int? concurrency;
}
