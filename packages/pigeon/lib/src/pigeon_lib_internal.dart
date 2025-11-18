// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart' as dart_ast;
import 'package:analyzer/dart/ast/syntactic_entity.dart'
    as dart_ast_syntactic_entity;
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart' as dart_ast_visitor;
import 'package:collection/collection.dart' as collection;
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';

import 'ast.dart';
import 'ast_generator.dart';
import 'cpp/cpp_generator.dart';
import 'dart/dart_generator.dart';
import 'generator_tools.dart';
import 'gobject/gobject_generator.dart';
import 'java/java_generator.dart';
import 'kotlin/kotlin_generator.dart';
import 'objc/objc_generator.dart';
import 'pigeon_lib.dart';
import 'swift/swift_generator.dart';

/// Options used when running the code generator.
class InternalPigeonOptions {
  /// Creates a instance of InternalPigeonOptions
  const InternalPigeonOptions({
    required this.input,
    required this.objcOptions,
    required this.javaOptions,
    required this.swiftOptions,
    required this.kotlinOptions,
    required this.cppOptions,
    required this.gobjectOptions,
    required this.dartOptions,
    this.copyrightHeader,
    this.astOut,
    this.debugGenerators,
    this.basePath,
    required this.dartPackageName,
  });

  InternalPigeonOptions._fromPigeonOptionsWithHeader(
    PigeonOptions options,
    Iterable<String>? copyrightHeader,
  ) : input = options.input,
      objcOptions =
          (options.objcHeaderOut == null || options.objcSourceOut == null)
          ? null
          : InternalObjcOptions.fromObjcOptions(
              options.objcOptions ?? const ObjcOptions(),
              objcHeaderOut: options.objcHeaderOut!,
              objcSourceOut: options.objcSourceOut!,
              fileSpecificClassNameComponent:
                  options.objcSourceOut
                      ?.split('/')
                      .lastOrNull
                      ?.split('.')
                      .firstOrNull ??
                  '',
              copyrightHeader: copyrightHeader,
            ),
      javaOptions = options.javaOut == null
          ? null
          : InternalJavaOptions.fromJavaOptions(
              options.javaOptions ?? const JavaOptions(),
              javaOut: options.javaOut!,
              copyrightHeader: copyrightHeader,
            ),
      swiftOptions = options.swiftOut == null
          ? null
          : InternalSwiftOptions.fromSwiftOptions(
              options.swiftOptions ?? const SwiftOptions(),
              swiftOut: options.swiftOut!,
              copyrightHeader: copyrightHeader,
            ),
      kotlinOptions = options.kotlinOut == null
          ? null
          : InternalKotlinOptions.fromKotlinOptions(
              options.kotlinOptions ?? const KotlinOptions(),
              kotlinOut: options.kotlinOut!,
              copyrightHeader: copyrightHeader,
            ),
      cppOptions =
          (options.cppHeaderOut == null || options.cppSourceOut == null)
          ? null
          : InternalCppOptions.fromCppOptions(
              options.cppOptions ?? const CppOptions(),
              cppHeaderOut: options.cppHeaderOut!,
              cppSourceOut: options.cppSourceOut!,
              copyrightHeader: copyrightHeader,
            ),
      gobjectOptions =
          options.gobjectHeaderOut == null || options.gobjectSourceOut == null
          ? null
          : InternalGObjectOptions.fromGObjectOptions(
              options.gobjectOptions ?? const GObjectOptions(),
              gobjectHeaderOut: options.gobjectHeaderOut!,
              gobjectSourceOut: options.gobjectSourceOut!,
              copyrightHeader: copyrightHeader,
            ),
      dartOptions =
          (options.dartOut == null &&
              options.dartOptions?.sourceOutPath == null)
          ? null
          : InternalDartOptions.fromDartOptions(
              options.dartOptions ?? const DartOptions(),
              dartOut: options.dartOut,
              testOut: options.dartTestOut,
              copyrightHeader: copyrightHeader,
            ),
      copyrightHeader = options.copyrightHeader != null
          ? _lineReader(
              path.posix.join(options.basePath ?? '', options.copyrightHeader),
            )
          : null,
      astOut = options.astOut,
      debugGenerators = options.debugGenerators,
      basePath = options.basePath,
      dartPackageName = options.getPackageName();

  /// Creates a instance of InternalPigeonOptions from PigeonOptions.
  static InternalPigeonOptions fromPigeonOptions(PigeonOptions options) {
    final Iterable<String>? copyrightHeader = options.copyrightHeader != null
        ? _lineReader(
            path.posix.join(options.basePath ?? '', options.copyrightHeader),
          )
        : null;

    return InternalPigeonOptions._fromPigeonOptionsWithHeader(
      options,
      copyrightHeader,
    );
  }

  /// Path to the file which will be processed.
  final String? input;

  /// Options that control how Dart will be generated.
  final InternalDartOptions? dartOptions;

  /// Options that control how Objective-C will be generated.
  final InternalObjcOptions? objcOptions;

  /// Options that control how Java will be generated.
  final InternalJavaOptions? javaOptions;

  /// Options that control how Swift will be generated.
  final InternalSwiftOptions? swiftOptions;

  /// Options that control how Kotlin will be generated.
  final InternalKotlinOptions? kotlinOptions;

  /// Options that control how C++ will be generated.
  final InternalCppOptions? cppOptions;

  /// Options that control how GObject source will be generated.
  final InternalGObjectOptions? gobjectOptions;

  /// Path to a copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// Path to AST debugging output.
  final String? astOut;

  /// True means print out line number of generators in comments at newlines.
  final bool? debugGenerators;

  /// A base path to be prepended to all provided output paths.
  final String? basePath;

  /// The name of the package the pigeon files will be used in.
  final String dartPackageName;
}

Iterable<String> _lineReader(String path) sync* {
  final String contents = File(path).readAsStringSync();
  const LineSplitter lineSplitter = LineSplitter();
  final List<String> lines = lineSplitter.convert(contents);
  for (final String line in lines) {
    yield line;
  }
}

IOSink? _openSink(String? output, {String basePath = ''}) {
  if (output == null) {
    return null;
  }
  IOSink sink;
  File file;
  if (output == 'stdout') {
    sink = stdout;
  } else {
    file = File(path.posix.join(basePath, output));
    file.createSync(recursive: true);
    sink = file.openWrite();
  }
  return sink;
}

/// An adapter that will call a generator to write code to a sink
/// based on the contents of [InternalPigeonOptions].
abstract class GeneratorAdapter {
  /// Constructor for [GeneratorAdapter]
  GeneratorAdapter(this.fileTypeList);

  /// A list of file types the generator should create.
  List<FileType> fileTypeList;

  /// Returns an [IOSink] instance to be written to
  /// if the [GeneratorAdapter] should generate.
  ///
  /// If it returns `null`, the [GeneratorAdapter] will be skipped.
  IOSink? shouldGenerate(InternalPigeonOptions options, FileType fileType);

  /// Write the generated code described in [root] to [sink] using the [options].
  void generate(
    StringSink sink,
    InternalPigeonOptions options,
    Root root,
    FileType fileType,
  );

  /// Generates errors that would only be appropriate for this [GeneratorAdapter].
  ///
  /// For example, if a certain feature isn't implemented in a [GeneratorAdapter] yet.
  List<Error> validate(InternalPigeonOptions options, Root root);
}

void _errorOnEventChannelApi(List<Error> errors, String generator, Root root) {
  if (root.containsEventChannel) {
    errors.add(Error(message: '$generator does not support event channels'));
  }
}

void _errorOnSealedClass(List<Error> errors, String generator, Root root) {
  if (root.classes.any((Class element) => element.isSealed)) {
    errors.add(Error(message: '$generator does not support sealed classes'));
  }
}

void _errorOnInheritedClass(List<Error> errors, String generator, Root root) {
  if (root.classes.any((Class element) => element.superClass != null)) {
    errors.add(
      Error(message: '$generator does not support inheritance in classes'),
    );
  }
}

/// A [GeneratorAdapter] that generates the AST.
class AstGeneratorAdapter implements GeneratorAdapter {
  /// Constructor for [AstGeneratorAdapter].
  AstGeneratorAdapter();

  @override
  List<FileType> fileTypeList = const <FileType>[FileType.na];

  @override
  void generate(
    StringSink sink,
    InternalPigeonOptions options,
    Root root,
    FileType fileType,
  ) {
    generateAst(root, sink);
  }

  @override
  IOSink? shouldGenerate(InternalPigeonOptions options, FileType _) =>
      _openSink(options.astOut, basePath: options.basePath ?? '');

