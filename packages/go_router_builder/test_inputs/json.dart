// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';

mixin $GoodJson {}

@TypedGoRoute<GoodJson>(path: '/')
class GoodJson extends GoRouteData with $GoodJson {
  const GoodJson({required this.id, this.optionalField});

  final JsonExample id;
  final JsonExample? optionalField;
}

class JsonExample {
  const JsonExample({required this.id});

  factory JsonExample.fromJson(Map<String, dynamic> json) {
    return JsonExample(id: json['id'] as String);
  }

  final String id;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id};
  }
}
