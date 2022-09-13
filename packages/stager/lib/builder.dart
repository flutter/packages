// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/stager_app_generator.dart';

/// Generates a .stager_app.dart file with a runnable main that calls [runApp]
/// with a [StagerApp] displaying all titled [Scene]s.
Builder buildStagerApp(BuilderOptions options) => LibraryBuilder(
      StagerAppGenerator(),
      generatedExtension: '.stager_app.dart',
    );