  @override
  List<Error> validate(InternalPigeonOptions options, Root root) => <Error>[];
}

/// A [GeneratorAdapter] that generates Dart source code.
class DartGeneratorAdapter implements GeneratorAdapter {
  /// Constructor for [DartGeneratorAdapter].
  DartGeneratorAdapter();

  /// A string representing the name of the language being generated.
  String languageString = 'Dart';

  @override
  List<FileType> fileTypeList = const <FileType>[FileType.na];

  @override
  void generate(
    StringSink sink,
    InternalPigeonOptions options,
    Root root,
    FileType fileType,
  ) {
    if (options.dartOptions == null) {
      return;
    }

    const DartGenerator generator = DartGenerator();
    generator.generate(
      options.dartOptions!,
      root,
      sink,
      dartPackageName: options.dartPackageName,
    );
  }

  @override
  IOSink? shouldGenerate(InternalPigeonOptions options, FileType _) =>
      _openSink(options.dartOptions?.dartOut, basePath: options.basePath ?? '');

  @override
  List<Error> validate(InternalPigeonOptions options, Root root) => <Error>[];
}

/// A [GeneratorAdapter] that generates Dart test source code.
class DartTestGeneratorAdapter implements GeneratorAdapter {
  /// Constructor for [DartTestGeneratorAdapter].
  DartTestGeneratorAdapter();

  @override
  List<FileType> fileTypeList = const <FileType>[FileType.na];

  @override
  void generate(
    StringSink sink,
    InternalPigeonOptions options,
    Root root,
    FileType fileType,
  ) {
    if (options.dartOptions == null) {
      return;
    }
    const DartGenerator testGenerator = DartGenerator();
    // The test code needs the actual package name of the Dart output, even if
    // the package name has been overridden for other uses.
    final String outputPackageName =
        deducePackageName(options.dartOptions?.dartOut ?? '') ??
        options.dartPackageName;
    testGenerator.generateTest(
      options.dartOptions!,
      root,
      sink,
      dartPackageName: options.dartPackageName,
      dartOutputPackageName: outputPackageName,
    );
  }

  @override
  IOSink? shouldGenerate(InternalPigeonOptions options, FileType _) {
    if (options.dartOptions?.testOut != null) {
      return _openSink(
        options.dartOptions?.testOut,
        basePath: options.basePath ?? '',
      );
    }
    return null;
  }

  @override
  List<Error> validate(InternalPigeonOptions options, Root root) => <Error>[];
}

/// A [GeneratorAdapter] that generates Objective-C code.
class ObjcGeneratorAdapter implements GeneratorAdapter {
  /// Constructor for [ObjcGeneratorAdapter].
  ObjcGeneratorAdapter({
    this.fileTypeList = const <FileType>[FileType.header, FileType.source],
  });

  /// A string representing the name of the language being generated.
  String languageString = 'Objective-C';

  @override
  List<FileType> fileTypeList;

  @override
  void generate(
    StringSink sink,
    InternalPigeonOptions options,
    Root root,
    FileType fileType,
  ) {
    if (options.objcOptions == null) {
      return;
    }
    final OutputFileOptions<InternalObjcOptions> outputFileOptions =
        OutputFileOptions<InternalObjcOptions>(
          fileType: fileType,
          languageOptions: options.objcOptions!,
        );
    const ObjcGenerator generator = ObjcGenerator();
    generator.generate(
      outputFileOptions,
      root,
      sink,
      dartPackageName: options.dartPackageName,
    );
  }

  @override
  IOSink? shouldGenerate(InternalPigeonOptions options, FileType fileType) {
    if (fileType == FileType.source) {
      return _openSink(
        options.objcOptions?.objcSourceOut,
        basePath: options.basePath ?? '',
      );
    } else {
      return _openSink(
        options.objcOptions?.objcHeaderOut,
        basePath: options.basePath ?? '',
      );
    }
  }

  @override
  List<Error> validate(InternalPigeonOptions options, Root root) {
    final List<Error> errors = <Error>[];
    _errorOnEventChannelApi(errors, languageString, root);
    _errorOnSealedClass(errors, languageString, root);
    _errorOnInheritedClass(errors, languageString, root);
    return errors;
  }
}

/// A [GeneratorAdapter] that generates Java source code.
class JavaGeneratorAdapter implements GeneratorAdapter {
  /// Constructor for [JavaGeneratorAdapter].
  JavaGeneratorAdapter();

  /// A string representing the name of the language being generated.
  String languageString = 'Java';

  @override
  List<FileType> fileTypeList = const <FileType>[FileType.na];

  @override
  void generate(
    StringSink sink,
    InternalPigeonOptions options,
    Root root,
    FileType fileType,
  ) {
    if (options.javaOptions == null) {
      return;
    }
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      options.javaOptions!,
      root,
      sink,
      dartPackageName: options.dartPackageName,
    );
  }

  @override
  IOSink? shouldGenerate(InternalPigeonOptions options, FileType _) =>
      _openSink(options.javaOptions?.javaOut, basePath: options.basePath ?? '');

  @override
  List<Error> validate(InternalPigeonOptions options, Root root) {
    final List<Error> errors = <Error>[];
    _errorOnEventChannelApi(errors, languageString, root);
    _errorOnSealedClass(errors, languageString, root);
    _errorOnInheritedClass(errors, languageString, root);
    return errors;
  }
}

/// A [GeneratorAdapter] that generates Swift source code.
class SwiftGeneratorAdapter implements GeneratorAdapter {
  /// Constructor for [SwiftGeneratorAdapter].
  SwiftGeneratorAdapter();

  /// A string representing the name of the language being generated.
  String languageString = 'Swift';

  @override
  List<FileType> fileTypeList = const <FileType>[FileType.na];

  @override
  void generate(
    StringSink sink,
    InternalPigeonOptions options,
    Root root,
    FileType fileType,
  ) {
    if (options.swiftOptions == null) {
      return;
    }
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      options.swiftOptions!,
      root,
      sink,
      dartPackageName: options.dartPackageName,
    );
  }

  @override
  IOSink? shouldGenerate(InternalPigeonOptions options, FileType _) =>
      _openSink(
        options.swiftOptions?.swiftOut,
        basePath: options.basePath ?? '',
      );

  @override
  List<Error> validate(InternalPigeonOptions options, Root root) => <Error>[];
}

/// A [GeneratorAdapter] that generates C++ source code.
class CppGeneratorAdapter implements GeneratorAdapter {
  /// Constructor for [CppGeneratorAdapter].
  CppGeneratorAdapter({
    this.fileTypeList = const <FileType>[FileType.header, FileType.source],
  });

  /// A string representing the name of the language being generated.
  String languageString = 'C++';

  @override
  List<FileType> fileTypeList;

  @override
  void generate(
    StringSink sink,
    InternalPigeonOptions options,
    Root root,
    FileType fileType,
  ) {
    if (options.cppOptions == null) {
      return;
    }
    final OutputFileOptions<InternalCppOptions> outputFileOptions =
        OutputFileOptions<InternalCppOptions>(
          fileType: fileType,
          languageOptions: options.cppOptions!,
        );
    const CppGenerator generator = CppGenerator();
    generator.generate(
      outputFileOptions,
      root,
      sink,
      dartPackageName: options.dartPackageName,
    );
  }

  @override
  IOSink? shouldGenerate(InternalPigeonOptions options, FileType fileType) {
    if (fileType == FileType.source) {
      return _openSink(
        options.cppOptions?.cppSourceOut,
        basePath: options.basePath ?? '',
      );
    } else {
      return _openSink(
        options.cppOptions?.cppHeaderOut,
        basePath: options.basePath ?? '',
      );
    }
  }

  @override
  List<Error> validate(InternalPigeonOptions options, Root root) {
    final List<Error> errors = <Error>[];
    _errorOnEventChannelApi(errors, languageString, root);
    _errorOnSealedClass(errors, languageString, root);
    _errorOnInheritedClass(errors, languageString, root);
    return errors;
  }
}

/// A [GeneratorAdapter] that generates GObject source code.
class GObjectGeneratorAdapter implements GeneratorAdapter {
  /// Constructor for [GObjectGeneratorAdapter].
  GObjectGeneratorAdapter({
    this.fileTypeList = const <FileType>[FileType.header, FileType.source],
  });

  /// A string representing the name of the language being generated.
  String languageString = 'GObject';

  @override
  List<FileType> fileTypeList;

