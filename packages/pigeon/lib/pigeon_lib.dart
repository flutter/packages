// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
import 'package:analyzer/dart/ast/ast.dart' show CompilationUnit;
import 'package:analyzer/dart/ast/visitor.dart' as dart_ast_visitor;
import 'package:analyzer/error/error.dart';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:pigeon/java_generator.dart';

import 'ast.dart';
import 'dart_generator.dart';
import 'objc_generator.dart';

const List<String> _validTypes = <String>[
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
];

class _Asynchronous {
  const _Asynchronous();
}

/// Metadata to annotate a Api method as asynchronous
const _Asynchronous async = _Asynchronous();

class ConfigurePigeon {
  const ConfigurePigeon(this.options);
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
      this.dartOptions,
      this.copyrightHeader});

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

  /// Options that control how Dart will be generated.
  final DartOptions? dartOptions;

  /// Path to a copyright header that will get prepended to generated code.
  final String? copyrightHeader;

  PigeonOptions copy({
    String? input,
    String? dartOut,
    String? dartTestOut,
    String? objcHeaderOut,
    String? objcSourceOut,
    ObjcOptions? objcOptions,
    String? javaOut,
    JavaOptions? javaOptions,
    DartOptions? dartOptions,
    String? copyrightHeader,
  }) {
    return PigeonOptions(
      input: input ?? this.input,
      dartOut: dartOut ?? this.dartOut,
      dartTestOut: dartTestOut ?? this.dartTestOut,
      objcHeaderOut: objcHeaderOut ?? this.objcHeaderOut,
      objcSourceOut: objcSourceOut ?? this.objcSourceOut,
      objcOptions: objcOptions ?? this.objcOptions,
      javaOut: javaOut ?? this.javaOut,
      javaOptions: javaOptions ?? this.javaOptions,
      dartOptions: dartOptions ?? this.dartOptions,
      copyrightHeader: copyrightHeader ?? this.copyrightHeader,
    );
  }
}

/// A collection of an AST represented as a [Root] and [Error]'s.
class ParseResults {
  /// Parametric constructor for [ParseResults].
  ParseResults({
    required this.root,
    required this.errors,
  });

  /// The resulting AST.
  final Root root;

  /// Errors generated while parsing input.
  final List<Error> errors;
}

