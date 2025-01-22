// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';

import 'about_page.dart';
import 'home_page.dart';

void main() {
  usePathUrlStrategy();
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      builder: (_, __) => const HomePage(title: 'Flutter Demo Home Page'),
    ),
    GoRoute(
      path: '/about',
      builder: (_, __) => const AboutPage(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: _router,
      // This blocks the About page button.
      debugShowCheckedModeBanner: false,
    );
  }
}
