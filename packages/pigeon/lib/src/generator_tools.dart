// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:mirrors';

import 'package:yaml/yaml.dart' as yaml;

import 'ast.dart';
import 'generator.dart';

/// The current version of pigeon.
///
/// This must match the version in pubspec.yaml.
const String pigeonVersion = '26.0.1';

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
  /// Constructor which takes a [StringSink] [Indent] will wrap.
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
  ///
  /// [trimIndentation] flag finds the line with the fewest leading empty
  /// spaces and trims the beginning of all lines by this number.
  void format(
    String input, {
    bool leadingSpace = true,
    bool trailingNewline = true,
    bool trimIndentation = true,
  }) {
    final List<String> lines = input.split('\n');

    final int indentationToRemove =
        !trimIndentation
            ? 0
            : lines
                .where((String line) => line.trim().isNotEmpty)
                .map((String line) => line.length - line.trimLeft().length)
                .reduce(min);

    for (int i = 0; i < lines.length; ++i) {
      final String line =
          lines[i].length >= indentationToRemove
              ? lines[i].substring(indentationToRemove)
              : lines[i];

      if (i == 0 && !leadingSpace) {
        add(line.replaceAll('\t', tab));
      } else if (line.isNotEmpty) {
        write(line.replaceAll('\t', tab));
      }
      if (trailingNewline || i < lines.length - 1) {
        addln('');
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
    if (begin != null) {
      _sink.write(begin + newline);
    }
    nest(nestCount, func);
    if (end != null && end.isNotEmpty) {
      _sink.write(str() + end);
      if (addTrailingNewline) {
        _sink.write(newline);
      }
    }
  }

  /// Like `addScoped` but writes the current indentation level.
  void writeScoped(
    String? begin,
    String? end,
    Function func, {
    int nestCount = 1,
    bool addTrailingNewline = true,
  }) {
    addScoped(
      str() + (begin ?? ''),
      end,
      func,
      nestCount: nestCount,
      addTrailingNewline: addTrailingNewline,
    );
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

/// Create the generated channel name for a [method] on an [api].
String makeChannelName(Api api, Method method, String dartPackageName) {
  return makeChannelNameWithStrings(
    apiName: api.name,
    methodName: method.name,
    dartPackageName: dartPackageName,
  );
}

/// Create the generated channel name for a method on an api.
String makeChannelNameWithStrings({
  required String apiName,
  required String methodName,
  required String dartPackageName,
}) {
  return 'dev.flutter.pigeon.$dartPackageName.$apiName.$methodName';
}

// TODO(tarrinneal): Determine whether HostDataType is needed.

/// Represents the mapping of a Dart datatype to a Host datatype.
class HostDatatype {
  /// Parametric constructor for HostDatatype.
  HostDatatype({
    required this.datatype,
    required this.isBuiltin,
    required this.isNullable,
    required this.isEnum,
  });

  /// The [String] that can be printed into host code to represent the type.
  final String datatype;

  /// `true` if the host datatype is something builtin.
  final bool isBuiltin;

  /// `true` if the type corresponds to a nullable Dart datatype.
  final bool isNullable;

  /// `true if the type is a custom enum.
  final bool isEnum;
}

/// Calculates the [HostDatatype] for the provided [NamedType].
///
/// It will check the field against [classes], the list of custom classes, to
/// check if it is a builtin type. [builtinResolver] will return the host
/// datatype for the Dart datatype for builtin types.
///
/// [customResolver] can modify the datatype of custom types.
HostDatatype getFieldHostDatatype(
  NamedType field,
  String? Function(TypeDeclaration) builtinResolver, {
  String Function(String)? customResolver,
}) {
  return _getHostDatatype(
    field.type,
    builtinResolver,
    customResolver: customResolver,
    fieldName: field.name,
  );
}

/// Calculates the [HostDatatype] for the provided [TypeDeclaration].
///
/// It will check the field against [classes], the list of custom classes, to
/// check if it is a builtin type. [builtinResolver] will return the host
/// datatype for the Dart datatype for builtin types.
///
/// [customResolver] can modify the datatype of custom types.
HostDatatype getHostDatatype(
  TypeDeclaration type,
  String? Function(TypeDeclaration) builtinResolver, {
  String Function(String)? customResolver,
}) {
  return _getHostDatatype(
    type,
    builtinResolver,
    customResolver: customResolver,
  );
}

HostDatatype _getHostDatatype(
  TypeDeclaration type,
  String? Function(TypeDeclaration) builtinResolver, {
  String Function(String)? customResolver,
  String? fieldName,
}) {
  final String? datatype = builtinResolver(type);
  if (datatype == null) {
    if (type.isClass) {
      final String customName =
          customResolver != null
              ? customResolver(type.baseName)
              : type.baseName;
      return HostDatatype(
        datatype: customName,
        isBuiltin: false,
        isNullable: type.isNullable,
        isEnum: false,
      );
    } else if (type.isEnum) {
      final String customName =
          customResolver != null
              ? customResolver(type.baseName)
              : type.baseName;
      return HostDatatype(
        datatype: customName,
        isBuiltin: false,
        isNullable: type.isNullable,
        isEnum: true,
      );
    } else {
      throw Exception(
        'unrecognized datatype ${fieldName == null ? '' : 'for field:"$fieldName" '}of type:"${type.baseName}"',
      );
    }
  } else {
    return HostDatatype(
      datatype: datatype,
      isBuiltin: true,
      isNullable: type.isNullable,
      isEnum: false,
    );
  }
}

/// Whether or not to include the version in the generated warning.
///
/// This is a global rather than an option because it's only intended to be
/// used internally, to avoid churn in Pigeon test files.
bool includeVersionInGeneratedWarning = true;

/// Warning printed at the top of all generated code.
@Deprecated('Use getGeneratedCodeWarning() instead')
const String generatedCodeWarning =
    'Autogenerated from Pigeon (v$pigeonVersion), do not edit directly.';

/// Warning printed at the top of all generated code.
String getGeneratedCodeWarning() {
  final String versionString =
      includeVersionInGeneratedWarning ? ' (v$pigeonVersion)' : '';
  return 'Autogenerated from Pigeon$versionString, do not edit directly.';
}

/// String to be printed after `getGeneratedCodeWarning()'s warning`.
const String seeAlsoWarning = 'See also: https://pub.dev/packages/pigeon';

/// Prefix for generated internal classes.
///
/// This lowers the chances of variable name collisions with user defined
/// parameters.
const String classNamePrefix = 'PigeonInternal';

/// Prefix for utility classes generated to be used with ProxyAPIs.
///
/// This lowers the chances of variable name collisions with user defined
/// parameters.
const String proxyApiClassNamePrefix = 'Pigeon';

/// Prefix for the name of generated native type APIs of ProxyAPIs.
const String hostProxyApiPrefix = '${proxyApiClassNamePrefix}Api';

/// Prefix for class member names not defined by the user.
///
/// This lowers the chances of variable name collisions with user defined
/// parameters.
const String classMemberNamePrefix = 'pigeon_';

/// Prefix for variable names not defined by the user.
///
/// This lowers the chances of variable name collisions with user defined
/// parameters.
const String varNamePrefix = 'pigeonVar_';

/// Prefixes that are not allowed for any names of any types or methods.
const List<String> disallowedPrefixes = <String>[
  classNamePrefix,
  classMemberNamePrefix,
  hostProxyApiPrefix,
  proxyApiClassNamePrefix,
  varNamePrefix,
  'pigeonChannelCodec',
];

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
    indent.writeln(line.isNotEmpty ? '$prefix$line' : prefix.trimRight());
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
        result[entry.key] = mergeMaps(
          (base[entry.key] as Map<String, Object>?)!,
          entryValue,
        );
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

/// A type name that is enumerated.
class EnumeratedType {
  /// Constructor.
  EnumeratedType(
    this.name,
    this.enumeration,
    this.type, {
    this.associatedClass,
    this.associatedEnum,
  });

  /// The name of the type.
  final String name;

  /// The enumeration of the class.
  final int enumeration;

  /// The type of custom type of the enumerated type.
  final CustomTypes type;

  /// The associated Class that is represented by the [EnumeratedType].
  final Class? associatedClass;

  /// The associated Enum that is represented by the [EnumeratedType].
  final Enum? associatedEnum;

  /// Returns the offset of the enumeration.
  int offset(int offset) => enumeration - offset;
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

/// The dedicated key for the base codecs used to access references in the
/// InstanceManager.
///
/// Generated codecs override the `StandardMessageCodec` which reserves the byte
/// keys of 0-127, so this value is chosen because it is the lowest available
/// key.
///
/// See https://api.flutter.dev/flutter/services/StandardMessageCodec/writeValue.html
/// for more information on keys in MessageCodecs.
const int proxyApiCodecInstanceManagerKey = 128;

/// Custom codecs' custom types are enumerations begin at this number to
/// avoid collisions with the StandardMessageCodec.
const int minimumCodecFieldKey = proxyApiCodecInstanceManagerKey + 1;

/// The maximum codec enumeration allowed.
const int maximumCodecFieldKey = 255;

/// The total number of keys allowed in the custom codec.
const int totalCustomCodecKeysAllowed =
    maximumCodecFieldKey - minimumCodecFieldKey;

Iterable<TypeDeclaration> _getTypeArguments(TypeDeclaration type) sync* {
  for (final TypeDeclaration typeArg in type.typeArguments) {
    yield* _getTypeArguments(typeArg);
  }
  yield type;
}

bool _isUnseenCustomType(
  TypeDeclaration type,
  Set<String> referencedTypeNames,
) {
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
  List<Api> apis,
  List<Class> classes,
) {
  final _Bag<TypeDeclaration, int> references = _Bag<TypeDeclaration, int>();
  for (final Api api in apis) {
    for (final Method method in api.methods) {
      for (final NamedType field in method.parameters) {
        references.addMany(_getTypeArguments(field.type), field.offset);
      }
      references.addMany(_getTypeArguments(method.returnType), method.offset);
    }
    if (api is AstProxyApi) {
      for (final Constructor constructor in api.constructors) {
        for (final NamedType parameter in constructor.parameters) {
          references.addMany(
            _getTypeArguments(parameter.type),
            parameter.offset,
          );
        }
      }
      for (final ApiField field in api.fields) {
        references.addMany(_getTypeArguments(field.type), field.offset);
      }
    }
  }

  final Set<String> referencedTypeNames =
      references.map.keys.map((TypeDeclaration e) => e.baseName).toSet();
  final List<String> classesToCheck = List<String>.from(referencedTypeNames);
  while (classesToCheck.isNotEmpty) {
    final String next = classesToCheck.removeLast();
    final Class aClass = classes.firstWhere(
      (Class x) => x.name == next,
      orElse: () => Class(name: '', fields: <NamedType>[]),
    );
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

/// Find the [TypeDeclaration] that has the highest API requirement and its
/// version, [T].
///
/// [T] depends on the language. For example, Android uses an int while iOS uses
/// semantic versioning.
({TypeDeclaration type, T version})?
findHighestApiRequirement<T extends Object>(
  Iterable<TypeDeclaration> types, {
  required T? Function(TypeDeclaration) onGetApiRequirement,
  required Comparator<T> onCompare,
}) {
  Iterable<TypeDeclaration> addAllRecursive(TypeDeclaration type) sync* {
    yield type;
    if (type.typeArguments.isNotEmpty) {
      for (final TypeDeclaration typeArg in type.typeArguments) {
        yield* addAllRecursive(typeArg);
      }
    }
  }

  final Iterable<TypeDeclaration> allReferencedTypes = types
      .expand(addAllRecursive)
      .where((TypeDeclaration type) => onGetApiRequirement(type) != null);

  if (allReferencedTypes.isEmpty) {
    return null;
  }

  final TypeDeclaration typeWithHighestRequirement = allReferencedTypes.reduce((
    TypeDeclaration one,
    TypeDeclaration two,
  ) {
    return onCompare(onGetApiRequirement(one)!, onGetApiRequirement(two)!) > 0
        ? one
        : two;
  });

  return (
    type: typeWithHighestRequirement,
    version: onGetApiRequirement(typeWithHighestRequirement)!,
  );
}

/// All custom definable data types.
enum CustomTypes {
  /// A custom Class.
  customClass,

  /// A custom Enum.
  customEnum,
}

/// Return the enumerated types that must exist in the codec
/// where the enumeration should be the key used in the buffer.
Iterable<EnumeratedType> getEnumeratedTypes(
  Root root, {
  bool excludeSealedClasses = false,
}) sync* {
  int index = 0;

  for (final Enum customEnum in root.enums) {
    yield EnumeratedType(
      customEnum.name,
      index + minimumCodecFieldKey,
      CustomTypes.customEnum,
      associatedEnum: customEnum,
    );
    index += 1;
  }

  for (final Class customClass in root.classes) {
    if (!excludeSealedClasses || !customClass.isSealed) {
      yield EnumeratedType(
        customClass.name,
        index + minimumCodecFieldKey,
        CustomTypes.customClass,
        associatedClass: customClass,
      );
      index += 1;
    }
  }
}

/// Checks if [root] contains enough custom types to require overflow codec tools.
bool customTypeOverflowCheck(Root root) {
  return root.classes.length + root.enums.length >
      maximumCodecFieldKey - minimumCodecFieldKey;
}

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
/// The [comments] list is meant for comments written in the input Dart file.
/// The [generatorComments] list is meant for comments added by the generators.
/// Include white space for all tokens when called, no assumptions are made.
void addDocumentationComments(
  Indent indent,
  List<String> comments,
  DocumentCommentSpecification commentSpec, {
  List<String> generatorComments = const <String>[],
}) {
  asDocumentationComments(
    comments,
    commentSpec,
    generatorComments: generatorComments,
  ).forEach(indent.writeln);
}

/// Formats documentation comments and adds them to current Indent.
///
/// The [comments] list is meant for comments written in the input Dart file.
/// The [generatorComments] list is meant for comments added by the generators.
/// Include white space for all tokens when called, no assumptions are made.
Iterable<String> asDocumentationComments(
  Iterable<String> comments,
  DocumentCommentSpecification commentSpec, {
  List<String> generatorComments = const <String>[],
}) sync* {
  final List<String> allComments = <String>[
    ...comments,
    if (comments.isNotEmpty && generatorComments.isNotEmpty) '',
    ...generatorComments,
  ];
  String currentLineOpenToken = commentSpec.openCommentToken;
  if (allComments.length > 1) {
    if (commentSpec.closeCommentToken != '') {
      yield commentSpec.openCommentToken;
      currentLineOpenToken = commentSpec.blockContinuationToken;
    }
    for (String line in allComments) {
      if (line.isNotEmpty && line[0] != ' ') {
        line = ' $line';
      }
      yield '$currentLineOpenToken$line';
    }
    if (commentSpec.closeCommentToken != '') {
      yield commentSpec.closeCommentToken;
    }
  } else if (allComments.length == 1) {
    yield '$currentLineOpenToken${allComments.first}${commentSpec.closeCommentToken}';
  }
}

/// Returns an ordered list of fields to provide consistent serialization order.
Iterable<NamedType> getFieldsInSerializationOrder(Class classDefinition) {
  // This returns the fields in the order they are declared in the pigeon file.
  return classDefinition.fields;
}

/// Crawls up the path of [dartFilePath] until it finds a pubspec.yaml in a
/// parent directory and returns its path.
String? _findPubspecPath(String dartFilePath) {
  try {
    Directory dir = File(dartFilePath).parent;
    String? pubspecPath;
    while (pubspecPath == null) {
      if (dir.existsSync()) {
        final Iterable<String> pubspecPaths = dir
            .listSync()
            .map((FileSystemEntity e) => e.path)
            .where((String path) => path.endsWith('pubspec.yaml'));
        if (pubspecPaths.isNotEmpty) {
          pubspecPath = pubspecPaths.first;
        } else {
          dir = dir.parent;
        }
      } else {
        break;
      }
    }
    return pubspecPath;
  } catch (ex) {
    return null;
  }
}

/// Given the path of a Dart file, [mainDartFile], the name of the package will
/// be deduced by locating and parsing its associated pubspec.yaml.
String? deducePackageName(String mainDartFile) {
  final String? pubspecPath = _findPubspecPath(mainDartFile);
  if (pubspecPath == null) {
    return null;
  }

  try {
    final String text = File(pubspecPath).readAsStringSync();
    return (yaml.loadYaml(text) as Map<dynamic, dynamic>)['name'] as String?;
  } catch (_) {
    return null;
  }
}

/// Enum to specify api type when generating code.
enum ApiType {
  /// Flutter api.
  flutter,

  /// Host api.
  host,
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
class OutputFileOptions<T extends InternalOptions> extends InternalOptions {
  /// Constructor.
  OutputFileOptions({required this.fileType, required this.languageOptions});

  /// To specify which file type should be created.
  FileType fileType;

  /// Options for specified language across all file types.
  T languageOptions;
}

/// Converts strings to Upper Camel Case.
String toUpperCamelCase(String text) {
  final RegExp separatorPattern = RegExp(r'[ _-]');
  return text.split(separatorPattern).map((String word) {
    return word.isEmpty
        ? ''
        : word.substring(0, 1).toUpperCase() + word.substring(1);
  }).join();
}

/// Converts strings to Lower Camel Case.
String toLowerCamelCase(String text) {
  final RegExp separatorPattern = RegExp(r'[ _-]');
  bool firstWord = true;
  return text.split(separatorPattern).map((String word) {
    if (word.isEmpty) {
      return '';
    }
    if (firstWord) {
      firstWord = false;
      return word.substring(0, 1).toLowerCase() + word.substring(1);
    }
    return word.substring(0, 1).toUpperCase() + word.substring(1);
  }).join();
}

/// Converts string to SCREAMING_SNAKE_CASE.
String toScreamingSnakeCase(String string) {
  return string
      .replaceAllMapped(
        RegExp(r'(?<=[a-z])[A-Z]'),
        (Match m) => '_${m.group(0)}',
      )
      .toUpperCase();
}

/// The channel name for the `removeStrongReference` method of the
/// `InstanceManager` API.
///
/// This ensures the channel name is the same for all languages.
String makeRemoveStrongReferenceChannelName(String dartPackageName) {
  return makeChannelNameWithStrings(
    apiName: '${classNamePrefix}InstanceManager',
    methodName: 'removeStrongReference',
    dartPackageName: dartPackageName,
  );
}

/// The channel name for the `clear` method of the `InstanceManager` API.
///
/// This ensures the channel name is the same for all languages.
String makeClearChannelName(String dartPackageName) {
  return makeChannelNameWithStrings(
    apiName: '${classNamePrefix}InstanceManager',
    methodName: 'clear',
    dartPackageName: dartPackageName,
  );
}

/// Whether the type is a collection.
bool isCollectionType(TypeDeclaration type) {
  return !type.isClass &&
      !type.isEnum &&
      !type.isProxyApi &&
      (type.baseName.contains('List') || type.baseName == 'Map');
}
