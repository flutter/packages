// Copyright 2013 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file exists solely to host compiled excerpts for README.md, and is not
// intended for use as an actual example application.

// ignore_for_file: unused_local_variable, public_member_api_docs, unreachable_from_main
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

  final output = template.renderString(<String, Object>{
    'names': <Map<String, String>>[
      <String, String>{'firstname': 'Greg', 'lastname': 'Lowe'},
      <String, String>{'firstname': 'Bob', 'lastname': 'Johnson'},
    ],
  });
}
// #enddocregion ExampleUsage

void nestedPathsExample() {
  // #docregion NestedPaths
  final t = Template('{{ author.name }}');
  final output = t.renderString(<String, Object>{
    'author': <String, String>{'name': 'Greg Lowe'},
  }); // Greg Lowe
  // #enddocregion NestedPaths
}

void partialsExample() {
  // #docregion Partials
  final partial = Template('{{ foo }}', name: 'partial');

  final resolver = (String name) {
    if (name == 'partial-name') {
      return partial;
    }
    return null;
  };

  final t = Template('{{> partial-name }}', partialResolver: resolver);
  final output = t.renderString(<String, String>{'foo': 'bar'}); // bar
  // #enddocregion Partials
}

void lambdaRenderExample() {
  // #docregion LambdaRender
  final t = Template('{{# foo }}oi{{/ foo }}');
  final lambda = (LambdaContext ctx) =>
      '<b>${ctx.renderString().toUpperCase()}</b>';
  final output = t.renderString(<String, Object>{'foo': lambda}); // <b>OI</b>
  // #enddocregion LambdaRender
}

void lambdaSimpleExample() {
  // #docregion LambdaSimple
  final t = Template('{{# foo }}');
  final lambda = (LambdaContext _) => 'bar';
  final output = t.renderString(<String, Object>{'foo': lambda}); // bar
  // #enddocregion LambdaSimple
}

void lambdaShownExample() {
  // #docregion LambdaShown
  final t = Template('{{# foo }}hidden{{/ foo }}');
  final lambda = (LambdaContext _) => 'shown';
  final output = t.renderString(<String, Object>{'foo': lambda}); // shown
  // #enddocregion LambdaShown
}

void lambdaRenderBarExample() {
  // #docregion LambdaRenderBar
  final t = Template('{{# foo }}{{bar}}{{/ foo }}');
  final lambda = (LambdaContext ctx) =>
      '<b>${ctx.renderString().toUpperCase()}</b>';
  final output = t.renderString(<String, Object>{'foo': lambda, 'bar': 'pub'}); // <b>PUB</b>
  // #enddocregion LambdaRenderBar
}

void lambdaRenderSourceExample() {
  // #docregion LambdaRenderSource
  final t = Template('{{# foo }}{{bar}}{{/ foo }}');
  final lambda = (LambdaContext ctx) =>
      ctx.renderSource('${ctx.source} {{cmd}}');
  final output = t.renderString(<String, Object>{
    'foo': lambda,
    'bar': 'pub',
    'cmd': 'build',
  }); // pub build
  // #enddocregion LambdaRenderSource
}
