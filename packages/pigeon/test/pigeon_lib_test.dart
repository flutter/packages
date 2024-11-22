// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:pigeon/ast.dart';
import 'package:pigeon/generator_tools.dart';
import 'package:pigeon/pigeon_lib.dart';
import 'package:test/test.dart';

class _ValidatorGeneratorAdapter implements GeneratorAdapter {
  _ValidatorGeneratorAdapter(this.sink);

  @override
  List<FileType> fileTypeList = const <FileType>[FileType.na];

  bool didCallValidate = false;

  final IOSink? sink;

  @override
  void generate(
      StringSink sink, PigeonOptions options, Root root, FileType fileType) {}

  @override
  IOSink? shouldGenerate(PigeonOptions options, FileType _) => sink;

  @override
  List<Error> validate(PigeonOptions options, Root root) {
    didCallValidate = true;
    return <Error>[
      Error(message: '_ValidatorGenerator'),
    ];
  }
}

void main() {
  /// Creates a temporary file named [filename] then calls [callback] with a
  /// [File] representing that temporary directory.  The file will be deleted
  /// after the [callback] is executed.
  void withTempFile(String filename, void Function(File) callback) {
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

  ParseResults parseSource(String source) {
    final Pigeon dartle = Pigeon.setup();
    ParseResults? results;
    withTempFile('source.dart', (File file) {
      file.writeAsStringSync(source);
      results = dartle.parseFile(file.path);
    });
    return results!;
  }

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

  test('parse args - swift_out', () {
    final PigeonOptions opts =
        Pigeon.parseArgs(<String>['--swift_out', 'Foo.swift']);
    expect(opts.swiftOut, equals('Foo.swift'));
  });

  test('parse args - kotlin_out', () {
    final PigeonOptions opts =
        Pigeon.parseArgs(<String>['--kotlin_out', 'Foo.kt']);
    expect(opts.kotlinOut, equals('Foo.kt'));
  });

  test('parse args - kotlin_package', () {
    final PigeonOptions opts =
        Pigeon.parseArgs(<String>['--kotlin_package', 'com.google.foo']);
    expect(opts.kotlinOptions?.package, equals('com.google.foo'));
  });

  test('parse args - cpp_header_out', () {
    final PigeonOptions opts =
        Pigeon.parseArgs(<String>['--cpp_header_out', 'foo.h']);
    expect(opts.cppHeaderOut, equals('foo.h'));
  });

  test('parse args - java_use_generated_annotation', () {
    final PigeonOptions opts =
        Pigeon.parseArgs(<String>['--java_use_generated_annotation']);
    expect(opts.javaOptions!.useGeneratedAnnotation, isTrue);
  });

  test('parse args - cpp_source_out', () {
    final PigeonOptions opts =
        Pigeon.parseArgs(<String>['--cpp_source_out', 'foo.cpp']);
    expect(opts.cppSourceOut, equals('foo.cpp'));
  });

  test('parse args - one_language', () {
    final PigeonOptions opts = Pigeon.parseArgs(<String>['--one_language']);
    expect(opts.oneLanguage, isTrue);
  });

  test('parse args - ast_out', () {
    final PigeonOptions opts =
        Pigeon.parseArgs(<String>['--ast_out', 'stdout']);
    expect(opts.astOut, equals('stdout'));
  });

  test('parse args - base_path', () {
    final PigeonOptions opts =
        Pigeon.parseArgs(<String>['--base_path', './foo/']);
    expect(opts.basePath, equals('./foo/'));
  });

  test('simple parse api', () {
    const String code = '''
class Input1 {
  String? input;
}

class Output1 {
  String? output;
}

class Unused {
  String? field;
}

@HostApi()
abstract class Api1 {
  Output1 doit(Input1 input);
}
''';
    final ParseResults parseResult = parseSource(code);
    expect(parseResult.errors.length, equals(0));
    final Root root = parseResult.root;
    expect(root.classes.length, equals(3));
    expect(root.apis.length, equals(1));
    expect(root.apis[0].name, equals('Api1'));
    expect(root.apis[0].methods.length, equals(1));
    expect(root.apis[0].methods[0].name, equals('doit'));
    expect(root.apis[0].methods[0].parameters[0].name, equals('input'));
    expect(
        root.apis[0].methods[0].parameters[0].type.baseName, equals('Input1'));
    expect(root.apis[0].methods[0].returnType.baseName, equals('Output1'));

    Class? input;
    Class? output;
    Class? unused;
    for (final Class classDefinition in root.classes) {
      if (classDefinition.name == 'Input1') {
        input = classDefinition;
      } else if (classDefinition.name == 'Output1') {
        output = classDefinition;
      } else if (classDefinition.name == 'Unused') {
        unused = classDefinition;
      }
    }
    expect(input, isNotNull);
    expect(output, isNotNull);
    expect(unused, isNotNull);

    expect(input?.fields.length, equals(1));
    expect(input?.fields[0].name, equals('input'));
    expect(input?.fields[0].type.baseName, equals('String'));
    expect(input?.fields[0].type.isNullable, isTrue);

    expect(output?.fields.length, equals(1));
    expect(output?.fields[0].name, equals('output'));
    expect(output?.fields[0].type.baseName, equals('String'));
    expect(output?.fields[0].type.isNullable, isTrue);

    expect(unused?.fields.length, equals(1));
    expect(unused?.fields[0].name, equals('field'));
    expect(unused?.fields[0].type.baseName, equals('String'));
    expect(unused?.fields[0].type.isNullable, isTrue);
  });

  test('invalid datatype', () {
    const String source = '''
class InvalidDatatype {
  dynamic something;
}

@HostApi()
abstract class Api {
  InvalidDatatype foo();
}
''';
    final ParseResults results = parseSource(source);
    expect(results.errors.length, 1);
    expect(results.errors[0].message, contains('InvalidDatatype'));
    expect(results.errors[0].message, contains('dynamic'));
  });

  test('enum in classes', () {
    const String code = '''
enum Enum1 {
  one,
  two,
}

class ClassWithEnum {
  Enum1? enum1;
}

@HostApi
abstract class Api {
  ClassWithEnum foo();
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, equals(0));
    expect(results.root.classes.length, equals(1));
    expect(results.root.classes[0].name, equals('ClassWithEnum'));
    expect(results.root.classes[0].fields.length, equals(1));
    expect(results.root.classes[0].fields[0].type.baseName, equals('Enum1'));
    expect(results.root.classes[0].fields[0].type.isNullable, isTrue);
    expect(results.root.classes[0].fields[0].name, equals('enum1'));
  });

  test('two methods', () {
    const String code = '''
class Input1 {
  String? input;
}

class Output1 {
  int? output;
}

@HostApi()
abstract class ApiTwoMethods {
  Output1 method1(Input1 input);
  Output1 method2(Input1 input);
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, 0);
    expect(results.root.apis.length, 1);
    expect(results.root.apis[0].methods.length, equals(2));
    expect(results.root.apis[0].methods[0].name, equals('method1'));
    expect(results.root.apis[0].methods[1].name, equals('method2'));
  });

  test('nested', () {
    const String code = '''
class Input1 {
  String? input;
}

class Nested {
  Input1? input;
}

@HostApi()
abstract class Api {
  Nested foo();
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, equals(0));
    expect(results.root.classes.length, equals(2));
    final Class nested =
        results.root.classes.firstWhere((Class x) => x.name == 'Nested');
    expect(nested.fields.length, equals(1));
    expect(nested.fields[0].type.baseName, equals('Input1'));
    expect(nested.fields[0].type.isNullable, isTrue);
  });

  test('flutter api', () {
    const String code = '''
class Input1 {
  String? input;
}

class Output1 {
  int? output;
}

@FlutterApi()
abstract class AFlutterApi {
  Output1 doit(Input1 input);
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, equals(0));
    expect(results.root.apis.length, equals(1));
    expect(results.root.apis[0].name, equals('AFlutterApi'));
    expect(results.root.apis[0], isA<AstFlutterApi>());
  });

  test('void host api', () {
    const String code = '''
class Input1 {
  String? input;
}

@HostApi()
abstract class VoidApi {
  void doit(Input1 input);
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, equals(0));
    expect(results.root.apis.length, equals(1));
    expect(results.root.apis[0].methods.length, equals(1));
    expect(results.root.apis[0].name, equals('VoidApi'));
    expect(results.root.apis[0].methods[0].returnType.isVoid, isTrue);
  });

  test('void arg host api', () {
    const String code = '''
class Output1 {
  String? output;
}

@HostApi()
abstract class VoidArgApi {
  Output1 doit();
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, equals(0));
    expect(results.root.apis.length, equals(1));
    expect(results.root.apis[0].methods.length, equals(1));
    expect(results.root.apis[0].name, equals('VoidArgApi'));
    expect(
        results.root.apis[0].methods[0].returnType.baseName, equals('Output1'));
    expect(results.root.apis[0].methods[0].parameters.isEmpty, isTrue);
  });

  test('mockDartClass', () {
    const String code = '''
class Output1 {
  String? output;
}

@HostApi(dartHostTestHandler: 'ApiWithMockDartClassMock')
abstract class ApiWithMockDartClass {
  Output1 doit();
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, equals(0));
    expect(results.root.apis.length, equals(1));
    expect(
      (results.root.apis[0] as AstHostApi).dartHostTestHandler,
      equals('ApiWithMockDartClassMock'),
    );
  });

  test('only visible from nesting', () {
    const String code = '''
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
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, 0);
    expect(results.root.apis.length, 1);
    final List<String> classNames =
        results.root.classes.map((Class x) => x.name).toList();
    expect(classNames.length, 2);
    expect(classNames.contains('Nestor'), true);
    expect(classNames.contains('OnlyVisibleFromNesting'), true);
  });

  test('copyright flag', () {
    final PigeonOptions results =
        Pigeon.parseArgs(<String>['--copyright_header', 'foobar.txt']);
    expect(results.copyrightHeader, 'foobar.txt');
  });

  test('Dart generator copyright flag', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    const PigeonOptions options =
        PigeonOptions(copyrightHeader: './copyright_header.txt');
    final DartGeneratorAdapter dartGeneratorAdapter = DartGeneratorAdapter();
    final StringBuffer buffer = StringBuffer();
    dartGeneratorAdapter.generate(buffer, options, root, FileType.na);
    expect(buffer.toString(), startsWith('// Copyright 2013'));
  });

  test('Java generator copyright flag', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    const PigeonOptions options = PigeonOptions(
        javaOut: 'Foo.java', copyrightHeader: './copyright_header.txt');
    final JavaGeneratorAdapter javaGeneratorAdapter = JavaGeneratorAdapter();
    final StringBuffer buffer = StringBuffer();
    javaGeneratorAdapter.generate(buffer, options, root, FileType.na);
    expect(buffer.toString(), startsWith('// Copyright 2013'));
  });

  test('Objc header generator copyright flag', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    const PigeonOptions options =
        PigeonOptions(copyrightHeader: './copyright_header.txt');
    final ObjcGeneratorAdapter objcHeaderGeneratorAdapter =
        ObjcGeneratorAdapter();
    final StringBuffer buffer = StringBuffer();
    objcHeaderGeneratorAdapter.generate(buffer, options, root, FileType.header);
    expect(buffer.toString(), startsWith('// Copyright 2013'));
  });

  test('Objc source generator copyright flag', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    const PigeonOptions options =
        PigeonOptions(copyrightHeader: './copyright_header.txt');
    final ObjcGeneratorAdapter objcSourceGeneratorAdapter =
        ObjcGeneratorAdapter();
    final StringBuffer buffer = StringBuffer();
    objcSourceGeneratorAdapter.generate(buffer, options, root, FileType.source);
    expect(buffer.toString(), startsWith('// Copyright 2013'));
  });

  test('Swift generator copyright flag', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    const PigeonOptions options = PigeonOptions(
        swiftOut: 'Foo.swift', copyrightHeader: './copyright_header.txt');
    final SwiftGeneratorAdapter swiftGeneratorAdapter = SwiftGeneratorAdapter();
    final StringBuffer buffer = StringBuffer();
    swiftGeneratorAdapter.generate(buffer, options, root, FileType.na);
    expect(buffer.toString(), startsWith('// Copyright 2013'));
  });

  test('C++ header generator copyright flag', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    const PigeonOptions options = PigeonOptions(
        cppHeaderOut: 'Foo.h', copyrightHeader: './copyright_header.txt');
    final CppGeneratorAdapter cppHeaderGeneratorAdapter = CppGeneratorAdapter();
    final StringBuffer buffer = StringBuffer();
    cppHeaderGeneratorAdapter.generate(buffer, options, root, FileType.header);
    expect(buffer.toString(), startsWith('// Copyright 2013'));
  });

  test('C++ source generator copyright flag', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    const PigeonOptions options =
        PigeonOptions(copyrightHeader: './copyright_header.txt');
    final CppGeneratorAdapter cppSourceGeneratorAdapter =
        CppGeneratorAdapter(fileTypeList: <FileType>[FileType.source]);
    final StringBuffer buffer = StringBuffer();
    cppSourceGeneratorAdapter.generate(buffer, options, root, FileType.source);
    expect(buffer.toString(), startsWith('// Copyright 2013'));
  });

  test('nested enum', () {
    const String code = '''
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
''';
    final ParseResults parseResult = parseSource(code);
    expect(parseResult.errors.length, equals(0));
    expect(parseResult.root.apis.length, 1);
    expect(parseResult.root.classes.length, 3);
    expect(parseResult.root.enums.length, 1);
  });

  test('test circular references', () {
    const String code = '''
class Foo {
  Bar? bar;
}

class Bar {
  Foo? foo;
}

@HostApi()
abstract class NotificationsHostApi {
  void doit(Foo foo);
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, 0);
    expect(results.root.classes.length, 2);
    final Class foo =
        results.root.classes.firstWhere((Class aClass) => aClass.name == 'Foo');
    expect(foo.fields.length, 1);
    expect(foo.fields[0].type.baseName, 'Bar');
  });

  test('test compilation error', () {
    const String code = 'Hello\n';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, greaterThanOrEqualTo(1));
    expect(results.errors[0].lineNumber, 1);
  });

  test('test method in data class error', () {
    const String code = '''
class Foo {
  int? x;
  int? foo() { return x; }
}

@HostApi()
abstract class Api {
  Foo doit(Foo foo);
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, 1);
    expect(results.errors[0].lineNumber, 3);
    expect(results.errors[0].message, contains('Method'));
  });

  test('test field initialization', () {
    const String code = '''
class Foo {
  int? x = 123;
}

@HostApi()
abstract class Api {
  Foo doit(Foo foo);
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, 1);
    expect(results.errors[0].lineNumber, 2);
    expect(results.errors[0].message, contains('Initialization'));
  });

  test('test field in api error', () {
    const String code = '''
class Foo {
  int? x;
}

@HostApi()
abstract class Api {
  int? x;
  Foo doit(Foo foo);
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, 1);
    expect(results.errors[0].lineNumber, 7);
    expect(results.errors[0].message, contains('Field'));
  });

  test('constructor in data class', () {
    const String code = '''
class Foo {
  int? x;
  Foo({this.x});
}

@HostApi()
abstract class Api {
  Foo doit(Foo foo);
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, 0);
  });

  test('constructor body in data class', () {
    const String code = '''
class Foo {
  int? x;
  Foo({this.x}) { print('hi'); }
}

@HostApi()
abstract class Api {
  Foo doit(Foo foo);
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, 1);
    expect(results.errors[0].lineNumber, 3);
    expect(results.errors[0].message, contains('Constructor'));
  });

  test('constructor body in data class', () {
    const String code = '''
class Foo {
  int? x;
  Foo() : x = 0;
}

@HostApi()
abstract class Api {
  Foo doit(Foo foo);
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, 1);
    expect(results.errors[0].lineNumber, 3);
    expect(results.errors[0].message, contains('Constructor'));
  });

  test('constructor in api class', () {
    const String code = '''
class Foo {
  int? x;
}

@HostApi()
abstract class Api {
  Api() { print('hi'); }
  Foo doit(Foo foo);
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, 1);
    expect(results.errors[0].lineNumber, 7);
    expect(results.errors[0].message, contains('Constructor'));
  });

  test('test invalid import', () {
    const String code = "import 'foo.dart';\n";
    final ParseResults results = parseSource(code);
    expect(results.errors.length, greaterThanOrEqualTo(1));
    expect(results.errors[0].lineNumber, 1);
  });

  test('test valid import', () {
    const String code = "import 'package:pigeon/pigeon.dart';\n";
    final ParseResults parseResults = parseSource(code);
    expect(parseResults.errors.length, 0);
  });

  test('error with static field', () {
    const String code = '''
class WithStaticField {
  static int? x;
  int? y;
}

@HostApi()
abstract class WithStaticFieldApi {
  void doit(WithStaticField withTemplate);
}
''';
    final ParseResults parseResult = parseSource(code);
    expect(parseResult.errors.length, equals(1));
    expect(parseResult.errors[0].message, contains('static field'));
    expect(parseResult.errors[0].lineNumber, isNotNull);
  });

  test('parse generics', () {
    const String code = '''
class Foo {
  List<int?>? list;
}

@HostApi()
abstract class Api {
  void doit(Foo foo);
}
''';
    final ParseResults parseResult = parseSource(code);
    expect(parseResult.errors.length, equals(0));
    final NamedType field = parseResult.root.classes[0].fields[0];
    expect(field.type.typeArguments.length, 1);
    expect(field.type.typeArguments[0].baseName, 'int');
  });

  test('parse recursive generics', () {
    const String code = '''
class Foo {
  List<List<int?>?>? list;
}

@HostApi()
abstract class Api {
  void doit(Foo foo);
}
''';
    final ParseResults parseResult = parseSource(code);
    expect(parseResult.errors.length, equals(0));
    final NamedType field = parseResult.root.classes[0].fields[0];
    expect(field.type.typeArguments.length, 1);
    expect(field.type.typeArguments[0].baseName, 'List');
    expect(field.type.typeArguments[0].typeArguments[0].baseName, 'int');
  });

  test('enums argument host', () {
    const String code = '''
enum Foo {
  one,
  two,
}

@HostApi()
abstract class Api {
  void doit(Foo foo);
}
''';
    final ParseResults parseResult = parseSource(code);
    expect(parseResult.errors.length, equals(0));
  });

  test('enums argument flutter', () {
    const String code = '''

enum Foo {
  one,
  two,
}

@FlutterApi()
abstract class Api {
  void doit(Foo foo);
}
''';
    final ParseResults parseResult = parseSource(code);
    expect(parseResult.errors.length, equals(0));
  });

  test('enums list argument', () {
    const String code = '''
enum Foo { one, two }

@HostApi()
abstract class Api {
  void doit(List<Foo> foo);
}
''';
    final ParseResults parseResult = parseSource(code);
    expect(parseResult.errors.length, equals(0));
  });

  test('enums map argument key', () {
    const String code = '''
enum Foo { one, two }

@HostApi()
abstract class Api {
  void doit(Map<Foo, Object> foo);
}
''';
    final ParseResults parseResult = parseSource(code);
    expect(parseResult.errors.length, equals(0));
  });

  test('enums map argument value', () {
    const String code = '''
enum Foo { one, two }

@HostApi()
abstract class Api {
  void doit(Map<Foo, Object> foo);
}
''';
    final ParseResults parseResult = parseSource(code);
    expect(parseResult.errors.length, equals(0));
  });

  test('enums return value', () {
    const String code = '''

enum Foo {
  one,
  two,
}

@HostApi()
abstract class Api {
  Foo doit();
}
''';
    final ParseResults parseResult = parseSource(code);
    expect(parseResult.errors.length, equals(0));
  });

  test('return type generics', () {
    const String code = '''
@HostApi()
abstract class Api {
  List<double?> doit();
}
''';
    final ParseResults parseResult = parseSource(code);
    expect(parseResult.root.apis[0].methods[0].returnType.baseName, 'List');
    expect(
        parseResult
            .root.apis[0].methods[0].returnType.typeArguments[0].baseName,
        'double');
    expect(
        parseResult
            .root.apis[0].methods[0].returnType.typeArguments[0].isNullable,
        isTrue);
  });

  test('argument generics', () {
    const String code = '''
@HostApi()
abstract class Api {
  void doit(int x, List<double?> value);
}
''';
    final ParseResults parseResult = parseSource(code);
    expect(parseResult.root.apis[0].methods[0].parameters[1].type.baseName,
        'List');
    expect(
        parseResult.root.apis[0].methods[0].parameters[1].type.typeArguments[0]
            .baseName,
        'double');
    expect(
        parseResult.root.apis[0].methods[0].parameters[1].type.typeArguments[0]
            .isNullable,
        isTrue);
  });

  test('map generics', () {
    const String code = '''
class Foo {
  Map<String?, int?> map;
}

@HostApi()
abstract class Api {
  void doit(Foo foo);
}
''';
    final ParseResults parseResult = parseSource(code);
    final NamedType field = parseResult.root.classes[0].fields[0];
    expect(field.type.typeArguments.length, 2);
    expect(field.type.typeArguments[0].baseName, 'String');
    expect(field.type.typeArguments[1].baseName, 'int');
  });

  test('two parameters', () {
    const String code = '''
class Input {
  String? input;
}

@HostApi()
abstract class Api {
  void method(Input input1, Input input2);
}
''';
    final ParseResults results = parseSource(code);
    expect(results.root.apis.length, 1);
    expect(results.root.apis[0].methods.length, equals(1));
    expect(results.root.apis[0].methods[0].name, equals('method'));
    expect(results.root.apis[0].methods[0].parameters.length, 2);
  });

  test('no type name argument', () {
    const String code = '''
@HostApi()
abstract class Api {
  void method(x);
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, 1);
    expect(results.errors[0].lineNumber, 3);
    expect(results.errors[0].message,
        contains('Parameters must specify their type'));
  });

  test('custom objc selector', () {
    const String code = '''
@HostApi()
abstract class Api {
  @ObjCSelector('subtractValue:by:')
  void subtract(int x, int y);
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, 0);
    expect(results.root.apis.length, 1);
    expect(results.root.apis[0].methods.length, equals(1));
    expect(results.root.apis[0].methods[0].objcSelector,
        equals('subtractValue:by:'));
  });

  test('custom objc invalid selector', () {
    const String code = '''
@HostApi()
abstract class Api {
  @ObjCSelector('subtractValue:by:error:')
  void subtract(int x, int y);
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, 1);
    expect(results.errors[0].lineNumber, 3);
    expect(results.errors[0].message,
        contains('Invalid selector, expected 2 parameters'));
  });

  test('custom objc no parameters', () {
    const String code = '''
@HostApi()
abstract class Api {
  @ObjCSelector('foobar')
  void initialize();
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, 0);
    expect(results.root.apis.length, 1);
    expect(results.root.apis[0].methods.length, equals(1));
    expect(results.root.apis[0].methods[0].objcSelector, equals('foobar'));
  });

  test('custom swift valid function signature', () {
    const String code = '''
@HostApi()
abstract class Api {
  @SwiftFunction('subtractValue(_:by:)')
  void subtract(int x, int y);
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, 0);
    expect(results.root.apis.length, 1);
    expect(results.root.apis[0].methods.length, equals(1));
    expect(results.root.apis[0].methods[0].swiftFunction,
        equals('subtractValue(_:by:)'));
  });

  test('custom swift invalid function signature', () {
    const String code = '''
@HostApi()
abstract class Api {
  @SwiftFunction('subtractValue(_:by:error:)')
  void subtract(int x, int y);
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, 1);
    expect(results.errors[0].lineNumber, 3);
    expect(results.errors[0].message,
        contains('Invalid function signature, expected 2 parameters'));
  });

  test('custom swift function signature no parameters', () {
    const String code = '''
@HostApi()
abstract class Api {
  @SwiftFunction('foobar()')
  void initialize();
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, 0);
    expect(results.root.apis.length, 1);
    expect(results.root.apis[0].methods.length, equals(1));
    expect(results.root.apis[0].methods[0].swiftFunction, equals('foobar()'));
  });

  test('dart test has copyright', () {
    final Root root = Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
    const PigeonOptions options = PigeonOptions(
      copyrightHeader: './copyright_header.txt',
      dartTestOut: 'stdout',
      dartOut: 'stdout',
    );
    final DartTestGeneratorAdapter dartTestGeneratorAdapter =
        DartTestGeneratorAdapter();
    final StringBuffer buffer = StringBuffer();
    dartTestGeneratorAdapter.generate(buffer, options, root, FileType.source);
    expect(buffer.toString(), startsWith('// Copyright 2013'));
  });

  test('only class reference is type argument for return value', () {
    const String code = '''
class Foo {
  int? foo;
}

@HostApi()
abstract class Api {
  List<Foo?> grabAll();
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, 0);
    expect(results.root.classes.length, 1);
    expect(results.root.classes[0].name, 'Foo');
  });

  test('only class reference is type argument for argument', () {
    const String code = '''
class Foo {
  int? foo;
}

@HostApi()
abstract class Api {
  void storeAll(List<Foo?> foos);
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, 0);
    expect(results.root.classes.length, 1);
    expect(results.root.classes[0].name, 'Foo');
  });

  test('recurse into type parameters', () {
    const String code = '''
class Foo {
  int? foo;
  List<Bar?> bars;
}

class Bar {
  int? bar;
}

@HostApi()
abstract class Api {
  void storeAll(List<Foo?> foos);
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, 0);
    expect(results.root.classes.length, 2);
    expect(
        results.root.classes
            .where((Class element) => element.name == 'Foo')
            .length,
        1);
    expect(
        results.root.classes
            .where((Class element) => element.name == 'Bar')
            .length,
        1);
  });

  test('undeclared class in argument type argument', () {
    const String code = '''
@HostApi()
abstract class Api {
  void storeAll(List<Foo?> foos);
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, 1);
    expect(results.errors[0].lineNumber, 3);
    expect(results.errors[0].message, contains('Unknown type: Foo'));
  });

  test('Object type argument', () {
    const String code = '''
@HostApi()
abstract class Api {
  void storeAll(List<Object?> foos);
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, 0);
  });

  test('Export unreferenced enums', () {
    const String code = '''
enum MessageKey {
  title,
  subtitle,
  description,
}

class Message {
  int? id;
  Map<int?, String?>? additionalProperties;
}

@HostApi()
abstract class HostApiBridge {
  void sendMessage(Message message);
}
''';
    final ParseResults results = parseSource(code);
    expect(results.root.enums.length, 1);
    expect(results.root.enums[0].name, 'MessageKey');
  });

  test('@ConfigurePigeon JavaOptions.copyrightHeader', () {
    const String code = '''
@ConfigurePigeon(PigeonOptions(
  javaOptions: JavaOptions(copyrightHeader: <String>['A', 'Header']),
))
class Message {
  int? id;
}
''';

    final ParseResults results = parseSource(code);
    final PigeonOptions options = PigeonOptions.fromMap(results.pigeonOptions!);
    expect(options.javaOptions!.copyrightHeader, <String>['A', 'Header']);
  });

  test('@ConfigurePigeon DartOptions.copyrightHeader', () {
    const String code = '''
@ConfigurePigeon(PigeonOptions(
  dartOptions: DartOptions(copyrightHeader: <String>['A', 'Header']),
))
class Message {
  int? id;
}
''';

    final ParseResults results = parseSource(code);
    final PigeonOptions options = PigeonOptions.fromMap(results.pigeonOptions!);
    expect(options.dartOptions!.copyrightHeader, <String>['A', 'Header']);
  });

  test('@ConfigurePigeon ObjcOptions.copyrightHeader', () {
    const String code = '''
@ConfigurePigeon(PigeonOptions(
  objcOptions: ObjcOptions(copyrightHeader: <String>['A', 'Header']),
))
class Message {
  int? id;
}
''';

    final ParseResults results = parseSource(code);
    final PigeonOptions options = PigeonOptions.fromMap(results.pigeonOptions!);
    expect(options.objcOptions!.copyrightHeader, <String>['A', 'Header']);
  });

  test('@ConfigurePigeon ObjcOptions.headerIncludePath', () {
    const String code = '''
@ConfigurePigeon(PigeonOptions(
  objcOptions: ObjcOptions(headerIncludePath: 'Header.path'),
))
class Message {
  int? id;
}
''';

    final ParseResults results = parseSource(code);
    final PigeonOptions options = PigeonOptions.fromMap(results.pigeonOptions!);
    expect(options.objcOptions?.headerIncludePath, 'Header.path');
  });

  test('@ConfigurePigeon CppOptions.headerIncludePath', () {
    const String code = '''
@ConfigurePigeon(PigeonOptions(
  cppOptions: CppOptions(headerIncludePath: 'Header.path'),
))
class Message {
  int? id;
}
''';

    final ParseResults results = parseSource(code);
    final PigeonOptions options = PigeonOptions.fromMap(results.pigeonOptions!);
    expect(options.cppOptions?.headerIncludePath, 'Header.path');
  });

  test('return nullable', () {
    const String code = '''
@HostApi()
abstract class Api {
  int? calc();
}
''';

    final ParseResults results = parseSource(code);
    expect(results.errors.length, 0);
    expect(results.root.apis[0].methods[0].returnType.isNullable, isTrue);
  });

  test('nullable parameters', () {
    const String code = '''
@HostApi()
abstract class Api {
  void calc(int? value);
}
''';
    final ParseResults results = parseSource(code);
    expect(results.errors.length, 0);
    expect(
        results.root.apis[0].methods[0].parameters[0].type.isNullable, isTrue);
  });

  test('task queue specified', () {
    const String code = '''
@HostApi()
abstract class Api {
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  int? calc();
}
''';

    final ParseResults results = parseSource(code);
    expect(results.errors.length, 0);
    expect(results.root.apis[0].methods[0].taskQueueType,
        equals(TaskQueueType.serialBackgroundThread));
  });

  test('task queue unspecified', () {
    const String code = '''
@HostApi()
abstract class Api {
  int? calc();
}
''';

    final ParseResults results = parseSource(code);
    expect(results.errors.length, 0);
    expect(results.root.apis[0].methods[0].taskQueueType,
        equals(TaskQueueType.serial));
  });

  test('unsupported task queue on FlutterApi', () {
    const String code = '''
@FlutterApi()
abstract class Api {
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  int? calc();
}
''';

    final ParseResults results = parseSource(code);
    expect(results.errors.length, 1);
    expect(results.errors[0].message,
        contains('Unsupported TaskQueue specification'));
  });

  test('generator validation', () async {
    final Completer<void> completer = Completer<void>();
    withTempFile('foo.dart', (File input) async {
      final _ValidatorGeneratorAdapter generator =
          _ValidatorGeneratorAdapter(stdout);
      final int result = await Pigeon.run(<String>['--input', input.path],
          adapters: <GeneratorAdapter>[generator]);
      expect(generator.didCallValidate, isTrue);
      expect(result, isNot(0));
      completer.complete();
    });
    await completer.future;
  });

  test('generator validation skipped', () async {
    final Completer<void> completer = Completer<void>();
    withTempFile('foo.dart', (File input) async {
      final _ValidatorGeneratorAdapter generator =
          _ValidatorGeneratorAdapter(null);
      final int result = await Pigeon.run(
          <String>['--input', input.path, '--dart_out', 'foo.dart'],
          adapters: <GeneratorAdapter>[generator]);
      expect(generator.didCallValidate, isFalse);
      expect(result, equals(0));
      completer.complete();
    });
    await completer.future;
  });

  test('run with PigeonOptions', () async {
    final Completer<void> completer = Completer<void>();
    withTempFile('foo.dart', (File input) async {
      final _ValidatorGeneratorAdapter generator =
          _ValidatorGeneratorAdapter(null);
      final int result = await Pigeon.runWithOptions(
          PigeonOptions(input: input.path, dartOut: 'foo.dart'),
          adapters: <GeneratorAdapter>[generator]);
      expect(generator.didCallValidate, isFalse);
      expect(result, equals(0));
      completer.complete();
    });
    await completer.future;
  });

  test('unsupported non-positional parameters on FlutterApi', () {
    const String code = '''
@FlutterApi()
abstract class Api {
  int? calc({int? anInt});
}
''';

    final ParseResults results = parseSource(code);
    expect(results.errors.length, 1);
    expect(results.errors[0].message,
        contains('FlutterApi method parameters must be positional'));
  });

  test('unsupported optional parameters on FlutterApi', () {
    const String code = '''
@FlutterApi()
abstract class Api {
  int? calc([int? anInt]);
}
''';

    final ParseResults results = parseSource(code);
    expect(results.errors.length, 1);
    expect(results.errors[0].message,
        contains('FlutterApi method parameters must not be optional'));
  });

  test('simple parse ProxyApi', () {
    const String code = '''
@ProxyApi()
abstract class MyClass {
  MyClass();
  late String aField;
  late void Function() aCallbackMethod;
  void aMethod();
}
''';
    final ParseResults parseResult = parseSource(code);
    expect(parseResult.errors.length, equals(0));
    final Root root = parseResult.root;
    expect(root.apis.length, equals(1));

    final AstProxyApi proxyApi = root.apis.single as AstProxyApi;
    expect(proxyApi.name, equals('MyClass'));
    expect(proxyApi.constructors.single.name, equals(''));
    expect(proxyApi.methods.length, equals(2));

    for (final Method method in proxyApi.methods) {
      if (method.location == ApiLocation.host) {
        expect(method.name, equals('aMethod'));
      } else if (method.location == ApiLocation.flutter) {
        expect(method.name, equals('aCallbackMethod'));
      }
    }
  });

  group('ProxyApi validation', () {
    test('error with using data class', () {
      const String code = '''
class DataClass {
  late int input;
}

@ProxyApi()
abstract class MyClass {
  MyClass(DataClass input);
}
''';
      final ParseResults parseResult = parseSource(code);
      expect(parseResult.errors.length, equals(1));
      expect(
        parseResult.errors.single.message,
        contains('ProxyApis do not support data classes'),
      );
    });

    test('super class must be proxy api', () {
      const String code = '''
class DataClass {
  late int input;
}

@ProxyApi()
abstract class MyClass extends DataClass {
  void aMethod();
}
''';
      final ParseResults parseResult = parseSource(code);
      expect(parseResult.errors, isNotEmpty);
      expect(
        parseResult.errors[0].message,
        contains('Super class of MyClass is not marked as a @ProxyApi'),
      );
    });

    test('interface must be proxy api', () {
      const String code = '''
class DataClass {
  late int input;
}

@ProxyApi()
abstract class MyClass implements DataClass {
  void aMethod();
}
''';
      final ParseResults parseResult = parseSource(code);
      expect(parseResult.errors, isNotEmpty);
      expect(
        parseResult.errors[0].message,
        contains('Interface of MyClass is not marked as a @ProxyApi'),
      );
    });

    test('unattached fields can not be inherited', () {
      const String code = '''
@ProxyApi()
abstract class MyClass extends MyOtherClass { }

@ProxyApi()
abstract class MyOtherClass {
  late int aField;
}
''';
      final ParseResults parseResult = parseSource(code);
      expect(parseResult.errors, isNotEmpty);
      expect(
        parseResult.errors[0].message,
        contains(
          'Unattached fields can not be inherited. Unattached field found for parent class: aField',
        ),
      );
    });

    test(
        'api is not used as an attached field while having an unattached field',
        () {
      const String code = '''
@ProxyApi()
abstract class MyClass {
  @attached
  late MyOtherClass anAttachedField;
}

@ProxyApi()
abstract class MyOtherClass {
  late int aField;
}
''';
      final ParseResults parseResult = parseSource(code);
      expect(parseResult.errors, isNotEmpty);
      expect(
        parseResult.errors[0].message,
        contains(
          'ProxyApis with unattached fields can not be used as attached fields: anAttachedField',
        ),
      );
    });

    test(
        'api is not used as an attached field while having a required Flutter method',
        () {
      const String code = '''
@ProxyApi()
abstract class MyClass {
  @attached
  late MyOtherClass anAttachedField;
}

@ProxyApi()
abstract class MyOtherClass {
  late void Function() aCallbackMethod;
}
''';
      final ParseResults parseResult = parseSource(code);
      expect(parseResult.errors, isNotEmpty);
      expect(
        parseResult.errors[0].message,
        contains(
          'ProxyApis with required callback methods can not be used as attached fields: anAttachedField',
        ),
      );
    });

    test('interfaces can only have callback methods', () {
      const String code = '''
@ProxyApi()
abstract class MyClass implements MyOtherClass {
}

@ProxyApi()
abstract class MyOtherClass {
  MyOtherClass();
}
''';
      final ParseResults parseResult = parseSource(code);
      expect(parseResult.errors, isNotEmpty);
      expect(
        parseResult.errors[0].message,
        contains(
          'ProxyApis used as interfaces can only have callback methods: `MyClass` implements `MyOtherClass`',
        ),
      );
    });

    test('attached fields must be a ProxyApi', () {
      const String code = '''
@ProxyApi()
abstract class MyClass {
  @attached
  late int aField;
}
''';
      final ParseResults parseResult = parseSource(code);
      expect(parseResult.errors, isNotEmpty);
      expect(
        parseResult.errors[0].message,
        contains('Attached fields must be a ProxyApi: int'),
      );
    });

    test('attached fields must not be nullable', () {
      const String code = '''
@ProxyApi()
abstract class MyClass {
  @attached
  late MyClass? aField;
}
''';
      final ParseResults parseResult = parseSource(code);
      expect(parseResult.errors, isNotEmpty);
      expect(
        parseResult.errors[0].message,
        contains('Attached fields must not be nullable: MyClass?'),
      );
    });
  });
}