  @override
  void generate(
    StringSink sink,
    InternalPigeonOptions options,
    Root root,
    FileType fileType,
  ) {
    if (options.gobjectOptions == null) {
      return;
    }
    final OutputFileOptions<InternalGObjectOptions> outputFileOptions =
        OutputFileOptions<InternalGObjectOptions>(
          fileType: fileType,
          languageOptions: options.gobjectOptions!,
        );
    const GObjectGenerator generator = GObjectGenerator();
    generator.generate(
      outputFileOptions,
      root,
      sink,
      dartPackageName: options.dartPackageName,
    );
  }

  @override
  IOSink? shouldGenerate(InternalPigeonOptions options, FileType fileType) {
    if (fileType == FileType.source) {
      return _openSink(
        options.gobjectOptions?.gobjectSourceOut,
        basePath: options.basePath ?? '',
      );
    } else {
      return _openSink(
        options.gobjectOptions?.gobjectHeaderOut,
        basePath: options.basePath ?? '',
      );
    }
  }

  @override
  List<Error> validate(InternalPigeonOptions options, Root root) {
    final List<Error> errors = <Error>[];
    // TODO(tarrinneal): Remove once overflow class is added to gobject generator.
    // https://github.com/flutter/flutter/issues/152916
    if (root.classes.length + root.enums.length > totalCustomCodecKeysAllowed) {
      errors.add(
        Error(
          message:
              'GObject generator does not yet support more than $totalCustomCodecKeysAllowed custom types.',
        ),
      );
    }
    _errorOnEventChannelApi(errors, languageString, root);
    _errorOnSealedClass(errors, languageString, root);
    _errorOnInheritedClass(errors, languageString, root);

    return errors;
  }
}

/// A [GeneratorAdapter] that generates Kotlin source code.
class KotlinGeneratorAdapter implements GeneratorAdapter {
  /// Constructor for [KotlinGeneratorAdapter].
  KotlinGeneratorAdapter({this.fileTypeList = const <FileType>[FileType.na]});

  @override
  List<FileType> fileTypeList;

  @override
  void generate(
    StringSink sink,
    InternalPigeonOptions options,
    Root root,
    FileType fileType,
  ) {
    if (options.kotlinOptions == null) {
      return;
    }
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      options.kotlinOptions!,
      root,
      sink,
      dartPackageName: options.dartPackageName,
    );
  }

  @override
  IOSink? shouldGenerate(InternalPigeonOptions options, FileType _) =>
      _openSink(
        options.kotlinOptions?.kotlinOut,
        basePath: options.basePath ?? '',
      );

  @override
  List<Error> validate(InternalPigeonOptions options, Root root) => <Error>[];
}

dart_ast.Annotation? _findMetadata(
  dart_ast.NodeList<dart_ast.Annotation> metadata,
  String query,
) {
  final Iterable<dart_ast.Annotation> annotations = metadata.where(
    (dart_ast.Annotation element) => element.name.name == query,
  );
  return annotations.isEmpty ? null : annotations.first;
}

bool _hasMetadata(
  dart_ast.NodeList<dart_ast.Annotation> metadata,
  String query,
) {
  return _findMetadata(metadata, query) != null;
}

extension _ObjectAs on Object {
  /// A convenience for chaining calls with casts.
  T? asNullable<T>() => this as T?;
}

List<Error> _validateAst(Root root, String source) {
  final List<Error> result = <Error>[];
  final List<String> customClasses = root.classes
      .map((Class x) => x.name)
      .toList();
  final Iterable<String> customEnums = root.enums.map((Enum x) => x.name);
  for (final Enum enumDefinition in root.enums) {
    final String? matchingPrefix = _findMatchingPrefixOrNull(
      enumDefinition.name,
      prefixes: disallowedPrefixes,
    );
    if (matchingPrefix != null) {
      result.add(
        Error(
          message:
              'Enum name must not begin with "$matchingPrefix" in enum "${enumDefinition.name}"',
        ),
      );
    }
    for (final EnumMember enumMember in enumDefinition.members) {
      final String? matchingPrefix = _findMatchingPrefixOrNull(
        enumMember.name,
        prefixes: disallowedPrefixes,
      );
      if (matchingPrefix != null) {
        result.add(
          Error(
            message:
                'Enum member name must not begin with "$matchingPrefix" in enum member "${enumMember.name}" of enum "${enumDefinition.name}"',
          ),
        );
      }
    }
  }
  for (final Class classDefinition in root.classes) {
    final String? matchingPrefix = _findMatchingPrefixOrNull(
      classDefinition.name,
      prefixes: disallowedPrefixes,
    );
    if (matchingPrefix != null) {
      result.add(
        Error(
          message:
              'Class name must not begin with "$matchingPrefix" in class "${classDefinition.name}"',
        ),
      );
    }
    for (final NamedType field in getFieldsInSerializationOrder(
      classDefinition,
    )) {
      final String? matchingPrefix = _findMatchingPrefixOrNull(
        field.name,
        prefixes: disallowedPrefixes,
      );
      if (matchingPrefix != null) {
        result.add(
          Error(
            message:
                'Class field name must not begin with "$matchingPrefix" in field "${field.name}" of class "${classDefinition.name}"',
            lineNumber: _calculateLineNumberNullable(source, field.offset),
          ),
        );
      }
      if (!(validTypes.contains(field.type.baseName) ||
          customClasses.contains(field.type.baseName) ||
          customEnums.contains(field.type.baseName))) {
        result.add(
          Error(
            message:
                'Unsupported datatype:"${field.type.baseName}" in class "${classDefinition.name}".',
            lineNumber: _calculateLineNumberNullable(source, field.offset),
          ),
        );
      }
      if (classDefinition.isSealed) {
        if (classDefinition.fields.isNotEmpty) {
          result.add(
            Error(
              message:
                  'Sealed class: "${classDefinition.name}" must not contain fields.',
              lineNumber: _calculateLineNumberNullable(source, field.offset),
            ),
          );
        }
      }
      if (classDefinition.superClass != null) {
        if (!classDefinition.superClass!.isSealed) {
          result.add(
            Error(
              message:
                  'Child class: "${classDefinition.name}" must extend a sealed class.',
              lineNumber: _calculateLineNumberNullable(source, field.offset),
            ),
          );
        }
      }
    }
  }

  bool containsEventChannelApi = false;

  for (final Api api in root.apis) {
    final String? matchingPrefix = _findMatchingPrefixOrNull(
      api.name,
      prefixes: disallowedPrefixes,
    );
    if (matchingPrefix != null) {
      result.add(
        Error(
          message:
              'API name must not begin with "$matchingPrefix" in API "${api.name}"',
        ),
      );
    }
    if (api is AstEventChannelApi) {
      if (containsEventChannelApi) {
        result.add(
          Error(
            message:
                'Event Channel methods must all be included in a single EventChannelApi',
          ),
        );
      }
      containsEventChannelApi = true;
    }
    if (api is AstProxyApi) {
      result.addAll(
        _validateProxyApi(
          api,
          source,
          customClasses: customClasses.toSet(),
          proxyApis: root.apis.whereType<AstProxyApi>().toSet(),
        ),
      );
    }
    for (final Method method in api.methods) {
      final String? matchingPrefix = _findMatchingPrefixOrNull(
        method.name,
        prefixes: disallowedPrefixes,
      );
      if (matchingPrefix != null) {
        result.add(
          Error(
            message:
                'Method name must not begin with "$matchingPrefix" in method "${method.name}" in API: "${api.name}"',
            lineNumber: _calculateLineNumberNullable(source, method.offset),
          ),
        );
      }
      if (api is AstEventChannelApi && method.parameters.isNotEmpty) {
        result.add(
          Error(
            message:
                'event channel methods must not be contain parameters, in method "${method.name}" in API: "${api.name}"',
            lineNumber: _calculateLineNumberNullable(source, method.offset),
          ),
        );
      }
      for (final Parameter param in method.parameters) {
        if (param.type.baseName.isEmpty) {
          result.add(
            Error(
              message:
                  'Parameters must specify their type in method "${method.name}" in API: "${api.name}"',
              lineNumber: _calculateLineNumberNullable(source, param.offset),
            ),
          );
        } else {
          final String? matchingPrefix = _findMatchingPrefixOrNull(
            param.name,
            prefixes: disallowedPrefixes,
          );
          if (matchingPrefix != null) {
            result.add(
              Error(
                message:
                    'Parameter name must not begin with "$matchingPrefix" in method "${method.name}" in API: "${api.name}"',
                lineNumber: _calculateLineNumberNullable(source, param.offset),
              ),
            );
          }
        }
        if (api is AstFlutterApi) {
          if (!param.isPositional) {
            result.add(
              Error(
                message:
                    'FlutterApi method parameters must be positional, in method "${method.name}" in API: "${api.name}"',
                lineNumber: _calculateLineNumberNullable(source, param.offset),
              ),
            );
          } else if (param.isOptional) {
            result.add(
              Error(
                message:
                    'FlutterApi method parameters must not be optional, in method "${method.name}" in API: "${api.name}"',
                lineNumber: _calculateLineNumberNullable(source, param.offset),
              ),
            );
          }
        }
      }
      if (method.objcSelector.isNotEmpty) {
        if (':'.allMatches(method.objcSelector).length !=
            method.parameters.length) {
          result.add(
            Error(
              message:
                  'Invalid selector, expected ${method.parameters.length} parameters.',
              lineNumber: _calculateLineNumberNullable(source, method.offset),
            ),
          );
        }
      }
      if (method.swiftFunction.isNotEmpty) {
        final RegExp signatureRegex = RegExp(
          '\\w+ *\\((\\w+:){${method.parameters.length}}\\)',
        );
        if (!signatureRegex.hasMatch(method.swiftFunction)) {
          result.add(
            Error(
              message:
                  'Invalid function signature, expected ${method.parameters.length} parameters.',
              lineNumber: _calculateLineNumberNullable(source, method.offset),
            ),
          );
        }
      }
      if (method.taskQueueType != TaskQueueType.serial &&
          method.location == ApiLocation.flutter) {
        result.add(
          Error(
            message: 'Unsupported TaskQueue specification on ${method.name}',
            lineNumber: _calculateLineNumberNullable(source, method.offset),
          ),
        );
      }
    }
  }

  return result;
}

