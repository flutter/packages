// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: unused_local_variable

// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ffi_test_types.dart';
import 'src/generated/jni_tests.gen.dart';

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
      final JniHostIntegrationCoreApiForNativeInterop? api =
          JniHostIntegrationCoreApiForNativeInterop.getInstance();
      try {
        api!.noop();
      } catch (e) {
        print(e);
        fail(e.toString());
      }
    });

//     testWidgets('all datatypes serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final JniAllTypes echoObject = api!.echoAllTypes(genericJniAllTypes);
//       expect(echoObject, genericJniAllTypes);
//     });

//     testWidgets('all nullable datatypes serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final JniAllNullableTypes? echoObject =
//           api!.echoAllNullableTypes(recursiveJniAllNullableTypes);

//       expect(echoObject, recursiveJniAllNullableTypes);
//     });

//     testWidgets('all null datatypes serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final JniAllNullableTypes allTypesNull = JniAllNullableTypes();

//       final JniAllNullableTypes? echoNullFilledClass =
//           api!.echoAllNullableTypes(allTypesNull);
//       expect(allTypesNull, echoNullFilledClass);
//     });

//     testWidgets('Classes with list of null serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final JniAllNullableTypes listTypes =
//           JniAllNullableTypes(list: <String?>['String', null]);

//       final JniAllNullableTypes? echoNullFilledClass =
//           api!.echoAllNullableTypes(listTypes);

//       expect(listTypes, echoNullFilledClass);
//     });

//     testWidgets('Classes with map of null serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final JniAllNullableTypes listTypes = JniAllNullableTypes(
//           map: <String?, String?>{'String': 'string', 'null': null});

//       final JniAllNullableTypes? echoNullFilledClass =
//           api!.echoAllNullableTypes(listTypes);

//       expect(listTypes, echoNullFilledClass);
//     });

//     testWidgets(
//         'all nullable datatypes without recursion serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final JniAllNullableTypesWithoutRecursion? echoObject = api!
//           .echoAllNullableTypesWithoutRecursion(
//               genericJniAllNullableTypesWithoutRecursion);

//       expect(echoObject, genericJniAllNullableTypesWithoutRecursion);
//     });

//     testWidgets(
//         'all null datatypes without recursion serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final JniAllNullableTypesWithoutRecursion allTypesNull =
//           JniAllNullableTypesWithoutRecursion();

//       final JniAllNullableTypesWithoutRecursion? echoNullFilledClass =
//           api!.echoAllNullableTypesWithoutRecursion(allTypesNull);
//       expect(allTypesNull, echoNullFilledClass);
//     });

//     testWidgets(
//         'Classes without recursion with list of null serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final JniAllNullableTypesWithoutRecursion listTypes =
//           JniAllNullableTypesWithoutRecursion(
//         list: <String?>['String', null],
//       );

//       final JniAllNullableTypesWithoutRecursion? echoNullFilledClass =
//           api!.echoAllNullableTypesWithoutRecursion(listTypes);

//       expect(listTypes, echoNullFilledClass);
//     });

//     testWidgets(
//         'Classes without recursion with map of null serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final JniAllNullableTypesWithoutRecursion listTypes =
//           JniAllNullableTypesWithoutRecursion(
//         map: <String?, String?>{'String': 'string', 'null': null},
//       );

//       final JniAllNullableTypesWithoutRecursion? echoNullFilledClass =
//           api!.echoAllNullableTypesWithoutRecursion(listTypes);

//       expect(listTypes, echoNullFilledClass);
//     });

//     testWidgets('errors are returned correctly', (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       expect(() async {
//         api!.throwError();
//       }, throwsA(isA<PlatformException>()));
//     });

//     testWidgets('errors are returned from void methods correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       expect(() async {
//         api!.throwErrorFromVoid();
//       }, throwsA(isA<PlatformException>()));
//     });

//     // testWidgets('flutter errors are returned correctly',
//     //     (WidgetTester _) async {
//     //   final JniHostIntegrationCoreApiForNativeInterop? api =
//     //       JniHostIntegrationCoreApiForNativeInterop.getInstance();
//     //   expect(
//     //       () => api!.throwFlutterError(),
//     //       throwsA((dynamic e) =>
//     //           e is PlatformException &&
//     //           e.code == 'code' &&
//     //           e.message == 'message' &&
//     //           e.details == 'details'));
//     // });

//     testWidgets('nested objects can be sent correctly', (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final JniAllClassesWrapper classWrapper = classWrapperMaker();
//       final String? receivedString =
//           api!.extractNestedNullableString(classWrapper);
//       expect(receivedString, classWrapper.allNullableTypes.aNullableString);
//     });

//     testWidgets('nested objects can be received correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const String sentString = 'Some string';
//       final JniAllClassesWrapper receivedObject =
//           api!.createNestedNullableString(sentString);
//       expect(receivedObject.allNullableTypes.aNullableString, sentString);
//     });

//     testWidgets('nested classes can serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final JniAllClassesWrapper classWrapper = classWrapperMaker();

//       final JniAllClassesWrapper receivedClassWrapper =
//           api!.echoClassWrapper(classWrapper);
//       expect(classWrapper, receivedClassWrapper);
//     });

//     testWidgets('nested null classes can serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final JniAllClassesWrapper classWrapper = classWrapperMaker();

//       classWrapper.allTypes = null;

//       final JniAllClassesWrapper receivedClassWrapper =
//           api!.echoClassWrapper(classWrapper);
//       expect(classWrapper, receivedClassWrapper);
//     });

//     testWidgets(
//         'Arguments of multiple types serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       const String aNullableString = 'this is a String';
//       const bool aNullableBool = false;
//       const int aNullableInt = regularInt;

//       final JniAllNullableTypes echoObject = api!.sendMultipleNullableTypes(
//           aNullableBool, aNullableInt, aNullableString);
//       expect(echoObject.aNullableInt, aNullableInt);
//       expect(echoObject.aNullableBool, aNullableBool);
//       expect(echoObject.aNullableString, aNullableString);
//     });

//     testWidgets(
//         'Arguments of multiple null types serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final JniAllNullableTypes echoNullFilledClass =
//           api!.sendMultipleNullableTypes(null, null, null);
//       expect(echoNullFilledClass.aNullableInt, null);
//       expect(echoNullFilledClass.aNullableBool, null);
//       expect(echoNullFilledClass.aNullableString, null);
//     });

//     testWidgets(
//         'Arguments of multiple types serialize and deserialize correctly (WithoutRecursion)',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       const String aNullableString = 'this is a String';
//       const bool aNullableBool = false;
//       const int aNullableInt = regularInt;

//       final JniAllNullableTypesWithoutRecursion echoObject = api!
//           .sendMultipleNullableTypesWithoutRecursion(
//               aNullableBool, aNullableInt, aNullableString);
//       expect(echoObject.aNullableInt, aNullableInt);
//       expect(echoObject.aNullableBool, aNullableBool);
//       expect(echoObject.aNullableString, aNullableString);
//     });

