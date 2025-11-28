// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The main entry point for the GoRouter refresh example app.
void main() => runApp(const RefreshExampleApp());

/// The root widget of the GoRouter refresh example application.
class RefreshExampleApp extends StatelessWidget {
  /// Creates a const [RefreshExampleApp].
  const RefreshExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GoRouter Refresh Example',
      routerConfig: _router,
    );
  }

  /// The GoRouter configuration.
  GoRouter get _router => GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder:
            (BuildContext context, GoRouterState state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/simple',
        builder:
            (BuildContext context, GoRouterState state) =>
                SimpleRefreshScreen(key: state.pageKey),
      ),
      GoRoute(
        path: '/nested/:id',
        builder:
            (BuildContext context, GoRouterState state) =>
                NestedScreen(id: state.pathParameters['id']!),
        routes: <RouteBase>[
          GoRoute(
            path: 'detail',
            builder: (BuildContext context, GoRouterState state) =>
                DetailScreen(parentId: state.pathParameters['id']),
          ),
        ],
      ),
      ShellRoute(
        builder:
            (BuildContext context, GoRouterState state, Widget child) =>
                ShellScreen(child: child),
        routes: <RouteBase>[
          GoRoute(
            path: '/shell/page1',
            builder:
                (BuildContext context, GoRouterState state) =>
                    ShellPage1(key: state.pageKey),
          ),
          GoRoute(
            path: '/shell/page2',
            builder:
                (BuildContext context, GoRouterState state) =>
                    ShellPage2(key: state.pageKey),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) {
          return StatefulShellScreen(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/stateful/tab1',
                builder:
                    (BuildContext context, GoRouterState state) =>
                        StatefulTab1(key: state.pageKey),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/stateful/tab2',
                builder:
                    (BuildContext context, GoRouterState state) =>
                        StatefulTab2(key: state.pageKey),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/stateful/tab3',
                builder:
                    (BuildContext context, GoRouterState state) =>
                        StatefulTab3(key: state.pageKey),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

// Data Service
/// A service that provides data.
class DataService {
  DataService._();

  /// The singleton instance of [DataService].
  static final DataService instance = DataService._();

  final Random _random = Random();
  int _counter = 0;

  /// Returns a string with the current counter and timestamp.
  String getData() {
    _counter++;
    return 'Data #$_counter - ${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Returns a random number between 0 and 99.
  int getRandomNumber() => _random.nextInt(100);
}

/// The home screen.
class HomeScreen extends StatelessWidget {
  /// Creates a const [HomeScreen].
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refresh Examples')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          ElevatedButton(
            onPressed: () => context.go('/simple'),
            child: const Text('Simple Refresh'),
          ),
          ElevatedButton(
            onPressed: () => context.go('/nested/123'),
            child: const Text('Nested Routes with Refresh'),
          ),
          ElevatedButton(
            onPressed: () => context.go('/shell/page1'),
            child: const Text('Shell Route with Refresh'),
          ),
          ElevatedButton(
            onPressed: () => context.go('/stateful/tab1'),
            child: const Text('Stateful Shell Route with Refresh'),
          ),
        ],
      ),
    );
  }
}

/// The simple refresh screen.
class SimpleRefreshScreen extends StatefulWidget {
  /// Creates a const [SimpleRefreshScreen].
  const SimpleRefreshScreen({super.key});

  @override
  State<SimpleRefreshScreen> createState() => SimpleRefreshScreenState();
}

/// The state for the [SimpleRefreshScreen].
class SimpleRefreshScreenState extends State<SimpleRefreshScreen> {
  late String _data;
  Timer? _timer;
  bool _autoRefresh = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _data = DataService.instance.getData();
    });
  }

  void _toggleAutoRefresh() {
    setState(() {
      _autoRefresh = !_autoRefresh;
      if (_autoRefresh) {
        _timer = Timer.periodic(const Duration(seconds: 2), (_) {
          if (mounted) {
            GoRouter.of(context).refresh();
          }
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void didUpdateWidget(covariant SimpleRefreshScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Refresh'),
        actions: <Widget>[
          IconButton(
            icon: Icon(_autoRefresh ? Icons.pause : Icons.play_arrow),
            onPressed: _toggleAutoRefresh,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              GoRouter.of(context).refresh();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_data, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            if (_autoRefresh)
              const Text(
                'Auto-refresh enabled',
                style: TextStyle(color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}

/// The screen for the nested route.
class NestedScreen extends StatefulWidget {
  /// The screen for the nested route.
  const NestedScreen({required this.id, super.key});

  /// The ID of the nested route.
  final String id;

  @override
  State<NestedScreen> createState() => NestedScreenState();
}

/// The state for the [NestedScreen].
class NestedScreenState extends State<NestedScreen> {
  late String _data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _data = 'Parent ${widget.id}: ${DataService.instance.getData()}';
    });
  }

  @override
  void didUpdateWidget(covariant NestedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nested ${widget.id}'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              GoRouter.of(context).refresh();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_data),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/nested/${widget.id}/detail'),
              child: const Text('Go to Detail'),
            ),
          ],
        ),
      ),
    );
  }
}

/// The screen for the detail route.
class DetailScreen extends StatefulWidget {
  /// The screen for the detail route.
  const DetailScreen({this.parentId, super.key});

  /// The ID of the parent route.
  final String? parentId;

  @override
  State<DetailScreen> createState() => DetailScreenState();
}

/// The state for the [DetailScreen].
class DetailScreenState extends State<DetailScreen> {
  late String _data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _data =
          'Detail for ${widget.parentId}: ${DataService.instance.getData()}';
    });
  }

  @override
  void didUpdateWidget(covariant DetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              GoRouter.of(context).refresh();
            },
          ),
        ],
      ),
      body: Center(child: Text(_data)),
    );
  }
}

