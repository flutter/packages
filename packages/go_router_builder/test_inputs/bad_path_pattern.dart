import 'package:go_router/go_router.dart';

@TypedGoRoute<BadPathParam>(path: 'bob/:id')
class BadPathParam extends GoRouteData {}
