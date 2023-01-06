// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';

import 'package:analyzer/dart/analysis/analysis_context.dart'
    show AnalysisContext;
import 'package:analyzer/dart/analysis/analysis_context_collection.dart'
    show AnalysisContextCollection;
import 'package:analyzer/dart/analysis/results.dart' show ParsedUnitResult;
import 'package:analyzer/dart/analysis/session.dart' show AnalysisSession;
import 'package:analyzer/dart/ast/ast.dart' as dart_ast;
import 'package:analyzer/dart/ast/syntactic_entity.dart'
    as dart_ast_syntactic_entity;
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart' as dart_ast_visitor;
import 'package:analyzer/error/error.dart' show AnalysisError;
import 'package:args/args.dart';
import 'package:path/path.dart' as path;

import 'ast.dart';
import 'ast_generator.dart';
import 'cpp_generator.dart';
import 'dart_generator.dart';
import 'generator_tools.dart';
import 'generator_tools.dart' as generator_tools;
import 'java_generator.dart';
import 'kotlin_generator.dart';
import 'objc_generator.dart';
import 'swift_generator.dart';

class _Asynchronous {
  const _Asynchronous();
}

/// Metadata to annotate a Api method as asynchronous
const Object async = _Asynchronous();

/// Metadata annotation used to configure how Pigeon will generate code.
class ConfigurePigeon {
  /// Constructor for ConfigurePigeon.
  const ConfigurePigeon(this.options);

  /// The [PigeonOptions] that will be merged into the command line options.
  final PigeonOptions options;
}

/// Metadata to annotate a Pigeon API implemented by the host-platform.
///
/// The abstract class with this annotation groups a collection of Dart↔host
/// interop methods. These methods are invoked by Dart and are received by a
/// host-platform (such as in Android or iOS) by a class implementing the
/// generated host-platform interface.
class HostApi {
  /// Parametric constructor for [HostApi].
  const HostApi({this.dartHostTestHandler});

  /// The name of an interface generated for tests. Implement this
  /// interface and invoke `[name of this handler].setup` to receive
  /// calls from your real [HostApi] class in Dart instead of the host
  /// platform code, as is typical.
  ///
  /// When using this, you must specify the `--out_test_dart` argument
  /// to specify where to generate the test file.
  ///
  /// Prefer to use a mock of the real [HostApi] with a mocking library for unit
  /// tests.  Generating this Dart handler is sometimes useful in integration
  /// testing.
  ///
  /// Defaults to `null` in which case no handler will be generated.
  final String? dartHostTestHandler;
}

/// Metadata to annotate a Pigeon API implemented by Flutter.
///
/// The abstract class with this annotation groups a collection of Dart↔host
/// interop methods. These methods are invoked by the host-platform (such as in
/// Android or iOS) and are received by Flutter by a class implementing the
/// generated Dart interface.
class FlutterApi {
  /// Parametric constructor for [FlutterApi].
  const FlutterApi();
}

/// Metadata to annotation methods to control the selector used for objc output.
/// The number of components in the provided selector must match the number of
/// arguments in the annotated method.
/// For example:
///   @ObjcSelector('divideValue:by:') double divide(int x, int y);
class ObjCSelector {
  /// Constructor.
  const ObjCSelector(this.value);

  /// The string representation of the selector.
  final String value;
}

/// Type of TaskQueue which determines how handlers are dispatched for
/// HostApi's.
enum TaskQueueType {
  /// Handlers are invoked serially on the default thread. This is the value if
  /// unspecified.
  serial,

  /// Handlers are invoked serially on a background thread.
  serialBackgroundThread,

  // TODO(gaaclarke): Add support for concurrent task queues.
  // /// Handlers are invoked concurrently on a background thread.
  // concurrentBackgroundThread,
}

/// Metadata annotation to control how handlers are dispatched for HostApi's.
/// Note that the TaskQueue API might not be available on the target version of
/// Flutter, see also:
/// https://docs.flutter.dev/development/platform-integration/platform-channels.
class TaskQueue {
  /// The constructor for a TaskQueue.
  const TaskQueue({required this.type});

  /// The type of the TaskQueue.
  final TaskQueueType type;
}

/// Represents an error as a result of parsing and generating code.
class Error {
  /// Parametric constructor for Error.
  Error({
    required this.message,
    this.filename,
    this.lineNumber,
  });

  /// A description of the error.
  String message;

  /// What file caused the [Error].
  String? filename;

  /// What line the error happened on.
  int? lineNumber;

  @override
  String toString() {
    return '(Error message:"$message" filename:"$filename" lineNumber:$lineNumber)';
  }
}

/// Options used when running the code generator.
class PigeonOptions {
  /// Creates a instance of PigeonOptions
  const PigeonOptions(
      {this.input,
      this.dartOut,
      this.dartTestOut,
      this.objcHeaderOut,
      this.objcSourceOut,
      this.objcOptions,
      this.javaOut,
      this.javaOptions,
      this.swiftOut,
      this.swiftOptions,
      this.kotlinOut,
      this.kotlinOptions,
      this.cppHeaderOut,
      this.cppSourceOut,
      this.cppOptions,
      this.dartOptions,
      this.copyrightHeader,
      this.oneLanguage,
      this.astOut,
      this.debugGenerators});

  /// Path to the file which will be processed.
  final String? input;

  /// Path to the dart file that will be generated.
  final String? dartOut;

  /// Path to the dart file that will be generated for test support classes.
  final String? dartTestOut;

  /// Path to the ".h" Objective-C file will be generated.
  final String? objcHeaderOut;

  /// Path to the ".m" Objective-C file will be generated.
  final String? objcSourceOut;

  /// Options that control how Objective-C will be generated.
  final ObjcOptions? objcOptions;

  /// Path to the java file that will be generated.
  final String? javaOut;

  /// Options that control how Java will be generated.
  final JavaOptions? javaOptions;

  /// Path to the swift file that will be generated.
  final String? swiftOut;

  /// Options that control how Swift will be generated.
  final SwiftOptions? swiftOptions;

  /// Path to the kotlin file that will be generated.
  final String? kotlinOut;

  /// Options that control how Kotlin will be generated.
  final KotlinOptions? kotlinOptions;

