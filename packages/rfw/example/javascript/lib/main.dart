// Copyright 2025 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
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
    _loadRemoteAssets();
  }

  Future<void> _loadRemoteAssets() async {
    final http.Response rfwResponse = await http.get(
      Uri.parse('https://moluopro.atomgit.net/web/applet/calculator.rfw'),
    );

    final http.Response jsResponse = await http.get(
      Uri.parse('https://moluopro.atomgit.net/web/applet/calculator.js'),
    );

    _runtime.update(
      const LibraryName(<String>['main']),
      decodeLibraryBlob(rfwResponse.bodyBytes),
    );

    _js.execInitScript(jsResponse.body);
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

  List<Object?> _asList(Object? value) {
    return value is List<Object?> ? value : const <Object?>[];
  }

  @override
  Widget build(BuildContext context) {
    if (!RendererBinding.instance.sendFramesToEngine) {
      return const Center(child: SizedBox.expand());
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
        final String argsString = args.join(',');
        _js.eval('$name($argsString);');
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
