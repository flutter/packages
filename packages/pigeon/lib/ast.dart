// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart' show ListEquality;
import 'package:meta/meta.dart';
import 'pigeon_lib.dart';

typedef _ListEquals = bool Function(List<Object?>, List<Object?>);

final _ListEquals _listEquals = const ListEquality<dynamic>().equals;

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
    required this.parameters,
    this.isAsynchronous = false,
    this.offset,
    this.objcSelector = '',
    this.swiftFunction = '',
    this.taskQueueType = TaskQueueType.serial,
    this.documentationComments = const <String>[],
  });

  /// The name of the method.
  String name;

  /// The data-type of the return value.
  TypeDeclaration returnType;

  /// The parameters passed into the [Method].
  List<Parameter> parameters;

  /// Whether the receiver of this method is expected to return synchronously or not.
  bool isAsynchronous;

  /// The offset in the source file where the field appears.
  int? offset;

  /// An override for the generated objc selector (ex. "divideNumber:by:").
  String objcSelector;

  /// An override for the generated swift function signature (ex. "divideNumber(_:by:)").
  String swiftFunction;

  /// Specifies how handlers are dispatched with respect to threading.
  TaskQueueType taskQueueType;

  /// List of documentation comments, separated by line.
  ///
  /// Lines should not include the comment marker itself, but should include any
  /// leading whitespace, so that any indentation in the original comment is preserved.
  /// For example: [" List of documentation comments, separated by line.", ...]
  List<String> documentationComments;

  @override
  String toString() {
    final String objcSelectorStr =
        objcSelector.isEmpty ? '' : ' objcSelector:$objcSelector';
    final String swiftFunctionStr =
        swiftFunction.isEmpty ? '' : ' swiftFunction:$swiftFunction';
    return '(Method name:$name returnType:$returnType parameters:$parameters isAsynchronous:$isAsynchronous$objcSelectorStr$swiftFunctionStr documentationComments:$documentationComments)';
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
    this.documentationComments = const <String>[],
  });

  /// The name of the API.
  String name;

  /// Where the API's implementation is located, host or Flutter.
  ApiLocation location;

  /// List of methods inside the API.
  List<Method> methods;

  /// The name of the Dart test interface to generate to help with testing.
  String? dartHostTestHandler;

  /// List of documentation comments, separated by line.
  ///
  /// Lines should not include the comment marker itself, but should include any
  /// leading whitespace, so that any indentation in the original comment is preserved.
  /// For example: [" List of documentation comments, separated by line.", ...]
  List<String> documentationComments;

  @override
  String toString() {
    return '(Api name:$name location:$location methods:$methods documentationComments:$documentationComments)';
  }
}

/// A specific instance of a type.
@immutable
class TypeDeclaration {
  /// Constructor for [TypeDeclaration].
  const TypeDeclaration({
    required this.baseName,
    required this.isNullable,
    this.associatedEnum,
    this.associatedClass,
    this.typeArguments = const <TypeDeclaration>[],
  });

  /// Void constructor.
  const TypeDeclaration.voidDeclaration()
      : baseName = 'void',
        isNullable = false,
        associatedEnum = null,
        associatedClass = null,
        typeArguments = const <TypeDeclaration>[];

  /// The base name of the [TypeDeclaration] (ex 'Foo' to 'Foo<Bar>?').
  final String baseName;

  /// Whether the declaration represents 'void'.
  bool get isVoid => baseName == 'void';

  /// Whether the type arguments to the entity (ex 'Bar' to 'Foo<Bar>?').
  final List<TypeDeclaration> typeArguments;

  /// Whether the type is nullable.
  final bool isNullable;

  /// Whether the [TypeDeclaration] has an [associatedEnum].
  bool get isEnum => associatedEnum != null;

  /// Associated [Enum], if any.
  final Enum? associatedEnum;

  /// Whether the [TypeDeclaration] has an [associatedClass].
  bool get isClass => associatedClass != null;

  /// Associated [Class], if any.
  final Class? associatedClass;

  @override
  int get hashCode {
    // This has to be implemented because TypeDeclaration is used as a Key to a
    // Map in generator_tools.dart.
    int hash = 17;
    hash = hash * 37 + baseName.hashCode;
    hash = hash * 37 + isNullable.hashCode;
    for (final TypeDeclaration typeArgument in typeArguments) {
      hash = hash * 37 + typeArgument.hashCode;
    }
    return hash;
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    } else {
      return other is TypeDeclaration &&
          baseName == other.baseName &&
          isNullable == other.isNullable &&
          _listEquals(typeArguments, other.typeArguments) &&
          isEnum == other.isEnum &&
          isClass == other.isClass &&
          associatedClass == other.associatedClass &&
          associatedEnum == other.associatedEnum;
    }
  }

  /// Returns duplicated `TypeDeclaration` with attached `associatedEnum` value.
  TypeDeclaration copyWithEnum(Enum enumDefinition) {
    return TypeDeclaration(
      baseName: baseName,
      isNullable: isNullable,
      associatedEnum: enumDefinition,
      typeArguments: typeArguments,
    );
  }

  /// Returns duplicated `TypeDeclaration` with attached `associatedClass` value.
  TypeDeclaration copyWithClass(Class classDefinition) {
    return TypeDeclaration(
      baseName: baseName,
      isNullable: isNullable,
      associatedClass: classDefinition,
      typeArguments: typeArguments,
    );
  }

  @override
  String toString() {
    final String typeArgumentsStr =
        typeArguments.isEmpty ? '' : 'typeArguments:$typeArguments';
    return '(TypeDeclaration baseName:$baseName isNullable:$isNullable$typeArgumentsStr isEnum:$isEnum isClass:$isClass)';
  }
}

