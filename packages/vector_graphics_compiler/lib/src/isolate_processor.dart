// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:pool/pool.dart';

import '../vector_graphics_compiler.dart';
import 'debug_format.dart';

/// The isolate processor distributes SVG compilation across multiple isolates.
class IsolateProcessor {
  /// Create a new [IsolateProcessor].
  IsolateProcessor(this._libpathops, this._libtessellator, int concurrency)
      : _pool = Pool(concurrency);

  final String? _libpathops;
  final String? _libtessellator;
  final Pool _pool;

  int _total = 0;
  int _current = 0;

  /// Process the provided input/output [Pair] objects into vector graphics.
  ///
  /// Returns whether all requests were successful.
  Future<bool> process(
    List<Pair> pairs, {
    SvgTheme theme = const SvgTheme(),
    required bool maskingOptimizerEnabled,
    required bool clippingOptimizerEnabled,
    required bool overdrawOptimizerEnabled,
    required bool tessellate,
    required bool dumpDebug,
  }) async {
    _total = pairs.length;
    _current = 0;
    bool failure = false;
    await Future.wait(eagerError: true, <Future<void>>[
      for (Pair pair in pairs)
        _process(
          pair,
          theme: theme,
          maskingOptimizerEnabled: maskingOptimizerEnabled,
          clippingOptimizerEnabled: clippingOptimizerEnabled,
          overdrawOptimizerEnabled: overdrawOptimizerEnabled,
          tessellate: tessellate,
          dumpDebug: dumpDebug,
          libpathops: _libpathops,
          libtessellator: _libtessellator,
        ).catchError((dynamic error, [StackTrace? stackTrace]) {
          failure = true;
          print('XXXXXXXXXXX ${pair.inputPath} XXXXXXXXXXXXX');
          print(error);
          print(stackTrace);
        }),
    ]);
    if (failure) {
      print('Some targets failed.');
    }
    return !failure;
  }

  static void _loadPathOps(String? libpathops) {
    if (libpathops != null && libpathops.isNotEmpty) {
      initializeLibPathOps(libpathops);
    } else if (!initializePathOpsFromFlutterCache()) {
      throw StateError('Could not find libpathops binary');
    }
  }

  static void _loadTessellator(String? libtessellator) {
    if (libtessellator != null && libtessellator.isNotEmpty) {
      initializeLibTesselator(libtessellator);
    } else if (!initializeTessellatorFromFlutterCache()) {
      throw StateError('Could not find libtessellator binary');
    }
  }

  Future<void> _process(
    Pair pair, {
    required bool maskingOptimizerEnabled,
    required bool clippingOptimizerEnabled,
    required bool overdrawOptimizerEnabled,
    required bool tessellate,
    required bool dumpDebug,
    required String? libpathops,
    required String? libtessellator,
    SvgTheme theme = const SvgTheme(),
  }) async {
    PoolResource? resource;
    try {
      resource = await _pool.request();
      await Isolate.run(() async {
        if (maskingOptimizerEnabled ||
            clippingOptimizerEnabled ||
            overdrawOptimizerEnabled) {
          _loadPathOps(libpathops);
        }
        if (tessellate) {
          _loadTessellator(libtessellator);
        }

        final Uint8List bytes = await encodeSvg(
          xml: File(pair.inputPath).readAsStringSync(),
          debugName: pair.inputPath,
          theme: theme,
          enableMaskingOptimizer: maskingOptimizerEnabled,
          enableClippingOptimizer: clippingOptimizerEnabled,
          enableOverdrawOptimizer: overdrawOptimizerEnabled,
        );
        File(pair.outputPath).writeAsBytesSync(bytes);
        if (dumpDebug) {
          final Uint8List debugBytes = dumpToDebugFormat(bytes);
          File(pair.outputPath + '.debug').writeAsBytesSync(debugBytes);
        }
      });
      _current++;
      print('Progress: $_current/$_total');
    } finally {
      resource?.release();
    }
  }
}

/// A combination of an input file and its output file.
class Pair {
  /// Create a new [Pair].
  const Pair(this.inputPath, this.outputPath);

  /// The path the SVG should be read from.
  final String inputPath;

  /// The path the vector graphic will be written to.
  final String outputPath;
}
