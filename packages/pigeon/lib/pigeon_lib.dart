import 'dart:io';
import 'dart:mirrors';

import 'package:args/args.dart';
import 'package:path/path.dart';

import 'ast.dart';
import 'dart_generator.dart';
import 'objc_generator.dart';

const List<String> _validTypes = <String>[
  'String',
  'int',
  'double',
  'Uint8List',
  'Int32List',
  'Int64List',
  'Float64List',
  'List',
  'Map',
];

class HostApi {
  const HostApi();
}

class FlutterApi {
  const FlutterApi();
}

class Error {
  Error({this.message, this.filename, this.lineNumber});
  String message;
  String filename;
  int lineNumber;
}

bool _isApi(ClassMirror classMirror) {
  return classMirror.isAbstract && _isHostApi(classMirror);
}

bool _isHostApi(ClassMirror apiMirror) {
  for (InstanceMirror instance in apiMirror.metadata) {
    if (instance.reflectee is HostApi) {
      return true;
    }
  }
  return false;
}

class DartleOptions {
  String input;
  String dartOut;
  String objcHeaderOut;
  String objcSourceOut;
  ObjcOptions objcOptions = ObjcOptions();
}

class ParseResults {
  ParseResults({this.root, this.errors});
  final Root root;
  final List<Error> errors;
}

class Dartle {
  static Dartle setup() {
    return Dartle();
  }

  Class _parseClassMirror(ClassMirror klassMirror) {
    final List<Field> fields = <Field>[];
    for (DeclarationMirror declaration in klassMirror.declarations.values) {
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

  ParseResults parse(List<Type> types) {
    final Root root = Root();
    final Set<ClassMirror> classes = <ClassMirror>{};
    final List<ClassMirror> apis = <ClassMirror>[];

    for (Type type in types) {
      final ClassMirror classMirror = reflectClass(type);
      if (_isApi(classMirror)) {
        apis.add(classMirror);
      } else {
        classes.add(classMirror);
      }
    }

    for (ClassMirror apiMirror in apis) {
      for (DeclarationMirror declaration in apiMirror.declarations.values) {
        if (declaration is MethodMirror && !declaration.isConstructor) {
          classes.add(declaration.returnType);
          classes.add(declaration.parameters[0].type);
        }
      }
    }

    root.classes = classes.map(_parseClassMirror).toList();

    root.apis = <Api>[];
    for (ClassMirror apiMirror in apis) {
      if (_isHostApi(apiMirror)) {
        final List<Func> functions = <Func>[];
        for (DeclarationMirror declaration in apiMirror.declarations.values) {
          if (declaration is MethodMirror && !declaration.isConstructor) {
            functions.add(Func()
              ..name = MirrorSystem.getName(declaration.simpleName)
              ..argType = MirrorSystem.getName(
                  declaration.parameters[0].type.simpleName)
              ..returnType =
                  MirrorSystem.getName(declaration.returnType.simpleName));
          }
        }
        root.apis.add(Api()
          ..name = MirrorSystem.getName(apiMirror.simpleName)
          ..location = ApiLocation.host
          ..functions = functions);
      }
    }

    final List<Error> validateErrors = _validateAst(root);
    return ParseResults(root: root, errors: validateErrors);
  }

  static String get usage {
    return '''

Dartle is a tool for generating type-safe communication code between Flutter
and the host platform.

usage: dartle --input <dartle path> --dart_out <dart path> [option]*

options:
''' +
        _argParser.usage;
  }

  static final ArgParser _argParser = ArgParser()
    ..addOption('input', help: 'REQUIRED: Path to dartle file.')
    ..addOption('dart_out',
        help: 'REQUIRED: Path to generated dart source file (.dart).')
    ..addOption('objc_source_out',
        help: 'Path to generated Objective-C source file (.m).')
    ..addOption('objc_header_out',
        help: 'Path to generated Objective-C header file (.h).')
    ..addOption('objc_prefix',
        help: 'Prefix for generated Objective-C classes and protocols.');

  static DartleOptions parseArgs(List<String> args) {
    final ArgResults results = _argParser.parse(args);

    final DartleOptions opts = DartleOptions();
    opts.input = results['input'];
    opts.dartOut = results['dart_out'];
    opts.objcHeaderOut = results['objc_header_out'];
    opts.objcSourceOut = results['objc_source_out'];
    opts.objcOptions.prefix = results['objc_prefix'];
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
    final List<String> customClasses = root.classes.map((Class x) => x.name).toList();
    for (Class klass in root.classes) {
      for (Field field in klass.fields) {
        if (!(_validTypes.contains(field.dataType) ||
            customClasses.contains(field.dataType))) {
          result.add(Error(
              message:
                  'Unsupported datatype:"${field.dataType}" in class "${klass.name}".'));
        }
      }
    }
    return result;
  }

  /// Crawls through the reflection system looking for a setupDartle method and
  /// executing it.
  static void _executeSetupDartle(DartleOptions options) {
    for (LibraryMirror library in currentMirrorSystem().libraries.values) {
      for (DeclarationMirror declaration in library.declarations.values) {
        if (declaration is MethodMirror &&
            MirrorSystem.getName(declaration.simpleName) == 'setupDartle') {
          if (declaration.parameters.length == 1 &&
              declaration.parameters[0].type == reflectClass(DartleOptions)) {
            library.invoke(declaration.simpleName, <dynamic>[options]);
          } else {
            print('warning: invalid \'setupDartle\' method defined.');
          }
        }
      }
    }
  }

  static Future<int> run(List<String> args) async {
    final Dartle dartle = Dartle.setup();
    final DartleOptions options = Dartle.parseArgs(args);

    _executeSetupDartle(options);

    if (options.input == null || options.dartOut == null) {
      print(usage);
      return 0;
    }

    final List<Error> errors = <Error>[];
    final List<Type> apis = <Type>[];
    options.objcOptions.header = basename(options.objcHeaderOut);

    for (LibraryMirror library in currentMirrorSystem().libraries.values) {
      for (DeclarationMirror declaration in library.declarations.values) {
        if (declaration is ClassMirror && _isApi(declaration)) {
          apis.add(declaration.reflectedType);
        }
      }
    }

    if (apis.isNotEmpty) {
      final ParseResults parseResults = dartle.parse(apis);
      for (Error err in parseResults.errors) {
        errors.add(Error(message: err.message, filename: options.input));
      }
      if (options.dartOut != null) {
        await _runGenerator(options.dartOut,
            (StringSink sink) => generateDart(parseResults.root, sink));
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
    } else {
      errors.add(Error(message: 'No dartle classes found, nothing generated.'));
    }

    printErrors(errors);

    return errors.isNotEmpty ? 1 : 0;
  }

  static void printErrors(List<Error> errors) {
    for (Error err in errors) {
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
