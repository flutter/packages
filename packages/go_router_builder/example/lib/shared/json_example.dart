// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class JsonExample {
  const JsonExample({required this.id, required this.name});

  factory JsonExample.fromJson(Map<String, dynamic> json) {
    return JsonExample(id: json['id'] as String, name: json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'name': name};
  }

  final String id;
  final String name;
}

const List<JsonExample> jsonData = <JsonExample>[
  JsonExample(id: '1', name: 'people'),
  JsonExample(id: '2', name: 'animals'),
];

class JsonExampleNested<T> {
  const JsonExampleNested({required this.child});

  factory JsonExampleNested.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return JsonExampleNested<T>(child: fromJsonT(json['child']));
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'child': child};
  }

  final T child;
}
