// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is hand-formatted.

import 'package:flutter_test/flutter_test.dart';
import 'package:rfw/formats.dart';

void main() {
  testWidgets('$LibraryName', (WidgetTester tester) async {
    T deconst<T>(T value) => value;
    final LibraryName a = LibraryName(<String>['core', deconst<String>('widgets')]);
    final LibraryName b = LibraryName(<String>['core', deconst<String>('widgets')]);
    final LibraryName c = LibraryName(<String>['core', deconst<String>('material')]);
    const LibraryName d = LibraryName(<String>['core']);
    expect('$a', 'core.widgets');
    expect('$c', 'core.material');
    expect(a, equals(b));
    expect(a.hashCode, equals(b.hashCode));
    expect(a, isNot(equals(c)));
    expect(a.hashCode, isNot(equals(c.hashCode)));
    expect(a.compareTo(b), 0);
    expect(b.compareTo(a), 0);
    expect(a.compareTo(c), 1);
    expect(c.compareTo(a), -1);
    expect(b.compareTo(c), 1);
    expect(c.compareTo(b), -1);
    expect(a.compareTo(d), 1);
    expect(b.compareTo(d), 1);
    expect(c.compareTo(d), 1);
    expect(d.compareTo(a), -1);
    expect(d.compareTo(b), -1);
    expect(d.compareTo(c), -1);
  });

  testWidgets('$FullyQualifiedWidgetName', (WidgetTester tester) async {
    const FullyQualifiedWidgetName aa = FullyQualifiedWidgetName(LibraryName(<String>['a']), 'a');
    const FullyQualifiedWidgetName ab = FullyQualifiedWidgetName(LibraryName(<String>['a']), 'b');
    const FullyQualifiedWidgetName bb = FullyQualifiedWidgetName(LibraryName(<String>['b']), 'b');
    expect('$aa', 'a:a');
    expect(aa, isNot(equals(bb)));
    expect(aa.hashCode, isNot(equals(bb.hashCode)));
    expect(aa.compareTo(aa), 0);
    expect(aa.compareTo(ab), -1);
    expect(aa.compareTo(bb), -1);
    expect(ab.compareTo(aa), 1);
    expect(ab.compareTo(ab), 0);
    expect(ab.compareTo(bb), -1);
    expect(bb.compareTo(aa), 1);
    expect(bb.compareTo(ab), 1);
    expect(bb.compareTo(bb), 0);
  });

  testWidgets('toStrings', (WidgetTester tester) async {
    expect('$missing', '<missing>');
    expect('${const Loop(0, 1)}', '...for loop in 0: 1');
    expect('${const Switch(0, <Object?, Object>{1: 2})}', 'switch 0 {1: 2}');
    expect('${const ConstructorCall("a", <String, Object>{})}', 'a({})');
    expect('${const ArgsReference(<Object>["a"])}', 'args.a');
    expect('${const BoundArgsReference(false, <Object>["a"])}', 'args(false).a');
    expect('${const DataReference(<Object>["a"])}', 'data.a');
    expect('${const LoopReference(0, <Object>["a"])}', 'loop0.a');
    expect('${const BoundLoopReference(0, <Object>["a"])}', 'loop(0).a');
    expect('${const StateReference(<Object>["a"])}', 'state.a');
    expect('${const BoundStateReference(0, <Object>["a"])}', 'state^0.a');
    expect('${const EventHandler("a", <String, Object?>{})}', 'event a {}');
    expect('${const SetStateHandler(StateReference(<Object>["a"]), false)}', 'set state.a = false');
    expect('${const Import(LibraryName(<String>["a"]))}', 'import a;');
    expect('${const WidgetDeclaration("a", null, ConstructorCall("b", <String, Object>{}))}', 'widget a = b({});');
    expect('${const WidgetDeclaration("a", <String, Object?>{ "x": false }, ConstructorCall("b", <String, Object>{}))}', 'widget a = b({});');
    expect('${const RemoteWidgetLibrary(<Import>[Import(LibraryName(<String>["a"]))], <WidgetDeclaration>[WidgetDeclaration("a", null, ConstructorCall("b", <String, Object>{}))])}', 'import a;\nwidget a = b({});');
  });

  testWidgets('$BoundArgsReference', (WidgetTester tester) async {
    final Object target = Object();
    final BoundArgsReference result = const ArgsReference(<Object>[0]).bind(target);
    expect(result.arguments, target);
    expect(result.parts, const <Object>[0]);
  });

  testWidgets('$DataReference', (WidgetTester tester) async {
    final DataReference result = const DataReference(<Object>[0]).constructReference(<Object>[1]);
    expect(result.parts, const <Object>[0, 1]);
  });

  testWidgets('$LoopReference', (WidgetTester tester) async {
    final LoopReference result = const LoopReference(9, <Object>[0]).constructReference(<Object>[1]);
    expect(result.parts, const <Object>[0, 1]);
  });

  testWidgets('$BoundLoopReference', (WidgetTester tester) async {
    final Object target = Object();
    final BoundLoopReference result = const LoopReference(9, <Object>[0]).bind(target).constructReference(<Object>[1]);
    expect(result.value, target);
    expect(result.parts, const <Object>[0, 1]);
  });

  testWidgets('$BoundStateReference', (WidgetTester tester) async {
    final BoundStateReference result = const StateReference(<Object>[0]).bind(9).constructReference(<Object>[1]);
    expect(result.depth, 9);
    expect(result.parts, const <Object>[0, 1]);
  });

  testWidgets('$SourceLocation comparison', (WidgetTester tester) async {
    const SourceLocation test1 = SourceLocation('test', 123);
    const SourceLocation test2 = SourceLocation('test', 234);
    expect(test1.compareTo(test2), lessThan(0));
    // test1 vs test1
    expect(test1 == test1, isTrue);
    expect(test1 < test1, isFalse);
    expect(test1 <= test1, isTrue);
    expect(test1 > test1, isFalse);
    expect(test1 >= test1, isTrue);
    // test1 vs test2
    expect(test1 == test2, isFalse);
    expect(test1 < test2, isTrue);
    expect(test1 <= test2, isTrue);
    expect(test1 > test2, isFalse);
    expect(test1 >= test2, isFalse);
    // test2 vs test1
    expect(test2 == test1, isFalse);
    expect(test2 < test1, isFalse);
    expect(test2 <= test1, isFalse);
    expect(test2 > test1, isTrue);
    expect(test2 >= test1, isTrue);
    // map
    final Map<SourceLocation, SourceLocation> map = <SourceLocation, SourceLocation>{
      test1: test1,
      test2: test2,
    };
    expect(map[test1], test1);
    expect(map[test2], test2);
  });

  testWidgets('$SourceLocation with non-matching sources', (WidgetTester tester) async {
    const SourceLocation test1 = SourceLocation('test1', 123);
    const SourceLocation test2 = SourceLocation('test2', 234);
    expect(() => test1.compareTo(test2), throwsA(anything));
    expect(() => test1 < test2, throwsA(anything));
    expect(() => test1 <= test2, throwsA(anything));
    expect(() => test1 > test2, throwsA(anything));
    expect(() => test1 >= test2, throwsA(anything));
  });

  testWidgets('$SourceLocation toString', (WidgetTester tester) async {
    const SourceLocation test = SourceLocation('test1', 123);
    expect('$test', 'test1@123');
  });

  testWidgets('$SourceRange', (WidgetTester tester) async {
    const SourceLocation a = SourceLocation('test', 123);
    const SourceLocation b = SourceLocation('test', 124);
    const SourceLocation c = SourceLocation('test', 125);
    final SourceRange range1 = SourceRange(a, b);
    final SourceRange range2 = SourceRange(b, c);
    // toString
    expect('$range1', 'test@123..124');
    // equality
    expect(range1 == range1, isTrue);
    expect(range1 == range2, isFalse);
    expect(range2 == range1, isFalse);
    // map
    final Map<SourceRange, SourceRange> map = <SourceRange, SourceRange>{
      range1: range1,
      range2: range2,
    };
    expect(map[range1], range1);
    expect(map[range2], range2);
  });
}
