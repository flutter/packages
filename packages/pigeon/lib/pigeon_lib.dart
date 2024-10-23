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
import 'package:collection/collection.dart' as collection;
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';

import 'ast.dart';
import 'ast_generator.dart';
import 'cpp_generator.dart';
import 'dart_generator.dart';
import 'generator_tools.dart';
import 'generator_tools.dart' as generator_tools;
import 'gobject_generator.dart';
import 'java_generator.dart';
import 'kotlin_generator.dart';
import 'objc_generator.dart';
import 'swift_generator.dart';

class _Asynchronous {
  const _Asynchronous();
}

class _Attached {
  const _Attached();
}

class _Static {
  const _Static();
}

/// Metadata to annotate a Api method as asynchronous
const Object async = _Asynchronous();

/// Metadata to annotate the field of a ProxyApi as an Attached Field.
///
/// Attached fields provide a synchronous [ProxyApi] instance as a field for
/// another [ProxyApi].
///
/// Attached fields:
/// * Must be nonnull.
/// * Must be a ProxyApi (a class annotated with `@ProxyApi()`).
/// * Must not contain any unattached fields.
/// * Must not have a required callback Flutter method.
///
/// Example generated code:
///
/// ```dart
/// class MyProxyApi {
///   final MyOtherProxyApi myField = pigeon_myField().
/// }
/// ```
///
/// The field provides access to the value synchronously, but the native
/// instance is stored in the native `InstanceManager` asynchronously. Similar
/// to how constructors are implemented.
const Object attached = _Attached();

/// Metadata to annotate a field of a ProxyApi as static.
///
/// Static fields are the same as [attached] fields except the field is static
/// and not attached to any instance of the ProxyApi.
const Object static = _Static();

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

/// Metadata to annotate a Pigeon API that wraps a native class.
///
/// The abstract class with this annotation groups a collection of Dart↔host
/// constructors, fields, methods and host↔Dart methods used to wrap a native
/// class.
///
/// The generated Dart class acts as a proxy to a native type and maintains
/// instances automatically with an `InstanceManager`. The generated host
/// language class implements methods to interact with class instances or static
/// methods.
class ProxyApi {
  /// Parametric constructor for [ProxyApi].
  const ProxyApi({this.superClass, this.kotlinOptions, this.swiftOptions});

  /// The proxy api that is a super class to this one.
  ///
  /// This provides an alternative to calling `extends` on a class since this
  /// requires calling the super class constructor.
  ///
  /// Note that using this instead of `extends` can cause unexpected conflicts
  /// with inherited method names.
  final Type? superClass;

  /// Options that control how Swift code will be generated for a specific
  /// ProxyApi.
  final SwiftProxyApiOptions? swiftOptions;

  /// Options that control how Kotlin code will be generated for a specific
  /// ProxyApi.
  final KotlinProxyApiOptions? kotlinOptions;
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

/// Metadata to annotate methods to control the signature used for Swift output.
///
/// The number of components in the provided signature must match the number of
/// arguments in the annotated method.
/// For example:
///   @SwiftFunction('divide(_:by:)') double divide(int x, String y);
class SwiftFunction {
  /// Constructor.
  const SwiftFunction(this.value);

  /// The string representation of the function signature.
  final String value;
}

/// Metadata to annotate data classes to be defined as class in Swift output.
class SwiftClass {
  /// Constructor.
  const SwiftClass();
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
  const PigeonOptions({
    this.input,
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
    this.gobjectHeaderOut,
    this.gobjectSourceOut,
    this.gobjectOptions,
    this.dartOptions,
    this.copyrightHeader,
    this.oneLanguage,
    this.astOut,
    this.debugGenerators,
    this.basePath,
    String? dartPackageName,
  }) : _dartPackageName = dartPackageName;

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

  /// Path to the ".h" GObject file that will be generated.
  final String? gobjectHeaderOut;

  /// Path to the ".cc" GObject file that will be generated.
  final String? gobjectSourceOut;

  /// Options that control how GObject source will be generated.
  final GObjectOptions? gobjectOptions;

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

  /// A base path to be prepended to all provided output paths.
  final String? basePath;

