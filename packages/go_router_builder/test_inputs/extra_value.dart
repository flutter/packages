import 'package:go_router/go_router.dart';

@TypedGoRoute<ExtraValueRoute>(path: '/default-value-route')
class ExtraValueRoute extends GoRouteData {
  ExtraValueRoute({this.param = 0, this.$extra});
  final int param;
  final int? $extra;
}
