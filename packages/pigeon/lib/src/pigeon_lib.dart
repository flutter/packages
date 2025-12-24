// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:mirrors';

import 'package:analyzer/dart/analysis/analysis_context.dart'
    show AnalysisContext;
import 'package:analyzer/dart/analysis/analysis_context_collection.dart'
    show AnalysisContextCollection;
import 'package:analyzer/dart/analysis/results.dart' show ParsedUnitResult;
import 'package:analyzer/dart/analysis/session.dart' show AnalysisSession;
import 'package:analyzer/dart/ast/ast.dart' as dart_ast;
import 'package:analyzer/diagnostic/diagnostic.dart' show Diagnostic;
import 'package:args/args.dart';
import 'package:meta/meta.dart' show visibleForTesting;
import 'package:path/path.dart' as path;

import 'ast.dart';
import 'cpp/cpp_generator.dart';
import 'dart/dart_generator.dart';
import 'generator_tools.dart';
import 'generator_tools.dart' as generator_tools;
import 'gobject/gobject_generator.dart';
import 'java/java_generator.dart';
import 'kotlin/kotlin_generator.dart';
import 'objc/objc_generator.dart';
import 'pigeon_lib_internal.dart';
import 'swift/swift_generator.dart';
import 'types/task_queue.dart';

export 'types/task_queue.dart' show TaskQueueType;

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
  const HostApi({
    @Deprecated('Mock/fake the generated Dart API instead.')
    this.dartHostTestHandler,
  });

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
  @Deprecated('Mock/fake the generated Dart API instead.')
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

/// Metadata to annotate a ProxyAPI.
///
/// A ProxyAPI is a generated API for interacting with a native type from Dart.
/// This includes the generated Dart proxy class and the native type API.
///
/// The abstract class with this annotation groups a collection of Dart↔host
/// constructors, fields, methods and host↔Dart methods used to interact with a
/// native type.
///
/// This generates:
/// 1. A Dart proxy class that handles communication with a native type API.
/// Instances of this proxy class represent instances of the native type.
/// 2. A native type API which handles communication with the Dart proxy class
/// and the native type. (e.g. When an instance method of a Dart proxy class is
/// called, the implementation of the native type API handles calling that
/// method on the native type.)
/// 3. An InstanceManager that is a global collection that manages serializable
/// references to the Dart proxy classes and the native type instances. This
/// also provides automatic garbage collection of native type instances when its
/// associated Dart proxy class instance is garbage collected.
class ProxyApi {
  /// Parametric constructor for [ProxyApi].
  const ProxyApi({this.superClass, this.kotlinOptions, this.swiftOptions});

  /// The class that is a super class to this one.
  ///
  /// Must be a type that is also annotated with [ProxyApi].
  ///
  /// This provides an alternative to calling `extends` on a class since this
  /// requires calling the super class constructor.
  ///
  /// Note that using this instead of `extends` can cause unexpected conflicts
  /// with inherited method names.
  final Type? superClass;

  /// Options that control how Swift code will be generated for a specific
  /// native type API of a ProxyAPI.
  final SwiftProxyApiOptions? swiftOptions;

  /// Options that control how Kotlin code will be generated for a specific
  /// native type API of a ProxyAPI.
  final KotlinProxyApiOptions? kotlinOptions;
}

/// Metadata to annotate a pigeon API that contains event channels.
///
/// This class is a tool to designate a set of event channel methods,
/// the class itself will not be generated.
///
/// All methods contained within the class will return a `Stream` of the
/// defined return type of the method definition.
class EventChannelApi {
  /// Constructor.
  const EventChannelApi({this.kotlinOptions, this.swiftOptions});

  /// Options for Kotlin generated code for Event Channels.
  final KotlinEventChannelOptions? kotlinOptions;

  /// Options for Swift generated code for Event Channels.
  final SwiftEventChannelOptions? swiftOptions;
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

/// Options used when configuring Pigeon.
class PigeonOptions {
  /// Creates a instance of PigeonOptions
  const PigeonOptions({
    this.input,
    this.dartOut,
    @Deprecated('Mock/fake the generated Dart API instead.') this.dartTestOut,
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
    this.astOut,
    this.debugGenerators,
    this.basePath,
    String? dartPackageName,
  }) : _dartPackageName = dartPackageName;