//     testWidgets(
//         'Arguments of multiple null types serialize and deserialize correctly (WithoutRecursion)',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final JniAllNullableTypesWithoutRecursion echoNullFilledClass =
//           api!.sendMultipleNullableTypesWithoutRecursion(null, null, null);
//       expect(echoNullFilledClass.aNullableInt, null);
//       expect(echoNullFilledClass.aNullableBool, null);
//       expect(echoNullFilledClass.aNullableString, null);
//     });

    testWidgets('Int serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApiForNativeInterop? api =
          JniHostIntegrationCoreApiForNativeInterop.getInstance();
      const int sentInt = regularInt;
      final int receivedInt = api!.echoInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Int64 serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApiForNativeInterop? api =
          JniHostIntegrationCoreApiForNativeInterop.getInstance();

      const int sentInt = biggerThanBigInt;
      final int receivedInt = api!.echoInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Doubles serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApiForNativeInterop? api =
          JniHostIntegrationCoreApiForNativeInterop.getInstance();

      const double sentDouble = 2.0694;
      final double receivedDouble = api!.echoDouble(sentDouble);
      expect(receivedDouble, sentDouble);
    });

    testWidgets('booleans serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApiForNativeInterop? api =
          JniHostIntegrationCoreApiForNativeInterop.getInstance();

      for (final bool sentBool in <bool>[true, false]) {
        final bool receivedBool = api!.echoBool(sentBool);
        expect(receivedBool, sentBool);
      }
    });

    testWidgets('strings serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApiForNativeInterop? api =
          JniHostIntegrationCoreApiForNativeInterop.getInstance();
      const String sentString = 'default';
      final String receivedString = api!.echoString(sentString);
      expect(receivedString, sentString);
    });

    // testWidgets('basicClass serialize and deserialize correctly',
    //     (WidgetTester _) async {
    //   final JniHostIntegrationCoreApiForNativeInterop? api =
    //       JniHostIntegrationCoreApiForNativeInterop.getInstance();
    //   final BasicClass basicClass = BasicClass(anInt: 1, aString: '1');
    //   final BasicClass receivedString = api!.echoBasicClass(basicClass);
    //   expect(receivedString, basicClass);
    // });

//     testWidgets('Uint8List serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
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
//       final Uint8List receivedUint8List = api!.echoUint8List(sentUint8List);
//       expect(receivedUint8List, sentUint8List);
//     });

    // testWidgets('generic Objects serialize and deserialize correctly',
    //     (WidgetTester _) async {
    //   final JniHostIntegrationCoreApiForNativeInterop? api =
    //       JniHostIntegrationCoreApiForNativeInterop.getInstance();
    //   const Object sentString = "I'm a computer";
    //   final Object receivedString = api!.echoObject(sentString);
    //   expect(receivedString, sentString);

    //   // Echo a second type as well to ensure the handling is generic.
    //   const Object sentInt = regularInt;
    //   final Object receivedInt = api.echoObject(sentInt);
    //   expect(receivedInt, sentInt);
    // });

    // testWidgets('lists serialize and deserialize correctly',
    //     (WidgetTester _) async {
    //   final JniHostIntegrationCoreApiForNativeInterop? api =
    //       JniHostIntegrationCoreApiForNativeInterop.getInstance();

    //   final List<Object?> echoObject = api!.echoList(list);
    //   expect(listEquals(echoObject, list), true);
    // });

    // testWidgets('enum lists serialize and deserialize correctly',
    //     (WidgetTester _) async {
    //   final JniHostIntegrationCoreApiForNativeInterop? api =
    //       JniHostIntegrationCoreApiForNativeInterop.getInstance();

    //   final List<JniAnEnum?> echoObject = api!.echoEnumList(enumList);
    //   expect(listEquals(echoObject, enumList), true);
    // });

//     testWidgets('class lists serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final List<JniAllNullableTypes?> echoObject =
//           api!.echoClassList(allNullableTypesList);
//       for (final (int index, JniAllNullableTypes? value)
//           in echoObject.indexed) {
//         expect(value, allNullableTypesList[index]);
//       }
//     });

//     testWidgets('NonNull enum lists serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final List<JniAnEnum> echoObject =
//           api!.echoNonNullEnumList(nonNullEnumList);
//       expect(listEquals(echoObject, nonNullEnumList), true);
//     });

//     testWidgets('NonNull class lists serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final List<JniAllNullableTypes> echoObject =
//           api!.echoNonNullClassList(nonNullJniAllNullableTypesList);
//       for (final (int index, JniAllNullableTypes value) in echoObject.indexed) {
//         expect(value, nonNullJniAllNullableTypesList[index]);
//       }
//     });

//     testWidgets('maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<Object?, Object?> echoObject = api!.echoMap(map);
//       expect(mapEquals(echoObject, map), true);
//     });

//     testWidgets('string maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<String?, String?> echoObject = api!.echoStringMap(stringMap);
//       expect(mapEquals(echoObject, stringMap), true);
//     });

//     testWidgets('int maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<int?, int?> echoObject = api!.echoIntMap(intMap);
//       expect(mapEquals(echoObject, intMap), true);
//     });

//     testWidgets('enum maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<JniAnEnum?, JniAnEnum?> echoObject = api!.echoEnumMap(enumMap);
//       expect(mapEquals(echoObject, enumMap), true);
//     });

//     testWidgets('class maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<int?, JniAllNullableTypes?> echoObject =
//           api!.echoClassMap(allNullableTypesMap);
//       for (final MapEntry<int?, JniAllNullableTypes?> entry
//           in echoObject.entries) {
//         expect(entry.value, allNullableTypesMap[entry.key]);
//       }
//     });

//     testWidgets('NonNull string maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<String, String> echoObject =
//           api!.echoNonNullStringMap(nonNullStringMap);
//       expect(mapEquals(echoObject, nonNullStringMap), true);
//     });

//     testWidgets('NonNull int maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<int, int> echoObject = api!.echoNonNullIntMap(nonNullIntMap);
//       expect(mapEquals(echoObject, nonNullIntMap), true);
//     });

//     testWidgets('NonNull enum maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<JniAnEnum, JniAnEnum> echoObject =
//           api!.echoNonNullEnumMap(nonNullEnumMap);
//       expect(mapEquals(echoObject, nonNullEnumMap), true);
//     });

//     testWidgets('NonNull class maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<int, JniAllNullableTypes> echoObject =
//           api!.echoNonNullClassMap(nonNullJniAllNullableTypesMap);
//       for (final MapEntry<int, JniAllNullableTypes> entry
//           in echoObject.entries) {
//         expect(entry.value, nonNullJniAllNullableTypesMap[entry.key]);
//       }
//     });

//     testWidgets('enums serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const JniAnEnum sentEnum = JniAnEnum.two;
//       final JniAnEnum receivedEnum = api!.echoEnum(sentEnum);
//       expect(receivedEnum, sentEnum);
//     });

//     testWidgets('enums serialize and deserialize correctly (again)',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const JniAnotherEnum sentEnum = JniAnotherEnum.justInCase;
//       final JniAnotherEnum receivedEnum = api!.echoAnotherEnum(sentEnum);
//       expect(receivedEnum, sentEnum);
//     });

//     testWidgets('multi word enums serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const JniAnEnum sentEnum = JniAnEnum.fortyTwo;
//       final JniAnEnum receivedEnum = api!.echoEnum(sentEnum);
//       expect(receivedEnum, sentEnum);
//     });

//     testWidgets('required named parameter', (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       // This number corresponds with the default value of this method.
//       const int sentInt = regularInt;
//       final int receivedInt = api!.echoRequiredInt(anInt: sentInt);
//       expect(receivedInt, sentInt);
//     });

//     testWidgets('optional default parameter no arg', (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       // This number corresponds with the default value of this method.
//       const double sentDouble = 3.14;
//       final double receivedDouble = api!.echoOptionalDefaultDouble();
//       expect(receivedDouble, sentDouble);
//     });

//     testWidgets('optional default parameter with arg', (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const double sentDouble = 3.15;
//       final double receivedDouble = api!.echoOptionalDefaultDouble(sentDouble);
//       expect(receivedDouble, sentDouble);
//     });

