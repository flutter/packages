// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/stager_app_generator.dart';

Builder buildStagerApp(BuilderOptions options) => LibraryBuilder(
      StagerAppGenerator(),
      generatedExtension: '.stager_app.dart',
    );
