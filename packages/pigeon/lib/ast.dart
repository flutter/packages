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
class Func extends Node {
  /// Parametric constructor for [Func].
  Func({this.name, this.returnType, this.argType});

  /// The name of the method.
  String name;

  /// The data-type of the return value.
  String returnType;

  /// The data-type of the argument.
  String argType;
}

/// Represents a collection of [Func]s that are hosted ona given [location].
class Api extends Node {
  /// Parametric constructor for [Api].
  Api({this.name, this.location, this.functions});

  /// The name of the API.
  String name;

  /// Where the API's implementation is located, host or Flutter.
  ApiLocation location;

  /// List of functions inside the API.
  List<Func> functions;
}

/// Represents a field on a [Class].
class Field extends Node {
  /// Parametric constructor for [Field].
  Field({this.name, this.dataType});

  /// The name of the field.
  String name;

  /// The data-type of the field (ex 'String' or 'int').
  String dataType;
}

/// Represents a class with [Field]s.
class Class extends Node {
  /// Parametric constructor for [Class].
  Class({this.name, this.fields});

  /// The name of the class.
  String name;

  /// All the fields contained in the class.
  List<Field> fields;
}

/// Top-level node for the AST.
class Root extends Node {
  /// Parametric constructor for [Root].
  Root({this.classes, this.apis});

  /// All the classes contained in the AST.
  List<Class> classes;

  /// All the API's contained in the AST.
  List<Api> apis;
}
