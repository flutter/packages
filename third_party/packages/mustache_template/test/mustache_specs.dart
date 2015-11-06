// Specification files can be downloaded here https://github.com/mustache/spec

// Test implemented by Georgios Valotasios.
// See: https://github.com/valotas/mustache4dart

library mustache_specs;

import 'dart:io';
import 'dart:convert';
import 'package:unittest/unittest.dart';
import 'package:mustache/mustache.dart';

String render(source, values, {partial}) {
  var resolver = null;
  resolver = (name) {
    var source = partial(name);
    if (source == null) return null;
    return new Template(source, partialResolver: resolver, lenient: true);
  };
  var t = new Template(source, partialResolver: resolver, lenient: true);
  return t.renderString(values);
}

main() {
  defineTests();
}

defineTests() {
  var specs_dir = new Directory('test/spec/specs');
  specs_dir.listSync().forEach((f) {
    if (f is File) {
      var filename = f.path;
      if (shouldRun(filename)) {
        var text = f.readAsStringSync(encoding: UTF8);
        _defineGroupFromFile(filename, text);
      }
    }
  });
}

_defineGroupFromFile(filename, text) {
  var json = JSON.decode(text);
  var tests = json['tests'];
  filename = filename.substring(filename.lastIndexOf('/') + 1);
  group("Specs of $filename", () {
    //Make sure that we reset the state of the Interpolation - Multiple Calls test
    //as for some reason dart can run the group more than once causing the test
    //to fail the second time it runs
    tearDown(() => lambdas['Interpolation - Multiple Calls'].reset());

    tests.forEach((t) {
      var testDescription = new StringBuffer(t['name']);
      testDescription.write(': ');
      testDescription.write(t['desc']);
      var template = t['template'];
      var data = t['data'];
      var templateOneline =
          template.replaceAll('\n', '\\n').replaceAll('\r', '\\r');
      var reason =
          new StringBuffer("Could not render right '''$templateOneline'''");
      var expected = t['expected'];
      var partials = t['partials'];
      var partial = (String name) {
        if (partials == null) {
          return null;
        }
        return partials[name];
      };

      //swap the data.lambda with a dart real function
      if (data['lambda'] != null) {
        data['lambda'] = lambdas[t['name']];
      }
      reason.write(" with '$data'");
      if (partials != null) {
        reason.write(" and partial: $partials");
      }
      test(
          testDescription.toString(),
          () => expect(render(template, data, partial: partial), expected,
              reason: reason.toString()));
    });
  });
}

bool shouldRun(String filename) {
  // filter out only .json files
  if (!filename.endsWith('.json')) {
    return false;
  }
  return true;
}

//Until we'll find a way to load a piece of code dynamically,
//we provide the lambdas at the test here
class _DummyCallableWithState {
  var _callCounter = 0;

  call(arg) => "${++_callCounter}";

  reset() => _callCounter = 0;
}

Function wrapLambda(Function f) =>
    (LambdaContext ctx) => ctx.renderSource(f(ctx.source).toString());

var lambdas = {
  'Interpolation': wrapLambda((t) => 'world'),
  'Interpolation - Expansion': wrapLambda((t) => '{{planet}}'),
  'Interpolation - Alternate Delimiters':
      wrapLambda((t) => "|planet| => {{planet}}"),
  'Interpolation - Multiple Calls':
      new _DummyCallableWithState(), //function() { return (g=(function(){return this})()).calls=(g.calls||0)+1 }
  'Escaping': wrapLambda((t) => '>'),
  'Section': wrapLambda((txt) => txt == "{{x}}" ? "yes" : "no"),
  'Section - Expansion': wrapLambda((txt) => "$txt{{planet}}$txt"),
  'Section - Alternate Delimiters':
      wrapLambda((txt) => "$txt{{planet}} => |planet|$txt"),
  'Section - Multiple Calls': wrapLambda((t) => "__${t}__"),
  'Inverted Section': wrapLambda((txt) => false)
};
