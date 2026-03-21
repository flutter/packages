// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print, prefer_function_declarations_over_variables

// #docregion ExampleUsage
import 'package:mustache_template/mustache_template.dart';

void main() {
  // #enddocregion ExampleUsage
  print('=== Basic Template ===');

  // Basic template rendering with sections and inverted sections.
  // #docregion ExampleUsage
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

  final String output = template.renderString({
    'names': [
      {'firstname': 'Greg', 'lastname': 'Lowe'},
      {'firstname': 'Bob', 'lastname': 'Johnson'},
    ],
  });

  print(output);
  // #enddocregion ExampleUsage

  // Nested paths
  final nested = Template('{{ author.name }}');
  print('=== Nested Paths ===');
  print(
    nested.renderString({
      'author': {'name': 'Greg Lowe'},
    }),
  );

  // Lambdas
  final lambdaTemplate = Template('{{# transform }}hello{{/ transform }}');
  final String Function(LambdaContext) lambda = (LambdaContext ctx) =>
      ctx.renderString().toUpperCase();
  print('=== Lambdas ===');
  print(lambdaTemplate.renderString({'transform': lambda}));
  // #docregion ExampleUsage
}

// #enddocregion ExampleUsage
