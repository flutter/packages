// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';

import 'ast.dart';

/// The current version of pigeon.
///
/// This must match the version in pubspec.yaml.
const String pigeonVersion = '9.0.2';

/// Read all the content from [stdin] to a String.
String readStdin() {
  final List<int> bytes = <int>[];
  int byte = stdin.readByteSync();
  while (byte >= 0) {
    bytes.add(byte);
    byte = stdin.readByteSync();
  }
  return utf8.decode(bytes);
}

/// True if the generator line number should be printed out at the end of newlines.
bool debugGenerators = false;

/// A helper class for managing indentation, wrapping a [StringSink].
class Indent {
  /// Constructor which takes a [StringSink] [Ident] will wrap.
  Indent(this._sink);

  int _count = 0;
  final StringSink _sink;

  /// String used for newlines (ex "\n").
  String get newline {
    if (debugGenerators) {
      final List<String> frames = StackTrace.current.toString().split('\n');
      return ' //${frames.firstWhere((String x) => x.contains('_generator.dart'))}\n';
    } else {
      return '\n';
    }
  }

  /// String used to represent a tab.
  final String tab = '  ';

  /// Increase the indentation level.
  void inc([int level = 1]) {
    _count += level;
  }

  /// Decrement the indentation level.
  void dec([int level = 1]) {
    _count -= level;
  }

  /// Returns the String representing the current indentation.
  String str() {
    String result = '';
    for (int i = 0; i < _count; i++) {
      result += tab;
    }
    return result;
  }

  /// Replaces the newlines and tabs of input and adds it to the stream.
  void format(String input,
      {bool leadingSpace = true, bool trailingNewline = true}) {
    final List<String> lines = input.split('\n');
    for (int i = 0; i < lines.length; ++i) {
      final String line = lines[i];
      if (i == 0 && !leadingSpace) {
        addln(line.replaceAll('\t', tab));
      } else if (i == lines.length - 1 && !trailingNewline) {
        write(line.replaceAll('\t', tab));
      } else {
        writeln(line.replaceAll('\t', tab));
      }
    }
  }

  /// Scoped increase of the indent level.
  ///
  /// For the execution of [func] the indentation will be incremented.
  void addScoped(
    String? begin,
    String? end,
    Function func, {
    bool addTrailingNewline = true,
    int nestCount = 1,
  }) {
    assert(begin != '' || end != '',
        'Use nest for indentation without any decoration');
    if (begin != null) {
      _sink.write(begin + newline);
    }
    nest(nestCount, func);
    if (end != null) {
      _sink.write(str() + end);
      if (addTrailingNewline) {
        _sink.write(newline);
      }
    }
  }

  /// Like `addScoped` but writes the current indentation level.
  void writeScoped(
    String? begin,
    String end,
    Function func, {
    bool addTrailingNewline = true,
  }) {
    assert(begin != '' || end != '',
        'Use nest for indentation without any decoration');
    addScoped(str() + (begin ?? ''), end, func,
        addTrailingNewline: addTrailingNewline);
  }

  /// Scoped increase of the indent level.
  ///
  /// For the execution of [func] the indentation will be incremented by the given amount.
  void nest(int count, Function func) {
    inc(count);
    func(); // ignore: avoid_dynamic_calls
    dec(count);
  }

  /// Add [text] with indentation and a newline.
  void writeln(String text) {
    if (text.isEmpty) {
      _sink.write(newline);
    } else {
      _sink.write(str() + text + newline);
    }
  }

  /// Add [text] with indentation.
  void write(String text) {
    _sink.write(str() + text);
  }

  /// Add [text] with a newline.
  void addln(String text) {
    _sink.write(text + newline);
  }

  /// Just adds [text].
  void add(String text) {
    _sink.write(text);
  }

  /// Adds [lines] number of newlines.
  void newln([int lines = 1]) {
    for (; lines > 0; lines--) {
      _sink.write(newline);
    }
  }
}

/// Create the generated channel name for a [func] on a [api].
String makeChannelName(Api api, Method func) {
  return 'dev.flutter.pigeon.${api.name}.${func.name}';
}

