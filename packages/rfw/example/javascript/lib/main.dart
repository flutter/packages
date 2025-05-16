// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:jsf/jsf.dart';
import 'package:rfw/rfw.dart';

void main() {
  runApp(
    WidgetsApp(
      color: const Color(0xFF000000),
      builder: (BuildContext context, Widget? navigator) => const Example(),
    ),
  );
}

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  final JsRuntime _js = JsRuntime();
  final Runtime _runtime = Runtime();
  final DynamicContent _data = DynamicContent();

  @override
  void initState() {
    super.initState();
    RendererBinding.instance.deferFirstFrame();

    _runtime.update(
      const LibraryName(<String>['core', 'widgets']),
      createCoreWidgets(),
    );

    _loadAssets();
  }

  Future<void> _loadAssets() async {
    final ByteData interfaceBytes =
        await rootBundle.load('assets/calculator.rfw');
    final String script = await rootBundle.loadString('assets/calculator.js');

    _runtime.update(
      const LibraryName(<String>['main']),
      decodeLibraryBlob(interfaceBytes.buffer.asUint8List()),
    );

    _js.execInitScript(script);
    _updateData();

    setState(() {
      RendererBinding.instance.allowFirstFrame();
    });
  }

  void _updateData() {
    final String result = _js.eval('value();');
    final int value = int.tryParse(result) ?? 0;

    _data.update('value',
        <String, Object>{'numeric': value, 'string': value.toString()});
  }

  List<Object?> _asList(Object? value) =>
      value is List ? value : const <Object?>[];

  @override
  Widget build(BuildContext context) {
    if (!RendererBinding.instance.sendFramesToEngine) {
      return const SizedBox.shrink();
    }

    return RemoteWidget(
      runtime: _runtime,
      data: _data,
      widget: const FullyQualifiedWidgetName(
        LibraryName(<String>['main']),
        'root',
      ),
      onEvent: (String name, DynamicMap arguments) {
        final List<Object?> args = _asList(arguments['arguments']);
        _js.eval('$name(${args.join(',')});');
        _updateData();
      },
    );
  }

  @override
  void dispose() {
    _js.dispose();
    super.dispose();
  }
}