  /// The name of the package the pigeon files will be used in.
  final String? _dartPackageName;

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
      cppHeaderOut: map['cppHeaderOut'] as String?,
      cppSourceOut: map['cppSourceOut'] as String?,
      cppOptions: map.containsKey('cppOptions')
          ? CppOptions.fromMap(map['cppOptions']! as Map<String, Object>)
          : null,
      gobjectHeaderOut: map['gobjectHeaderOut'] as String?,
      gobjectSourceOut: map['gobjectSourceOut'] as String?,
      gobjectOptions: map.containsKey('gobjectOptions')
          ? GObjectOptions.fromMap(
              map['gobjectOptions']! as Map<String, Object>)
          : null,
      dartOptions: map.containsKey('dartOptions')
          ? DartOptions.fromMap(map['dartOptions']! as Map<String, Object>)
          : null,
      copyrightHeader: map['copyrightHeader'] as String?,
      oneLanguage: map['oneLanguage'] as bool?,
      astOut: map['astOut'] as String?,
      debugGenerators: map['debugGenerators'] as bool?,
      basePath: map['basePath'] as String?,
      dartPackageName: map['dartPackageName'] as String?,
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
      if (cppHeaderOut != null) 'cppHeaderOut': cppHeaderOut!,
      if (cppSourceOut != null) 'cppSourceOut': cppSourceOut!,
      if (cppOptions != null) 'cppOptions': cppOptions!.toMap(),
      if (gobjectHeaderOut != null) 'gobjectHeaderOut': gobjectHeaderOut!,
      if (gobjectSourceOut != null) 'gobjectSourceOut': gobjectSourceOut!,
      if (gobjectOptions != null) 'gobjectOptions': gobjectOptions!.toMap(),
      if (dartOptions != null) 'dartOptions': dartOptions!.toMap(),
      if (copyrightHeader != null) 'copyrightHeader': copyrightHeader!,
      if (astOut != null) 'astOut': astOut!,
      if (oneLanguage != null) 'oneLanguage': oneLanguage!,
      if (debugGenerators != null) 'debugGenerators': debugGenerators!,
      if (basePath != null) 'basePath': basePath!,
      if (_dartPackageName != null) 'dartPackageName': _dartPackageName,
    };
    return result;
  }

  /// Overrides any non-null parameters from [options] into this to make a new
  /// [PigeonOptions].
  PigeonOptions merge(PigeonOptions options) {
    return PigeonOptions.fromMap(mergeMaps(toMap(), options.toMap()));
  }

  /// Returns provided or deduced package name, throws `Exception` if none found.
  String getPackageName() {
    final String? name = _dartPackageName ?? deducePackageName(dartOut ?? '');
    if (name == null) {
      throw Exception(
        'Unable to deduce package name, and no package name supplied.\n'
        'Add a `dartPackageName` property to your `PigeonOptions` config,\n'
        'or add --dartPackageName={name_of_package} to your command line pigeon call.',
      );
    }
    return name;
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
  DartOptions? dartOptions,
  String? copyrightHeader, {
  String? dartOutPath,
  String? testOutPath,
  String basePath = '',
}) {
  dartOptions = dartOptions ?? const DartOptions();
  return dartOptions.merge(DartOptions(
    sourceOutPath: dartOutPath,
    testOutPath: testOutPath,
    copyrightHeader: copyrightHeader != null
        ? _lineReader(path.posix.join(basePath, copyrightHeader))
        : null,
  ));
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
      _openSink(options.astOut, basePath: options.basePath ?? '');

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
      options.dartOptions,
      options.copyrightHeader,
      testOutPath: options.dartTestOut,
      basePath: options.basePath ?? '',
    );
    const DartGenerator generator = DartGenerator();
    generator.generate(
      dartOptionsWithHeader,
      root,
      sink,
      dartPackageName: options.getPackageName(),
    );
  }

  @override
  IOSink? shouldGenerate(PigeonOptions options, FileType _) =>
      _openSink(options.dartOut, basePath: options.basePath ?? '');

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
      basePath: options.basePath ?? '',
    );
    const DartGenerator testGenerator = DartGenerator();
    // The test code needs the actual package name of the Dart output, even if
    // the package name has been overridden for other uses.
    final String outputPackageName =
        deducePackageName(options.dartOut ?? '') ?? options.getPackageName();
    testGenerator.generateTest(
      dartOptionsWithHeader,
      root,
      sink,
      dartPackageName: options.getPackageName(),
      dartOutputPackageName: outputPackageName,
    );
  }

  @override
  IOSink? shouldGenerate(PigeonOptions options, FileType _) {
    if (options.dartTestOut != null) {
      return _openSink(options.dartTestOut, basePath: options.basePath ?? '');
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
      fileSpecificClassNameComponent: options.objcSourceOut
              ?.split('/')
              .lastOrNull
              ?.split('.')
              .firstOrNull ??
          '',
      copyrightHeader: options.copyrightHeader != null
          ? _lineReader(
              path.posix.join(options.basePath ?? '', options.copyrightHeader))
          : null,
    ));
    final OutputFileOptions<ObjcOptions> outputFileOptions =
        OutputFileOptions<ObjcOptions>(
            fileType: fileType, languageOptions: objcOptionsWithHeader);
    const ObjcGenerator generator = ObjcGenerator();
    generator.generate(
      outputFileOptions,
      root,
      sink,
      dartPackageName: options.getPackageName(),
    );
  }

  @override
  IOSink? shouldGenerate(PigeonOptions options, FileType fileType) {
    if (fileType == FileType.source) {
      return _openSink(options.objcSourceOut, basePath: options.basePath ?? '');
    } else {
      return _openSink(options.objcHeaderOut, basePath: options.basePath ?? '');
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
          ? _lineReader(
              path.posix.join(options.basePath ?? '', options.copyrightHeader))
          : null,
    ));
    const JavaGenerator generator = JavaGenerator();
    generator.generate(
      javaOptions,
      root,
      sink,
      dartPackageName: options.getPackageName(),
    );
  }

  @override
  IOSink? shouldGenerate(PigeonOptions options, FileType _) =>
      _openSink(options.javaOut, basePath: options.basePath ?? '');

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
      fileSpecificClassNameComponent:
          options.swiftOut?.split('/').lastOrNull?.split('.').firstOrNull ?? '',
      copyrightHeader: options.copyrightHeader != null
          ? _lineReader(
              path.posix.join(options.basePath ?? '', options.copyrightHeader))
          : null,
      errorClassName: swiftOptions.errorClassName,
    ));
    const SwiftGenerator generator = SwiftGenerator();
    generator.generate(
      swiftOptions,
      root,
      sink,
      dartPackageName: options.getPackageName(),
    );
  }

  @override
  IOSink? shouldGenerate(PigeonOptions options, FileType _) =>
      _openSink(options.swiftOut, basePath: options.basePath ?? '');

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
          ? _lineReader(
              path.posix.join(options.basePath ?? '', options.copyrightHeader))
          : null,
    ));
    final OutputFileOptions<CppOptions> outputFileOptions =
        OutputFileOptions<CppOptions>(
            fileType: fileType, languageOptions: cppOptionsWithHeader);
    const CppGenerator generator = CppGenerator();
    generator.generate(
      outputFileOptions,
      root,
      sink,
      dartPackageName: options.getPackageName(),
    );
  }

  @override
  IOSink? shouldGenerate(PigeonOptions options, FileType fileType) {
    if (fileType == FileType.source) {
      return _openSink(options.cppSourceOut, basePath: options.basePath ?? '');
    } else {
      return _openSink(options.cppHeaderOut, basePath: options.basePath ?? '');
    }
  }

  @override
  List<Error> validate(PigeonOptions options, Root root) => <Error>[];
}