  /// Path to the ".h" C++ file that will be generated.
  final String? cppHeaderOut;

  /// Path to the ".cpp" C++ file that will be generated.
  final String? cppSourceOut;

  /// Options that control how C++ will be generated.
  final CppOptions? cppOptions;

  /// Options that control how Dart will be generated.
  final DartOptions? dartOptions;

  /// Path to a copyright header that will get prepended to generated code.
  final String? copyrightHeader;

  /// If Pigeon allows generating code for one language.
  final bool? oneLanguage;

  /// Path to AST debugging output.
  final String? astOut;

  /// True means print out line number of generators in comments at newlines.
  final bool? debugGenerators;

  /// Creates a [PigeonOptions] from a Map representation where:
  /// `x = PigeonOptions.fromMap(x.toMap())`.
  static PigeonOptions fromMap(Map<String, Object> map) {
    return PigeonOptions(
      input: map['input'] as String?,
      dartOut: map['dartOut'] as String?,
      dartTestOut: map['dartTestOut'] as String?,
      objcHeaderOut: map['objcHeaderOut'] as String?,
      objcSourceOut: map['objcSourceOut'] as String?,
      objcOptions: map.containsKey('objcOptions')
          ? ObjcOptions.fromMap(map['objcOptions']! as Map<String, Object>)
          : null,
      javaOut: map['javaOut'] as String?,
      javaOptions: map.containsKey('javaOptions')
          ? JavaOptions.fromMap(map['javaOptions']! as Map<String, Object>)
          : null,
      swiftOut: map['swiftOut'] as String?,
      swiftOptions: map.containsKey('swiftOptions')
          ? SwiftOptions.fromList(map['swiftOptions']! as Map<String, Object>)
          : null,
      kotlinOut: map['kotlinOut'] as String?,
      kotlinOptions: map.containsKey('kotlinOptions')
          ? KotlinOptions.fromMap(map['kotlinOptions']! as Map<String, Object>)
          : null,
      cppHeaderOut: map['experimental_cppHeaderOut'] as String?,
      cppSourceOut: map['experimental_cppSourceOut'] as String?,
      cppOptions: map.containsKey('experimental_cppOptions')
          ? CppOptions.fromMap(
              map['experimental_cppOptions']! as Map<String, Object>)
          : null,
      dartOptions: map.containsKey('dartOptions')
          ? DartOptions.fromMap(map['dartOptions']! as Map<String, Object>)
          : null,
      copyrightHeader: map['copyrightHeader'] as String?,
      oneLanguage: map['oneLanguage'] as bool?,
      astOut: map['astOut'] as String?,
      debugGenerators: map['debugGenerators'] as bool?,
    );
  }

  /// Converts a [PigeonOptions] to a Map representation where:
  /// `x = PigeonOptions.fromMap(x.toMap())`.
  Map<String, Object> toMap() {
    final Map<String, Object> result = <String, Object>{
      if (input != null) 'input': input!,
      if (dartOut != null) 'dartOut': dartOut!,
      if (dartTestOut != null) 'dartTestOut': dartTestOut!,
      if (objcHeaderOut != null) 'objcHeaderOut': objcHeaderOut!,
      if (objcSourceOut != null) 'objcSourceOut': objcSourceOut!,
      if (objcOptions != null) 'objcOptions': objcOptions!.toMap(),
      if (javaOut != null) 'javaOut': javaOut!,
      if (javaOptions != null) 'javaOptions': javaOptions!.toMap(),
      if (swiftOut != null) 'swiftOut': swiftOut!,
      if (swiftOptions != null) 'swiftOptions': swiftOptions!.toMap(),
      if (kotlinOut != null) 'kotlinOut': kotlinOut!,
      if (kotlinOptions != null) 'kotlinOptions': kotlinOptions!.toMap(),
      if (cppHeaderOut != null) 'experimental_cppHeaderOut': cppHeaderOut!,
      if (cppSourceOut != null) 'experimental_cppSourceOut': cppSourceOut!,
      if (cppOptions != null) 'experimental_cppOptions': cppOptions!.toMap(),
      if (dartOptions != null) 'dartOptions': dartOptions!.toMap(),
      if (copyrightHeader != null) 'copyrightHeader': copyrightHeader!,
      if (astOut != null) 'astOut': astOut!,
      if (oneLanguage != null) 'oneLanguage': oneLanguage!,
      if (debugGenerators != null) 'debugGenerators': debugGenerators!,
    };
    return result;
  }

  /// Overrides any non-null parameters from [options] into this to make a new
  /// [PigeonOptions].
  PigeonOptions merge(PigeonOptions options) {
    return PigeonOptions.fromMap(mergeMaps(toMap(), options.toMap()));
  }
}

/// A collection of an AST represented as a [Root] and [Error]'s.
class ParseResults {
  /// Parametric constructor for [ParseResults].
  ParseResults({
    required this.root,
    required this.errors,
    required this.pigeonOptions,
  });

  /// The resulting AST.
  final Root root;

  /// Errors generated while parsing input.
  final List<Error> errors;

  /// The Map representation of any [PigeonOptions] specified with
  /// [ConfigurePigeon] during parsing.
  final Map<String, Object>? pigeonOptions;
}

Iterable<String> _lineReader(String path) sync* {
  final String contents = File(path).readAsStringSync();
  const LineSplitter lineSplitter = LineSplitter();
  final List<String> lines = lineSplitter.convert(contents);
  for (final String line in lines) {
    yield line;
  }
}

IOSink? _openSink(String? output) {
  if (output == null) {
    return null;
  }
  IOSink sink;
  File file;
  if (output == 'stdout') {
    sink = stdout;
  } else {
    file = File(output);
    sink = file.openWrite();
  }
  return sink;
}

/// An adapter that will call a generator to write code to a sink
/// based on the contents of [PigeonOptions].
abstract class GeneratorAdapter {
  /// Constructor for [GeneratorAdapter]
  GeneratorAdapter(this.fileTypeList);

  /// A list of file types the generator should create.
  List<FileType> fileTypeList;