//     testWidgets('named default parameter no arg', (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       // This string corresponds with the default value of this method.
//       const String sentString = 'default';
//       final String receivedString = api!.echoNamedDefaultString();
//       expect(receivedString, sentString);
//     });

//     testWidgets('named default parameter with arg', (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       // This string corresponds with the default value of this method.
//       const String sentString = 'notDefault';
//       final String receivedString =
//           api!.echoNamedDefaultString(aString: sentString);
//       expect(receivedString, sentString);
//     });

//     testWidgets('Nullable Int serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const int sentInt = regularInt;
//       final int? receivedInt = api!.echoNullableInt(sentInt);
//       expect(receivedInt, sentInt);
//     });

//     testWidgets('Nullable Int64 serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const int sentInt = biggerThanBigInt;
//       final int? receivedInt = api!.echoNullableInt(sentInt);
//       expect(receivedInt, sentInt);
//     });

//     testWidgets('Null Ints serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final int? receivedNullInt = api!.echoNullableInt(null);
//       expect(receivedNullInt, null);
//     });

//     testWidgets('Nullable Doubles serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const double sentDouble = 2.0694;
//       final double? receivedDouble = api!.echoNullableDouble(sentDouble);
//       expect(receivedDouble, sentDouble);
//     });

//     testWidgets('Null Doubles serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final double? receivedNullDouble = api!.echoNullableDouble(null);
//       expect(receivedNullDouble, null);
//     });

//     testWidgets('Nullable booleans serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       for (final bool? sentBool in <bool?>[true, false]) {
//         final bool? receivedBool = api!.echoNullableBool(sentBool);
//         expect(receivedBool, sentBool);
//       }
//     });

//     testWidgets('Null booleans serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const bool? sentBool = null;
//       final bool? receivedBool = api!.echoNullableBool(sentBool);
//       expect(receivedBool, sentBool);
//     });

//     testWidgets('Nullable strings serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       const String sentString = "I'm a computer";
//       final String? receivedString = api!.echoNullableString(sentString);
//       expect(receivedString, sentString);
//     });

//     testWidgets('Null strings serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final String? receivedNullString = api!.echoNullableString(null);
//       expect(receivedNullString, null);
//     });

//     testWidgets('Nullable Uint8List serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
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
//           api!.echoNullableUint8List(sentUint8List);
//       expect(receivedUint8List, sentUint8List);
//     });

//     testWidgets('Null Uint8List serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final Uint8List? receivedNullUint8List = api!.echoNullableUint8List(null);
//       expect(receivedNullUint8List, null);
//     });

//     testWidgets('generic nullable Objects serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       const Object sentString = "I'm a computer";
//       final Object? receivedString = api!.echoNullableObject(sentString);
//       expect(receivedString, sentString);

//       // Echo a second type as well to ensure the handling is generic.
//       const Object sentInt = regularInt;
//       final Object? receivedInt = api.echoNullableObject(sentInt);
//       expect(receivedInt, sentInt);
//     });

//     testWidgets('Null generic Objects serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final Object? receivedNullObject = api!.echoNullableObject(null);
//       expect(receivedNullObject, null);
//     });

//     testWidgets('nullable lists serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final List<Object?>? echoObject = api!.echoNullableList(list);
//       expect(listEquals(echoObject, list), true);
//     });

//     testWidgets('nullable enum lists serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final List<JniAnEnum?>? echoObject = api!.echoNullableEnumList(enumList);
//       expect(listEquals(echoObject, enumList), true);
//     });

//     testWidgets('nullable lists serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final List<JniAllNullableTypes?>? echoObject =
//           api!.echoNullableClassList(allNullableTypesList);
//       for (final (int index, JniAllNullableTypes? value)
//           in echoObject!.indexed) {
//         expect(value, allNullableTypesList[index]);
//       }
//     });

//     testWidgets(
//         'nullable NonNull enum lists serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final List<JniAnEnum?>? echoObject =
//           api!.echoNullableNonNullEnumList(nonNullEnumList);
//       expect(listEquals(echoObject, nonNullEnumList), true);
//     });

//     testWidgets('nullable NonNull lists serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final List<JniAllNullableTypes?>? echoObject =
//           api!.echoNullableClassList(nonNullJniAllNullableTypesList);
//       for (final (int index, JniAllNullableTypes? value)
//           in echoObject!.indexed) {
//         expect(value, nonNullJniAllNullableTypesList[index]);
//       }
//     });

//     testWidgets('nullable maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<Object?, Object?>? echoObject = api!.echoNullableMap(map);
//       expect(mapEquals(echoObject, map), true);
//     });

//     testWidgets('nullable string maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<String?, String?>? echoObject =
//           api!.echoNullableStringMap(stringMap);
//       expect(mapEquals(echoObject, stringMap), true);
//     });

//     testWidgets('nullable int maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<int?, int?>? echoObject = api!.echoNullableIntMap(intMap);
//       expect(mapEquals(echoObject, intMap), true);
//     });

//     testWidgets('nullable enum maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<JniAnEnum?, JniAnEnum?>? echoObject =
//           api!.echoNullableEnumMap(enumMap);
//       expect(mapEquals(echoObject, enumMap), true);
//     });

//     testWidgets('nullable class maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<int?, JniAllNullableTypes?>? echoObject =
//           api!.echoNullableClassMap(allNullableTypesMap);
//       for (final MapEntry<int?, JniAllNullableTypes?> entry
//           in echoObject!.entries) {
//         expect(entry.value, allNullableTypesMap[entry.key]);
//       }
//     });

//     testWidgets(
//         'nullable NonNull string maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<String?, String?>? echoObject =
//           api!.echoNullableNonNullStringMap(nonNullStringMap);
//       expect(mapEquals(echoObject, nonNullStringMap), true);
//     });

//     testWidgets('nullable NonNull int maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<int?, int?>? echoObject =
//           api!.echoNullableNonNullIntMap(nonNullIntMap);
//       expect(mapEquals(echoObject, nonNullIntMap), true);
//     });

//     testWidgets(
//         'nullable NonNull enum maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<JniAnEnum?, JniAnEnum?>? echoObject =
//           api!.echoNullableNonNullEnumMap(nonNullEnumMap);
//       expect(mapEquals(echoObject, nonNullEnumMap), true);
//     });

//     testWidgets(
//         'nullable NonNull class maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<int?, JniAllNullableTypes?>? echoObject =
//           api!.echoNullableNonNullClassMap(nonNullJniAllNullableTypesMap);
//       for (final MapEntry<int?, JniAllNullableTypes?> entry
//           in echoObject!.entries) {
//         expect(entry.value, nonNullJniAllNullableTypesMap[entry.key]);
//       }
//     });

//     testWidgets('nullable enums serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const JniAnEnum sentEnum = JniAnEnum.three;
//       final JniAnEnum? echoEnum = api!.echoNullableEnum(sentEnum);
//       expect(echoEnum, sentEnum);
//     });

//     testWidgets('nullable enums serialize and deserialize correctly (again)',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const JniAnotherEnum sentEnum = JniAnotherEnum.justInCase;
//       final JniAnotherEnum? echoEnum = api!.echoAnotherNullableEnum(sentEnum);
//       expect(echoEnum, sentEnum);
//     });

//     testWidgets('multi word nullable enums serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const JniAnEnum sentEnum = JniAnEnum.fourHundredTwentyTwo;
//       final JniAnEnum? echoEnum = api!.echoNullableEnum(sentEnum);
//       expect(echoEnum, sentEnum);
//     });

