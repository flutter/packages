// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// This sample app demonstrates how to provide a codec for complex extra data.
void main() => runApp(const MyApp());

/// The router configuration.
final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder:
          (BuildContext context, GoRouterState state) => const HomeScreen(),
    ),
  ],
  extraCodec: const MyExtraCodec(),
);

/// The main app.
class MyApp extends StatelessWidget {
  /// Constructs a [MyApp]
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}

/// The home screen.
class HomeScreen extends StatelessWidget {
  /// Constructs a [HomeScreen].
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "If running in web, use the browser's backward and forward button to test extra codec after setting extra several times.",
            ),
            Text(
              'The extra for this page is: ${GoRouterState.of(context).extra}',
            ),
            ElevatedButton(
              onPressed: () => context.go('/', extra: ComplexData1('data')),
              child: const Text('Set extra to ComplexData1'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/', extra: ComplexData2('data')),
              child: const Text('Set extra to ComplexData2'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A complex class.
class ComplexData1 {
  /// Create a complex object.
  ComplexData1(this.data);

  /// The data.
  final String data;

  @override
  String toString() => 'ComplexData1(data: $data)';
}

/// A complex class.
class ComplexData2 {
  /// Create a complex object.
  ComplexData2(this.data);

  /// The data.
  final String data;

  @override
  String toString() => 'ComplexData2(data: $data)';
}

/// A codec that can serialize both [ComplexData1] and [ComplexData2].
class MyExtraCodec extends Codec<Object?, Object?> {
  /// Create a codec.
  const MyExtraCodec();
  @override
  Converter<Object?, Object?> get decoder => const _MyExtraDecoder();

  @override
  Converter<Object?, Object?> get encoder => const _MyExtraEncoder();
}

class _MyExtraDecoder extends Converter<Object?, Object?> {
  const _MyExtraDecoder();
  @override
  Object? convert(Object? input) {
    if (input == null) {
      return null;
    }
    final List<Object?> inputAsList = input as List<Object?>;
    if (inputAsList[0] == 'ComplexData1') {
      return ComplexData1(inputAsList[1]! as String);
    }
    if (inputAsList[0] == 'ComplexData2') {
      return ComplexData2(inputAsList[1]! as String);
    }
    throw FormatException('Unable to parse input: $input');
  }
}

class _MyExtraEncoder extends Converter<Object?, Object?> {
  const _MyExtraEncoder();
  @override
  Object? convert(Object? input) {
    if (input == null) {
      return null;
    }
    switch (input) {
      case ComplexData1 _:
        return <Object?>['ComplexData1', input.data];
      case ComplexData2 _:
        return <Object?>['ComplexData2', input.data];
      default:
        throw FormatException('Cannot encode type ${input.runtimeType}');
    }
  }
}
