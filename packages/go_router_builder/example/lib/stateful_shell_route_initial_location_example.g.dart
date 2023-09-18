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
              path: '/first',
              factory: $FirstRouteDataExtension._fromState,
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          initialLocation: SecondShellBranchData.$initialLocation,
          routes: [
            GoRouteData.$route(
              path: '/second/:section',
              factory: $SecondRouteDataExtension._fromState,
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/third',
              factory: $ThirdRouteDataExtension._fromState,
            ),
          ],
        ),
      ],
    );

extension $MainShellRouteDataExtension on MainShellRouteData {
  static MainShellRouteData _fromState(GoRouterState state) =>
      const MainShellRouteData();
}

extension $FirstRouteDataExtension on FirstRouteData {
  static FirstRouteData _fromState(GoRouterState state) =>
      const FirstRouteData();

  String get location => GoRouteData.$location(
        '/first',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SecondRouteDataExtension on SecondRouteData {
  static SecondRouteData _fromState(GoRouterState state) => SecondRouteData(
        section: _$SecondPageSectionEnumMap
            ._$fromName(state.pathParameters['section']!),
      );

  String get location => GoRouteData.$location(
        '/second/${Uri.encodeComponent(_$SecondPageSectionEnumMap[section]!)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

const _$SecondPageSectionEnumMap = {
  SecondPageSection.first: 'first',
  SecondPageSection.second: 'second',
  SecondPageSection.third: 'third',
};

extension $ThirdRouteDataExtension on ThirdRouteData {
  static ThirdRouteData _fromState(GoRouterState state) =>
      const ThirdRouteData();

  String get location => GoRouteData.$location(
        '/third',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension<T extends Enum> on Map<T, String> {
  T _$fromName(String value) =>
      entries.singleWhere((element) => element.value == value).key;
}
