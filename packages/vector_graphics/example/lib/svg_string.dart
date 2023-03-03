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
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 953 272">
  <path
    d="M136.28 4.09L217.95 4 80.93 140.95l-35.71 35.51-40.63-40.68L136.28 4.09zm-.76 122.28c1.06-1.4 3.01-.71 4.49-.89l77.87.02-70.97 70.9-40.84-40.59 29.45-29.44z"
    fill="#44d1fd" />
  <path opacity=".54"
    d="M332.74 61.21l89.03.03-.01 17.53c-23.29 0-46.59-.07-69.89.03-1.78.59-.94 2.82-1.14 4.19l.07 47.15c.59 1.77 2.83.92 4.21 1.14l59.76-.03v17.51c-18.58-.01-37.15-.01-55.73 0-2.76-.01-5.55-.18-8.28.29l-.21 66.56c-5.99-.24-11.97-.02-17.96-.15l-.01-151.42.16-2.83zm110.62.03h18.28l.01 104.76-.2 49.33c-5.95-.11-11.9-.14-17.84.02-.46-2.44-.27-4.92-.27-7.38l.02-146.73zm178.92 12.99l18.34.01.03 31c8.97.22 17.99-.4 26.94.31-.25 5.56-.04 11.12-.14 16.68-8.92.02-17.83.09-26.74-.04l-.07 61.74c.19 5.72 1.41 12.63 6.97 15.58 6.35 3.61 14.15 1.91 20.16-1.57v17.96c-6.62 3-14.17 3.36-21.28 2.39-10.02-1.53-19.62-8.36-22.65-18.29-2.01-5.44-1.55-11.31-1.59-16.99l-.04-60.13-.45-.51c-6.33-.34-12.68.05-19.02-.17.04-5.66-.22-11.32.14-16.97 6.44-.11 12.91.29 19.34-.2l.06-30.8zm77.48-.06c6.1.21 12.2-.07 18.29.14l.42.46c.23 10.18-.31 20.39.24 30.55 8.69-.16 17.38-.03 26.06-.08l.06 16.86c-8.74.33-17.51.13-26.25.08l-.1 62.81c-.01 5.47 1.57 11.94 6.86 14.63 6.49 3.54 14.36 1.72 20.39-1.9l-.02 18.06c-6.43 2.9-13.68 3.46-20.62 2.66-9.01-1.2-17.83-6.29-22.06-14.54-2.04-4.32-3.18-9.1-3.37-13.87v-67.78c-6.33-.01-12.65.02-18.97 0l.04-17.07c6.23.17 12.46-.05 18.69.16.66-10.36-.05-20.79.34-31.17zm89.02 31.65c12.66-5.25 27.27-5.35 40.2-.95 14.81 5.11 26.27 18.03 30.47 33.02 2.75 8.31 2.64 17.14 2.25 25.78l-87.05.09c.72 9.27 3.49 18.72 9.93 25.68 9.15 10.67 24.9 14.63 38.2 10.44 9.33-2.75 16.61-9.93 21.4-18.18 5.3 2.37 10.45 5.07 15.73 7.5-7.22 13.76-20.35 24.69-35.78 27.65-12.67 2.37-26.53 2.43-38.15-3.83-15.08-7.49-25.46-22.74-28.42-39.14-2.15-12.6-1.48-25.93 3.26-37.89 4.97-13.13 15.02-24.5 27.96-30.17m6.89 15.81c-10.65 4.92-17.51 15.85-19.65 27.13l66.76-.21c-1.06-7.37-3.68-14.86-9.08-20.19-9.46-10.14-25.63-12.12-38.03-6.73zm105.66 1.45c6.97-16.93 28.38-25.82 45.31-18.73v19.76c-7.11-2.8-15.08-4.53-22.59-2.32-10.26 3.05-17.85 12.2-20.76 22.27-2 6.8-1.25 13.9-1.17 20.87-.78 9.02.39 18.05-.2 27.07.48 7.79-.42 15.58.24 23.38-6.22.3-12.44-.02-18.65.19-.36-23.51-.05-47.03-.15-70.55l.14-39.59c5.83.16 11.67-.02 17.51.12.53 5.84-.65 11.71.32 17.53zm-413.47-17.87c6.2.26 12.45-.37 18.62.33l-.09 65.54c-.06 8.01 1.08 16.76 6.62 22.98 7.15 7.92 19.26 9.37 29.04 6.24 13.07-4.68 22.19-18.52 21.66-32.36l.2-62.73 18.67.04-.11 110.05c-5.92-.1-11.83 0-17.74-.07l-.07-15.66c-3.83 4.81-7.85 9.68-13.34 12.71-11.24 7.09-25.5 8.03-38.09 4.4-8.12-2.45-15.19-8.14-19.26-15.58-4.83-8.18-6.05-17.85-6.33-27.17l.22-68.72z" />
  <path fill="#1fbcfd" d="M65.36 196.47l40.71-40.66 40.84 40.59.17.18-41 40.62-40.72-40.73z" />
  <path fill="#08589c"
    d="M106.08 237.2l41-40.62 70.83 70.9c-26.68.06-53.35-.02-80.02.04-1.52.34-2.46-1.05-3.43-1.91l-28.38-28.41z" />
</svg>
''';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
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
              _data == null
                  ? const Placeholder()
                  : VectorGraphic(
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

class RawBytesLoader extends BytesLoader {
  const RawBytesLoader(this.data);

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
