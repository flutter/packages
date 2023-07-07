import 'package:go_router/go_router.dart';

@TypedGoRoute<IterableDefaultValueRoute>(path: '/iterable-default-value-route')
class IterableDefaultValueRoute extends GoRouteData {
  IterableDefaultValueRoute({this.param = const <int>[0]});
  final Iterable<int> param;
}
