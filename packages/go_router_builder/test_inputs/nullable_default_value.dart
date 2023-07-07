import 'package:go_router/go_router.dart';

@TypedGoRoute<NullableDefaultValueRoute>(path: '/nullable-default-value-route')
class NullableDefaultValueRoute extends GoRouteData {
  NullableDefaultValueRoute({this.param = 0});
  final int? param;
}
