/// Enum that represents where an [Api] is located, on the host or Flutter.
enum ApiLocation {
  host,
  flutter,
}

/// Superclass for all AST nodes.
class Node {}

/// Represents a method on an [Api].
class Func extends Node {
  Func({this.name, this.returnType, this.argType});
  String name;
  String returnType;
  String argType;
}

/// Represents a collection of [Func]s that are hosted ona given [location].
class Api extends Node {
  Api({this.name, this.location, this.functions});
  String name;
  ApiLocation location;
  List<Func> functions;
}

/// Represents a field on a [Class].
class Field extends Node {
  Field({this.name, this.dataType});
  String name;
  String dataType;
}

/// Represents a class with [Field]s.
class Class extends Node {
  Class({this.name, this.fields});
  String name;
  List<Field> fields;
}

/// Top-level node for the AST.
class Root extends Node {
  Root({this.classes, this.apis});
  List<Class> classes;
  List<Api> apis;
}
