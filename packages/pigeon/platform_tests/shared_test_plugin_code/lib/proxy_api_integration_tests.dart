// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: unused_local_variable

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'generated.dart';
import 'integration_tests.dart' show TargetGenerator, proxyApiSupportedLanguages;

/// Runs the Proxy API integration tests.

void runProxyApiIntegrationTests(TargetGenerator targetGenerator) {
  group('Proxy API Tests', () {
    if (!proxyApiSupportedLanguages.contains(targetGenerator)) {
      return;
    }

    testWidgets('named constructor', (_) async {
      final instance = ProxyApiTestClass.namedConstructor(
        aBool: true,
        anInt: 0,
        aDouble: 0.0,
        aString: '',
        aUint8List: Uint8List(0),
        aList: const <Object?>[],
        aMap: const <String?, Object?>{},
        anEnum: ProxyApiTestEnum.one,
        aProxyApi: ProxyApiSuperClass(),
        flutterEchoBool: (ProxyApiTestClass instance, bool aBool) => true,
        flutterEchoInt: (_, _) => 3,
        flutterEchoDouble: (_, _) => 1.0,
        flutterEchoString: (_, _) => '',
        flutterEchoUint8List: (_, _) => Uint8List(0),
        flutterEchoList: (_, _) => <Object?>[],
        flutterEchoProxyApiList: (_, _) => <ProxyApiTestClass?>[],
        flutterEchoMap: (_, _) => <String?, Object?>{},
        flutterEchoEnum: (_, _) => ProxyApiTestEnum.one,
        flutterEchoProxyApi: (_, _) => ProxyApiSuperClass(),
        flutterEchoAsyncString: (_, _) async => '',
        flutterEchoProxyApiMap: (_, _) => <String?, ProxyApiTestClass?>{},
      );
      // Ensure no error calling method on instance.
      await instance.noop();
    });

    testWidgets('noop', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      await expectLater(api.noop(), completes);
    });

    testWidgets('throwError', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      await expectLater(() => api.throwError(), throwsA(isA<PlatformException>()));
    });

    testWidgets('throwErrorFromVoid', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      await expectLater(() => api.throwErrorFromVoid(), throwsA(isA<PlatformException>()));
    });

    testWidgets('throwFlutterError', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      await expectLater(
        () => api.throwFlutterError(),
        throwsA((dynamic e) {
          return e is PlatformException &&
              e.code == 'code' &&
              e.message == 'message' &&
              e.details == 'details';
        }),
      );
    });

    testWidgets('echoInt', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const value = 0;
      expect(await api.echoInt(value), value);
    });

    testWidgets('echoDouble', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const value = 0.0;
      expect(await api.echoDouble(value), value);
    });

    testWidgets('echoBool', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const value = true;
      expect(await api.echoBool(value), value);
    });

    testWidgets('echoString', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const value = 'string';
      expect(await api.echoString(value), value);
    });

    testWidgets('echoUint8List', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      final value = Uint8List(0);
      expect(await api.echoUint8List(value), value);
    });

    testWidgets('echoObject', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const Object value = 'apples';
      expect(await api.echoObject(value), value);
    });

    testWidgets('echoList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const List<Object?> value = <int>[1, 2];
      expect(await api.echoList(value), value);
    });

    testWidgets('echoProxyApiList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      final value = <ProxyApiTestClass>[
        _createGenericProxyApiTestClass(),
        _createGenericProxyApiTestClass(),
      ];
      expect(await api.echoProxyApiList(value), value);
    });

    testWidgets('echoMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const value = <String?, Object?>{'apple': 'pie'};
      expect(await api.echoMap(value), value);
    });

    testWidgets('echoProxyApiMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      final value = <String, ProxyApiTestClass>{'42': _createGenericProxyApiTestClass()};
      expect(await api.echoProxyApiMap(value), value);
    });

    testWidgets('echoEnum', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const ProxyApiTestEnum value = ProxyApiTestEnum.three;
      expect(await api.echoEnum(value), value);
    });

    testWidgets('echoProxyApi', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      final value = ProxyApiSuperClass();
      expect(await api.echoProxyApi(value), value);
    });

    testWidgets('echoNullableInt', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableInt(null), null);
      expect(await api.echoNullableInt(1), 1);
    });

    testWidgets('echoNullableDouble', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableDouble(null), null);
      expect(await api.echoNullableDouble(1.0), 1.0);
    });

    testWidgets('echoNullableBool', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableBool(null), null);
      expect(await api.echoNullableBool(false), false);
    });

    testWidgets('echoNullableString', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableString(null), null);
      expect(await api.echoNullableString('aString'), 'aString');
    });

    testWidgets('echoNullableUint8List', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableUint8List(null), null);
      expect(await api.echoNullableUint8List(Uint8List(0)), Uint8List(0));
    });

    testWidgets('echoNullableObject', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableObject(null), null);
      expect(await api.echoNullableObject('aString'), 'aString');
    });

    testWidgets('echoNullableList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableList(null), null);
      expect(await api.echoNullableList(<int>[1]), <int>[1]);
    });

    testWidgets('echoNullableMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableMap(null), null);
      expect(await api.echoNullableMap(<String, int>{'value': 1}), <String, int>{'value': 1});
    });

    testWidgets('echoNullableEnum', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableEnum(null), null);
      expect(await api.echoNullableEnum(ProxyApiTestEnum.one), ProxyApiTestEnum.one);
    });

    testWidgets('echoNullableProxyApi', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableProxyApi(null), null);

      final proxyApi = ProxyApiSuperClass();
      expect(await api.echoNullableProxyApi(proxyApi), proxyApi);
    });

    testWidgets('noopAsync', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      await expectLater(api.noopAsync(), completes);
    });

    testWidgets('echoAsyncInt', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const value = 0;
      expect(await api.echoAsyncInt(value), value);
    });

    testWidgets('echoAsyncDouble', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const value = 0.0;
      expect(await api.echoAsyncDouble(value), value);
    });

    testWidgets('echoAsyncBool', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const value = false;
      expect(await api.echoAsyncBool(value), value);
    });

    testWidgets('echoAsyncString', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const value = 'ping';
      expect(await api.echoAsyncString(value), value);
    });

    testWidgets('echoAsyncUint8List', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      final value = Uint8List(0);
      expect(await api.echoAsyncUint8List(value), value);
    });

    testWidgets('echoAsyncObject', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const Object value = 0;
      expect(await api.echoAsyncObject(value), value);
    });

    testWidgets('echoAsyncList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const value = <Object?>['apple', 'pie'];
      expect(await api.echoAsyncList(value), value);
    });

    testWidgets('echoAsyncMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      final value = <String?, Object?>{'something': ProxyApiSuperClass()};
      expect(await api.echoAsyncMap(value), value);
    });

    testWidgets('echoAsyncEnum', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const ProxyApiTestEnum value = ProxyApiTestEnum.two;
      expect(await api.echoAsyncEnum(value), value);
    });

    testWidgets('throwAsyncError', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      await expectLater(() => api.throwAsyncError(), throwsA(isA<PlatformException>()));
    });

    testWidgets('throwAsyncErrorFromVoid', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      await expectLater(() => api.throwAsyncErrorFromVoid(), throwsA(isA<PlatformException>()));
    });

    testWidgets('throwAsyncFlutterError', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      await expectLater(
        () => api.throwAsyncFlutterError(),
        throwsA((dynamic e) {
          return e is PlatformException &&
              e.code == 'code' &&
              e.message == 'message' &&
              e.details == 'details';
        }),
      );
    });

    testWidgets('echoAsyncNullableInt', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableInt(null), null);
      expect(await api.echoAsyncNullableInt(1), 1);
    });

    testWidgets('echoAsyncNullableDouble', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableDouble(null), null);
      expect(await api.echoAsyncNullableDouble(2.0), 2.0);
    });

    testWidgets('echoAsyncNullableBool', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableBool(null), null);
      expect(await api.echoAsyncNullableBool(true), true);
    });

    testWidgets('echoAsyncNullableString', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableString(null), null);
      expect(await api.echoAsyncNullableString('aString'), 'aString');
    });

    testWidgets('echoAsyncNullableUint8List', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableUint8List(null), null);
      expect(await api.echoAsyncNullableUint8List(Uint8List(0)), Uint8List(0));
    });

    testWidgets('echoAsyncNullableObject', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableObject(null), null);
      expect(await api.echoAsyncNullableObject(1), 1);
    });

    testWidgets('echoAsyncNullableList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableList(null), null);
      expect(await api.echoAsyncNullableList(<int>[1]), <int>[1]);
    });

    testWidgets('echoAsyncNullableMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableMap(null), null);
      expect(await api.echoAsyncNullableMap(<String, int>{'banana': 1}), <String, int>{
        'banana': 1,
      });
    });

    testWidgets('echoAsyncNullableEnum', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableEnum(null), null);
      expect(await api.echoAsyncNullableEnum(ProxyApiTestEnum.one), ProxyApiTestEnum.one);
    });

    testWidgets('staticNoop', (_) async {
      await expectLater(ProxyApiTestClass.staticNoop(), completes);
    });

    testWidgets('echoStaticString', (_) async {
      const value = 'static string';
      expect(await ProxyApiTestClass.echoStaticString(value), value);
    });

    testWidgets('staticAsyncNoop', (_) async {
      await expectLater(ProxyApiTestClass.staticAsyncNoop(), completes);
    });

    testWidgets('callFlutterNoop', (_) async {
      var called = false;
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterNoop: (ProxyApiTestClass instance) async {
          called = true;
        },
      );

      await api.callFlutterNoop();
      expect(called, isTrue);
    });

    testWidgets('callFlutterThrowError', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterThrowError: (_) {
          throw FlutterError('this is an error');
        },
      );

      await expectLater(
        api.callFlutterThrowError(),
        throwsA(
          isA<PlatformException>().having(
            (PlatformException exception) => exception.message,
            'message',
            equals('this is an error'),
          ),
        ),
      );
    });

    testWidgets('callFlutterThrowErrorFromVoid', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterThrowErrorFromVoid: (_) {
          throw FlutterError('this is an error');
        },
      );

      await expectLater(
        api.callFlutterThrowErrorFromVoid(),
        throwsA(
          isA<PlatformException>().having(
            (PlatformException exception) => exception.message,
            'message',
            equals('this is an error'),
          ),
        ),
      );
    });

    testWidgets('callFlutterEchoBool', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoBool: (_, bool aBool) => aBool,
      );

      const value = true;
      expect(await api.callFlutterEchoBool(value), value);
    });

    testWidgets('callFlutterEchoInt', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoInt: (_, int anInt) => anInt,
      );

      const value = 0;
      expect(await api.callFlutterEchoInt(value), value);
    });

    testWidgets('callFlutterEchoDouble', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoDouble: (_, double aDouble) => aDouble,
      );

      const value = 0.0;
      expect(await api.callFlutterEchoDouble(value), value);
    });

    testWidgets('callFlutterEchoString', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoString: (_, String aString) => aString,
      );

      const value = 'a string';
      expect(await api.callFlutterEchoString(value), value);
    });

    testWidgets('callFlutterEchoUint8List', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoUint8List: (_, Uint8List aUint8List) => aUint8List,
      );

      final value = Uint8List(0);
      expect(await api.callFlutterEchoUint8List(value), value);
    });

    testWidgets('callFlutterEchoList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoList: (_, List<Object?> aList) => aList,
      );

      final value = <Object?>[0, 0.0, true, ProxyApiSuperClass()];
      expect(await api.callFlutterEchoList(value), value);
    });

    testWidgets('callFlutterEchoProxyApiList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoProxyApiList: (_, List<ProxyApiTestClass?> aList) => aList,
      );

      final List<ProxyApiTestClass?> value = <ProxyApiTestClass>[_createGenericProxyApiTestClass()];
      expect(await api.callFlutterEchoProxyApiList(value), value);
    });

    testWidgets('callFlutterEchoMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoMap: (_, Map<String?, Object?> aMap) => aMap,
      );

      final value = <String?, Object?>{'a String': 4};
      expect(await api.callFlutterEchoMap(value), value);
    });

    testWidgets('callFlutterEchoProxyApiMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoProxyApiMap: (_, Map<String?, ProxyApiTestClass?> aMap) => aMap,
      );

      final value = <String?, ProxyApiTestClass?>{'a String': _createGenericProxyApiTestClass()};
      expect(await api.callFlutterEchoProxyApiMap(value), value);
    });

    testWidgets('callFlutterEchoEnum', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoEnum: (_, ProxyApiTestEnum anEnum) => anEnum,
      );

      const ProxyApiTestEnum value = ProxyApiTestEnum.three;
      expect(await api.callFlutterEchoEnum(value), value);
    });

    testWidgets('callFlutterEchoProxyApi', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoProxyApi: (_, ProxyApiSuperClass aProxyApi) => aProxyApi,
      );

      final value = ProxyApiSuperClass();
      expect(await api.callFlutterEchoProxyApi(value), value);
    });

    testWidgets('callFlutterEchoNullableBool', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableBool: (_, bool? aBool) => aBool,
      );
      expect(await api.callFlutterEchoNullableBool(null), null);
      expect(await api.callFlutterEchoNullableBool(true), true);
    });

    testWidgets('callFlutterEchoNullableInt', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableInt: (_, int? anInt) => anInt,
      );
      expect(await api.callFlutterEchoNullableInt(null), null);
      expect(await api.callFlutterEchoNullableInt(1), 1);
    });

    testWidgets('callFlutterEchoNullableDouble', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableDouble: (_, double? aDouble) => aDouble,
      );
      expect(await api.callFlutterEchoNullableDouble(null), null);
      expect(await api.callFlutterEchoNullableDouble(1.0), 1.0);
    });

    testWidgets('callFlutterEchoNullableString', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableString: (_, String? aString) => aString,
      );
      expect(await api.callFlutterEchoNullableString(null), null);
      expect(await api.callFlutterEchoNullableString('aString'), 'aString');
    });

    testWidgets('callFlutterEchoNullableUint8List', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableUint8List: (_, Uint8List? aUint8List) => aUint8List,
      );
      expect(await api.callFlutterEchoNullableUint8List(null), null);
      expect(await api.callFlutterEchoNullableUint8List(Uint8List(0)), Uint8List(0));
    });

    testWidgets('callFlutterEchoNullableList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableList: (_, List<Object?>? aList) => aList,
      );
      expect(await api.callFlutterEchoNullableList(null), null);
      expect(await api.callFlutterEchoNullableList(<int>[0]), <int>[0]);
    });

    testWidgets('callFlutterEchoNullableMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableMap: (_, Map<String?, Object?>? aMap) => aMap,
      );
      expect(await api.callFlutterEchoNullableMap(null), null);
      expect(await api.callFlutterEchoNullableMap(<String, int>{'str': 0}), <String, int>{
        'str': 0,
      });
    });

    testWidgets('callFlutterEchoNullableEnum', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableEnum: (_, ProxyApiTestEnum? anEnum) => anEnum,
      );
      expect(await api.callFlutterEchoNullableEnum(null), null);
      expect(await api.callFlutterEchoNullableEnum(ProxyApiTestEnum.two), ProxyApiTestEnum.two);
    });

    testWidgets('callFlutterEchoNullableProxyApi', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableProxyApi: (_, ProxyApiSuperClass? aProxyApi) => aProxyApi,
      );

      expect(await api.callFlutterEchoNullableProxyApi(null), null);

      final proxyApi = ProxyApiSuperClass();
      expect(await api.callFlutterEchoNullableProxyApi(proxyApi), proxyApi);
    });

    testWidgets('callFlutterNoopAsync', (_) async {
      var called = false;
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterNoopAsync: (ProxyApiTestClass instance) async {
          called = true;
        },
      );

      await api.callFlutterNoopAsync();
      expect(called, isTrue);
    });

    testWidgets('callFlutterEchoAsyncString', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoAsyncString: (_, String aString) async => aString,
      );

      const value = 'a string';
      expect(await api.callFlutterEchoAsyncString(value), value);
    });
  });
}