/// Represents the mapping of a Dart datatype to a Host datatype.
class HostDatatype {
  /// Parametric constructor for HostDatatype.
  HostDatatype({
    required this.datatype,
    required this.isBuiltin,
    required this.isNullable,
  });

  /// The [String] that can be printed into host code to represent the type.
  final String datatype;

  /// `true` if the host datatype is something builtin.
  final bool isBuiltin;

  /// `true` if the type corresponds to a nullable Dart datatype.
  final bool isNullable;
}

/// Calculates the [HostDatatype] for the provided [NamedType].
///
/// It will check the field against [classes], the list of custom classes, to
/// check if it is a builtin type. [builtinResolver] will return the host
/// datatype for the Dart datatype for builtin types.
///
/// [customResolver] can modify the datatype of custom types.
HostDatatype getFieldHostDatatype(NamedType field, List<Class> classes,
    List<Enum> enums, String? Function(TypeDeclaration) builtinResolver,
    {String Function(String)? customResolver}) {
  return _getHostDatatype(field.type, classes, enums, builtinResolver,
      customResolver: customResolver, fieldName: field.name);
}

/// Calculates the [HostDatatype] for the provided [TypeDeclaration].
///
/// It will check the field against [classes], the list of custom classes, to
/// check if it is a builtin type. [builtinResolver] will return the host
/// datatype for the Dart datatype for builtin types.
///
/// [customResolver] can modify the datatype of custom types.
HostDatatype getHostDatatype(TypeDeclaration type, List<Class> classes,
    List<Enum> enums, String? Function(TypeDeclaration) builtinResolver,
    {String Function(String)? customResolver}) {
  return _getHostDatatype(type, classes, enums, builtinResolver,
      customResolver: customResolver);
}

HostDatatype _getHostDatatype(TypeDeclaration type, List<Class> classes,
    List<Enum> enums, String? Function(TypeDeclaration) builtinResolver,
    {String Function(String)? customResolver, String? fieldName}) {
  final String? datatype = builtinResolver(type);
  if (datatype == null) {
    if (classes.map((Class x) => x.name).contains(type.baseName)) {
      final String customName = customResolver != null
          ? customResolver(type.baseName)
          : type.baseName;
      return HostDatatype(
          datatype: customName, isBuiltin: false, isNullable: type.isNullable);
    } else if (enums.map((Enum x) => x.name).contains(type.baseName)) {
      final String customName = customResolver != null
          ? customResolver(type.baseName)
          : type.baseName;
      return HostDatatype(
          datatype: customName, isBuiltin: false, isNullable: type.isNullable);
    } else {
      throw Exception(
          'unrecognized datatype ${fieldName == null ? '' : 'for field:"$fieldName" '}of type:"${type.baseName}"');
    }
  } else {
    return HostDatatype(
        datatype: datatype, isBuiltin: true, isNullable: type.isNullable);
  }
}

/// Warning printed at the top of all generated code.
const String generatedCodeWarning =
    'Autogenerated from Pigeon (v$pigeonVersion), do not edit directly.';

/// String to be printed after `generatedCodeWarning`.
const String seeAlsoWarning = 'See also: https://pub.dev/packages/pigeon';

/// Collection of keys used in dictionaries across generators.
class Keys {
  /// The key in the result hash for the 'result' value.
  static const String result = 'result';

  /// The key in the result hash for the 'error' value.
  static const String error = 'error';

  /// The key in an error hash for the 'code' value.
  static const String errorCode = 'code';

  /// The key in an error hash for the 'message' value.
  static const String errorMessage = 'message';

  /// The key in an error hash for the 'details' value.
  static const String errorDetails = 'details';
}

/// Returns true if `type` represents 'void'.
bool isVoid(TypeMirror type) {
  return MirrorSystem.getName(type.simpleName) == 'void';
}

/// Adds the [lines] to [indent].
void addLines(Indent indent, Iterable<String> lines, {String? linePrefix}) {
  final String prefix = linePrefix ?? '';
  for (final String line in lines) {
    indent.writeln('$prefix$line');
  }
}