//     testWidgets('null lists serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final List<Object?>? echoObject = api!.echoNullableList(null);
//       expect(listEquals(echoObject, null), true);
//     });

//     testWidgets('null maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final Map<Object?, Object?>? echoObject = api!.echoNullableMap(null);
//       expect(mapEquals(echoObject, null), true);
//     });

//     testWidgets('null string maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final Map<String?, String?>? echoObject =
//           api!.echoNullableStringMap(null);
//       expect(mapEquals(echoObject, null), true);
//     });

//     testWidgets('null int maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final Map<int?, int?>? echoObject = api!.echoNullableIntMap(null);
//       expect(mapEquals(echoObject, null), true);
//     });

//     testWidgets('null enums serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const JniAnEnum? sentEnum = null;
//       final JniAnEnum? echoEnum = api!.echoNullableEnum(sentEnum);
//       expect(echoEnum, sentEnum);
//     });

//     testWidgets('null enums serialize and deserialize correctly (again)',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const JniAnotherEnum? sentEnum = null;
//       final JniAnotherEnum? echoEnum = api!.echoAnotherNullableEnum(sentEnum);
//       expect(echoEnum, sentEnum);
//     });

//     testWidgets('null classes serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final JniAllNullableTypes? echoObject = api!.echoAllNullableTypes(null);

//       expect(echoObject, isNull);
//     });

//     testWidgets('optional nullable parameter', (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const int sentInt = regularInt;
//       final int? receivedInt = api!.echoOptionalNullableInt(sentInt);
//       expect(receivedInt, sentInt);
//     });

//     testWidgets('Null optional nullable parameter', (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final int? receivedNullInt = api!.echoOptionalNullableInt();
//       expect(receivedNullInt, null);
//     });

//     testWidgets('named nullable parameter', (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       const String sentString = "I'm a computer";
//       final String? receivedString =
//           api!.echoNamedNullableString(aNullableString: sentString);
//       expect(receivedString, sentString);
//     });

//     testWidgets('Null named nullable parameter', (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final String? receivedNullString = api!.echoNamedNullableString();
//       expect(receivedNullString, null);
//     });
//   });

//   group('Host async API tests', () {
//     testWidgets('basic void->void call works', (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       expect(api!.noopAsync(), completes);
//     });

//     testWidgets('async errors are returned from non void methods correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       expect(() async {
//         await api!.throwAsyncError();
//       }, throwsA(isA<PlatformException>()));
//     });

//     testWidgets('async errors are returned from void methods correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       expect(() async {
//         await api!.throwAsyncErrorFromVoid();
//       }, throwsA(isA<PlatformException>()));
//     });

//     // testWidgets(
//     // 'async flutter errors are returned from non void methods correctly',
//     //     (WidgetTester _) async {
//     //   final JniHostIntegrationCoreApiForNativeInterop? api =
//     //       JniHostIntegrationCoreApiForNativeInterop.getInstance();

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
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final JniAllTypes echoObject =
//           await api!.echoAsyncJniAllTypes(genericJniAllTypes);

//       expect(echoObject, genericJniAllTypes);
//     });

//     testWidgets(
//         'all nullable async datatypes serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final JniAllNullableTypes? echoObject = await api!
//           .echoAsyncNullableJniAllNullableTypes(recursiveJniAllNullableTypes);

//       expect(echoObject, recursiveJniAllNullableTypes);
//     });

//     testWidgets('all null datatypes async serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final JniAllNullableTypes allTypesNull = JniAllNullableTypes();

//       final JniAllNullableTypes? echoNullFilledClass =
//           await api!.echoAsyncNullableJniAllNullableTypes(allTypesNull);
//       expect(echoNullFilledClass, allTypesNull);
//     });

//     testWidgets(
//         'all nullable async datatypes without recursion serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final JniAllNullableTypesWithoutRecursion? echoObject = await api!
//           .echoAsyncNullableJniAllNullableTypesWithoutRecursion(
//               genericJniAllNullableTypesWithoutRecursion);

//       expect(echoObject, genericJniAllNullableTypesWithoutRecursion);
//     });

//     testWidgets(
//         'all null datatypes without recursion async serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final JniAllNullableTypesWithoutRecursion allTypesNull =
//           JniAllNullableTypesWithoutRecursion();

//       final JniAllNullableTypesWithoutRecursion? echoNullFilledClass =
//           await api!.echoAsyncNullableJniAllNullableTypesWithoutRecursion(
//               allTypesNull);
//       expect(echoNullFilledClass, allTypesNull);
//     });

//     testWidgets('Int async serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const int sentInt = regularInt;
//       final int receivedInt = await api!.echoAsyncInt(sentInt);
//       expect(receivedInt, sentInt);
//     });

//     testWidgets('Int64 async serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const int sentInt = biggerThanBigInt;
//       final int receivedInt = await api!.echoAsyncInt(sentInt);
//       expect(receivedInt, sentInt);
//     });

//     testWidgets('Doubles async serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const double sentDouble = 2.0694;
//       final double receivedDouble = await api!.echoAsyncDouble(sentDouble);
//       expect(receivedDouble, sentDouble);
//     });

//     testWidgets('booleans async serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       for (final bool sentBool in <bool>[true, false]) {
//         final bool receivedBool = await api!.echoAsyncBool(sentBool);
//         expect(receivedBool, sentBool);
//       }
//     });

//     testWidgets('strings async serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const String sentObject = 'Hello, asynchronously!';

//       final String echoObject = await api!.echoAsyncString(sentObject);
//       expect(echoObject, sentObject);
//     });

//     testWidgets('Uint8List async serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
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
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
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
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final List<Object?> echoObject = await api!.echoAsyncList(list);
//       expect(listEquals(echoObject, list), true);
//     });

//     testWidgets('enum lists serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final List<JniAnEnum?> echoObject =
//           await api!.echoAsyncEnumList(enumList);
//       expect(listEquals(echoObject, enumList), true);
//     });

//     testWidgets('class lists serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final List<JniAllNullableTypes?> echoObject =
//           await api!.echoAsyncClassList(allNullableTypesList);
//       for (final (int index, JniAllNullableTypes? value)
//           in echoObject.indexed) {
//         expect(value, allNullableTypesList[index]);
//       }
//     });

//     testWidgets('maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<Object?, Object?> echoObject = await api!.echoAsyncMap(map);
//       expect(mapEquals(echoObject, map), true);
//     });

//     testWidgets('string maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<String?, String?> echoObject =
//           await api!.echoAsyncStringMap(stringMap);
//       expect(mapEquals(echoObject, stringMap), true);
//     });

//     testWidgets('int maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<int?, int?> echoObject = await api!.echoAsyncIntMap(intMap);
//       expect(mapEquals(echoObject, intMap), true);
//     });

//     testWidgets('enum maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<JniAnEnum?, JniAnEnum?> echoObject =
//           await api!.echoAsyncEnumMap(enumMap);
//       expect(mapEquals(echoObject, enumMap), true);
//     });

//     testWidgets('class maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<int?, JniAllNullableTypes?> echoObject =
//           await api!.echoAsyncClassMap(allNullableTypesMap);
//       for (final MapEntry<int?, JniAllNullableTypes?> entry
//           in echoObject.entries) {
//         expect(entry.value, allNullableTypesMap[entry.key]);
//       }
//     });

//     testWidgets('enums serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const JniAnEnum sentEnum = JniAnEnum.three;
//       final JniAnEnum echoEnum = await api!.echoAsyncEnum(sentEnum);
//       expect(echoEnum, sentEnum);
//     });

