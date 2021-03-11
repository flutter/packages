// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:mirrors';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:path/path.dart';
import 'package:pigeon/java_generator.dart';

import 'ast.dart';
import 'dart_generator.dart';
import 'generator_tools.dart';
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
  final String dartHostTestHandler;
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
  Error({this.message, this.filename, this.lineNumber});

  /// A description of the error.
  String message;

  /// What file caused the [Error].
  String filename;

  /// What line the error happened on.
  int lineNumber;

  @override
  String toString() {
    return '(Error message:"$message" filename:"$filename" lineNumber:$lineNumber)';
  }
}

bool _isApi(ClassMirror classMirror) {
  return classMirror.isAbstract &&
      (_getHostApi(classMirror) != null || _isFlutterApi(classMirror));
}

HostApi _getHostApi(ClassMirror apiMirror) {
  for (final InstanceMirror instance in apiMirror.metadata) {
    if (instance.reflectee is HostApi) {
      return instance.reflectee;
    }
  }
  return null;
}

bool _isFlutterApi(ClassMirror apiMirror) {
  for (final InstanceMirror instance in apiMirror.metadata) {
    if (instance.reflectee is FlutterApi) {
      return true;
    }
  }
  return false;
}

/// Options used when running the code generator.
class PigeonOptions {
  /// Path to the file which will be processed.
  String input;

  /// Path to the dart file that will be generated.
  String dartOut;

  /// Path to the dart file that will be generated for test support classes.
  String dartTestOut;

  /// Path to the ".h" Objective-C file will be generated.
  String objcHeaderOut;

  /// Path to the ".m" Objective-C file will be generated.
  String objcSourceOut;

  /// Options that control how Objective-C will be generated.
  ObjcOptions objcOptions = ObjcOptions();

  /// Path to the java file that will be generated.
  String javaOut;

  /// Options that control how Java will be generated.
  JavaOptions javaOptions = JavaOptions();

  /// Options that control how Dart will be generated.
  DartOptions dartOptions = DartOptions();
}

/// A collection of an AST represented as a [Root] and [Error]'s.
class ParseResults {
  /// Parametric constructor for [ParseResults].
  ParseResults({this.root, this.errors});

  /// The resulting AST.
  final Root root;

  /// Errors generated while parsing input.
  final List<Error> errors;
}

/// Tool for generating code to facilitate platform channels usage.
class Pigeon {
  /// Create and setup a [Pigeon] instance.
  static Pigeon setup() {
    return Pigeon();
  }

  Class _parseClassMirror(ClassMirror klassMirror) {
    final List<Field> fields = <Field>[];
    for (final DeclarationMirror declaration
        in klassMirror.declarations.values) {
      if (declaration is VariableMirror) {
        fields.add(Field()
          ..name = MirrorSystem.getName(declaration.simpleName)
          ..dataType = MirrorSystem.getName(declaration.type.simpleName));
      }
    }
    final Class klass = Class()
      ..name = MirrorSystem.getName(klassMirror.simpleName)
      ..fields = fields;
    return klass;
  }

  Iterable<Class> _parseClassMirrors(Iterable<ClassMirror> mirrors) sync* {
    for (final ClassMirror mirror in mirrors) {
      yield _parseClassMirror(mirror);
      final Iterable<ClassMirror> nestedTypes = mirror.declarations.values
          .whereType<VariableMirror>()
          .map((VariableMirror variable) => variable.type)
          .whereType<ClassMirror>()

          ///note: This will need to be changed if we support generic types.
          .where((ClassMirror mirror) =>
              !_validTypes.contains(MirrorSystem.getName(mirror.simpleName)));
      for (final Class klass in _parseClassMirrors(nestedTypes)) {
        yield klass;
      }
    }
  }

  Iterable<T> _unique<T, U>(Iterable<T> iter, U Function(T val) getKey) sync* {
    final Set<U> seen = <U>{};
    for (final T val in iter) {
      if (seen.add(getKey(val))) {
        yield val;
      }
    }
  }

  /// Use reflection to parse the [types] provided.
  ParseResults parse(List<Type> types) {
    final Root root = Root();
    final Set<ClassMirror> classes = <ClassMirror>{};
    final List<ClassMirror> apis = <ClassMirror>[];

    for (final Type type in types) {
      final ClassMirror classMirror = reflectClass(type);
      if (_isApi(classMirror)) {
        apis.add(classMirror);
      } else {
        classes.add(classMirror);
      }
    }

    for (final ClassMirror apiMirror in apis) {
      for (final DeclarationMirror declaration
          in apiMirror.declarations.values) {
        if (declaration is MethodMirror && !declaration.isConstructor) {
          if (!isVoid(declaration.returnType)) {
            classes.add(declaration.returnType);
          }
          if (declaration.parameters.isNotEmpty) {
            classes.add(declaration.parameters[0].type);
          }
        }
      }
    }

    root.classes =
        _unique(_parseClassMirrors(classes), (Class x) => x.name).toList();

    root.apis = <Api>[];
    for (final ClassMirror apiMirror in apis) {
      final List<Method> functions = <Method>[];
      for (final DeclarationMirror declaration
          in apiMirror.declarations.values) {
        if (declaration is MethodMirror && !declaration.isConstructor) {
          final bool isAsynchronous =
              declaration.metadata.any((InstanceMirror it) {
            return MirrorSystem.getName(it.type.simpleName) ==
                '${async.runtimeType}';
          });
          functions.add(Method()
            ..name = MirrorSystem.getName(declaration.simpleName)
            ..argType = declaration.parameters.isEmpty
                ? 'void'
                : MirrorSystem.getName(
                    declaration.parameters[0].type.simpleName)
            ..returnType =
                MirrorSystem.getName(declaration.returnType.simpleName)
            ..isAsynchronous = isAsynchronous);
        }
      }
      final HostApi hostApi = _getHostApi(apiMirror);
      root.apis.add(Api(
          name: MirrorSystem.getName(apiMirror.simpleName),
          location: hostApi != null ? ApiLocation.host : ApiLocation.flutter,
          methods: functions,
          dartHostTestHandler: hostApi?.dartHostTestHandler));
    }

    final List<Error> validateErrors = _validateAst(root);
    return ParseResults(root: root, errors: validateErrors);
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
        help: 'Makes generated Dart code have null safety annotations')
    ..addOption('objc_header_out',
        help: 'Path to generated Objective-C header file (.h).')
    ..addOption('objc_prefix',
        help: 'Prefix for generated Objective-C classes and protocols.');