List<Error> _validateProxyApi(
  AstProxyApi api,
  String source, {
  required Set<String> customClasses,
  required Set<AstProxyApi> proxyApis,
}) {
  final List<Error> result = <Error>[];

  bool isDataClass(NamedType type) =>
      customClasses.contains(type.type.baseName);
  bool isProxyApi(NamedType type) =>
      proxyApis.any((AstProxyApi api) => api.name == type.type.baseName);
  Error unsupportedDataClassError(NamedType type) {
    return Error(
      message: 'ProxyApis do not support data classes: ${type.type.baseName}.',
      lineNumber: _calculateLineNumberNullable(source, type.offset),
    );
  }

  AstProxyApi? directSuperClass;

  // Validate direct super class is annotated with @ProxyApi
  if (api.superClass != null) {
    directSuperClass = proxyApis.firstWhereOrNull(
      (AstProxyApi proxyApi) => proxyApi.name == api.superClass?.baseName,
    );
    if (directSuperClass == null) {
      result.add(
        Error(
          message:
              'Super class of ${api.name} is not annotated with @ProxyApi: '
              '${api.superClass?.baseName}',
        ),
      );
    }
  }

  // Validate that the api does not inherit an unattached field from its super class.
  if (directSuperClass != null &&
      directSuperClass.unattachedFields.isNotEmpty) {
    result.add(
      Error(
        message:
            'Unattached fields can not be inherited. Unattached field found for parent class: ${directSuperClass.unattachedFields.first.name}',
        lineNumber: _calculateLineNumberNullable(
          source,
          directSuperClass.unattachedFields.first.offset,
        ),
      ),
    );
  }

  // Validate all interfaces are annotated with @ProxyApi
  final Iterable<String> interfaceNames = api.interfaces.map(
    (TypeDeclaration type) => type.baseName,
  );
  for (final String interfaceName in interfaceNames) {
    if (!proxyApis.any((AstProxyApi api) => api.name == interfaceName)) {
      result.add(
        Error(
          message:
              'Interface of ${api.name} is not annotated with a @ProxyApi: $interfaceName',
        ),
      );
    }
  }

  final bool hasUnattachedField = api.unattachedFields.isNotEmpty;
  final bool hasRequiredFlutterMethod = api.flutterMethods.any(
    (Method method) => method.isRequired,
  );
  for (final AstProxyApi proxyApi in proxyApis) {
    // Validate this api is not used as an attached field while either:
    // 1. Having an unattached field.
    // 2. Having a required Flutter method.
    if (hasUnattachedField || hasRequiredFlutterMethod) {
      for (final ApiField field in proxyApi.attachedFields) {
        if (field.type.baseName == api.name) {
          if (hasUnattachedField) {
            result.add(
              Error(
                message:
                    'ProxyApis with unattached fields can not be used as attached fields: ${field.name}',
                lineNumber: _calculateLineNumberNullable(source, field.offset),
              ),
            );
          }
          if (hasRequiredFlutterMethod) {
            result.add(
              Error(
                message:
                    'ProxyApis with required callback methods can not be used as attached fields: ${field.name}',
                lineNumber: _calculateLineNumberNullable(source, field.offset),
              ),
            );
          }
        }
      }
    }

    // Validate this api isn't used as an interface and contains anything except
    // Flutter methods, a static host method, attached methods.
    final bool isValidInterfaceProxyApi =
        api.constructors.isEmpty &&
        api.fields.where((ApiField field) => !field.isStatic).isEmpty &&
        api.hostMethods.where((Method method) => !method.isStatic).isEmpty;
    if (!isValidInterfaceProxyApi) {
      final Iterable<String> interfaceNames = proxyApi.interfaces.map(
        (TypeDeclaration type) => type.baseName,
      );
      for (final String interfaceName in interfaceNames) {
        if (interfaceName == api.name) {
          result.add(
            Error(
              message:
                  'ProxyApis used as interfaces can only have callback methods: `${proxyApi.name}` implements `${api.name}`',
            ),
          );
        }
      }
    }
  }

  // Validate constructor parameters
  for (final Constructor constructor in api.constructors) {
    for (final Parameter parameter in constructor.parameters) {
      if (isDataClass(parameter)) {
        result.add(unsupportedDataClassError(parameter));
      }

      if (api.fields.any((ApiField field) => field.name == parameter.name) ||
          api.flutterMethods.any(
            (Method method) => method.name == parameter.name,
          )) {
        result.add(
          Error(
            message:
                'Parameter names must not share a name with a field or callback method in constructor "${constructor.name}" in API: "${api.name}"',
            lineNumber: _calculateLineNumberNullable(source, parameter.offset),
          ),
        );
      }

      if (parameter.type.baseName.isEmpty) {
        result.add(
          Error(
            message:
                'Parameters must specify their type in constructor "${constructor.name}" in API: "${api.name}"',
            lineNumber: _calculateLineNumberNullable(source, parameter.offset),
          ),
        );
      } else {
        final String? matchingPrefix = _findMatchingPrefixOrNull(
          parameter.name,
          prefixes: disallowedPrefixes,
        );
        if (matchingPrefix != null) {
          result.add(
            Error(
              message:
                  'Parameter name must not begin with "$matchingPrefix" in constructor "${constructor.name} in API: "${api.name}"',
              lineNumber: _calculateLineNumberNullable(
                source,
                parameter.offset,
              ),
            ),
          );
        }
      }
    }
    if (constructor.swiftFunction.isNotEmpty) {
      final RegExp signatureRegex = RegExp(
        '\\w+ *\\((\\w+:){${constructor.parameters.length}}\\)',
      );
      if (!signatureRegex.hasMatch(constructor.swiftFunction)) {
        result.add(
          Error(
            message:
                'Invalid constructor signature, expected ${constructor.parameters.length} parameters.',
            lineNumber: _calculateLineNumberNullable(
              source,
              constructor.offset,
            ),
          ),
        );
      }
    }
  }

  // Validate method parameters
  for (final Method method in api.methods) {
    for (final Parameter parameter in method.parameters) {
      if (isDataClass(parameter)) {
        result.add(unsupportedDataClassError(parameter));
      }

      final String? matchingPrefix = _findMatchingPrefixOrNull(
        parameter.name,
        prefixes: <String>[classNamePrefix, varNamePrefix],
      );
      if (matchingPrefix != null) {
        result.add(
          Error(
            message:
                'Parameter name must not begin with "$matchingPrefix" in method "${method.name} in API: "${api.name}"',
            lineNumber: _calculateLineNumberNullable(source, parameter.offset),
          ),
        );
      }
    }

    if (method.location == ApiLocation.flutter) {
      if (!method.returnType.isVoid &&
          !method.returnType.isNullable &&
          !method.isRequired) {
        result.add(
          Error(
            message:
                'Callback methods that return a non-null value must be non-null: ${method.name}.',
            lineNumber: _calculateLineNumberNullable(source, method.offset),
          ),
        );
      }
      if (method.isStatic) {
        result.add(
          Error(
            message:
                'Static callback methods are not supported: ${method.name}.',
            lineNumber: _calculateLineNumberNullable(source, method.offset),
          ),
        );
      }
    }
  }

  // Validate fields
  for (final ApiField field in api.fields) {
    if (isDataClass(field)) {
      result.add(unsupportedDataClassError(field));
    } else if (field.isStatic) {
      if (!isProxyApi(field)) {
        result.add(
          Error(
            message:
                'Static fields are considered attached fields and must be a ProxyApi: ${field.type.baseName}',
            lineNumber: _calculateLineNumberNullable(source, field.offset),
          ),
        );
      } else if (field.type.isNullable) {
        result.add(
          Error(
            message:
                'Static fields are considered attached fields and must not be nullable: ${field.type.baseName}?',
            lineNumber: _calculateLineNumberNullable(source, field.offset),
          ),
        );
      }
    } else if (field.isAttached) {
      if (!isProxyApi(field)) {
        result.add(
          Error(
            message:
                'Attached fields must be a ProxyApi: ${field.type.baseName}',
            lineNumber: _calculateLineNumberNullable(source, field.offset),
          ),
        );
      }
      if (field.type.isNullable) {
        result.add(
          Error(
            message:
                'Attached fields must not be nullable: ${field.type.baseName}?',
            lineNumber: _calculateLineNumberNullable(source, field.offset),
          ),
        );
      }
    }
  }

  return result;
}