//     testWidgets('enums serialize and deserialize correctly (again)',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const JniAnotherEnum sentEnum = JniAnotherEnum.justInCase;
//       final JniAnotherEnum echoEnum = await api!.echoAnotherAsyncEnum(sentEnum);
//       expect(echoEnum, sentEnum);
//     });

//     testWidgets('multi word enums serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const JniAnEnum sentEnum = JniAnEnum.fourHundredTwentyTwo;
//       final JniAnEnum echoEnum = await api!.echoAsyncEnum(sentEnum);
//       expect(echoEnum, sentEnum);
//     });

//     testWidgets('nullable Int async serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const int sentInt = regularInt;
//       final int? receivedInt = await api!.echoAsyncNullableInt(sentInt);
//       expect(receivedInt, sentInt);
//     });

//     testWidgets('nullable Int64 async serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const int sentInt = biggerThanBigInt;
//       final int? receivedInt = await api!.echoAsyncNullableInt(sentInt);
//       expect(receivedInt, sentInt);
//     });

//     testWidgets('nullable Doubles async serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const double sentDouble = 2.0694;
//       final double? receivedDouble =
//           await api!.echoAsyncNullableDouble(sentDouble);
//       expect(receivedDouble, sentDouble);
//     });

//     testWidgets('nullable booleans async serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       for (final bool sentBool in <bool>[true, false]) {
//         final bool? receivedBool = await api!.echoAsyncNullableBool(sentBool);
//         expect(receivedBool, sentBool);
//       }
//     });

//     testWidgets('nullable strings async serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const String sentObject = 'Hello, asynchronously!';

//       final String? echoObject = await api!.echoAsyncNullableString(sentObject);
//       expect(echoObject, sentObject);
//     });

//     testWidgets('nullable Uint8List async serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
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
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
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
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final List<Object?>? echoObject = await api!.echoAsyncNullableList(list);
//       expect(listEquals(echoObject, list), true);
//     });

//     testWidgets('nullable enum lists serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final List<JniAnEnum?>? echoObject =
//           await api!.echoAsyncNullableEnumList(enumList);
//       expect(listEquals(echoObject, enumList), true);
//     });

//     testWidgets('nullable class lists serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final List<JniAllNullableTypes?>? echoObject =
//           await api!.echoAsyncNullableClassList(allNullableTypesList);
//       for (final (int index, JniAllNullableTypes? value)
//           in echoObject!.indexed) {
//         expect(value, allNullableTypesList[index]);
//       }
//     });

//     testWidgets('nullable maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<Object?, Object?>? echoObject =
//           await api!.echoAsyncNullableMap(map);
//       expect(mapEquals(echoObject, map), true);
//     });

//     testWidgets('nullable string maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<String?, String?>? echoObject =
//           await api!.echoAsyncNullableStringMap(stringMap);
//       expect(mapEquals(echoObject, stringMap), true);
//     });

//     testWidgets('nullable int maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<int?, int?>? echoObject =
//           await api!.echoAsyncNullableIntMap(intMap);
//       expect(mapEquals(echoObject, intMap), true);
//     });

//     testWidgets('nullable enum maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<JniAnEnum?, JniAnEnum?>? echoObject =
//           await api!.echoAsyncNullableEnumMap(enumMap);
//       expect(mapEquals(echoObject, enumMap), true);
//     });

//     testWidgets('nullable class maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Map<int?, JniAllNullableTypes?>? echoObject =
//           await api!.echoAsyncNullableClassMap(allNullableTypesMap);
//       for (final MapEntry<int?, JniAllNullableTypes?> entry
//           in echoObject!.entries) {
//         expect(entry.value, allNullableTypesMap[entry.key]);
//       }
//     });

//     testWidgets('nullable enums serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const JniAnEnum sentEnum = JniAnEnum.three;
//       final JniAnEnum? echoEnum = await api!.echoAsyncNullableEnum(sentEnum);
//       expect(echoEnum, sentEnum);
//     });

//     testWidgets('nullable enums serialize and deserialize correctly (again)',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const JniAnotherEnum sentEnum = JniAnotherEnum.justInCase;
//       final JniAnotherEnum? echoEnum =
//           await api!.echoAnotherAsyncNullableEnum(sentEnum);
//       expect(echoEnum, sentEnum);
//     });

//     testWidgets('nullable enums serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const JniAnEnum sentEnum = JniAnEnum.fortyTwo;
//       final JniAnEnum? echoEnum = await api!.echoAsyncNullableEnum(sentEnum);
//       expect(echoEnum, sentEnum);
//     });

//     testWidgets('null Ints async serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final int? receivedInt = await api!.echoAsyncNullableInt(null);
//       expect(receivedInt, null);
//     });

//     testWidgets('null Doubles async serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final double? receivedDouble = await api!.echoAsyncNullableDouble(null);
//       expect(receivedDouble, null);
//     });

//     testWidgets('null booleans async serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final bool? receivedBool = await api!.echoAsyncNullableBool(null);
//       expect(receivedBool, null);
//     });

//     testWidgets('null strings async serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final String? echoObject = await api!.echoAsyncNullableString(null);
//       expect(echoObject, null);
//     });

//     testWidgets('null Uint8List async serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final Uint8List? receivedUint8List =
//           await api!.echoAsyncNullableUint8List(null);
//       expect(receivedUint8List, null);
//     });

//     testWidgets(
//         'null generic Objects async serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();
//       final Object? receivedString = await api!.echoAsyncNullableObject(null);
//       expect(receivedString, null);
//     });

//     testWidgets('null lists serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final List<Object?>? echoObject = await api!.echoAsyncNullableList(null);
//       expect(listEquals(echoObject, null), true);
//     });

//     testWidgets('null maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final Map<Object?, Object?>? echoObject =
//           await api!.echoAsyncNullableMap(null);
//       expect(mapEquals(echoObject, null), true);
//     });

//     testWidgets('null string maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final Map<String?, String?>? echoObject =
//           await api!.echoAsyncNullableStringMap(null);
//       expect(mapEquals(echoObject, null), true);
//     });

//     testWidgets('null int maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       final Map<int?, int?>? echoObject =
//           await api!.echoAsyncNullableIntMap(null);
//       expect(mapEquals(echoObject, null), true);
//     });

//     testWidgets('null enums serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const JniAnEnum? sentEnum = null;
//       final JniAnEnum? echoEnum = await api!.echoAsyncNullableEnum(null);
//       expect(echoEnum, sentEnum);
//     });

//     testWidgets('null enums serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniHostIntegrationCoreApiForNativeInterop? api =
//           JniHostIntegrationCoreApiForNativeInterop.getInstance();

//       const JniAnotherEnum? sentEnum = null;
//       final JniAnotherEnum? echoEnum =
//           await api!.echoAnotherAsyncNullableEnum(null);
//       expect(echoEnum, sentEnum);
//     });
//   });

//   group('Host API with suffix', () {
//     testWidgets('echo string succeeds with suffix with multiple instances',
//         (_) async {
//       final JniHostSmallApiForNativeInterop? apiWithSuffixOne =
//           JniHostSmallApiForNativeInterop.getInstance(channelName: 'suffixOne');
//       final JniHostSmallApiForNativeInterop? apiWithSuffixTwo =
//           JniHostSmallApiForNativeInterop.getInstance(channelName: 'suffixTwo');
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
//         final JniHostSmallApiForNativeInterop? apiWithSuffixOne =
//             JniHostSmallApiForNativeInterop.getInstance(
//                 channelName: 'suffixWithNoHost');
//         await apiWithSuffixOne!.echo(sentString);
//       } on ArgumentError catch (e) {
//         expect(e.message, contains('suffixWithNoHost'));
//       }
//       try {
//         final JniHostSmallApiForNativeInterop? apiWithSuffixTwo =
//             JniHostSmallApiForNativeInterop.getInstance(
//                 channelName: 'suffixWithoutHost');
//         await apiWithSuffixTwo!.echo(sentString);
//       } on ArgumentError catch (e) {
//         expect(e.message, contains('suffixWithoutHost'));
//       }
//     });
//   });

