// ignore_for_file: avoid_relative_lib_imports

import 'dart:async';

import 'package:test/test.dart';

import '../example/lib/main.dart' as example_app;
import '../example/lib/readme_excerpts.dart' as readme_excerpts;

Future<List<String>> _capturePrints(FutureOr<void> Function() body) async {
  final output = <String>[];
  await runZoned(
    () async => body(),
    zoneSpecification: ZoneSpecification(
      print: (
        Zone self,
        ZoneDelegate parent,
        Zone zone,
        String line,
      ) {
        output.add(line);
      },
    ),
  );
  return output;
}

void main() {
  group('Example app', () {
    test('main runs and prints the documented sections', () async {
      final List<String> output = await _capturePrints(example_app.main);

      expect(output, hasLength(6));
      expect(output[0], equals('=== Basic Template ==='));
      expect(output[1], allOf(contains('Lowe, Greg'), contains('Johnson, Bob')));
      expect(output[2], equals('=== Nested Paths ==='));
      expect(output[3], equals('Greg Lowe'));
      expect(output[4], equals('=== Lambdas ==='));
      expect(output[5], equals('HELLO'));
    });
  });

  group('README excerpts', () {
    test('example usage renders both names', () async {
      final List<String> output = await _capturePrints(readme_excerpts.main);

      expect(output, hasLength(1));
      expect(output.single, allOf(contains('Lowe, Greg'), contains('Johnson, Bob')));
    });

    test('nested paths example renders the nested value', () async {
      final List<String> output = await _capturePrints(
        readme_excerpts.nestedPathsExample,
      );

      expect(output, equals(<String>['Greg Lowe']));
    });

    test('partials example renders the partial output', () async {
      final List<String> output = await _capturePrints(
        readme_excerpts.partialsExample,
      );

      expect(output, equals(<String>['bar']));
    });

    test('simple lambda example renders the replacement text', () async {
      final List<String> output = await _capturePrints(
        readme_excerpts.lambdaSimpleExample,
      );

      expect(output, equals(<String>['bar']));
    });

    test('lambda block example renders the alternate text', () async {
      final List<String> output = await _capturePrints(
        readme_excerpts.lambdaShownExample,
      );

      expect(output, equals(<String>['shown']));
    });

    test('lambda render example uppercases the section body', () async {
      final List<String> output = await _capturePrints(
        readme_excerpts.lambdaRenderExample,
      );

      expect(output, equals(<String>['<b>OI</b>']));
    });

    test('lambda render with context data includes the variable value', () async {
      final List<String> output = await _capturePrints(
        readme_excerpts.lambdaRenderBarExample,
      );

      expect(output, equals(<String>['<b>PUB</b>']));
    });

    test('lambda renderSource example reparses in the current context', () async {
      final List<String> output = await _capturePrints(
        readme_excerpts.lambdaRenderSourceExample,
      );

      expect(output, equals(<String>['pub build']));
    });
  });
}