/// The shell screen for the shell route.
class ShellScreen extends StatelessWidget {
  /// The shell screen for the shell route.
  const ShellScreen({required this.child, super.key});

  /// The child widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex:
            GoRouterState.of(context).uri.path == '/shell/page1' ? 0 : 1,
        onTap: (int index) {
          if (index == 0) {
            context.go('/shell/page1');
          } else {
            context.go('/shell/page2');
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Page 1'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Page 2'),
        ],
      ),
    );
  }
}

/// The first page of the shell route.
class ShellPage1 extends StatefulWidget {
  /// The first page of the shell route.
  const ShellPage1({super.key});

  @override
  State<ShellPage1> createState() => ShellPage1State();
}

/// The state for the [ShellPage1].
class ShellPage1State extends State<ShellPage1> {
  late int _number;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _number = DataService.instance.getRandomNumber();
    });
  }

  @override
  void didUpdateWidget(covariant ShellPage1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shell Page 1'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              GoRouter.of(context).refresh();
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Random: $_number', style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}

/// The second page of the shell route.
class ShellPage2 extends StatefulWidget {
  /// The second page of the shell route.
  const ShellPage2({super.key});

  @override
  State<ShellPage2> createState() => ShellPage2State();
}

/// The state for the [ShellPage2].
class ShellPage2State extends State<ShellPage2> {
  late String _data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _data = DataService.instance.getData();
    });
  }

  @override
  void didUpdateWidget(covariant ShellPage2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shell Page 2'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              GoRouter.of(context).refresh();
            },
          ),
        ],
      ),
      body: Center(child: Text(_data)),
    );
  }
}

/// The stateful shell screen for the stateful shell route.
class StatefulShellScreen extends StatelessWidget {
  /// The stateful shell screen for the stateful shell route.
  const StatefulShellScreen({required this.navigationShell, super.key});

  /// The navigation shell.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (int index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Tab 1'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Tab 2'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Tab 3'),
        ],
      ),
    );
  }
}

/// The first tab of the stateful shell route.
class StatefulTab1 extends StatefulWidget {
  /// The first tab of the stateful shell route.
  const StatefulTab1({super.key});

  @override
  State<StatefulTab1> createState() => StatefulTab1State();
}

/// The state for the [StatefulTab1].
class StatefulTab1State extends State<StatefulTab1> {
  late String _data;
  int _refreshCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _data = DataService.instance.getData();
      _refreshCount++;
    });
  }

  @override
  void didUpdateWidget(covariant StatefulTab1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stateful Tab 1'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              GoRouter.of(context).refresh();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_data, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Text('Refresh count: $_refreshCount'),
            const SizedBox(height: 20),
            const Text(
              'State is preserved when switching tabs',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

/// The second tab of the stateful shell route.
class StatefulTab2 extends StatefulWidget {
  /// The second tab of the stateful shell route.
  const StatefulTab2({super.key});

  @override
  State<StatefulTab2> createState() => StatefulTab2State();
}

/// The state for the [StatefulTab2].
class StatefulTab2State extends State<StatefulTab2> {
  late int _number;
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _number = DataService.instance.getRandomNumber();
    });
  }

  void _incrementTap() {
    setState(() {
      _tapCount++;
    });
  }

  @override
  void didUpdateWidget(covariant StatefulTab2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stateful Tab 2'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              GoRouter.of(context).refresh();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Random: $_number', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            Text('Tap count: $_tapCount'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _incrementTap,
              child: const Text('Increment Tap Count'),
            ),
          ],
        ),
      ),
    );
  }
}

/// The third tab of the stateful shell route.
class StatefulTab3 extends StatefulWidget {
  /// The third tab of the stateful shell route.
  const StatefulTab3({super.key});

  @override
  State<StatefulTab3> createState() => StatefulTab3State();
}

/// The state for the [StatefulTab3].
class StatefulTab3State extends State<StatefulTab3> {
  late String _data;
  final List<String> _history = <String>[];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _data = DataService.instance.getData();
      _history.add(_data);
    });
  }

  @override
  void didUpdateWidget(covariant StatefulTab3 oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stateful Tab 3'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              GoRouter.of(context).refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Text('Current: $_data', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('History count: ${_history.length}'),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _history.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(_history[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
