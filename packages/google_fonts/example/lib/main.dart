// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'example_font_selection.dart';
import 'example_simple.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light(useMaterial3: true),
      home: DefaultTabController(
        animationDuration: Duration.zero,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Google Fonts Demo'),
            bottom: const TabBar(
              tabs: <Widget>[Tab(text: 'Simple'), Tab(text: 'Select a font')],
            ),
          ),
          body: const TabBarView(
            children: <Widget>[ExampleSimple(), ExampleFontSelection()],
          ),
        ),
      ),
    );
  }
}
