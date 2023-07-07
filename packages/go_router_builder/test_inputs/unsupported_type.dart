import 'package:go_router/go_router.dart';

@TypedGoRoute<UnsupportedType>(path: 'bob/:id')
class UnsupportedType extends GoRouteData {
  UnsupportedType({required this.id});
  final Stopwatch id;
}
