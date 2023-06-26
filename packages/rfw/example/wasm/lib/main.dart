// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is hand-formatted.

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:js/js_util.dart';
import 'package:rfw/rfw.dart';
import 'package:web/web.dart';

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
  // This is this object https://developer.mozilla.org/en-US/docs/WebAssembly/JavaScript_interface/Instance/exports
  // which contains the Wasm memory and functions.
  late final JSObject _wasmExports;

  @override
  void initState() {
    super.initState();
    RendererBinding.instance.deferFirstFrame();
    _runtime.update(const LibraryName(<String>['core', 'widgets']), createCoreWidgets());
    _loadRfwAndWasm();
  }

  Future<void> _loadRfwAndWasm() async {
    final Response interfaceResponse =
      await promiseToFuture<Response>(window.fetch(interfaceUrl.toJS));
    final Response logicResponse =
      await promiseToFuture<Response>(window.fetch(logicUrl.toJS));

    final ByteBuffer interfaceByteBuffer =
      await promiseToFuture(interfaceResponse.arrayBuffer());
    final ByteBuffer logicByteBuffer =
      await promiseToFuture(logicResponse.arrayBuffer());

    _runtime.update(
      const LibraryName(<String>['main']),
      decodeLibraryBlob(interfaceByteBuffer.asUint8List()),
    );
    final Instance wasmInstance = (
      await promiseToFuture<WebAssemblyInstantiatedSource>(
        WebAssembly.instantiate(logicByteBuffer.toJS)
      )
    ).instance;
    _wasmExports = wasmInstance.exports;

    _updateData();
    setState(() { RendererBinding.instance.allowFirstFrame(); });
  }

  void _updateData() {
    // Retrieve the calculator value from Wasm.
    final int value =
      callMethod(_wasmExports, 'value', const <Object>[]).toInt();
    // Push the calculator value to RFW.
    _data.update(
      'value',
      <String, Object?>{ 'numeric': value, 'string': value.toString() },
    );
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
        final Object? rfwArguments = arguments['arguments'];
        // Call Wasm calculator function.
        callMethod(
          _wasmExports,
          name,
          rfwArguments == null
              ? const <Object>[]
              : rfwArguments as List<Object?>,
        );
        _updateData();
      },
    );
  }
}