  /// Convert command-line arugments to [PigeonOptions].
  static PigeonOptions parseArgs(List<String> args) {
    final ArgResults results = _argParser.parse(args);

    final PigeonOptions opts = PigeonOptions();
    opts.input = results['input'];
    opts.dartOut = results['dart_out'];
    opts.dartTestOut = results['dart_test_out'];
    opts.objcHeaderOut = results['objc_header_out'];
    opts.objcSourceOut = results['objc_source_out'];
    opts.objcOptions.prefix = results['objc_prefix'];
    opts.javaOut = results['java_out'];
    opts.javaOptions.package = results['java_package'];
    opts.dartOptions.isNullSafe = results['dart_null_safety'];
    return opts;
  }

  static Future<void> _runGenerator(
      String output, void Function(IOSink sink) func) async {
    IOSink sink;
    File file;
    if (output == 'stdout') {
      sink = stdout;
    } else {
      file = File(output);
      sink = file.openWrite();
    }
    func(sink);
    await sink.flush();
  }

  List<Error> _validateAst(Root root) {
    final List<Error> result = <Error>[];
    final List<String> customClasses =
        root.classes.map((Class x) => x.name).toList();
    for (final Class klass in root.classes) {
      for (final Field field in klass.fields) {
        if (!(_validTypes.contains(field.dataType) ||
            customClasses.contains(field.dataType))) {
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

  static String _posixify(String input) {
    final path.Context context = path.Context(style: path.Style.posix);
    return context.fromUri(path.toUri(path.absolute(input)));
  }

  /// The 'main' entrypoint used by the command-line tool.  [args] are the
  /// command-line arguments.
  static Future<int> run(List<String> args) async {
    final Pigeon pigeon = Pigeon.setup();
    final PigeonOptions options = Pigeon.parseArgs(args);

    _executeConfigurePigeon(options);

    if (options.input == null || options.dartOut == null) {
      print(usage);
      return 0;
    }

    final List<Error> errors = <Error>[];
    final List<Type> apis = <Type>[];
    if (options.objcHeaderOut != null) {
      options.objcOptions.header = basename(options.objcHeaderOut);
    }
    if (options.javaOut != null) {
      options.javaOptions.className = basenameWithoutExtension(options.javaOut);
    }

    for (final LibraryMirror library
        in currentMirrorSystem().libraries.values) {
      for (final DeclarationMirror declaration in library.declarations.values) {
        if (declaration is ClassMirror && _isApi(declaration)) {
          apis.add(declaration.reflectedType);
        }
      }
    }

    if (apis.isNotEmpty) {
      final ParseResults parseResults = pigeon.parse(apis);
      for (final Error err in parseResults.errors) {
        errors.add(Error(message: err.message, filename: options.input));
      }
      if (options.dartOut != null) {
        await _runGenerator(
            options.dartOut,
            (StringSink sink) =>
                generateDart(options.dartOptions, parseResults.root, sink));
      }
      if (options.dartTestOut != null) {
        final String mainPath = context.relative(
          _posixify(options.dartOut),
          from: _posixify(path.dirname(options.dartTestOut)),
        );
        await _runGenerator(
          options.dartTestOut,
          (StringSink sink) => generateTestDart(
            options.dartOptions,
            parseResults.root,
            sink,
            mainPath,
          ),
        );
      }
      if (options.objcHeaderOut != null) {
        await _runGenerator(
            options.objcHeaderOut,
            (StringSink sink) => generateObjcHeader(
                options.objcOptions, parseResults.root, sink));
      }
      if (options.objcSourceOut != null) {
        await _runGenerator(
            options.objcSourceOut,
            (StringSink sink) => generateObjcSource(
                options.objcOptions, parseResults.root, sink));
      }
      if (options.javaOut != null) {
        await _runGenerator(
            options.javaOut,
            (StringSink sink) =>
                generateJava(options.javaOptions, parseResults.root, sink));
      }
    } else {
      errors.add(Error(message: 'No pigeon classes found, nothing generated.'));
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
