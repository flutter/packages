// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';
// used for json decoder/encoder
export 'dart:convert' show jsonDecode, jsonEncode;

@TypedGoRoute<BadJson>(path: '/')
class BadJson extends GoRouteData {
  const BadJson({required this.nested, this.deepNested});

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
    Map<String, dynamic> json,
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
