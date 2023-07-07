import 'package:go_router/go_router.dart';

@TypedGoRoute<NullableRequiredParamInPath>(path: 'bob/:id')
class NullableRequiredParamInPath extends GoRouteData {
  NullableRequiredParamInPath({required this.id});
  final int? id;
}