  /// Returns an [IOSink] instance to be written to
  /// if the [GeneratorAdapter] should generate.
  ///
  /// If it returns `null`, the [GeneratorAdapter] will be skipped.
  IOSink? shouldGenerate(PigeonOptions options, FileType fileType);

  /// Write the generated code described in [root] to [sink] using the [options].
  void generate(
      StringSink sink, PigeonOptions options, Root root, FileType fileType);

  /// Generates errors that would only be appropriate for this [GeneratorAdapter].
  ///
  /// For example, if a certain feature isn't implemented in a [GeneratorAdapter] yet.
  List<Error> validate(PigeonOptions options, Root root);
}

DartOptions _dartOptionsWithCopyrightHeader(
    DartOptions? dartOptions, String? copyrightHeader,
    {String? dartOutPath, String? testOutPath}) {
  dartOptions = dartOptions ?? DartOptions();
  return dartOptions.merge(DartOptions(
      sourceOutPath: dartOutPath,
      testOutPath: testOutPath,
      copyrightHeader:
          copyrightHeader != null ? _lineReader(copyrightHeader) : null));
}

/// A [GeneratorAdapter] that generates the AST.
class AstGeneratorAdapter implements GeneratorAdapter {
  /// Constructor for [AstGeneratorAdapter].
  AstGeneratorAdapter();

  @override
  List<FileType> fileTypeList = const <FileType>[FileType.na];

  @override
  void generate(
      StringSink sink, PigeonOptions options, Root root, FileType fileType) {
    generateAst(root, sink);
  }

  @override
  IOSink? shouldGenerate(PigeonOptions options, FileType _) =>
      _openSink(options.astOut);

  @override
  List<Error> validate(PigeonOptions options, Root root) => <Error>[];
}

/// A [GeneratorAdapter] that generates Dart source code.
class DartGeneratorAdapter implements GeneratorAdapter {
  /// Constructor for [DartGeneratorAdapter].
  DartGeneratorAdapter();

  @override
  List<FileType> fileTypeList = const <FileType>[FileType.na];

  @override
  void generate(
      StringSink sink, PigeonOptions options, Root root, FileType fileType) {
    final DartOptions dartOptionsWithHeader = _dartOptionsWithCopyrightHeader(
        options.dartOptions, options.copyrightHeader);
    final DartGenerator generator = DartGenerator();
    generator.generate(dartOptionsWithHeader, root, sink);
  }

  @override
  IOSink? shouldGenerate(PigeonOptions options, FileType _) =>
      _openSink(options.dartOut);

  @override
  List<Error> validate(PigeonOptions options, Root root) => <Error>[];
}

/// A [GeneratorAdapter] that generates Dart test source code.
class DartTestGeneratorAdapter implements GeneratorAdapter {
  /// Constructor for [DartTestGeneratorAdapter].
  DartTestGeneratorAdapter();

  @override
  List<FileType> fileTypeList = const <FileType>[FileType.na];

  @override
  void generate(
      StringSink sink, PigeonOptions options, Root root, FileType fileType) {
    final DartOptions dartOptionsWithHeader = _dartOptionsWithCopyrightHeader(
      options.dartOptions,
      options.copyrightHeader,
      dartOutPath: options.dartOut,
      testOutPath: options.dartTestOut,
    );
    final DartGenerator testGenerator = DartGenerator();
    testGenerator.generateTest(
      dartOptionsWithHeader,
      root,
      sink,
    );
  }

  @override
  IOSink? shouldGenerate(PigeonOptions options, FileType _) {
    if (options.dartTestOut != null) {
      return _openSink(options.dartTestOut);
    } else {
      return null;
    }
  }

  @override
  List<Error> validate(PigeonOptions options, Root root) => <Error>[];
}

/// A [GeneratorAdapter] that generates Objective-C code.
class ObjcGeneratorAdapter implements GeneratorAdapter {
  /// Constructor for [ObjcGeneratorAdapter].
  ObjcGeneratorAdapter(
      {this.fileTypeList = const <FileType>[FileType.header, FileType.source]});

  @override
  List<FileType> fileTypeList;

  @override
  void generate(
      StringSink sink, PigeonOptions options, Root root, FileType fileType) {
    final ObjcOptions objcOptions = options.objcOptions ?? const ObjcOptions();
    final ObjcOptions objcOptionsWithHeader = objcOptions.merge(ObjcOptions(
      copyrightHeader: options.copyrightHeader != null
          ? _lineReader(options.copyrightHeader!)
          : null,
    ));
    final OutputFileOptions<ObjcOptions> outputFileOptions =
        OutputFileOptions<ObjcOptions>(
            fileType: fileType, languageOptions: objcOptionsWithHeader);
    final ObjcGenerator generator = ObjcGenerator();
    generator.generate(outputFileOptions, root, sink);
  }

  @override
  IOSink? shouldGenerate(PigeonOptions options, FileType fileType) {
    if (fileType == FileType.source) {
      return _openSink(options.objcSourceOut);
    } else {
      return _openSink(options.objcHeaderOut);
    }
  }

  @override
  List<Error> validate(PigeonOptions options, Root root) => <Error>[];
}

/// A [GeneratorAdapter] that generates Java source code.
class JavaGeneratorAdapter implements GeneratorAdapter {
  /// Constructor for [JavaGeneratorAdapter].
  JavaGeneratorAdapter();

  @override
  List<FileType> fileTypeList = const <FileType>[FileType.na];

  @override
  void generate(
      StringSink sink, PigeonOptions options, Root root, FileType fileType) {
    JavaOptions javaOptions = options.javaOptions ?? const JavaOptions();
    javaOptions = javaOptions.merge(JavaOptions(
        className: javaOptions.className ??
            path.basenameWithoutExtension(options.javaOut!),
        copyrightHeader: options.copyrightHeader != null
            ? _lineReader(options.copyrightHeader!)
            : null));
    final JavaGenerator generator = JavaGenerator();
    generator.generate(javaOptions, root, sink);
  }

  @override
  IOSink? shouldGenerate(PigeonOptions options, FileType _) =>
      _openSink(options.javaOut);

  @override
  List<Error> validate(PigeonOptions options, Root root) => <Error>[];
}

