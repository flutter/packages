// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:pigeon/ast.dart';
import 'package:pigeon/pigeon_lib.dart';
import 'package:test/test.dart';

class Input1 {
  String? input;
}

class Output1 {
  String? output;
}

enum Enum1 {
  one,
  two,
}

class ClassWithEnum {
  Enum1? enum1;
}

@HostApi()
abstract class Api1 {
  Output1 doit(Input1 input);
}

class InvalidDatatype {
  dynamic something;
}

@HostApi()
abstract class ApiTwoMethods {
  Output1 method1(Input1 input);
  Output1 method2(Input1 input);
}

class Nested {
  Input1? input;
}

@FlutterApi()
abstract class AFlutterApi {
  Output1 doit(Input1 input);
}

@HostApi()
abstract class VoidApi {
  void doit(Input1 input);
}

@HostApi()
abstract class VoidArgApi {
  Output1 doit();
}

@HostApi(dartHostTestHandler: 'ApiWithMockDartClassMock')
abstract class ApiWithMockDartClass {
  Output1 doit();
}

class OnlyVisibleFromNesting {
  String? foo;
}

class Nestor {
  OnlyVisibleFromNesting? nested;
}

@HostApi()
abstract class NestorApi {
  Nestor getit();
}

@HostApi()
abstract class InvalidArgTypeApi {
  void doit(bool value);
}

@HostApi()
abstract class InvalidReturnTypeApi {
  bool doit();
}

enum NestedEnum { one, two }

class NestedEnum1 {
  NestedEnum? test;
}

class NestedEnum2 {
  NestedEnum1? class1;
}

class NestedEnum3 {
  NestedEnum2? class1;
  int? n;
}

@HostApi()
abstract class NestedEnumApi {
  void method(NestedEnum3 foo);
}

