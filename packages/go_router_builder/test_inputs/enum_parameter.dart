import 'package:go_router/go_router.dart';

@TypedGoRoute<EnumParam>(path: '/:y')
class EnumParam extends GoRouteData {
  EnumParam({required this.y});
  final EnumTest y;
}

enum EnumTest {
  a(1),
  b(3),
  c(5);

  const EnumTest(this.x);
  final int x;
}
