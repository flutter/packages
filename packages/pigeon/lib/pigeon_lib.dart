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
import 'package:analyzer/dart/ast/syntactic_entity.dart'
    as dart_ast_syntactic_entity;
import 'package:analyzer/dart/ast/visitor.dart' as dart_ast_visitor;
import 'package:analyzer/error/error.dart' show AnalysisError;
import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:pigeon/generator_tools.dart';
import 'package:pigeon/java_generator.dart';

import 'ast.dart';
import 'dart_generator.dart';
import 'objc_generator.dart';

class _Asynchronous {
  const _Asynchronous();
}

/// Metadata to annotate a Api method as asynchronous
const _Asynchronous async = _Asynchronous();

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
      this.copyrightHeader,
      this.oneLanguage});

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

  /// If Pigeon allows generating code for one language.
  final bool? oneLanguage;

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
          ? ObjcOptions.fromMap((map['objcOptions'] as Map<String, Object>?)!)
          : null,
      javaOut: map['javaOut'] as String?,
      javaOptions: map.containsKey('javaOptions')
          ? JavaOptions.fromMap((map['javaOptions'] as Map<String, Object>?)!)
          : null,
      dartOptions: map.containsKey('dartOptions')
          ? DartOptions.fromMap((map['dartOptions'] as Map<String, Object>?)!)
          : null,
      copyrightHeader: map['copyrightHeader'] as String?,
      oneLanguage: map['oneLanguage'] as bool?,
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
      if (dartOptions != null) 'dartOptions': dartOptions!.toMap(),
      if (copyrightHeader != null) 'copyrightHeader': copyrightHeader!,
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

DartOptions _dartOptionsWithCopyrightHeader(
    DartOptions? dartOptions, String? copyrightHeader) {
  dartOptions = dartOptions ?? const DartOptions();
  return dartOptions.merge(DartOptions(
      copyrightHeader:
          copyrightHeader != null ? _lineReader(copyrightHeader) : null));
}

/// A [Generator] that generates Dart source code.
class DartGenerator implements Generator {
  /// Constructor for [DartGenerator].
  const DartGenerator();

