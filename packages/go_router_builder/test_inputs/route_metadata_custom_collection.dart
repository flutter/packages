// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

@TypedGoRoute<MetadataRoute>(path: '/metadata')
@RouteMetadata(<String, Object?>{'values': IntList()})
class MetadataRoute extends GoRouteData with $MetadataRoute {
  const MetadataRoute();
}

class IntList implements List<int> {
  const IntList();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

mixin $MetadataRoute {}