/// A [GeneratorAdapter] that generates GObject source code.
class GObjectGeneratorAdapter implements GeneratorAdapter {
  /// Constructor for [GObjectGeneratorAdapter].
  GObjectGeneratorAdapter(
      {this.fileTypeList = const <FileType>[FileType.header, FileType.source]});

  @override
  List<FileType> fileTypeList;

  @override
  void generate(
      StringSink sink, PigeonOptions options, Root root, FileType fileType) {
    final GObjectOptions gobjectOptions =
        options.gobjectOptions ?? const GObjectOptions();
    final GObjectOptions gobjectOptionsWithHeader =
        gobjectOptions.merge(GObjectOptions(
      copyrightHeader: options.copyrightHeader != null
          ? _lineReader(
              path.posix.join(options.basePath ?? '', options.copyrightHeader))
          : null,
    ));
    final OutputFileOptions<GObjectOptions> outputFileOptions =
        OutputFileOptions<GObjectOptions>(
            fileType: fileType, languageOptions: gobjectOptionsWithHeader);
    const GObjectGenerator generator = GObjectGenerator();
    generator.generate(
      outputFileOptions,
      root,
      sink,
      dartPackageName: options.getPackageName(),
    );
  }

  @override
  IOSink? shouldGenerate(PigeonOptions options, FileType fileType) {
    if (fileType == FileType.source) {
      return _openSink(options.gobjectSourceOut,
          basePath: options.basePath ?? '');
    } else {
      return _openSink(options.gobjectHeaderOut,
          basePath: options.basePath ?? '');
    }
  }

  @override
  List<Error> validate(PigeonOptions options, Root root) {
    final List<Error> errors = <Error>[];
    // TODO(tarrinneal): Remove once overflow class is added to gobject generator.
    // https://github.com/flutter/flutter/issues/152916
    if (root.classes.length + root.enums.length > totalCustomCodecKeysAllowed) {
      errors.add(Error(
          message:
              'GObject generator does not yet support more than $totalCustomCodecKeysAllowed custom types.'));
    }
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
      StringSink sink, PigeonOptions options, Root root, FileType fileType) {
    KotlinOptions kotlinOptions =
        options.kotlinOptions ?? const KotlinOptions();
    kotlinOptions = kotlinOptions.merge(KotlinOptions(
      errorClassName: kotlinOptions.errorClassName ?? 'FlutterError',
      includeErrorClass: kotlinOptions.includeErrorClass,
      fileSpecificClassNameComponent:
          options.kotlinOut?.split('/').lastOrNull?.split('.').firstOrNull ??
              '',
      copyrightHeader: options.copyrightHeader != null
          ? _lineReader(
              path.posix.join(options.basePath ?? '', options.copyrightHeader))
          : null,
    ));
    const KotlinGenerator generator = KotlinGenerator();
    generator.generate(
      kotlinOptions,
      root,
      sink,
      dartPackageName: options.getPackageName(),
    );
  }

  @override
  IOSink? shouldGenerate(PigeonOptions options, FileType _) =>
      _openSink(options.kotlinOut, basePath: options.basePath ?? '');

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
  for (final Enum enumDefinition in root.enums) {
    final String? matchingPrefix = _findMatchingPrefixOrNull(
      enumDefinition.name,
      prefixes: disallowedPrefixes,
    );
    if (matchingPrefix != null) {
      result.add(Error(
        message:
            'Enum name must not begin with "$matchingPrefix" in enum "${enumDefinition.name}"',
      ));
    }
    for (final EnumMember enumMember in enumDefinition.members) {
      final String? matchingPrefix = _findMatchingPrefixOrNull(
        enumMember.name,
        prefixes: disallowedPrefixes,
      );
      if (matchingPrefix != null) {
        result.add(Error(
          message:
              'Enum member name must not begin with "$matchingPrefix" in enum member "${enumMember.name}" of enum "${enumDefinition.name}"',
        ));
      }
    }
  }
  for (final Class classDefinition in root.classes) {
    final String? matchingPrefix = _findMatchingPrefixOrNull(
      classDefinition.name,
      prefixes: disallowedPrefixes,
    );
    if (matchingPrefix != null) {
      result.add(Error(
        message:
            'Class name must not begin with "$matchingPrefix" in class "${classDefinition.name}"',
      ));
    }
    for (final NamedType field
        in getFieldsInSerializationOrder(classDefinition)) {
      final String? matchingPrefix = _findMatchingPrefixOrNull(
        field.name,
        prefixes: disallowedPrefixes,
      );
      if (matchingPrefix != null) {
        result.add(Error(
          message:
              'Class field name must not begin with "$matchingPrefix" in field "${field.name}" of class "${classDefinition.name}"',
          lineNumber: _calculateLineNumberNullable(source, field.offset),
        ));
      }
      if (!(validTypes.contains(field.type.baseName) ||
          customClasses.contains(field.type.baseName) ||
          customEnums.contains(field.type.baseName))) {
        result.add(Error(
          message:
              'Unsupported datatype:"${field.type.baseName}" in class "${classDefinition.name}".',
          lineNumber: _calculateLineNumberNullable(source, field.offset),
        ));
      }
    }
  }

