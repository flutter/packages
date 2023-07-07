import 'package:go_router/go_router.dart';

@TypedGoRoute<IterableWithEnumRoute>(path: '/iterable-with-enum')
class IterableWithEnumRoute extends GoRouteData {
  IterableWithEnumRoute({this.param});

  final Iterable<EnumOnlyUsedInIterable>? param;
}

enum EnumOnlyUsedInIterable {
  a,
  b,
  c,
}
