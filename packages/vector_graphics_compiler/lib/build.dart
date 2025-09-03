// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:data_assets/data_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:path/path.dart' as p;

import 'src/util/isolate_processor.dart';
import 'vector_graphics_compiler.dart';

/// Helper to build svg
Future<void> compileSvg(
  BuildInput input,
  BuildOutputBuilder output, {
  required String name,
  required Uri file,
  Options options = const Options(),
}) async => compileSvgs(
  input,
  output,
  nameToFile: <String, Uri>{name: file},
  options: options,
);

/// Helper to build svgs
Future<void> compileSvgs(
  BuildInput input,
  BuildOutputBuilder output, {
  required Map<String, Uri> nameToFile,
  Options options = const Options(),
}) async {
  final IsolateProcessor processor = IsolateProcessor(
    null,
    null,
    Platform.numberOfProcessors,
  );

  final Map<String, Pair> pairs = nameToFile.map(
    (String name, Uri file) => MapEntry<String, Pair>(
      name,
      Pair(
        file.path,
        '${p.join(input.outputDirectory.path, p.basenameWithoutExtension(file.path))}.vec',
      ),
    ),
  );
  if (!await processor.process(
    pairs.values,
    maskingOptimizerEnabled: true,
    clippingOptimizerEnabled: true,
    overdrawOptimizerEnabled: true,
    tessellate: false,
    dumpDebug: options.dumpDebug,
    useHalfPrecisionControlPoints: false,
  )) {
    throw ArgumentError(
      'Did not succeed for ${pairs.map((String name, Pair e) => MapEntry<String, String>(name, '$name: ${e.inputPath} -> ${e.outputPath}')).values}',
    );
  }

  for (final MapEntry<String, Pair> entry in pairs.entries) {
    final String name = entry.key;
    final Pair pair = entry.value;
    final String packageName = input.packageName;

    output.assets.data.add(
      DataAsset(
        package: packageName,
        name: name,
        file: Uri.file(pair.outputPath),
      ),
    );
  }
}

/// Options for the processor.
class Options {
  // ignore: public_member_api_docs
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

  // ignore: public_member_api_docs
  final String? inputFilePath;

  // ignore: public_member_api_docs
  final String? outputFilePath;

  // ignore: public_member_api_docs
  final String? inputDirPath;

  // ignore: public_member_api_docs
  final String? outputDirPath;

  // ignore: public_member_api_docs
  final SvgTheme theme;

  // ignore: public_member_api_docs
  final bool maskingOptimizerEnabled;

  // ignore: public_member_api_docs
  final bool clippingOptimizerEnabled;

  // ignore: public_member_api_docs
  final bool overdrawOptimizerEnabled;

  // ignore: public_member_api_docs
  final bool tessellate;

  // ignore: public_member_api_docs
  final bool dumpDebug;

  // ignore: public_member_api_docs
  final bool useHalfPrecisionControlPoints;

  // ignore: public_member_api_docs
  final String? libpathops;

  // ignore: public_member_api_docs
  final String? libtessellator;

  // ignore: public_member_api_docs
  final int? concurrency;
}