ProxyApiTestClass _createGenericProxyApiTestClass({
  bool Function(ProxyApiTestClass, bool)? flutterEchoBool,
  int Function(ProxyApiTestClass, int)? flutterEchoInt,
  double Function(ProxyApiTestClass, double)? flutterEchoDouble,
  String Function(ProxyApiTestClass, String)? flutterEchoString,
  Uint8List Function(ProxyApiTestClass, Uint8List)? flutterEchoUint8List,
  List<Object?> Function(ProxyApiTestClass, List<Object?>)? flutterEchoList,
  List<ProxyApiTestClass?> Function(ProxyApiTestClass, List<ProxyApiTestClass?>)?
  flutterEchoProxyApiList,
  Map<String?, Object?> Function(ProxyApiTestClass, Map<String?, Object?>)? flutterEchoMap,
  ProxyApiTestEnum Function(ProxyApiTestClass, ProxyApiTestEnum)? flutterEchoEnum,
  ProxyApiSuperClass Function(ProxyApiTestClass, ProxyApiSuperClass)? flutterEchoProxyApi,
  Future<String> Function(ProxyApiTestClass, String)? flutterEchoAsyncString,
  Map<String?, ProxyApiTestClass?> Function(ProxyApiTestClass, Map<String?, ProxyApiTestClass?>)?
  flutterEchoProxyApiMap,
  bool? Function(ProxyApiTestClass, bool?)? flutterEchoNullableBool,
  int? Function(ProxyApiTestClass, int?)? flutterEchoNullableInt,
  double? Function(ProxyApiTestClass, double?)? flutterEchoNullableDouble,
  String? Function(ProxyApiTestClass, String?)? flutterEchoNullableString,
  Uint8List? Function(ProxyApiTestClass, Uint8List?)? flutterEchoNullableUint8List,
  List<Object?>? Function(ProxyApiTestClass, List<Object?>?)? flutterEchoNullableList,
  Map<String?, Object?>? Function(ProxyApiTestClass, Map<String?, Object?>?)?
  flutterEchoNullableMap,
  ProxyApiTestEnum? Function(ProxyApiTestClass, ProxyApiTestEnum?)? flutterEchoNullableEnum,
  ProxyApiSuperClass? Function(ProxyApiTestClass, ProxyApiSuperClass?)? flutterEchoNullableProxyApi,
  Future<void> Function(ProxyApiTestClass)? flutterNoopAsync,
  Future<void> Function(ProxyApiTestClass)? flutterNoop,
  void Function(ProxyApiTestClass)? flutterThrowError,
  void Function(ProxyApiTestClass)? flutterThrowErrorFromVoid,
}) {
  return ProxyApiTestClass.namedConstructor(
    aBool: true,
    anInt: 0,
    aDouble: 0.0,
    aString: '',
    aUint8List: Uint8List(0),
    aList: const <Object?>[],
    aMap: const <String?, Object?>{},
    anEnum: ProxyApiTestEnum.one,
    aProxyApi: ProxyApiSuperClass(),
    flutterEchoBool: flutterEchoBool ?? (ProxyApiTestClass instance, bool aBool) => aBool,
    flutterEchoInt: flutterEchoInt ?? (_, int anInt) => anInt,
    flutterEchoDouble: flutterEchoDouble ?? (_, double aDouble) => aDouble,
    flutterEchoString: flutterEchoString ?? (_, String aString) => aString,
    flutterEchoUint8List: flutterEchoUint8List ?? (_, Uint8List aUint8List) => aUint8List,
    flutterEchoList: flutterEchoList ?? (_, List<Object?> aList) => aList,
    flutterEchoProxyApiList:
        flutterEchoProxyApiList ?? (_, List<ProxyApiTestClass?> aList) => aList,
    flutterEchoMap: flutterEchoMap ?? (_, Map<String?, Object?> aMap) => aMap,
    flutterEchoEnum: flutterEchoEnum ?? (_, ProxyApiTestEnum anEnum) => anEnum,
    flutterEchoProxyApi: flutterEchoProxyApi ?? (_, ProxyApiSuperClass aProxyApi) => aProxyApi,
    flutterEchoAsyncString: flutterEchoAsyncString ?? (_, String aString) async => aString,
    flutterEchoProxyApiMap:
        flutterEchoProxyApiMap ?? (_, Map<String?, ProxyApiTestClass?> aMap) => aMap,
    flutterEchoNullableBool: flutterEchoNullableBool ?? (_, bool? aBool) => aBool,
    flutterEchoNullableInt: flutterEchoNullableInt ?? (_, int? anInt) => anInt,
    flutterEchoNullableDouble: flutterEchoNullableDouble ?? (_, double? aDouble) => aDouble,
    flutterEchoNullableString: flutterEchoNullableString ?? (_, String? aString) => aString,
    flutterEchoNullableUint8List:
        flutterEchoNullableUint8List ?? (_, Uint8List? aUint8List) => aUint8List,
    flutterEchoNullableList: flutterEchoNullableList ?? (_, List<Object?>? aList) => aList,
    flutterEchoNullableMap: flutterEchoNullableMap ?? (_, Map<String?, Object?>? aMap) => aMap,
    flutterEchoNullableEnum: flutterEchoNullableEnum ?? (_, ProxyApiTestEnum? anEnum) => anEnum,
    flutterEchoNullableProxyApi:
        flutterEchoNullableProxyApi ?? (_, ProxyApiSuperClass? aProxyApi) => aProxyApi,
    flutterNoopAsync: flutterNoopAsync ?? (_) async {},
    flutterNoop: flutterNoop ?? (_) async {},
    flutterThrowError: flutterThrowError ?? (_) => null,
    flutterThrowErrorFromVoid: flutterThrowErrorFromVoid ?? (_) {},
  );
}
