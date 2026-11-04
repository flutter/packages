// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'shared/metadata.dart' as data;

part 'route_metadata.g.dart';

void main() => runApp(const MetadataApp());

/// An example of metadata on generated routes.
class MetadataApp extends StatelessWidget {
  /// Creates the example application.
  const MetadataApp({super.key});

  @override
  Widget build(BuildContext context) =>
      MaterialApp.router(routerConfig: _router);
}

final GoRouter _router = GoRouter(
  routes: $appRoutes,
  initialLocation: '/library/1',
);

// #docregion routeMetadata
/// A library route with metadata shared by its descendants.
@TypedGoRoute<LibraryRoute>(
  path: '/library/:id',
  routes: <TypedRoute<RouteData>>[
    TypedRelativeGoRoute<PreviewRoute>(path: 'preview'),
  ],
)
@RouteMetadata(<String, Object?>{
  'section': 'library',
  'requiresAuth': true,
  'labels': <String>{'books'},
})
class LibraryRoute extends GoRouteData with $LibraryRoute {
  /// Creates a library route for [id].
  const LibraryRoute(this.id);

  /// The library identifier from the path.
  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) => Scaffold(
    appBar: AppBar(title: Text('Library $id')),
    body: TextButton(
      onPressed: () => const PreviewRoute().goRelative(context),
      child: const Text('Preview'),
    ),
  );
}
// #enddocregion routeMetadata

/// A child route whose metadata overrides the parent's authentication flag.
@RouteMetadata(data.previewMetadata)
class PreviewRoute extends RelativeGoRouteData with $PreviewRoute {
  /// Creates the preview route.
  const PreviewRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => Scaffold(
    appBar: AppBar(title: Text(state.metadata['title']! as String)),
    body: Text('Section: ${state.metadata['section']}'),
  );
}