String _posixify(String input) {
  final path.Context context = path.Context(style: path.Style.posix);
  return context.fromUri(path.toUri(path.absolute(input)));
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

/// A generator that will write code to a sink based on the contents of [PigeonOptions].
abstract class Generator {
  /// Returns an [IOSink] instance to be written to if the [Generator] should
  /// generate.  If it returns `null`, the [Generator] will be skipped.
  IOSink? shouldGenerate(PigeonOptions options);

  /// Write the generated code described in [root] to [sink] using the
  /// [options].
  void generate(StringSink sink, PigeonOptions options, Root root);
}

/// A [Generator] that generates Dart source code.
class DartGenerator implements Generator {
  /// Constructor for [DartGenerator].
  const DartGenerator();

  @override
  void generate(StringSink sink, PigeonOptions options, Root root) {
    final DartOptions dartOptions = options.dartOptions ?? const DartOptions();
    final DartOptions dartOptionsWithHeader = dartOptions.copy(
        copyrightHeader: options.copyrightHeader != null
            ? _lineReader(options.copyrightHeader!)
            : null);
    generateDart(dartOptionsWithHeader, root, sink);
  }

  @override
  IOSink? shouldGenerate(PigeonOptions options) => _openSink(options.dartOut);
}

/// A [Generator] that generates Dart test source code.
class DartTestGenerator implements Generator {
  /// Constructor for [DartTestGenerator].
  const DartTestGenerator();

  @override
  void generate(StringSink sink, PigeonOptions options, Root root) {
    final String mainPath = path.context.relative(
      _posixify(options.dartOut!),
      from: _posixify(path.dirname(options.dartTestOut!)),
    );
    generateTestDart(
      options.dartOptions ?? const DartOptions(),
      root,
      sink,
      mainPath,
    );
  }

  @override
  IOSink? shouldGenerate(PigeonOptions options) {
    if (options.dartTestOut != null && options.dartOut != null) {
      return _openSink(options.dartTestOut);
    } else {
      return null;
    }
  }
}

/// A [Generator] that generates Objective-C header code.
class ObjcHeaderGenerator implements Generator {
  /// Constructor for [ObjcHeaderGenerator].
  const ObjcHeaderGenerator();

  @override
  void generate(StringSink sink, PigeonOptions options, Root root) {
    final ObjcOptions objcOptions = options.objcOptions ?? const ObjcOptions();
    final ObjcOptions objcOptionsWithHeader = objcOptions.copy(
        copyrightHeader: options.copyrightHeader != null
            ? _lineReader(options.copyrightHeader!)
            : null);
    generateObjcHeader(objcOptionsWithHeader, root, sink);
  }

  @override
  IOSink? shouldGenerate(PigeonOptions options) =>
      _openSink(options.objcHeaderOut);
}

/// A [Generator] that generates Objective-C source code.
class ObjcSourceGenerator implements Generator {
  /// Constructor for [ObjcSourceGenerator].
  const ObjcSourceGenerator();

  @override
  void generate(StringSink sink, PigeonOptions options, Root root) {
    final ObjcOptions objcOptions = options.objcOptions ?? const ObjcOptions();
    final ObjcOptions objcOptionsWithHeader = objcOptions.copy(
        copyrightHeader: options.copyrightHeader != null
            ? _lineReader(options.copyrightHeader!)
            : null);
    generateObjcSource(objcOptionsWithHeader, root, sink);
  }

  @override
  IOSink? shouldGenerate(PigeonOptions options) =>
      _openSink(options.objcSourceOut);
}

/// A [Generator] that generates Java source code.
class JavaGenerator implements Generator {
  /// Constructor for [JavaGenerator].
  const JavaGenerator();

  @override
  void generate(StringSink sink, PigeonOptions options, Root root) {
    JavaOptions javaOptions = options.javaOptions ?? const JavaOptions();
    javaOptions = javaOptions.copy(
        className: javaOptions.className ??
            path.basenameWithoutExtension(options.javaOut!),
        copyrightHeader: options.copyrightHeader != null
            ? _lineReader(options.copyrightHeader!)
            : null);
    generateJava(javaOptions, root, sink);
  }

  @override
  IOSink? shouldGenerate(PigeonOptions options) => _openSink(options.javaOut);
}

bool _hasMetadata(
    dart_ast.NodeList<dart_ast.Annotation> metadata, String query) {
  return metadata
      .where((dart_ast.Annotation element) => element.name.name == query)
      .isNotEmpty;
}

List<Error> _validateAst(Root root) {
  final List<Error> result = <Error>[];
  final List<String> customClasses =
      root.classes.map((Class x) => x.name).toList();
  final List<String> customEnums = root.enums.map((Enum x) => x.name).toList();
  for (final Class klass in root.classes) {
    for (final Field field in klass.fields) {
      if (!(_validTypes.contains(field.dataType) ||
          customClasses.contains(field.dataType) ||
          customEnums.contains(field.dataType))) {
        result.add(Error(
            message:
                'Unsupported datatype:"${field.dataType}" in class "${klass.name}".'));
      }
    }
  }
  for (final Api api in root.apis) {
    for (final Method method in api.methods) {
      if (_validTypes.contains(method.argType)) {
        result.add(Error(
            message:
                'Unsupported argument type: "${method.argType}" in API: "${api.name}" method: "${method.name}'));
      }
      if (_validTypes.contains(method.returnType)) {
        result.add(Error(
            message:
                'Unsupported return type: "${method.returnType}" in API: "${api.name}" method: "${method.name}'));
      }
    }
  }

  return result;
}

class _RootBuilder extends dart_ast_visitor.RecursiveAstVisitor<Object?> {
  final List<Api> _apis = <Api>[];
  final List<Enum> _enums = <Enum>[];
  final List<Class> _classes = <Class>[];
  final List<Error> _errors = <Error>[];

  Class? _currentClass;
  Api? _currentApi;

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

  ParseResults results({List<String>? typeFilter}) {
    _storeCurrentApi();
    _storeCurrentClass();

    final List<Api> filteredApis = typeFilter == null
        ? _apis
        : _apis.where((Api x) => typeFilter.contains(x.name)).toList();

    final Set<String> referencedTypes = <String>{};
    for (final Api api in filteredApis) {
      for (final Method method in api.methods) {
        referencedTypes.add(method.argType);
        referencedTypes.add(method.returnType);
      }
    }

    final List<Class> classesWithNullTagStripped = _classes.map((Class aClass) {
      return Class(
          name: aClass.name,
          fields: aClass.fields.map((Field field) {
            String datatype = field.dataType;
            if (datatype.endsWith('?')) {
              datatype = datatype.substring(0, datatype.length - 1);
            } else {
              // _errors.add(Error(
              //     message:
              //         'Field ${aClass.name}.${field.name} must be nullable.'));
            }
            return Field(name: field.name, dataType: datatype);
          }).toList());
    }).toList();

    final List<String> classesToCheck = List<String>.from(referencedTypes);
    while (classesToCheck.isNotEmpty) {
      final String next = classesToCheck.last;
      classesToCheck.removeLast();
      final Class aClass = classesWithNullTagStripped.firstWhere(
          (Class x) => x.name == next,
          orElse: () => Class(name: '', fields: <Field>[]));
      for (final Field field in aClass.fields) {
        if (!referencedTypes.contains(field.dataType) &&
            classesWithNullTagStripped
                    .indexWhere((Class x) => x.name == field.dataType) >=
                0) {
          referencedTypes.add(field.dataType);
          classesToCheck.add(field.dataType);
        }
      }
    }

    final bool Function(Class) classRemover = typeFilter == null
        ? (Class x) => !referencedTypes.contains(x.name)
        : (Class x) =>
            !referencedTypes.contains(x.name) && !typeFilter.contains(x.name);
    final List<Class> referencedClasses =
        List<Class>.from(classesWithNullTagStripped);
    referencedClasses.removeWhere(classRemover);

    final Root completeRoot =
        Root(apis: filteredApis, classes: referencedClasses, enums: _enums);

    final List<Error> validateErrors = _validateAst(completeRoot);
    final List<Error> totalErrors = List<Error>.from(_errors);
    totalErrors.addAll(validateErrors);

    return ParseResults(
      root: totalErrors.isEmpty
          ? completeRoot
          : Root(apis: <Api>[], classes: <Class>[], enums: <Enum>[]),
      errors: totalErrors,
    );
  }

  @override
  Object? visitClassDeclaration(dart_ast.ClassDeclaration node) {
    _storeCurrentApi();
    _storeCurrentClass();

    if (node.isAbstract) {
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
          name: node.name.name,
          location: ApiLocation.host,
          methods: <Method>[],
          dartHostTestHandler: dartHostTestHandler,
        );
      } else if (_hasMetadata(node.metadata, 'FlutterApi')) {
        _currentApi = Api(
          name: node.name.name,
          location: ApiLocation.flutter,
          methods: <Method>[],
        );
      }
    } else {
      _currentClass = Class(name: node.name.name, fields: <Field>[]);
    }

    node.visitChildren(this);
    return null;
  }

  @override
  Object? visitMethodDeclaration(dart_ast.MethodDeclaration node) {
    final dart_ast.FormalParameterList parameters = node.parameters!;
    late String argType;
    if (parameters.parameters.isEmpty) {
      argType = 'void';
    } else {
      final dart_ast.FormalParameter firstParameter =
          parameters.parameters.first;
      final dart_ast.TypeName typeName = firstParameter.childEntities
          // ignore: always_specify_types
          .firstWhere((e) => e is dart_ast.TypeName) as dart_ast.TypeName;
      argType = typeName.name.name;
    }
    final bool isAsynchronous = _hasMetadata(node.metadata, 'async');
    if (_currentApi != null) {
      _currentApi!.methods.add(Method(
          name: node.name.name,
          returnType: node.returnType.toString(),
          argType: argType,
          isAsynchronous: isAsynchronous));
    }
    return null;
  }

  @override
  Object? visitEnumDeclaration(dart_ast.EnumDeclaration node) {
    _enums.add(Enum(
        name: node.name.name,
        members: node.constants
            .map((dart_ast.EnumConstantDeclaration e) => e.name.name)
            .toList()));
    return null;
  }

  @override
  Object? visitFieldDeclaration(dart_ast.FieldDeclaration node) {
    if (_currentClass != null) {
      _currentClass!.fields.add(Field(
          name: node.fields.variables[0].name.name,
          dataType: node.fields.type.toString()));
    }
    return null;
  }
}