/// A [GeneratorAdapter] that generates Swift source code.
class SwiftGeneratorAdapter implements GeneratorAdapter {
  /// Constructor for [SwiftGeneratorAdapter].
  SwiftGeneratorAdapter();

  @override
  List<FileType> fileTypeList = const <FileType>[FileType.na];

  @override
  void generate(
      StringSink sink, PigeonOptions options, Root root, FileType fileType) {
    SwiftOptions swiftOptions = options.swiftOptions ?? const SwiftOptions();
    swiftOptions = swiftOptions.merge(SwiftOptions(
        copyrightHeader: options.copyrightHeader != null
            ? _lineReader(options.copyrightHeader!)
            : null));
    final SwiftGenerator generator = SwiftGenerator();
    generator.generate(swiftOptions, root, sink);
  }

  @override
  IOSink? shouldGenerate(PigeonOptions options, FileType _) =>
      _openSink(options.swiftOut);

  @override
  List<Error> validate(PigeonOptions options, Root root) => <Error>[];
}

/// A [GeneratorAdapter] that generates C++ source code.
class CppGeneratorAdapter implements GeneratorAdapter {
  /// Constructor for [CppGeneratorAdapter].
  CppGeneratorAdapter(
      {this.fileTypeList = const <FileType>[FileType.header, FileType.source]});

  @override
  List<FileType> fileTypeList;

  @override
  void generate(
      StringSink sink, PigeonOptions options, Root root, FileType fileType) {
    final CppOptions cppOptions = options.cppOptions ?? const CppOptions();
    final CppOptions cppOptionsWithHeader = cppOptions.merge(CppOptions(
      copyrightHeader: options.copyrightHeader != null
          ? _lineReader(options.copyrightHeader!)
          : null,
    ));
    final OutputFileOptions<CppOptions> outputFileOptions =
        OutputFileOptions<CppOptions>(
            fileType: fileType, languageOptions: cppOptionsWithHeader);
    final CppGenerator generator = CppGenerator();
    generator.generate(outputFileOptions, root, sink);
  }

  @override
  IOSink? shouldGenerate(PigeonOptions options, FileType fileType) {
    if (fileType == FileType.source) {
      return _openSink(options.cppSourceOut);
    } else {
      return _openSink(options.cppHeaderOut);
    }
  }

  @override
  List<Error> validate(PigeonOptions options, Root root) => <Error>[];
}

/// A [GeneratorAdapter] that generates Kotlin source code.
class KotlinGeneratorAdapter implements GeneratorAdapter {
  /// Constructor for [KotlinGeneratorAdapter].
  KotlinGeneratorAdapter({this.fileTypeList = const <FileType>[FileType.na]});

  @override
  List<FileType> fileTypeList;

  @override
  void generate(
      StringSink sink, PigeonOptions options, Root root, FileType fileType) {
    KotlinOptions kotlinOptions =
        options.kotlinOptions ?? const KotlinOptions();
    kotlinOptions = kotlinOptions.merge(KotlinOptions(
        copyrightHeader: options.copyrightHeader != null
            ? _lineReader(options.copyrightHeader!)
            : null));
    final KotlinGenerator generator = KotlinGenerator();
    generator.generate(kotlinOptions, root, sink);
  }

  @override
  IOSink? shouldGenerate(PigeonOptions options, FileType _) =>
      _openSink(options.kotlinOut);

  @override
  List<Error> validate(PigeonOptions options, Root root) => <Error>[];
}

dart_ast.Annotation? _findMetadata(
    dart_ast.NodeList<dart_ast.Annotation> metadata, String query) {
  final Iterable<dart_ast.Annotation> annotations = metadata
      .where((dart_ast.Annotation element) => element.name.name == query);
  return annotations.isEmpty ? null : annotations.first;
}

bool _hasMetadata(
    dart_ast.NodeList<dart_ast.Annotation> metadata, String query) {
  return _findMetadata(metadata, query) != null;
}

extension _ObjectAs on Object {
  /// A convenience for chaining calls with casts.
  T? asNullable<T>() => this as T?;
}

