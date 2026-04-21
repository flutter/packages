// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mustache_template/mustache_template.dart';
import 'package:test/test.dart';

void main() {
  group('README examples', () {
    test('basic usage example runs', () {
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

      expect(output, contains('Lowe, Greg'));
      expect(output, contains('Johnson, Bob'));
    });

    test('nested paths example runs', () {
      final t = Template('{{ author.name }}');
      final Object output = t.renderString({
        'author': {'name': 'Greg Lowe'},
      });
      expect(output, equals('Greg Lowe'));
    });

    test('partials example runs', () {
      final partial = Template('{{ foo }}', name: 'partial');

      Template? resolver(String name) =>
          name == 'partial-name' ? partial : null;

      final t = Template('{{> partial-name }}', partialResolver: resolver);

      final Object output = t.renderString({'foo': 'bar'}); // bar
      expect(output, equals('bar'));
    });

    test('lambdas example runs', () {
      final t = Template('{{# foo }}{{bar}}{{/ foo }}');
      String lambda(LambdaContext ctx) =>
          '<b>${ctx.renderString().toUpperCase()}</b>';
      final Object output = t.renderString({'foo': lambda, 'bar': 'pub'});
      expect(output, equals('<b>PUB</b>'));
    });

    test('lambda renderSource example runs', () {
      final t = Template('{{# foo }}{{bar}}{{/ foo }}');
      String lambda(LambdaContext ctx) =>
          ctx.renderSource('${ctx.source} {{cmd}}');
      final Object output = t.renderString({
        'foo': lambda,
        'bar': 'pub',
        'cmd': 'build',
      });
      expect(output, equals('pub build'));
    });
  });
}
