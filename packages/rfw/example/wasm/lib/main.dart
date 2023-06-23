// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is hand-formatted.

import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:js/js.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:rfw/rfw.dart';
// import 'package:wasm/wasm.dart';

const String urlPrefix = 'https://raw.githubusercontent.com/flutter/packages/main/packages/rfw/example/wasm/logic';

const String interfaceUrl = '$urlPrefix/calculator.rfw';
const String logicUrl = '$urlPrefix/calculator.wasm';

void main() {
  runApp(WidgetsApp(color: const Color(0xFF000000), builder: (BuildContext context, Widget? navigator) => const Example()));
}

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  final Runtime _runtime = Runtime();
  final DynamicContent _data = DynamicContent();
  late final WasmInstance _logic;

  @override
  void initState() {
    super.initState();
    RendererBinding.instance.deferFirstFrame();
    _runtime.update(const LibraryName(<String>['core', 'widgets']), createCoreWidgets());
    _loadLogic();
  }

  late final WasmFunction _dataFetcher;

  Future<void> _loadLogic() async {
    final DateTime expiryDate = DateTime.now().subtract(const Duration(hours: 6));

    final uiBytes = (await get(Uri.parse(interfaceUrl))).bodyBytes;
    final logicBytes = (await get(Uri.parse(logicUrl))).bodyBytes;

    _runtime.update(const LibraryName(<String>['main']), decodeLibraryBlob(uiBytes));

    _logic = WasmModule(await logicFile.readAsBytes()).builder().build();
    _dataFetcher = _logic.lookupFunction('value') as WasmFunction;
    _updateData();
    setState(() { RendererBinding.instance.allowFirstFrame(); });
  }

  void _updateData() {
    final dynamic value = _dataFetcher.apply(const <Object?>[]);
    _data.update('value', <String, Object?>{ 'numeric': value, 'string': value.toString() });
  }

  List<Object?> _asList(Object? value) {
    if (value is List<Object?>) {
      return value;
    }
    return const <Object?>[];
  }

  @override
  Widget build(BuildContext context) {
    if (!RendererBinding.instance.sendFramesToEngine) {
      return const SizedBox.shrink();
    }
    return RemoteWidget(
      runtime: _runtime,
      data: _data,
      widget: const FullyQualifiedWidgetName(LibraryName(<String>['main']), 'root'),
      onEvent: (String name, DynamicMap arguments) {
        final WasmFunction function = _logic.lookupFunction(name) as WasmFunction;
        function.apply(_asList(arguments['arguments']));
        _updateData();
      },
    );
  }
}
