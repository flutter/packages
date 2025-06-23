// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: always_specify_types, public_member_api_docs

part of 'stateful_shell_route_initial_location_example.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $mainShellRouteData,
    ];

RouteBase get $mainShellRouteData => StatefulShellRouteData.$route(
      factory: $MainShellRouteDataExtension._fromState,
      branches: [
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/home',
              factory: _$HomeRouteData._fromState,
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          initialLocation: NotificationsShellBranchData.$initialLocation,
          routes: [
            GoRouteData.$route(
              path: '/notifications/:section',
              factory: _$NotificationsRouteData._fromState,
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/orders',
              factory: _$OrdersRouteData._fromState,
            ),
          ],
        ),
      ],
    );

extension $MainShellRouteDataExtension on MainShellRouteData {
  static MainShellRouteData _fromState(GoRouterState state) =>
      const MainShellRouteData();
}

mixin _$HomeRouteData on GoRouteData {
  static HomeRouteData _fromState(GoRouterState state) => const HomeRouteData();

  @override
  String get location => GoRouteData.$location(
        '/home',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$NotificationsRouteData on GoRouteData {
  static NotificationsRouteData _fromState(GoRouterState state) =>
      NotificationsRouteData(
        section: _$NotificationsPageSectionEnumMap
            ._$fromName(state.pathParameters['section']!)!,
      );

  NotificationsRouteData get _self => this as NotificationsRouteData;

  @override
  String get location => GoRouteData.$location(
        '/notifications/${Uri.encodeComponent(_$NotificationsPageSectionEnumMap[_self.section]!)}',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

const _$NotificationsPageSectionEnumMap = {
  NotificationsPageSection.latest: 'latest',
  NotificationsPageSection.old: 'old',
  NotificationsPageSection.archive: 'archive',
};

mixin _$OrdersRouteData on GoRouteData {
  static OrdersRouteData _fromState(GoRouterState state) =>
      const OrdersRouteData();

  @override
  String get location => GoRouteData.$location(
        '/orders',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

extension<T extends Enum> on Map<T, String> {
  T? _$fromName(String? value) =>
      entries.where((element) => element.value == value).firstOrNull?.key;
}
