// ignore_for_file: avoid_relative_lib_imports

import 'package:test/test.dart';

import '../example/lib/main.dart' as example_app;
import '../example/lib/readme_excerpts.dart' as readme_excerpts;

void main() {
  group('Example app', () {
    test('example app runs without error', () {
      expect(example_app.main, returnsNormally);
    });
  });

  group('README excerpts', () {
    test('nested paths example renders the nested value', () {
      expect(readme_excerpts.nestedPathsExample(), equals('Greg Lowe'));
    });

    test('partials example renders the partial output', () {
      expect(readme_excerpts.partialsExample(), equals('bar'));
    });

    test('simple lambda example renders the replacement text', () {
      expect(readme_excerpts.lambdaSimpleExample(), equals('bar'));
    });

    test('lambda block example renders the alternate text', () {
      expect(readme_excerpts.lambdaShownExample(), equals('shown'));
    });

    test('lambda render example uppercases the section body', () {
      expect(readme_excerpts.lambdaRenderExample(), equals('<b>OI</b>'));
    });

    test('lambda render with context data includes the variable value', () {
      expect(readme_excerpts.lambdaRenderBarExample(), equals('<b>PUB</b>'));
    });

    test('lambda renderSource example reparses in the current context', () {
      expect(readme_excerpts.lambdaRenderSourceExample(), equals('pub build'));
    });
  });
}
