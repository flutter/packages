// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:data_assets/data_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:path/path.dart' as p;

import 'src/util/isolate_processor.dart';

/// Helper to build svg
Future<void> compileSvg(
  BuildInput input,
  BuildOutputBuilder output, {
  required String name,
  required Uri file,
}) async => compileSvgs(input, output, nameToFile: <String, Uri>{name: file});

/// Helper to build svgs
Future<void> compileSvgs(
  BuildInput input,
  BuildOutputBuilder output, {
  required Map<String, Uri> nameToFile,
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
    dumpDebug: true,
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
