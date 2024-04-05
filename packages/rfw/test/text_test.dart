// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is hand-formatted.
// ignore_for_file: use_raw_strings, avoid_escaping_inner_quotes

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
    test('1.2', 'Expected symbol "{" but found 1.2 at line 1 column 3.');
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
    test('{ a: -', 'Unexpected end of file after minus sign at line 1 column 6.');
    test('{ a: -a', 'Unexpected character U+0061 ("a") after minus sign (expected digit) at line 1 column 7.');
    test('{ a: 0', 'Expected symbol "}" but found <EOF> at line 1 column 6.');
    test('{ a: 0e', 'Unexpected end of file after exponent separator at line 1 column 7.');
    test('{ a: 0ee', 'Unexpected character U+0065 ("e") after exponent separator at line 1 column 8.');
    test('{ a: 0e-', 'Unexpected end of file after exponent separator and minus sign at line 1 column 8.');
    test('{ a: 0e-e', 'Unexpected character U+0065 ("e") in exponent at line 1 column 9.');
    test('{ a: 0e-f', 'Unexpected character U+0066 ("f") in exponent at line 1 column 9.');
    test('{ a: 0e-.', 'Unexpected character U+002E (".") in exponent at line 1 column 9.');
    test('{ a: 0e- ', 'Unexpected character U+0020 in exponent at line 1 column 9.');
    test('{ a: 0e-0', 'Expected symbol "}" but found <EOF> at line 1 column 9.');
    test('{ a: 0e-0{', 'Expected symbol "}" but found { at line 1 column 10.');
    test('{ a: 0e-0;', 'Expected symbol "}" but found ; at line 1 column 10.');
    test('{ a: 0e-0e', 'Unexpected character U+0065 ("e") in exponent at line 1 column 10.');
    test('{ a: 0 ', 'Expected symbol "}" but found <EOF> at line 1 column 7.');
    test('{ a: 0.', 'Unexpected end of file after decimal point at line 1 column 7.');
    test('{ a: 0.e', 'Unexpected character U+0065 ("e") in fraction component at line 1 column 8.');
    test('{ a: 0. ', 'Unexpected character U+0020 in fraction component at line 1 column 8.');
    test('{ a: 00', 'Expected symbol "}" but found <EOF> at line 1 column 7.');
    test('{ a: 00e', 'Unexpected end of file after exponent separator at line 1 column 8.');
    test('{ a: 00ee', 'Unexpected character U+0065 ("e") after exponent separator at line 1 column 9.');
    test('{ a: 00e-', 'Unexpected end of file after exponent separator and minus sign at line 1 column 9.');
    test('{ a: 00 ', 'Expected symbol "}" but found <EOF> at line 1 column 8.');
    test('{ a: -0', 'Expected symbol "}" but found <EOF> at line 1 column 7.');
    test('{ a: -0.', 'Unexpected end of file after decimal point at line 1 column 8.');
    test('{ a: -0. ', 'Unexpected character U+0020 in fraction component at line 1 column 9.');
    test('{ a: -0.0', 'Expected symbol "}" but found <EOF> at line 1 column 9.');
    test('{ a: -0.0 ', 'Expected symbol "}" but found <EOF> at line 1 column 10.');
    test('{ a: -0.0e', 'Unexpected end of file after exponent separator at line 1 column 10.');
    test('{ a: -0.0ee', 'Unexpected character U+0065 ("e") after exponent separator at line 1 column 11.');
    test('{ a: -0.0e-', 'Unexpected end of file after exponent separator and minus sign at line 1 column 11.');
    test('{ a: -0.0f', 'Unexpected character U+0066 ("f") in fraction component at line 1 column 10.');
    test('{ a: -00', 'Expected symbol "}" but found <EOF> at line 1 column 8.');
    test('{ a: 0f', 'Unexpected character U+0066 ("f") after zero at line 1 column 7.');
    test('{ a: -0f', 'Unexpected character U+0066 ("f") after negative zero at line 1 column 8.');
    test('{ a: 00f', 'Unexpected character U+0066 ("f") at line 1 column 8.');
    test('{ a: -00f', 'Unexpected character U+0066 ("f") at line 1 column 9.');
    test('{ a: test.0', 'Unexpected test at line 1 column 10.');
    test('{ a: test.0 ', 'Unexpected test at line 1 column 10.');
    test('{ a: 0x', 'Unexpected end of file after 0x prefix at line 1 column 7.');
    test('{ a: 0xg', 'Unexpected character U+0067 ("g") after 0x prefix at line 1 column 8.');
    test('{ a: 0xx', 'Unexpected character U+0078 ("x") after 0x prefix at line 1 column 8.');
    test('{ a: 0x}', 'Unexpected character U+007D ("}") after 0x prefix at line 1 column 8.');
    test('{ a: 0x0', 'Expected symbol "}" but found <EOF> at line 1 column 8.');
    test('{ a: 0xff', 'Expected symbol "}" but found <EOF> at line 1 column 9.');
    test('{ a: 0xfg', 'Unexpected character U+0067 ("g") in hex literal at line 1 column 9.');
    test('{ a: ."hello"', 'Unexpected . at line 1 column 7.');
    test('{ a: "hello"."hello"', 'Expected symbol "}" but found . at line 1 column 14.');
    test('{ a: "hello"', 'Expected symbol "}" but found <EOF> at line 1 column 12.');
    test('{ a: "\n"', 'Unexpected end of line inside string at line 2 column 0.');
    test('{ a: "hello\n"', 'Unexpected end of line inside string at line 2 column 0.');
    test('{ a: "\\', 'Unexpected end of file inside string at line 1 column 7.');
    test('{ a: ."hello"', 'Unexpected . at line 1 column 7.');
    test('{ "a": \'hello\'.\'hello\'', 'Expected symbol "}" but found . at line 1 column 16.');
    test('{ "a": \'hello\'', 'Expected symbol "}" but found <EOF> at line 1 column 14.');
    test('{ "a": \'hello\'h', 'Unexpected character U+0068 ("h") after end quote at line 1 column 15.');
    test('{ "a": \'\n\'', 'Unexpected end of line inside string at line 2 column 0.');
    test('{ "a": \'hello\n\'', 'Unexpected end of line inside string at line 2 column 0.');
    test('{ "a": \'\\', 'Unexpected end of file inside string at line 1 column 9.');
    test('{ "a": \'\\\'', 'Unexpected end of file inside string at line 1 column 10.');
    test('{ "a": \'\\u', 'Unexpected end of file inside Unicode escape at line 1 column 10.');
    test('{ "a": \'\\u0', 'Unexpected end of file inside Unicode escape at line 1 column 11.');
    test('{ "a": \'\\u00', 'Unexpected end of file inside Unicode escape at line 1 column 12.');
    test('{ "a": \'\\u000', 'Unexpected end of file inside Unicode escape at line 1 column 13.');
    test('{ "a": \'\\u0000', 'Unexpected end of file inside string at line 1 column 14.');
    test('{ "a": \'\\u|', 'Unexpected character U+007C ("|") in Unicode escape at line 1 column 11.');
    test('{ "a": \'\\u0|', 'Unexpected character U+007C ("|") in Unicode escape at line 1 column 12.');
    test('{ "a": \'\\u00|', 'Unexpected character U+007C ("|") in Unicode escape at line 1 column 13.');
    test('{ "a": \'\\u000|', 'Unexpected character U+007C ("|") in Unicode escape at line 1 column 14.');
    test('{ "a": \'\\u0000|', 'Unexpected end of file inside string at line 1 column 15.');
    test('{ "a": \'\\U263A\' }', 'Unexpected character U+0055 ("U") after backslash in string at line 1 column 10.');
    test('{ "a": "\\', 'Unexpected end of file inside string at line 1 column 9.');
    test('{ "a": "\\"', 'Unexpected end of file inside string at line 1 column 10.');
    test('{ "a": "\\u', 'Unexpected end of file inside Unicode escape at line 1 column 10.');
    test('{ "a": "\\u0', 'Unexpected end of file inside Unicode escape at line 1 column 11.');
    test('{ "a": "\\u00', 'Unexpected end of file inside Unicode escape at line 1 column 12.');
    test('{ "a": "\\u000', 'Unexpected end of file inside Unicode escape at line 1 column 13.');
    test('{ "a": "\\u0000', 'Unexpected end of file inside string at line 1 column 14.');
    test('{ "a": "\\u|', 'Unexpected character U+007C ("|") in Unicode escape at line 1 column 11.');
    test('{ "a": "\\u0|', 'Unexpected character U+007C ("|") in Unicode escape at line 1 column 12.');
    test('{ "a": "\\u00|', 'Unexpected character U+007C ("|") in Unicode escape at line 1 column 13.');
    test('{ "a": "\\u000|', 'Unexpected character U+007C ("|") in Unicode escape at line 1 column 14.');
    test('{ "a": "\\u0000|', 'Unexpected end of file inside string at line 1 column 15.');
    test('{ "a": "\\U263A" }', 'Unexpected character U+0055 ("U") after backslash in string at line 1 column 10.');
    test('{ "a": ', 'Unexpected <EOF> at line 1 column 7.');
    test('{ "a": /', 'Unexpected end of file inside comment delimiter at line 1 column 8.');
    test('{ "a": /.', 'Unexpected character U+002E (".") inside comment delimiter at line 1 column 9.');
    test('{ "a": //', 'Unexpected <EOF> at line 1 column 9.');
    test('{ "a": /*', 'Unexpected end of file in block comment at line 1 column 9.');
    test('{ "a": /*/', 'Unexpected end of file in block comment at line 1 column 10.');
    test('{ "a": /**', 'Unexpected end of file in block comment at line 1 column 10.');
    test('{ "a": /* *', 'Unexpected end of file in block comment at line 1 column 11.');
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
    expect(parseDataFile('{ "a": -0, b: "x" }'), <String, Object?>{ 'a': 0, 'b': 'x' });
    expect(parseDataFile('{ "a": null }'), <String, Object?>{ });
    expect(parseDataFile('{ "a": -6 }'), <String, Object?>{ 'a': -6 });
    expect(parseDataFile('{ "a": -7 }'), <String, Object?>{ 'a': -7 });
    expect(parseDataFile('{ "a": -8 }'), <String, Object?>{ 'a': -8 });
    expect(parseDataFile('{ "a": -9 }'), <String, Object?>{ 'a': -9 });
    expect(parseDataFile('{ "a": 01 }'), <String, Object?>{ 'a': 1 });
    expect(parseDataFile('{ "a": 0e0 }'), <String, Object?>{ 'a': 0.0 });
    expect(parseDataFile('{ "a": 0e1 }'), <String, Object?>{ 'a': 0.0 });
    expect(parseDataFile('{ "a": 0e8 }'), <String, Object?>{ 'a': 0.0 });
    expect(parseDataFile('{ "a": 1e9 }'), <String, Object?>{ 'a': 1000000000.0 });
    expect(parseDataFile('{ "a": -0e1 }'), <String, Object?>{ 'a': 0.0 });
    expect(parseDataFile('{ "a": 00e1 }'), <String, Object?>{ 'a': 0.0 });
    expect(parseDataFile('{ "a": -00e1 }'), <String, Object?>{ 'a': 0.0 });
    expect(parseDataFile('{ "a": 00.0e1 }'), <String, Object?>{ 'a': 0.0 });
    expect(parseDataFile('{ "a": -00.0e1 }'), <String, Object?>{ 'a': 0.0 });
    expect(parseDataFile('{ "a": -00.0e-1 }'), <String, Object?>{ 'a': 0.0 });
    expect(parseDataFile('{ "a": -1e-1 }'), <String, Object?>{ 'a': -0.1 });
    expect(parseDataFile('{ "a": -1e-2 }'), <String, Object?>{ 'a': -0.01 });
    expect(parseDataFile('{ "a": -1e-3 }'), <String, Object?>{ 'a': -0.001 });
    expect(parseDataFile('{ "a": -1e-4 }'), <String, Object?>{ 'a': -0.0001 });
    expect(parseDataFile('{ "a": -1e-5 }'), <String, Object?>{ 'a': -0.00001 });
    expect(parseDataFile('{ "a": -1e-6 }'), <String, Object?>{ 'a': -0.000001 });
    expect(parseDataFile('{ "a": -1e-7 }'), <String, Object?>{ 'a': -0.0000001 });
    expect(parseDataFile('{ "a": -1e-8 }'), <String, Object?>{ 'a': -0.00000001 });
    expect(parseDataFile('{ "a": -1e-9 }'), <String, Object?>{ 'a': -0.000000001 });
    expect(parseDataFile('{ "a": -1e-10 }'), <String, Object?>{ 'a': -0.0000000001 });
    expect(parseDataFile('{ "a": -1e-11 }'), <String, Object?>{ 'a': -0.00000000001 });
    expect(parseDataFile('{ "a": -1e-12 }'), <String, Object?>{ 'a': -0.000000000001 });
    expect(parseDataFile('{ "a": -1e-13 }'), <String, Object?>{ 'a': -0.0000000000001 });
    expect(parseDataFile('{ "a": -1e-14 }'), <String, Object?>{ 'a': -0.00000000000001 });
    expect(parseDataFile('{ "a": -1e-15 }'), <String, Object?>{ 'a': -0.000000000000001 });
    expect(parseDataFile('{ "a": -1e-16 }'), <String, Object?>{ 'a': -0.0000000000000001 });
    expect(parseDataFile('{ "a": -1e-17 }'), <String, Object?>{ 'a': -0.00000000000000001 });
    expect(parseDataFile('{ "a": -1e-18 }'), <String, Object?>{ 'a': -0.000000000000000001 });
    expect(parseDataFile('{ "a": -1e-19 }'), <String, Object?>{ 'a': -0.0000000000000000001 });
    expect(parseDataFile('{ "a": 0x0 }'), <String, Object?>{ 'a': 0 });
    expect(parseDataFile('{ "a": 0x1 }'), <String, Object?>{ 'a': 1 });
    expect(parseDataFile('{ "a": 0x01 }'), <String, Object?>{ 'a': 1 });
    expect(parseDataFile('{ "a": 0xa }'), <String, Object?>{ 'a': 10 });
    expect(parseDataFile('{ "a": 0xb }'), <String, Object?>{ 'a': 11 });
    expect(parseDataFile('{ "a": 0xc }'), <String, Object?>{ 'a': 12 });
    expect(parseDataFile('{ "a": 0xd }'), <String, Object?>{ 'a': 13 });
    expect(parseDataFile('{ "a": 0xe }'), <String, Object?>{ 'a': 14 });
    expect(parseDataFile('{ "a": 0xfa }'), <String, Object?>{ 'a': 250 });
    expect(parseDataFile('{ "a": 0xfb }'), <String, Object?>{ 'a': 251 });
    expect(parseDataFile('{ "a": 0xfc }'), <String, Object?>{ 'a': 252 });
    expect(parseDataFile('{ "a": 0xfd }'), <String, Object?>{ 'a': 253 });
    expect(parseDataFile('{ "a": 0xfe }'), <String, Object?>{ 'a': 254 });
    expect(parseDataFile('{ "a": "\\"\\/\\\'\\b\\f\\n\\r\\t\\\\" }'), <String, Object?>{ 'a': '\x22\x2F\x27\x08\x0C\x0A\x0D\x09\x5C' });
    expect(parseDataFile('{ "a": \'\\"\\/\\\'\\b\\f\\n\\r\\t\\\\\' }'), <String, Object?>{ 'a': '\x22\x2F\x27\x08\x0C\x0A\x0D\x09\x5C' });
    expect(parseDataFile('{ "a": \'\\u263A\' }'), <String, Object?>{ 'a': '☺' });
    expect(parseDataFile('{ "a": \'\\u0000\' }'), <String, Object?>{ 'a': '\x00' });
    expect(parseDataFile('{ "a": \'\\u1111\' }'), <String, Object?>{ 'a': 'ᄑ' });
    expect(parseDataFile('{ "a": \'\\u2222\' }'), <String, Object?>{ 'a': '∢' });
    expect(parseDataFile('{ "a": \'\\u3333\' }'), <String, Object?>{ 'a': '㌳' });
    expect(parseDataFile('{ "a": \'\\u4444\' }'), <String, Object?>{ 'a': '䑄' });
    expect(parseDataFile('{ "a": \'\\u5555\' }'), <String, Object?>{ 'a': '啕' });
    expect(parseDataFile('{ "a": \'\\u6666\' }'), <String, Object?>{ 'a': '晦' });
    expect(parseDataFile('{ "a": \'\\u7777\' }'), <String, Object?>{ 'a': '睷' });
    expect(parseDataFile('{ "a": \'\\u8888\' }'), <String, Object?>{ 'a': '袈' });
    expect(parseDataFile('{ "a": \'\\u9999\' }'), <String, Object?>{ 'a': '香' });
    expect(parseDataFile('{ "a": \'\\uaaaa\' }'), <String, Object?>{ 'a': 'ꪪ' });
    expect(parseDataFile('{ "a": \'\\ubbbb\' }'), <String, Object?>{ 'a': '뮻' });
    expect(parseDataFile('{ "a": \'\\ucccc\' }'), <String, Object?>{ 'a': '쳌' });
    expect(parseDataFile('{ "a": \'\\udddd\' }'), <String, Object?>{ 'a': '\u{dddd}' }); // low surragate
    expect(parseDataFile('{ "a": \'\\ueeee\' }'), <String, Object?>{ 'a': '\u{eeee}' }); // private use area
    expect(parseDataFile('{ "a": \'\\uffff\' }'), <String, Object?>{ 'a': '\u{ffff}' }); // not technically a valid Unicode character
    expect(parseDataFile('{ "a": \'\\uAAAA\' }'), <String, Object?>{ 'a': 'ꪪ' });
    expect(parseDataFile('{ "a": \'\\uBBBB\' }'), <String, Object?>{ 'a': '뮻' });
    expect(parseDataFile('{ "a": \'\\uCCCC\' }'), <String, Object?>{ 'a': '쳌' });
    expect(parseDataFile('{ "a": \'\\uDDDD\' }'), <String, Object?>{ 'a': '\u{dddd}' });
    expect(parseDataFile('{ "a": \'\\uEEEE\' }'), <String, Object?>{ 'a': '\u{eeee}' });
    expect(parseDataFile('{ "a": \'\\uFFFF\' }'), <String, Object?>{ 'a': '\u{ffff}' });
    expect(parseDataFile('{ "a": /**/ "1" }'), <String, Object?>{ 'a': '1' });
    expect(parseDataFile('{ "a": /* */ "1" }'), <String, Object?>{ 'a': '1' });
    expect(parseDataFile('{ "a": /*\n*/ "1" }'), <String, Object?>{ 'a': '1' });
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
    test('import foo."', 'Unexpected end of file inside string at line 1 column 12.');
    test('import foo. "', 'Unexpected end of file inside string at line 1 column 13.');
    test('import foo.\'', 'Unexpected end of file inside string at line 1 column 12.');
    test('import foo. \'', 'Unexpected end of file inside string at line 1 column 13.');
    test('widget a = b(c: [ ...for args in []: "e" ]);', 'args is a reserved word at line 1 column 30.');
    test('widget a = switch 0 { 0: a(), 0: b() };', 'Switch has duplicate cases for key 0 at line 1 column 32.');
    test('widget a = switch 0 { default: a(), default: b() };', 'Switch has multiple default cases at line 1 column 44.');
    test('widget a = b(c: args)', 'Expected symbol "." but found ) at line 1 column 21.');
    test('widget a = b(c: args.=)', 'Unexpected = at line 1 column 22.');
    test('widget a = b(c: args.0', 'Expected symbol ")" but found <EOF> at line 1 column 22.');
    test('widget a = b(c: args.0 ', 'Expected symbol ")" but found <EOF> at line 1 column 23.');
    test('widget a = b(c: args.0)', 'Expected symbol ";" but found <EOF> at line 1 column 23.');
    test('widget a = b(c: args.0f', 'Unexpected character U+0066 ("f") in integer at line 1 column 23.');
    test('widget a = b(c: [ ..', 'Unexpected end of file inside "..." symbol at line 1 column 20.');
    test('widget a = b(c: [ .. ]);', 'Unexpected character U+0020 inside "..." symbol at line 1 column 21.');
    test('widget a = b(c: [ ... ]);', 'Expected identifier but found ] at line 1 column 23.');
    test('widget a = b(c: [ ...baa ]);', 'Expected for but found baa at line 1 column 25.');
    test('widget a = 0;', 'Expected identifier but found 0 at line 1 column 13.');
    test('widget a = a.', 'Expected symbol "(" but found . at line 1 column 13.');
    test('widget a = a. ', 'Expected symbol "(" but found . at line 1 column 14.');
    test('widget a = a.0', 'Expected symbol "(" but found . at line 1 column 14.');
    test('widget a = a.0 ', 'Expected symbol "(" but found . at line 1 column 14.');
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
    expect(parseLibraryFile('widget a = b(c:data.11234567890."e");').toString(), 'widget a = b({c: data.11234567890.e});');
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
    expect(parseLibraryFile('widget a = b(c:args.foo.12);').toString(), 'widget a = b({c: args.foo.12});');
    expect(parseLibraryFile('widget a = b(c:data.foo.12);').toString(), 'widget a = b({c: data.foo.12});');
    expect(parseLibraryFile('widget a = b(c:state.foo.12);').toString(), 'widget a = b({c: state.foo.12});');
    expect(parseLibraryFile('widget a = b(c: [...for d in []: d.12]);').toString(), 'widget a = b({c: [...for loop in []: loop0.12]});');
    expect(parseLibraryFile('widget a = b(c:args.foo.98);').toString(), 'widget a = b({c: args.foo.98});');
    expect(parseLibraryFile('widget a = b(c:data.foo.98);').toString(), 'widget a = b({c: data.foo.98});');
    expect(parseLibraryFile('widget a = b(c:state.foo.98);').toString(), 'widget a = b({c: state.foo.98});');
    expect(parseLibraryFile('widget a = b(c: [...for d in []: d.98]);').toString(), 'widget a = b({c: [...for loop in []: loop0.98]});');
    expect(parseLibraryFile('widget a = b(c:args.foo.000);').toString(), 'widget a = b({c: args.foo.0});');
    expect(parseLibraryFile('widget a = b(c:data.foo.000);').toString(), 'widget a = b({c: data.foo.0});');
    expect(parseLibraryFile('widget a = b(c:state.foo.000);').toString(), 'widget a = b({c: state.foo.0});');
    expect(parseLibraryFile('widget a = b(c: [...for d in []: d.000]);').toString(), 'widget a = b({c: [...for loop in []: loop0.0]});');
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

  testWidgets('parseLibraryFile: widgetBuilders work', (WidgetTester tester) async {
    final RemoteWidgetLibrary libraryFile = parseLibraryFile('''
      widget a = Builder(builder: (scope) => Container());
    ''');
    expect(libraryFile.toString(), 'widget a = Builder({builder: (scope) => Container({})});');
  });

  testWidgets('parseLibraryFile: widgetBuilders work with arguments', (WidgetTester tester) async {
    final RemoteWidgetLibrary libraryFile = parseLibraryFile('''
      widget a = Builder(builder: (scope) => Container(width: scope.width));
    ''');
    expect(libraryFile.toString(), 'widget a = Builder({builder: (scope) => Container({width: scope.width})});');
  });

    testWidgets('parseLibraryFile: widgetBuilder arguments are lexical scoped', (WidgetTester tester) async {
    final RemoteWidgetLibrary libraryFile = parseLibraryFile('''
      widget a = A(
        a: (s1) => B(
          b: (s2) => T(s1: s1.s1, s2: s2.s2),
        ),
      );
    ''');
    expect(libraryFile.toString(), 'widget a = A({a: (s1) => B({b: (s2) => T({s1: s1.s1, s2: s2.s2})})});');
  });

  testWidgets('parseLibraryFile: widgetBuilder arguments can be shadowed', (WidgetTester tester) async {
    final RemoteWidgetLibrary libraryFile = parseLibraryFile('''
      widget a = A(
        a: (s1) => B(
          b: (s1) => T(t: s1.foo),
        ),
      );
    ''');
    expect(libraryFile.toString(), 'widget a = A({a: (s1) => B({b: (s1) => T({t: s1.foo})})});');
  });

  testWidgets('parseLibraryFile: widgetBuilders check the returned value', (WidgetTester tester) async {
    void test(String input, String expectedMessage) {
      try {
        parseLibraryFile(input);
        fail('parsing `$input` did not result in an error (expected "$expectedMessage").');
      } on ParserException catch (e) {
        expect('$e', expectedMessage);
      }
    }

    const String expectedErrorMessage =
      'Expecting a switch or constructor call got 1 at line 1 column 27.';
    test('widget a = B(b: (foo) => 1);', expectedErrorMessage);
  });

  testWidgets('parseLibraryFile: widgetBuilders check reserved words', (WidgetTester tester) async {
    void test(String input, String expectedMessage) {
      try {
        parseLibraryFile(input);
        fail('parsing `$input` did not result in an error (expected "$expectedMessage").');
      } on ParserException catch (e) {
        expect('$e', expectedMessage);
      }
    }

    const String expectedErrorMessage =
      'args is a reserved word at line 1 column 34.';
    test('widget a = Builder(builder: (args) => Container(width: args.width));', expectedErrorMessage);
  });

  testWidgets('parseLibraryFile: widgetBuilders check reserved words', (WidgetTester tester) async {
   void test(String input, String expectedMessage) {
      try {
        parseDataFile(input);
        fail('parsing `$input` did not result in an error (expected "$expectedMessage").');
      } on ParserException catch (e) {
        expect('$e', expectedMessage);
      }
    }

   const String expectedErrorMessage =
     'Expected symbol "{" but found widget at line 1 column 7.';
   test('widget a = Builder(builder: (args) => Container(width: args.width));', expectedErrorMessage);
  });

  testWidgets('parseLibraryFile: switch works with widgetBuilders', (WidgetTester tester) async {
    final RemoteWidgetLibrary libraryFile = parseLibraryFile('''
      widget a = A(
        b: switch args.down {
          true: (foo) => B(),
          false: (bar) => C(),
        }
      );
    ''');
    expect(libraryFile.toString(), 'widget a = A({b: switch args.down {true: (foo) => B({}), false: (bar) => C({})}});');
  });

  testWidgets('parseLibraryFile: widgetBuilders work with switch', (WidgetTester tester) async {
    final RemoteWidgetLibrary libraryFile = parseLibraryFile('''
      widget a = A(
        b: (foo) => switch foo.letter {
          'a': A(),
          'b': B(),
        },
      );
    ''');
    expect(libraryFile.toString(), 'widget a = A({b: (foo) => switch foo.letter {a: A({}), b: B({})}});');
  });

  testWidgets('parseLibraryFile: widgetBuilders work with lists', (WidgetTester tester) async {
    final RemoteWidgetLibrary libraryFile = parseLibraryFile('''
      widget a = A(
        b: (s1) => B(c: [s1.c]),
      );
    ''');
    expect(libraryFile.toString(), 'widget a = A({b: (s1) => B({c: [s1.c]})});' );
  });

  testWidgets('parseLibraryFile: widgetBuilders work with maps', (WidgetTester tester) async {
    final RemoteWidgetLibrary libraryFile = parseLibraryFile('''
      widget a = A(
        b: (s1) => B(c: {d: s1.d}),
      );
    ''');
    expect(libraryFile.toString(), 'widget a = A({b: (s1) => B({c: {d: s1.d}})});');
  });

  testWidgets('parseLibraryFile: widgetBuilders work with setters', (WidgetTester tester) async {
    final RemoteWidgetLibrary libraryFile = parseLibraryFile('''
      widget a {foo: 0} = A(
        b: (s1) => B(onTap: set state.foo = s1.foo),
      );
    ''');
    expect(libraryFile.toString(), 'widget a = A({b: (s1) => B({onTap: set state.foo = s1.foo})});');
  });

  testWidgets('parseLibraryFile: widgetBuilders work with events', (WidgetTester tester) async {
    final RemoteWidgetLibrary libraryFile = parseLibraryFile('''
      widget a {foo: 0} = A(
        b: (s1) => B(onTap: event "foo" {result: s1.result})
      );
    ''');
    expect(libraryFile.toString(), 'widget a = A({b: (s1) => B({onTap: event foo {result: s1.result}})});');
  });
}
