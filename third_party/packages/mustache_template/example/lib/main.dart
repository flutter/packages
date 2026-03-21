// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print, prefer_function_declarations_over_variables

import 'package:mustache_template/mustache_template.dart';

void main() {
  // Basic template rendering with sections and inverted sections.
  const source = '''
{{# names }}
  <div>{{ lastname }}, {{ firstname }}</div>
{{/ names }}
{{^ names }}
  <div>No names.</div>
{{/ names }}
''';

  final template = Template(source, name: 'example.html');

  final String output = template.renderString({
    'names': [
      {'firstname': 'Greg', 'lastname': 'Lowe'},
      {'firstname': 'Bob', 'lastname': 'Johnson'},
    ],
  });

  print('=== Basic Template ===');
  print(output);

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
}
