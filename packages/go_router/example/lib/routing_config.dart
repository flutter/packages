// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// This app shows how to dynamically add more route into routing config
void main() => runApp(const MyApp());

/// The main app.
class MyApp extends StatefulWidget {
  /// Constructs a [MyApp]
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isNewRouteAdded = false;

  late final ValueNotifier<RoutingConfig> myConfig =
      ValueNotifier<RoutingConfig>(_generateRoutingConfig());

  late final GoRouter router = GoRouter.routingConfig(
    routingConfig: myConfig,
    errorBuilder:
        (_, GoRouterState state) => Scaffold(
          appBar: AppBar(title: const Text('Page not found')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('${state.uri} does not exist'),
                ElevatedButton(
                  onPressed: () => router.go('/'),
                  child: const Text('Go to home'),
                ),
              ],
            ),
          ),
        ),
  );

  RoutingConfig _generateRoutingConfig() {
    return RoutingConfig(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (_, __) {
            return Scaffold(
              appBar: AppBar(title: const Text('Home')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed:
                          isNewRouteAdded
                              ? null
                              : () {
                                setState(() {
                                  isNewRouteAdded = true;
                                  // Modify the routing config.
                                  myConfig.value = _generateRoutingConfig();
                                });
                              },
                      child:
                          isNewRouteAdded
                              ? const Text('A route has been added')
                              : const Text('Add a new route'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        router.go('/new-route');
                      },
                      child: const Text('Try going to /new-route'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (isNewRouteAdded)
          GoRoute(
            path: '/new-route',
            builder: (_, __) {
              return Scaffold(
                appBar: AppBar(title: const Text('A new Route')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () => router.go('/'),
                        child: const Text('Go to home'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: router);
  }
}
