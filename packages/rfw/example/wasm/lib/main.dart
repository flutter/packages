// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is hand-formatted.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:rfw/rfw.dart';

import 'platforms/platform.dart';
import 'platforms/stub.dart'
  if (dart.library.io) 'platforms/desktop.dart'
  if (dart.library.js_interop) 'platforms/web.dart';

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
  final Runtime _rfwRuntime = Runtime();
  final DynamicContent _rfwData = DynamicContent();

  late final Network _network;
  late final Wasm _wasm;

  @override
  void initState() {
    super.initState();
    RendererBinding.instance.deferFirstFrame();
    _rfwRuntime.update(const LibraryName(<String>['core', 'widgets']), createCoreWidgets());

    // These produce platform specific implementations for network fetching
    // and Wasm loading and calling.
    _network = NetworkImplementation();
    _wasm = WasmImplementation();

    _loadRfwAndWasm();
  }

  Future<void> _loadRfwAndWasm() async {
    final List<int> interfaceBytes = await _network.get(interfaceUrl);
    _rfwRuntime.update(
      const LibraryName(<String>['main']),
      decodeLibraryBlob(Uint8List.fromList(interfaceBytes)),
    );

    await _wasm.loadModule(logicUrl);

    _updateData();
    setState(() { RendererBinding.instance.allowFirstFrame(); });
  }

  void _updateData() {
    // Retrieve the calculator value from Wasm.
    final int value = _wasm.call('value', null).toInt();
    // Push the calculator value to RFW.
    _rfwData.update(
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
      runtime: _rfwRuntime,
      data: _rfwData,
      widget: const FullyQualifiedWidgetName(LibraryName(<String>['main']), 'root'),
      onEvent: (String name, DynamicMap arguments) {
        final Object? rfwArguments = arguments['arguments'];
        // Call Wasm calculator function.
        _wasm.call(name, rfwArguments == null
            ? const <Object>[]
            : rfwArguments as List<Object?>);
        _updateData();
      },
    );
  }
}
