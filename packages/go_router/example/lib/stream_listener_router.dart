import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  GoRouter.optionURLReflectsImperativeAPIs = true;

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

/// A counter stream that emits a new value when the counter is incremented.
class CounterStream {
  int _counter = 0;

  final StreamController<int> _streamController =
      StreamController<int>.broadcast();

  /// The stream that emits a new value when the counter is incremented.
  Stream<int> get stateStream => _streamController.stream.asBroadcastStream();

  /// Increments the counter and emits a new value.
  void increment() {
    _streamController.sink.add(++_counter);
  }
}

/// A counter stream that emits a new value when the counter is incremented.
final CounterStream counterStream = CounterStream();

/// A listener that listens to a stream and refreshes the router when the stream emits a new value.
class StreamListener extends ChangeNotifier {
  /// Creates a stream listener.
  StreamListener(Stream<dynamic> stream) {
    notifyListeners();

    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void notifyListeners() {
    super.notifyListeners();
    log('refreshing the router');
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// The main application widget.
class MyApp extends StatefulWidget {
  /// Creates the main application widget.
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  refreshListenable: StreamListener(counterStream.stateStream),
  routes: <RouteBase>[
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return GenericPage(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const GenericPage(showPushButton: true, path: 'a'),
          routes: <RouteBase>[
            GoRoute(
              path: 'a',
              name: 'a',
              builder: (BuildContext context, GoRouterState state) =>
                  const GenericPage(showPushButton: true, path: 'b'),
              routes: <RouteBase>[
                GoRoute(
                  path: 'b',
                  name: 'b',
                  builder: (BuildContext context, GoRouterState state) =>
                      const GenericPage(showBackButton: true),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

class _MyAppState extends State<MyApp> {
  late StreamSubscription<int> _stateSubscription;

  /// The current state of the counter.
  int _currentState = 0;

  @override
  void initState() {
    super.initState();
    _stateSubscription = counterStream.stateStream.listen((int state) {
      setState(() {
        _currentState = state;
        log('$_currentState:: "try double place to listen"');
      });
    });
  }

  @override
  void dispose() {
    _stateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: _router,
    );
  }
}

/// A dialog test widget.
class DialogTest extends StatelessWidget {
  /// Creates a dialog test widget.
  const DialogTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        height: 300,
        alignment: Alignment.center,
        child: Material(
          color: Colors.white,
          child: Column(
            children:
                <String>['Navigator::pop', 'GoRouter::pop'].map((String e) {
              return InkWell(
                child: SizedBox(
                  height: 60,
                  width: 300,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(e),
                      const Icon(Icons.close),
                    ],
                  ),
                ),
                onTap: () {
                  if (e == 'GoRouter::pop') {
                    // WHEN THE USER PRESSES THIS BUTTON, THE URL
                    // DOESN'T CHANGE, BUT THE SCREEN DOES
                    counterStream
                        .increment(); // <- when removing this line the issue is gone
                    GoRouter.of(context).pop();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// A generic page that can be used to display a page in the app.
class GenericPage extends StatefulWidget {
  /// Creates a generic page.
  const GenericPage({
    this.child,
    Key? key,
    this.showPushButton = false,
    this.showBackButton = false,
    this.path,
  }) : super(key: key ?? const ValueKey<String>('ShellWidget'));

  /// The child widget to be displayed in the page.
  final Widget? child;

  /// Whether to show the push button.
  final bool showPushButton;

  /// Whether to show the back button.
  final bool showBackButton;

  /// The path of the page.
  final String? path;

  @override
  State<GenericPage> createState() => _GenericPageState();
}

class _GenericPageState extends State<GenericPage> {
  late StreamSubscription<int> _stateSubscription;
  int _currentState = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    _stateSubscription = counterStream.stateStream.listen((int state) {
      setState(() {
        _currentState = state;
      });
    });
  }

  @override
  void dispose() {
    _stateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: widget.child != null
          ? AppBar(
              title: Text('Count: $_currentState'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return const DialogTest();
                      },
                    );
                  },
                  child: const Text('dialog1'),
                ),
                TextButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return const DialogTest();
                      },
                    );
                  },
                  child: const Text('dialog2'),
                ),
                TextButton(
                  onPressed: () {
                    _scaffoldKey.currentState?.openEndDrawer();
                  },
                  child: const Text('EndDrawer'),
                ),
              ],
            )
          : null,
      endDrawer: const Drawer(
        width: 200,
        child: DialogTest(),
      ),
      body: _buildWidget(context),
    );
  }

  Widget _buildWidget(BuildContext context) {
    if (widget.child != null) {
      return widget.child!;
    }

    if (widget.showBackButton) {
      return TextButton(
        onPressed: () {
          // WHEN THE USER PRESSES THIS BUTTON, THE URL
          // DOESN'T CHANGE, BUT THE SCREEN DOES
          counterStream
              .increment(); // <- when removing this line the issue is gone
          GoRouter.of(context).pop();
        },
        child: const Text('<- Go Back'),
      );
    }

    if (widget.showPushButton) {
      return TextButton(
        onPressed: () {
          GoRouter.of(context).goNamed(widget.path!);
        },
        child: const Text('Push ->'),
      );
    }

    return Text('Current state: $_currentState');
  }
}
