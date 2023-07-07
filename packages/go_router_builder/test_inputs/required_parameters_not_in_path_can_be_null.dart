import 'package:go_router/go_router.dart';

@TypedGoRoute<NullableRequiredParamNotInPath>(path: 'bob')
class NullableRequiredParamNotInPath extends GoRouteData {
  NullableRequiredParamNotInPath({required this.id});
  final int? id;
}