int _calculateLineNumber(AnalysisError error) {
  int result = 1;
  final String contents = error.source.contents.data;

  for (int i = 0; i < error.offset; ++i) {
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

  String _typeNameToString(Type type) {
    return MirrorSystem.getName(reflectClass(type).simpleName);
  }

  /// Reads the file located at [path] and generates [ParseResults] by parsing
  /// it.  [types] optionally filters out what datatypes are actually parsed.
  ParseResults parseFile(String inputPath, {List<Type>? types}) {
    final List<String> includedPaths = <String>[
      path.absolute(path.normalize(inputPath))
    ];
    final AnalysisContextCollection collection =
        AnalysisContextCollection(includedPaths: includedPaths);

    final List<Error> compilationErrors = <Error>[];
    final _RootBuilder rootBuilder = _RootBuilder();
    for (final AnalysisContext context in collection.contexts) {
      for (final String path in context.contextRoot.analyzedFiles()) {
        final AnalysisSession session = context.currentSession;
        final ParsedUnitResult result =
            session.getParsedUnit2(path) as ParsedUnitResult;
        if (result.errors.isEmpty) {
          final CompilationUnit unit = result.unit;
          unit.accept(rootBuilder);
        } else {
          for (final AnalysisError error in result.errors) {
            compilationErrors.add(Error(
                message: error.message,
                filename: error.source.fullName,
                lineNumber: _calculateLineNumber(error)));
          }
        }
      }
    }

    if (compilationErrors.isEmpty) {
      return rootBuilder.results(
          typeFilter:
              // ignore: prefer_null_aware_operators
              types == null ? null : types.map(_typeNameToString).toList());
    } else {
      return ParseResults(root: Root.makeEmpty(), errors: compilationErrors);
    }
  }

  /// String that describes how the tool is used.
  static String get usage {
    return '''

Pigeon is a tool for generating type-safe communication code between Flutter
and the host platform.

usage: pigeon --input <pigeon path> --dart_out <dart path> [option]*

options:
''' +
        _argParser.usage;
  }

  static final ArgParser _argParser = ArgParser()
    ..addOption('input', help: 'REQUIRED: Path to pigeon file.')
    ..addOption('dart_out',
        help: 'REQUIRED: Path to generated Dart source file (.dart).')
    ..addOption('dart_test_out',
        help: 'Path to generated library for Dart tests, when using '
            '@HostApi(dartHostTestHandler:).')
    ..addOption('objc_source_out',
        help: 'Path to generated Objective-C source file (.m).')
    ..addOption('java_out', help: 'Path to generated Java file (.java).')
    ..addOption('java_package',
        help: 'The package that generated Java code will be in.')
    ..addFlag('dart_null_safety',
        help: 'Makes generated Dart code have null safety annotations',
        defaultsTo: true)
    ..addOption('objc_header_out',
        help: 'Path to generated Objective-C header file (.h).')
    ..addOption('objc_prefix',
        help: 'Prefix for generated Objective-C classes and protocols.')
    ..addOption('copyright_header',
        help:
            'Path to file with copyright header to be prepended to generated code.');

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
      ),
      dartOptions: DartOptions(
        isNullSafe: results['dart_null_safety'],
      ),
      copyrightHeader: results['copyright_header'],
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
            print('warning: invalid \'configurePigeon\' method defined.');
          }
        }
      }
    }
  }

  /// The 'main' entrypoint used by the command-line tool.  [args] are the
  /// command-line arguments.  The optional parameter [generators] allows you to
  /// customize the generators that pigeon will use.
  static Future<int> run(List<String> args,
      {List<Generator>? generators}) async {
    final Pigeon pigeon = Pigeon.setup();
    PigeonOptions options = Pigeon.parseArgs(args);
    final List<Generator> safeGenerators = generators ??
        <Generator>[
          const DartGenerator(),
          const JavaGenerator(),
          const DartTestGenerator(),
          const ObjcHeaderGenerator(),
          const ObjcSourceGenerator(),
        ];
    _executeConfigurePigeon(options);

    if (options.input == null || options.dartOut == null) {
      print(usage);
      return 0;
    }

    final List<Error> errors = <Error>[];
    if (options.objcHeaderOut != null) {
      options = options.copy(
          objcOptions: options.objcOptions!
              .copy(header: path.basename(options.objcHeaderOut!)));
    }

    final ParseResults parseResults = pigeon.parseFile(options.input!);
    for (final Error err in parseResults.errors) {
      errors.add(Error(
          message: err.message,
          filename: options.input,
          lineNumber: err.lineNumber));
    }
    if (errors.isEmpty) {
      for (final Generator generator in safeGenerators) {
        final IOSink? sink = generator.shouldGenerate(options);
        if (sink != null) {
          generator.generate(sink, options, parseResults.root);
          await sink.flush();
        }
      }
    }

    printErrors(errors);

    return errors.isNotEmpty ? 1 : 0;
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