List<Error> _validateAst(Root root, String source) {
  final List<Error> result = <Error>[];
  final List<String> customClasses =
      root.classes.map((Class x) => x.name).toList();
  final Iterable<String> customEnums = root.enums.map((Enum x) => x.name);
  for (final Class klass in root.classes) {
    for (final NamedType field in getFieldsInSerializationOrder(klass)) {
      if (field.type.typeArguments != null) {
        for (final TypeDeclaration typeArgument in field.type.typeArguments) {
          if (!typeArgument.isNullable) {
            result.add(Error(
              message:
                  'Generic type arguments must be nullable in field "${field.name}" in class "${klass.name}".',
              lineNumber: _calculateLineNumberNullable(source, field.offset),
            ));
          }
          if (customEnums.contains(typeArgument.baseName)) {
            result.add(Error(
              message:
                  'Enum types aren\'t supported in type arguments in "${field.name}" in class "${klass.name}".',
              lineNumber: _calculateLineNumberNullable(source, field.offset),
            ));
          }
        }
      }
      if (!(validTypes.contains(field.type.baseName) ||
          customClasses.contains(field.type.baseName) ||
          customEnums.contains(field.type.baseName))) {
        result.add(Error(
          message:
              'Unsupported datatype:"${field.type.baseName}" in class "${klass.name}".',
          lineNumber: _calculateLineNumberNullable(source, field.offset),
        ));
      }
    }
  }
  for (final Api api in root.apis) {
    for (final Method method in api.methods) {
      if (api.location == ApiLocation.flutter &&
          method.arguments.isNotEmpty &&
          method.arguments.any((NamedType element) =>
              customEnums.contains(element.type.baseName))) {
        result.add(Error(
          message:
              'Enums aren\'t yet supported for primitive arguments in FlutterApis: "${method.arguments[0]}" in API: "${api.name}" method: "${method.name}" (https://github.com/flutter/flutter/issues/87307)',
          lineNumber: _calculateLineNumberNullable(source, method.offset),
        ));
      }
      if (customEnums.contains(method.returnType.baseName)) {
        result.add(Error(
          message:
              'Enums aren\'t yet supported for primitive return types: "${method.returnType}" in API: "${api.name}" method: "${method.name}" (https://github.com/flutter/flutter/issues/87307)',
        ));
      }
      for (final NamedType unnamedType in method.arguments
          .where((NamedType element) => element.type.baseName.isEmpty)) {
        result.add(Error(
          message:
              'Arguments must specify their type in method "${method.name}" in API: "${api.name}"',
          lineNumber: _calculateLineNumberNullable(source, unnamedType.offset),
        ));
      }
      if (method.objcSelector.isNotEmpty) {
        if (':'.allMatches(method.objcSelector).length !=
            method.arguments.length) {
          result.add(Error(
            message:
                'Invalid selector, expected ${method.arguments.length} arguments.',
            lineNumber: _calculateLineNumberNullable(source, method.offset),
          ));
        }
      }
      if (method.taskQueueType != TaskQueueType.serial &&
          api.location != ApiLocation.host) {
        result.add(Error(
          message: 'Unsupported TaskQueue specification on ${method.name}',
          lineNumber: _calculateLineNumberNullable(source, method.offset),
        ));
      }
    }
  }

  return result;
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

class _RootBuilder extends dart_ast_visitor.RecursiveAstVisitor<Object?> {
  _RootBuilder(this.source);

  final List<Api> _apis = <Api>[];
  final List<Enum> _enums = <Enum>[];
  final List<Class> _classes = <Class>[];
  final List<Error> _errors = <Error>[];
  final String source;

  Class? _currentClass;
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
    }
  }

  ParseResults results() {
    _storeCurrentApi();
    _storeCurrentClass();

    final Map<TypeDeclaration, List<int>> referencedTypes =
        getReferencedTypes(_apis, _classes);
    final Set<String> referencedTypeNames =
        referencedTypes.keys.map((TypeDeclaration e) => e.baseName).toSet();
    final List<Class> referencedClasses = List<Class>.from(_classes);
    referencedClasses
        .removeWhere((Class x) => !referencedTypeNames.contains(x.name));

    final List<Enum> referencedEnums = List<Enum>.from(_enums);
    final Root completeRoot =
        Root(apis: _apis, classes: referencedClasses, enums: referencedEnums);

    final List<Error> validateErrors = _validateAst(completeRoot, source);
    final List<Error> totalErrors = List<Error>.from(_errors);
    totalErrors.addAll(validateErrors);

    for (final MapEntry<TypeDeclaration, List<int>> element
        in referencedTypes.entries) {
      if (!referencedClasses
              .map((Class e) => e.name)
              .contains(element.key.baseName) &&
          !referencedEnums
              .map((Enum e) => e.name)
              .contains(element.key.baseName) &&
          !validTypes.contains(element.key.baseName) &&
          !element.key.isVoid &&
          element.key.baseName != 'dynamic' &&
          element.key.baseName != 'Object' &&
          element.key.baseName.isNotEmpty) {
        final int? lineNumber = element.value.isEmpty
            ? null
            : _calculateLineNumber(source, element.value.first);
        totalErrors.add(Error(
            message: 'Unknown type: ${element.key.baseName}',
            lineNumber: lineNumber));
      }
    }

    return ParseResults(
      root: totalErrors.isEmpty
          ? completeRoot
          : Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]),
      errors: totalErrors,
      pigeonOptions: _pigeonOptions,
    );
  }

  Object _expressionToMap(dart_ast.Expression expression) {
    if (expression is dart_ast.MethodInvocation) {
      final Map<String, Object> result = <String, Object>{};
      for (final dart_ast.Expression argument
          in expression.argumentList.arguments) {
        if (argument is dart_ast.NamedExpression) {
          result[argument.name.label.name] =
              _expressionToMap(argument.expression);
        } else {
          _errors.add(Error(
            message: 'expected NamedExpression but found $expression',
            lineNumber: _calculateLineNumber(source, argument.offset),
          ));
        }
      }
      return result;
    } else if (expression is dart_ast.SimpleStringLiteral) {
      return expression.value;
    } else if (expression is dart_ast.IntegerLiteral) {
      return expression.value!;
    } else if (expression is dart_ast.BooleanLiteral) {
      return expression.value;
    } else if (expression is dart_ast.ListLiteral) {
      final List<dynamic> list = <dynamic>[];
      for (final dart_ast.CollectionElement element in expression.elements) {
        if (element is dart_ast.Expression) {
          list.add(_expressionToMap(element));
        } else {
          _errors.add(Error(
            message: 'expected Expression but found $element',
            lineNumber: _calculateLineNumber(source, element.offset),
          ));
        }
      }
      return list;
    } else {
      _errors.add(Error(
        message:
            'unrecongized expression type ${expression.runtimeType} $expression',
        lineNumber: _calculateLineNumber(source, expression.offset),
      ));
      return 0;
    }
  }

  @override
  Object? visitImportDirective(dart_ast.ImportDirective node) {
    if (node.uri.stringValue != 'package:pigeon/pigeon.dart') {
      _errors.add(Error(
        message:
            "Unsupported import ${node.uri}, only imports of 'package:pigeon/pigeon.dart' are supported.",
        lineNumber: _calculateLineNumber(source, node.offset),
      ));
    }
    return null;
  }

  @override
  Object? visitAnnotation(dart_ast.Annotation node) {
    if (node.name.name == 'ConfigurePigeon') {
      if (node.arguments == null) {
        _errors.add(Error(
          message: 'ConfigurePigeon expects a PigeonOptions() call.',
          lineNumber: _calculateLineNumber(source, node.offset),
        ));
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
      if (_hasMetadata(node.metadata, 'HostApi')) {
        final dart_ast.Annotation hostApi = node.metadata.firstWhere(
            (dart_ast.Annotation element) => element.name.name == 'HostApi');
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
        _currentApi = Api(
          name: node.name2.lexeme,
          location: ApiLocation.host,
          methods: <Method>[],
          dartHostTestHandler: dartHostTestHandler,
          documentationComments:
              _documentationCommentsParser(node.documentationComment?.tokens),
        );
      } else if (_hasMetadata(node.metadata, 'FlutterApi')) {
        _currentApi = Api(
          name: node.name2.lexeme,
          location: ApiLocation.flutter,
          methods: <Method>[],
          documentationComments:
              _documentationCommentsParser(node.documentationComment?.tokens),
        );
      }
    } else {
      _currentClass = Class(
        name: node.name2.lexeme,
        fields: <NamedType>[],
        documentationComments:
            _documentationCommentsParser(node.documentationComment?.tokens),
      );
    }

    node.visitChildren(this);
    return null;
  }

  /// Converts Token's to Strings and removes documentation comment symbol.
  List<String> _documentationCommentsParser(List<Token>? comments) {
    const String docCommentPrefix = '///';
    return comments
            ?.map((Token line) => line.length > docCommentPrefix.length
                ? line.toString().substring(docCommentPrefix.length)
                : '')
            .toList() ??
        <String>[];
  }

  NamedType formalParameterToField(dart_ast.FormalParameter parameter) {
    final dart_ast.NamedType? namedType =
        getFirstChildOfType<dart_ast.NamedType>(parameter);
    if (namedType != null) {
      final String argTypeBaseName = namedType.name.name;
      final bool isNullable = namedType.question != null;
      final List<TypeDeclaration> argTypeArguments =
          typeAnnotationsToTypeArguments(namedType.typeArguments);
      return NamedType(
          type: TypeDeclaration(
              baseName: argTypeBaseName,
              isNullable: isNullable,
              typeArguments: argTypeArguments),
          name: parameter.name?.lexeme ?? '',
          offset: parameter.offset);
    } else {
      return NamedType(
        name: '',
        type: const TypeDeclaration(baseName: '', isNullable: false),
        offset: parameter.offset,
      );
    }
  }

  static T? getFirstChildOfType<T>(dart_ast.AstNode entity) {
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
    final List<NamedType> arguments =
        parameters.parameters.map(formalParameterToField).toList();
    final bool isAsynchronous = _hasMetadata(node.metadata, 'async');
    final String objcSelector = _findMetadata(node.metadata, 'ObjCSelector')
            ?.arguments
            ?.arguments
            .first
            .asNullable<dart_ast.SimpleStringLiteral>()
            ?.value ??
        '';
    final dart_ast.ArgumentList? taskQueueArguments =
        _findMetadata(node.metadata, 'TaskQueue')?.arguments;
    final String? taskQueueTypeName = taskQueueArguments == null
        ? null
        : getFirstChildOfType<dart_ast.NamedExpression>(taskQueueArguments)
            ?.expression
            .asNullable<dart_ast.PrefixedIdentifier>()
            ?.name;
    final TaskQueueType taskQueueType =
        _stringToEnum(TaskQueueType.values, taskQueueTypeName) ??
            TaskQueueType.serial;

    if (_currentApi != null) {
      // Methods without named return types aren't supported.
      final dart_ast.TypeAnnotation returnType = node.returnType!;
      final dart_ast.SimpleIdentifier returnTypeIdentifier =
          getFirstChildOfType<dart_ast.SimpleIdentifier>(returnType)!;
      _currentApi!.methods.add(
        Method(
          name: node.name2.lexeme,
          returnType: TypeDeclaration(
              baseName: returnTypeIdentifier.name,
              typeArguments: typeAnnotationsToTypeArguments(
                  (returnType as dart_ast.NamedType).typeArguments),
              isNullable: returnType.question != null),
          arguments: arguments,
          isAsynchronous: isAsynchronous,
          objcSelector: objcSelector,
          offset: node.offset,
          taskQueueType: taskQueueType,
          documentationComments:
              _documentationCommentsParser(node.documentationComment?.tokens),
        ),
      );
    } else if (_currentClass != null) {
      _errors.add(Error(
          message:
              'Methods aren\'t supported in Pigeon data classes ("${node.name2.lexeme}").',
          lineNumber: _calculateLineNumber(source, node.offset)));
    }
    node.visitChildren(this);
    return null;
  }

  @override
  Object? visitEnumDeclaration(dart_ast.EnumDeclaration node) {
    _enums.add(Enum(
      name: node.name2.lexeme,
      members: node.constants
          .map((dart_ast.EnumConstantDeclaration e) => EnumMember(
                name: e.name2.lexeme,
                documentationComments: _documentationCommentsParser(
                    e.documentationComment?.tokens),
              ))
          .toList(),
      documentationComments:
          _documentationCommentsParser(node.documentationComment?.tokens),
    ));
    node.visitChildren(this);
    return null;
  }

  List<TypeDeclaration> typeAnnotationsToTypeArguments(
      dart_ast.TypeArgumentList? typeArguments) {
    final List<TypeDeclaration> result = <TypeDeclaration>[];
    if (typeArguments != null) {
      for (final Object x in typeArguments.childEntities) {
        if (x is dart_ast.NamedType) {
          result.add(TypeDeclaration(
              baseName: x.name.name,
              isNullable: x.question != null,
              typeArguments: typeAnnotationsToTypeArguments(x.typeArguments)));
        }
      }
    }
    return result;
  }

  @override
  Object? visitFieldDeclaration(dart_ast.FieldDeclaration node) {
    if (_currentClass != null) {
      final dart_ast.TypeAnnotation? type = node.fields.type;
      if (node.isStatic) {
        _errors.add(Error(
            message:
                'Pigeon doesn\'t support static fields ("$node"), consider using enums.',
            lineNumber: _calculateLineNumber(source, node.offset)));
      } else if (type is dart_ast.NamedType) {
        final _FindInitializer findInitializerVisitor = _FindInitializer();
        node.visitChildren(findInitializerVisitor);
        if (findInitializerVisitor.initializer != null) {
          _errors.add(Error(
              message:
                  'Initialization isn\'t supported for fields in Pigeon data classes ("$node"), just use nullable types with no initializer (example "int? x;").',
              lineNumber: _calculateLineNumber(source, node.offset)));
        } else {
          final dart_ast.TypeArgumentList? typeArguments = type.typeArguments;
          _currentClass!.fields.add(NamedType(
            type: TypeDeclaration(
              baseName: type.name.name,
              isNullable: type.question != null,
              typeArguments: typeAnnotationsToTypeArguments(typeArguments),
            ),
            name: node.fields.variables[0].name2.lexeme,
            offset: node.offset,
            documentationComments:
                _documentationCommentsParser(node.documentationComment?.tokens),
          ));
        }
      } else {
        _errors.add(Error(
            message: 'Expected a named type but found "$node".',
            lineNumber: _calculateLineNumber(source, node.offset)));
      }
    } else if (_currentApi != null) {
      _errors.add(Error(
          message: 'Fields aren\'t supported in Pigeon API classes ("$node").',
          lineNumber: _calculateLineNumber(source, node.offset)));
    }
    node.visitChildren(this);
    return null;
  }

  @override
  Object? visitConstructorDeclaration(dart_ast.ConstructorDeclaration node) {
    if (_currentApi != null) {
      _errors.add(Error(
          message: 'Constructors aren\'t supported in API classes ("$node").',
          lineNumber: _calculateLineNumber(source, node.offset)));
    } else {
      if (node.body.beginToken.lexeme != ';') {
        _errors.add(Error(
            message:
                'Constructor bodies aren\'t supported in data classes ("$node").',
            lineNumber: _calculateLineNumber(source, node.offset)));
      } else if (node.initializers.isNotEmpty) {
        _errors.add(Error(
            message:
                'Constructor initializers aren\'t supported in data classes (use "this.fieldName") ("$node").',
            lineNumber: _calculateLineNumber(source, node.offset)));
      }
    }
    node.visitChildren(this);
    return null;
  }
}