  for (final Api api in root.apis) {
    final String? matchingPrefix = _findMatchingPrefixOrNull(
      api.name,
      prefixes: disallowedPrefixes,
    );
    if (matchingPrefix != null) {
      result.add(Error(
        message:
            'API name must not begin with "$matchingPrefix" in API "${api.name}"',
      ));
    }
    if (api is AstProxyApi) {
      result.addAll(_validateProxyApi(
        api,
        source,
        customClasses: customClasses.toSet(),
        proxyApis: root.apis.whereType<AstProxyApi>().toSet(),
      ));
    }
    for (final Method method in api.methods) {
      final String? matchingPrefix = _findMatchingPrefixOrNull(
        method.name,
        prefixes: disallowedPrefixes,
      );
      if (matchingPrefix != null) {
        result.add(Error(
          message:
              'Method name must not begin with "$matchingPrefix" in method "${method.name}" in API: "${api.name}"',
          lineNumber: _calculateLineNumberNullable(source, method.offset),
        ));
      }
      for (final Parameter param in method.parameters) {
        if (param.type.baseName.isEmpty) {
          result.add(Error(
            message:
                'Parameters must specify their type in method "${method.name}" in API: "${api.name}"',
            lineNumber: _calculateLineNumberNullable(source, param.offset),
          ));
        } else {
          final String? matchingPrefix = _findMatchingPrefixOrNull(
            param.name,
            prefixes: disallowedPrefixes,
          );
          if (matchingPrefix != null) {
            result.add(Error(
              message:
                  'Parameter name must not begin with "$matchingPrefix" in method "${method.name}" in API: "${api.name}"',
              lineNumber: _calculateLineNumberNullable(source, param.offset),
            ));
          }
        }
        if (api is AstFlutterApi) {
          if (!param.isPositional) {
            result.add(Error(
              message:
                  'FlutterApi method parameters must be positional, in method "${method.name}" in API: "${api.name}"',
              lineNumber: _calculateLineNumberNullable(source, param.offset),
            ));
          } else if (param.isOptional) {
            result.add(Error(
              message:
                  'FlutterApi method parameters must not be optional, in method "${method.name}" in API: "${api.name}"',
              lineNumber: _calculateLineNumberNullable(source, param.offset),
            ));
          }
        }
      }
      if (method.objcSelector.isNotEmpty) {
        if (':'.allMatches(method.objcSelector).length !=
            method.parameters.length) {
          result.add(Error(
            message:
                'Invalid selector, expected ${method.parameters.length} parameters.',
            lineNumber: _calculateLineNumberNullable(source, method.offset),
          ));
        }
      }
      if (method.swiftFunction.isNotEmpty) {
        final RegExp signatureRegex =
            RegExp('\\w+ *\\((\\w+:){${method.parameters.length}}\\)');
        if (!signatureRegex.hasMatch(method.swiftFunction)) {
          result.add(Error(
            message:
                'Invalid function signature, expected ${method.parameters.length} parameters.',
            lineNumber: _calculateLineNumberNullable(source, method.offset),
          ));
        }
      }
      if (method.taskQueueType != TaskQueueType.serial &&
          method.location == ApiLocation.flutter) {
        result.add(Error(
          message: 'Unsupported TaskQueue specification on ${method.name}',
          lineNumber: _calculateLineNumberNullable(source, method.offset),
        ));
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
  bool isProxyApi(NamedType type) => proxyApis.any(
        (AstProxyApi api) => api.name == type.type.baseName,
      );
  Error unsupportedDataClassError(NamedType type) {
    return Error(
      message: 'ProxyApis do not support data classes: ${type.type.baseName}.',
      lineNumber: _calculateLineNumberNullable(source, type.offset),
    );
  }

  AstProxyApi? directSuperClass;

  // Validate direct super class is another ProxyApi
  if (api.superClass != null) {
    directSuperClass = proxyApis.firstWhereOrNull(
      (AstProxyApi proxyApi) => proxyApi.name == api.superClass?.baseName,
    );
    if (directSuperClass == null) {
      result.add(
        Error(
          message: 'Super class of ${api.name} is not marked as a @ProxyApi: '
              '${api.superClass?.baseName}',
        ),
      );
    }
  }

  // Validate that the api does not inherit an unattached field from its super class.
  if (directSuperClass != null &&
      directSuperClass.unattachedFields.isNotEmpty) {
    result.add(Error(
      message:
          'Unattached fields can not be inherited. Unattached field found for parent class: ${directSuperClass.unattachedFields.first.name}',
      lineNumber: _calculateLineNumberNullable(
        source,
        directSuperClass.unattachedFields.first.offset,
      ),
    ));
  }

  // Validate all interfaces are other ProxyApis
  final Iterable<String> interfaceNames = api.interfaces.map(
    (TypeDeclaration type) => type.baseName,
  );
  for (final String interfaceName in interfaceNames) {
    if (!proxyApis.any((AstProxyApi api) => api.name == interfaceName)) {
      result.add(Error(
        message:
            'Interface of ${api.name} is not marked as a @ProxyApi: $interfaceName',
      ));
    }
  }

  final bool hasUnattachedField = api.unattachedFields.isNotEmpty;
  final bool hasRequiredFlutterMethod =
      api.flutterMethods.any((Method method) => method.isRequired);
  for (final AstProxyApi proxyApi in proxyApis) {
    // Validate this api is not used as an attached field while either:
    // 1. Having an unattached field.
    // 2. Having a required Flutter method.
    if (hasUnattachedField || hasRequiredFlutterMethod) {
      for (final ApiField field in proxyApi.attachedFields) {
        if (field.type.baseName == api.name) {
          if (hasUnattachedField) {
            result.add(Error(
              message:
                  'ProxyApis with unattached fields can not be used as attached fields: ${field.name}',
              lineNumber: _calculateLineNumberNullable(
                source,
                field.offset,
              ),
            ));
          }
          if (hasRequiredFlutterMethod) {
            result.add(Error(
              message:
                  'ProxyApis with required callback methods can not be used as attached fields: ${field.name}',
              lineNumber: _calculateLineNumberNullable(
                source,
                field.offset,
              ),
            ));
          }
        }
      }
    }

    // Validate this api isn't used as an interface and contains anything except
    // Flutter methods, a static host method, attached methods.
    final bool isValidInterfaceProxyApi = api.constructors.isEmpty &&
        api.fields.where((ApiField field) => !field.isStatic).isEmpty &&
        api.hostMethods.where((Method method) => !method.isStatic).isEmpty;
    if (!isValidInterfaceProxyApi) {
      final Iterable<String> interfaceNames = proxyApi.interfaces.map(
        (TypeDeclaration type) => type.baseName,
      );
      for (final String interfaceName in interfaceNames) {
        if (interfaceName == api.name) {
          result.add(Error(
            message:
                'ProxyApis used as interfaces can only have callback methods: `${proxyApi.name}` implements `${api.name}`',
          ));
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
          api.flutterMethods
              .any((Method method) => method.name == parameter.name)) {
        result.add(Error(
          message:
              'Parameter names must not share a name with a field or callback method in constructor "${constructor.name}" in API: "${api.name}"',
          lineNumber: _calculateLineNumberNullable(source, parameter.offset),
        ));
      }

      if (parameter.type.baseName.isEmpty) {
        result.add(Error(
          message:
              'Parameters must specify their type in constructor "${constructor.name}" in API: "${api.name}"',
          lineNumber: _calculateLineNumberNullable(source, parameter.offset),
        ));
      } else {
        final String? matchingPrefix = _findMatchingPrefixOrNull(
          parameter.name,
          prefixes: disallowedPrefixes,
        );
        if (matchingPrefix != null) {
          result.add(Error(
            message:
                'Parameter name must not begin with "$matchingPrefix" in constructor "${constructor.name} in API: "${api.name}"',
            lineNumber: _calculateLineNumberNullable(source, parameter.offset),
          ));
        }
      }
    }
    if (constructor.swiftFunction.isNotEmpty) {
      final RegExp signatureRegex =
          RegExp('\\w+ *\\((\\w+:){${constructor.parameters.length}}\\)');
      if (!signatureRegex.hasMatch(constructor.swiftFunction)) {
        result.add(Error(
          message:
              'Invalid constructor signature, expected ${constructor.parameters.length} parameters.',
          lineNumber: _calculateLineNumberNullable(source, constructor.offset),
        ));
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
        prefixes: <String>[
          classNamePrefix,
          varNamePrefix,
        ],
      );
      if (matchingPrefix != null) {
        result.add(Error(
          message:
              'Parameter name must not begin with "$matchingPrefix" in method "${method.name} in API: "${api.name}"',
          lineNumber: _calculateLineNumberNullable(source, parameter.offset),
        ));
      }
    }

    if (method.location == ApiLocation.flutter && method.isStatic) {
      result.add(Error(
        message: 'Static callback methods are not supported: ${method.name}.',
        lineNumber: _calculateLineNumberNullable(source, method.offset),
      ));
    }
  }

  // Validate fields
  for (final ApiField field in api.fields) {
    if (isDataClass(field)) {
      result.add(unsupportedDataClassError(field));
    } else if (field.isStatic) {
      if (!isProxyApi(field)) {
        result.add(Error(
          message:
              'Static fields are considered attached fields and must be a ProxyApi: ${field.type.baseName}',
          lineNumber: _calculateLineNumberNullable(source, field.offset),
        ));
      } else if (field.type.isNullable) {
        result.add(Error(
          message:
              'Static fields are considered attached fields and must not be nullable: ${field.type.baseName}?',
          lineNumber: _calculateLineNumberNullable(source, field.offset),
        ));
      }
    } else if (field.isAttached) {
      if (!isProxyApi(field)) {
        result.add(Error(
          message: 'Attached fields must be a ProxyApi: ${field.type.baseName}',
          lineNumber: _calculateLineNumberNullable(source, field.offset),
        ));
      }
      if (field.type.isNullable) {
        result.add(Error(
          message:
              'Attached fields must not be nullable: ${field.type.baseName}?',
          lineNumber: _calculateLineNumberNullable(source, field.offset),
        ));
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

class _RootBuilder extends dart_ast_visitor.RecursiveAstVisitor<Object?> {
  _RootBuilder(this.source);

  final List<Api> _apis = <Api>[];
  final List<Enum> _enums = <Enum>[];
  final List<Class> _classes = <Class>[];
  final List<Error> _errors = <Error>[];
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

  ParseResults results() {
    _storeCurrentApi();
    _storeCurrentClass();

    final Map<TypeDeclaration, List<int>> referencedTypes =
        getReferencedTypes(_apis, _classes);
    final Set<String> referencedTypeNames =
        referencedTypes.keys.map((TypeDeclaration e) => e.baseName).toSet();
    final List<Class> nonReferencedClasses = List<Class>.from(_classes);
    nonReferencedClasses
        .removeWhere((Class x) => referencedTypeNames.contains(x.name));
    for (final Class x in nonReferencedClasses) {
      x.isReferenced = false;
    }

    final List<Enum> referencedEnums = List<Enum>.from(_enums);
    final Root completeRoot =
        Root(apis: _apis, classes: _classes, enums: referencedEnums);

    final List<Error> validateErrors = _validateAst(completeRoot, source);
    final List<Error> totalErrors = List<Error>.from(_errors);
    totalErrors.addAll(validateErrors);

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
            : _calculateLineNumber(source, element.value.first);
        totalErrors.add(Error(
            message: 'Unknown type: ${element.key.baseName}',
            lineNumber: lineNumber));
      }
    }
    for (final Class classDefinition in _classes) {
      classDefinition.fields = _attachAssociatedDefinitions(
        classDefinition.fields,
      );
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
        (Enum enumDefinition) => enumDefinition.name == type.baseName);
    final Class? assocClass = _classes.firstWhereOrNull(
        (Class classDefinition) => classDefinition.name == type.baseName);
    final AstProxyApi? assocProxyApi =
        _apis.whereType<AstProxyApi>().firstWhereOrNull(
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
    } else if (expression is dart_ast.SimpleIdentifier) {
      return expression.name;
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
    } else if (expression is dart_ast.SetOrMapLiteral) {
      final Set<dynamic> set = <dynamic>{};
      for (final dart_ast.CollectionElement element in expression.elements) {
        if (element is dart_ast.Expression) {
          set.add(_expressionToMap(element));
        } else {
          _errors.add(Error(
            message: 'expected Expression but found $element',
            lineNumber: _calculateLineNumber(source, element.offset),
          ));
        }
      }
      return set;
    } else {
      _errors.add(Error(
        message:
            'unrecognized expression type ${expression.runtimeType} $expression',
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

        _currentApi = AstHostApi(
          name: node.name.lexeme,
          methods: <Method>[],
          dartHostTestHandler: dartHostTestHandler,
          documentationComments:
              _documentationCommentsParser(node.documentationComment?.tokens),
        );
      } else if (_hasMetadata(node.metadata, 'FlutterApi')) {
        _currentApi = AstFlutterApi(
          name: node.name.lexeme,
          methods: <Method>[],
          documentationComments:
              _documentationCommentsParser(node.documentationComment?.tokens),
        );
      } else if (_hasMetadata(node.metadata, 'ProxyApi')) {
        final dart_ast.Annotation proxyApiAnnotation = node.metadata.firstWhere(
          (dart_ast.Annotation element) => element.name.name == 'ProxyApi',
        );

        final Map<String, Object?> annotationMap = <String, Object?>{};
        for (final dart_ast.Expression expression
            in proxyApiAnnotation.arguments!.arguments) {
          if (expression is dart_ast.NamedExpression) {
            annotationMap[expression.name.label.name] =
                _expressionToMap(expression.expression);
          }
        }

        final String? superClassName = annotationMap['superClass'] as String?;
        TypeDeclaration? superClass;
        if (superClassName != null && node.extendsClause != null) {
          _errors.add(
            Error(
              message:
                  'ProxyApis should either set the super class in the annotation OR use extends: ("${node.name.lexeme}").',
              lineNumber: _calculateLineNumber(source, node.offset),
            ),
          );
        } else if (superClassName != null) {
          superClass = TypeDeclaration(
            baseName: superClassName,
            isNullable: false,
          );
        } else if (node.extendsClause != null) {
          superClass = TypeDeclaration(
            baseName: node.extendsClause!.superclass.name2.lexeme,
            isNullable: false,
          );
        }

        final Set<TypeDeclaration> interfaces = <TypeDeclaration>{};
        if (node.implementsClause != null) {
          for (final dart_ast.NamedType type
              in node.implementsClause!.interfaces) {
            interfaces.add(TypeDeclaration(
              baseName: type.name2.lexeme,
              isNullable: false,
            ));
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
                lineNumber: _calculateLineNumber(source, node.offset),
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
          documentationComments:
              _documentationCommentsParser(node.documentationComment?.tokens),
        );
      }
    } else {
      _currentClass = Class(
        name: node.name.lexeme,
        fields: <NamedType>[],
        isSwiftClass: _hasMetadata(node.metadata, 'SwiftClass'),
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

  Parameter formalParameterToPigeonParameter(
    dart_ast.FormalParameter formalParameter, {
    bool? isNamed,
    bool? isOptional,
    bool? isPositional,
    bool? isRequired,
    String? defaultValue,
  }) {
    final dart_ast.NamedType? parameter =
        getFirstChildOfType<dart_ast.NamedType>(formalParameter);
    final dart_ast.SimpleFormalParameter? simpleFormalParameter =
        getFirstChildOfType<dart_ast.SimpleFormalParameter>(formalParameter);
    if (parameter != null) {
      final String argTypeBaseName = _getNamedTypeQualifiedName(parameter);
      final bool isNullable = parameter.question != null;
      final List<TypeDeclaration> argTypeArguments =
          typeAnnotationsToTypeArguments(parameter.typeArguments);
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

      return formalParameterToPigeonParameter(
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
    final List<Parameter> arguments =
        parameters.parameters.map(formalParameterToPigeonParameter).toList();
    final bool isAsynchronous = _hasMetadata(node.metadata, 'async');
    final bool isStatic = _hasMetadata(node.metadata, 'static');
    final String objcSelector = _findMetadata(node.metadata, 'ObjCSelector')
            ?.arguments
            ?.arguments
            .first
            .asNullable<dart_ast.SimpleStringLiteral>()
            ?.value ??
        '';
    final String swiftFunction = _findMetadata(node.metadata, 'SwiftFunction')
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
      returnType as dart_ast.NamedType;
      _currentApi!.methods.add(
        Method(
          name: node.name.lexeme,
          returnType: TypeDeclaration(
              baseName: _getNamedTypeQualifiedName(returnType),
              typeArguments:
                  typeAnnotationsToTypeArguments(returnType.typeArguments),
              isNullable: returnType.question != null),
          parameters: arguments,
          isStatic: isStatic,
          location: switch (_currentApi!) {
            AstHostApi() => ApiLocation.host,
            AstProxyApi() => ApiLocation.host,
            AstFlutterApi() => ApiLocation.flutter,
          },
          isAsynchronous: isAsynchronous,
          objcSelector: objcSelector,
          swiftFunction: swiftFunction,
          offset: node.offset,
          taskQueueType: taskQueueType,
          documentationComments:
              _documentationCommentsParser(node.documentationComment?.tokens),
        ),
      );
    } else if (_currentClass != null) {
      _errors.add(Error(
          message:
              'Methods aren\'t supported in Pigeon data classes ("${node.name.lexeme}").',
          lineNumber: _calculateLineNumber(source, node.offset)));
    }
    node.visitChildren(this);
    return null;
  }

  @override
  Object? visitEnumDeclaration(dart_ast.EnumDeclaration node) {
    _enums.add(Enum(
      name: node.name.lexeme,
      members: node.constants
          .map((dart_ast.EnumConstantDeclaration e) => EnumMember(
                name: e.name.lexeme,
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
              baseName: _getNamedTypeQualifiedName(x),
              isNullable: x.question != null,
              typeArguments: typeAnnotationsToTypeArguments(x.typeArguments)));
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
          final String name = node.fields.variables[0].name.lexeme;
          final NamedType field = NamedType(
            type: TypeDeclaration(
              baseName: _getNamedTypeQualifiedName(type),
              isNullable: type.question != null,
              typeArguments: typeAnnotationsToTypeArguments(typeArguments),
            ),
            name: name,
            offset: node.offset,
            defaultValue: _currentClassDefaultValues[name],
            documentationComments:
                _documentationCommentsParser(node.documentationComment?.tokens),
          );
          _currentClass!.fields.add(field);
        }
      } else {
        _errors.add(Error(
            message: 'Expected a named type but found "$node".',
            lineNumber: _calculateLineNumber(source, node.offset)));
      }
    } else if (_currentApi is AstProxyApi) {
      _addProxyApiField(type, node);
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
    if (_currentApi is AstProxyApi) {
      final dart_ast.FormalParameterList parameters = node.parameters;
      final List<Parameter> arguments =
          parameters.parameters.map(formalParameterToPigeonParameter).toList();
      final String swiftFunction = _findMetadata(node.metadata, 'SwiftFunction')
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
      } else {
        for (final dart_ast.FormalParameter param
            in node.parameters.parameters) {
          if (param is dart_ast.DefaultFormalParameter) {
            if (param.name != null && param.defaultValue != null) {
              _currentClassDefaultValues[param.name!.toString()] =
                  param.defaultValue!.toString();
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
      return '${importPrefix.name.lexeme}.${node.name2.lexeme}';
    }
    return node.name2.lexeme;
  }

  void _addProxyApiField(
    dart_ast.TypeAnnotation? type,
    dart_ast.FieldDeclaration node,
  ) {
    final bool isStatic = _hasMetadata(node.metadata, 'static');
    if (type is dart_ast.GenericFunctionType) {
      final List<Parameter> parameters = type.parameters.parameters
          .map(formalParameterToPigeonParameter)
          .toList();
      final String swiftFunction = _findMetadata(node.metadata, 'SwiftFunction')
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

      // Methods without named return types aren't supported.
      final dart_ast.TypeAnnotation returnType = type.returnType!;
      returnType as dart_ast.NamedType;

      _currentApi!.methods.add(
        Method(
          name: node.fields.variables[0].name.lexeme,
          returnType: TypeDeclaration(
            baseName: _getNamedTypeQualifiedName(returnType),
            typeArguments:
                typeAnnotationsToTypeArguments(returnType.typeArguments),
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
          documentationComments:
              _documentationCommentsParser(node.documentationComment?.tokens),
        ),
      );
    } else if (type is dart_ast.NamedType) {
      final _FindInitializer findInitializerVisitor = _FindInitializer();
      node.visitChildren(findInitializerVisitor);
      if (findInitializerVisitor.initializer != null) {
        _errors.add(Error(
            message:
                'Initialization isn\'t supported for fields in ProxyApis ("$node"), just use nullable types with no initializer (example "int? x;").',
            lineNumber: _calculateLineNumber(source, node.offset)));
      } else {
        final dart_ast.TypeArgumentList? typeArguments = type.typeArguments;
        (_currentApi as AstProxyApi?)!.fields.add(
              ApiField(
                type: TypeDeclaration(
                  baseName: _getNamedTypeQualifiedName(type),
                  isNullable: type.question != null,
                  typeArguments: typeAnnotationsToTypeArguments(
                    typeArguments,
                  ),
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
  /// it. [types] optionally filters out what datatypes are actually parsed.
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
    ..addOption(
      'swift_out',
      help: 'Path to generated Swift file (.swift).',
      aliases: const <String>['experimental_swift_out'],
    )
    ..addOption(
      'kotlin_out',
      help: 'Path to generated Kotlin file (.kt).',
      aliases: const <String>['experimental_kotlin_out'],
    )
    ..addOption(
      'kotlin_package',
      help: 'The package that generated Kotlin code will be in.',
      aliases: const <String>['experimental_kotlin_package'],
    )
    ..addOption(
      'cpp_header_out',
      help: 'Path to generated C++ header file (.h).',
      aliases: const <String>['experimental_cpp_header_out'],
    )
    ..addOption(
      'cpp_source_out',
      help: 'Path to generated C++ classes file (.cpp).',
      aliases: const <String>['experimental_cpp_source_out'],
    )
    ..addOption('cpp_namespace',
        help: 'The namespace that generated C++ code will be in.')
    ..addOption(
      'gobject_header_out',
      help: 'Path to generated GObject header file (.h).',
      aliases: const <String>['experimental_gobject_header_out'],
    )
    ..addOption(
      'gobject_source_out',
      help: 'Path to generated GObject classes file (.cc).',
      aliases: const <String>['experimental_gobject_source_out'],
    )
    ..addOption('gobject_module',
        help: 'The module that generated GObject code will be in.')
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
        help: 'Print the line number of the generator in comments at newlines.')
    ..addOption('base_path',
        help:
            'A base path to be prefixed to all outputs and copyright header path. Generally used for testing',
        hide: true)
    ..addOption('package_name',
        help: 'The package that generated code will be in.');

  /// Convert command-line arguments to [PigeonOptions].
  static PigeonOptions parseArgs(List<String> args) {
    // Note: This function shouldn't perform any logic, just translate the args
    // to PigeonOptions.  Synthesized values inside of the PigeonOption should
    // get set in the `run` function to accommodate users that are using the
    // `configurePigeon` function.
    final ArgResults results = _argParser.parse(args);

    final PigeonOptions opts = PigeonOptions(
      input: results['input'] as String?,
      dartOut: results['dart_out'] as String?,
      dartTestOut: results['dart_test_out'] as String?,
      objcHeaderOut: results['objc_header_out'] as String?,
      objcSourceOut: results['objc_source_out'] as String?,
      objcOptions: ObjcOptions(
        prefix: results['objc_prefix'] as String?,
      ),
      javaOut: results['java_out'] as String?,
      javaOptions: JavaOptions(
        package: results['java_package'] as String?,
        useGeneratedAnnotation:
            results['java_use_generated_annotation'] as bool?,
      ),
      swiftOut: results['swift_out'] as String?,
      kotlinOut: results['kotlin_out'] as String?,
      kotlinOptions: KotlinOptions(
        package: results['kotlin_package'] as String?,
      ),
      cppHeaderOut: results['cpp_header_out'] as String?,
      cppSourceOut: results['cpp_source_out'] as String?,
      cppOptions: CppOptions(
        namespace: results['cpp_namespace'] as String?,
      ),
      gobjectHeaderOut: results['gobject_header_out'] as String?,
      gobjectSourceOut: results['gobject_source_out'] as String?,
      gobjectOptions: GObjectOptions(
        module: results['gobject_module'] as String?,
      ),
      copyrightHeader: results['copyright_header'] as String?,
      oneLanguage: results['one_language'] as bool?,
      astOut: results['ast_out'] as String?,
      debugGenerators: results['debug_generators'] as bool?,
      basePath: results['base_path'] as String?,
      dartPackageName: results['package_name'] as String?,
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
  static Future<int> runWithOptions(
    PigeonOptions options, {
    List<GeneratorAdapter>? adapters,
    String? sdkPath,
    bool injectOverflowTypes = false,
  }) async {
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
          GObjectGeneratorAdapter(),
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

    if (injectOverflowTypes) {
      final List<Enum> addedEnums = List<Enum>.generate(
        totalCustomCodecKeysAllowed - 1,
        (final int tag) {
          return Enum(
              name: 'FillerEnum$tag',
              members: <EnumMember>[EnumMember(name: 'FillerMember$tag')]);
        },
      );
      addedEnums.addAll(parseResults.root.enums);
      parseResults.root.enums = addedEnums;
    }

    final List<Error> errors = <Error>[];
    errors.addAll(parseResults.errors);

    // Helper to clean up non-Stdout sinks.
    Future<void> releaseSink(IOSink sink) async {
      if (sink is! Stdout) {
        await sink.close();
      }
    }

    for (final GeneratorAdapter adapter in safeGeneratorAdapters) {
      if (injectOverflowTypes && adapter is GObjectGeneratorAdapter) {
        continue;
      }
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
          objcOptions: (options.objcOptions ?? const ObjcOptions()).merge(
              ObjcOptions(
                  headerIncludePath: options.objcOptions?.headerIncludePath ??
                      path.basename(options.objcHeaderOut!)))));
    }

    if (options.cppHeaderOut != null) {
      options = options.merge(PigeonOptions(
          cppOptions: (options.cppOptions ?? const CppOptions()).merge(
              CppOptions(
                  headerIncludePath: options.cppOptions?.headerIncludePath ??
                      path.basename(options.cppHeaderOut!)))));
    }

    if (options.gobjectHeaderOut != null) {
      options = options.merge(PigeonOptions(
          gobjectOptions: (options.gobjectOptions ?? const GObjectOptions())
              .merge(GObjectOptions(
                  headerIncludePath:
                      path.basename(options.gobjectHeaderOut!)))));
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
