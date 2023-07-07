import 'package:go_router/go_router.dart';

@TypedGoRoute<NonNullableRequiredParamNotInPath>(path: 'bob')
class NonNullableRequiredParamNotInPath extends GoRouteData {
  NonNullableRequiredParamNotInPath({required this.id});
  final int id;
}
