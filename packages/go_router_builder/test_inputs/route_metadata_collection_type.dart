// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

enum MetadataValue { private }

@TypedGoRoute<MetadataRoute>(path: '/metadata')
@RouteMetadata({'nested': <MetadataValue>[]})
class MetadataRoute extends GoRouteData with $MetadataRoute {
  const MetadataRoute();
}

mixin $MetadataRoute {}
