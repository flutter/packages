// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: unused_local_variable

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ni_test_types.dart';
import 'src/generated/ni_tests.gen.dart';

/// Possible host languages that test can target.
enum TargetGenerator {
  /// The Windows C++ generator.
  cpp,

  /// The Linux GObject generator.
  gobject,

  /// The Android Java generator.
  java,

  /// The Android Kotlin generator.
  kotlin,

  /// The iOS Objective-C generator.
  objc,

  /// The iOS or macOS Swift generator.
  swift,
}

/// Host languages that support generating Proxy APIs.
const Set<TargetGenerator> proxyApiSupportedLanguages = <TargetGenerator>{
  TargetGenerator.kotlin,
  TargetGenerator.swift,
};

/// Sets up and runs the integration tests.
void runPigeonIntegrationTests(TargetGenerator targetGenerator) {
  group('Host sync API tests', () {
    testWidgets('basic void->void call works', (WidgetTester _) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();
      try {
        api!.noop();
      } catch (e) {
        fail(e.toString());
      }
    });

    testWidgets('all datatypes serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      final NIAllTypes echoObject = api!.echoAllTypes(genericNIAllTypes);
      expect(echoObject, genericNIAllTypes);
    });

    //     testWidgets('all nullable datatypes serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       final NIAllNullableTypes? echoObject =
    //           api!.echoAllNullableTypes(recursiveNIAllNullableTypes);

    //       expect(echoObject, recursiveNIAllNullableTypes);
    //     });

    //     testWidgets('all null datatypes serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       final NIAllNullableTypes allTypesNull = NIAllNullableTypes();

    //       final NIAllNullableTypes? echoNullFilledClass =
    //           api!.echoAllNullableTypes(allTypesNull);
    //       expect(allTypesNull, echoNullFilledClass);
    //     });

    testWidgets(
      'Classes with list of null serialize and deserialize correctly',
      (WidgetTester _) async {
        final NIHostIntegrationCoreApiForNativeInterop? api =
            NIHostIntegrationCoreApiForNativeInterop.getInstance();

        final NIAllNullableTypesWithoutRecursion listTypes =
            NIAllNullableTypesWithoutRecursion(list: <String?>['String', null]);

        final NIAllNullableTypesWithoutRecursion? echoNullFilledClass = api!
            .echoAllNullableTypesWithoutRecursion(listTypes);

        expect(listTypes, echoNullFilledClass);
      },
    );

    testWidgets(
      'Classes with map of null serialize and deserialize correctly',
      (WidgetTester _) async {
        final NIHostIntegrationCoreApiForNativeInterop? api =
            NIHostIntegrationCoreApiForNativeInterop.getInstance();

        final NIAllNullableTypesWithoutRecursion listTypes =
            NIAllNullableTypesWithoutRecursion(
              map: <String?, String?>{'String': 'string', 'null': null},
            );

        final NIAllNullableTypesWithoutRecursion? echoNullFilledClass = api!
            .echoAllNullableTypesWithoutRecursion(listTypes);

        expect(listTypes, echoNullFilledClass);
      },
    );

    testWidgets(
      'all nullable datatypes without recursion serialize and deserialize correctly',
      (WidgetTester _) async {
        final NIHostIntegrationCoreApiForNativeInterop? api =
            NIHostIntegrationCoreApiForNativeInterop.getInstance();

        final NIAllNullableTypesWithoutRecursion? echoObject = api!
            .echoAllNullableTypesWithoutRecursion(
              genericNIAllNullableTypesWithoutRecursion,
            );

        expect(echoObject, genericNIAllNullableTypesWithoutRecursion);
      },
    );

    testWidgets(
      'all null datatypes without recursion serialize and deserialize correctly',
      (WidgetTester _) async {
        final NIHostIntegrationCoreApiForNativeInterop? api =
            NIHostIntegrationCoreApiForNativeInterop.getInstance();

        final NIAllNullableTypesWithoutRecursion allTypesNull =
            NIAllNullableTypesWithoutRecursion();

        final NIAllNullableTypesWithoutRecursion? echoNullFilledClass = api!
            .echoAllNullableTypesWithoutRecursion(allTypesNull);
        expect(allTypesNull, echoNullFilledClass);
      },
    );

    testWidgets(
      'Classes without recursion with list of null serialize and deserialize correctly',
      (WidgetTester _) async {
        final NIHostIntegrationCoreApiForNativeInterop? api =
            NIHostIntegrationCoreApiForNativeInterop.getInstance();

        final NIAllNullableTypesWithoutRecursion listTypes =
            NIAllNullableTypesWithoutRecursion(list: <String?>['String', null]);

        final NIAllNullableTypesWithoutRecursion? echoNullFilledClass = api!
            .echoAllNullableTypesWithoutRecursion(listTypes);

        expect(listTypes, echoNullFilledClass);
      },
    );

    testWidgets(
      'Classes without recursion with map of null serialize and deserialize correctly',
      (WidgetTester _) async {
        final NIHostIntegrationCoreApiForNativeInterop? api =
            NIHostIntegrationCoreApiForNativeInterop.getInstance();

        final NIAllNullableTypesWithoutRecursion listTypes =
            NIAllNullableTypesWithoutRecursion(
              map: <String?, String?>{'String': 'string', 'null': null},
            );

        final NIAllNullableTypesWithoutRecursion? echoNullFilledClass = api!
            .echoAllNullableTypesWithoutRecursion(listTypes);

        expect(listTypes, echoNullFilledClass);
      },
    );

    testWidgets('errors are returned correctly', (WidgetTester _) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      expect(() async {
        api!.throwError();
      }, throwsA(isA<PlatformException>()));
    });

    testWidgets('errors are returned from void methods correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      expect(() async {
        api!.throwErrorFromVoid();
      }, throwsA(isA<PlatformException>()));
    });

    testWidgets('flutter errors are returned correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();
      expect(
        () => api!.throwFlutterError(),
        throwsA(
          (dynamic e) =>
              e is PlatformException &&
              e.code == 'code' &&
              e.message == 'message' &&
              e.details == 'details',
        ),
      );
    });

    testWidgets('nested objects can be sent correctly', (WidgetTester _) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();
      final NIAllClassesWrapper classWrapper = classWrapperMaker();
      final String? receivedString = api!.extractNestedNullableString(
        classWrapper,
      );
      expect(
        receivedString,
        classWrapper.allNullableTypesWithoutRecursion?.aNullableString,
      );
    });

    testWidgets('nested objects can be received correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      const String sentString = 'Some string';
      final NIAllClassesWrapper receivedObject = api!
          .createNestedNullableString(sentString);
      expect(
        receivedObject.allNullableTypesWithoutRecursion?.aNullableString,
        sentString,
      );
    });

    testWidgets('nested classes can serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();
      final NIAllClassesWrapper classWrapper = classWrapperMaker();
      final NIAllClassesWrapper receivedClassWrapper = api!.echoClassWrapper(
        classWrapper,
      );

      expect(classWrapper, receivedClassWrapper);
    });

    testWidgets('nested null classes can serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();
      final NIAllClassesWrapper classWrapper = classWrapperMaker();

      classWrapper.allTypes = null;

      final NIAllClassesWrapper receivedClassWrapper = api!.echoClassWrapper(
        classWrapper,
      );
      expect(classWrapper, receivedClassWrapper);
    });

    testWidgets(
      'Arguments of multiple types serialize and deserialize correctly',
      (WidgetTester _) async {
        final NIHostIntegrationCoreApiForNativeInterop? api =
            NIHostIntegrationCoreApiForNativeInterop.getInstance();
        const String aNullableString = 'this is a String';
        const bool aNullableBool = false;
        const int aNullableInt = regularInt;

        final NIAllNullableTypesWithoutRecursion echoObject = api!
            .sendMultipleNullableTypesWithoutRecursion(
              aNullableBool,
              aNullableInt,
              aNullableString,
            );
        expect(echoObject.aNullableInt, aNullableInt);
        expect(echoObject.aNullableBool, aNullableBool);
        expect(echoObject.aNullableString, aNullableString);
      },
    );

    testWidgets(
      'Arguments of multiple null types serialize and deserialize correctly',
      (WidgetTester _) async {
        final NIHostIntegrationCoreApiForNativeInterop? api =
            NIHostIntegrationCoreApiForNativeInterop.getInstance();

        final NIAllNullableTypesWithoutRecursion echoNullFilledClass = api!
            .sendMultipleNullableTypes(null, null, null);
        expect(echoNullFilledClass.aNullableInt, null);
        expect(echoNullFilledClass.aNullableBool, null);
        expect(echoNullFilledClass.aNullableString, null);
      },
    );

    testWidgets(
      'Arguments of multiple types serialize and deserialize correctly (WithoutRecursion)',
      (WidgetTester _) async {
        final NIHostIntegrationCoreApiForNativeInterop? api =
            NIHostIntegrationCoreApiForNativeInterop.getInstance();
        const String aNullableString = 'this is a String';
        const bool aNullableBool = false;
        const int aNullableInt = regularInt;

        final NIAllNullableTypesWithoutRecursion echoObject = api!
            .sendMultipleNullableTypesWithoutRecursion(
              aNullableBool,
              aNullableInt,
              aNullableString,
            );
        expect(echoObject.aNullableInt, aNullableInt);
        expect(echoObject.aNullableBool, aNullableBool);
        expect(echoObject.aNullableString, aNullableString);
      },
    );

    testWidgets(
      'Arguments of multiple null types serialize and deserialize correctly (WithoutRecursion)',
      (WidgetTester _) async {
        final NIHostIntegrationCoreApiForNativeInterop? api =
            NIHostIntegrationCoreApiForNativeInterop.getInstance();

        final NIAllNullableTypesWithoutRecursion echoNullFilledClass = api!
            .sendMultipleNullableTypesWithoutRecursion(null, null, null);
        expect(echoNullFilledClass.aNullableInt, null);
        expect(echoNullFilledClass.aNullableBool, null);
        expect(echoNullFilledClass.aNullableString, null);
      },
    );

    testWidgets('Int serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();
      const int sentInt = regularInt;
      final int receivedInt = api!.echoInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Int64 serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      const int sentInt = biggerThanBigInt;
      final int receivedInt = api!.echoInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Doubles serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      const double sentDouble = 2.0694;
      final double receivedDouble = api!.echoDouble(sentDouble);
      expect(receivedDouble, sentDouble);
    });

    testWidgets('booleans serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      for (final bool sentBool in <bool>[true, false]) {
        final bool receivedBool = api!.echoBool(sentBool);
        expect(receivedBool, sentBool);
      }
    });

    testWidgets('strings serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();
      const String sentString = 'default';
      final String receivedString = api!.echoString(sentString);
      expect(receivedString, sentString);
    });

    testWidgets('Uint8List serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();
      final List<int> data = <int>[
        102,
        111,
        114,
        116,
        121,
        45,
        116,
        119,
        111,
        0,
      ];
      final Uint8List sentUint8List = Uint8List.fromList(data);
      final Uint8List receivedUint8List = api!.echoUint8List(sentUint8List);
      expect(receivedUint8List, sentUint8List);
    });

    testWidgets(
      'strings as generic Objects serialize and deserialize correctly',
      (WidgetTester _) async {
        final NIHostIntegrationCoreApiForNativeInterop? api =
            NIHostIntegrationCoreApiForNativeInterop.getInstance();
        const Object sentString = "I'm a computer";
        final Object receivedString = api!.echoObject(sentString);
        expect(receivedString, sentString);
      },
    );

    testWidgets(
      'integers as generic Objects serialize and deserialize correctly',
      (WidgetTester _) async {
        final NIHostIntegrationCoreApiForNativeInterop? api =
            NIHostIntegrationCoreApiForNativeInterop.getInstance();

        const Object sentInt = regularInt;
        final Object receivedInt = api!.echoObject(sentInt);
        expect(receivedInt, sentInt);
      },
    );

    testWidgets(
      'booleans as generic Objects serialize and deserialize correctly',
      (WidgetTester _) async {
        final NIHostIntegrationCoreApiForNativeInterop? api =
            NIHostIntegrationCoreApiForNativeInterop.getInstance();

        const Object sentBool = true;
        final Object receivedBool = api!.echoObject(sentBool);
        expect(receivedBool, sentBool);
      },
    );

    testWidgets(
      'double as generic Objects serialize and deserialize correctly',
      (WidgetTester _) async {
        final NIHostIntegrationCoreApiForNativeInterop? api =
            NIHostIntegrationCoreApiForNativeInterop.getInstance();

        const Object sentDouble = 2.0694;
        final Object receivedDouble = api!.echoObject(sentDouble);
        expect(receivedDouble, sentDouble);
      },
    );

    testWidgets(
      'Uint8List as generic Objects serialize and deserialize correctly',
      (WidgetTester _) async {
        final NIHostIntegrationCoreApiForNativeInterop? api =
            NIHostIntegrationCoreApiForNativeInterop.getInstance();

        final Object sentUint8List = Uint8List.fromList(<int>[1, 2, 3]);
        final Object receivedUint8List = api!.echoObject(sentUint8List);
        expect(receivedUint8List, sentUint8List);
      },
    );

    testWidgets(
      'Int32List as generic Objects serialize and deserialize correctly',
      (WidgetTester _) async {
        final NIHostIntegrationCoreApiForNativeInterop? api =
            NIHostIntegrationCoreApiForNativeInterop.getInstance();

        final Object sentInt32List = Int32List.fromList(<int>[1, 2, 3]);
        final Object receivedInt32List = api!.echoObject(sentInt32List);
        expect(receivedInt32List, sentInt32List);
      },
    );

    testWidgets(
      'Int64List as generic Objects serialize and deserialize correctly',
      (WidgetTester _) async {
        final NIHostIntegrationCoreApiForNativeInterop? api =
            NIHostIntegrationCoreApiForNativeInterop.getInstance();

        final Object sentInt64List = Int64List.fromList(<int>[1, 2, 3]);
        final Object receivedInt64List = api!.echoObject(sentInt64List);
        expect(receivedInt64List, sentInt64List);
      },
    );

    testWidgets(
      'class as generic Objects serialize and deserialize correctly',
      (WidgetTester _) async {
        final NIHostIntegrationCoreApiForNativeInterop? api =
            NIHostIntegrationCoreApiForNativeInterop.getInstance();

        final Object receivedClass = api!.echoObject(
          genericNIAllNullableTypesWithoutRecursion,
        );
        expect(receivedClass, genericNIAllNullableTypesWithoutRecursion);
      },
    );

    // testWidgets('Float32List as generic Objects serialize and deserialize correctly', (WidgetTester _) async {
    //   final NIHostIntegrationCoreApiForNativeInterop? api =
    //       NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //   final Object sentFloat32List = Float32List.fromList(<double>[1.0, 2.0, 3.0]);
    //   final Object receivedFloat32List = api!.echoObject(sentFloat32List);
    //   expect(receivedFloat32List, sentFloat32List);
    // });

    testWidgets(
      'Float64List as generic Objects serialize and deserialize correctly',
      (WidgetTester _) async {
        final NIHostIntegrationCoreApiForNativeInterop? api =
            NIHostIntegrationCoreApiForNativeInterop.getInstance();

        final Object sentFloat64List = Float64List.fromList(<double>[
          1.0,
          2.0,
          3.0,
        ]);
        final Object receivedFloat64List = api!.echoObject(sentFloat64List);
        expect(receivedFloat64List, sentFloat64List);
      },
    );

    testWidgets('List as generic Objects serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      final Object receivedList = api!.echoObject(list);
      expect(receivedList, list);
    });

    testWidgets('Map as generic Objects serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      final Object receivedMap = api!.echoObject(map);
      expect(receivedMap, map);
    });

    testWidgets('lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      final List<Object?> echoObject = api!.echoList(list);
      expect(listEquals(echoObject, list), true);
    });

    testWidgets('string lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      final List<String?> echoObject = api!.echoStringList(stringList);
      expect(listEquals(echoObject, stringList), true);
    });

    testWidgets('int lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      final List<int?> echoObject = api!.echoIntList(intList);
      expect(listEquals(echoObject, intList), true);
    });

    testWidgets('double lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      final List<double?> echoObject = api!.echoDoubleList(doubleList);
      expect(listEquals(echoObject, doubleList), true);
    });

    testWidgets('bool lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      final List<bool?> echoObject = api!.echoBoolList(boolList);
      expect(listEquals(echoObject, boolList), true);
    });

    testWidgets('enum lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      final List<NIAnEnum?> echoObject = api!.echoEnumList(enumList);
      expect(listEquals(echoObject, enumList), true);
    });

    testWidgets('class lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      final List<NIAllNullableTypesWithoutRecursion?> echoObject = api!
          .echoClassList(allNullableTypesWithoutRecursionList);
      for (final (int index, NIAllNullableTypesWithoutRecursion? value)
          in echoObject.indexed) {
        expect(value, allNullableTypesWithoutRecursionList[index]);
      }
    });

    testWidgets('NonNull enum lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      final List<NIAnEnum> echoObject = api!.echoNonNullEnumList(
        nonNullEnumList,
      );
      expect(listEquals(echoObject, nonNullEnumList), true);
    });

    testWidgets('NonNull class lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      final List<NIAllNullableTypesWithoutRecursion> echoObject = api!
          .echoNonNullClassList(nonNullNIAllNullableTypesWithoutRecursionList);
      for (final (int index, NIAllNullableTypesWithoutRecursion value)
          in echoObject.indexed) {
        expect(value, nonNullNIAllNullableTypesWithoutRecursionList[index]);
      }
    });

    testWidgets('maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();
      final Map<Object?, Object?> echoObject = api!.echoMap(map);
      expect(mapEquals(echoObject, map), true);
    });

    testWidgets('string maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();
      final Map<String?, String?> echoObject = api!.echoStringMap(stringMap);
      expect(mapEquals(echoObject, stringMap), true);
    });

    testWidgets('int maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();
      final Map<int?, int?> echoObject = api!.echoIntMap(intMap);
      expect(mapEquals(echoObject, intMap), true);
    });

    testWidgets('enum maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();
      final Map<NIAnEnum?, NIAnEnum?> echoObject = api!.echoEnumMap(enumMap);
      expect(mapEquals(echoObject, enumMap), true);
    });

    testWidgets('class maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();
      final Map<int?, NIAllNullableTypesWithoutRecursion?> echoObject = api!
          .echoClassMap(allNullableTypesWithoutRecursionMap);
      for (final MapEntry<int?, NIAllNullableTypesWithoutRecursion?> entry
          in echoObject.entries) {
        expect(entry.value, allNullableTypesWithoutRecursionMap[entry.key]);
      }
    });

    testWidgets('NonNull string maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();
      final Map<String, String> echoObject = api!.echoNonNullStringMap(
        nonNullStringMap,
      );
      expect(mapEquals(echoObject, nonNullStringMap), true);
    });

    testWidgets('NonNull int maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();
      final Map<int, int> echoObject = api!.echoNonNullIntMap(nonNullIntMap);
      expect(mapEquals(echoObject, nonNullIntMap), true);
    });

    testWidgets('NonNull enum maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();
      final Map<NIAnEnum, NIAnEnum> echoObject = api!.echoNonNullEnumMap(
        nonNullEnumMap,
      );
      expect(mapEquals(echoObject, nonNullEnumMap), true);
    });

    testWidgets('NonNull class maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();
      final Map<int, NIAllNullableTypesWithoutRecursion> echoObject = api!
          .echoNonNullClassMap(nonNullNIAllNullableTypesWithoutRecursionMap);
      for (final MapEntry<int, NIAllNullableTypesWithoutRecursion> entry
          in echoObject.entries) {
        expect(
          entry.value,
          nonNullNIAllNullableTypesWithoutRecursionMap[entry.key],
        );
      }
    });

    testWidgets('enums serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      const NIAnEnum sentEnum = NIAnEnum.two;
      final NIAnEnum receivedEnum = api!.echoEnum(sentEnum);
      expect(receivedEnum, sentEnum);
    });

    testWidgets('enums serialize and deserialize correctly (again)', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      const NIAnotherEnum sentEnum = NIAnotherEnum.justInCase;
      final NIAnotherEnum receivedEnum = api!.echoAnotherEnum(sentEnum);
      expect(receivedEnum, sentEnum);
    });

    testWidgets('multi word enums serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      const NIAnEnum sentEnum = NIAnEnum.fortyTwo;
      final NIAnEnum receivedEnum = api!.echoEnum(sentEnum);
      expect(receivedEnum, sentEnum);
    });

    //     testWidgets('required named parameter', (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();
    //       // This number corresponds with the default value of this method.
    //       const int sentInt = regularInt;
    //       final int receivedInt = api!.echoRequiredInt(anInt: sentInt);
    //       expect(receivedInt, sentInt);
    //     });

    //     testWidgets('optional default parameter no arg', (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       // This number corresponds with the default value of this method.
    //       const double sentDouble = 3.14;
    //       final double receivedDouble = api!.echoOptionalDefaultDouble();
    //       expect(receivedDouble, sentDouble);
    //     });

    //     testWidgets('optional default parameter with arg', (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       const double sentDouble = 3.15;
    //       final double receivedDouble = api!.echoOptionalDefaultDouble(sentDouble);
    //       expect(receivedDouble, sentDouble);
    //     });

    //     testWidgets('named default parameter no arg', (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();
    //       // This string corresponds with the default value of this method.
    //       const String sentString = 'default';
    //       final String receivedString = api!.echoNamedDefaultString();
    //       expect(receivedString, sentString);
    //     });

    //     testWidgets('named default parameter with arg', (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();
    //       // This string corresponds with the default value of this method.
    //       const String sentString = 'notDefault';
    //       final String receivedString =
    //           api!.echoNamedDefaultString(aString: sentString);
    //       expect(receivedString, sentString);
    //     });

    testWidgets('Nullable Int serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      const int sentInt = regularInt;
      final int? receivedInt = api!.echoNullableInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Nullable Int64 serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      const int sentInt = biggerThanBigInt;
      final int? receivedInt = api!.echoNullableInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Null Ints serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      final int? receivedNullInt = api!.echoNullableInt(null);
      expect(receivedNullInt, null);
    });

    testWidgets('Nullable Doubles serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      const double sentDouble = 2.0694;
      final double? receivedDouble = api!.echoNullableDouble(sentDouble);
      expect(receivedDouble, sentDouble);
    });

    testWidgets('Null Doubles serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      final double? receivedNullDouble = api!.echoNullableDouble(null);
      expect(receivedNullDouble, null);
    });

    testWidgets('Nullable booleans serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      for (final bool? sentBool in <bool?>[true, false]) {
        final bool? receivedBool = api!.echoNullableBool(sentBool);
        expect(receivedBool, sentBool);
      }
    });

    testWidgets('Null booleans serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      const bool? sentBool = null;
      final bool? receivedBool = api!.echoNullableBool(sentBool);
      expect(receivedBool, sentBool);
    });

    testWidgets('Nullable strings serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();
      const String sentString = "I'm a computer";
      final String? receivedString = api!.echoNullableString(sentString);
      expect(receivedString, sentString);
    });

    testWidgets('Null strings serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      final String? receivedNullString = api!.echoNullableString(null);
      expect(receivedNullString, null);
    });

    testWidgets('Nullable Uint8List serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();
      final List<int> data = <int>[
        102,
        111,
        114,
        116,
        121,
        45,
        116,
        119,
        111,
        0,
      ];
      final Uint8List sentUint8List = Uint8List.fromList(data);
      final Uint8List? receivedUint8List = api!.echoNullableUint8List(
        sentUint8List,
      );
      expect(receivedUint8List, sentUint8List);
    });

    testWidgets('Null Uint8List serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      final Uint8List? receivedNullUint8List = api!.echoNullableUint8List(null);
      expect(receivedNullUint8List, null);
    });

    testWidgets(
      'generic nullable Objects serialize and deserialize correctly',
      (WidgetTester _) async {
        final NIHostIntegrationCoreApiForNativeInterop? api =
            NIHostIntegrationCoreApiForNativeInterop.getInstance();
        const Object sentString = "I'm a computer";
        final Object? receivedString = api!.echoNullableObject(sentString);
        expect(receivedString, sentString);

        // Echo a second type as well to ensure the handling is generic.
        const Object sentInt = regularInt;
        final Object? receivedInt = api.echoNullableObject(sentInt);
        expect(receivedInt, sentInt);
      },
    );

    testWidgets('Null generic Objects serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      final Object? receivedNullObject = api!.echoNullableObject(null);
      expect(receivedNullObject, null);
    });

    testWidgets('nullable lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      final List<Object?>? echoObject = api!.echoNullableList(list);
      expect(listEquals(echoObject, list), true);
    });

    testWidgets('nullable enum lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      final List<NIAnEnum?>? echoObject = api!.echoNullableEnumList(enumList);
      expect(listEquals(echoObject, enumList), true);
    });

    testWidgets('nullable lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      final List<NIAllNullableTypesWithoutRecursion?>? echoObject = api!
          .echoNullableClassList(allNullableTypesWithoutRecursionList);
      for (final (int index, NIAllNullableTypesWithoutRecursion? value)
          in echoObject!.indexed) {
        expect(value, allNullableTypesWithoutRecursionList[index]);
      }
    });

    testWidgets(
      'nullable NonNull enum lists serialize and deserialize correctly',
      (WidgetTester _) async {
        final NIHostIntegrationCoreApiForNativeInterop? api =
            NIHostIntegrationCoreApiForNativeInterop.getInstance();

        final List<NIAnEnum?>? echoObject = api!.echoNullableNonNullEnumList(
          nonNullEnumList,
        );
        expect(listEquals(echoObject, nonNullEnumList), true);
      },
    );

    testWidgets('nullable NonNull lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      final List<NIAllNullableTypesWithoutRecursion?>? echoObject = api!
          .echoNullableClassList(nonNullNIAllNullableTypesWithoutRecursionList);
      for (final (int index, NIAllNullableTypesWithoutRecursion? value)
          in echoObject!.indexed) {
        expect(value, nonNullNIAllNullableTypesWithoutRecursionList[index]);
      }
    });

    testWidgets('nullable maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();
      final Map<Object?, Object?>? echoObject = api!.echoNullableMap(map);
      expect(mapEquals(echoObject, map), true);
    });

    testWidgets('nullable string maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();
      final Map<String?, String?>? echoObject = api!.echoNullableStringMap(
        stringMap,
      );
      expect(mapEquals(echoObject, stringMap), true);
    });

    testWidgets('nullable int maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();
      final Map<int?, int?>? echoObject = api!.echoNullableIntMap(intMap);
      expect(mapEquals(echoObject, intMap), true);
    });

    testWidgets('nullable enum maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();
      final Map<NIAnEnum?, NIAnEnum?>? echoObject = api!.echoNullableEnumMap(
        enumMap,
      );
      expect(mapEquals(echoObject, enumMap), true);
    });

    testWidgets('nullable class maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();
      final Map<int?, NIAllNullableTypesWithoutRecursion?>? echoObject = api!
          .echoNullableClassMap(allNullableTypesWithoutRecursionMap);
      for (final MapEntry<int?, NIAllNullableTypesWithoutRecursion?> entry
          in echoObject!.entries) {
        expect(entry.value, allNullableTypesWithoutRecursionMap[entry.key]);
      }
    });

    testWidgets(
      'nullable NonNull string maps serialize and deserialize correctly',
      (WidgetTester _) async {
        final NIHostIntegrationCoreApiForNativeInterop? api =
            NIHostIntegrationCoreApiForNativeInterop.getInstance();
        final Map<String?, String?>? echoObject = api!
            .echoNullableNonNullStringMap(nonNullStringMap);
        expect(mapEquals(echoObject, nonNullStringMap), true);
      },
    );

    testWidgets(
      'nullable NonNull int maps serialize and deserialize correctly',
      (WidgetTester _) async {
        final NIHostIntegrationCoreApiForNativeInterop? api =
            NIHostIntegrationCoreApiForNativeInterop.getInstance();
        final Map<int?, int?>? echoObject = api!.echoNullableNonNullIntMap(
          nonNullIntMap,
        );
        expect(mapEquals(echoObject, nonNullIntMap), true);
      },
    );

    testWidgets(
      'nullable NonNull enum maps serialize and deserialize correctly',
      (WidgetTester _) async {
        final NIHostIntegrationCoreApiForNativeInterop? api =
            NIHostIntegrationCoreApiForNativeInterop.getInstance();
        final Map<NIAnEnum?, NIAnEnum?>? echoObject = api!
            .echoNullableNonNullEnumMap(nonNullEnumMap);
        expect(mapEquals(echoObject, nonNullEnumMap), true);
      },
    );

    testWidgets(
      'nullable NonNull class maps serialize and deserialize correctly',
      (WidgetTester _) async {
        final NIHostIntegrationCoreApiForNativeInterop? api =
            NIHostIntegrationCoreApiForNativeInterop.getInstance();
        final Map<int?, NIAllNullableTypesWithoutRecursion?>? echoObject = api!
            .echoNullableNonNullClassMap(
              nonNullNIAllNullableTypesWithoutRecursionMap,
            );
        for (final MapEntry<int?, NIAllNullableTypesWithoutRecursion?> entry
            in echoObject!.entries) {
          expect(
            entry.value,
            nonNullNIAllNullableTypesWithoutRecursionMap[entry.key],
          );
        }
      },
    );

    testWidgets('nullable enums serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      const NIAnEnum sentEnum = NIAnEnum.three;
      final NIAnEnum? echoEnum = api!.echoNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('nullable enums serialize and deserialize correctly (again)', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      const NIAnotherEnum sentEnum = NIAnotherEnum.justInCase;
      final NIAnotherEnum? echoEnum = api!.echoAnotherNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets(
      'multi word nullable enums serialize and deserialize correctly',
      (WidgetTester _) async {
        final NIHostIntegrationCoreApiForNativeInterop? api =
            NIHostIntegrationCoreApiForNativeInterop.getInstance();

        const NIAnEnum sentEnum = NIAnEnum.fourHundredTwentyTwo;
        final NIAnEnum? echoEnum = api!.echoNullableEnum(sentEnum);
        expect(echoEnum, sentEnum);
      },
    );

    testWidgets('null lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      final List<Object?>? echoObject = api!.echoNullableList(null);
      expect(listEquals(echoObject, null), true);
    });

    testWidgets('null maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      final Map<Object?, Object?>? echoObject = api!.echoNullableMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null string maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      final Map<String?, String?>? echoObject = api!.echoNullableStringMap(
        null,
      );
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null int maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      final Map<int?, int?>? echoObject = api!.echoNullableIntMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null enums serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      const NIAnEnum? sentEnum = null;
      final NIAnEnum? echoEnum = api!.echoNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('null enums serialize and deserialize correctly (again)', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      const NIAnotherEnum? sentEnum = null;
      final NIAnotherEnum? echoEnum = api!.echoAnotherNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('null classes serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final NIHostIntegrationCoreApiForNativeInterop? api =
          NIHostIntegrationCoreApiForNativeInterop.getInstance();

      final NIAllNullableTypesWithoutRecursion? echoObject = api!
          .echoAllNullableTypesWithoutRecursion(null);

      expect(echoObject, isNull);
    });

    //     testWidgets('optional nullable parameter', (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       const int sentInt = regularInt;
    //       final int? receivedInt = api!.echoOptionalNullableInt(sentInt);
    //       expect(receivedInt, sentInt);
    //     });

    //     testWidgets('Null optional nullable parameter', (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       final int? receivedNullInt = api!.echoOptionalNullableInt();
    //       expect(receivedNullInt, null);
    //     });

    //     testWidgets('named nullable parameter', (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();
    //       const String sentString = "I'm a computer";
    //       final String? receivedString =
    //           api!.echoNamedNullableString(aNullableString: sentString);
    //       expect(receivedString, sentString);
    //     });

    //     testWidgets('Null named nullable parameter', (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       final String? receivedNullString = api!.echoNamedNullableString();
    //       expect(receivedNullString, null);
    //     });
    //   });

    //   group('Host async API tests', () {
    //     testWidgets('basic void->void call works', (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       expect(api!.noopAsync(), completes);
    //     });

    //     testWidgets('async errors are returned from non void methods correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       expect(() async {
    //         await api!.throwAsyncError();
    //       }, throwsA(isA<PlatformException>()));
    //     });

    //     testWidgets('async errors are returned from void methods correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       expect(() async {
    //         await api!.throwAsyncErrorFromVoid();
    //       }, throwsA(isA<PlatformException>()));
    //     });

    //     // testWidgets(
    //     // 'async flutter errors are returned from non void methods correctly',
    //     //     (WidgetTester _) async {
    //     //   final NIHostIntegrationCoreApiForNativeInterop? api =
    //     //       NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //     //   expect(
    //     //       () => api!.throwAsyncFlutterError(),
    //     //       throwsA((dynamic e) =>
    //     //           e is PlatformException &&
    //     //           e.code == 'code' &&
    //     //           e.message == 'message' &&
    //     //           e.details == 'details'));
    //     // });

    //     testWidgets('all datatypes async serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       final NIAllTypes echoObject =
    //           await api!.echoAsyncNIAllTypes(genericNIAllTypes);

    //       expect(echoObject, genericNIAllTypes);
    //     });

    //     testWidgets(
    //         'all nullable async datatypes serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       final NIAllNullableTypes? echoObject = await api!
    //           .echoAsyncNullableNIAllNullableTypes(recursiveNIAllNullableTypes);

    //       expect(echoObject, recursiveNIAllNullableTypes);
    //     });

    //     testWidgets('all null datatypes async serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       final NIAllNullableTypes allTypesNull = NIAllNullableTypes();

    //       final NIAllNullableTypes? echoNullFilledClass =
    //           await api!.echoAsyncNullableNIAllNullableTypes(allTypesNull);
    //       expect(echoNullFilledClass, allTypesNull);
    //     });

    //     testWidgets(
    //         'all nullable async datatypes without recursion serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       final NIAllNullableTypesWithoutRecursion? echoObject = await api!
    //           .echoAsyncNullableNIAllNullableTypesWithoutRecursion(
    //               genericNIAllNullableTypesWithoutRecursion);

    //       expect(echoObject, genericNIAllNullableTypesWithoutRecursion);
    //     });

    //     testWidgets(
    //         'all null datatypes without recursion async serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       final NIAllNullableTypesWithoutRecursion allTypesNull =
    //           NIAllNullableTypesWithoutRecursion();

    //       final NIAllNullableTypesWithoutRecursion? echoNullFilledClass = await api!
    //           .echoAsyncNullableNIAllNullableTypesWithoutRecursion(allTypesNull);
    //       expect(echoNullFilledClass, allTypesNull);
    //     });

    //     testWidgets('Int async serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       const int sentInt = regularInt;
    //       final int receivedInt = await api!.echoAsyncInt(sentInt);
    //       expect(receivedInt, sentInt);
    //     });

    //     testWidgets('Int64 async serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       const int sentInt = biggerThanBigInt;
    //       final int receivedInt = await api!.echoAsyncInt(sentInt);
    //       expect(receivedInt, sentInt);
    //     });

    //     testWidgets('Doubles async serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       const double sentDouble = 2.0694;
    //       final double receivedDouble = await api!.echoAsyncDouble(sentDouble);
    //       expect(receivedDouble, sentDouble);
    //     });

    //     testWidgets('booleans async serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       for (final bool sentBool in <bool>[true, false]) {
    //         final bool receivedBool = await api!.echoAsyncBool(sentBool);
    //         expect(receivedBool, sentBool);
    //       }
    //     });

    //     testWidgets('strings async serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       const String sentObject = 'Hello, asynchronously!';

    //       final String echoObject = await api!.echoAsyncString(sentObject);
    //       expect(echoObject, sentObject);
    //     });

    //     testWidgets('Uint8List async serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();
    //       final List<int> data = <int>[
    //         102,
    //         111,
    //         114,
    //         116,
    //         121,
    //         45,
    //         116,
    //         119,
    //         111,
    //         0
    //       ];
    //       final Uint8List sentUint8List = Uint8List.fromList(data);
    //       final Uint8List receivedUint8List =
    //           await api!.echoAsyncUint8List(sentUint8List);
    //       expect(receivedUint8List, sentUint8List);
    //     });

    //     testWidgets('generic Objects async serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();
    //       const Object sentString = "I'm a computer";
    //       final Object receivedString = await api!.echoAsyncObject(sentString);
    //       expect(receivedString, sentString);

    //       // Echo a second type as well to ensure the handling is generic.
    //       const Object sentInt = regularInt;
    //       final Object receivedInt = await api.echoAsyncObject(sentInt);
    //       expect(receivedInt, sentInt);
    //     });

    //     testWidgets('lists serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       final List<Object?> echoObject = await api!.echoAsyncList(list);
    //       expect(listEquals(echoObject, list), true);
    //     });

    //     testWidgets('enum lists serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       final List<NIAnEnum?> echoObject = await api!.echoAsyncEnumList(enumList);
    //       expect(listEquals(echoObject, enumList), true);
    //     });

    //     testWidgets('class lists serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       final List<NIAllNullableTypes?> echoObject =
    //           await api!.echoAsyncClassList(allNullableTypesList);
    //       for (final (int index, NIAllNullableTypes? value) in echoObject.indexed) {
    //         expect(value, allNullableTypesList[index]);
    //       }
    //     });

    //     testWidgets('maps serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();
    //       final Map<Object?, Object?> echoObject = await api!.echoAsyncMap(map);
    //       expect(mapEquals(echoObject, map), true);
    //     });

    //     testWidgets('string maps serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();
    //       final Map<String?, String?> echoObject =
    //           await api!.echoAsyncStringMap(stringMap);
    //       expect(mapEquals(echoObject, stringMap), true);
    //     });

    //     testWidgets('int maps serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();
    //       final Map<int?, int?> echoObject = await api!.echoAsyncIntMap(intMap);
    //       expect(mapEquals(echoObject, intMap), true);
    //     });

    //     testWidgets('enum maps serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();
    //       final Map<NIAnEnum?, NIAnEnum?> echoObject =
    //           await api!.echoAsyncEnumMap(enumMap);
    //       expect(mapEquals(echoObject, enumMap), true);
    //     });

    //     testWidgets('class maps serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();
    //       final Map<int?, NIAllNullableTypes?> echoObject =
    //           await api!.echoAsyncClassMap(allNullableTypesMap);
    //       for (final MapEntry<int?, NIAllNullableTypes?> entry
    //           in echoObject.entries) {
    //         expect(entry.value, allNullableTypesMap[entry.key]);
    //       }
    //     });

    //     testWidgets('enums serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       const NIAnEnum sentEnum = NIAnEnum.three;
    //       final NIAnEnum echoEnum = await api!.echoAsyncEnum(sentEnum);
    //       expect(echoEnum, sentEnum);
    //     });

    //     testWidgets('enums serialize and deserialize correctly (again)',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       const NIAnotherEnum sentEnum = NIAnotherEnum.justInCase;
    //       final NIAnotherEnum echoEnum = await api!.echoAnotherAsyncEnum(sentEnum);
    //       expect(echoEnum, sentEnum);
    //     });

    //     testWidgets('multi word enums serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       const NIAnEnum sentEnum = NIAnEnum.fourHundredTwentyTwo;
    //       final NIAnEnum echoEnum = await api!.echoAsyncEnum(sentEnum);
    //       expect(echoEnum, sentEnum);
    //     });

    //     testWidgets('nullable Int async serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       const int sentInt = regularInt;
    //       final int? receivedInt = await api!.echoAsyncNullableInt(sentInt);
    //       expect(receivedInt, sentInt);
    //     });

    //     testWidgets('nullable Int64 async serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       const int sentInt = biggerThanBigInt;
    //       final int? receivedInt = await api!.echoAsyncNullableInt(sentInt);
    //       expect(receivedInt, sentInt);
    //     });

    //     testWidgets('nullable Doubles async serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       const double sentDouble = 2.0694;
    //       final double? receivedDouble =
    //           await api!.echoAsyncNullableDouble(sentDouble);
    //       expect(receivedDouble, sentDouble);
    //     });

    //     testWidgets('nullable booleans async serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       for (final bool sentBool in <bool>[true, false]) {
    //         final bool? receivedBool = await api!.echoAsyncNullableBool(sentBool);
    //         expect(receivedBool, sentBool);
    //       }
    //     });

    //     testWidgets('nullable strings async serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       const String sentObject = 'Hello, asynchronously!';

    //       final String? echoObject = await api!.echoAsyncNullableString(sentObject);
    //       expect(echoObject, sentObject);
    //     });

    //     testWidgets('nullable Uint8List async serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();
    //       final List<int> data = <int>[
    //         102,
    //         111,
    //         114,
    //         116,
    //         121,
    //         45,
    //         116,
    //         119,
    //         111,
    //         0
    //       ];
    //       final Uint8List sentUint8List = Uint8List.fromList(data);
    //       final Uint8List? receivedUint8List =
    //           await api!.echoAsyncNullableUint8List(sentUint8List);
    //       expect(receivedUint8List, sentUint8List);
    //     });

    //     testWidgets(
    //         'nullable generic Objects async serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();
    //       const Object sentString = "I'm a computer";
    //       final Object? receivedString =
    //           await api!.echoAsyncNullableObject(sentString);
    //       expect(receivedString, sentString);

    //       // Echo a second type as well to ensure the handling is generic.
    //       const Object sentInt = regularInt;
    //       final Object? receivedInt = await api.echoAsyncNullableObject(sentInt);
    //       expect(receivedInt, sentInt);
    //     });

    //     testWidgets('nullable lists serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       final List<Object?>? echoObject = await api!.echoAsyncNullableList(list);
    //       expect(listEquals(echoObject, list), true);
    //     });

    //     testWidgets('nullable enum lists serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       final List<NIAnEnum?>? echoObject =
    //           await api!.echoAsyncNullableEnumList(enumList);
    //       expect(listEquals(echoObject, enumList), true);
    //     });

    //     testWidgets('nullable class lists serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       final List<NIAllNullableTypes?>? echoObject =
    //           await api!.echoAsyncNullableClassList(allNullableTypesList);
    //       for (final (int index, NIAllNullableTypes? value)
    //           in echoObject!.indexed) {
    //         expect(value, allNullableTypesList[index]);
    //       }
    //     });

    //     testWidgets('nullable maps serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();
    //       final Map<Object?, Object?>? echoObject =
    //           await api!.echoAsyncNullableMap(map);
    //       expect(mapEquals(echoObject, map), true);
    //     });

    //     testWidgets('nullable string maps serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();
    //       final Map<String?, String?>? echoObject =
    //           await api!.echoAsyncNullableStringMap(stringMap);
    //       expect(mapEquals(echoObject, stringMap), true);
    //     });

    //     testWidgets('nullable int maps serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();
    //       final Map<int?, int?>? echoObject =
    //           await api!.echoAsyncNullableIntMap(intMap);
    //       expect(mapEquals(echoObject, intMap), true);
    //     });

    //     testWidgets('nullable enum maps serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();
    //       final Map<NIAnEnum?, NIAnEnum?>? echoObject =
    //           await api!.echoAsyncNullableEnumMap(enumMap);
    //       expect(mapEquals(echoObject, enumMap), true);
    //     });

    //     testWidgets('nullable class maps serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();
    //       final Map<int?, NIAllNullableTypes?>? echoObject =
    //           await api!.echoAsyncNullableClassMap(allNullableTypesMap);
    //       for (final MapEntry<int?, NIAllNullableTypes?> entry
    //           in echoObject!.entries) {
    //         expect(entry.value, allNullableTypesMap[entry.key]);
    //       }
    //     });

    //     testWidgets('nullable enums serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       const NIAnEnum sentEnum = NIAnEnum.three;
    //       final NIAnEnum? echoEnum = await api!.echoAsyncNullableEnum(sentEnum);
    //       expect(echoEnum, sentEnum);
    //     });

    //     testWidgets('nullable enums serialize and deserialize correctly (again)',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       const NIAnotherEnum sentEnum = NIAnotherEnum.justInCase;
    //       final NIAnotherEnum? echoEnum =
    //           await api!.echoAnotherAsyncNullableEnum(sentEnum);
    //       expect(echoEnum, sentEnum);
    //     });

    //     testWidgets('nullable enums serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       const NIAnEnum sentEnum = NIAnEnum.fortyTwo;
    //       final NIAnEnum? echoEnum = await api!.echoAsyncNullableEnum(sentEnum);
    //       expect(echoEnum, sentEnum);
    //     });

    //     testWidgets('null Ints async serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       final int? receivedInt = await api!.echoAsyncNullableInt(null);
    //       expect(receivedInt, null);
    //     });

    //     testWidgets('null Doubles async serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       final double? receivedDouble = await api!.echoAsyncNullableDouble(null);
    //       expect(receivedDouble, null);
    //     });

    //     testWidgets('null booleans async serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       final bool? receivedBool = await api!.echoAsyncNullableBool(null);
    //       expect(receivedBool, null);
    //     });

    //     testWidgets('null strings async serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       final String? echoObject = await api!.echoAsyncNullableString(null);
    //       expect(echoObject, null);
    //     });

    //     testWidgets('null Uint8List async serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       final Uint8List? receivedUint8List =
    //           await api!.echoAsyncNullableUint8List(null);
    //       expect(receivedUint8List, null);
    //     });

    //     testWidgets(
    //         'null generic Objects async serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();
    //       final Object? receivedString = await api!.echoAsyncNullableObject(null);
    //       expect(receivedString, null);
    //     });

    //     testWidgets('null lists serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       final List<Object?>? echoObject = await api!.echoAsyncNullableList(null);
    //       expect(listEquals(echoObject, null), true);
    //     });

    //     testWidgets('null maps serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       final Map<Object?, Object?>? echoObject =
    //           await api!.echoAsyncNullableMap(null);
    //       expect(mapEquals(echoObject, null), true);
    //     });

    //     testWidgets('null string maps serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       final Map<String?, String?>? echoObject =
    //           await api!.echoAsyncNullableStringMap(null);
    //       expect(mapEquals(echoObject, null), true);
    //     });

    //     testWidgets('null int maps serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       final Map<int?, int?>? echoObject =
    //           await api!.echoAsyncNullableIntMap(null);
    //       expect(mapEquals(echoObject, null), true);
    //     });

    //     testWidgets('null enums serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       const NIAnEnum? sentEnum = null;
    //       final NIAnEnum? echoEnum = await api!.echoAsyncNullableEnum(null);
    //       expect(echoEnum, sentEnum);
    //     });

    //     testWidgets('null enums serialize and deserialize correctly',
    //         (WidgetTester _) async {
    //       final NIHostIntegrationCoreApiForNativeInterop? api =
    //           NIHostIntegrationCoreApiForNativeInterop.getInstance();

    //       const NIAnotherEnum? sentEnum = null;
    //       final NIAnotherEnum? echoEnum =
    //           await api!.echoAnotherAsyncNullableEnum(null);
    //       expect(echoEnum, sentEnum);
    //     });
  });

  //   group('Host API with suffix', () {
  //     testWidgets('echo string succeeds with suffix with multiple instances',
  //         (_) async {
  //       final NIHostSmallApiForAndroid? apiWithSuffixOne =
  //           NIHostSmallApiForAndroid.getInstance(channelName: 'suffixOne');
  //       final NIHostSmallApiForAndroid? apiWithSuffixTwo =
  //           NIHostSmallApiForAndroid.getInstance(channelName: 'suffixTwo');
  //       const String sentString = "I'm a computer";
  //       final String echoStringOne = await apiWithSuffixOne!.echo(sentString);
  //       final String echoStringTwo = await apiWithSuffixTwo!.echo(sentString);
  //       expect(sentString, echoStringOne);
  //       expect(sentString, echoStringTwo);
  //     });

  //     testWidgets('multiple instances will have different instance names',
  //         (_) async {
  //       // The only way to get the channel name back is to throw an exception.
  //       // These APIs have no corresponding APIs on the host platforms.
  //       const String sentString = "I'm a computer";
  //       try {
  //         final NIHostSmallApiForAndroid? apiWithSuffixOne =
  //             NIHostSmallApiForAndroid.getInstance(
  //                 channelName: 'suffixWithNoHost');
  //         await apiWithSuffixOne!.echo(sentString);
  //       } on ArgumentError catch (e) {
  //         expect(e.message, contains('suffixWithNoHost'));
  //       }
  //       try {
  //         final NIHostSmallApiForAndroid? apiWithSuffixTwo =
  //             NIHostSmallApiForAndroid.getInstance(
  //                 channelName: 'suffixWithoutHost');
  //         await apiWithSuffixTwo!.echo(sentString);
  //       } on ArgumentError catch (e) {
  //         expect(e.message, contains('suffixWithoutHost'));
  //       }
  //     });
  //   });

  //   group('Flutter Api "ForAndroid"', () {
  //     final NIFlutterIntegrationCoreApiRegistrar registrar =
  //         NIFlutterIntegrationCoreApiRegistrar();

  //     final NIFlutterIntegrationCoreApi flutterApi =
  //         registrar.register(_NIFlutterIntegrationCoreApiImpl());
  //     final NIHostIntegrationCoreApiForNativeInterop? api =
  //         NIHostIntegrationCoreApiForNativeInterop.getInstance();
  //     api!;

  //     testWidgets('basic void->void call works', (WidgetTester _) async {
  //       api.callFlutterNoop();
  //     });

  //     testWidgets('errors are returned from non void methods correctly',
  //         (WidgetTester _) async {
  //       expect(() async {
  //         api.callFlutterThrowError();
  //       }, throwsA(isA<PlatformException>()));
  //     });

  //     testWidgets('errors are returned from void methods correctly',
  //         (WidgetTester _) async {
  //       expect(() async {
  //         api.callFlutterThrowErrorFromVoid();
  //       }, throwsA(isA<PlatformException>()));
  //     });

  //     testWidgets('all datatypes serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final NIAllTypes echoObject =
  //           api.callFlutterEchoNIAllTypes(genericNIAllTypes);

  //       expect(echoObject, genericNIAllTypes);
  //     });

  //     testWidgets(
  //         'Arguments of multiple types serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const String aNullableString = 'this is a String';
  //       const bool aNullableBool = false;
  //       const int aNullableInt = regularInt;

  //       final NIAllNullableTypes compositeObject =
  //           api.callFlutterSendMultipleNullableTypes(
  //               aNullableBool, aNullableInt, aNullableString);
  //       expect(compositeObject.aNullableInt, aNullableInt);
  //       expect(compositeObject.aNullableBool, aNullableBool);
  //       expect(compositeObject.aNullableString, aNullableString);
  //     });

  //     testWidgets(
  //         'Arguments of multiple null types serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final NIAllNullableTypes compositeObject =
  //           api.callFlutterSendMultipleNullableTypes(null, null, null);
  //       expect(compositeObject.aNullableInt, null);
  //       expect(compositeObject.aNullableBool, null);
  //       expect(compositeObject.aNullableString, null);
  //     });

  //     testWidgets(
  //         'Arguments of multiple types serialize and deserialize correctly (WithoutRecursion)',
  //         (WidgetTester _) async {
  //       const String aNullableString = 'this is a String';
  //       const bool aNullableBool = false;
  //       const int aNullableInt = regularInt;

  //       final NIAllNullableTypesWithoutRecursion compositeObject =
  //           api.callFlutterSendMultipleNullableTypesWithoutRecursion(
  //               aNullableBool, aNullableInt, aNullableString);
  //       expect(compositeObject.aNullableInt, aNullableInt);
  //       expect(compositeObject.aNullableBool, aNullableBool);
  //       expect(compositeObject.aNullableString, aNullableString);
  //     });

  //     testWidgets(
  //         'Arguments of multiple null types serialize and deserialize correctly (WithoutRecursion)',
  //         (WidgetTester _) async {
  //       final NIAllNullableTypesWithoutRecursion compositeObject =
  //           api.callFlutterSendMultipleNullableTypesWithoutRecursion(
  //               null, null, null);
  //       expect(compositeObject.aNullableInt, null);
  //       expect(compositeObject.aNullableBool, null);
  //       expect(compositeObject.aNullableString, null);
  //     });

  //     testWidgets('booleans serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       for (final bool sentObject in <bool>[true, false]) {
  //         final bool echoObject = api.callFlutterEchoBool(sentObject);
  //         expect(echoObject, sentObject);
  //       }
  //     });

  //     testWidgets('ints serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const int sentObject = regularInt;
  //       final int echoObject = api.callFlutterEchoInt(sentObject);
  //       expect(echoObject, sentObject);
  //     });

  //     testWidgets('doubles serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const double sentObject = 2.0694;
  //       final double echoObject = api.callFlutterEchoDouble(sentObject);
  //       expect(echoObject, sentObject);
  //     });

  //     testWidgets('strings serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const String sentObject = 'Hello Dart!';
  //       final String echoObject = api.callFlutterEchoString(sentObject);
  //       expect(echoObject, sentObject);
  //     });

  //     testWidgets('Uint8Lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final List<int> data = <int>[
  //         102,
  //         111,
  //         114,
  //         116,
  //         121,
  //         45,
  //         116,
  //         119,
  //         111,
  //         0
  //       ];
  //       final Uint8List sentObject = Uint8List.fromList(data);
  //       final Uint8List echoObject = api.callFlutterEchoUint8List(sentObject);
  //       expect(echoObject, sentObject);
  //     });

  //     testWidgets('lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final List<Object?> echoObject = api.callFlutterEchoList(list);
  //       expect(listEquals(echoObject, list), true);
  //     });

  //     testWidgets('enum lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final List<NIAnEnum?> echoObject = api.callFlutterEchoEnumList(enumList);
  //       expect(listEquals(echoObject, enumList), true);
  //     });

  //     testWidgets('class lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final List<NIAllNullableTypes?> echoObject =
  //           api.callFlutterEchoClassList(allNullableTypesList);
  //       for (final (int index, NIAllNullableTypes? value) in echoObject.indexed) {
  //         expect(value, allNullableTypesList[index]);
  //       }
  //     });

  //     testWidgets('NonNull enum lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final List<NIAnEnum> echoObject =
  //           api.callFlutterEchoNonNullEnumList(nonNullEnumList);
  //       expect(listEquals(echoObject, nonNullEnumList), true);
  //     });

  //     testWidgets('NonNull class lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final List<NIAllNullableTypes> echoObject =
  //           api.callFlutterEchoNonNullClassList(nonNullNIAllNullableTypesList);
  //       for (final (int index, NIAllNullableTypes? value) in echoObject.indexed) {
  //         expect(value, nonNullNIAllNullableTypesList[index]);
  //       }
  //     });

  //     testWidgets('maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<Object?, Object?> echoObject = api.callFlutterEchoMap(map);
  //       expect(mapEquals(echoObject, map), true);
  //     });

  //     testWidgets('string maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<String?, String?> echoObject =
  //           api.callFlutterEchoStringMap(stringMap);
  //       expect(mapEquals(echoObject, stringMap), true);
  //     });

  //     testWidgets('int maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<int?, int?> echoObject = api.callFlutterEchoIntMap(intMap);
  //       expect(mapEquals(echoObject, intMap), true);
  //     });

  //     testWidgets('enum maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<NIAnEnum?, NIAnEnum?> echoObject =
  //           api.callFlutterEchoEnumMap(enumMap);
  //       expect(mapEquals(echoObject, enumMap), true);
  //     });

  //     testWidgets('class maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<int?, NIAllNullableTypes?> echoObject =
  //           api.callFlutterEchoClassMap(allNullableTypesMap);
  //       for (final MapEntry<int?, NIAllNullableTypes?> entry
  //           in echoObject.entries) {
  //         expect(entry.value, allNullableTypesMap[entry.key]);
  //       }
  //     });

  //     testWidgets('NonNull string maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<String, String> echoObject =
  //           api.callFlutterEchoNonNullStringMap(nonNullStringMap);
  //       expect(mapEquals(echoObject, nonNullStringMap), true);
  //     });

  //     testWidgets('NonNull int maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<int, int> echoObject =
  //           api.callFlutterEchoNonNullIntMap(nonNullIntMap);
  //       expect(mapEquals(echoObject, nonNullIntMap), true);
  //     });

  //     testWidgets('NonNull enum maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<NIAnEnum, NIAnEnum> echoObject =
  //           api.callFlutterEchoNonNullEnumMap(nonNullEnumMap);
  //       expect(mapEquals(echoObject, nonNullEnumMap), true);
  //     });

  //     testWidgets('NonNull class maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<int, NIAllNullableTypes> echoObject =
  //           api.callFlutterEchoNonNullClassMap(nonNullNIAllNullableTypesMap);
  //       for (final MapEntry<int, NIAllNullableTypes> entry
  //           in echoObject.entries) {
  //         expect(entry.value, nonNullNIAllNullableTypesMap[entry.key]);
  //       }
  //     });

  //     testWidgets('enums serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const NIAnEnum sentEnum = NIAnEnum.three;
  //       final NIAnEnum echoEnum = api.callFlutterEchoEnum(sentEnum);
  //       expect(echoEnum, sentEnum);
  //     });

  //     testWidgets('enums serialize and deserialize correctly (again)',
  //         (WidgetTester _) async {
  //       const NIAnotherEnum sentEnum = NIAnotherEnum.justInCase;
  //       final NIAnotherEnum echoEnum = api.callFlutterEchoNIAnotherEnum(sentEnum);
  //       expect(echoEnum, sentEnum);
  //     });

  //     testWidgets('multi word enums serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const NIAnEnum sentEnum = NIAnEnum.fortyTwo;
  //       final NIAnEnum echoEnum = api.callFlutterEchoEnum(sentEnum);
  //       expect(echoEnum, sentEnum);
  //     });

  //     testWidgets('nullable booleans serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       for (final bool? sentObject in <bool?>[true, false]) {
  //         final bool? echoObject = api.callFlutterEchoNullableBool(sentObject);
  //         expect(echoObject, sentObject);
  //       }
  //     });

  //     testWidgets('null booleans serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const bool? sentObject = null;
  //       final bool? echoObject = api.callFlutterEchoNullableBool(sentObject);
  //       expect(echoObject, sentObject);
  //     });

  //     testWidgets('nullable ints serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const int sentObject = regularInt;
  //       final int? echoObject = api.callFlutterEchoNullableInt(sentObject);
  //       expect(echoObject, sentObject);
  //     });

  //     testWidgets('nullable big ints serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const int sentObject = biggerThanBigInt;
  //       final int? echoObject = api.callFlutterEchoNullableInt(sentObject);
  //       expect(echoObject, sentObject);
  //     });

  //     testWidgets('null ints serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final int? echoObject = api.callFlutterEchoNullableInt(null);
  //       expect(echoObject, null);
  //     });

  //     testWidgets('nullable doubles serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const double sentObject = 2.0694;
  //       final double? echoObject = api.callFlutterEchoNullableDouble(sentObject);
  //       expect(echoObject, sentObject);
  //     });

  //     testWidgets('null doubles serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final double? echoObject = api.callFlutterEchoNullableDouble(null);
  //       expect(echoObject, null);
  //     });

  //     testWidgets('nullable strings serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const String sentObject = "I'm a computer";
  //       final String? echoObject = api.callFlutterEchoNullableString(sentObject);
  //       expect(echoObject, sentObject);
  //     });

  //     testWidgets('null strings serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final String? echoObject = api.callFlutterEchoNullableString(null);
  //       expect(echoObject, null);
  //     });

  //     testWidgets('nullable Uint8Lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final List<int> data = <int>[
  //         102,
  //         111,
  //         114,
  //         116,
  //         121,
  //         45,
  //         116,
  //         119,
  //         111,
  //         0
  //       ];
  //       final Uint8List sentObject = Uint8List.fromList(data);
  //       final Uint8List? echoObject =
  //           api.callFlutterEchoNullableUint8List(sentObject);
  //       expect(echoObject, sentObject);
  //     });

  //     testWidgets('null Uint8Lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Uint8List? echoObject = api.callFlutterEchoNullableUint8List(null);
  //       expect(echoObject, null);
  //     });

  //     testWidgets('nullable lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final List<Object?>? echoObject = api.callFlutterEchoNullableList(list);
  //       expect(listEquals(echoObject, list), true);
  //     });

  //     testWidgets('nullable enum lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final List<NIAnEnum?>? echoObject =
  //           api.callFlutterEchoNullableEnumList(enumList);
  //       expect(listEquals(echoObject, enumList), true);
  //     });

  //     testWidgets('nullable class lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final List<NIAllNullableTypes?>? echoObject =
  //           api.callFlutterEchoNullableClassList(allNullableTypesList);
  //       for (final (int index, NIAllNullableTypes? value)
  //           in echoObject!.indexed) {
  //         expect(value, allNullableTypesList[index]);
  //       }
  //     });

  //     testWidgets(
  //         'nullable NonNull enum lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final List<NIAnEnum?>? echoObject =
  //           api.callFlutterEchoNullableNonNullEnumList(nonNullEnumList);
  //       expect(listEquals(echoObject, nonNullEnumList), true);
  //     });

  //     testWidgets(
  //         'nullable NonNull class lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final List<NIAllNullableTypes?>? echoObject =
  //           api.callFlutterEchoNullableNonNullClassList(
  //               nonNullNIAllNullableTypesList);
  //       for (final (int index, NIAllNullableTypes? value)
  //           in echoObject!.indexed) {
  //         expect(value, nonNullNIAllNullableTypesList[index]);
  //       }
  //     });

  //     testWidgets('null lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final List<Object?>? echoObject = api.callFlutterEchoNullableList(null);
  //       expect(listEquals(echoObject, null), true);
  //     });

  //     testWidgets('nullable maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<Object?, Object?>? echoObject =
  //           api.callFlutterEchoNullableMap(map);
  //       expect(mapEquals(echoObject, map), true);
  //     });

  //     testWidgets('null maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<Object?, Object?>? echoObject =
  //           api.callFlutterEchoNullableMap(null);
  //       expect(mapEquals(echoObject, null), true);
  //     });

  //     testWidgets('nullable string maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<String?, String?>? echoObject =
  //           api.callFlutterEchoNullableStringMap(stringMap);
  //       expect(mapEquals(echoObject, stringMap), true);
  //     });

  //     testWidgets('nullable int maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<int?, int?>? echoObject =
  //           api.callFlutterEchoNullableIntMap(intMap);
  //       expect(mapEquals(echoObject, intMap), true);
  //     });

  //     testWidgets('nullable enum maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<NIAnEnum?, NIAnEnum?>? echoObject =
  //           api.callFlutterEchoNullableEnumMap(enumMap);
  //       expect(mapEquals(echoObject, enumMap), true);
  //     });

  //     testWidgets('nullable class maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<int?, NIAllNullableTypes?>? echoObject =
  //           api.callFlutterEchoNullableClassMap(allNullableTypesMap);
  //       for (final MapEntry<int?, NIAllNullableTypes?> entry
  //           in echoObject!.entries) {
  //         expect(entry.value, allNullableTypesMap[entry.key]);
  //       }
  //     });

  //     testWidgets(
  //         'nullable NonNull string maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<String?, String?>? echoObject =
  //           api.callFlutterEchoNullableNonNullStringMap(nonNullStringMap);
  //       expect(mapEquals(echoObject, nonNullStringMap), true);
  //     });

  //     testWidgets('nullable NonNull int maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<int?, int?>? echoObject =
  //           api.callFlutterEchoNullableNonNullIntMap(nonNullIntMap);
  //       expect(mapEquals(echoObject, nonNullIntMap), true);
  //     });

  //     testWidgets(
  //         'nullable NonNull enum maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<NIAnEnum?, NIAnEnum?>? echoObject =
  //           api.callFlutterEchoNullableNonNullEnumMap(nonNullEnumMap);
  //       expect(mapEquals(echoObject, nonNullEnumMap), true);
  //     });

  //     testWidgets(
  //         'nullable NonNull class maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<int?, NIAllNullableTypes?>? echoObject = api
  //           .callFlutterEchoNullableNonNullClassMap(nonNullNIAllNullableTypesMap);
  //       for (final MapEntry<int?, NIAllNullableTypes?> entry
  //           in echoObject!.entries) {
  //         expect(entry.value, nonNullNIAllNullableTypesMap[entry.key]);
  //       }
  //     });

  //     testWidgets('null maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<int?, int?>? echoObject =
  //           api.callFlutterEchoNullableIntMap(null);
  //       expect(mapEquals(echoObject, null), true);
  //     });

  //     testWidgets('nullable enums serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const NIAnEnum sentEnum = NIAnEnum.three;
  //       final NIAnEnum? echoEnum = api.callFlutterEchoNullableEnum(sentEnum);
  //       expect(echoEnum, sentEnum);
  //     });

  //     testWidgets('nullable enums serialize and deserialize correctly (again)',
  //         (WidgetTester _) async {
  //       const NIAnotherEnum sentEnum = NIAnotherEnum.justInCase;
  //       final NIAnotherEnum? echoEnum =
  //           api.callFlutterEchoAnotherNullableEnum(sentEnum);
  //       expect(echoEnum, sentEnum);
  //     });

  //     testWidgets('multi word nullable enums serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const NIAnEnum sentEnum = NIAnEnum.fourHundredTwentyTwo;
  //       final NIAnEnum? echoEnum = api.callFlutterEchoNullableEnum(sentEnum);
  //       expect(echoEnum, sentEnum);
  //     });

  //     testWidgets('null enums serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const NIAnEnum? sentEnum = null;
  //       final NIAnEnum? echoEnum = api.callFlutterEchoNullableEnum(sentEnum);
  //       expect(echoEnum, sentEnum);
  //     });

  //     testWidgets('null enums serialize and deserialize correctly (again)',
  //         (WidgetTester _) async {
  //       const NIAnotherEnum? sentEnum = null;
  //       final NIAnotherEnum? echoEnum =
  //           api.callFlutterEchoAnotherNullableEnum(sentEnum);
  //       expect(echoEnum, sentEnum);
  //     });

  //     // testWidgets('async method works', (WidgetTester _) async {
  //     //   expect(api.callFlutterNoopAsync(), completes);
  //     // });

  //     // testWidgets('echo string', (WidgetTester _) async {
  //     //   const String aString = 'this is a string';
  //     //   final String echoString = await api.callFlutterEchoAsyncString(aString);
  //     //   expect(echoString, aString);
  //     // });
  //   });

  //   group('Flutter Api with legacy Api', () {
  //     NIFlutterIntegrationCoreApi.setUp(_NIFlutterIntegrationCoreApiImpl());
  //     final NIHostIntegrationCoreApi api =
  //         NIHostIntegrationCoreApi.createWithNIApi();

  //     testWidgets('basic void->void call works', (WidgetTester _) async {
  //       await api.callFlutterNoop();
  //     });

  //     testWidgets('errors are returned from non void methods correctly',
  //         (WidgetTester _) async {
  //       expect(() async {
  //         await api.callFlutterThrowError();
  //       }, throwsA(isA<PlatformException>()));
  //     });

  //     testWidgets('errors are returned from void methods correctly',
  //         (WidgetTester _) async {
  //       expect(() async {
  //         await api.callFlutterThrowErrorFromVoid();
  //       }, throwsA(isA<PlatformException>()));
  //     });

  //     testWidgets('all datatypes serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final NIAllTypes echoObject =
  //           await api.callFlutterEchoNIAllTypes(genericNIAllTypes);

  //       expect(echoObject, genericNIAllTypes);
  //     });

  //     testWidgets(
  //         'Arguments of multiple types serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const String aNullableString = 'this is a String';
  //       const bool aNullableBool = false;
  //       const int aNullableInt = regularInt;

  //       final NIAllNullableTypes compositeObject =
  //           await api.callFlutterSendMultipleNullableTypes(
  //               aNullableBool, aNullableInt, aNullableString);
  //       expect(compositeObject.aNullableInt, aNullableInt);
  //       expect(compositeObject.aNullableBool, aNullableBool);
  //       expect(compositeObject.aNullableString, aNullableString);
  //     });

  //     testWidgets(
  //         'Arguments of multiple null types serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final NIAllNullableTypes compositeObject =
  //           await api.callFlutterSendMultipleNullableTypes(null, null, null);
  //       expect(compositeObject.aNullableInt, null);
  //       expect(compositeObject.aNullableBool, null);
  //       expect(compositeObject.aNullableString, null);
  //     });

  //     testWidgets(
  //         'Arguments of multiple types serialize and deserialize correctly (WithoutRecursion)',
  //         (WidgetTester _) async {
  //       const String aNullableString = 'this is a String';
  //       const bool aNullableBool = false;
  //       const int aNullableInt = regularInt;

  //       final NIAllNullableTypesWithoutRecursion compositeObject =
  //           await api.callFlutterSendMultipleNullableTypesWithoutRecursion(
  //               aNullableBool, aNullableInt, aNullableString);
  //       expect(compositeObject.aNullableInt, aNullableInt);
  //       expect(compositeObject.aNullableBool, aNullableBool);
  //       expect(compositeObject.aNullableString, aNullableString);
  //     });

  //     testWidgets(
  //         'Arguments of multiple null types serialize and deserialize correctly (WithoutRecursion)',
  //         (WidgetTester _) async {
  //       final NIAllNullableTypesWithoutRecursion compositeObject =
  //           await api.callFlutterSendMultipleNullableTypesWithoutRecursion(
  //               null, null, null);
  //       expect(compositeObject.aNullableInt, null);
  //       expect(compositeObject.aNullableBool, null);
  //       expect(compositeObject.aNullableString, null);
  //     });

  //     testWidgets('booleans serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       for (final bool sentObject in <bool>[true, false]) {
  //         final bool echoObject = await api.callFlutterEchoBool(sentObject);
  //         expect(echoObject, sentObject);
  //       }
  //     });

  //     testWidgets('ints serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const int sentObject = regularInt;
  //       final int echoObject = await api.callFlutterEchoInt(sentObject);
  //       expect(echoObject, sentObject);
  //     });

  //     testWidgets('doubles serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const double sentObject = 2.0694;
  //       final double echoObject = await api.callFlutterEchoDouble(sentObject);
  //       expect(echoObject, sentObject);
  //     });

  //     testWidgets('strings serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const String sentObject = 'Hello Dart!';
  //       final String echoObject = await api.callFlutterEchoString(sentObject);
  //       expect(echoObject, sentObject);
  //     });

  //     testWidgets('Uint8Lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final List<int> data = <int>[
  //         102,
  //         111,
  //         114,
  //         116,
  //         121,
  //         45,
  //         116,
  //         119,
  //         111,
  //         0
  //       ];
  //       final Uint8List sentObject = Uint8List.fromList(data);
  //       final Uint8List echoObject =
  //           await api.callFlutterEchoUint8List(sentObject);
  //       expect(echoObject, sentObject);
  //     });

  //     testWidgets('lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final List<Object?> echoObject = await api.callFlutterEchoList(list);
  //       expect(listEquals(echoObject, list), true);
  //     });

  //     testWidgets('enum lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final List<NIAnEnum?> echoObject =
  //           await api.callFlutterEchoEnumList(enumList);
  //       expect(listEquals(echoObject, enumList), true);
  //     });

  //     testWidgets('class lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final List<NIAllNullableTypes?> echoObject =
  //           await api.callFlutterEchoClassList(allNullableTypesList);
  //       for (final (int index, NIAllNullableTypes? value) in echoObject.indexed) {
  //         expect(value, allNullableTypesList[index]);
  //       }
  //     });

  //     testWidgets('NonNull enum lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final List<NIAnEnum> echoObject =
  //           await api.callFlutterEchoNonNullEnumList(nonNullEnumList);
  //       expect(listEquals(echoObject, nonNullEnumList), true);
  //     });

  //     testWidgets('NonNull class lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final List<NIAllNullableTypes> echoObject = await api
  //           .callFlutterEchoNonNullClassList(nonNullNIAllNullableTypesList);
  //       for (final (int index, NIAllNullableTypes? value) in echoObject.indexed) {
  //         expect(value, nonNullNIAllNullableTypesList[index]);
  //       }
  //     });

  //     testWidgets('maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<Object?, Object?> echoObject =
  //           await api.callFlutterEchoMap(map);
  //       expect(mapEquals(echoObject, map), true);
  //     });

  //     testWidgets('string maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<String?, String?> echoObject =
  //           await api.callFlutterEchoStringMap(stringMap);
  //       expect(mapEquals(echoObject, stringMap), true);
  //     });

  //     testWidgets('int maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<int?, int?> echoObject =
  //           await api.callFlutterEchoIntMap(intMap);
  //       expect(mapEquals(echoObject, intMap), true);
  //     });

  //     testWidgets('enum maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<NIAnEnum?, NIAnEnum?> echoObject =
  //           await api.callFlutterEchoEnumMap(enumMap);
  //       expect(mapEquals(echoObject, enumMap), true);
  //     });

  //     testWidgets('class maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<int?, NIAllNullableTypes?> echoObject =
  //           await api.callFlutterEchoClassMap(allNullableTypesMap);
  //       for (final MapEntry<int?, NIAllNullableTypes?> entry
  //           in echoObject.entries) {
  //         expect(entry.value, allNullableTypesMap[entry.key]);
  //       }
  //     });

  //     testWidgets('NonNull string maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<String, String> echoObject =
  //           await api.callFlutterEchoNonNullStringMap(nonNullStringMap);
  //       expect(mapEquals(echoObject, nonNullStringMap), true);
  //     });

  //     testWidgets('NonNull int maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<int, int> echoObject =
  //           await api.callFlutterEchoNonNullIntMap(nonNullIntMap);
  //       expect(mapEquals(echoObject, nonNullIntMap), true);
  //     });

  //     testWidgets('NonNull enum maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<NIAnEnum, NIAnEnum> echoObject =
  //           await api.callFlutterEchoNonNullEnumMap(nonNullEnumMap);
  //       expect(mapEquals(echoObject, nonNullEnumMap), true);
  //     });

  //     testWidgets('NonNull class maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<int, NIAllNullableTypes> echoObject = await api
  //           .callFlutterEchoNonNullClassMap(nonNullNIAllNullableTypesMap);
  //       for (final MapEntry<int, NIAllNullableTypes> entry
  //           in echoObject.entries) {
  //         expect(entry.value, nonNullNIAllNullableTypesMap[entry.key]);
  //       }
  //     });

  //     testWidgets('enums serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const NIAnEnum sentEnum = NIAnEnum.three;
  //       final NIAnEnum echoEnum = await api.callFlutterEchoEnum(sentEnum);
  //       expect(echoEnum, sentEnum);
  //     });

  //     testWidgets('enums serialize and deserialize correctly (again)',
  //         (WidgetTester _) async {
  //       const NIAnotherEnum sentEnum = NIAnotherEnum.justInCase;
  //       final NIAnotherEnum echoEnum =
  //           await api.callFlutterEchoNIAnotherEnum(sentEnum);
  //       expect(echoEnum, sentEnum);
  //     });

  //     testWidgets('multi word enums serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const NIAnEnum sentEnum = NIAnEnum.fortyTwo;
  //       final NIAnEnum echoEnum = await api.callFlutterEchoEnum(sentEnum);
  //       expect(echoEnum, sentEnum);
  //     });

  //     testWidgets('nullable booleans serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       for (final bool? sentObject in <bool?>[true, false]) {
  //         final bool? echoObject =
  //             await api.callFlutterEchoNullableBool(sentObject);
  //         expect(echoObject, sentObject);
  //       }
  //     });

  //     testWidgets('null booleans serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const bool? sentObject = null;
  //       final bool? echoObject =
  //           await api.callFlutterEchoNullableBool(sentObject);
  //       expect(echoObject, sentObject);
  //     });

  //     testWidgets('nullable ints serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const int sentObject = regularInt;
  //       final int? echoObject = await api.callFlutterEchoNullableInt(sentObject);
  //       expect(echoObject, sentObject);
  //     });

  //     testWidgets('nullable big ints serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const int sentObject = biggerThanBigInt;
  //       final int? echoObject = await api.callFlutterEchoNullableInt(sentObject);
  //       expect(echoObject, sentObject);
  //     });

  //     testWidgets('null ints serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final int? echoObject = await api.callFlutterEchoNullableInt(null);
  //       expect(echoObject, null);
  //     });

  //     testWidgets('nullable doubles serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const double sentObject = 2.0694;
  //       final double? echoObject =
  //           await api.callFlutterEchoNullableDouble(sentObject);
  //       expect(echoObject, sentObject);
  //     });

  //     testWidgets('null doubles serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final double? echoObject = await api.callFlutterEchoNullableDouble(null);
  //       expect(echoObject, null);
  //     });

  //     testWidgets('nullable strings serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const String sentObject = "I'm a computer";
  //       final String? echoObject =
  //           await api.callFlutterEchoNullableString(sentObject);
  //       expect(echoObject, sentObject);
  //     });

  //     testWidgets('null strings serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final String? echoObject = await api.callFlutterEchoNullableString(null);
  //       expect(echoObject, null);
  //     });

  //     testWidgets('nullable Uint8Lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final List<int> data = <int>[
  //         102,
  //         111,
  //         114,
  //         116,
  //         121,
  //         45,
  //         116,
  //         119,
  //         111,
  //         0
  //       ];
  //       final Uint8List sentObject = Uint8List.fromList(data);
  //       final Uint8List? echoObject =
  //           await api.callFlutterEchoNullableUint8List(sentObject);
  //       expect(echoObject, sentObject);
  //     });

  //     testWidgets('null Uint8Lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Uint8List? echoObject =
  //           await api.callFlutterEchoNullableUint8List(null);
  //       expect(echoObject, null);
  //     });

  //     testWidgets('nullable lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final List<Object?>? echoObject =
  //           await api.callFlutterEchoNullableList(list);
  //       expect(listEquals(echoObject, list), true);
  //     });

  //     testWidgets('nullable enum lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final List<NIAnEnum?>? echoObject =
  //           await api.callFlutterEchoNullableEnumList(enumList);
  //       expect(listEquals(echoObject, enumList), true);
  //     });

  //     testWidgets('nullable class lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final List<NIAllNullableTypes?>? echoObject =
  //           await api.callFlutterEchoNullableClassList(allNullableTypesList);
  //       for (final (int index, NIAllNullableTypes? value)
  //           in echoObject!.indexed) {
  //         expect(value, allNullableTypesList[index]);
  //       }
  //     });

  //     testWidgets(
  //         'nullable NonNull enum lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final List<NIAnEnum?>? echoObject =
  //           await api.callFlutterEchoNullableNonNullEnumList(nonNullEnumList);
  //       expect(listEquals(echoObject, nonNullEnumList), true);
  //     });

  //     testWidgets(
  //         'nullable NonNull class lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final List<NIAllNullableTypes?>? echoObject =
  //           await api.callFlutterEchoNullableNonNullClassList(
  //               nonNullNIAllNullableTypesList);
  //       for (final (int index, NIAllNullableTypes? value)
  //           in echoObject!.indexed) {
  //         expect(value, nonNullNIAllNullableTypesList[index]);
  //       }
  //     });

  //     testWidgets('null lists serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final List<Object?>? echoObject =
  //           await api.callFlutterEchoNullableList(null);
  //       expect(listEquals(echoObject, null), true);
  //     });

  //     testWidgets('nullable maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<Object?, Object?>? echoObject =
  //           await api.callFlutterEchoNullableMap(map);
  //       expect(mapEquals(echoObject, map), true);
  //     });

  //     testWidgets('null maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<Object?, Object?>? echoObject =
  //           await api.callFlutterEchoNullableMap(null);
  //       expect(mapEquals(echoObject, null), true);
  //     });

  //     testWidgets('nullable string maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<String?, String?>? echoObject =
  //           await api.callFlutterEchoNullableStringMap(stringMap);
  //       expect(mapEquals(echoObject, stringMap), true);
  //     });

  //     testWidgets('nullable int maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<int?, int?>? echoObject =
  //           await api.callFlutterEchoNullableIntMap(intMap);
  //       expect(mapEquals(echoObject, intMap), true);
  //     });

  //     testWidgets('nullable enum maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<NIAnEnum?, NIAnEnum?>? echoObject =
  //           await api.callFlutterEchoNullableEnumMap(enumMap);
  //       expect(mapEquals(echoObject, enumMap), true);
  //     });

  //     testWidgets('nullable class maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<int?, NIAllNullableTypes?>? echoObject =
  //           await api.callFlutterEchoNullableClassMap(allNullableTypesMap);
  //       for (final MapEntry<int?, NIAllNullableTypes?> entry
  //           in echoObject!.entries) {
  //         expect(entry.value, allNullableTypesMap[entry.key]);
  //       }
  //     });

  //     testWidgets(
  //         'nullable NonNull string maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<String?, String?>? echoObject =
  //           await api.callFlutterEchoNullableNonNullStringMap(nonNullStringMap);
  //       expect(mapEquals(echoObject, nonNullStringMap), true);
  //     });

  //     testWidgets('nullable NonNull int maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<int?, int?>? echoObject =
  //           await api.callFlutterEchoNullableNonNullIntMap(nonNullIntMap);
  //       expect(mapEquals(echoObject, nonNullIntMap), true);
  //     });

  //     testWidgets(
  //         'nullable NonNull enum maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<NIAnEnum?, NIAnEnum?>? echoObject =
  //           await api.callFlutterEchoNullableNonNullEnumMap(nonNullEnumMap);
  //       expect(mapEquals(echoObject, nonNullEnumMap), true);
  //     });

  //     testWidgets(
  //         'nullable NonNull class maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<int?, NIAllNullableTypes?>? echoObject = await api
  //           .callFlutterEchoNullableNonNullClassMap(nonNullNIAllNullableTypesMap);
  //       for (final MapEntry<int?, NIAllNullableTypes?> entry
  //           in echoObject!.entries) {
  //         expect(entry.value, nonNullNIAllNullableTypesMap[entry.key]);
  //       }
  //     });

  //     testWidgets('null maps serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       final Map<int?, int?>? echoObject =
  //           await api.callFlutterEchoNullableIntMap(null);
  //       expect(mapEquals(echoObject, null), true);
  //     });

  //     testWidgets('nullable enums serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const NIAnEnum sentEnum = NIAnEnum.three;
  //       final NIAnEnum? echoEnum =
  //           await api.callFlutterEchoNullableEnum(sentEnum);
  //       expect(echoEnum, sentEnum);
  //     });

  //     testWidgets('nullable enums serialize and deserialize correctly (again)',
  //         (WidgetTester _) async {
  //       const NIAnotherEnum sentEnum = NIAnotherEnum.justInCase;
  //       final NIAnotherEnum? echoEnum =
  //           await api.callFlutterEchoAnotherNullableEnum(sentEnum);
  //       expect(echoEnum, sentEnum);
  //     });

  //     testWidgets('multi word nullable enums serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const NIAnEnum sentEnum = NIAnEnum.fourHundredTwentyTwo;
  //       final NIAnEnum? echoEnum =
  //           await api.callFlutterEchoNullableEnum(sentEnum);
  //       expect(echoEnum, sentEnum);
  //     });

  //     testWidgets('null enums serialize and deserialize correctly',
  //         (WidgetTester _) async {
  //       const NIAnEnum? sentEnum = null;
  //       final NIAnEnum? echoEnum =
  //           await api.callFlutterEchoNullableEnum(sentEnum);
  //       expect(echoEnum, sentEnum);
  //     });

  //     testWidgets('null enums serialize and deserialize correctly (again)',
  //         (WidgetTester _) async {
  //       const NIAnotherEnum? sentEnum = null;
  //       final NIAnotherEnum? echoEnum =
  //           await api.callFlutterEchoAnotherNullableEnum(sentEnum);
  //       expect(echoEnum, sentEnum);
  //     });

  //     // testWidgets('async method works', (WidgetTester _) async {
  //     //   expect(await api.callFlutterNoopAsync(), completes);
  //     // });

  //     // testWidgets('echo string', (WidgetTester _) async {
  //     //   const String aString = 'this is a string';
  //     //   final String echoString = await api.callFlutterEchoAsyncString(aString);
  //     //   expect(echoString, aString);
  //     // });
  //   });
  // }

  // class _NIFlutterIntegrationCoreApiImpl extends NIFlutterIntegrationCoreApi {
  //   @override
  //   String echoString(String value) {
  //     return value;
  //   }

  //   @override
  //   void noop() {
  //     return;
  //   }

  //   @override
  //   int echoInt(int anInt) {
  //     return anInt;
  //   }

  //   @override
  //   bool echoBool(bool aBool) {
  //     return aBool;
  //   }

  //   @override
  //   NIAnotherEnum? echoAnotherNullableEnum(NIAnotherEnum? anotherEnum) {
  //     return anotherEnum;
  //   }

  //   // @override
  //   // Future<String> echoAsyncString(String aString) async {
  //   //   return aString;
  //   // }

  //   @override
  //   List<NIAllNullableTypes?> echoClassList(List<NIAllNullableTypes?> classList) {
  //     return classList;
  //   }

  //   @override
  //   Map<int?, NIAllNullableTypes?> echoClassMap(
  //       Map<int?, NIAllNullableTypes?> classMap) {
  //     return classMap;
  //   }

  //   @override
  //   double echoDouble(double aDouble) {
  //     return aDouble;
  //   }

  //   @override
  //   NIAnEnum echoEnum(NIAnEnum anEnum) {
  //     return anEnum;
  //   }

  //   @override
  //   List<NIAnEnum?> echoEnumList(List<NIAnEnum?> enumList) {
  //     return enumList;
  //   }

  //   @override
  //   Map<NIAnEnum?, NIAnEnum?> echoEnumMap(Map<NIAnEnum?, NIAnEnum?> enumMap) {
  //     return enumMap;
  //   }

  //   @override
  //   Map<int?, int?> echoIntMap(Map<int?, int?> intMap) {
  //     return intMap;
  //   }

  //   @override
  //   NIAllNullableTypes? echoNIAllNullableTypes(NIAllNullableTypes? everything) {
  //     return everything;
  //   }

  //   @override
  //   NIAllNullableTypesWithoutRecursion? echoNIAllNullableTypesWithoutRecursion(
  //       NIAllNullableTypesWithoutRecursion? everything) {
  //     return everything;
  //   }

  //   @override
  //   NIAllTypes echoNIAllTypes(NIAllTypes everything) {
  //     return everything;
  //   }

  //   @override
  //   NIAnotherEnum echoNIAnotherEnum(NIAnotherEnum anotherEnum) {
  //     return anotherEnum;
  //   }

  //   @override
  //   List<Object?> echoList(List<Object?> list) {
  //     return list;
  //   }

  //   @override
  //   Map<Object?, Object?> echoMap(Map<Object?, Object?> map) {
  //     return map;
  //   }

  //   @override
  //   List<NIAllNullableTypes> echoNonNullClassList(
  //       List<NIAllNullableTypes> classList) {
  //     return classList;
  //   }

  //   @override
  //   Map<int, NIAllNullableTypes> echoNonNullClassMap(
  //       Map<int, NIAllNullableTypes> classMap) {
  //     return classMap;
  //   }

  //   @override
  //   List<NIAnEnum> echoNonNullEnumList(List<NIAnEnum> enumList) {
  //     return enumList;
  //   }

  //   @override
  //   Map<NIAnEnum, NIAnEnum> echoNonNullEnumMap(Map<NIAnEnum, NIAnEnum> enumMap) {
  //     return enumMap;
  //   }

  //   @override
  //   Map<int, int> echoNonNullIntMap(Map<int, int> intMap) {
  //     return intMap;
  //   }

  //   @override
  //   Map<String, String> echoNonNullStringMap(Map<String, String> stringMap) {
  //     return stringMap;
  //   }

  //   @override
  //   bool? echoNullableBool(bool? aBool) {
  //     return aBool;
  //   }

  //   @override
  //   List<NIAllNullableTypes?>? echoNullableClassList(
  //       List<NIAllNullableTypes?>? classList) {
  //     return classList;
  //   }

  //   @override
  //   Map<int?, NIAllNullableTypes?>? echoNullableClassMap(
  //       Map<int?, NIAllNullableTypes?>? classMap) {
  //     return classMap;
  //   }

  //   @override
  //   double? echoNullableDouble(double? aDouble) {
  //     return aDouble;
  //   }

  //   @override
  //   NIAnEnum? echoNullableEnum(NIAnEnum? anEnum) {
  //     return anEnum;
  //   }

  //   @override
  //   List<NIAnEnum?>? echoNullableEnumList(List<NIAnEnum?>? enumList) {
  //     return enumList;
  //   }

  //   @override
  //   Map<NIAnEnum?, NIAnEnum?>? echoNullableEnumMap(
  //       Map<NIAnEnum?, NIAnEnum?>? enumMap) {
  //     return enumMap;
  //   }

  //   @override
  //   int? echoNullableInt(int? anInt) {
  //     return anInt;
  //   }

  //   @override
  //   Map<int?, int?>? echoNullableIntMap(Map<int?, int?>? intMap) {
  //     return intMap;
  //   }

  //   @override
  //   List<Object?>? echoNullableList(List<Object?>? list) {
  //     return list;
  //   }

  //   @override
  //   Map<Object?, Object?>? echoNullableMap(Map<Object?, Object?>? map) {
  //     return map;
  //   }

  //   @override
  //   List<NIAllNullableTypes>? echoNullableNonNullClassList(
  //       List<NIAllNullableTypes>? classList) {
  //     return classList;
  //   }

  //   @override
  //   Map<int, NIAllNullableTypes>? echoNullableNonNullClassMap(
  //       Map<int, NIAllNullableTypes>? classMap) {
  //     return classMap;
  //   }

  //   @override
  //   List<NIAnEnum>? echoNullableNonNullEnumList(List<NIAnEnum>? enumList) {
  //     return enumList;
  //   }

  //   @override
  //   Map<NIAnEnum, NIAnEnum>? echoNullableNonNullEnumMap(
  //       Map<NIAnEnum, NIAnEnum>? enumMap) {
  //     return enumMap;
  //   }

  //   @override
  //   Map<int, int>? echoNullableNonNullIntMap(Map<int, int>? intMap) {
  //     return intMap;
  //   }

  //   @override
  //   Map<String, String>? echoNullableNonNullStringMap(
  //       Map<String, String>? stringMap) {
  //     return stringMap;
  //   }

  //   @override
  //   String? echoNullableString(String? aString) {
  //     return aString;
  //   }

  //   @override
  //   Map<String?, String?>? echoNullableStringMap(
  //       Map<String?, String?>? stringMap) {
  //     return stringMap;
  //   }

  //   @override
  //   Uint8List? echoNullableUint8List(Uint8List? list) {
  //     return list;
  //   }

  //   @override
  //   Map<String?, String?> echoStringMap(Map<String?, String?> stringMap) {
  //     return stringMap;
  //   }

  //   @override
  //   Uint8List echoUint8List(Uint8List list) {
  //     return list;
  //   }

  //   // @override
  //   // Future<void> noopAsync() async {
  //   //   return;
  //   // }

  //   @override
  //   NIAllNullableTypes sendMultipleNullableTypes(
  //       bool? aNullableBool, int? aNullableInt, String? aNullableString) {
  //     return NIAllNullableTypes(
  //       aNullableBool: aNullableBool,
  //       aNullableInt: aNullableInt,
  //       aNullableString: aNullableString,
  //     );
  //   }

  //   @override
  //   NIAllNullableTypesWithoutRecursion sendMultipleNullableTypesWithoutRecursion(
  //       bool? aNullableBool, int? aNullableInt, String? aNullableString) {
  //     return NIAllNullableTypesWithoutRecursion(
  //       aNullableBool: aNullableBool,
  //       aNullableInt: aNullableInt,
  //       aNullableString: aNullableString,
  //     );
  //   }

  //   @override
  //   Object? throwError() {
  //     throw FlutterError('this is an error');
  //   }

  //   @override
  //   void throwErrorFromVoid() {
  //     throw FlutterError('this is an error');
  //   }
}