//   group('Flutter Api "ForNativeInterop"', () {
//     final JniFlutterIntegrationCoreApiRegistrar registrar =
//         JniFlutterIntegrationCoreApiRegistrar();

//     final JniFlutterIntegrationCoreApi flutterApi =
//         registrar.register(_JniFlutterIntegrationCoreApiImpl());
//     final JniHostIntegrationCoreApiForNativeInterop? api =
//         JniHostIntegrationCoreApiForNativeInterop.getInstance();
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
//       final JniAllTypes echoObject =
//           api.callFlutterEchoJniAllTypes(genericJniAllTypes);

//       expect(echoObject, genericJniAllTypes);
//     });

//     testWidgets(
//         'Arguments of multiple types serialize and deserialize correctly',
//         (WidgetTester _) async {
//       const String aNullableString = 'this is a String';
//       const bool aNullableBool = false;
//       const int aNullableInt = regularInt;

//       final JniAllNullableTypes compositeObject =
//           api.callFlutterSendMultipleNullableTypes(
//               aNullableBool, aNullableInt, aNullableString);
//       expect(compositeObject.aNullableInt, aNullableInt);
//       expect(compositeObject.aNullableBool, aNullableBool);
//       expect(compositeObject.aNullableString, aNullableString);
//     });

//     testWidgets(
//         'Arguments of multiple null types serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniAllNullableTypes compositeObject =
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

//       final JniAllNullableTypesWithoutRecursion compositeObject =
//           api.callFlutterSendMultipleNullableTypesWithoutRecursion(
//               aNullableBool, aNullableInt, aNullableString);
//       expect(compositeObject.aNullableInt, aNullableInt);
//       expect(compositeObject.aNullableBool, aNullableBool);
//       expect(compositeObject.aNullableString, aNullableString);
//     });

//     testWidgets(
//         'Arguments of multiple null types serialize and deserialize correctly (WithoutRecursion)',
//         (WidgetTester _) async {
//       final JniAllNullableTypesWithoutRecursion compositeObject =
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
//       final List<JniAnEnum?> echoObject = api.callFlutterEchoEnumList(enumList);
//       expect(listEquals(echoObject, enumList), true);
//     });

//     testWidgets('class lists serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final List<JniAllNullableTypes?> echoObject =
//           api.callFlutterEchoClassList(allNullableTypesList);
//       for (final (int index, JniAllNullableTypes? value)
//           in echoObject.indexed) {
//         expect(value, allNullableTypesList[index]);
//       }
//     });

//     testWidgets('NonNull enum lists serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final List<JniAnEnum> echoObject =
//           api.callFlutterEchoNonNullEnumList(nonNullEnumList);
//       expect(listEquals(echoObject, nonNullEnumList), true);
//     });

//     testWidgets('NonNull class lists serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final List<JniAllNullableTypes> echoObject =
//           api.callFlutterEchoNonNullClassList(nonNullJniAllNullableTypesList);
//       for (final (int index, JniAllNullableTypes? value)
//           in echoObject.indexed) {
//         expect(value, nonNullJniAllNullableTypesList[index]);
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
//       final Map<JniAnEnum?, JniAnEnum?> echoObject =
//           api.callFlutterEchoEnumMap(enumMap);
//       expect(mapEquals(echoObject, enumMap), true);
//     });

//     testWidgets('class maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final Map<int?, JniAllNullableTypes?> echoObject =
//           api.callFlutterEchoClassMap(allNullableTypesMap);
//       for (final MapEntry<int?, JniAllNullableTypes?> entry
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
//       final Map<JniAnEnum, JniAnEnum> echoObject =
//           api.callFlutterEchoNonNullEnumMap(nonNullEnumMap);
//       expect(mapEquals(echoObject, nonNullEnumMap), true);
//     });

//     testWidgets('NonNull class maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final Map<int, JniAllNullableTypes> echoObject =
//           api.callFlutterEchoNonNullClassMap(nonNullJniAllNullableTypesMap);
//       for (final MapEntry<int, JniAllNullableTypes> entry
//           in echoObject.entries) {
//         expect(entry.value, nonNullJniAllNullableTypesMap[entry.key]);
//       }
//     });

//     testWidgets('enums serialize and deserialize correctly',
//         (WidgetTester _) async {
//       const JniAnEnum sentEnum = JniAnEnum.three;
//       final JniAnEnum echoEnum = api.callFlutterEchoEnum(sentEnum);
//       expect(echoEnum, sentEnum);
//     });

//     testWidgets('enums serialize and deserialize correctly (again)',
//         (WidgetTester _) async {
//       const JniAnotherEnum sentEnum = JniAnotherEnum.justInCase;
//       final JniAnotherEnum echoEnum =
//           api.callFlutterEchoJniAnotherEnum(sentEnum);
//       expect(echoEnum, sentEnum);
//     });

//     testWidgets('multi word enums serialize and deserialize correctly',
//         (WidgetTester _) async {
//       const JniAnEnum sentEnum = JniAnEnum.fortyTwo;
//       final JniAnEnum echoEnum = api.callFlutterEchoEnum(sentEnum);
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
//       final List<JniAnEnum?>? echoObject =
//           api.callFlutterEchoNullableEnumList(enumList);
//       expect(listEquals(echoObject, enumList), true);
//     });

//     testWidgets('nullable class lists serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final List<JniAllNullableTypes?>? echoObject =
//           api.callFlutterEchoNullableClassList(allNullableTypesList);
//       for (final (int index, JniAllNullableTypes? value)
//           in echoObject!.indexed) {
//         expect(value, allNullableTypesList[index]);
//       }
//     });

//     testWidgets(
//         'nullable NonNull enum lists serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final List<JniAnEnum?>? echoObject =
//           api.callFlutterEchoNullableNonNullEnumList(nonNullEnumList);
//       expect(listEquals(echoObject, nonNullEnumList), true);
//     });

//     testWidgets(
//         'nullable NonNull class lists serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final List<JniAllNullableTypes?>? echoObject =
//           api.callFlutterEchoNullableNonNullClassList(
//               nonNullJniAllNullableTypesList);
//       for (final (int index, JniAllNullableTypes? value)
//           in echoObject!.indexed) {
//         expect(value, nonNullJniAllNullableTypesList[index]);
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
//       final Map<JniAnEnum?, JniAnEnum?>? echoObject =
//           api.callFlutterEchoNullableEnumMap(enumMap);
//       expect(mapEquals(echoObject, enumMap), true);
//     });

//     testWidgets('nullable class maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final Map<int?, JniAllNullableTypes?>? echoObject =
//           api.callFlutterEchoNullableClassMap(allNullableTypesMap);
//       for (final MapEntry<int?, JniAllNullableTypes?> entry
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
//       final Map<JniAnEnum?, JniAnEnum?>? echoObject =
//           api.callFlutterEchoNullableNonNullEnumMap(nonNullEnumMap);
//       expect(mapEquals(echoObject, nonNullEnumMap), true);
//     });

