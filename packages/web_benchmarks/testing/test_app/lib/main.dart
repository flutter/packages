// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'about_page.dart';
import 'home_page.dart';
import 'icon_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: 'home',
      routes: <String, WidgetBuilder>{
        'home': (_) => const HomePage(title: 'Flutter Demo Home Page'),
        'about': (_) => const AboutPage(),
        'icon_generator': (_) => const IconGeneratorPage(),
      },
    );
  }
}
