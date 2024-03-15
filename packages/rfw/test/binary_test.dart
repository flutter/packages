// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is hand-formatted.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:rfw/formats.dart';

// This is a number that requires more than 32 bits but less than 53 bits, so
// that it works in a JS Number and tests the logic that parses 64 bit ints as
// two separate 32 bit ints.
const int largeNumber = 9007199254730661;

void main() {
  testWidgets('String example', (WidgetTester tester) async {
    final Uint8List bytes = encodeDataBlob('Hello');
    expect(bytes, <int>[ 0xFE, 0x52, 0x57, 0x44, 0x04, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x48, 0x65, 0x6C, 0x6C, 0x6F ]);
    final Object value = decodeDataBlob(bytes);
    expect(value, isA<String>());
    expect(value, 'Hello');
  });

  testWidgets('Big integer example', (WidgetTester tester) async {
    // This value is intentionally inside the JS Number range but above 2^32.
    final Uint8List bytes = encodeDataBlob(largeNumber);
    expect(bytes, <int>[ 0xfe, 0x52, 0x57, 0x44, 0x02, 0xa5, 0xd7, 0xff, 0xff, 0xff, 0xff, 0x1f, 0x00, ]);
    final Object value = decodeDataBlob(bytes);
    expect(value, isA<int>());
    expect(value, largeNumber);
  });

  testWidgets('Big negative integer example', (WidgetTester tester) async {
    final Uint8List bytes = encodeDataBlob(-largeNumber);
    expect(bytes, <int>[ 0xfe, 0x52, 0x57, 0x44, 0x02, 0x5b, 0x28, 0x00, 0x00, 0x00, 0x00, 0xe0, 0xff, ]);
    final Object value = decodeDataBlob(bytes);
    expect(value, isA<int>());
    expect(value, -largeNumber);
  });

  testWidgets('Small integer example', (WidgetTester tester) async {
    final Uint8List bytes = encodeDataBlob(1);
    expect(bytes, <int>[ 0xfe, 0x52, 0x57, 0x44, 0x02, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, ]);
    final Object value = decodeDataBlob(bytes);
    expect(value, isA<int>());
    expect(value, 1);
  });

  testWidgets('Small negative integer example', (WidgetTester tester) async {
    final Uint8List bytes = encodeDataBlob(-1);
    expect(bytes, <int>[ 0xfe, 0x52, 0x57, 0x44, 0x02, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, ]);
    final Object value = decodeDataBlob(bytes);
    expect(value, isA<int>());
    expect(value, -1);
  });

  testWidgets('Zero integer example', (WidgetTester tester) async {
    // This value is intentionally inside the JS Number range but above 2^32.
    final Uint8List bytes = encodeDataBlob(0);
    expect(bytes, <int>[ 0xfe, 0x52, 0x57, 0x44, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, ]);
    final Object value = decodeDataBlob(bytes);
    expect(value, isA<int>());
    expect(value, 0);
  });

  testWidgets('Map example', (WidgetTester tester) async {
    final Uint8List bytes = encodeDataBlob(const <String, Object?>{ 'a': 15 });
    expect(bytes, <int>[
      0xFE, 0x52, 0x57, 0x44, 0x07, 0x01, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x61, 0x02, 0x0F,  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    ]);
    final Object value = decodeDataBlob(bytes);
    expect(value, isA<DynamicMap>());
    expect(value, const <String, Object?>{ 'a': 15 });
  });

  testWidgets('Signature check in decoders', (WidgetTester tester) async {
    try {
      decodeDataBlob(Uint8List.fromList(<int>[ 0xFE, 0x52, 0x46, 0x57, 0x04, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x48, 0x65, 0x6C, 0x6C, 0x6F ]));
      fail('did not throw exception');
    } on FormatException catch (e) {
      expect('$e', contains('File signature mismatch. Expected FE 52 57 44 but found FE 52 46 57.'));
    }
    try {
      decodeLibraryBlob(Uint8List.fromList(<int>[ 0xFE, 0x52, 0x57, 0x44, 0x04, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x48, 0x65, 0x6C, 0x6C, 0x6F ]));
      fail('did not throw exception');
    } on FormatException catch (e) {
      expect('$e', contains('File signature mismatch. Expected FE 52 46 57 but found FE 52 57 44.'));
    }
  });

  testWidgets('Trailing byte check', (WidgetTester tester) async {
    try {
      decodeDataBlob(Uint8List.fromList(<int>[ 0xFE, 0x52, 0x57, 0x44, 0x00, 0x00 ]));
      fail('did not throw exception');
    } on FormatException catch (e) {
      expect('$e', contains('Unexpected trailing bytes after value.'));
    }
    try {
      decodeLibraryBlob(Uint8List.fromList(<int>[ 0xFE, 0x52, 0x46, 0x57, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ]));
      fail('did not throw exception');
    } on FormatException catch (e) {
      expect('$e', contains('Unexpected trailing bytes after constructors.'));
    }
  });

  testWidgets('Incomplete files in signatures', (WidgetTester tester) async {
    try {
      decodeDataBlob(Uint8List.fromList(<int>[ 0xFE, 0x52, 0x57 ]));
      fail('did not throw exception');
    } on FormatException catch (e) {
      expect('$e', contains('Could not read byte at offset 3: unexpected end of file.'));
    }
    try {
      decodeLibraryBlob(Uint8List.fromList(<int>[ 0xFE, 0x52, 0x46 ]));
      fail('did not throw exception');
    } on FormatException catch (e) {
      expect('$e', contains('Could not read byte at offset 3: unexpected end of file.'));
    }
  });

  testWidgets('Incomplete files after signatures', (WidgetTester tester) async {
    try {
      decodeDataBlob(Uint8List.fromList(<int>[ 0xFE, 0x52, 0x57, 0x44 ]));
      fail('did not throw exception');
    } on FormatException catch (e) {
      expect('$e', contains('Could not read byte at offset 4: unexpected end of file.'));
    }
    try {
      decodeLibraryBlob(Uint8List.fromList(<int>[ 0xFE, 0x52, 0x46, 0x57 ]));
      fail('did not throw exception');
    } on FormatException catch (e) {
      expect('$e', contains('Could not read int64 at offset 4: unexpected end of file.'));
    }
  });

  testWidgets('Invalid value tag', (WidgetTester tester) async {
    try {
      decodeDataBlob(Uint8List.fromList(<int>[ 0xFE, 0x52, 0x57, 0x44, 0xCC ]));
      fail('did not throw exception');
    } on FormatException catch (e) {
      expect('$e', contains('Unrecognized data type 0xCC while decoding blob.'));
    }
  });

  testWidgets('Library encoder smoke test', (WidgetTester tester) async {
    final Uint8List bytes = encodeLibraryBlob(const RemoteWidgetLibrary(<Import>[], <WidgetDeclaration>[]));
    expect(bytes, <int>[ 0xFE, 0x52, 0x46, 0x57, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ]);
    final RemoteWidgetLibrary value = decodeLibraryBlob(bytes);
    expect(value.imports, isEmpty);
    expect(value.widgets, isEmpty);
  });

  testWidgets('Library encoder: imports', (WidgetTester tester) async {
    final Uint8List bytes = encodeLibraryBlob(const RemoteWidgetLibrary(<Import>[Import(LibraryName(<String>['a']))], <WidgetDeclaration>[]));
    expect(bytes, <int>[
      0xFE, 0x52, 0x46, 0x57, 0x01, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x61, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00,
    ]);
    final RemoteWidgetLibrary value = decodeLibraryBlob(bytes);
    expect(value.imports, hasLength(1));
    expect(value.imports.single.name, const LibraryName(<String>['a']));
    expect(value.widgets, isEmpty);
  });

  testWidgets('Doubles', (WidgetTester tester) async {
    final Uint8List bytes = encodeDataBlob(0.25);
    expect(bytes, <int>[ 0xFE, 0x52, 0x57, 0x44, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xD0, 0x3F ]);
    final Object value = decodeDataBlob(bytes);
    expect(value, isA<double>());
    expect(value, 0.25);
  });

  testWidgets('Library decoder: invalid widget declaration root', (WidgetTester tester) async {
    final Uint8List bytes = Uint8List.fromList(<int>[
      0xfe, 0x52, 0x46, 0x57, 0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x61, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0xEF,
    ]);
    try {
      decodeLibraryBlob(bytes);
    } on FormatException catch (e) {
      expect('$e', contains('Unrecognized data type 0xEF while decoding widget declaration root.'));
    }
  });

  testWidgets('Library encoder: args references', (WidgetTester tester) async {
    final Uint8List bytes = encodeLibraryBlob(const RemoteWidgetLibrary(<Import>[], <WidgetDeclaration>[
      WidgetDeclaration('a', null, ConstructorCall('b', <String, Object?>{ 'c': <Object?>[ ArgsReference(<Object>['d', 5]) ] })),
    ]));
    expect(bytes, <int>[
      0xfe, 0x52, 0x46, 0x57, 0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x61, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0x01, 0x00,  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x62, 0x01,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x63,
      0x05, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  0x00, 0x0a, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x04, 0x01, 0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x64, 0x02, 0x05, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00,
    ]);
    final RemoteWidgetLibrary value = decodeLibraryBlob(bytes);
    expect(value.imports, isEmpty);
    expect(value.widgets, hasLength(1));
    expect(value.widgets.first.name, 'a');
    expect(value.widgets.first.initialState, isNull);
    expect(value.widgets.first.root, isA<ConstructorCall>());
    expect((value.widgets.first.root as ConstructorCall).name, 'b');
    expect((value.widgets.first.root as ConstructorCall).arguments, hasLength(1));
    expect((value.widgets.first.root as ConstructorCall).arguments.keys, <Object?>['c']);
    expect((value.widgets.first.root as ConstructorCall).arguments['c'], hasLength(1));
    expect(((value.widgets.first.root as ConstructorCall).arguments['c']! as DynamicList)[0], isA<ArgsReference>());
    expect((((value.widgets.first.root as ConstructorCall).arguments['c']! as DynamicList)[0]! as ArgsReference).parts, hasLength(2));
    expect((((value.widgets.first.root as ConstructorCall).arguments['c']! as DynamicList)[0]! as ArgsReference).parts[0], 'd');
    expect((((value.widgets.first.root as ConstructorCall).arguments['c']! as DynamicList)[0]! as ArgsReference).parts[1], 5);
  });

  testWidgets('Library encoder: invalid args references', (WidgetTester tester) async {
    try {
      encodeLibraryBlob(const RemoteWidgetLibrary(<Import>[], <WidgetDeclaration>[
        WidgetDeclaration('a', null, ConstructorCall('b', <String, Object?>{ 'c': <Object?>[ ArgsReference(<Object>[false]) ] })),
      ]));
    } on StateError catch (e) {
      expect('$e', contains('Unexpected type bool while encoding blob.'));
    }
  });

  testWidgets('Library decoder: invalid args references', (WidgetTester tester) async {
    final Uint8List bytes = Uint8List.fromList(<int>[
      0xfe, 0x52, 0x46, 0x57, 0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x61, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0x01, 0x00,  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x62, 0x01,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x63,
      0x05, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  0x00, 0x0a, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0xAC,
    ]);
    try {
      decodeLibraryBlob(bytes);
    } on FormatException catch (e) {
      expect('$e', contains('Invalid reference type 0xAC while decoding blob.'));
    }
  });

  testWidgets('Library encoder: switches', (WidgetTester tester) async {
    final Uint8List bytes = encodeLibraryBlob(const RemoteWidgetLibrary(<Import>[], <WidgetDeclaration>[
      WidgetDeclaration('a', null, Switch('b', <Object?, Object>{ null: 'c' })),
    ]));
    expect(bytes, <int>[
      0xfe, 0x52, 0x46, 0x57, 0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x61, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x0f, 0x04, 0x01,  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x62,
      0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  0x10, 0x04, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x63,
    ]);
    final RemoteWidgetLibrary value = decodeLibraryBlob(bytes);
    expect(value.imports, isEmpty);
    expect(value.widgets, hasLength(1));
    expect(value.widgets.first.name, 'a');
    expect(value.widgets.first.initialState, isNull);
    expect(value.widgets.first.root, isA<Switch>());
    expect((value.widgets.first.root as Switch).input, 'b');
    expect((value.widgets.first.root as Switch).outputs, hasLength(1));
    expect((value.widgets.first.root as Switch).outputs.keys, <Object?>[null]);
    expect((value.widgets.first.root as Switch).outputs[null], 'c');
  });

  testWidgets('Library encoder: switches', (WidgetTester tester) async {
    final Uint8List bytes = encodeLibraryBlob(const RemoteWidgetLibrary(<Import>[], <WidgetDeclaration>[
      WidgetDeclaration('a', null, Switch('b', <Object?, Object>{ 'c': 'd' })),
    ]));
    expect(bytes, <int>[
      0xfe, 0x52, 0x46, 0x57, 0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x61, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x0f, 0x04, 0x01,  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x62,
      0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  0x04, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x63, 0x04, 0x01, 0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x64,
    ]);
    final RemoteWidgetLibrary value = decodeLibraryBlob(bytes);
    expect(value.imports, isEmpty);
    expect(value.widgets, hasLength(1));
    expect(value.widgets.first.name, 'a');
    expect(value.widgets.first.initialState, isNull);
    expect(value.widgets.first.root, isA<Switch>());
    expect((value.widgets.first.root as Switch).input, 'b');
    expect((value.widgets.first.root as Switch).outputs, hasLength(1));
    expect((value.widgets.first.root as Switch).outputs.keys, <Object?>['c']);
    expect((value.widgets.first.root as Switch).outputs['c'], 'd');
  });

  testWidgets('Bools', (WidgetTester tester) async {
    final Uint8List bytes = encodeDataBlob(const <Object?>[ false, true ]);
    expect(bytes, <int>[
      0xFE, 0x52, 0x57, 0x44, 0x05, 0x02, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,
    ]);
    final Object value = decodeDataBlob(bytes);
    expect(value, isA<DynamicList>());
    expect(value, const <Object?>{ false, true });
  });

  testWidgets('Library encoder: loops', (WidgetTester tester) async {
    final Uint8List bytes = encodeLibraryBlob(const RemoteWidgetLibrary(<Import>[], <WidgetDeclaration>[
      WidgetDeclaration('a', null, ConstructorCall('b', <String, Object?>{ 'c': <Object?>[
        Loop(<Object?>[], ConstructorCall('d', <String, Object?>{ 'e': LoopReference(0, <Object>[]) })),
      ] })),
    ]));
    expect(bytes, <int>[
      0xfe, 0x52, 0x46, 0x57, 0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x61, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0x01, 0x00,  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x62, 0x01,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x63,
      0x05, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  0x00, 0x08, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x09, 0x01, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x64, 0x01, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x00, 0x65, 0x0c, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ]);
    final RemoteWidgetLibrary value = decodeLibraryBlob(bytes);
    expect(value.imports, isEmpty);
    expect(value.widgets, hasLength(1));
    expect(value.widgets.first.name, 'a');
    expect(value.widgets.first.initialState, isNull);
    expect(value.widgets.first.root, isA<ConstructorCall>());
    expect((value.widgets.first.root as ConstructorCall).name, 'b');
    expect((value.widgets.first.root as ConstructorCall).arguments, hasLength(1));
    expect((value.widgets.first.root as ConstructorCall).arguments.keys, <Object?>['c']);
    expect((value.widgets.first.root as ConstructorCall).arguments['c'], hasLength(1));
    expect(((value.widgets.first.root as ConstructorCall).arguments['c']! as DynamicList)[0], isA<Loop>());
    expect((((value.widgets.first.root as ConstructorCall).arguments['c']! as DynamicList)[0]! as Loop).input, isEmpty);
    expect((((value.widgets.first.root as ConstructorCall).arguments['c']! as DynamicList)[0]! as Loop).output, isA<ConstructorCall>());
    expect(((((value.widgets.first.root as ConstructorCall).arguments['c']! as DynamicList)[0]! as Loop).output as ConstructorCall).name, 'd');
    expect(((((value.widgets.first.root as ConstructorCall).arguments['c']! as DynamicList)[0]! as Loop).output as ConstructorCall).arguments, hasLength(1));
    expect(((((value.widgets.first.root as ConstructorCall).arguments['c']! as DynamicList)[0]! as Loop).output as ConstructorCall).arguments['e'], isA<LoopReference>());
    expect((((((value.widgets.first.root as ConstructorCall).arguments['c']! as DynamicList)[0]! as Loop).output as ConstructorCall).arguments['e']! as LoopReference).loop, 0);
    expect((((((value.widgets.first.root as ConstructorCall).arguments['c']! as DynamicList)[0]! as Loop).output as ConstructorCall).arguments['e']! as LoopReference).parts, isEmpty);
  });

  testWidgets('Library encoder: data references', (WidgetTester tester) async {
    final Uint8List bytes = encodeLibraryBlob(const RemoteWidgetLibrary(<Import>[], <WidgetDeclaration>[
      WidgetDeclaration('a', null, ConstructorCall('b', <String, Object?>{ 'c': DataReference(<Object>['d']) })),
    ]));
    expect(bytes, <int>[
      0xfe, 0x52, 0x46, 0x57, 0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x61, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0x01, 0x00,  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x62, 0x01,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x63,
      0x0B, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  0x00, 0x04, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x64,
    ]);
    final RemoteWidgetLibrary value = decodeLibraryBlob(bytes);
    expect(value.imports, isEmpty);
    expect(value.widgets, hasLength(1));
    expect(value.widgets.first.name, 'a');
    expect(value.widgets.first.initialState, isNull);
    expect(value.widgets.first.root, isA<ConstructorCall>());
    expect((value.widgets.first.root as ConstructorCall).name, 'b');
    expect((value.widgets.first.root as ConstructorCall).arguments, hasLength(1));
    expect((value.widgets.first.root as ConstructorCall).arguments.keys, <Object?>['c']);
    expect((value.widgets.first.root as ConstructorCall).arguments['c'], isA<DataReference>());
    expect(((value.widgets.first.root as ConstructorCall).arguments['c']! as DataReference).parts, const <Object>[ 'd' ]);
  });

  testWidgets('Library encoder: state references', (WidgetTester tester) async {
    final Uint8List bytes = encodeLibraryBlob(const RemoteWidgetLibrary(<Import>[], <WidgetDeclaration>[
      WidgetDeclaration('a', null, ConstructorCall('b', <String, Object?>{ 'c': StateReference(<Object>['d']) })),
    ]));
    expect(bytes, <int>[
      0xfe, 0x52, 0x46, 0x57, 0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x61, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0x01, 0x00,  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x62, 0x01,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x63,
      0x0D, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  0x00, 0x04, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x64,
    ]);
    final RemoteWidgetLibrary value = decodeLibraryBlob(bytes);
    expect(value.imports, isEmpty);
    expect(value.widgets, hasLength(1));
    expect(value.widgets.first.name, 'a');
    expect(value.widgets.first.initialState, isNull);
    expect(value.widgets.first.root, isA<ConstructorCall>());
    expect((value.widgets.first.root as ConstructorCall).name, 'b');
    expect((value.widgets.first.root as ConstructorCall).arguments, hasLength(1));
    expect((value.widgets.first.root as ConstructorCall).arguments.keys, <Object?>['c']);
    expect((value.widgets.first.root as ConstructorCall).arguments['c'], isA<StateReference>());
    expect(((value.widgets.first.root as ConstructorCall).arguments['c']! as StateReference).parts, const <Object>[ 'd' ]);
  });

  testWidgets('Library encoder: event handler', (WidgetTester tester) async {
    final Uint8List bytes = encodeLibraryBlob(const RemoteWidgetLibrary(<Import>[], <WidgetDeclaration>[
      WidgetDeclaration('a', null, ConstructorCall('b', <String, Object?>{ 'c': EventHandler('d', <String, Object?>{}) })),
    ]));
    expect(bytes, <int>[
      0xfe, 0x52, 0x46, 0x57, 0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x61, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0x01, 0x00,  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x62, 0x01,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x63,
      0x0E, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  0x00, 0x64, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00,
    ]);
    final RemoteWidgetLibrary value = decodeLibraryBlob(bytes);
    expect(value.imports, isEmpty);
    expect(value.widgets, hasLength(1));
    expect(value.widgets.first.name, 'a');
    expect(value.widgets.first.initialState, isNull);
    expect(value.widgets.first.root, isA<ConstructorCall>());
    expect((value.widgets.first.root as ConstructorCall).name, 'b');
    expect((value.widgets.first.root as ConstructorCall).arguments, hasLength(1));
    expect((value.widgets.first.root as ConstructorCall).arguments.keys, <Object?>['c']);
    expect((value.widgets.first.root as ConstructorCall).arguments['c'], isA<EventHandler>());
    expect(((value.widgets.first.root as ConstructorCall).arguments['c']! as EventHandler).eventName, 'd');
    expect(((value.widgets.first.root as ConstructorCall).arguments['c']! as EventHandler).eventArguments, isEmpty);
  });

  testWidgets('Library encoder: state setter', (WidgetTester tester) async {
    final Uint8List bytes = encodeLibraryBlob(const RemoteWidgetLibrary(<Import>[], <WidgetDeclaration>[
      WidgetDeclaration('a', null, ConstructorCall('b', <String, Object?>{ 'c': SetStateHandler(StateReference(<Object>['d']), false) })),
    ]));
    expect(bytes, <int>[
      0xfe, 0x52, 0x46, 0x57, 0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x61, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0x01, 0x00,  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x62, 0x01,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x63,
      0x11, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  0x00, 0x04, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x64, 0x00,
    ]);
    final RemoteWidgetLibrary value = decodeLibraryBlob(bytes);
    expect(value.imports, isEmpty);
    expect(value.widgets, hasLength(1));
    expect(value.widgets.first.name, 'a');
    expect(value.widgets.first.initialState, isNull);
    expect(value.widgets.first.root, isA<ConstructorCall>());
    expect((value.widgets.first.root as ConstructorCall).name, 'b');
    expect((value.widgets.first.root as ConstructorCall).arguments, hasLength(1));
    expect((value.widgets.first.root as ConstructorCall).arguments.keys, <Object?>['c']);
    expect((value.widgets.first.root as ConstructorCall).arguments['c'], isA<SetStateHandler>());
    expect(((value.widgets.first.root as ConstructorCall).arguments['c']! as SetStateHandler).stateReference.parts, <Object>['d']);
    expect(((value.widgets.first.root as ConstructorCall).arguments['c']! as SetStateHandler).value, false);
  });

  testWidgets('Library encoder: switch', (WidgetTester tester) async {
    final Uint8List bytes = encodeLibraryBlob(const RemoteWidgetLibrary(<Import>[], <WidgetDeclaration>[
      WidgetDeclaration('a', null, ConstructorCall('b', <String, Object?>{ 'c': Switch(false, <Object?, Object>{} ) })),
    ]));
    expect(bytes, <int>[
      0xfe, 0x52, 0x46, 0x57, 0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x61, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0x01, 0x00,  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x62, 0x01,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x63,
      0x0F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  0x00, 0x00,
    ]);
    final RemoteWidgetLibrary value = decodeLibraryBlob(bytes);
    expect(value.imports, isEmpty);
    expect(value.widgets, hasLength(1));
    expect(value.widgets.first.name, 'a');
    expect(value.widgets.first.initialState, isNull);
    expect(value.widgets.first.root, isA<ConstructorCall>());
    expect((value.widgets.first.root as ConstructorCall).name, 'b');
    expect((value.widgets.first.root as ConstructorCall).arguments, hasLength(1));
    expect((value.widgets.first.root as ConstructorCall).arguments.keys, <Object?>['c']);
    expect((value.widgets.first.root as ConstructorCall).arguments['c'], isA<Switch>());
    expect(((value.widgets.first.root as ConstructorCall).arguments['c']! as Switch).input, false);
    expect(((value.widgets.first.root as ConstructorCall).arguments['c']! as Switch).outputs, isEmpty);
  });

  testWidgets('Library encoder: initial state', (WidgetTester tester) async {
    final Uint8List bytes = encodeLibraryBlob(const RemoteWidgetLibrary(<Import>[], <WidgetDeclaration>[
      WidgetDeclaration('a', <String, Object?>{}, ConstructorCall('b', <String, Object?>{})),
    ]));
    expect(bytes, <int>[
      0xfe, 0x52, 0x46, 0x57, 0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x61, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0x01, 0x00,  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x62, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    ]);
    final RemoteWidgetLibrary value = decodeLibraryBlob(bytes);
    expect(value.imports, isEmpty);
    expect(value.widgets, hasLength(1));
    expect(value.widgets.first.name, 'a');
    expect(value.widgets.first.initialState, isNull);
    expect(value.widgets.first.root, isA<ConstructorCall>());
    expect((value.widgets.first.root as ConstructorCall).name, 'b');
    expect((value.widgets.first.root as ConstructorCall).arguments, isEmpty);
  });

  testWidgets('Library encoder: initial state', (WidgetTester tester) async {
    final Uint8List bytes = encodeLibraryBlob(const RemoteWidgetLibrary(<Import>[], <WidgetDeclaration>[
      WidgetDeclaration('a', <String, Object?>{ 'b': false }, ConstructorCall('c', <String, Object?>{})),
    ]));
    expect(bytes, <int>[
      0xfe, 0x52, 0x46, 0x57, 0x00, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x61, 0x01, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00,  0x00, 0x00, 0x00, 0x00, 0x00, 0x62, 0x00, 0x09,
      0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x63,  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00,
    ]);
    final RemoteWidgetLibrary value = decodeLibraryBlob(bytes);
    expect(value.imports, isEmpty);
    expect(value.widgets, hasLength(1));
    expect(value.widgets.first.name, 'a');
    expect(value.widgets.first.initialState, isNotNull);
    expect(value.widgets.first.initialState, hasLength(1));
    expect(value.widgets.first.initialState!['b'], false);
    expect(value.widgets.first.root, isA<ConstructorCall>());
    expect((value.widgets.first.root as ConstructorCall).name, 'c');
    expect((value.widgets.first.root as ConstructorCall).arguments, isEmpty);
  });

  testWidgets('Library encoder: widget builders work',  (WidgetTester tester) async {
    const String source = '''
      widget Foo = Builder(
        builder: (scope) => Text(text: scope.text),
      );
    ''';
    final RemoteWidgetLibrary library = parseLibraryFile(source);
    final Uint8List encoded = encodeLibraryBlob(library);
    final RemoteWidgetLibrary decoded = decodeLibraryBlob(encoded);

    expect(library.toString(), decoded.toString());
  });

  testWidgets('Library encoder: widget builders throws',  (WidgetTester tester) async {
    const RemoteWidgetLibrary remoteWidgetLibrary = RemoteWidgetLibrary(
      <Import>[], 
      <WidgetDeclaration>[
        WidgetDeclaration(
          'a', 
          <String, Object?>{},
          ConstructorCall(
            'c', 
            <String, Object?>{
              'builder': WidgetBuilderDeclaration('scope', ArgsReference(<Object>[])),
            },
          ),
        ),
      ],
    );
    try {
      decodeLibraryBlob(encodeLibraryBlob(remoteWidgetLibrary));
      fail('did not throw exception');
    } on FormatException catch (e) {
      expect('$e', contains('Unrecognized data type 0x0A while decoding widget builder blob.'));
    }
  });
}
