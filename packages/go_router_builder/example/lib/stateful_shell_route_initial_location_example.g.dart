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
              factory: $HomeRouteDataExtension._fromState,
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          initialLocation: NotificationsShellBranchData.$initialLocation,
          routes: [
            GoRouteData.$route(
              path: '/notifications/:section',
              factory: $NotificationsRouteDataExtension._fromState,
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/orders',
              factory: $OrdersRouteDataExtension._fromState,
            ),
          ],
        ),
      ],
    );

extension $MainShellRouteDataExtension on MainShellRouteData {
  static MainShellRouteData _fromState(GoRouterState state) =>
      const MainShellRouteData();
}

extension $HomeRouteDataExtension on HomeRouteData {
  static HomeRouteData _fromState(GoRouterState state) => const HomeRouteData();

  String get location => GoRouteData.$location(
        '/home',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $NotificationsRouteDataExtension on NotificationsRouteData {
  static NotificationsRouteData _fromState(GoRouterState state) =>
      NotificationsRouteData(
        section: _$NotificationsPageSectionEnumMap
            ._$fromName(state.pathParameters['section']!)!,
      );

  String get location => GoRouteData.$location(
        '/notifications/${Uri.encodeComponent(_$NotificationsPageSectionEnumMap[section]!)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

const _$NotificationsPageSectionEnumMap = {
  NotificationsPageSection.latest: 'latest',
  NotificationsPageSection.old: 'old',
  NotificationsPageSection.archive: 'archive',
};

extension $OrdersRouteDataExtension on OrdersRouteData {
  static OrdersRouteData _fromState(GoRouterState state) =>
      const OrdersRouteData();

  String get location => GoRouteData.$location(
        '/orders',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension<T extends Enum> on Map<T, String> {
  T? _$fromName(String value) =>
      entries.where((element) => element.value == value).firstOrNull?.key;
}