/// Recursively merges [modification] into [base].
///
/// In other words, whenever there is a conflict over the value of a key path,
/// [modification]'s value for that key path is selected.
Map<String, Object> mergeMaps(
  Map<String, Object> base,
  Map<String, Object> modification,
) {
  final Map<String, Object> result = <String, Object>{};
  for (final MapEntry<String, Object> entry in modification.entries) {
    if (base.containsKey(entry.key)) {
      final Object entryValue = entry.value;
      if (entryValue is Map<String, Object>) {
        assert(base[entry.key] is Map<String, Object>);
        result[entry.key] =
            mergeMaps((base[entry.key] as Map<String, Object>?)!, entryValue);
      } else {
        result[entry.key] = entry.value;
      }
    } else {
      result[entry.key] = entry.value;
    }
  }
  for (final MapEntry<String, Object> entry in base.entries) {
    if (!result.containsKey(entry.key)) {
      result[entry.key] = entry.value;
    }
  }
  return result;
}

/// A class name that is enumerated.
class EnumeratedClass {
  /// Constructor.
  EnumeratedClass(this.name, this.enumeration);

  /// The name of the class.
  final String name;

  /// The enumeration of the class.
  final int enumeration;
}

/// Supported basic datatypes.
const List<String> validTypes = <String>[
  'String',
  'bool',
  'int',
  'double',
  'Uint8List',
  'Int32List',
  'Int64List',
  'Float64List',
  'List',
  'Map',
  'Object',
];

/// Custom codecs' custom types are enumerated from 255 down to this number to
/// avoid collisions with the StandardMessageCodec.
const int _minimumCodecFieldKey = 128;

Iterable<TypeDeclaration> _getTypeArguments(TypeDeclaration type) sync* {
  for (final TypeDeclaration typeArg in type.typeArguments) {
    yield* _getTypeArguments(typeArg);
  }
  yield type;
}

bool _isUnseenCustomType(
    TypeDeclaration type, Set<String> referencedTypeNames) {
  return !referencedTypeNames.contains(type.baseName) &&
      !validTypes.contains(type.baseName);
}

class _Bag<Key, Value> {
  Map<Key, List<Value>> map = <Key, List<Value>>{};
  void add(Key key, Value? value) {
    if (!map.containsKey(key)) {
      map[key] = value == null ? <Value>[] : <Value>[value];
    } else {
      if (value != null) {
        map[key]!.add(value);
      }
    }
  }

  void addMany(Iterable<Key> keys, Value? value) {
    for (final Key key in keys) {
      add(key, value);
    }
  }
}

/// Recurses into a list of [Api]s and produces a list of all referenced types
/// and an associated [List] of the offsets where they are found.
Map<TypeDeclaration, List<int>> getReferencedTypes(
    List<Api> apis, List<Class> classes) {
  final _Bag<TypeDeclaration, int> references = _Bag<TypeDeclaration, int>();
  for (final Api api in apis) {
    for (final Method method in api.methods) {
      for (final NamedType field in method.arguments) {
        references.addMany(_getTypeArguments(field.type), field.offset);
      }
      references.addMany(_getTypeArguments(method.returnType), method.offset);
    }
  }

  final Set<String> referencedTypeNames =
      references.map.keys.map((TypeDeclaration e) => e.baseName).toSet();
  final List<String> classesToCheck = List<String>.from(referencedTypeNames);
  while (classesToCheck.isNotEmpty) {
    final String next = classesToCheck.removeLast();
    final Class aClass = classes.firstWhere((Class x) => x.name == next,
        orElse: () => Class(name: '', fields: <NamedType>[]));
    for (final NamedType field in aClass.fields) {
      if (_isUnseenCustomType(field.type, referencedTypeNames)) {
        references.add(field.type, field.offset);
        classesToCheck.add(field.type.baseName);
      }
      for (final TypeDeclaration typeArg in field.type.typeArguments) {
        if (_isUnseenCustomType(typeArg, referencedTypeNames)) {
          references.add(typeArg, field.offset);
          classesToCheck.add(typeArg.baseName);
        }
      }
    }
  }
  return references.map;
}

/// Returns true if the concrete type cannot be determined at compile-time.
bool _isConcreteTypeAmbiguous(TypeDeclaration type) {
  return (type.baseName == 'List' && type.typeArguments.isEmpty) ||
      (type.baseName == 'Map' && type.typeArguments.isEmpty) ||
      type.baseName == 'Object';
}

