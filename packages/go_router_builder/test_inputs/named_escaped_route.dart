import 'package:go_router/go_router.dart';

@TypedGoRoute<NamedEscapedRoute>(path: '/named-route', name: r'named$Route')
class NamedEscapedRoute extends GoRouteData {}
