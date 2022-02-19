import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/src/go_router_delegate.dart';
import 'package:go_router/src/go_router_error_page.dart';

GoRouterDelegate createGoRouterDelegate({
  Listenable? refreshListenable,
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const DummyStatefulWidget()),
      GoRoute(
        path: '/error',
        builder: (_, __) => const GoRouterErrorScreen(null),
      ),
    ],
    refreshListenable: refreshListenable,
  );
  return router.routerDelegate;
}

void main() {
  group('pop', () {
    test('removes the last element', () {
      final delegate = createGoRouterDelegate()
        ..push('/error')
        ..addListener(expectAsync0(() {}));
      final last = delegate.matches.last;
      delegate.pop();
      expect(delegate.matches.length, 1);
      expect(delegate.matches.contains(last), false);
    });

    test('throws when it pops more than matches count', () {
      final delegate = createGoRouterDelegate()..push('/error');
      expect(
        () => delegate
          ..pop()
          ..pop(),
        throwsException,
      );
    });
  });

  test('on dispose unsubscribes from refreshListenable', () {
    final refreshListenable = FakeRefreshListenable();
    createGoRouterDelegate(refreshListenable: refreshListenable).dispose();
    expect(refreshListenable.unsubscribed, true);
  });
}

class FakeRefreshListenable extends ChangeNotifier {
  bool unsubscribed = false;
  @override
  void removeListener(VoidCallback listener) {
    unsubscribed = true;
    super.removeListener(listener);
  }
}

class DummyStatefulWidget extends StatefulWidget {
  const DummyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<DummyStatefulWidget> createState() => _DummyStatefulWidgetState();
}

class _DummyStatefulWidgetState extends State<DummyStatefulWidget> {
  @override
  Widget build(BuildContext context) => Container();
}
