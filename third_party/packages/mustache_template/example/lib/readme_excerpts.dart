// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file exists solely to host compiled excerpts for README.md, and is not
// intended for use as an actual example application.

// ignore_for_file: avoid_print, public_member_api_docs, unreachable_from_main
// ignore_for_file: prefer_function_declarations_over_variables
// ignore_for_file: specify_nonobvious_local_variable_types

// #docregion ExampleUsage
import 'package:mustache_template/mustache_template.dart';

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

  final output = template.renderString({
    'names': [
      {'firstname': 'Greg', 'lastname': 'Lowe'},
      {'firstname': 'Bob', 'lastname': 'Johnson'},
    ],
  });

  print(output);
}
// #enddocregion ExampleUsage

void nestedPathsExample() {
  // #docregion NestedPaths
  final t = Template('{{ author.name }}');
  final output = t.renderString({
    'author': {'name': 'Greg Lowe'},
  });
  // #enddocregion NestedPaths
  print(output);
}

void partialsExample() {
  // #docregion Partials
  final partial = Template('{{ foo }}', name: 'partial');

  final resolver = (String name) {
    if (name == 'partial-name') {
      // Name of partial tag.
      return partial;
    }
    return null;
  };

  final t = Template('{{> partial-name }}', partialResolver: resolver);

  final output = t.renderString({'foo': 'bar'}); // bar
  // #enddocregion Partials
  print(output);
}

void lambdaSimpleExample() {
  // #docregion LambdaSimple
  final t = Template('{{# foo }}{{/ foo }}');
  final lambda = (_) => 'bar';
  t.renderString({'foo': lambda}); // bar
  // #enddocregion LambdaSimple
}

void lambdaShownExample() {
  // #docregion LambdaShown
  final t = Template('{{# foo }}hidden{{/ foo }}');
  final lambda = (_) => 'shown';
  t.renderString({'foo': lambda}); // shown
  // #enddocregion LambdaShown
}

void lambdaRenderExample() {
  // #docregion LambdaRender
  final t = Template('{{# foo }}oi{{/ foo }}');
  final lambda = (LambdaContext ctx) =>
      '<b>${ctx.renderString().toUpperCase()}</b>';
  t.renderString({'foo': lambda}); // <b>OI</b>
  // #enddocregion LambdaRender
}

void lambdaRenderBarExample() {
  // #docregion LambdaRenderBar
  final t = Template('{{# foo }}{{bar}}{{/ foo }}');
  final lambda = (LambdaContext ctx) =>
      '<b>${ctx.renderString().toUpperCase()}</b>';
  t.renderString({'foo': lambda, 'bar': 'pub'}); // <b>PUB</b>
  // #enddocregion LambdaRenderBar
}

void lambdaRenderSourceExample() {
  // #docregion LambdaRenderSource
  final t = Template('{{# foo }}{{bar}}{{/ foo }}');
  final lambda = (LambdaContext ctx) =>
      ctx.renderSource('${ctx.source} {{cmd}}');
  t.renderString({'foo': lambda, 'bar': 'pub', 'cmd': 'build'}); // pub build
  // #enddocregion LambdaRenderSource
}