  @override
  void generate(StringSink sink, PigeonOptions options, Root root) {
    final DartOptions dartOptionsWithHeader = _dartOptionsWithCopyrightHeader(
        options.dartOptions, options.copyrightHeader);
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
    final DartOptions dartOptionsWithHeader = _dartOptionsWithCopyrightHeader(
        options.dartOptions, options.copyrightHeader);
    generateTestDart(
      dartOptionsWithHeader,
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
    final ObjcOptions objcOptionsWithHeader = objcOptions.merge(ObjcOptions(
        copyrightHeader: options.copyrightHeader != null
            ? _lineReader(options.copyrightHeader!)
            : null));
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
    final ObjcOptions objcOptionsWithHeader = objcOptions.merge(ObjcOptions(
        copyrightHeader: options.copyrightHeader != null
            ? _lineReader(options.copyrightHeader!)
            : null));
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
    javaOptions = javaOptions.merge(JavaOptions(
        className: javaOptions.className ??
            path.basenameWithoutExtension(options.javaOut!),
        copyrightHeader: options.copyrightHeader != null
            ? _lineReader(options.copyrightHeader!)
            : null));
    generateJava(javaOptions, root, sink);
  }

  @override
  IOSink? shouldGenerate(PigeonOptions options) => _openSink(options.javaOut);
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
    for (final NamedType field in klass.fields) {
      if (field.type.typeArguments != null) {
        for (final TypeDeclaration typeArgument in field.type.typeArguments) {
          if (!typeArgument.isNullable) {
            result.add(Error(
              message:
                  'Generic type arguments must be nullable in field "${field.name}" in class "${klass.name}".',
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
      if (method.returnType.isNullable) {
        result.add(Error(
          message:
              'Nullable return types types aren\'t supported for Pigeon methods: "${method.returnType.baseName}" in API: "${api.name}" method: "${method.name}"',
          lineNumber: _calculateLineNumberNullable(source, method.offset),
        ));
      }
      if (method.arguments.isNotEmpty &&
          method.arguments.any((NamedType element) =>
              customEnums.contains(element.type.baseName))) {
        result.add(Error(
          message:
              'Enums aren\'t yet supported for primitive arguments: "${method.arguments[0]}" in API: "${api.name}" method: "${method.name}" (https://github.com/flutter/flutter/issues/87307)',
          lineNumber: _calculateLineNumberNullable(source, method.offset),
        ));
      }
      if (customEnums.contains(method.returnType.baseName)) {
        result.add(Error(
          message:
              'Enums aren\'t yet supported for primitive return types: "${method.returnType}" in API: "${api.name}" method: "${method.name}" (https://github.com/flutter/flutter/issues/87307)',
        ));
      }
      if (method.arguments.isNotEmpty &&
          method.arguments
              .any((NamedType element) => element.type.isNullable)) {
        result.add(Error(
          message:
              'Nullable argument types aren\'t supported for Pigeon in API: "${api.name}" method: "${method.name}"',
          lineNumber: _calculateLineNumberNullable(source, method.offset),
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
    referencedEnums.removeWhere(
        (final Enum anEnum) => !referencedTypeNames.contains(anEnum.name));

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
            'Unsupported import ${node.uri}, only imports of \'package:pigeon/pigeon.dart\' are supported.',
        lineNumber: _calculateLineNumber(source, node.offset),
      ));
    }
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
      _currentClass = Class(name: node.name.name, fields: <NamedType>[]);
    }

    node.visitChildren(this);
    return null;
  }

  NamedType formalParameterToField(dart_ast.FormalParameter parameter) {
    final dart_ast.TypeName? typeName =
        getFirstChildOfType<dart_ast.TypeName>(parameter);
    if (typeName != null) {
      final String argTypeBaseName = typeName.name.name;
      final bool isNullable = typeName.question != null;
      final List<TypeDeclaration> argTypeArguments =
          typeAnnotationsToTypeArguments(typeName.typeArguments);
      return NamedType(
          type: TypeDeclaration(
              baseName: argTypeBaseName,
              isNullable: isNullable,
              typeArguments: argTypeArguments),
          name: parameter.identifier?.name ?? '',
          offset: parameter.offset);
    } else {
      return NamedType(
        name: '',
        type: TypeDeclaration(baseName: '', isNullable: false),
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
    if (_currentApi != null) {
      // Methods without named return types aren't supported.
      final dart_ast.TypeAnnotation returnType = node.returnType!;
      final dart_ast.SimpleIdentifier returnTypeIdentifier =
          getFirstChildOfType<dart_ast.SimpleIdentifier>(returnType)!;
      _currentApi!.methods.add(Method(
          name: node.name.name,
          returnType: TypeDeclaration(
              baseName: returnTypeIdentifier.name,
              typeArguments: typeAnnotationsToTypeArguments(
                  (returnType as dart_ast.NamedType).typeArguments),
              isNullable: returnType.question != null),
          arguments: arguments,
          isAsynchronous: isAsynchronous,
          objcSelector: objcSelector,
          offset: node.offset));
    } else if (_currentClass != null) {
      _errors.add(Error(
          message:
              'Methods aren\'t supported in Pigeon data classes ("${node.name.name}").',
          lineNumber: _calculateLineNumber(source, node.offset)));
    }
    node.visitChildren(this);
    return null;
  }

  @override
  Object? visitEnumDeclaration(dart_ast.EnumDeclaration node) {
    _enums.add(Enum(
        name: node.name.name,
        members: node.constants
            .map((dart_ast.EnumConstantDeclaration e) => e.name.name)
            .toList()));
    node.visitChildren(this);
    return null;
  }

  List<TypeDeclaration> typeAnnotationsToTypeArguments(
      dart_ast.TypeArgumentList? typeArguments) {
    final List<TypeDeclaration> result = <TypeDeclaration>[];
    if (typeArguments != null) {
      for (final Object x in typeArguments.childEntities) {
        if (x is dart_ast.TypeName) {
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
                'Pigeon doesn\'t support static fields ("${node.toString()}"), consider using enums.',
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
                  typeArguments: typeAnnotationsToTypeArguments(typeArguments)),
              name: node.fields.variables[0].name.name,
              offset: node.offset));
        }
      } else {
        _errors.add(Error(
            message: 'Expected a named type but found "${node.toString()}".',
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
    final String type = _currentApi != null ? 'API classes' : 'data classes';
    _errors.add(Error(
        message: 'Constructors aren\'t supported in $type ("$node").',
        lineNumber: _calculateLineNumber(source, node.offset)));
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
            session.getParsedUnit2(path) as ParsedUnitResult;
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
''' +
        _argParser.usage;
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
    ..addFlag('dart_null_safety',
        help: 'Makes generated Dart code have null safety annotations',
        defaultsTo: true)
    ..addOption('objc_header_out',
        help: 'Path to generated Objective-C header file (.h).')
    ..addOption('objc_prefix',
        help: 'Prefix for generated Objective-C classes and protocols.')
    ..addOption('copyright_header',
        help:
            'Path to file with copyright header to be prepended to generated code.')
    ..addFlag('one_language',
        help: 'Allow Pigeon to only generate code for one language.',
        defaultsTo: false);

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
      oneLanguage: results['one_language'],
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
  /// customize the generators that pigeon will use. The optional parameter
  /// [sdkPath] allows you to specify the Dart SDK path.
  static Future<int> run(List<String> args,
      {List<Generator>? generators, String? sdkPath}) async {
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

    if (options.input == null) {
      print(usage);
      return 0;
    }

    final ParseResults parseResults =
        pigeon.parseFile(options.input!, sdkPath: sdkPath);
    if (parseResults.pigeonOptions != null) {
      options = PigeonOptions.fromMap(
          mergeMaps(options.toMap(), parseResults.pigeonOptions!));
    }

    if (options.oneLanguage == false && options.dartOut == null) {
      print(usage);
      return 1;
    }

    final List<Error> errors = <Error>[];
    if (options.objcHeaderOut != null) {
      options = options.merge(PigeonOptions(
          objcOptions: options.objcOptions!.merge(
              ObjcOptions(header: path.basename(options.objcHeaderOut!)))));
    }

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
