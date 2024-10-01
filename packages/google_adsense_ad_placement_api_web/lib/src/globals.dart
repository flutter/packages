// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

import 'ad_placement_api.dart';
import 'ad_placement_api_js_interop.dart';

/// Wraps the javascript window object to get loaded Ad Sense Ad Placement API.
@JS()
external AdPlacementApiJSObject get window;

/// Main entrypoint for the library, named this way to mirror the API for the JS sdk
// ignore: non_constant_identifier_names
AdPlacementApi adPlacementApi = AdPlacementApi(window);
