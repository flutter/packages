// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file exists solely to host compiled excerpts for README.md, and is not
// intended for use as an actual example application.

// ignore_for_file: avoid_print, public_member_api_docs, unreachable_from_main
// ignore_for_file: prefer_function_declarations_over_variables
// ignore_for_file: specify_nonobvious_local_variable_types

import 'package:mustache_template/mustache_template.dart';

String nestedPathsExample() {
  // #docregion NestedPaths
  final t = Template('{{ author.name }}');
  final output = t.renderString({
    'author': {'name': 'Greg Lowe'},
  });
  // #enddocregion NestedPaths
  return output;
}

String partialsExample() {
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
  return output;
}

String lambdaSimpleExample() {
  // #docregion LambdaSimple
  final t = Template('{{# foo }}{{/ foo }}');
  final lambda = (_) => 'bar';
  final output = t.renderString({'foo': lambda}); // bar
  // #enddocregion LambdaSimple
  return output;
}

String lambdaShownExample() {
  // #docregion LambdaShown
  final t = Template('{{# foo }}hidden{{/ foo }}');
  final lambda = (_) => 'shown';
  final output = t.renderString({'foo': lambda}); // shown
  // #enddocregion LambdaShown
  return output;
}

String lambdaRenderExample() {
  // #docregion LambdaRender
  final t = Template('{{# foo }}oi{{/ foo }}');
  final lambda = (LambdaContext ctx) =>
      '<b>${ctx.renderString().toUpperCase()}</b>';
  final output = t.renderString({'foo': lambda}); // <b>OI</b>
  // #enddocregion LambdaRender
  return output;
}

String lambdaRenderBarExample() {
  // #docregion LambdaRenderBar
  final t = Template('{{# foo }}{{bar}}{{/ foo }}');
  final lambda = (LambdaContext ctx) =>
      '<b>${ctx.renderString().toUpperCase()}</b>';
  final output = t.renderString({'foo': lambda, 'bar': 'pub'}); // <b>PUB</b>
  // #enddocregion LambdaRenderBar
  return output;
}

String lambdaRenderSourceExample() {
  // #docregion LambdaRenderSource
  final t = Template('{{# foo }}{{bar}}{{/ foo }}');
  final lambda = (LambdaContext ctx) =>
      ctx.renderSource('${ctx.source} {{cmd}}');
  final output = t.renderString({
    'foo': lambda,
    'bar': 'pub',
    'cmd': 'build',
  }); // pub build
  // #enddocregion LambdaRenderSource
  return output;
}