String? _findMatchingPrefixOrNull(
  String value, {
  required List<String> prefixes,
}) {
  for (final String prefix in prefixes) {
    if (value.startsWith(prefix)) {
      return prefix;
    }
  }

  return null;
}

class _FindInitializer extends dart_ast_visitor.RecursiveAstVisitor<Object?> {
  dart_ast.Expression? initializer;
  @override
  Object? visitVariableDeclaration(dart_ast.VariableDeclaration node) {
    if (node.initializer != null) {
      initializer = node.initializer;
    }
    return null;
  }
}

/// Class used to parse, and check the validity of input files.
/// Builds the [Root] class used throughout generation.
class RootBuilder extends dart_ast_visitor.RecursiveAstVisitor<Object?> {
  /// Constructor for RootBuilder.
  RootBuilder(this.source);

  final List<Api> _apis = <Api>[];
  final List<Enum> _enums = <Enum>[];
  final List<Class> _classes = <Class>[];
  final List<Error> _errors = <Error>[];

  /// Input file location.
  final String source;

  Class? _currentClass;
  Map<String, String> _currentClassDefaultValues = <String, String>{};
  Api? _currentApi;
  Map<String, Object>? _pigeonOptions;

  void _storeCurrentApi() {
    if (_currentApi != null) {
      _apis.add(_currentApi!);
      _currentApi = null;
    }
  }

  void _storeCurrentClass() {
    if (_currentClass != null) {
      _classes.add(_currentClass!);
      _currentClass = null;
      _currentClassDefaultValues = <String, String>{};
    }
  }