  /// Path to the file which will be processed.
  final String? input;

  /// Path to the Dart file that will be generated.
  final String? dartOut;

  /// Path to the Dart file that will be generated for test support classes.
  @Deprecated('Mock/fake the generated Dart API instead.')
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
              map['gobjectOptions']! as Map<String, Object>,
            )
          : null,
      dartOptions: map.containsKey('dartOptions')
          ? DartOptions.fromMap(map['dartOptions']! as Map<String, Object>)
          : null,
      copyrightHeader: map['copyrightHeader'] as String?,
      astOut: map['astOut'] as String?,
      debugGenerators: map['debugGenerators'] as bool?,
      basePath: map['basePath'] as String?,
      dartPackageName: map['dartPackageName'] as String?,
    );
  }

  /// Converts a [PigeonOptions] to a Map representation where:
  /// `x = PigeonOptions.fromMap(x.toMap())`.
  Map<String, Object> toMap() {
    final result = <String, Object>{
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
        'or add --package_name={name_of_package} to your command line pigeon call.',
      );
    }
    return name;
  }
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
    final includedPaths = <String>[path.absolute(path.normalize(inputPath))];
    final collection = AnalysisContextCollection(
      includedPaths: includedPaths,
      sdkPath: sdkPath,
    );

    final compilationErrors = <Error>[];
    final rootBuilder = RootBuilder(File(inputPath).readAsStringSync());
    for (final AnalysisContext context in collection.contexts) {
      for (final String path in context.contextRoot.analyzedFiles()) {
        final AnalysisSession session = context.currentSession;
        final result = session.getParsedUnit(path) as ParsedUnitResult;
        if (result.diagnostics.isEmpty) {
          final dart_ast.CompilationUnit unit = result.unit;
          unit.accept(rootBuilder);
        } else {
          for (final Diagnostic diagnostic in result.diagnostics) {
            compilationErrors.add(
              Error(
                message: diagnostic.message,
                filename: diagnostic.source.fullName,
                lineNumber: calculateLineNumber(
                  diagnostic.source.contents.data,
                  diagnostic.offset,
                ),
              ),
            );
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
    ..addOption(
      'dart_out',
      help:
          'Path to generated Dart source file (.dart). '
          'Required if one_language is not specified.',
    )
    ..addOption(
      'dart_test_out',
      help:
          'Path to generated library for Dart tests, when using '
          '@HostApi(dartHostTestHandler:).',
    )
    ..addOption(
      'objc_source_out',
      help: 'Path to generated Objective-C source file (.m).',
    )
    ..addOption('java_out', help: 'Path to generated Java file (.java).')
    ..addOption(
      'java_package',
      help: 'The package that generated Java code will be in.',
    )
    ..addFlag(
      'java_use_generated_annotation',
      help: 'Adds the java.annotation.Generated annotation to the output.',
    )
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
    ..addOption(
      'cpp_namespace',
      help: 'The namespace that generated C++ code will be in.',
    )
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
    ..addOption(
      'gobject_module',
      help: 'The module that generated GObject code will be in.',
    )
    ..addOption(
      'objc_header_out',
      help: 'Path to generated Objective-C header file (.h).',
    )
    ..addOption(
      'objc_prefix',
      help: 'Prefix for generated Objective-C classes and protocols.',
    )
    ..addOption(
      'copyright_header',
      help:
          'Path to file with copyright header to be prepended to generated code.',
    )
    ..addFlag(
      'one_language',
      hide: true,
      help: 'Does nothing, only here to avoid breaking changes',
    )
    ..addOption(
      'ast_out',
      help:
          'Path to generated AST debugging info. (Warning: format subject to change)',
    )
    ..addFlag(
      'debug_generators',
      help: 'Print the line number of the generator in comments at newlines.',
    )
    ..addOption(
      'base_path',
      help:
          'A base path to be prefixed to all outputs and copyright header path. Generally used for testing',
      hide: true,
    )
    ..addOption(
      'package_name',
      help: 'The package that generated code will be in.',
    );

  /// Convert command-line arguments to [PigeonOptions].
  static PigeonOptions parseArgs(List<String> args) {
    // Note: This function shouldn't perform any logic, just translate the args
    // to PigeonOptions.  Synthesized values inside of the PigeonOption should
    // get set in the `run` function to accommodate users that are using the
    // `configurePigeon` function.
    final ArgResults results = _argParser.parse(args);

    final opts = PigeonOptions(
      input: results['input'] as String?,
      dartOut: results['dart_out'] as String?,
      dartTestOut: results['dart_test_out'] as String?,
      objcHeaderOut: results['objc_header_out'] as String?,
      objcSourceOut: results['objc_source_out'] as String?,
      objcOptions: ObjcOptions(prefix: results['objc_prefix'] as String?),
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
      cppOptions: CppOptions(namespace: results['cpp_namespace'] as String?),
      gobjectHeaderOut: results['gobject_header_out'] as String?,
      gobjectSourceOut: results['gobject_source_out'] as String?,
      gobjectOptions: GObjectOptions(
        module: results['gobject_module'] as String?,
      ),
      copyrightHeader: results['copyright_header'] as String?,
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
  static Future<int> run(
    List<String> args, {
    List<GeneratorAdapter>? adapters,
    String? sdkPath,
  }) {
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
    bool mergeDefinitionFileOptions = true,
    @visibleForTesting ParseResults? parseResults,
  }) async {
    final Pigeon pigeon = Pigeon.setup();
    if (options.debugGenerators ?? false) {
      generator_tools.debugGenerators = true;
    }
    final List<GeneratorAdapter> safeGeneratorAdapters =
        adapters ??
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

    parseResults =
        parseResults ?? pigeon.parseFile(options.input!, sdkPath: sdkPath);

    final errors = <Error>[];
    errors.addAll(parseResults.errors);

    // Helper to clean up non-Stdout sinks.
    Future<void> releaseSink(IOSink sink) async {
      if (sink is! Stdout) {
        await sink.close();
      }
    }

    if (parseResults.pigeonOptions != null && mergeDefinitionFileOptions) {
      options = PigeonOptions.fromMap(
        mergeMaps(options.toMap(), parseResults.pigeonOptions!),
      );
    }

    final InternalPigeonOptions internalOptions =
        InternalPigeonOptions.fromPigeonOptions(options);

    for (final adapter in safeGeneratorAdapters) {
      final IOSink? sink = adapter.shouldGenerate(
        internalOptions,
        FileType.source,
      );
      if (sink != null) {
        final List<Error> adapterErrors = adapter.validate(
          internalOptions,
          parseResults.root,
        );
        errors.addAll(adapterErrors);
        await releaseSink(sink);
      }
    }

    if (errors.isNotEmpty) {
      printErrors(
        errors
            .map(
              (Error err) => Error(
                message: err.message,
                filename: internalOptions.input,
                lineNumber: err.lineNumber,
              ),
            )
            .toList(),
      );
      return 1;
    }

    for (final adapter in safeGeneratorAdapters) {
      for (final FileType fileType in adapter.fileTypeList) {
        final IOSink? sink = adapter.shouldGenerate(internalOptions, fileType);
        if (sink != null) {
          adapter.generate(sink, internalOptions, parseResults.root, fileType);
          await sink.flush();
          await releaseSink(sink);
        }
      }
    }

    return 0;
  }

  /// Print a list of errors to stderr.
  static void printErrors(List<Error> errors) {
    for (final err in errors) {
      if (err.filename != null) {
        if (err.lineNumber != null) {
          stderr.writeln(
            'Error: ${err.filename}:${err.lineNumber}: ${err.message}',
          );
        } else {
          stderr.writeln('Error: ${err.filename}: ${err.message}');
        }
      } else {
        stderr.writeln('Error: ${err.message}');
      }
    }
  }
}

/// Represents an error as a result of parsing and generating code.
class Error {
  /// Parametric constructor for Error.
  Error({required this.message, this.filename, this.lineNumber});

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
