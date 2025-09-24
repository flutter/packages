// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs, unreachable_from_main

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'custom_encoder_example.g.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  App({super.key});

  @override
  Widget build(BuildContext context) =>
      MaterialApp.router(routerConfig: _router, title: _appTitle);

  final GoRouter _router = GoRouter(routes: $appRoutes);
}

@TypedGoRoute<HomeRoute>(
  path: '/',
  name: 'Home',
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<EncodedRoute>(path: 'encoded'),
  ],
)
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

class EncodedRoute extends GoRouteData with $EncodedRoute {
  const EncodedRoute(this.token);

  @CustomParameterCodec(encode: toBase64, decode: fromBase64)
  final String token;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      EncodedScreen(token: token);
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text(_appTitle)),
    body: ListView(
      children: <Widget>[
        ListTile(
          title: const Text('Base64Token'),
          onTap: () => const EncodedRoute('Base64Token').go(context),
        ),
        ListTile(
          title: const Text('from url only'),
          // like in deep links
          onTap: () => context.go('/encoded?token=ZW5jb2RlZCBpbmZvIQ'),
        ),
      ],
    ),
  );
}

class EncodedScreen extends StatelessWidget {
  const EncodedScreen({super.key, required this.token});
  final String token;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Base64Token')),
    body: Center(child: Text(token)),
  );
}

String fromBase64(String value) {
  return const Utf8Decoder().convert(
    base64Url.decode(base64Url.normalize(value)),
  );
}

String toBase64(String value) {
  return base64Url.encode(const Utf8Encoder().convert(value));
}

const String _appTitle = 'GoRouter Example: custom encoder';