/// Given an [Api], return the enumerated classes that must exist in the codec
/// where the enumeration should be the key used in the buffer.
Iterable<EnumeratedClass> getCodecClasses(Api api, Root root) sync* {
  final Set<String> enumNames = root.enums.map((Enum e) => e.name).toSet();
  final Map<TypeDeclaration, List<int>> referencedTypes =
      getReferencedTypes(<Api>[api], root.classes);
  final Iterable<String> allTypeNames =
      referencedTypes.keys.any(_isConcreteTypeAmbiguous)
          ? root.classes.map((Class aClass) => aClass.name)
          : referencedTypes.keys.map((TypeDeclaration e) => e.baseName);
  final List<String> sortedNames = allTypeNames
      .where((String element) =>
          element != 'void' &&
          !validTypes.contains(element) &&
          !enumNames.contains(element))
      .toList();
  sortedNames.sort();
  int enumeration = _minimumCodecFieldKey;
  const int maxCustomClassesPerApi = 255 - _minimumCodecFieldKey;
  if (sortedNames.length > maxCustomClassesPerApi) {
    throw Exception(
        "Pigeon doesn't support more than $maxCustomClassesPerApi referenced custom classes per API, try splitting up your APIs.");
  }
  for (final String name in sortedNames) {
    yield EnumeratedClass(name, enumeration);
    enumeration += 1;
  }
}

/// Returns true if the [TypeDeclaration] represents an enum.
bool isEnum(Root root, TypeDeclaration type) =>
    root.enums.map((Enum e) => e.name).contains(type.baseName);

/// Describes how to format a document comment.
class DocumentCommentSpecification {
  /// Constructor for [DocumentationCommentSpecification]
  const DocumentCommentSpecification(
    this.openCommentToken, {
    this.closeCommentToken = '',
    this.blockContinuationToken = '',
  });

  /// Token that represents the open symbol for a documentation comment.
  final String openCommentToken;

  /// Token that represents the closing symbol for a documentation comment.
  final String closeCommentToken;

  /// Token that represents the continuation symbol for a block of documentation comments.
  final String blockContinuationToken;
}

/// Formats documentation comments and adds them to current Indent.
///
/// The [comments] list is meant for comments written in the input dart file.
/// The [generatorComments] list is meant for comments added by the generators.
/// Include white space for all tokens when called, no assumptions are made.
void addDocumentationComments(
  Indent indent,
  List<String> comments,
  DocumentCommentSpecification commentSpec, {
  List<String> generatorComments = const <String>[],
}) {
  final List<String> allComments = <String>[
    ...comments,
    if (comments.isNotEmpty && generatorComments.isNotEmpty) '',
    ...generatorComments,
  ];
  String currentLineOpenToken = commentSpec.openCommentToken;
  if (allComments.length > 1) {
    if (commentSpec.closeCommentToken != '') {
      indent.writeln(commentSpec.openCommentToken);
      currentLineOpenToken = commentSpec.blockContinuationToken;
    }
    for (String line in allComments) {
      if (line.isNotEmpty && line[0] != ' ') {
        line = ' $line';
      }
      indent.writeln(
        '$currentLineOpenToken$line',
      );
    }
    if (commentSpec.closeCommentToken != '') {
      indent.writeln(commentSpec.closeCommentToken);
    }
  } else if (allComments.length == 1) {
    indent.writeln(
      '$currentLineOpenToken${allComments.first}${commentSpec.closeCommentToken}',
    );
  }
}

/// Returns an ordered list of fields to provide consistent serialisation order.
Iterable<NamedType> getFieldsInSerializationOrder(Class klass) {
  // This returns the fields in the order they are declared in the pigeon file.
  return klass.fields;
}

/// Enum to specify which file will be generated for multi-file generators
enum FileType {
  /// header file.
  header,

  /// source file.
  source,

  /// file type is not applicable.
  na,
}

/// Options for [Generator]s that have multiple output file types.
///
/// Specifies which file to write as well as wraps all language options.
class OutputFileOptions<T> {
  /// Constructor.
  OutputFileOptions({required this.fileType, required this.languageOptions});

  /// To specify which file type should be created.
  FileType fileType;

  /// Options for specified language across all file types.
  T languageOptions;
}
