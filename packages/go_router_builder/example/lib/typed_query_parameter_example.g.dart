// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: always_specify_types, public_member_api_docs

part of 'typed_query_parameter_example.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$intRoute];

RouteBase get $intRoute =>
    GoRouteData.$route(path: '/int-route', factory: $IntRoute._fromState);

mixin $IntRoute on GoRouteData {
  static IntRoute _fromState(GoRouterState state) => IntRoute(
    intField: _$convertMapValue(
      'intField',
      state.uri.queryParameters,
      int.tryParse,
    ),
    intFieldWithDefaultValue:
        _$convertMapValue(
          'int_field_with_default_value',
          state.uri.queryParameters,
          int.parse,
        ) ??
        1,
    intFieldWithSpace: _$convertMapValue(
      'int field',
      state.uri.queryParameters,
      int.tryParse,
    ),
    customField: CustomParameter.decode(
      state.uri.queryParameters['custom-field'],
    ),
    customFieldWithDefaultValue:
        CustomParameter.decode(
          state.uri.queryParameters['custom-field-with-default-value'],
        ) ??
        const CustomParameter(valueString: 'default', valueInt: 0),
  );

  IntRoute get _self => this as IntRoute;

  @override
  String get location => GoRouteData.$location(
    '/int-route',
    queryParams: {
      if (_self.intField != null) 'intField': _self.intField!.toString(),
      if (_self.intFieldWithDefaultValue != 1)
        'int_field_with_default_value': _self.intFieldWithDefaultValue
            .toString(),
      if (_self.intFieldWithSpace != null)
        'int field': _self.intFieldWithSpace!.toString(),
      if (_self.customField != null)
        'custom-field': CustomParameter.encode(_self.customField),
      if (CustomParameter.compare(
        _self.customFieldWithDefaultValue,
        const CustomParameter(valueString: 'default', valueInt: 0),
      ))
        'custom-field-with-default-value': CustomParameter.encode(
          _self.customFieldWithDefaultValue,
        ),
    },
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

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T? Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}
