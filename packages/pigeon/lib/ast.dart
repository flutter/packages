// Copyright 2013 The Flutter Authors. All rights reserved.
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
  Method({
    required this.name,
    required this.returnType,
    required this.argType,
    this.isAsynchronous = false,
    this.offset,
  });

  /// The name of the method.
  String name;

  /// The data-type of the return value.
  Field returnType;

  /// The data-type of the argument.
  Field argType;

  /// Whether the receiver of this method is expected to return synchronously or not.
  bool isAsynchronous;

  /// The offset in the source file where the field appears.
  int? offset;

  @override
  String toString() {
    return '(Api name:$name returnType:$returnType argType:$argType isAsynchronous:$isAsynchronous)';
  }
}

/// Represents a collection of [Method]s that are hosted on a given [location].
class Api extends Node {
  /// Parametric constructor for [Api].
  Api({
    required this.name,
    required this.location,
    required this.methods,
    this.dartHostTestHandler,
  });

  /// The name of the API.
  String name;

  /// Where the API's implementation is located, host or Flutter.
  ApiLocation location;

  /// List of methods inside the API.
  List<Method> methods;

  /// The name of the Dart test interface to generate to help with testing.
  String? dartHostTestHandler;

  @override
  String toString() {
    return '(Api name:$name location:$location methods:$methods)';
  }
}

/// A parameter to a generic entity.  For example, "String" to "List<String>".
class TypeArgument {
  /// Constructor for [TypeArgument].
  TypeArgument({
    required this.dataType,
    required this.isNullable,
    this.typeArguments,
  });

  /// A string representation of the base datatype.
  final String dataType;

  /// The type arguments to this [TypeArgument].
  final List<TypeArgument>? typeArguments;

  /// True if the type is nullable.
  final bool isNullable;

  @override
  String toString() {
    return '(TypeArgument dataType:$dataType isNullable:$isNullable typeArguments:$typeArguments)';
  }
}

/// An entity that represents a typed concept, like a [TypeArgument] or [Field].
abstract class TypedEntity {
  /// The data-type of the entity (ex 'String' or 'int').
  String get dataType;

  /// The type arguments to the entity.
  List<TypeDeclaration>? get typeArguments;

  /// True if the type is nullable.
  bool get isNullable;
}

/// Represents a type declaration.
class TypeDeclaration implements TypedEntity {
  /// Constructor for [TypeDeclaration].
  TypeDeclaration({
    required this.dataType,
    required this.isNullable,
    this.typeArguments,
  });

  @override
  final String dataType;

  @override
  final List<TypeDeclaration>? typeArguments;

  @override
  final bool isNullable;

  @override
  String toString() {
    return '(TypeDeclaration dataType:$dataType isNullable:$isNullable typeArguments:$typeArguments)';
  }
}

/// Represents a field on a [Class].
class Field extends Node implements TypedEntity {
  /// Parametric constructor for [Field].
  Field({
    required this.name,
    required String dataType,
    required bool isNullable,
    List<TypeDeclaration>? typeArguments,
    this.offset,
  }) : type = TypeDeclaration(
            dataType: dataType,
            isNullable: isNullable,
            typeArguments: typeArguments);

  /// The name of the field.
  String name;

  /// The offset in the source file where the field appears.
  int? offset;

  /// The type of the [Field].
  TypeDeclaration type;

  @override
  String get dataType => type.dataType;

  @override
  bool get isNullable => type.isNullable;

  @override
  List<TypeDeclaration>? get typeArguments => type.typeArguments;

  @override
  String toString() {
    return '(Field name:$name dataType:$dataType typeArguments:$typeArguments)';
  }
}

/// Represents a class with [Field]s.
class Class extends Node {
  /// Parametric constructor for [Class].
  Class({
    required this.name,
    required this.fields,
  });

  /// The name of the class.
  String name;

  /// All the fields contained in the class.
  List<Field> fields;

  @override
  String toString() {
    return '(Class name:$name fields:$fields)';
  }
}

/// Represents a Enum.
class Enum extends Node {
  /// Parametric constructor for [Enum].
  Enum({
    required this.name,
    required this.members,
  });

  /// The name of the enum.
  String name;

  /// All of the members of the enum.
  List<String> members;

  @override
  String toString() {
    return '(Enum name:$name members:$members)';
  }
}

/// Top-level node for the AST.
class Root extends Node {
  /// Parametric constructor for [Root].
  Root({
    required this.classes,
    required this.apis,
    required this.enums,
  });

  /// Factory function for generating an empty root, usually used when early errors are encountered.
  factory Root.makeEmpty() {
    return Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]);
  }

  /// All the classes contained in the AST.
  List<Class> classes;

  /// All the API's contained in the AST.
  List<Api> apis;

  /// All of the enums contained in the AST.
  List<Enum> enums;

  @override
  String toString() {
    return '(Root classes:$classes apis:$apis enums:$enums)';
  }
}