//     testWidgets(
//         'nullable NonNull class maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final Map<int?, JniAllNullableTypes?>? echoObject =
//           api.callFlutterEchoNullableNonNullClassMap(
//               nonNullJniAllNullableTypesMap);
//       for (final MapEntry<int?, JniAllNullableTypes?> entry
//           in echoObject!.entries) {
//         expect(entry.value, nonNullJniAllNullableTypesMap[entry.key]);
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
//       const JniAnEnum sentEnum = JniAnEnum.three;
//       final JniAnEnum? echoEnum = api.callFlutterEchoNullableEnum(sentEnum);
//       expect(echoEnum, sentEnum);
//     });

//     testWidgets('nullable enums serialize and deserialize correctly (again)',
//         (WidgetTester _) async {
//       const JniAnotherEnum sentEnum = JniAnotherEnum.justInCase;
//       final JniAnotherEnum? echoEnum =
//           api.callFlutterEchoAnotherNullableEnum(sentEnum);
//       expect(echoEnum, sentEnum);
//     });

//     testWidgets('multi word nullable enums serialize and deserialize correctly',
//         (WidgetTester _) async {
//       const JniAnEnum sentEnum = JniAnEnum.fourHundredTwentyTwo;
//       final JniAnEnum? echoEnum = api.callFlutterEchoNullableEnum(sentEnum);
//       expect(echoEnum, sentEnum);
//     });

//     testWidgets('null enums serialize and deserialize correctly',
//         (WidgetTester _) async {
//       const JniAnEnum? sentEnum = null;
//       final JniAnEnum? echoEnum = api.callFlutterEchoNullableEnum(sentEnum);
//       expect(echoEnum, sentEnum);
//     });

//     testWidgets('null enums serialize and deserialize correctly (again)',
//         (WidgetTester _) async {
//       const JniAnotherEnum? sentEnum = null;
//       final JniAnotherEnum? echoEnum =
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
//     JniFlutterIntegrationCoreApi.setUp(_JniFlutterIntegrationCoreApiImpl());
//     final JniHostIntegrationCoreApi api =
//         JniHostIntegrationCoreApi.createWithJniApi();

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
//       final JniAllTypes echoObject =
//           await api.callFlutterEchoJniAllTypes(genericJniAllTypes);

//       expect(echoObject, genericJniAllTypes);
//     });

//     testWidgets(
//         'Arguments of multiple types serialize and deserialize correctly',
//         (WidgetTester _) async {
//       const String aNullableString = 'this is a String';
//       const bool aNullableBool = false;
//       const int aNullableInt = regularInt;

//       final JniAllNullableTypes compositeObject =
//           await api.callFlutterSendMultipleNullableTypes(
//               aNullableBool, aNullableInt, aNullableString);
//       expect(compositeObject.aNullableInt, aNullableInt);
//       expect(compositeObject.aNullableBool, aNullableBool);
//       expect(compositeObject.aNullableString, aNullableString);
//     });

//     testWidgets(
//         'Arguments of multiple null types serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final JniAllNullableTypes compositeObject =
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

//       final JniAllNullableTypesWithoutRecursion compositeObject =
//           await api.callFlutterSendMultipleNullableTypesWithoutRecursion(
//               aNullableBool, aNullableInt, aNullableString);
//       expect(compositeObject.aNullableInt, aNullableInt);
//       expect(compositeObject.aNullableBool, aNullableBool);
//       expect(compositeObject.aNullableString, aNullableString);
//     });

//     testWidgets(
//         'Arguments of multiple null types serialize and deserialize correctly (WithoutRecursion)',
//         (WidgetTester _) async {
//       final JniAllNullableTypesWithoutRecursion compositeObject =
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
//       final List<JniAnEnum?> echoObject =
//           await api.callFlutterEchoEnumList(enumList);
//       expect(listEquals(echoObject, enumList), true);
//     });

//     testWidgets('class lists serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final List<JniAllNullableTypes?> echoObject =
//           await api.callFlutterEchoClassList(allNullableTypesList);
//       for (final (int index, JniAllNullableTypes? value)
//           in echoObject.indexed) {
//         expect(value, allNullableTypesList[index]);
//       }
//     });

//     testWidgets('NonNull enum lists serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final List<JniAnEnum> echoObject =
//           await api.callFlutterEchoNonNullEnumList(nonNullEnumList);
//       expect(listEquals(echoObject, nonNullEnumList), true);
//     });

//     testWidgets('NonNull class lists serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final List<JniAllNullableTypes> echoObject = await api
//           .callFlutterEchoNonNullClassList(nonNullJniAllNullableTypesList);
//       for (final (int index, JniAllNullableTypes? value)
//           in echoObject.indexed) {
//         expect(value, nonNullJniAllNullableTypesList[index]);
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
//       final Map<JniAnEnum?, JniAnEnum?> echoObject =
//           await api.callFlutterEchoEnumMap(enumMap);
//       expect(mapEquals(echoObject, enumMap), true);
//     });

//     testWidgets('class maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final Map<int?, JniAllNullableTypes?> echoObject =
//           await api.callFlutterEchoClassMap(allNullableTypesMap);
//       for (final MapEntry<int?, JniAllNullableTypes?> entry
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
//       final Map<JniAnEnum, JniAnEnum> echoObject =
//           await api.callFlutterEchoNonNullEnumMap(nonNullEnumMap);
//       expect(mapEquals(echoObject, nonNullEnumMap), true);
//     });

//     testWidgets('NonNull class maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final Map<int, JniAllNullableTypes> echoObject = await api
//           .callFlutterEchoNonNullClassMap(nonNullJniAllNullableTypesMap);
//       for (final MapEntry<int, JniAllNullableTypes> entry
//           in echoObject.entries) {
//         expect(entry.value, nonNullJniAllNullableTypesMap[entry.key]);
//       }
//     });

//     testWidgets('enums serialize and deserialize correctly',
//         (WidgetTester _) async {
//       const JniAnEnum sentEnum = JniAnEnum.three;
//       final JniAnEnum echoEnum = await api.callFlutterEchoEnum(sentEnum);
//       expect(echoEnum, sentEnum);
//     });

//     testWidgets('enums serialize and deserialize correctly (again)',
//         (WidgetTester _) async {
//       const JniAnotherEnum sentEnum = JniAnotherEnum.justInCase;
//       final JniAnotherEnum echoEnum =
//           await api.callFlutterEchoJniAnotherEnum(sentEnum);
//       expect(echoEnum, sentEnum);
//     });

//     testWidgets('multi word enums serialize and deserialize correctly',
//         (WidgetTester _) async {
//       const JniAnEnum sentEnum = JniAnEnum.fortyTwo;
//       final JniAnEnum echoEnum = await api.callFlutterEchoEnum(sentEnum);
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
//       final List<JniAnEnum?>? echoObject =
//           await api.callFlutterEchoNullableEnumList(enumList);
//       expect(listEquals(echoObject, enumList), true);
//     });

//     testWidgets('nullable class lists serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final List<JniAllNullableTypes?>? echoObject =
//           await api.callFlutterEchoNullableClassList(allNullableTypesList);
//       for (final (int index, JniAllNullableTypes? value)
//           in echoObject!.indexed) {
//         expect(value, allNullableTypesList[index]);
//       }
//     });

//     testWidgets(
//         'nullable NonNull enum lists serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final List<JniAnEnum?>? echoObject =
//           await api.callFlutterEchoNullableNonNullEnumList(nonNullEnumList);
//       expect(listEquals(echoObject, nonNullEnumList), true);
//     });

