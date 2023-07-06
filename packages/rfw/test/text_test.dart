// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is hand-formatted.

import 'package:flutter_test/flutter_test.dart';
import 'package:rfw/formats.dart';

void main() {
  testWidgets('empty parseDataFile', (WidgetTester tester) async {
    final DynamicMap result = parseDataFile('{}');
    expect(result, <String, Object?>{ });
  });

  testWidgets('empty parseLibraryFile', (WidgetTester tester) async {
    final RemoteWidgetLibrary result = parseLibraryFile('');
    expect(result.imports, isEmpty);
    expect(result.widgets, isEmpty);
  });

  testWidgets('space parseDataFile', (WidgetTester tester) async {
    final DynamicMap result = parseDataFile(' \n {} \n ');
    expect(result, <String, Object?>{ });
  });

  testWidgets('space parseLibraryFile', (WidgetTester tester) async {
    final RemoteWidgetLibrary result = parseLibraryFile(' \n ');
    expect(result.imports, isEmpty);
    expect(result.widgets, isEmpty);
  });

  testWidgets('error handling in parseDataFile', (WidgetTester tester) async {
    void test(String input, String expectedMessage) {
      try {
        parseDataFile(input);
        fail('parsing `$input` did not result in an error (expected "$expectedMessage").');
      } on ParserException catch (e) {
        expect('$e', expectedMessage);
      }
    }
    test('', 'Expected symbol "{" but found <EOF> at line 1 column 0.');
    test('}', 'Expected symbol "{" but found } at line 1 column 1.');
    test('1', 'Expected symbol "{" but found 1 at line 1 column 1.');
    test('1.0', 'Expected symbol "{" but found 1.0 at line 1 column 3.');
    test('a', 'Expected symbol "{" but found a at line 1 column 1.');
    test('"a"', 'Expected symbol "{" but found "a" at line 1 column 3.');
    test('&', 'Unexpected character U+0026 ("&") at line 1 column 1.');
    test('\t', 'Unexpected character U+0009 at line 1 column 1.');
    test('{ a: 0, a: 0 }', 'Duplicate key "a" in map at line 1 column 10.');
    test('{ a: 0; }', 'Expected symbol "}" but found ; at line 1 column 7.');
    test('{ a: [ 0 ; ] }', 'Expected comma but found ; at line 1 column 10.');
    test('{ } x', 'Expected end of file but found x at line 1 column 5.');
    test('{ a: a }', 'Unexpected a at line 1 column 7.');
    test('{ ... }', 'Expected symbol "}" but found … at line 1 column 5.');
    test('{ a: ... }', 'Unexpected … at line 1 column 8.');
  });

  testWidgets('valid values in parseDataFile', (WidgetTester tester) async {
    expect(parseDataFile('{ }\n\n  \n\n'), <String, Object?>{ });
    expect(parseDataFile('{ a: "b" }'), <String, Object?>{ 'a': 'b' });
    expect(parseDataFile('{ a: [ "b", 9 ] }'), <String, Object?>{ 'a': <Object?>[ 'b', 9 ] });
    expect(parseDataFile('{ a: { } }'), <String, Object?>{ 'a': <String, Object?>{ } });
    expect(parseDataFile('{ a: 123.456e7 }'), <String, Object?>{ 'a': 123.456e7 });
    expect(parseDataFile('{ a: true }'), <String, Object?>{ 'a': true });
    expect(parseDataFile('{ a: false }'), <String, Object?>{ 'a': false });
    expect(parseDataFile('{ "a": 0 }'), <String, Object?>{ 'a': 0 });
    expect(parseDataFile('{ "a": null }'), <String, Object?>{ });
  });

  testWidgets('error handling in parseLibraryFile', (WidgetTester tester) async {
    void test(String input, String expectedMessage) {
      try {
        parseLibraryFile(input);
        fail('parsing `$input` did not result in an error (expected "$expectedMessage").');
      } on ParserException catch (e) {
        expect('$e', expectedMessage);
      }
    }
    test('2', 'Expected keywords "import" or "widget", or end of file but found 2 at line 1 column 1.');
    test('impor', 'Expected keywords "import" or "widget", or end of file but found impor at line 1 column 5.');
    test('import', 'Expected string but found <EOF> at line 1 column 6.');
    test('import 2', 'Expected string but found 2 at line 1 column 8.');
    test('import foo', 'Expected symbol ";" but found <EOF> at line 1 column 10.');
    test('import foo.', 'Expected string but found <EOF> at line 1 column 11.');
    test('import foo,', 'Expected symbol ";" but found , at line 1 column 11.');
    test('import foo+', 'Unexpected character U+002B ("+") inside identifier at line 1 column 11.');
    test('import foo.1', 'Expected string but found 1 at line 1 column 12.');
    test('import foo.+', 'Unexpected character U+002B ("+") after period at line 1 column 12.');
    test('widget a = b(c: [ ...for args in []: "e" ]);', 'args is a reserved word at line 1 column 30.');
    test('widget a = switch 0 { 0: a(), 0: b() };', 'Switch has duplicate cases for key 0 at line 1 column 32.');
    test('widget a = switch 0 { default: a(), default: b() };', 'Switch has multiple default cases at line 1 column 44.');
    test('widget a = b(c: args)', 'Expected symbol "." but found ) at line 1 column 21.');
    test('widget a = b(c: args.=)', 'Unexpected = at line 1 column 22.');
    test('widget a = b(c: [ ... ]);', 'Expected identifier but found ] at line 1 column 23.');
    test('widget a = b(c: [ ...baa ]);', 'Expected for but found baa at line 1 column 25.');
    test('widget a = 0;', 'Expected identifier but found 0 at line 1 column 13.');
  });

  testWidgets('parseLibraryFile: imports', (WidgetTester tester) async {
    final RemoteWidgetLibrary result = parseLibraryFile('import foo.bar;');
    expect(result.imports, hasLength(1));
    expect(result.imports.single.toString(), 'import foo.bar;');
    expect(result.widgets, isEmpty);
  });

  testWidgets('parseLibraryFile: loops', (WidgetTester tester) async {
    final RemoteWidgetLibrary result = parseLibraryFile('widget a = b(c: [ ...for d in []: "e" ]);');
    expect(result.imports, isEmpty);
    expect(result.widgets, hasLength(1));
    expect(result.widgets.single.toString(), 'widget a = b({c: [...for loop in []: e]});');
  });

  testWidgets('parseLibraryFile: switch', (WidgetTester tester) async {
    expect(parseLibraryFile('widget a = switch 0 { 0: a() };').toString(), 'widget a = switch 0 {0: a({})};');
    expect(parseLibraryFile('widget a = switch 0 { default: a() };').toString(), 'widget a = switch 0 {null: a({})};');
    expect(parseLibraryFile('widget a = b(c: switch 1 { 2: 3 });').toString(), 'widget a = b({c: switch 1 {2: 3}});');
  });

  testWidgets('parseLibraryFile: references', (WidgetTester tester) async {
    expect(parseLibraryFile('widget a = b(c: [...for d in []: d]);').toString(), 'widget a = b({c: [...for loop in []: loop0.]});');
    expect(parseLibraryFile('widget a = b(c:args.foo.bar);').toString(), 'widget a = b({c: args.foo.bar});');
    expect(parseLibraryFile('widget a = b(c:data.foo.bar);').toString(), 'widget a = b({c: data.foo.bar});');
    expect(parseLibraryFile('widget a = b(c:state.foo.bar);').toString(), 'widget a = b({c: state.foo.bar});');
    expect(parseLibraryFile('widget a = b(c: [...for d in []: d.bar]);').toString(), 'widget a = b({c: [...for loop in []: loop0.bar]});');
    expect(parseLibraryFile('widget a = b(c:args.foo."bar");').toString(), 'widget a = b({c: args.foo.bar});');
    expect(parseLibraryFile('widget a = b(c:data.foo."bar");').toString(), 'widget a = b({c: data.foo.bar});');
    expect(parseLibraryFile('widget a = b(c:state.foo."bar");').toString(), 'widget a = b({c: state.foo.bar});');
    expect(parseLibraryFile('widget a = b(c: [...for d in []: d."bar"]);').toString(), 'widget a = b({c: [...for loop in []: loop0.bar]});');
    expect(parseLibraryFile('widget a = b(c:args.foo.9);').toString(), 'widget a = b({c: args.foo.9});');
    expect(parseLibraryFile('widget a = b(c:data.foo.9);').toString(), 'widget a = b({c: data.foo.9});');
    expect(parseLibraryFile('widget a = b(c:state.foo.9);').toString(), 'widget a = b({c: state.foo.9});');
    expect(parseLibraryFile('widget a = b(c: [...for d in []: d.9]);').toString(), 'widget a = b({c: [...for loop in []: loop0.9]});');
  });

  testWidgets('parseLibraryFile: event handlers', (WidgetTester tester) async {
    expect(parseLibraryFile('widget a = b(c: event "d" { });').toString(), 'widget a = b({c: event d {}});');
    expect(parseLibraryFile('widget a = b(c: set state.d = 0);').toString(), 'widget a = b({c: set state.d = 0});');
  });

  testWidgets('parseLibraryFile: stateful widgets', (WidgetTester tester) async {
    expect(parseLibraryFile('widget a {} = c();').toString(), 'widget a = c({});');
    expect(parseLibraryFile('widget a {b: 0} = c();').toString(), 'widget a = c({});');
    final RemoteWidgetLibrary result = parseLibraryFile('widget a {b: 0} = c();');
    expect(result.widgets.single.initialState, <String, Object?>{'b': 0});
  });
}
