import 'package:go_router/go_router.dart';

@TypedGoRoute<DefaultValueRoute>(path: '/default-value-route')
class DefaultValueRoute extends GoRouteData {
  DefaultValueRoute({this.param = 0});
  final int param;
}
