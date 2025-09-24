// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// json example
class JsonExample {
  /// json example
  const JsonExample({required this.id, required this.name});

  /// fromJson decoder
  factory JsonExample.fromJson(Map<String, dynamic> json) {
    return JsonExample(id: json['id'] as String, name: json['name'] as String);
  }

  /// toJson encoder
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'name': name};
  }

  /// id
  final String id;

  /// name
  final String name;
}

/// example info
const List<JsonExample> jsonData = <JsonExample>[
  JsonExample(id: '1', name: 'people'),
  JsonExample(id: '2', name: 'animals'),
];

/// Json Nested Example
class JsonExampleNested<T> {
  /// Json Nested Example
  const JsonExampleNested({required this.child});

  /// toJson decoder
  factory JsonExampleNested.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return JsonExampleNested<T>(child: fromJsonT(json['child']));
  }

  /// toJson encoder
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'child': child};
  }

  /// child
  final T child;
}
