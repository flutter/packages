// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_android/file_selector_android.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';

import 'home_page.dart';
import 'open_image_page.dart';
import 'open_multiple_images_page.dart';
import 'open_text_page.dart';

/// Entry point for integration tests that require espresso.
@pragma('vm:entry-point')
void integrationTestMain() {
  enableFlutterDriverExtension();
  main();
}

void main() {
  FileSelectorPlatform.instance = FileSelectorAndroid();
  runApp(const MyApp());
}

/// MyApp is the Main Application.
class MyApp extends StatelessWidget {
  /// Default Constructor
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Selector Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
      routes: <String, WidgetBuilder>{
        '/open/image': (BuildContext context) => const OpenImagePage(),
        '/open/images': (BuildContext context) =>
            const OpenMultipleImagesPage(),
        '/open/text': (BuildContext context) => const OpenTextPage(),
      },
    );
  }
}
