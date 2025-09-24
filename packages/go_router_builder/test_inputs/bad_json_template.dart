// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin $BadJsonTemplate {}

@TypedGoRoute<BadJsonTemplate>(path: '/')
class BadJsonTemplate extends GoRouteData with $BadJsonTemplate {
  const BadJsonTemplate({required this.nested, this.deepNested});

  final JsonExampleNested<JsonExample> nested;
  final JsonExampleNested<JsonExampleNested<JsonExample>>? deepNested;
}

class JsonExample {
  const JsonExample({required this.id});

  factory JsonExample.fromJson(Map<String, dynamic> json) {
    return JsonExample(id: json['id'] as String);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id};
  }

  final String id;
}

class JsonExampleNested<T> {
  const JsonExampleNested({required this.child});

  // from fromJson is not well formed
  factory JsonExampleNested.fromJson(
    // ignore: avoid_unused_constructor_parameters
    Map<String, dynamic> json,
    // ignore: avoid_unused_constructor_parameters
    void Function(Object? json) fromJsonT,
    /*T Function(Object? json) fromJsonT,*/
  ) {
    return JsonExampleNested<T>(child: /*fromJsonT(json['child'])*/ null);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'child': child};
  }

  final T? child;
}
