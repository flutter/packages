// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: always_specify_types, public_member_api_docs

part of 'all_types.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<GoRoute> get $appRoutes => [
      $allTypesRoute,
    ];

GoRoute get $allTypesRoute => GoRouteData.$route(
      path:
          '/:requiredBigIntField/:requiredBoolField/:requiredDateTimeField/:requiredDoubleField/:requiredEnumField/:requiredIntField/:requiredNumField/:requiredStringField/:requiredUriField',
      factory: $AllTypesRouteExtension._fromState,
    );

extension $AllTypesRouteExtension on AllTypesRoute {
  static AllTypesRoute _fromState(GoRouterState state) => AllTypesRoute(
        requiredBigIntField: BigInt.parse(state.params['requiredBigIntField']!),
        requiredBoolField: _$boolConverter(state.params['requiredBoolField']!),
        requiredDateTimeField:
            DateTime.parse(state.params['requiredDateTimeField']!),
        requiredDoubleField: double.parse(state.params['requiredDoubleField']!),
        requiredEnumField: _$PersonDetailsEnumMap
            ._$fromName(state.params['requiredEnumField']!),
        requiredIntField: int.parse(state.params['requiredIntField']!),
        requiredNumField: num.parse(state.params['requiredNumField']!),
        requiredStringField: state.params['requiredStringField']!,
        requiredUriField: Uri.parse(state.params['requiredUriField']!),
        bigIntField:
            _$convertMapValue('big-int-field', state.queryParams, BigInt.parse),
        boolField:
            _$convertMapValue('bool-field', state.queryParams, _$boolConverter),
        dateTimeField: _$convertMapValue(
            'date-time-field', state.queryParams, DateTime.parse),
        doubleField:
            _$convertMapValue('double-field', state.queryParams, double.parse),
        enumField: _$convertMapValue(
            'enum-field', state.queryParams, _$PersonDetailsEnumMap._$fromName),
        intField: _$convertMapValue('int-field', state.queryParams, int.parse),
        numField: _$convertMapValue('num-field', state.queryParams, num.parse),
        stringField: state.queryParams['string-field'],
        uriField: _$convertMapValue('uri-field', state.queryParams, Uri.parse),
      );

  String get location => GoRouteData.$location(
        '/${Uri.encodeComponent(requiredBigIntField.toString())}/${Uri.encodeComponent(requiredBoolField.toString())}/${Uri.encodeComponent(requiredDateTimeField.toString())}/${Uri.encodeComponent(requiredDoubleField.toString())}/${Uri.encodeComponent(_$PersonDetailsEnumMap[requiredEnumField]!)}/${Uri.encodeComponent(requiredIntField.toString())}/${Uri.encodeComponent(requiredNumField.toString())}/${Uri.encodeComponent(requiredStringField)}/${Uri.encodeComponent(requiredUriField.toString())}',
        queryParams: {
          if (bigIntField != null) 'big-int-field': bigIntField!.toString(),
          if (boolField != null) 'bool-field': boolField!.toString(),
          if (dateTimeField != null)
            'date-time-field': dateTimeField!.toString(),
          if (doubleField != null) 'double-field': doubleField!.toString(),
          if (enumField != null)
            'enum-field': _$PersonDetailsEnumMap[enumField!]!,
          if (intField != null) 'int-field': intField!.toString(),
          if (numField != null) 'num-field': numField!.toString(),
          if (stringField != null) 'string-field': stringField!,
          if (uriField != null) 'uri-field': uriField!.toString(),
        },
      );

  void go(BuildContext buildContext) => buildContext.go(location, extra: this);
}

const _$PersonDetailsEnumMap = {
  PersonDetails.hobbies: 'hobbies',
  PersonDetails.favoriteFood: 'favorite-food',
  PersonDetails.favoriteSport: 'favorite-sport',
};

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}

bool _$boolConverter(String value) {
  switch (value) {
    case 'true':
      return true;
    case 'false':
      return false;
    default:
      throw UnsupportedError('Cannot convert "$value" into a bool.');
  }
}

extension<T extends Enum> on Map<T, String> {
  T _$fromName(String value) =>
      entries.singleWhere((element) => element.value == value).key;
}
