import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CounterStream {
  int _counter = 0;

  final _streamController = StreamController<int>.broadcast();

  Stream<int> get stateStream => _streamController.stream.asBroadcastStream();

  void increment() {
    print("increment() ++_counter is ${++_counter}");
    _streamController.sink.add(++_counter);
  }

  // Future<void> delayedRerender() async {
  //   increment();
  //   increment();
  // }

  void dispose() {
    _streamController.close();
  }
}

final CounterStream counterStream = CounterStream();

class StreamListener extends ChangeNotifier {
  StreamListener(Stream<dynamic> stream) {
    notifyListeners();

    _subscription = stream.asBroadcastStream().listen((_) {
      try {
        print("Start");
        notifyListeners();
        print("d");
      } catch (e) {
        print("Error::${e.toString()}");
      }
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void notifyListeners() {
    print("[before] refreshing the router");
    super.notifyListeners();
    print("[after] refreshing the router");
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

void main() {
  GoRouter.optionURLReflectsImperativeAPIs = true;

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  refreshListenable: StreamListener(counterStream.stateStream),
  // refreshListenable: ChangeNotifier(),
  routes: <RouteBase>[
    ShellRoute(
      builder: (context, state, child) {
        return GenericPage(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const GenericPage(showPushButton: true, path: 'a'),
          routes: [
            GoRoute(
              path: 'a',
              name: "a",
              builder: (BuildContext context, GoRouterState state) =>
                  const GenericPage(showPushButton: true, path: 'b'),
              routes: [
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
  int _currentState = 0;

  @override
  void initState() {
    super.initState();
    _stateSubscription = counterStream.stateStream.listen((state) {
      print('_currentState::$_currentState');
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
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: _router,
    );
  }
}

class GenericPage extends StatefulWidget {
  final Widget? child;
  final bool showPushButton;
  final bool showBackButton;
  final String? path;

  const GenericPage({
    this.child,
    Key? key,
    this.showPushButton = false,
    this.showBackButton = false,
    this.path,
  }) : super(key: key ?? const ValueKey<String>('ShellWidget'));

  @override
  State<GenericPage> createState() => _GenericPageState();
}

class _GenericPageState extends State<GenericPage> {
  late StreamSubscription<int> _stateSubscription;
  int _currentState = 0;

  @override
  void initState() {
    super.initState();
    _stateSubscription = counterStream.stateStream.listen((state) {
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
      appBar: widget.child != null
          ? AppBar(
              title: Text('Count: $_currentState'),
              actions: [
                TextButton(
                  onPressed: () {
                    GoRouter.of(context).pop();
                  },
                  child: Text("Normal pop"),
                )
              ],
            )
          : null,
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
          GoRouter.of(context).pop();

          // WHEN THE USER PRESSES THIS BUTTON, THE URL
          // DOESN'T CHANGE, BUT THE SCREEN DOES
          counterStream
              .increment(); // <- when removing this line the issue is gone
          print("start pop()");
        },
        child: Text("<- Go Back"),
      );
    }

    if (widget.showPushButton) {
      return TextButton(
        onPressed: () {
          GoRouter.of(context).goNamed(widget.path!);
        },
        child: Text("Push ->"),
      );
    }

    return Text('Current state: $_currentState');
  }
}
