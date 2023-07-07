import 'package:go_router/go_router.dart';

@TypedGoRoute<RequiredExtraValueRoute>(path: '/default-value-route')
class RequiredExtraValueRoute extends GoRouteData {
  RequiredExtraValueRoute({required this.$extra});
  final int $extra;
}