int? _calculateLineNumberNullable(String contents, int? offset) {
  return (offset == null) ? null : _calculateLineNumber(contents, offset);
}

int _calculateLineNumber(String contents, int offset) {
  int result = 1;
  for (int i = 0; i < offset; ++i) {
    if (contents[i] == '\n') {
      result += 1;
    }
  }
  return result;
}

/// Tool for generating code to facilitate platform channels usage.
class Pigeon {
  /// Create and setup a [Pigeon] instance.
  static Pigeon setup() {
    return Pigeon();
  }

  /// Reads the file located at [path] and generates [ParseResults] by parsing
  /// it.  [types] optionally filters out what datatypes are actually parsed.
  /// [sdkPath] for specifying the Dart SDK path for
  /// [AnalysisContextCollection].
  ParseResults parseFile(String inputPath, {String? sdkPath}) {
    final List<String> includedPaths = <String>[
      path.absolute(path.normalize(inputPath))
    ];
    final AnalysisContextCollection collection = AnalysisContextCollection(
      includedPaths: includedPaths,
      sdkPath: sdkPath,
    );

    final List<Error> compilationErrors = <Error>[];
    final _RootBuilder rootBuilder =
        _RootBuilder(File(inputPath).readAsStringSync());
    for (final AnalysisContext context in collection.contexts) {
      for (final String path in context.contextRoot.analyzedFiles()) {
        final AnalysisSession session = context.currentSession;
        final ParsedUnitResult result =
            session.getParsedUnit(path) as ParsedUnitResult;
        if (result.errors.isEmpty) {
          final dart_ast.CompilationUnit unit = result.unit;
          unit.accept(rootBuilder);
        } else {
          for (final AnalysisError error in result.errors) {
            compilationErrors.add(Error(
                message: error.message,
                filename: error.source.fullName,
                lineNumber: _calculateLineNumber(
                    error.source.contents.data, error.offset)));
          }
        }
      }
    }

    if (compilationErrors.isEmpty) {
      return rootBuilder.results();
    } else {
      return ParseResults(
        root: Root.makeEmpty(),
        errors: compilationErrors,
        pigeonOptions: null,
      );
    }
  }