  /// The results after parsing the input files.
  ParseResults results() {
    _storeCurrentApi();
    _storeCurrentClass();

    final Map<TypeDeclaration, List<int>> referencedTypes = getReferencedTypes(
      _apis,
      _classes,
    );
    final Set<String> referencedTypeNames = referencedTypes.keys
        .map((TypeDeclaration e) => e.baseName)
        .toSet();
    final List<Class> nonReferencedTypes = List<Class>.from(_classes);
    nonReferencedTypes.removeWhere(
      (Class x) => referencedTypeNames.contains(x.name),
    );
    for (final Class x in nonReferencedTypes) {
      x.isReferenced = false;
    }

    final List<Enum> referencedEnums = List<Enum>.from(_enums);
    bool containsHostApi = false;
    bool containsFlutterApi = false;
    bool containsProxyApi = false;
    bool containsEventChannel = false;

    for (final Api api in _apis) {
      switch (api) {
        case AstHostApi():
          containsHostApi = true;
        case AstFlutterApi():
          containsFlutterApi = true;
        case AstProxyApi():
          containsProxyApi = true;
        case AstEventChannelApi():
          containsEventChannel = true;
      }
    }

    final Root completeRoot = Root(
      apis: _apis,
      classes: _classes,
      enums: referencedEnums,
      containsHostApi: containsHostApi,
      containsFlutterApi: containsFlutterApi,
      containsProxyApi: containsProxyApi,
      containsEventChannel: containsEventChannel,
    );

    final List<Error> totalErrors = List<Error>.from(_errors);

    for (final MapEntry<TypeDeclaration, List<int>> element
        in referencedTypes.entries) {
      if (!_classes.map((Class e) => e.name).contains(element.key.baseName) &&
          !referencedEnums
              .map((Enum e) => e.name)
              .contains(element.key.baseName) &&
          !_apis
              .whereType<AstProxyApi>()
              .map((AstProxyApi e) => e.name)
              .contains(element.key.baseName) &&
          !validTypes.contains(element.key.baseName) &&
          !element.key.isVoid &&
          element.key.baseName != 'dynamic' &&
          element.key.baseName != 'Object' &&
          element.key.baseName.isNotEmpty) {
        final int? lineNumber = element.value.isEmpty
            ? null
            : calculateLineNumber(source, element.value.first);
        totalErrors.add(
          Error(
            message: 'Unknown type: ${element.key.baseName}',
            lineNumber: lineNumber,
          ),
        );
      }
    }
    for (final Class classDefinition in _classes) {
      classDefinition.fields = _attachAssociatedDefinitions(
        classDefinition.fields,
      );
      classDefinition.superClass = _attachSuperClass(classDefinition);
    }

    for (final Api api in _apis) {
      for (final Method func in api.methods) {
        func.parameters = _attachAssociatedDefinitions(func.parameters);
        func.returnType = _attachAssociatedDefinition(func.returnType);
      }
      if (api is AstProxyApi) {
        for (final Constructor constructor in api.constructors) {
          constructor.parameters = _attachAssociatedDefinitions(
            constructor.parameters,
          );
        }

        api.fields = _attachAssociatedDefinitions(api.fields);

        if (api.superClass != null) {
          api.superClass = _attachAssociatedDefinition(api.superClass!);
        }

        final Set<TypeDeclaration> newInterfaceSet = <TypeDeclaration>{};
        for (final TypeDeclaration interface in api.interfaces) {
          newInterfaceSet.add(_attachAssociatedDefinition(interface));
        }
        api.interfaces = newInterfaceSet;
      }
    }
    final List<Error> validateErrors = _validateAst(completeRoot, source);
    totalErrors.addAll(validateErrors);

    return ParseResults(
      root: totalErrors.isEmpty
          ? completeRoot
          : Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]),
      errors: totalErrors,
      pigeonOptions: _pigeonOptions,
    );
  }

  TypeDeclaration _attachAssociatedDefinition(TypeDeclaration type) {
    final Enum? assocEnum = _enums.firstWhereOrNull(
      (Enum enumDefinition) => enumDefinition.name == type.baseName,
    );
    final Class? assocClass = _classes.firstWhereOrNull(
      (Class classDefinition) => classDefinition.name == type.baseName,
    );
    final AstProxyApi? assocProxyApi = _apis
        .whereType<AstProxyApi>()
        .firstWhereOrNull(
          (Api apiDefinition) => apiDefinition.name == type.baseName,
        );
    if (assocClass != null) {
      type = type.copyWithClass(assocClass);
    } else if (assocEnum != null) {
      type = type.copyWithEnum(assocEnum);
    } else if (assocProxyApi != null) {
      type = type.copyWithProxyApi(assocProxyApi);
    }
    if (type.typeArguments.isNotEmpty) {
      final List<TypeDeclaration> newTypes = <TypeDeclaration>[];
      for (final TypeDeclaration type in type.typeArguments) {
        newTypes.add(_attachAssociatedDefinition(type));
      }
      type = type.copyWithTypeArguments(newTypes);
    }

    return type;
  }

  List<T> _attachAssociatedDefinitions<T extends NamedType>(Iterable<T> types) {
    final List<T> result = <T>[];
    for (final NamedType type in types) {
      result.add(
        type.copyWithType(_attachAssociatedDefinition(type.type)) as T,
      );
    }
    return result;
  }

  Class? _attachSuperClass(Class childClass) {
    if (childClass.superClassName == null) {
      return null;
    }

    for (final Class parentClass in _classes) {
      if (parentClass.name == childClass.superClassName) {
        parentClass.children.add(childClass);
        return parentClass;
      }
    }
    return null;
  }

  Object _expressionToMap(dart_ast.Expression expression) {
    if (expression is dart_ast.MethodInvocation) {
      final Map<String, Object> result = <String, Object>{};
      for (final dart_ast.Expression argument
          in expression.argumentList.arguments) {
        if (argument is dart_ast.NamedExpression) {
          result[argument.name.label.name] = _expressionToMap(
            argument.expression,
          );
        } else {
          _errors.add(
            Error(
              message: 'expected NamedExpression but found $expression',
              lineNumber: calculateLineNumber(source, argument.offset),
            ),
          );
        }
      }
      return result;
    } else if (expression is dart_ast.SimpleStringLiteral) {
      return expression.value;
    } else if (expression is dart_ast.IntegerLiteral) {
      return expression.value!;
    } else if (expression is dart_ast.BooleanLiteral) {
      return expression.value;
    } else if (expression is dart_ast.SimpleIdentifier) {
      return expression.name;
    } else if (expression is dart_ast.ListLiteral) {
      final List<dynamic> list = <dynamic>[];
      for (final dart_ast.CollectionElement element in expression.elements) {
        if (element is dart_ast.Expression) {
          list.add(_expressionToMap(element));
        } else {
          _errors.add(
            Error(
              message: 'expected Expression but found $element',
              lineNumber: calculateLineNumber(source, element.offset),
            ),
          );
        }
      }
      return list;
    } else if (expression is dart_ast.SetOrMapLiteral) {
      final Set<dynamic> set = <dynamic>{};
      for (final dart_ast.CollectionElement element in expression.elements) {
        if (element is dart_ast.Expression) {
          set.add(_expressionToMap(element));
        } else {
          _errors.add(
            Error(
              message: 'expected Expression but found $element',
              lineNumber: calculateLineNumber(source, element.offset),
            ),
          );
        }
      }
      return set;
    } else {
      _errors.add(
        Error(
          message:
              'unrecognized expression type ${expression.runtimeType} $expression',
          lineNumber: calculateLineNumber(source, expression.offset),
        ),
      );
      return 0;
    }
  }

  @override
  Object? visitImportDirective(dart_ast.ImportDirective node) {
    if (node.uri.stringValue != 'package:pigeon/pigeon.dart') {
      _errors.add(
        Error(
          message:
              "Unsupported import ${node.uri}, only imports of 'package:pigeon/pigeon.dart' are supported.",
          lineNumber: calculateLineNumber(source, node.offset),
        ),
      );
    }
    return null;
  }

  @override
  Object? visitAnnotation(dart_ast.Annotation node) {
    if (node.name.name == 'ConfigurePigeon') {
      if (node.arguments == null) {
        _errors.add(
          Error(
            message: 'ConfigurePigeon expects a PigeonOptions() call.',
            lineNumber: calculateLineNumber(source, node.offset),
          ),
        );
      }
      final Map<String, Object> pigeonOptionsMap =
          _expressionToMap(node.arguments!.arguments.first)
              as Map<String, Object>;
      _pigeonOptions = pigeonOptionsMap;
    }
    node.visitChildren(this);
    return null;
  }

  @override
  Object? visitClassDeclaration(dart_ast.ClassDeclaration node) {
    _storeCurrentApi();
    _storeCurrentClass();

    if (node.abstractKeyword != null) {
      if (node.metadata.length > 2 ||
          (node.metadata.length > 1 &&
              !_hasMetadata(node.metadata, 'ConfigurePigeon'))) {
        _errors.add(
          Error(
            message:
                'API "${node.name.lexeme}" can only have one API annotation but contains: ${node.metadata}',
            lineNumber: calculateLineNumber(source, node.offset),
          ),
        );
      }
      if (_hasMetadata(node.metadata, 'HostApi')) {
        final dart_ast.Annotation hostApi = node.metadata.firstWhere(
          (dart_ast.Annotation element) => element.name.name == 'HostApi',
        );
        String? dartHostTestHandler;
        if (hostApi.arguments != null) {
          for (final dart_ast.Expression expression
              in hostApi.arguments!.arguments) {
            if (expression is dart_ast.NamedExpression) {
              if (expression.name.label.name == 'dartHostTestHandler') {
                final dart_ast.Expression dartHostTestHandlerExpression =
                    expression.expression;
                if (dartHostTestHandlerExpression
                    is dart_ast.SimpleStringLiteral) {
                  dartHostTestHandler = dartHostTestHandlerExpression.value;
                }
              }
            }
          }
        }

        _currentApi = AstHostApi(
          name: node.name.lexeme,
          methods: <Method>[],
          dartHostTestHandler: dartHostTestHandler,
          documentationComments: _documentationCommentsParser(
            node.documentationComment?.tokens,
          ),
        );
      } else if (_hasMetadata(node.metadata, 'FlutterApi')) {
        _currentApi = AstFlutterApi(
          name: node.name.lexeme,
          methods: <Method>[],
          documentationComments: _documentationCommentsParser(
            node.documentationComment?.tokens,
          ),
        );
      } else if (_hasMetadata(node.metadata, 'ProxyApi')) {
        final dart_ast.Annotation proxyApiAnnotation = node.metadata.firstWhere(
          (dart_ast.Annotation element) => element.name.name == 'ProxyApi',
        );

        final Map<String, Object?> annotationMap = <String, Object?>{};
        for (final dart_ast.Expression expression
            in proxyApiAnnotation.arguments!.arguments) {
          if (expression is dart_ast.NamedExpression) {
            annotationMap[expression.name.label.name] = _expressionToMap(
              expression.expression,
            );
          }
        }

        final String? superClassName = annotationMap['superClass'] as String?;
        TypeDeclaration? superClass;
        if (superClassName != null && node.extendsClause != null) {
          _errors.add(
            Error(
              message:
                  'ProxyApis should either set the super class in the annotation OR use extends: ("${node.name.lexeme}").',
              lineNumber: calculateLineNumber(source, node.offset),
            ),
          );
        } else if (superClassName != null) {
          superClass = TypeDeclaration(
            baseName: superClassName,
            isNullable: false,
          );
        } else if (node.extendsClause != null) {
          superClass = TypeDeclaration(
            baseName: node.extendsClause!.superclass.name.lexeme,
            isNullable: false,
          );
        }

        final Set<TypeDeclaration> interfaces = <TypeDeclaration>{};
        if (node.implementsClause != null) {
          for (final dart_ast.NamedType type
              in node.implementsClause!.interfaces) {
            interfaces.add(
              TypeDeclaration(baseName: type.name.lexeme, isNullable: false),
            );
          }
        }

        SwiftProxyApiOptions? swiftOptions;
        final Map<String, Object?>? swiftOptionsMap =
            annotationMap['swiftOptions'] as Map<String, Object?>?;
        if (swiftOptionsMap != null) {
          swiftOptions = SwiftProxyApiOptions(
            name: swiftOptionsMap['name'] as String?,
            import: swiftOptionsMap['import'] as String?,
            minIosApi: swiftOptionsMap['minIosApi'] as String?,
            minMacosApi: swiftOptionsMap['minMacosApi'] as String?,
            supportsIos: swiftOptionsMap['supportsIos'] as bool? ?? true,
            supportsMacos: swiftOptionsMap['supportsMacos'] as bool? ?? true,
          );
        }

        void tryParseApiRequirement(String? version) {
          if (version == null) {
            return;
          }
          try {
            Version.parse(version);
          } on FormatException catch (error) {
            _errors.add(
              Error(
                message:
                    'Could not parse version: ${error.message}. Please use semantic versioning format: "1.2.3".',
                lineNumber: calculateLineNumber(source, node.offset),
              ),
            );
          }
        }

        tryParseApiRequirement(swiftOptions?.minIosApi);
        tryParseApiRequirement(swiftOptions?.minMacosApi);

        KotlinProxyApiOptions? kotlinOptions;
        final Map<String, Object?>? kotlinOptionsMap =
            annotationMap['kotlinOptions'] as Map<String, Object?>?;
        if (kotlinOptionsMap != null) {
          kotlinOptions = KotlinProxyApiOptions(
            fullClassName: kotlinOptionsMap['fullClassName'] as String?,
            minAndroidApi: kotlinOptionsMap['minAndroidApi'] as int?,
          );
        }

        _currentApi = AstProxyApi(
          name: node.name.lexeme,
          methods: <Method>[],
          constructors: <Constructor>[],
          fields: <ApiField>[],
          superClass: superClass,
          interfaces: interfaces,
          swiftOptions: swiftOptions,
          kotlinOptions: kotlinOptions,
          documentationComments: _documentationCommentsParser(
            node.documentationComment?.tokens,
          ),
        );
      } else if (_hasMetadata(node.metadata, 'EventChannelApi')) {
        final dart_ast.Annotation annotation = node.metadata.firstWhere(
          (dart_ast.Annotation element) =>
              element.name.name == 'EventChannelApi',
        );

        final Map<String, Object?> annotationMap = <String, Object?>{};
        for (final dart_ast.Expression expression
            in annotation.arguments!.arguments) {
          if (expression is dart_ast.NamedExpression) {
            annotationMap[expression.name.label.name] = _expressionToMap(
              expression.expression,
            );
          }
        }

        SwiftEventChannelOptions? swiftOptions;
        KotlinEventChannelOptions? kotlinOptions;
        final Map<String, Object?>? swiftOptionsMap =
            annotationMap['swiftOptions'] as Map<String, Object?>?;
        if (swiftOptionsMap != null) {
          swiftOptions = SwiftEventChannelOptions(
            includeSharedClasses:
                swiftOptionsMap['includeSharedClasses'] as bool? ?? true,
          );
        }
        final Map<String, Object?>? kotlinOptionsMap =
            annotationMap['kotlinOptions'] as Map<String, Object?>?;
        if (kotlinOptionsMap != null) {
          kotlinOptions = KotlinEventChannelOptions(
            includeSharedClasses:
                kotlinOptionsMap['includeSharedClasses'] as bool? ?? true,
          );
        }
        _currentApi = AstEventChannelApi(
          name: node.name.lexeme,
          methods: <Method>[],
          swiftOptions: swiftOptions,
          kotlinOptions: kotlinOptions,
          documentationComments: _documentationCommentsParser(
            node.documentationComment?.tokens,
          ),
        );
      }
    } else {
      _currentClass = Class(
        name: node.name.lexeme,
        fields: <NamedType>[],
        superClassName:
            node.implementsClause?.interfaces.first.name.toString() ??
            node.extendsClause?.superclass.name.toString(),
        isSealed: node.sealedKeyword != null,
        isSwiftClass: _hasMetadata(node.metadata, 'SwiftClass'),
        documentationComments: _documentationCommentsParser(
          node.documentationComment?.tokens,
        ),
      );
    }

    node.visitChildren(this);
    return null;
  }

  /// Converts Token's to Strings and removes documentation comment symbol.
  List<String> _documentationCommentsParser(List<Token>? comments) {
    const String docCommentPrefix = '///';
    return comments
            ?.map(
              (Token line) => line.length > docCommentPrefix.length
                  ? line.toString().substring(docCommentPrefix.length)
                  : '',
            )
            .toList() ??
        <String>[];
  }

  Parameter _formalParameterToPigeonParameter(
    dart_ast.FormalParameter formalParameter, {
    bool? isNamed,
    bool? isOptional,
    bool? isPositional,
    bool? isRequired,
    String? defaultValue,
  }) {
    final dart_ast.NamedType? parameter =
        _getFirstChildOfType<dart_ast.NamedType>(formalParameter);
    final dart_ast.SimpleFormalParameter? simpleFormalParameter =
        _getFirstChildOfType<dart_ast.SimpleFormalParameter>(formalParameter);
    if (parameter != null) {
      final String argTypeBaseName = _getNamedTypeQualifiedName(parameter);
      final bool isNullable = parameter.question != null;
      final List<TypeDeclaration> argTypeArguments =
          _typeAnnotationsToTypeArguments(parameter.typeArguments);
      return Parameter(
        type: TypeDeclaration(
          baseName: argTypeBaseName,
          isNullable: isNullable,
          typeArguments: argTypeArguments,
        ),
        name: formalParameter.name?.lexeme ?? '',
        offset: formalParameter.offset,
        isNamed: isNamed ?? formalParameter.isNamed,
        isOptional: isOptional ?? formalParameter.isOptional,
        isPositional: isPositional ?? formalParameter.isPositional,
        isRequired: isRequired ?? formalParameter.isRequired,
        defaultValue: defaultValue,
      );
    } else if (simpleFormalParameter != null) {
      String? defaultValue;
      if (formalParameter is dart_ast.DefaultFormalParameter) {
        defaultValue = formalParameter.defaultValue?.toString();
      }

      return _formalParameterToPigeonParameter(
        simpleFormalParameter,
        isNamed: simpleFormalParameter.isNamed,
        isOptional: simpleFormalParameter.isOptional,
        isPositional: simpleFormalParameter.isPositional,
        isRequired: simpleFormalParameter.isRequired,
        defaultValue: defaultValue,
      );
    } else {
      return Parameter(
        name: '',
        type: const TypeDeclaration(baseName: '', isNullable: false),
        offset: formalParameter.offset,
      );
    }
  }

  static T? _getFirstChildOfType<T>(dart_ast.AstNode entity) {
    for (final dart_ast_syntactic_entity.SyntacticEntity child
        in entity.childEntities) {
      if (child is T) {
        return child as T;
      }
    }
    return null;
  }

  T? _stringToEnum<T>(List<T> values, String? str) {
    if (str == null) {
      return null;
    }
    for (final T value in values) {
      if (value.toString() == str) {
        return value;
      }
    }
    return null;
  }

  @override
  Object? visitMethodDeclaration(dart_ast.MethodDeclaration node) {
    final dart_ast.FormalParameterList parameters = node.parameters!;
    final List<Parameter> arguments = parameters.parameters
        .map(_formalParameterToPigeonParameter)
        .toList();
    final bool isAsynchronous = _hasMetadata(node.metadata, 'async');
    final bool isStatic = _hasMetadata(node.metadata, 'static');
    final String objcSelector =
        _findMetadata(node.metadata, 'ObjCSelector')?.arguments?.arguments.first
            .asNullable<dart_ast.SimpleStringLiteral>()
            ?.value ??
        '';
    final String swiftFunction =
        _findMetadata(node.metadata, 'SwiftFunction')
            ?.arguments
            ?.arguments
            .first
            .asNullable<dart_ast.SimpleStringLiteral>()
            ?.value ??
        '';
    final dart_ast.ArgumentList? taskQueueArguments = _findMetadata(
      node.metadata,
      'TaskQueue',
    )?.arguments;
    final String? taskQueueTypeName = taskQueueArguments == null
        ? null
        : _getFirstChildOfType<dart_ast.NamedExpression>(
            taskQueueArguments,
          )?.expression.asNullable<dart_ast.PrefixedIdentifier>()?.name;
    final TaskQueueType taskQueueType =
        _stringToEnum(TaskQueueType.values, taskQueueTypeName) ??
        TaskQueueType.serial;

    if (_currentApi != null) {
      // Methods without named return types aren't supported.
      final dart_ast.TypeAnnotation returnType = node.returnType!;
      returnType as dart_ast.NamedType;
      _currentApi!.methods.add(
        Method(
          name: node.name.lexeme,
          returnType: TypeDeclaration(
            baseName: _getNamedTypeQualifiedName(returnType),
            typeArguments: _typeAnnotationsToTypeArguments(
              returnType.typeArguments,
            ),
            isNullable: returnType.question != null,
          ),
          parameters: arguments,
          isStatic: isStatic,
          location: switch (_currentApi!) {
            AstHostApi() => ApiLocation.host,
            AstProxyApi() => ApiLocation.host,
            AstFlutterApi() => ApiLocation.flutter,
            AstEventChannelApi() => ApiLocation.host,
          },
          isAsynchronous: isAsynchronous,
          objcSelector: objcSelector,
          swiftFunction: swiftFunction,
          offset: node.offset,
          taskQueueType: taskQueueType,
          documentationComments: _documentationCommentsParser(
            node.documentationComment?.tokens,
          ),
        ),
      );
    } else if (_currentClass != null) {
      _errors.add(
        Error(
          message:
              'Methods aren\'t supported in Pigeon data classes ("${node.name.lexeme}").',
          lineNumber: calculateLineNumber(source, node.offset),
        ),
      );
    }
    node.visitChildren(this);
    return null;
  }

  @override
  Object? visitEnumDeclaration(dart_ast.EnumDeclaration node) {
    _enums.add(
      Enum(
        name: node.name.lexeme,
        members: node.constants
            .map(
              (dart_ast.EnumConstantDeclaration e) => EnumMember(
                name: e.name.lexeme,
                documentationComments: _documentationCommentsParser(
                  e.documentationComment?.tokens,
                ),
              ),
            )
            .toList(),
        documentationComments: _documentationCommentsParser(
          node.documentationComment?.tokens,
        ),
      ),
    );
    node.visitChildren(this);
    return null;
  }

  List<TypeDeclaration> _typeAnnotationsToTypeArguments(
    dart_ast.TypeArgumentList? typeArguments,
  ) {
    final List<TypeDeclaration> result = <TypeDeclaration>[];
    if (typeArguments != null) {
      for (final Object x in typeArguments.childEntities) {
        if (x is dart_ast.NamedType) {
          result.add(
            TypeDeclaration(
              baseName: _getNamedTypeQualifiedName(x),
              isNullable: x.question != null,
              typeArguments: _typeAnnotationsToTypeArguments(x.typeArguments),
            ),
          );
        }
      }
    }
    return result;
  }

  @override
  Object? visitFieldDeclaration(dart_ast.FieldDeclaration node) {
    final dart_ast.TypeAnnotation? type = node.fields.type;
    if (_currentClass != null) {
      if (node.isStatic) {
        _errors.add(
          Error(
            message:
                'Pigeon doesn\'t support static fields ("$node"), consider using enums.',
            lineNumber: calculateLineNumber(source, node.offset),
          ),
        );
      } else if (type is dart_ast.NamedType) {
        final _FindInitializer findInitializerVisitor = _FindInitializer();
        node.visitChildren(findInitializerVisitor);
        if (findInitializerVisitor.initializer != null) {
          _errors.add(
            Error(
              message:
                  'Initialization isn\'t supported for fields in Pigeon data classes ("$node"), just use nullable types with no initializer (example "int? x;").',
              lineNumber: calculateLineNumber(source, node.offset),
            ),
          );
        } else {
          final dart_ast.TypeArgumentList? typeArguments = type.typeArguments;
          final String name = node.fields.variables[0].name.lexeme;
          final NamedType field = NamedType(
            type: TypeDeclaration(
              baseName: _getNamedTypeQualifiedName(type),
              isNullable: type.question != null,
              typeArguments: _typeAnnotationsToTypeArguments(typeArguments),
            ),
            name: name,
            offset: node.offset,
            defaultValue: _currentClassDefaultValues[name],
            documentationComments: _documentationCommentsParser(
              node.documentationComment?.tokens,
            ),
          );
          _currentClass!.fields.add(field);
        }
      } else {
        _errors.add(
          Error(
            message: 'Expected a named type but found "$node".',
            lineNumber: calculateLineNumber(source, node.offset),
          ),
        );
      }
    } else if (_currentApi is AstProxyApi) {
      _addProxyApiField(type, node);
    } else if (_currentApi != null) {
      _errors.add(
        Error(
          message: 'Fields aren\'t supported in Pigeon API classes ("$node").',
          lineNumber: calculateLineNumber(source, node.offset),
        ),
      );
    }
    node.visitChildren(this);
    return null;
  }

  @override
  Object? visitConstructorDeclaration(dart_ast.ConstructorDeclaration node) {
    if (_currentApi is AstProxyApi) {
      final dart_ast.FormalParameterList parameters = node.parameters;
      final List<Parameter> arguments = parameters.parameters
          .map(_formalParameterToPigeonParameter)
          .toList();
      final String swiftFunction =
          _findMetadata(node.metadata, 'SwiftFunction')
              ?.arguments
              ?.arguments
              .first
              .asNullable<dart_ast.SimpleStringLiteral>()
              ?.value ??
          '';

      (_currentApi as AstProxyApi?)!.constructors.add(
        Constructor(
          name: node.name?.lexeme ?? '',
          parameters: arguments,
          swiftFunction: swiftFunction,
          offset: node.offset,
          documentationComments: _documentationCommentsParser(
            node.documentationComment?.tokens,
          ),
        ),
      );
    } else if (_currentApi != null) {
      _errors.add(
        Error(
          message: 'Constructors aren\'t supported in API classes ("$node").',
          lineNumber: calculateLineNumber(source, node.offset),
        ),
      );
    } else {
      if (node.body.beginToken.lexeme != ';') {
        _errors.add(
          Error(
            message:
                'Constructor bodies aren\'t supported in data classes ("$node").',
            lineNumber: calculateLineNumber(source, node.offset),
          ),
        );
      } else if (node.initializers.isNotEmpty) {
        _errors.add(
          Error(
            message:
                'Constructor initializers aren\'t supported in data classes (use "this.fieldName") ("$node").',
            lineNumber: calculateLineNumber(source, node.offset),
          ),
        );
      } else {
        for (final dart_ast.FormalParameter param
            in node.parameters.parameters) {
          if (param is dart_ast.DefaultFormalParameter) {
            if (param.name != null && param.defaultValue != null) {
              _currentClassDefaultValues[param.name!.toString()] = param
                  .defaultValue!
                  .toString();
            }
          }
        }
      }
    }
    node.visitChildren(this);
    return null;
  }

  static String _getNamedTypeQualifiedName(dart_ast.NamedType node) {
    final dart_ast.ImportPrefixReference? importPrefix = node.importPrefix;
    if (importPrefix != null) {
      return '${importPrefix.name.lexeme}.${node.name.lexeme}';
    }
    return node.name.lexeme;
  }

  void _addProxyApiField(
    dart_ast.TypeAnnotation? type,
    dart_ast.FieldDeclaration node,
  ) {
    final bool isStatic = _hasMetadata(node.metadata, 'static');
    if (type is dart_ast.GenericFunctionType) {
      final List<Parameter> parameters = type.parameters.parameters
          .map(_formalParameterToPigeonParameter)
          .toList();
      final String swiftFunction =
          _findMetadata(node.metadata, 'SwiftFunction')
              ?.arguments
              ?.arguments
              .first
              .asNullable<dart_ast.SimpleStringLiteral>()
              ?.value ??
          '';
      final dart_ast.ArgumentList? taskQueueArguments = _findMetadata(
        node.metadata,
        'TaskQueue',
      )?.arguments;
      final String? taskQueueTypeName = taskQueueArguments == null
          ? null
          : _getFirstChildOfType<dart_ast.NamedExpression>(
              taskQueueArguments,
            )?.expression.asNullable<dart_ast.PrefixedIdentifier>()?.name;
      final TaskQueueType taskQueueType =
          _stringToEnum(TaskQueueType.values, taskQueueTypeName) ??
          TaskQueueType.serial;

      // Methods without named return types aren't supported.
      final dart_ast.TypeAnnotation returnType = type.returnType!;
      returnType as dart_ast.NamedType;

      _currentApi!.methods.add(
        Method(
          name: node.fields.variables[0].name.lexeme,
          returnType: TypeDeclaration(
            baseName: _getNamedTypeQualifiedName(returnType),
            typeArguments: _typeAnnotationsToTypeArguments(
              returnType.typeArguments,
            ),
            isNullable: returnType.question != null,
          ),
          location: ApiLocation.flutter,
          isRequired: type.question == null,
          isStatic: isStatic,
          parameters: parameters,
          isAsynchronous: _hasMetadata(node.metadata, 'async'),
          swiftFunction: swiftFunction,
          offset: node.offset,
          taskQueueType: taskQueueType,
          documentationComments: _documentationCommentsParser(
            node.documentationComment?.tokens,
          ),
        ),
      );
    } else if (type is dart_ast.NamedType) {
      final _FindInitializer findInitializerVisitor = _FindInitializer();
      node.visitChildren(findInitializerVisitor);
      if (findInitializerVisitor.initializer != null) {
        _errors.add(
          Error(
            message:
                'Initialization isn\'t supported for fields in ProxyApis ("$node"), just use nullable types with no initializer (example "int? x;").',
            lineNumber: calculateLineNumber(source, node.offset),
          ),
        );
      } else {
        final dart_ast.TypeArgumentList? typeArguments = type.typeArguments;
        (_currentApi as AstProxyApi?)!.fields.add(
          ApiField(
            type: TypeDeclaration(
              baseName: _getNamedTypeQualifiedName(type),
              isNullable: type.question != null,
              typeArguments: _typeAnnotationsToTypeArguments(typeArguments),
            ),
            name: node.fields.variables[0].name.lexeme,
            isAttached: _hasMetadata(node.metadata, 'attached') || isStatic,
            isStatic: isStatic,
            offset: node.offset,
            documentationComments: _documentationCommentsParser(
              node.documentationComment?.tokens,
            ),
          ),
        );
      }
    }
  }
}

int? _calculateLineNumberNullable(String contents, int? offset) {
  return (offset == null) ? null : calculateLineNumber(contents, offset);
}

/// Calculates the line number for debugging.
int calculateLineNumber(String contents, int offset) {
  int result = 1;
  for (int i = 0; i < offset; ++i) {
    if (contents[i] == '\n') {
      result += 1;
    }
  }
  return result;
}
