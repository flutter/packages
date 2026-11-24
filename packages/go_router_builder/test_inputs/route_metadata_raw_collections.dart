// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: strict_raw_type

import 'package:go_router/go_router.dart';

@TypedGoRoute<MetadataRoute>(path: '/metadata')
@RouteMetadata(<String, Object?>{
  'lists': <List>[],
  'sets': <Set>{},
  'maps': <String, Map>{},
  'objects': <Object>[],
})
class MetadataRoute extends GoRouteData with $MetadataRoute {
  const MetadataRoute();
}

mixin $MetadataRoute {}
