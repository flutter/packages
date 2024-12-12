// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

const String _flutterLogoString = '''
<svg xmlns="http://www.w3.org/2000/svg" width="384" height="384" fill="none"
  style="-webkit-print-color-adjust:exact">
  <defs>
    <clipPath id="a" class="frame-clip">
      <rect width="384" height="384" rx="40" ry="40" style="opacity:1" />
    </clipPath>
  </defs>
  <g clip-path="url(#a)">
    <rect width="384" height="384" class="frame-background" rx="40" ry="40" style="opacity:1" id="r"/>
    <g class="frame-children">
      <rect width="290" height="70" x="31" y="32" rx="30" ry="30"
        style="fill:#22c55e;fill-opacity:1" />
      <rect width="290" height="70" x="31" y="282" rx="30" ry="30"
        style="fill:#22c55e;fill-opacity:1" />
      <rect width="290" height="70" x="95" y="157" rx="30" ry="30"
        style="fill:#f59e0b;fill-opacity:1" />
    </g>
  </g>
</svg>
''';

void main() {
  runApp(const MyApp());
}

/// The main example app widget.
class MyApp extends StatefulWidget {
  /// Creates a new [MyApp].
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _controller =
      TextEditingController(text: _flutterLogoString);
  ByteData? _data;
  Timer? _debounce;
  int _svgLength = 0;
  int _gzSvgLength = 0;
  int _vgLength = 0;
  int _gzVgLength = 0;

  void _reloadSvg(String text) {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 250), () {
      compute((String svg) {
        final Uint8List compiledBytes = encodeSvg(
          xml: svg,
          debugName: '<string>',
          enableClippingOptimizer: false,
          enableMaskingOptimizer: false,
          enableOverdrawOptimizer: false,
        );
        return compiledBytes.buffer.asByteData();
      }, text, debugLabel: 'Load Bytes')
          .then((ByteData data) {
        if (!mounted) {
          return;
        }
        setState(() {
          // String is UTF-16.
          _svgLength = text.length * 2;
          _gzSvgLength = gzip.encode(utf8.encode(text)).length;
          _vgLength = data.lengthInBytes;
          _gzVgLength = gzip.encode(data.buffer.asUint8List()).length;
          _data = data;
        });
      }, onError: (Object error, StackTrace stack) {
        debugPrint(error.toString());
        debugPrint(stack.toString());
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _reloadSvg(_flutterLogoString);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _debounce = null;
    _data = null;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vector Graphics Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Center(
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 10),
              if (_data == null)
                const Placeholder()
              else
                VectorGraphic(
                  loader: RawBytesLoader(
                    _data!,
                  ),
                ),
              const Divider(),
              Text('SVG size (compressed): $_svgLength ($_gzSvgLength). '
                  'VG size (compressed): $_vgLength ($_gzVgLength)'),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _controller,
                  onChanged: _reloadSvg,
                  scrollPhysics: const NeverScrollableScrollPhysics(),
                  maxLines: null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A [BytesLoader] that passes on existing bytes.
class RawBytesLoader extends BytesLoader {
  /// Creates a [RawBytesLoader] that returns [data] directly.
  const RawBytesLoader(this.data);

  /// The data to return.
  final ByteData data;

  @override
  Future<ByteData> loadBytes(BuildContext? context) async {
    return data;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  bool operator ==(Object other) {
    return other is RawBytesLoader && other.data == data;
  }
}