/// Represents a named entity that has a type.
@immutable
class NamedType extends Node {
  /// Parametric constructor for [NamedType].
  NamedType({
    required this.name,
    required this.type,
    this.offset,
    this.defaultValue,
    this.documentationComments = const <String>[],
  });

  /// The name of the entity.
  final String name;

  /// The type.
  final TypeDeclaration type;

  /// The offset in the source file where the [NamedType] appears.
  final int? offset;

  /// Stringified version of the default value of types that have default values.
  final String? defaultValue;

  /// List of documentation comments, separated by line.
  ///
  /// Lines should not include the comment marker itself, but should include any
  /// leading whitespace, so that any indentation in the original comment is preserved.
  /// For example: [" List of documentation comments, separated by line.", ...]
  final List<String> documentationComments;

  /// Returns a copy of [NamedType] instance with new attached [TypeDeclaration].
  NamedType copyWithType(TypeDeclaration type) {
    return NamedType(
      name: name,
      type: type,
      offset: offset,
      defaultValue: defaultValue,
      documentationComments: documentationComments,
    );
  }

  @override
  String toString() {
    return '(NamedType name:$name type:$type defaultValue:$defaultValue documentationComments:$documentationComments)';
  }
}

/// Represents a [Method]'s parameter that has a type and a name.
@immutable
class Parameter extends NamedType {
  /// Parametric constructor for [Parameter].
  Parameter({
    required super.name,
    required super.type,
    super.offset,
    super.defaultValue,
    bool? isNamed,
    bool? isOptional,
    bool? isPositional,
    bool? isRequired,
    super.documentationComments,
  })  : isNamed = isNamed ?? true,
        isOptional = isOptional ?? false,
        isPositional = isPositional ?? true,
        isRequired = isRequired ?? true;

  /// Whether this parameter is a named parameter.
  ///
  /// Defaults to `true`.
  final bool isNamed;

  /// Whether this parameter is an optional parameter.
  ///
  /// Defaults to `false`.
  final bool isOptional;

  /// Whether this parameter is a positional parameter.
  ///
  /// Defaults to `true`.
  final bool isPositional;

  /// Whether this parameter is a required parameter.
  ///
  /// Defaults to `true`.
  final bool isRequired;

  /// Returns a copy of [Parameter] instance with new attached [TypeDeclaration].
  @override
  Parameter copyWithType(TypeDeclaration type) {
    return Parameter(
      name: name,
      type: type,
      offset: offset,
      defaultValue: defaultValue,
      isNamed: isNamed,
      isOptional: isOptional,
      isPositional: isPositional,
      isRequired: isRequired,
      documentationComments: documentationComments,
    );
  }

  @override
  String toString() {
    return '(Parameter name:$name type:$type isNamed:$isNamed isOptional:$isOptional isPositional:$isPositional isRequired:$isRequired documentationComments:$documentationComments)';
  }
}

/// Represents a class with fields.
class Class extends Node {
  /// Parametric constructor for [Class].
  Class({
    required this.name,
    required this.fields,
    this.documentationComments = const <String>[],
  });

  /// The name of the class.
  String name;

  /// All the fields contained in the class.
  List<NamedType> fields;

  /// List of documentation comments, separated by line.
  ///
  /// Lines should not include the comment marker itself, but should include any
  /// leading whitespace, so that any indentation in the original comment is preserved.
  /// For example: [" List of documentation comments, separated by line.", ...]
  List<String> documentationComments;

  @override
  String toString() {
    return '(Class name:$name fields:$fields documentationComments:$documentationComments)';
  }
}

/// Represents a Enum.
class Enum extends Node {
  /// Parametric constructor for [Enum].
  Enum({
    required this.name,
    required this.members,
    this.documentationComments = const <String>[],
  });

  /// The name of the enum.
  String name;

  /// All of the members of the enum.
  List<EnumMember> members;

  /// List of documentation comments, separated by line.
  ///
  /// Lines should not include the comment marker itself, but should include any
  /// leading whitespace, so that any indentation in the original comment is preserved.
  /// For example: [" List of documentation comments, separated by line.", ...]
  List<String> documentationComments;

  @override
  String toString() {
    return '(Enum name:$name members:$members documentationComments:$documentationComments)';
  }
}

/// Represents a Enum member.
class EnumMember extends Node {
  /// Parametric constructor for [EnumMember].
  EnumMember({
    required this.name,
    this.documentationComments = const <String>[],
  });

  /// The name of the enum member.
  final String name;

  /// List of documentation comments, separated by line.
  ///
  /// Lines should not include the comment marker itself, but should include any
  /// leading whitespace, so that any indentation in the original comment is preserved.
  /// For example: [" List of documentation comments, separated by line.", ...]
  final List<String> documentationComments;

  @override
  String toString() {
    return '(EnumMember name:$name documentationComments:$documentationComments)';
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
