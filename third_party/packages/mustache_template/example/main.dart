// ignore_for_file: avoid_print

import 'package:mustache_template/mustache_template.dart';

// #docregion basic-usage
void main() {
  const source = '''
    {{# names }}
      <div>{{ lastname }}, {{ firstname }}</div>
    {{/ names }}
    {{^ names }}
      <div>No names.</div>
    {{/ names }}
    {{! I am a comment. }}
  ''';

  final template = Template(source, name: 'template-filename.html');

  final Object output = template.renderString({
    'names': [
      {'firstname': 'Greg', 'lastname': 'Lowe'},
      {'firstname': 'Bob', 'lastname': 'Johnson'},
    ],
  });

  print(output);
  // #enddocregion basic-usage

  // #docregion nested-paths
  final t = Template('{{ author.name }}');
  final Object nestedOutput = t.renderString({
    'author': {'name': 'Greg Lowe'},
  });
  print(nestedOutput);
  // #enddocregion nested-paths

  // #docregion partials
  final partial = Template('{{ foo }}', name: 'partial');

  Template? resolver(String name) => name == 'partial-name' ? partial : null;

  final pt = Template('{{> partial-name }}', partialResolver: resolver);

  final Object partialOutput = pt.renderString({'foo': 'bar'}); // bar
  print(partialOutput);
  // #enddocregion partials

  // #docregion lambdas
  final lt = Template('{{# foo }}{{bar}}{{/ foo }}');
  String lambda(LambdaContext ctx) =>
      '<b>${ctx.renderString().toUpperCase()}</b>';
  print(lt.renderString({'foo': lambda, 'bar': 'pub'})); // <b>PUB</b>
  // #enddocregion lambdas

  // #docregion lambda-render-source
  final rst = Template('{{# foo }}{{bar}}{{/ foo }}');
  String renderSourceLambda(LambdaContext ctx) =>
      ctx.renderSource('${ctx.source} {{cmd}}');
  print(
    rst.renderString({'foo': renderSourceLambda, 'bar': 'pub', 'cmd': 'build'}),
  ); // pub build
  // #enddocregion lambda-render-source
}
