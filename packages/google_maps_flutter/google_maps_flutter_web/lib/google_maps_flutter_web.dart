// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library google_maps_flutter_web;

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps/google_maps_visualization.dart' as visualization;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:sanitize_html/sanitize_html.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:web/web.dart' as web;
import 'package:web/web.dart';

import 'src/dom_window_extension.dart';
import 'src/google_maps_inspector_web.dart';
import 'src/map_styler.dart';
import 'src/marker_clustering.dart';
import 'src/third_party/to_screen_location/to_screen_location.dart';
import 'src/types.dart';
import 'src/utils.dart';

part 'src/circle.dart';
part 'src/circles.dart';
part 'src/convert.dart';
part 'src/google_maps_controller.dart';
part 'src/google_maps_flutter_web.dart';
part 'src/heatmap.dart';
part 'src/heatmaps.dart';
part 'src/marker.dart';
part 'src/markers.dart';
part 'src/overlay.dart';
part 'src/overlays.dart';
part 'src/polygon.dart';
part 'src/polygons.dart';
part 'src/polyline.dart';
part 'src/polylines.dart';