  /// String that describes how the tool is used.
  static String get usage {
    return '''
Pigeon is a tool for generating type-safe communication code between Flutter
and the host platform.

usage: pigeon --input <pigeon path> --dart_out <dart path> [option]*

options:
${_argParser.usage}''';
  }

  static final ArgParser _argParser = ArgParser()
    ..addOption('input', help: 'REQUIRED: Path to pigeon file.')
    ..addOption('dart_out',
        help: 'Path to generated Dart source file (.dart). '
            'Required if one_language is not specified.')
    ..addOption('dart_test_out',
        help: 'Path to generated library for Dart tests, when using '
            '@HostApi(dartHostTestHandler:).')
    ..addOption('objc_source_out',
        help: 'Path to generated Objective-C source file (.m).')
    ..addOption('java_out', help: 'Path to generated Java file (.java).')
    ..addOption('java_package',
        help: 'The package that generated Java code will be in.')
    ..addFlag('java_use_generated_annotation',
        help: 'Adds the java.annotation.Generated annotation to the output.')
    ..addOption('experimental_swift_out',
        help: 'Path to generated Swift file (.swift).')
    ..addOption('experimental_kotlin_out',
        help: 'Path to generated Kotlin file (.kt). (experimental)')
    ..addOption('experimental_kotlin_package',
        help:
            'The package that generated Kotlin code will be in. (experimental)')
    ..addOption('experimental_cpp_header_out',
        help: 'Path to generated C++ header file (.h). (experimental)')
    ..addOption('experimental_cpp_source_out',
        help: 'Path to generated C++ classes file (.cpp). (experimental)')
    ..addOption('cpp_namespace',
        help: 'The namespace that generated C++ code will be in.')
    ..addOption('objc_header_out',
        help: 'Path to generated Objective-C header file (.h).')
    ..addOption('objc_prefix',
        help: 'Prefix for generated Objective-C classes and protocols.')
    ..addOption('copyright_header',
        help:
            'Path to file with copyright header to be prepended to generated code.')
    ..addFlag('one_language',
        help: 'Allow Pigeon to only generate code for one language.')
    ..addOption('ast_out',
        help:
            'Path to generated AST debugging info. (Warning: format subject to change)')
    ..addFlag('debug_generators',
        help:
            'Print the line number of the generator in comments at newlines.');

