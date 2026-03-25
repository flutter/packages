// Specification files can be downloaded here https://github.com/mustache/spec

// Test implemented by Georgios Valotasios.
// See: https://github.com/valotas/mustache4dart

import 'dart:convert';
import 'dart:io';

import 'package:mustache_template/mustache.dart';
import 'package:test/test.dart';

String render(
  String source,
  dynamic values, {
  required String? Function(String) partial,
}) {
  late Template? Function(String) resolver;
  resolver = (String name) {
    final String? source = partial(name);
    if (source == null) {
      return null;
    }
    return Template(source, partialResolver: resolver, lenient: true);
  };
  final t = Template(source, partialResolver: resolver, lenient: true);
  return t.renderString(values);
}

void main() {
  defineTests();
}

void defineTests() {
  final specsDir = Directory('test/spec/specs');
  specsDir.listSync().forEach((FileSystemEntity f) {
    if (f is File) {
      final String filename = f.path;
      if (shouldRun(filename)) {
        final String text = f.readAsStringSync();
        _defineGroupFromFile(filename, text);
      }
    }
  });
}

void _defineGroupFromFile(String filename, String text) {
  final Map<String, Object?> jsondata =
      (json.decode(text) as Map<dynamic, dynamic>).cast<String, Object?>();
  final List<Map<String, Object?>> tests = (jsondata['tests']! as List<dynamic>)
      .cast<Map<String, Object?>>();
  filename = filename.substring(filename.lastIndexOf('/') + 1);
  group('Specs of $filename', () {
    for (final t in tests) {
      final testDescription = StringBuffer(t['name']! as String);
      testDescription.write(': ');
      testDescription.write(t['desc']);
      final template = t['template']! as String;
      final Object? data = t['data'];
      final String templateOneline = template
          .replaceAll('\n', r'\n')
          .replaceAll('\r', r'\r');
      final reason = StringBuffer(
        "Could not render right '''$templateOneline'''",
      );
      final Object? expected = t['expected'];
      final partials = t['partials'] as Map<String, Object?>?;
      String? partial(String name) {
        if (partials == null) {
          return null;
        }
        return partials[name] as String?;
      }

      //swap the data.lambda with a dart real function
      if (data is Map && data['lambda'] != null) {
        data['lambda'] = lambdas[t['name']];
      }
      reason.write(" with '$data'");
      if (partials != null) {
        reason.write(' and partial: $partials');
      }
      test(
        testDescription.toString(),
        () => expect(
          render(template, data, partial: partial),
          expected,
          reason: reason.toString(),
        ),
      );
    }
  });
}

bool shouldRun(String filename) {
  // filter out only .json files
  if (!filename.endsWith('.json')) {
    return false;
  }
  return true;
}

String Function(Object?) _dummyCallableWithState() {
  var callCounter = 0;
  return (Object? arg) {
    callCounter++;
    return callCounter.toString();
  };
}

String Function(LambdaContext) wrapLambda(Object? Function(Object?) f) =>
    (LambdaContext ctx) => ctx.renderSource(f(ctx.source).toString());

Map<String, Function> lambdas = <String, Function>{
  'Interpolation': wrapLambda((Object? t) => 'world'),
  'Interpolation - Expansion': wrapLambda((Object? t) => '{{planet}}'),
  'Interpolation - Alternate Delimiters': wrapLambda(
    (Object? t) => '|planet| => {{planet}}',
  ),
  'Interpolation - Multiple Calls': wrapLambda(
    _dummyCallableWithState(),
  ), //function() { return (g=(function(){return this})()).calls=(g.calls||0)+1 }
  'Escaping': wrapLambda((Object? t) => '>'),
  'Section': wrapLambda((Object? txt) => txt == '{{x}}' ? 'yes' : 'no'),
  'Section - Expansion': wrapLambda((Object? txt) => '$txt{{planet}}$txt'),
  'Section - Alternate Delimiters': wrapLambda(
    (Object? txt) => '$txt{{planet}} => |planet|$txt',
  ),
  'Section - Multiple Calls': wrapLambda((Object? t) => '__${t}__'),
  'Inverted Section': wrapLambda((Object? txt) => false),
};
