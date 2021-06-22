// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
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

bool _isApi(ClassMirror classMirror) {
  return classMirror.isAbstract &&
      (_getHostApi(classMirror) != null || _isFlutterApi(classMirror));
}

HostApi? _getHostApi(ClassMirror apiMirror) {
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
  /// Creates a instance of PigeonOptions
  PigeonOptions();

  /// Path to the file which will be processed.
  String? input;

  /// Path to the dart file that will be generated.
  String? dartOut;

  /// Path to the dart file that will be generated for test support classes.
  String? dartTestOut;

  /// Path to the ".h" Objective-C file will be generated.
  String? objcHeaderOut;

  /// Path to the ".m" Objective-C file will be generated.
  String? objcSourceOut;

  /// Options that control how Objective-C will be generated.
  ObjcOptions? objcOptions;

  /// Path to the java file that will be generated.
  String? javaOut;

  /// Options that control how Java will be generated.
  JavaOptions? javaOptions;

  /// Options that control how Dart will be generated.
  DartOptions? dartOptions = DartOptions();

  /// Path to a copyright header that will get prepended to generated code.
  String? copyrightHeader;
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
    final DartOptions dartOptions = options.dartOptions ?? DartOptions();
    dartOptions.copyrightHeader = options.copyrightHeader != null
        ? _lineReader(options.copyrightHeader!)
        : null;
    generateDart(dartOptions, root, sink);
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
    final String mainPath = context.relative(
      _posixify(options.dartOut!),
      from: _posixify(path.dirname(options.dartTestOut!)),
    );
    generateTestDart(
      options.dartOptions ?? DartOptions(),
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
    final ObjcOptions objcOptions = options.objcOptions ?? ObjcOptions();
    objcOptions.copyrightHeader = options.copyrightHeader != null
        ? _lineReader(options.copyrightHeader!)
        : null;
    generateObjcHeader(objcOptions, root, sink);
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
    final ObjcOptions objcOptions = options.objcOptions ?? ObjcOptions();
    objcOptions.copyrightHeader = options.copyrightHeader != null
        ? _lineReader(options.copyrightHeader!)
        : null;
    generateObjcSource(objcOptions, root, sink);
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
    if (options.javaOptions!.className == null) {
      options.javaOptions!.className =
          path.basenameWithoutExtension(options.javaOut!);
    }
    options.javaOptions!.copyrightHeader = options.copyrightHeader != null
        ? _lineReader(options.copyrightHeader!)
        : null;
    generateJava(options.javaOptions ?? JavaOptions(), root, sink);
  }

  @override
  IOSink? shouldGenerate(PigeonOptions options) => _openSink(options.javaOut);
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
        fields.add(Field(
          name: MirrorSystem.getName(declaration.simpleName),
          dataType: MirrorSystem.getName(
            declaration.type.simpleName,
          ),
        ));
      }
    }
    final Class klass = Class(
      name: MirrorSystem.getName(klassMirror.simpleName),
      fields: fields,
    );
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
              !_validTypes.contains(MirrorSystem.getName(mirror.simpleName)) &&
              !mirror.isEnum);
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
    final Set<ClassMirror> classes = <ClassMirror>{};
    final Set<ClassMirror> enums = <ClassMirror>{};
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
            classes.add(declaration.returnType as ClassMirror);
          }
          if (declaration.parameters.isNotEmpty) {
            classes.add(declaration.parameters[0].type as ClassMirror);
          }
        }
      }
    }

    // Recurse into class field declarations.
    final List<ClassMirror> classesToRecurse = <ClassMirror>[...classes];
    while (classesToRecurse.isNotEmpty) {
      final ClassMirror next = classesToRecurse.removeLast();
      for (final DeclarationMirror declaration in next.declarations.values) {
        if (declaration is VariableMirror) {
          final TypeMirror fieldType = declaration.type;
          if (fieldType is ClassMirror) {
            if (!classes.contains(fieldType) &&
                !fieldType.isEnum &&
                !_validTypes
                    .contains(MirrorSystem.getName(fieldType.simpleName))) {
              classes.add(declaration.type as ClassMirror);
              classesToRecurse.add(declaration.type as ClassMirror);
            }
          }
        }
      }
    }

    // Parse referenced enum types out of classes.
    for (final ClassMirror klass in classes) {
      for (final DeclarationMirror declaration in klass.declarations.values) {
        if (declaration is VariableMirror) {
          if (declaration.type is ClassMirror &&
              (declaration.type as ClassMirror).isEnum) {
            enums.add(declaration.type as ClassMirror);
          }
        }
      }
    }
    final Root root = Root(
      classes:
          _unique(_parseClassMirrors(classes), (Class x) => x.name).toList(),
      apis: <Api>[],
      enums: <Enum>[],
    );
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
          functions.add(Method(
            name: MirrorSystem.getName(declaration.simpleName),
            argType: declaration.parameters.isEmpty
                ? 'void'
                : MirrorSystem.getName(
                    declaration.parameters[0].type.simpleName),
            returnType: MirrorSystem.getName(declaration.returnType.simpleName),
            isAsynchronous: isAsynchronous,
          ));
        }
      }
      final HostApi? hostApi = _getHostApi(apiMirror);
      root.apis.add(Api(
        name: MirrorSystem.getName(apiMirror.simpleName),
        location: hostApi != null ? ApiLocation.host : ApiLocation.flutter,
        methods: functions,
        dartHostTestHandler: hostApi?.dartHostTestHandler,
      ));
    }

    for (final ClassMirror enumMirror in enums) {
      // These declarations are innate to enums and are skipped as they are
      // not user defined values.
      final Set<String> skippedEnumDeclarations = <String>{
        'index',
        '_name',
        'values',
        'toString',
        'TestEnum',
        MirrorSystem.getName(enumMirror.simpleName),
      };
      final List<String> members = <String>[];
      final List<Symbol> keys = enumMirror.declarations.keys.toList();
      for (int i = 0; i < enumMirror.declarations.keys.length; i++) {
        final String name = MirrorSystem.getName(keys[i]);
        if (skippedEnumDeclarations.contains(name)) {
          continue;
        }
        members.add(name);
      }
      root.enums.add(Enum(
          name: MirrorSystem.getName(enumMirror.simpleName), members: members));
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

    final PigeonOptions opts = PigeonOptions();
    opts.input = results['input'];
    opts.dartOut = results['dart_out'];
    opts.dartTestOut = results['dart_test_out'];
    opts.objcHeaderOut = results['objc_header_out'];
    opts.objcSourceOut = results['objc_source_out'];
    opts.objcOptions = ObjcOptions(
      prefix: results['objc_prefix'],
    );
    opts.javaOut = results['java_out'];
    opts.javaOptions = JavaOptions(
      package: results['java_package'],
    );
    opts.dartOptions = DartOptions()..isNullSafe = results['dart_null_safety'];
    opts.copyrightHeader = results['copyright_header'];
    return opts;
  }

  List<Error> _validateAst(Root root) {
    final List<Error> result = <Error>[];
    final List<String> customClasses =
        root.classes.map((Class x) => x.name).toList();
    final List<String> customEnums =
        root.enums.map((Enum x) => x.name).toList();
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
    final PigeonOptions options = Pigeon.parseArgs(args);
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
    final List<Type> apis = <Type>[];
    if (options.objcHeaderOut != null) {
      options.objcOptions?.header = basename(options.objcHeaderOut!);
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
      for (final Generator generator in safeGenerators) {
        final IOSink? sink = generator.shouldGenerate(options);
        if (sink != null) {
          generator.generate(sink, options, parseResults.root);
          await sink.flush();
        }
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
