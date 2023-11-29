// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:css_colors/css_colors.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CSS Color Example'),
          backgroundColor: CSSColors.orange,
        ),
        body: Center(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), color: CSSColors.blue),
            padding: const EdgeInsets.all(15),
            child: const Text(
              'Flutter is Great',
              style: TextStyle(color: CSSColors.white),
            ),
          ),
        ),
      ),
    );
  }
}
