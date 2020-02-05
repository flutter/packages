// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';
import 'package:pigeon/pigeon_lib.dart';
import 'package:pigeon/ast.dart';

class Input1 {
  String input;
}

class Output1 {
  String output;
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
  Input1 input;
}

@FlutterApi()
abstract class AFlutterApi {
  Output1 doit(Input1 input);
}

void main() {
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
    final ParseResults parseResult = dartle.parse(<Type>[Api1]);
    expect(parseResult.errors.length, equals(0));
    final Root root = parseResult.root;
    expect(root.classes.length, equals(2));
    expect(root.apis.length, equals(1));
    expect(root.apis[0].name, equals('Api1'));
    expect(root.apis[0].methods.length, equals(1));
    expect(root.apis[0].methods[0].name, equals('doit'));
    expect(root.apis[0].methods[0].argType, equals('Input1'));
    expect(root.apis[0].methods[0].returnType, equals('Output1'));

    Class input;
    Class output;
    for (Class klass in root.classes) {
      if (klass.name == 'Input1') {
        input = klass;
      } else if (klass.name == 'Output1') {
        output = klass;
      }
    }
    expect(input, isNotNull);
    expect(output, isNotNull);

    expect(input.fields.length, equals(1));
    expect(input.fields[0].name, equals('input'));
    expect(input.fields[0].dataType, equals('String'));

    expect(output.fields.length, equals(1));
    expect(output.fields[0].name, equals('output'));
    expect(output.fields[0].dataType, equals('String'));
  });

  test('invalid datatype', () {
    final Pigeon dartle = Pigeon.setup();
    final ParseResults results = dartle.parse(<Type>[InvalidDatatype]);
    expect(results.errors.length, 1);
    expect(results.errors[0].message, contains('InvalidDatatype'));
    expect(results.errors[0].message, contains('dynamic'));
  });

  test('two methods', () {
    final Pigeon dartle = Pigeon.setup();
    final ParseResults results = dartle.parse(<Type>[ApiTwoMethods]);
    expect(results.errors.length, 0);
    expect(results.root.apis.length, 1);
    expect(results.root.apis[0].methods.length, equals(2));
    expect(results.root.apis[0].methods[0].name, equals('method1'));
    expect(results.root.apis[0].methods[1].name, equals('method2'));
  });

  test('nested', () {
    final Pigeon dartle = Pigeon.setup();
    final ParseResults results = dartle.parse(<Type>[Nested, Input1]);
    expect(results.errors.length, equals(0));
    expect(results.root.classes.length, equals(2));
    expect(results.root.classes[0].name, equals('Nested'));
    expect(results.root.classes[0].fields.length, equals(1));
    expect(results.root.classes[0].fields[0].dataType, equals('Input1'));
  });

  test('flutter api', () {
    final Pigeon pigeon = Pigeon.setup();
    final ParseResults results = pigeon.parse(<Type>[AFlutterApi]);
    expect(results.errors.length, equals(0));
    expect(results.root.apis.length, equals(1));
    expect(results.root.apis[0].name, equals('AFlutterApi'));
    expect(results.root.apis[0].location, equals(ApiLocation.flutter));
  });
}