//     testWidgets(
//         'nullable NonNull class lists serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final List<JniAllNullableTypes?>? echoObject =
//           await api.callFlutterEchoNullableNonNullClassList(
//               nonNullJniAllNullableTypesList);
//       for (final (int index, JniAllNullableTypes? value)
//           in echoObject!.indexed) {
//         expect(value, nonNullJniAllNullableTypesList[index]);
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
//       final Map<JniAnEnum?, JniAnEnum?>? echoObject =
//           await api.callFlutterEchoNullableEnumMap(enumMap);
//       expect(mapEquals(echoObject, enumMap), true);
//     });

//     testWidgets('nullable class maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final Map<int?, JniAllNullableTypes?>? echoObject =
//           await api.callFlutterEchoNullableClassMap(allNullableTypesMap);
//       for (final MapEntry<int?, JniAllNullableTypes?> entry
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
//       final Map<JniAnEnum?, JniAnEnum?>? echoObject =
//           await api.callFlutterEchoNullableNonNullEnumMap(nonNullEnumMap);
//       expect(mapEquals(echoObject, nonNullEnumMap), true);
//     });

//     testWidgets(
//         'nullable NonNull class maps serialize and deserialize correctly',
//         (WidgetTester _) async {
//       final Map<int?, JniAllNullableTypes?>? echoObject =
//           await api.callFlutterEchoNullableNonNullClassMap(
//               nonNullJniAllNullableTypesMap);
//       for (final MapEntry<int?, JniAllNullableTypes?> entry
//           in echoObject!.entries) {
//         expect(entry.value, nonNullJniAllNullableTypesMap[entry.key]);
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
//       const JniAnEnum sentEnum = JniAnEnum.three;
//       final JniAnEnum? echoEnum =
//           await api.callFlutterEchoNullableEnum(sentEnum);
//       expect(echoEnum, sentEnum);
//     });

//     testWidgets('nullable enums serialize and deserialize correctly (again)',
//         (WidgetTester _) async {
//       const JniAnotherEnum sentEnum = JniAnotherEnum.justInCase;
//       final JniAnotherEnum? echoEnum =
//           await api.callFlutterEchoAnotherNullableEnum(sentEnum);
//       expect(echoEnum, sentEnum);
//     });

//     testWidgets('multi word nullable enums serialize and deserialize correctly',
//         (WidgetTester _) async {
//       const JniAnEnum sentEnum = JniAnEnum.fourHundredTwentyTwo;
//       final JniAnEnum? echoEnum =
//           await api.callFlutterEchoNullableEnum(sentEnum);
//       expect(echoEnum, sentEnum);
//     });

//     testWidgets('null enums serialize and deserialize correctly',
//         (WidgetTester _) async {
//       const JniAnEnum? sentEnum = null;
//       final JniAnEnum? echoEnum =
//           await api.callFlutterEchoNullableEnum(sentEnum);
//       expect(echoEnum, sentEnum);
//     });

//     testWidgets('null enums serialize and deserialize correctly (again)',
//         (WidgetTester _) async {
//       const JniAnotherEnum? sentEnum = null;
//       final JniAnotherEnum? echoEnum =
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

// class _JniFlutterIntegrationCoreApiImpl extends JniFlutterIntegrationCoreApi {
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
//   JniAnotherEnum? echoAnotherNullableEnum(JniAnotherEnum? anotherEnum) {
//     return anotherEnum;
//   }

//   // @override
//   // Future<String> echoAsyncString(String aString) async {
//   //   return aString;
//   // }

//   @override
//   List<JniAllNullableTypes?> echoClassList(
//       List<JniAllNullableTypes?> classList) {
//     return classList;
//   }

//   @override
//   Map<int?, JniAllNullableTypes?> echoClassMap(
//       Map<int?, JniAllNullableTypes?> classMap) {
//     return classMap;
//   }

//   @override
//   double echoDouble(double aDouble) {
//     return aDouble;
//   }

//   @override
//   JniAnEnum echoEnum(JniAnEnum anEnum) {
//     return anEnum;
//   }

//   @override
//   List<JniAnEnum?> echoEnumList(List<JniAnEnum?> enumList) {
//     return enumList;
//   }

//   @override
//   Map<JniAnEnum?, JniAnEnum?> echoEnumMap(Map<JniAnEnum?, JniAnEnum?> enumMap) {
//     return enumMap;
//   }

//   @override
//   Map<int?, int?> echoIntMap(Map<int?, int?> intMap) {
//     return intMap;
//   }

//   @override
//   JniAllNullableTypes? echoJniAllNullableTypes(
//       JniAllNullableTypes? everything) {
//     return everything;
//   }

//   @override
//   JniAllNullableTypesWithoutRecursion? echoJniAllNullableTypesWithoutRecursion(
//       JniAllNullableTypesWithoutRecursion? everything) {
//     return everything;
//   }

//   @override
//   JniAllTypes echoJniAllTypes(JniAllTypes everything) {
//     return everything;
//   }

//   @override
//   JniAnotherEnum echoJniAnotherEnum(JniAnotherEnum anotherEnum) {
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
//   List<JniAllNullableTypes> echoNonNullClassList(
//       List<JniAllNullableTypes> classList) {
//     return classList;
//   }

//   @override
//   Map<int, JniAllNullableTypes> echoNonNullClassMap(
//       Map<int, JniAllNullableTypes> classMap) {
//     return classMap;
//   }

//   @override
//   List<JniAnEnum> echoNonNullEnumList(List<JniAnEnum> enumList) {
//     return enumList;
//   }

//   @override
//   Map<JniAnEnum, JniAnEnum> echoNonNullEnumMap(
//       Map<JniAnEnum, JniAnEnum> enumMap) {
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
//   List<JniAllNullableTypes?>? echoNullableClassList(
//       List<JniAllNullableTypes?>? classList) {
//     return classList;
//   }

//   @override
//   Map<int?, JniAllNullableTypes?>? echoNullableClassMap(
//       Map<int?, JniAllNullableTypes?>? classMap) {
//     return classMap;
//   }

//   @override
//   double? echoNullableDouble(double? aDouble) {
//     return aDouble;
//   }

//   @override
//   JniAnEnum? echoNullableEnum(JniAnEnum? anEnum) {
//     return anEnum;
//   }

//   @override
//   List<JniAnEnum?>? echoNullableEnumList(List<JniAnEnum?>? enumList) {
//     return enumList;
//   }

//   @override
//   Map<JniAnEnum?, JniAnEnum?>? echoNullableEnumMap(
//       Map<JniAnEnum?, JniAnEnum?>? enumMap) {
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
//   List<JniAllNullableTypes>? echoNullableNonNullClassList(
//       List<JniAllNullableTypes>? classList) {
//     return classList;
//   }

//   @override
//   Map<int, JniAllNullableTypes>? echoNullableNonNullClassMap(
//       Map<int, JniAllNullableTypes>? classMap) {
//     return classMap;
//   }

//   @override
//   List<JniAnEnum>? echoNullableNonNullEnumList(List<JniAnEnum>? enumList) {
//     return enumList;
//   }

//   @override
//   Map<JniAnEnum, JniAnEnum>? echoNullableNonNullEnumMap(
//       Map<JniAnEnum, JniAnEnum>? enumMap) {
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
//   JniAllNullableTypes sendMultipleNullableTypes(
//       bool? aNullableBool, int? aNullableInt, String? aNullableString) {
//     return JniAllNullableTypes(
//       aNullableBool: aNullableBool,
//       aNullableInt: aNullableInt,
//       aNullableString: aNullableString,
//     );
//   }

//   @override
//   JniAllNullableTypesWithoutRecursion sendMultipleNullableTypesWithoutRecursion(
//       bool? aNullableBool, int? aNullableInt, String? aNullableString) {
//     return JniAllNullableTypesWithoutRecursion(
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
// }
  });
}