void main() {
  const String thisPath = './test/pigeon_lib_test.dart';

  test('parse args - input', () {
    final PigeonOptions opts =
        Pigeon.parseArgs(<String>['--input', 'foo.dart']);
    expect(opts.input, equals('foo.dart'));
  });

  test('parse args - dart_out', () {
    final PigeonOptions opts =
        Pigeon.parseArgs(<String>['--dart_out', 'foo.dart']);
    expect(opts.dartOut, equals('foo.dart'));
  });

  test('parse args - java_package', () {
    final PigeonOptions opts =
        Pigeon.parseArgs(<String>['--java_package', 'com.google.foo']);
    expect(opts.javaOptions?.package, equals('com.google.foo'));
  });

  test('parse args - input', () {
    final PigeonOptions opts =
        Pigeon.parseArgs(<String>['--java_out', 'foo.java']);
    expect(opts.javaOut, equals('foo.java'));
  });

  test('parse args - objc_header_out', () {
    final PigeonOptions opts =
        Pigeon.parseArgs(<String>['--objc_header_out', 'foo.h']);
    expect(opts.objcHeaderOut, equals('foo.h'));
  });

  test('parse args - objc_source_out', () {
    final PigeonOptions opts =
        Pigeon.parseArgs(<String>['--objc_source_out', 'foo.m']);
    expect(opts.objcSourceOut, equals('foo.m'));
  });

  test('simple parse api', () {
    final Pigeon dartle = Pigeon.setup();
    final ParseResults parseResult = dartle.parseFile(thisPath,
        types: <Type>[Api1], ignoresInvalidImports: true);
    expect(parseResult.errors.length, equals(0));
    final Root root = parseResult.root;
    expect(root.classes.length, equals(2));
    expect(root.apis.length, equals(1));
    expect(root.apis[0].name, equals('Api1'));
    expect(root.apis[0].methods.length, equals(1));
    expect(root.apis[0].methods[0].name, equals('doit'));
    expect(root.apis[0].methods[0].argType, equals('Input1'));
    expect(root.apis[0].methods[0].returnType, equals('Output1'));

    Class? input;
    Class? output;
    for (final Class klass in root.classes) {
      if (klass.name == 'Input1') {
        input = klass;
      } else if (klass.name == 'Output1') {
        output = klass;
      }
    }
    expect(input, isNotNull);
    expect(output, isNotNull);

    expect(input?.fields.length, equals(1));
    expect(input?.fields[0].name, equals('input'));
    expect(input?.fields[0].dataType, equals('String'));

    expect(output?.fields.length, equals(1));
    expect(output?.fields[0].name, equals('output'));
    expect(output?.fields[0].dataType, equals('String'));
  });

  test('invalid datatype', () {
    final Pigeon dartle = Pigeon.setup();
    final ParseResults results = dartle.parseFile(thisPath,
        types: <Type>[InvalidDatatype], ignoresInvalidImports: true);
    expect(results.errors.length, 1);
    expect(results.errors[0].message, contains('InvalidDatatype'));
    expect(results.errors[0].message, contains('dynamic'));
  });

  test('enum in classes', () {
    final Pigeon dartle = Pigeon.setup();
    final ParseResults results = dartle.parseFile(thisPath,
        types: <Type>[ClassWithEnum], ignoresInvalidImports: true);
    expect(results.errors.length, equals(0));
    expect(results.root.classes.length, equals(1));
    expect(results.root.classes[0].name, equals('ClassWithEnum'));
    expect(results.root.classes[0].fields.length, equals(1));
    expect(results.root.classes[0].fields[0].dataType, equals('Enum1'));
    expect(results.root.classes[0].fields[0].name, equals('enum1'));
  });

  test('two methods', () {
    final Pigeon dartle = Pigeon.setup();
    final ParseResults results = dartle.parseFile(thisPath,
        types: <Type>[ApiTwoMethods], ignoresInvalidImports: true);
    expect(results.errors.length, 0);
    expect(results.root.apis.length, 1);
    expect(results.root.apis[0].methods.length, equals(2));
    expect(results.root.apis[0].methods[0].name, equals('method1'));
    expect(results.root.apis[0].methods[1].name, equals('method2'));
  });

  test('nested', () {
    final Pigeon dartle = Pigeon.setup();
    final ParseResults results = dartle.parseFile(thisPath,
        types: <Type>[Nested, Input1], ignoresInvalidImports: true);
    expect(results.errors.length, equals(0));
    expect(results.root.classes.length, equals(2));
    final Class nested =
        results.root.classes.firstWhere((Class x) => x.name == 'Nested');
    expect(nested.fields.length, equals(1));
    expect(nested.fields[0].dataType, equals('Input1'));
  });

  test('flutter api', () {
    final Pigeon pigeon = Pigeon.setup();
    final ParseResults results = pigeon.parseFile(thisPath,
        types: <Type>[AFlutterApi], ignoresInvalidImports: true);
    expect(results.errors.length, equals(0));
    expect(results.root.apis.length, equals(1));
    expect(results.root.apis[0].name, equals('AFlutterApi'));
    expect(results.root.apis[0].location, equals(ApiLocation.flutter));
  });

  test('void host api', () {
    final Pigeon pigeon = Pigeon.setup();
    final ParseResults results = pigeon.parseFile(thisPath,
        types: <Type>[VoidApi], ignoresInvalidImports: true);
    expect(results.errors.length, equals(0));
    expect(results.root.apis.length, equals(1));
    expect(results.root.apis[0].methods.length, equals(1));
    expect(results.root.apis[0].name, equals('VoidApi'));
    expect(results.root.apis[0].methods[0].returnType, equals('void'));
  });

  test('void arg host api', () {
    final Pigeon pigeon = Pigeon.setup();
    final ParseResults results = pigeon.parseFile(thisPath,
        types: <Type>[VoidArgApi], ignoresInvalidImports: true);
    expect(results.errors.length, equals(0));
    expect(results.root.apis.length, equals(1));
    expect(results.root.apis[0].methods.length, equals(1));
    expect(results.root.apis[0].name, equals('VoidArgApi'));
    expect(results.root.apis[0].methods[0].returnType, equals('Output1'));
    expect(results.root.apis[0].methods[0].argType, equals('void'));
  });

  test('mockDartClass', () {
    final Pigeon pigeon = Pigeon.setup();
    final ParseResults results = pigeon.parseFile(thisPath,
        types: <Type>[ApiWithMockDartClass], ignoresInvalidImports: true);
    expect(results.errors.length, equals(0));
    expect(results.root.apis.length, equals(1));
    expect(results.root.apis[0].dartHostTestHandler,
        equals('ApiWithMockDartClassMock'));
  });

  test('only visible from nesting', () {
    final Pigeon dartle = Pigeon.setup();
    final ParseResults results = dartle.parseFile(thisPath,
        types: <Type>[NestorApi], ignoresInvalidImports: true);
    expect(results.errors.length, 0);
    expect(results.root.apis.length, 1);
    final List<String> classNames =
        results.root.classes.map((Class x) => x.name).toList();
    expect(classNames.length, 2);
    expect(classNames.contains('Nestor'), true);
    expect(classNames.contains('OnlyVisibleFromNesting'), true);
  });

  test('invalid datatype for argument', () {
    final Pigeon pigeon = Pigeon.setup();
    final ParseResults results = pigeon.parseFile(thisPath,
        types: <Type>[InvalidArgTypeApi], ignoresInvalidImports: true);
    expect(results.errors.length, 1);
  });

  test('invalid datatype for argument', () {
    final Pigeon pigeon = Pigeon.setup();
    final ParseResults results = pigeon.parseFile(thisPath,
        types: <Type>[InvalidReturnTypeApi], ignoresInvalidImports: true);
    expect(results.errors.length, 1);
  });

  test('null safety flag', () {
    final PigeonOptions results =
        Pigeon.parseArgs(<String>['--dart_null_safety']);
    expect(results.dartOptions?.isNullSafe, isTrue);
  });

  test('copyright flag', () {
    final PigeonOptions results =
        Pigeon.parseArgs(<String>['--copyright_header', 'foobar.txt']);
    expect(results.copyrightHeader, 'foobar.txt');
  });

  test('Dart generater copyright flag', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    const PigeonOptions options =
        PigeonOptions(copyrightHeader: './copyright_header.txt');
    const DartGenerator dartGenerator = DartGenerator();
    final StringBuffer buffer = StringBuffer();
    dartGenerator.generate(buffer, options, root);
    expect(buffer.toString(), startsWith('// Copyright 2013'));
  });

  test('Java generater copyright flag', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    const PigeonOptions options = PigeonOptions(
        javaOut: 'Foo.java', copyrightHeader: './copyright_header.txt');
    const JavaGenerator javaGenerator = JavaGenerator();
    final StringBuffer buffer = StringBuffer();
    javaGenerator.generate(buffer, options, root);
    expect(buffer.toString(), startsWith('// Copyright 2013'));
  });

  test('Objc header generater copyright flag', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    const PigeonOptions options =
        PigeonOptions(copyrightHeader: './copyright_header.txt');
    const ObjcHeaderGenerator objcHeaderGenerator = ObjcHeaderGenerator();
    final StringBuffer buffer = StringBuffer();
    objcHeaderGenerator.generate(buffer, options, root);
    expect(buffer.toString(), startsWith('// Copyright 2013'));
  });

  test('Objc source generater copyright flag', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    const PigeonOptions options =
        PigeonOptions(copyrightHeader: './copyright_header.txt');
    const ObjcSourceGenerator objcSourceGenerator = ObjcSourceGenerator();
    final StringBuffer buffer = StringBuffer();
    objcSourceGenerator.generate(buffer, options, root);
    expect(buffer.toString(), startsWith('// Copyright 2013'));
  });

  test('nested enum', () {
    final Pigeon dartle = Pigeon.setup();
    final ParseResults parseResult = dartle.parseFile(thisPath,
        types: <Type>[NestedEnumApi], ignoresInvalidImports: true);
    expect(parseResult.errors.length, equals(0));
    expect(parseResult.root.apis.length, 1);
    expect(parseResult.root.classes.length, 3);
    expect(parseResult.root.enums.length, 1);
  });

  void _withTempFile(String filename, void Function(File) callback) {
    final Directory dir = Directory.systemTemp.createTempSync();
    final String path = '${dir.path}/$filename';
    final File file = File(path);
    file.createSync();
    try {
      callback(file);
    } finally {
      dir.deleteSync(recursive: true);
    }
  }

  test('test compilation error', () {
    final Pigeon dartle = Pigeon.setup();
    _withTempFile('compilationError.dart', (File file) {
      file.writeAsStringSync('Hello\n');
      final ParseResults results =
          dartle.parseFile(file.path, ignoresInvalidImports: true);
      expect(results.errors.length, greaterThanOrEqualTo(1));
      expect(results.errors[0].lineNumber, 1);
    });
  });

  test('test invalid import', () {
    final Pigeon dartle = Pigeon.setup();
    _withTempFile('compilationError.dart', (File file) {
      file.writeAsStringSync('import \'foo.dart\';\n');
      final ParseResults results = dartle.parseFile(file.path);
      expect(results.errors.length, greaterThanOrEqualTo(1));
      expect(results.errors[0].lineNumber, 1);
    });
  });

  test('test valid import', () {
    final Pigeon dartle = Pigeon.setup();
    _withTempFile('compilationError.dart', (File file) {
      file.writeAsStringSync('import \'package:pigeon/pigeon.dart\';\n');
      final ParseResults results = dartle.parseFile(file.path);
      expect(results.errors.length, 0);
    });
  });
}
