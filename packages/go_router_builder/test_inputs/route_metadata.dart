// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

import 'route_metadata.dart.sources/constants.dart';

@TypedGoRoute<MetadataRoute>(
  path: '/metadata/:id',
  routes: <TypedRoute<RouteData>>[TypedRelativeGoRoute<MetadataChild>(path: 'child')],
)
@RouteMetadata({
  'requiresAuth': true,
  'section': 'library',
  'values': [null, false, 42, -1.5, r'dollar$quote"'],
  'nested': {'key': 'value'},
  'set': <String>{'a', 'b'},
})
class MetadataRoute extends GoRouteData with $MetadataRoute {
  const MetadataRoute(this.id);
  final String id;
}

@RouteMetadata({'requiresAuth': false, 'title': 'Preview'})
class MetadataChild extends RelativeGoRouteData with $MetadataChild {
  const MetadataChild();
}

@TypedGoRoute<ImportedMetadataRoute>(path: '/imported')
@RouteMetadata(importedMetadata)
class ImportedMetadataRoute extends GoRouteData with $ImportedMetadataRoute {
  const ImportedMetadataRoute();
}

@TypedGoRoute<EmptyMetadataRoute>(path: '/empty')
@RouteMetadata({})
class EmptyMetadataRoute extends GoRouteData with $EmptyMetadataRoute {
  const EmptyMetadataRoute();
}

mixin $MetadataRoute {}

mixin $MetadataChild {}

mixin $ImportedMetadataRoute {}

mixin $EmptyMetadataRoute {}
