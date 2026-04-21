// ignore_for_file: avoid_print, prefer_const_declarations, specify_nonobvious_local_variable_types, prefer_final_locals, prefer_function_declarations_over_variables

import 'package:mustache_template/mustache_template.dart';

// #docregion basic-usage
void main() {
  var source = '''
    {{# names }}
      <div>{{ lastname }}, {{ firstname }}</div>
    {{/ names }}
    {{^ names }}
      <div>No names.</div>
    {{/ names }}
    {{! I am a comment. }}
  ''';

  var template = Template(source, name: 'template-filename.html');

  var output = template.renderString({
    'names': [
      {'firstname': 'Greg', 'lastname': 'Lowe'},
      {'firstname': 'Bob', 'lastname': 'Johnson'},
    ],
  });

  print(output);
  // #enddocregion basic-usage

  // #docregion nested-paths
  var t = Template('{{ author.name }}');
  var nestedOutput = t.renderString({
    'author': {'name': 'Greg Lowe'},
  });
  print(nestedOutput);
  // #enddocregion nested-paths

  // #docregion partials
  var partial = Template('{{ foo }}', name: 'partial');

  var resolver = (String name) => name == 'partial-name' ? partial : null;

  var pt = Template('{{> partial-name }}', partialResolver: resolver);

  var partialOutput = pt.renderString({'foo': 'bar'}); // bar
  print(partialOutput);
  // #enddocregion partials

  // #docregion lambdas
  var lt = Template('{{# foo }}{{bar}}{{/ foo }}');
  var lambda = (LambdaContext ctx) =>
      '<b>${ctx.renderString().toUpperCase()}</b>';
  print(lt.renderString({'foo': lambda, 'bar': 'pub'})); // <b>PUB</b>
  // #enddocregion lambdas

  // #docregion lambda-render-source
  var rst = Template('{{# foo }}{{bar}}{{/ foo }}');
  var renderSourceLambda = (LambdaContext ctx) =>
      ctx.renderSource('${ctx.source} {{cmd}}');
  print(
    rst.renderString({'foo': renderSourceLambda, 'bar': 'pub', 'cmd': 'build'}),
  ); // pub build
  // #enddocregion lambda-render-source
}