  /// Convert command-line arguments to [PigeonOptions].
  static PigeonOptions parseArgs(List<String> args) {
    // Note: This function shouldn't perform any logic, just translate the args
    // to PigeonOptions.  Synthesized values inside of the PigeonOption should
    // get set in the `run` function to accomodate users that are using the
    // `configurePigeon` function.
    final ArgResults results = _argParser.parse(args);

    final PigeonOptions opts = PigeonOptions(
      input: results['input'],
      dartOut: results['dart_out'],
      dartTestOut: results['dart_test_out'],
      objcHeaderOut: results['objc_header_out'],
      objcSourceOut: results['objc_source_out'],
      objcOptions: ObjcOptions(
        prefix: results['objc_prefix'],
      ),
      javaOut: results['java_out'],
      javaOptions: JavaOptions(
        package: results['java_package'],
        useGeneratedAnnotation: results['java_use_generated_annotation'],
      ),
      swiftOut: results['experimental_swift_out'],
      kotlinOut: results['experimental_kotlin_out'],
      kotlinOptions: KotlinOptions(
        package: results['experimental_kotlin_package'],
      ),
      cppHeaderOut: results['experimental_cpp_header_out'],
      cppSourceOut: results['experimental_cpp_source_out'],
      cppOptions: CppOptions(
        namespace: results['cpp_namespace'],
      ),
      copyrightHeader: results['copyright_header'],
      oneLanguage: results['one_language'],
      astOut: results['ast_out'],
      debugGenerators: results['debug_generators'],
    );
    return opts;
  }

  /// Crawls through the reflection system looking for a configurePigeon method and
  /// executing it.
  static void _executeConfigurePigeon(PigeonOptions options) {
    for (final LibraryMirror library
        in currentMirrorSystem().libraries.values) {
      for (final DeclarationMirror declaration in library.declarations.values) {
        if (declaration is MethodMirror &&
            MirrorSystem.getName(declaration.simpleName) == 'configurePigeon') {
          if (declaration.parameters.length == 1 &&
              declaration.parameters[0].type == reflectClass(PigeonOptions)) {
            library.invoke(declaration.simpleName, <dynamic>[options]);
          } else {
            print("warning: invalid 'configurePigeon' method defined.");
          }
        }
      }
    }
  }

  /// The 'main' entrypoint used by the command-line tool.  [args] are the
  /// command-line arguments.  The optional parameter [adapters] allows you to
  /// customize the generators that pigeon will use. The optional parameter
  /// [sdkPath] allows you to specify the Dart SDK path.
  static Future<int> run(List<String> args,
      {List<GeneratorAdapter>? adapters, String? sdkPath}) {
    final PigeonOptions options = Pigeon.parseArgs(args);
    return runWithOptions(options, adapters: adapters, sdkPath: sdkPath);
  }

  /// The 'main' entrypoint used by external packages.  [options] is
  /// used when running the code generator.  The optional parameter [adapters] allows you to
  /// customize the generators that pigeon will use. The optional parameter
  /// [sdkPath] allows you to specify the Dart SDK path.
  static Future<int> runWithOptions(PigeonOptions options,
      {List<GeneratorAdapter>? adapters, String? sdkPath}) async {
    final Pigeon pigeon = Pigeon.setup();
    if (options.debugGenerators ?? false) {
      generator_tools.debugGenerators = true;
    }
    final List<GeneratorAdapter> safeGeneratorAdapters = adapters ??
        <GeneratorAdapter>[
          DartGeneratorAdapter(),
          JavaGeneratorAdapter(),
          SwiftGeneratorAdapter(),
          KotlinGeneratorAdapter(),
          CppGeneratorAdapter(),
          DartTestGeneratorAdapter(),
          ObjcGeneratorAdapter(),
          AstGeneratorAdapter(),
        ];
    _executeConfigurePigeon(options);

    if (options.input == null) {
      print(usage);
      return 0;
    }

    final ParseResults parseResults =
        pigeon.parseFile(options.input!, sdkPath: sdkPath);

    final List<Error> errors = <Error>[];
    errors.addAll(parseResults.errors);

    // Helper to clean up non-Stdout sinks.
    Future<void> releaseSink(IOSink sink) async {
      if (sink is! Stdout) {
        await sink.close();
      }
    }

    for (final GeneratorAdapter adapter in safeGeneratorAdapters) {
      final IOSink? sink = adapter.shouldGenerate(options, FileType.source);
      if (sink != null) {
        final List<Error> adapterErrors =
            adapter.validate(options, parseResults.root);
        errors.addAll(adapterErrors);
        await releaseSink(sink);
      }
    }

    if (errors.isNotEmpty) {
      printErrors(errors
          .map((Error err) => Error(
              message: err.message,
              filename: options.input,
              lineNumber: err.lineNumber))
          .toList());
      return 1;
    }

    if (parseResults.pigeonOptions != null) {
      options = PigeonOptions.fromMap(
          mergeMaps(options.toMap(), parseResults.pigeonOptions!));
    }

    if (options.oneLanguage == false && options.dartOut == null) {
      print(usage);
      return 1;
    }

    if (options.objcHeaderOut != null) {
      options = options.merge(PigeonOptions(
          objcOptions: options.objcOptions!.merge(ObjcOptions(
              headerIncludePath: path.basename(options.objcHeaderOut!)))));
    }

    if (options.cppHeaderOut != null) {
      options = options.merge(PigeonOptions(
          cppOptions: options.cppOptions!.merge(CppOptions(
              headerIncludePath: path.basename(options.cppHeaderOut!)))));
    }

    for (final GeneratorAdapter adapter in safeGeneratorAdapters) {
      for (final FileType fileType in adapter.fileTypeList) {
        final IOSink? sink = adapter.shouldGenerate(options, fileType);
        if (sink != null) {
          adapter.generate(sink, options, parseResults.root, fileType);
          await sink.flush();
          await releaseSink(sink);
        }
      }
    }

    return 0;
  }

  /// Print a list of errors to stderr.
  static void printErrors(List<Error> errors) {
    for (final Error err in errors) {
      if (err.filename != null) {
        if (err.lineNumber != null) {
          stderr.writeln(
              'Error: ${err.filename}:${err.lineNumber}: ${err.message}');
        } else {
          stderr.writeln('Error: ${err.filename}: ${err.message}');
        }
      } else {
        stderr.writeln('Error: ${err.message}');
      }
    }
  }
}
