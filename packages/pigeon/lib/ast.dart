// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Enum that represents where an [Api] is located, on the host or Flutter.
enum ApiLocation {
  /// The API is for calling functions defined on the host.
  host,

  /// The API is for calling functions defined in Flutter.
  flutter,
}

/// Superclass for all AST nodes.
class Node {}

/// Represents a method on an [Api].
class Method extends Node {
  /// Parametric constructor for [Method].
  Method({this.name, this.returnType, this.argType, this.isAsynchronous});

  /// The name of the method.
  String name;

  /// The data-type of the return value.
  String returnType;

  /// The data-type of the argument.
  String argType;

  /// Whether the receiver of this method is expected to return synchronously or not.
  bool isAsynchronous;
}

/// Represents a collection of [Method]s that are hosted on a given [location].
class Api extends Node {
  /// Parametric constructor for [Api].
  Api({this.name, this.location, this.methods, this.dartHostTestHandler});

  /// The name of the API.
  String name;

  /// Where the API's implementation is located, host or Flutter.
  ApiLocation location;

  /// List of methods inside the API.
  List<Method> methods;

  /// The name of the Dart test interface to generate to help with testing.
  String dartHostTestHandler;
}

/// Represents a field on a [Class].
class Field extends Node {
  /// Parametric constructor for [Field].
  Field({this.name, this.dataType});

  /// The name of the field.
  String name;

  /// The data-type of the field (ex 'String' or 'int').
  String dataType;

  @override
  String toString() {
    return '(Field name:$name)';
  }
}

/// Represents a class with [Field]s.
class Class extends Node {
  /// Parametric constructor for [Class].
  Class({this.name, this.fields});

  /// The name of the class.
  String name;

  /// All the fields contained in the class.
  List<Field> fields;

  @override
  String toString() {
    return '(Class name:$name fields:$fields)';
  }
}

/// Top-level node for the AST.
class Root extends Node {
  /// Parametric constructor for [Root].
  Root({this.classes, this.apis});

  /// All the classes contained in the AST.
  List<Class> classes;

  /// All the API's contained in the AST.
  List<Api> apis;

  @override
  String toString() {
    return '(Root classes:$classes apis:$apis)';
  }
}
