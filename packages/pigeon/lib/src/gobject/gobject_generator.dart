// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:path/path.dart' as path;

import '../ast.dart';
import '../generator.dart';
import '../generator_tools.dart';

/// Documentation comment spec.
const DocumentCommentSpecification _docCommentSpec =
    DocumentCommentSpecification(
      '/**',
      closeCommentToken: ' */',
      blockContinuationToken: ' *',
    );

/// Name for codec class.
const String _codecBaseName = 'MessageCodec';

/// Name of the standard codec from the Flutter SDK.
const String _standardCodecName = 'FlStandardMessageCodec';

/// Options that control how GObject code will be generated.
class GObjectOptions {
  /// Creates a [GObjectOptions] object
  const GObjectOptions({
    this.headerIncludePath,
    this.module,
    this.copyrightHeader,
    this.headerOutPath,
  });

  /// The path to the header that will get placed in the source file (example:
  /// "foo.h").
  final String? headerIncludePath;

  /// The module where the generated class will live.
  final String? module;

  /// A copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// The path to the output header file location.
  final String? headerOutPath;

  /// Creates a [GObjectOptions] from a Map representation where:
  /// `x = GObjectOptions.fromMap(x.toMap())`.
  static GObjectOptions fromMap(Map<String, Object> map) {
    final Iterable<dynamic>? copyrightHeader =
        map['copyrightHeader'] as Iterable<dynamic>?;
    return GObjectOptions(
      headerIncludePath: map['header'] as String?,
      module: map['module'] as String?,
      copyrightHeader: copyrightHeader?.cast<String>(),
      headerOutPath: map['gobjectHeaderOut'] as String?,
    );
  }

  /// Converts a [GObjectOptions] to a Map representation where:
  /// `x = GObjectOptions.fromMap(x.toMap())`.
  Map<String, Object> toMap() {
    final Map<String, Object> result = <String, Object>{
      if (headerIncludePath != null) 'header': headerIncludePath!,
      if (module != null) 'module': module!,
      if (copyrightHeader != null) 'copyrightHeader': copyrightHeader!,
    };
    return result;
  }

  /// Overrides any non-null parameters from [options] into this to make a new
  /// [GObjectOptions].
  GObjectOptions merge(GObjectOptions options) {
    return GObjectOptions.fromMap(mergeMaps(toMap(), options.toMap()));
  }
}

/// Options that control how GObject code will be generated.
class InternalGObjectOptions extends InternalOptions {
  /// Creates a [InternalGObjectOptions] object
  const InternalGObjectOptions({
    required this.headerIncludePath,
    required this.gobjectHeaderOut,
    required this.gobjectSourceOut,
    this.module,
    this.copyrightHeader,
    this.headerOutPath,
  });

  /// Creates InternalGObjectOptions from GObjectOptions.
  InternalGObjectOptions.fromGObjectOptions(
    GObjectOptions options, {
    required this.gobjectHeaderOut,
    required this.gobjectSourceOut,
    Iterable<String>? copyrightHeader,
  }) : headerIncludePath =
           options.headerIncludePath ?? path.basename(gobjectHeaderOut),
       module = options.module,
       copyrightHeader = options.copyrightHeader ?? copyrightHeader,
       headerOutPath = options.headerOutPath;

  /// The path to the header that will get placed in the source file (example:
  /// "foo.h").
  final String headerIncludePath;

  /// Path to the ".h" GObject file that will be generated.
  final String gobjectHeaderOut;

  /// Path to the ".cc" GObject file that will be generated.
  final String gobjectSourceOut;

  /// The module where the generated class will live.
  final String? module;

  /// A copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// The path to the output header file location.
  final String? headerOutPath;
}

/// Class that manages all GObject code generation.
class GObjectGenerator
    extends Generator<OutputFileOptions<InternalGObjectOptions>> {
  /// Constructor.
  const GObjectGenerator();

  /// Generates GObject file of type specified in [generatorOptions]
  @override
  void generate(
    OutputFileOptions<InternalGObjectOptions> generatorOptions,
    Root root,
    StringSink sink, {
    required String dartPackageName,
  }) {
    assert(
      generatorOptions.fileType == FileType.header ||
          generatorOptions.fileType == FileType.source,
    );
    if (generatorOptions.fileType == FileType.header) {
      const GObjectHeaderGenerator().generate(
        generatorOptions.languageOptions,
        root,
        sink,
        dartPackageName: dartPackageName,
      );
    } else if (generatorOptions.fileType == FileType.source) {
      const GObjectSourceGenerator().generate(
        generatorOptions.languageOptions,
        root,
        sink,
        dartPackageName: dartPackageName,
      );
    }
  }
}

/// Writes GObject header (.h) file to sink.
class GObjectHeaderGenerator
    extends StructuredGenerator<InternalGObjectOptions> {
  /// Constructor.
  const GObjectHeaderGenerator();

  @override
  void writeFilePrologue(
    InternalGObjectOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (generatorOptions.copyrightHeader != null) {
      addLines(indent, generatorOptions.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('// ${getGeneratedCodeWarning()}');
    indent.writeln('// $seeAlsoWarning');
  }

  @override
  void writeFileImports(
    InternalGObjectOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.newln();
    final String guardName = _getGuardName(generatorOptions.headerIncludePath);
    indent.writeln('#ifndef $guardName');
    indent.writeln('#define $guardName');

    indent.newln();
    indent.writeln('#include <flutter_linux/flutter_linux.h>');
  }

  @override
  void writeOpenNamespace(
    InternalGObjectOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.newln();
    indent.writeln('G_BEGIN_DECLS');
  }

  @override
  void writeEnum(
    InternalGObjectOptions generatorOptions,
    Root root,
    Indent indent,
    Enum anEnum, {
    required String dartPackageName,
  }) {
    final String module = _getModule(generatorOptions, dartPackageName);
    final String enumName = _getClassName(module, anEnum.name);

    indent.newln();
    final List<String> enumValueCommentLines = <String>[];
    for (int i = 0; i < anEnum.members.length; i++) {
      final EnumMember member = anEnum.members[i];
      final String itemName = _getEnumValue(
        dartPackageName,
        anEnum.name,
        member.name,
      );
      enumValueCommentLines.add('$itemName:');
      enumValueCommentLines.addAll(member.documentationComments);
    }
    addDocumentationComments(indent, <String>[
      '$enumName:',
      ...enumValueCommentLines,
      '',
      ...anEnum.documentationComments,
    ], _docCommentSpec);
    indent.writeScoped('typedef enum {', '} $enumName;', () {
      for (int i = 0; i < anEnum.members.length; i++) {
        final EnumMember member = anEnum.members[i];
        final String itemName = _getEnumValue(
          dartPackageName,
          anEnum.name,
          member.name,
        );
        indent.writeln(
          '$itemName = $i${i == anEnum.members.length - 1 ? '' : ','}',
        );
      }
    });
  }

  @override
  void writeDataClass(
    InternalGObjectOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    final String module = _getModule(generatorOptions, dartPackageName);
    final String className = _getClassName(module, classDefinition.name);
    final String methodPrefix = _getMethodPrefix(module, classDefinition.name);

    indent.newln();
    addDocumentationComments(indent, <String>[
      '$className:',
      '',
      ...classDefinition.documentationComments,
    ], _docCommentSpec);

    indent.newln();
    _writeDeclareFinalType(indent, module, classDefinition.name);

    indent.newln();
    final List<String> constructorArgs = <String>[];
    for (final NamedType field in classDefinition.fields) {
      final String fieldName = _getFieldName(field.name);
      final String type = _getType(module, field.type);
      constructorArgs.add('$type $fieldName');
      if (_isNumericListType(field.type)) {
        constructorArgs.add('size_t ${fieldName}_length');
      }
    }
    final List<String> constructorFieldCommentLines = <String>[];
    for (final NamedType field in classDefinition.fields) {
      final String fieldName = _getFieldName(field.name);
      constructorFieldCommentLines.add('$fieldName: field in this object.');
      if (_isNumericListType(field.type)) {
        constructorFieldCommentLines.add(
          '${fieldName}_length: length of @$fieldName.',
        );
      }
    }
    addDocumentationComments(indent, <String>[
      '${methodPrefix}_new:',
      ...constructorFieldCommentLines,
      '',
      'Creates a new #${classDefinition.name} object.',
      '',
      'Returns: a new #$className',
    ], _docCommentSpec);

    indent.writeln(
      "$className* ${methodPrefix}_new(${constructorArgs.join(', ')});",
    );

    for (final NamedType field in classDefinition.fields) {
      final String fieldName = _getFieldName(field.name);
      final String returnType = _getType(module, field.type);

      indent.newln();
      addDocumentationComments(indent, <String>[
        '${methodPrefix}_get_$fieldName',
        '@object: a #$className.',
        if (_isNumericListType(field.type))
          '@length: location to write the length of this value.',
        '',
        if (field.documentationComments.isNotEmpty)
          ...field.documentationComments
        else
          'Gets the value of the ${field.name} field of @object.',
        '',
        'Returns: the field value.',
      ], _docCommentSpec);
      final List<String> getterArgs = <String>[
        '$className* object',
        if (_isNumericListType(field.type)) 'size_t* length',
      ];
      indent.writeln(
        '$returnType ${methodPrefix}_get_$fieldName(${getterArgs.join(', ')});',
      );
    }
  }

  @override
  void writeGeneralCodec(
    InternalGObjectOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    final String module = _getModule(generatorOptions, dartPackageName);
    indent.newln();
    _writeDeclareFinalType(
      indent,
      module,
      _codecBaseName,
      parentClassName: _standardCodecName,
    );

    final Iterable<EnumeratedType> customTypes = getEnumeratedTypes(
      root,
      excludeSealedClasses: true,
    );

    if (customTypes.isNotEmpty) {
      indent.newln();
      addDocumentationComments(indent, <String>[
        'Custom type ID constants:',
        '',
        'Constants used to identify custom types in the codec.',
        'They are used in the codec to encode and decode custom types.',
        'They may be used in custom object creation functions to identify the type.',
      ], _docCommentSpec);
    }

    for (final EnumeratedType customType in customTypes) {
      final String customTypeId = _getCustomTypeId(module, customType);
      indent.writeln('extern const int $customTypeId;');
    }
  }

  @override
  void writeFlutterApi(
    InternalGObjectOptions generatorOptions,
    Root root,
    Indent indent,
    Api api, {
    required String dartPackageName,
  }) {
    final String module = _getModule(generatorOptions, dartPackageName);
    final String className = _getClassName(module, api.name);

    for (final Method method in api.methods) {
      _writeFlutterApiRespondClass(indent, module, api, method);
    }

    final String methodPrefix = _getMethodPrefix(module, api.name);
    indent.newln();
    addDocumentationComments(indent, <String>[
      '$className:',
      '',
      ...api.documentationComments,
    ], _docCommentSpec);

    indent.newln();
    _writeDeclareFinalType(indent, module, api.name);

    indent.newln();
    addDocumentationComments(indent, <String>[
      '${methodPrefix}_new:',
      '@messenger: an #FlBinaryMessenger.',
      '@suffix: (allow-none): a suffix to add to the API or %NULL for none.',
      '',
      'Creates a new object to access the ${api.name} API.',
      '',
      'Returns: a new #$className',
    ], _docCommentSpec);
    indent.writeln(
      '$className* ${methodPrefix}_new(FlBinaryMessenger* messenger, const gchar* suffix);',
    );

    for (final Method method in api.methods) {
      final String methodName = _getMethodName(method.name);
      final String responseName = _getResponseName(api.name, method.name);
      final String responseClassName = _getClassName(module, responseName);

      final List<String> asyncArgs = <String>['$className* api'];
      for (final Parameter param in method.parameters) {
        final String paramName = _snakeCaseFromCamelCase(param.name);
        asyncArgs.add('${_getType(module, param.type)} $paramName');
        if (_isNumericListType(param.type)) {
          asyncArgs.add('size_t ${paramName}_length');
        }
      }
      asyncArgs.addAll(<String>[
        'GCancellable* cancellable',
        'GAsyncReadyCallback callback',
        'gpointer user_data',
      ]);
      indent.newln();
      final List<String> methodParameterCommentLines = <String>[];
      for (final Parameter param in method.parameters) {
        final String paramName = _snakeCaseFromCamelCase(param.name);
        methodParameterCommentLines.add(
          '@$paramName: ${param.type.isNullable ? '(allow-none): ' : ''}parameter for this method.',
        );
        if (_isNumericListType(param.type)) {
          methodParameterCommentLines.add(
            '@${paramName}_length: length of $paramName.',
          );
        }
      }
      addDocumentationComments(indent, <String>[
        '${methodPrefix}_$methodName:',
        '@api: a #$className.',
        ...methodParameterCommentLines,
        '@cancellable: (allow-none): a #GCancellable or %NULL.',
        '@callback: (scope async): (allow-none): a #GAsyncReadyCallback to call when the call is complete or %NULL to ignore the response.',
        '@user_data: (closure): user data to pass to @callback.',
        '',
        ...method.documentationComments,
      ], _docCommentSpec);
      indent.writeln(
        "void ${methodPrefix}_$methodName(${asyncArgs.join(', ')});",
      );

      final List<String> finishArgs = <String>[
        '$className* api',
        'GAsyncResult* result',
        'GError** error',
      ];
      indent.newln();
      addDocumentationComments(indent, <String>[
        '${methodPrefix}_${methodName}_finish:',
        '@api: a #$className.',
        '@result: a #GAsyncResult.',
        '@error: (allow-none): #GError location to store the error occurring, or %NULL to ignore.',
        '',
        'Completes a ${methodPrefix}_$methodName() call.',
        '',
        'Returns: a #$responseClassName or %NULL on error.',
      ], _docCommentSpec);
      indent.writeln(
        "$responseClassName* ${methodPrefix}_${methodName}_finish(${finishArgs.join(', ')});",
      );
    }
  }

  // Write the API response classes.
  void _writeFlutterApiRespondClass(
    Indent indent,
    String module,
    Api api,
    Method method,
  ) {
    final String responseName = _getResponseName(api.name, method.name);
    final String responseClassName = _getClassName(module, responseName);
    final String responseMethodPrefix = _getMethodPrefix(module, responseName);
    final String primitiveType = _getType(
      module,
      method.returnType,
      primitive: true,
    );

    indent.newln();
    _writeDeclareFinalType(indent, module, responseName);

    indent.newln();
    addDocumentationComments(indent, <String>[
      '${responseMethodPrefix}_is_error:',
      '@response: a #$responseClassName.',
      '',
      'Checks if a response to ${api.name}.${method.name} is an error.',
      '',
      'Returns: a %TRUE if this response is an error.',
    ], _docCommentSpec);
    indent.writeln(
      'gboolean ${responseMethodPrefix}_is_error($responseClassName* response);',
    );

    indent.newln();
    addDocumentationComments(indent, <String>[
      '${responseMethodPrefix}_get_error_code:',
      '@response: a #$responseClassName.',
      '',
      'Get the error code for this response.',
      '',
      'Returns: an error code or %NULL if not an error.',
    ], _docCommentSpec);
    indent.writeln(
      'const gchar* ${responseMethodPrefix}_get_error_code($responseClassName* response);',
    );

    indent.newln();
    addDocumentationComments(indent, <String>[
      '${responseMethodPrefix}_get_error_message:',
      '@response: a #$responseClassName.',
      '',
      'Get the error message for this response.',
      '',
      'Returns: an error message.',
    ], _docCommentSpec);
    indent.writeln(
      'const gchar* ${responseMethodPrefix}_get_error_message($responseClassName* response);',
    );

    indent.newln();
    addDocumentationComments(indent, <String>[
      '${responseMethodPrefix}_get_error_details:',
      '@response: a #$responseClassName.',
      '',
      'Get the error details for this response.',
      '',
      'Returns: (allow-none): an error details or %NULL.',
    ], _docCommentSpec);
    indent.writeln(
      'FlValue* ${responseMethodPrefix}_get_error_details($responseClassName* response);',
    );

    if (!method.returnType.isVoid) {
      indent.newln();
      addDocumentationComments(indent, <String>[
        '${responseMethodPrefix}_get_return_value:',
        '@response: a #$responseClassName.',
        if (_isNumericListType(method.returnType))
          '@return_value_length: (allow-none): location to write length of the return value or %NULL to ignore.',
        '',
        'Get the return value for this response.',
        '',
        if (method.returnType.isNullable)
          'Returns: (allow-none): a return value or %NULL.'
        else
          'Returns: a return value.',
      ], _docCommentSpec);
      final String returnType =
          _isNullablePrimitiveType(method.returnType)
              ? '$primitiveType*'
              : primitiveType;
      indent.writeln(
        '$returnType ${responseMethodPrefix}_get_return_value($responseClassName* response${_isNumericListType(method.returnType) ? ', size_t* return_value_length' : ''});',
      );
    }
  }

  @override
  void writeHostApi(
    InternalGObjectOptions generatorOptions,
    Root root,
    Indent indent,
    Api api, {
    required String dartPackageName,
  }) {
    final String module = _getModule(generatorOptions, dartPackageName);
    final String methodPrefix = _getMethodPrefix(module, api.name);
    final String vtableName = _getVTableName(module, api.name);

    indent.newln();
    _writeDeclareFinalType(indent, module, api.name);

    final bool hasAsyncMethod = api.methods.any(
      (Method method) => method.isAsynchronous,
    );
    if (hasAsyncMethod) {
      indent.newln();
      _writeDeclareFinalType(indent, module, '${api.name}ResponseHandle');
    }

    for (final Method method in api.methods.where(
      (Method method) => !method.isAsynchronous,
    )) {
      _writeHostApiRespondClass(indent, module, api, method);
    }

    indent.newln();
    _writeApiVTable(indent, module, api);

    indent.newln();
    addDocumentationComments(indent, <String>[
      '${methodPrefix}_set_method_handlers:',
      '',
      '@messenger: an #FlBinaryMessenger.',
      '@suffix: (allow-none): a suffix to add to the API or %NULL for none.',
      '@vtable: implementations of the methods in this API.',
      '@user_data: (closure): user data to pass to the functions in @vtable.',
      '@user_data_free_func: (allow-none): a function which gets called to free @user_data, or %NULL.',
      '',
      'Connects the method handlers in the ${api.name} API.',
    ], _docCommentSpec);
    indent.writeln(
      'void ${methodPrefix}_set_method_handlers(FlBinaryMessenger* messenger, const gchar* suffix, const $vtableName* vtable, gpointer user_data, GDestroyNotify user_data_free_func);',
    );

    indent.newln();
    addDocumentationComments(indent, <String>[
      '${methodPrefix}_clear_method_handlers:',
      '',
      '@messenger: an #FlBinaryMessenger.',
      '@suffix: (allow-none): a suffix to add to the API or %NULL for none.',
      '',
      'Clears the method handlers in the ${api.name} API.',
    ], _docCommentSpec);
    indent.writeln(
      'void ${methodPrefix}_clear_method_handlers(FlBinaryMessenger* messenger, const gchar* suffix);',
    );

    for (final Method method in api.methods.where(
      (Method method) => method.isAsynchronous,
    )) {
      _writeHostApiRespondFunctionPrototype(indent, module, api, method);
    }
  }

  // Write the API response classes.
  void _writeHostApiRespondClass(
    Indent indent,
    String module,
    Api api,
    Method method,
  ) {
    final String responseName = _getResponseName(api.name, method.name);
    final String responseClassName = _getClassName(module, responseName);
    final String responseMethodPrefix = _getMethodPrefix(module, responseName);

    indent.newln();
    _writeDeclareFinalType(indent, module, responseName);

    final String returnType = _getType(module, method.returnType);
    indent.newln();
    final List<String> constructorArgs = <String>[
      if (returnType != 'void') '$returnType return_value',
      if (_isNumericListType(method.returnType)) 'size_t return_value_length',
    ];
    addDocumentationComments(indent, <String>[
      '${responseMethodPrefix}_new:',
      '',
      'Creates a new response to ${api.name}.${method.name}.',
      '',
      'Returns: a new #$responseClassName',
    ], _docCommentSpec);
    indent.writeln(
      '$responseClassName* ${responseMethodPrefix}_new(${constructorArgs.join(', ')});',
    );

    indent.newln();
    addDocumentationComments(indent, <String>[
      '${responseMethodPrefix}_new_error:',
      '@code: error code.',
      '@message: error message.',
      '@details: (allow-none): error details or %NULL.',
      '',
      'Creates a new error response to ${api.name}.${method.name}.',
      '',
      'Returns: a new #$responseClassName',
    ], _docCommentSpec);
    indent.writeln(
      '$responseClassName* ${responseMethodPrefix}_new_error(const gchar* code, const gchar* message, FlValue* details);',
    );
  }

  // Write the vtable for an API.
  void _writeApiVTable(Indent indent, String module, Api api) {
    final String className = _getClassName(module, api.name);
    final String vtableName = _getVTableName(module, api.name);

    addDocumentationComments(indent, <String>[
      '$vtableName:',
      '',
      'Table of functions exposed by ${api.name} to be implemented by the API provider.',
    ], _docCommentSpec);
    indent.writeScoped('typedef struct {', '} $vtableName;', () {
      for (final Method method in api.methods) {
        final String methodName = _getMethodName(method.name);
        final String responseName = _getResponseName(api.name, method.name);
        final String responseClassName = _getClassName(module, responseName);

        final List<String> methodArgs = <String>[];
        for (final Parameter param in method.parameters) {
          final String name = _snakeCaseFromCamelCase(param.name);
          methodArgs.add('${_getType(module, param.type)} $name');
          if (_isNumericListType(param.type)) {
            methodArgs.add('size_t ${name}_length');
          }
        }
        methodArgs.addAll(<String>[
          if (method.isAsynchronous)
            '${className}ResponseHandle* response_handle',
          'gpointer user_data',
        ]);
        final String returnType =
            method.isAsynchronous ? 'void' : '$responseClassName*';
        indent.writeln("$returnType (*$methodName)(${methodArgs.join(', ')});");
      }
    });
  }

  // Write the function prototype for an API method response.
  void _writeHostApiRespondFunctionPrototype(
    Indent indent,
    String module,
    Api api,
    Method method,
  ) {
    final String className = _getClassName(module, api.name);
    final String methodPrefix = _getMethodPrefix(module, api.name);
    final String methodName = _getMethodName(method.name);
    final String returnType = _getType(module, method.returnType);

    indent.newln();
    final List<String> respondArgs = <String>[
      '${className}ResponseHandle* response_handle',
      if (returnType != 'void') '$returnType return_value',
      if (_isNumericListType(method.returnType)) 'size_t return_value_length',
    ];
    addDocumentationComments(indent, <String>[
      '${methodPrefix}_respond_$methodName:',
      '@response_handle: a #${className}ResponseHandle.',
      if (returnType != 'void')
        '@return_value: location to write the value returned by this method.',
      if (_isNumericListType(method.returnType))
        '@return_value_length: (allow-none): location to write length of @return_value or %NULL to ignore.',
      '',
      'Responds to ${api.name}.${method.name}. ',
    ], _docCommentSpec);
    indent.writeln(
      "void ${methodPrefix}_respond_$methodName(${respondArgs.join(', ')});",
    );

    indent.newln();
    final List<String> respondErrorArgs = <String>[
      '${className}ResponseHandle* response_handle',
      'const gchar* code',
      'const gchar* message',
      'FlValue* details',
    ];
    addDocumentationComments(indent, <String>[
      '${methodPrefix}_respond_error_$methodName:',
      '@response_handle: a #${className}ResponseHandle.',
      '@code: error code.',
      '@message: error message.',
      '@details: (allow-none): error details or %NULL.',
      '',
      'Responds with an error to ${api.name}.${method.name}. ',
    ], _docCommentSpec);
    indent.writeln(
      "void ${methodPrefix}_respond_error_$methodName(${respondErrorArgs.join(', ')});",
    );
  }

  @override
  void writeCloseNamespace(
    InternalGObjectOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.newln();
    indent.writeln('G_END_DECLS');

    indent.newln();
    final String guardName = _getGuardName(generatorOptions.headerIncludePath);
    indent.writeln('#endif  // $guardName');
  }
}

/// Writes GObject source (.cc) file to sink.
class GObjectSourceGenerator
    extends StructuredGenerator<InternalGObjectOptions> {
  /// Constructor.
  const GObjectSourceGenerator();

  @override
  void writeFilePrologue(
    InternalGObjectOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (generatorOptions.copyrightHeader != null) {
      addLines(indent, generatorOptions.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('// ${getGeneratedCodeWarning()}');
    indent.writeln('// $seeAlsoWarning');
  }

  @override
  void writeFileImports(
    InternalGObjectOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.newln();
    indent.writeln('#include "${generatorOptions.headerIncludePath}"');
  }

  @override
  void writeDataClass(
    InternalGObjectOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    final String module = _getModule(generatorOptions, dartPackageName);
    final String snakeModule = _snakeCaseFromCamelCase(module);
    final String className = _getClassName(module, classDefinition.name);
    final String snakeClassName = _snakeCaseFromCamelCase(classDefinition.name);

    final String methodPrefix = _getMethodPrefix(module, classDefinition.name);
    final String testMacro = '${snakeModule}_IS_$snakeClassName'.toUpperCase();

    indent.newln();
    _writeObjectStruct(indent, module, classDefinition.name, () {
      for (final NamedType field in classDefinition.fields) {
        final String fieldName = _getFieldName(field.name);
        final String fieldType = _getType(module, field.type, isOutput: true);
        indent.writeln('$fieldType $fieldName;');
        if (_isNumericListType(field.type)) {
          indent.writeln('size_t ${fieldName}_length;');
        }
      }
    });

    indent.newln();
    _writeDefineType(indent, module, classDefinition.name);

    indent.newln();
    _writeDispose(indent, module, classDefinition.name, () {
      bool haveSelf = false;
      for (final NamedType field in classDefinition.fields) {
        final String fieldName = _getFieldName(field.name);
        final String? clear = _getClearFunction(field.type, 'self->$fieldName');
        if (clear != null) {
          if (!haveSelf) {
            _writeCastSelf(indent, module, classDefinition.name, 'object');
            haveSelf = true;
          }
          indent.writeln('$clear;');
        }
      }
    });

    indent.newln();
    _writeInit(indent, module, classDefinition.name, () {});

    indent.newln();
    _writeClassInit(indent, module, classDefinition.name, () {});

    final List<String> constructorArgs = <String>[];
    for (final NamedType field in classDefinition.fields) {
      final String fieldName = _getFieldName(field.name);
      constructorArgs.add('${_getType(module, field.type)} $fieldName');
      if (_isNumericListType(field.type)) {
        constructorArgs.add('size_t ${fieldName}_length');
      }
    }
    indent.newln();
    indent.writeScoped(
      "$className* ${methodPrefix}_new(${constructorArgs.join(', ')}) {",
      '}',
      () {
        _writeObjectNew(indent, module, classDefinition.name);
        for (final NamedType field in classDefinition.fields) {
          final String fieldName = _getFieldName(field.name);
          final String value = _referenceValue(
            module,
            field.type,
            fieldName,
            lengthVariableName: '${fieldName}_length',
          );

          if (_isNullablePrimitiveType(field.type)) {
            final String primitiveType = _getType(
              module,
              field.type,
              primitive: true,
            );
            indent.writeScoped('if ($value != nullptr) {', '}', () {
              indent.writeln(
                'self->$fieldName = static_cast<$primitiveType*>(malloc(sizeof($primitiveType)));',
              );
              indent.writeln('*self->$fieldName = *$value;');
            });
            indent.writeScoped('else {', '}', () {
              indent.writeln('self->$fieldName = nullptr;');
            });
          } else if (field.type.isNullable) {
            indent.writeScoped('if ($fieldName != nullptr) {', '}', () {
              indent.writeln('self->$fieldName = $value;');
              if (_isNumericListType(field.type)) {
                indent.writeln(
                  'self->${fieldName}_length = ${fieldName}_length;',
                );
              }
            });
            indent.writeScoped('else {', '}', () {
              indent.writeln('self->$fieldName = nullptr;');
              if (_isNumericListType(field.type)) {
                indent.writeln('self->${fieldName}_length = 0;');
              }
            });
          } else {
            indent.writeln('self->$fieldName = $value;');
            if (_isNumericListType(field.type)) {
              indent.writeln(
                'self->${fieldName}_length = ${fieldName}_length;',
              );
            }
          }
        }
        indent.writeln('return self;');
      },
    );

    for (final NamedType field in classDefinition.fields) {
      final String fieldName = _getFieldName(field.name);
      final String returnType = _getType(module, field.type);

      indent.newln();
      final List<String> getterArgs = <String>[
        '$className* self',
        if (_isNumericListType(field.type)) 'size_t* length',
      ];
      indent.writeScoped(
        '$returnType ${methodPrefix}_get_$fieldName(${getterArgs.join(', ')}) {',
        '}',
        () {
          indent.writeln(
            'g_return_val_if_fail($testMacro(self), ${_getDefaultValue(module, field.type)});',
          );
          if (_isNumericListType(field.type)) {
            indent.writeln('*length = self->${fieldName}_length;');
          }
          indent.writeln('return self->$fieldName;');
        },
      );
    }

    indent.newln();
    indent.writeScoped(
      'static FlValue* ${methodPrefix}_to_list($className* self) {',
      '}',
      () {
        indent.writeln('FlValue* values = fl_value_new_list();');
        for (final NamedType field in classDefinition.fields) {
          final String fieldName = _getFieldName(field.name);
          indent.writeln(
            'fl_value_append_take(values, ${_makeFlValue(root, module, field.type, 'self->$fieldName', lengthVariableName: 'self->${fieldName}_length')});',
          );
        }
        indent.writeln('return values;');
      },
    );

    indent.newln();
    indent.writeScoped(
      'static $className* ${methodPrefix}_new_from_list(FlValue* values) {',
      '}',
      () {
        final List<String> args = <String>[];
        for (int i = 0; i < classDefinition.fields.length; i++) {
          final NamedType field = classDefinition.fields[i];
          final String fieldName = _getFieldName(field.name);
          final String fieldType = _getType(module, field.type);
          final String fieldValue = _fromFlValue(module, field.type, 'value$i');
          indent.writeln(
            'FlValue* value$i = fl_value_get_list_value(values, $i);',
          );
          args.add(fieldName);
          if (_isNullablePrimitiveType(field.type)) {
            indent.writeln('$fieldType $fieldName = nullptr;');
            indent.writeln(
              '${_getType(module, field.type, isOutput: true, primitive: true)} ${fieldName}_value;',
            );
            indent.writeScoped(
              'if (fl_value_get_type(value$i) != FL_VALUE_TYPE_NULL) {',
              '}',
              () {
                indent.writeln('${fieldName}_value = $fieldValue;');
                indent.writeln('$fieldName = &${fieldName}_value;');
              },
            );
          } else if (field.type.isNullable) {
            indent.writeln('$fieldType $fieldName = nullptr;');
            if (_isNumericListType(field.type)) {
              indent.writeln('size_t ${fieldName}_length = 0;');
              args.add('${fieldName}_length');
            }
            indent.writeScoped(
              'if (fl_value_get_type(value$i) != FL_VALUE_TYPE_NULL) {',
              '}',
              () {
                indent.writeln('$fieldName = $fieldValue;');
                if (_isNumericListType(field.type)) {
                  indent.writeln(
                    '${fieldName}_length = fl_value_get_length(value$i);',
                  );
                }
              },
            );
          } else {
            indent.writeln('$fieldType $fieldName = $fieldValue;');
            if (_isNumericListType(field.type)) {
              indent.writeln(
                'size_t ${fieldName}_length = fl_value_get_length(value$i);',
              );
              args.add('${fieldName}_length');
            }
          }
        }
        indent.writeln('return ${methodPrefix}_new(${args.join(', ')});');
      },
    );
  }

  @override
  void writeGeneralCodec(
    InternalGObjectOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    final String module = _getModule(generatorOptions, dartPackageName);
    final String codecClassName = _getClassName(module, _codecBaseName);
    final String codecMethodPrefix = _getMethodPrefix(module, _codecBaseName);

    final Iterable<EnumeratedType> customTypes = getEnumeratedTypes(
      root,
      excludeSealedClasses: true,
    );

    indent.newln();
    _writeObjectStruct(
      indent,
      module,
      _codecBaseName,
      () {},
      parentClassName: _standardCodecName,
    );

    indent.newln();
    _writeDefineType(
      indent,
      module,
      _codecBaseName,
      parentType: 'fl_standard_message_codec_get_type()',
    );

    indent.newln();
    for (final EnumeratedType customType in customTypes) {
      final String customTypeId = _getCustomTypeId(module, customType);
      indent.writeln('const int $customTypeId = ${customType.enumeration};');
    }

    for (final EnumeratedType customType in customTypes) {
      final String customTypeName = _getClassName(module, customType.name);
      final String snakeCustomTypeName = _snakeCaseFromCamelCase(
        customTypeName,
      );
      final String customTypeId = _getCustomTypeId(module, customType);

      indent.newln();
      final String valueType =
          customType.type == CustomTypes.customClass
              ? '$customTypeName*'
              : 'FlValue*';
      indent.writeScoped(
        'static gboolean ${codecMethodPrefix}_write_$snakeCustomTypeName($_standardCodecName* codec, GByteArray* buffer, $valueType value, GError** error) {',
        '}',
        () {
          indent.writeln('uint8_t type = $customTypeId;');
          indent.writeln(
            'g_byte_array_append(buffer, &type, sizeof(uint8_t));',
          );
          if (customType.type == CustomTypes.customClass) {
            indent.writeln(
              'g_autoptr(FlValue) values = ${snakeCustomTypeName}_to_list(value);',
            );
            indent.writeln(
              'return fl_standard_message_codec_write_value(codec, buffer, values, error);',
            );
          } else if (customType.type == CustomTypes.customEnum) {
            indent.writeln(
              'return fl_standard_message_codec_write_value(codec, buffer, value, error);',
            );
          }
        },
      );
    }

    indent.newln();
    indent.writeScoped(
      'static gboolean ${codecMethodPrefix}_write_value($_standardCodecName* codec, GByteArray* buffer, FlValue* value, GError** error) {',
      '}',
      () {
        indent.writeScoped(
          'if (fl_value_get_type(value) == FL_VALUE_TYPE_CUSTOM) {',
          '}',
          () {
            indent.writeScoped(
              'switch (fl_value_get_custom_type(value)) {',
              '}',
              () {
                for (final EnumeratedType customType in customTypes) {
                  final String customTypeId = _getCustomTypeId(
                    module,
                    customType,
                  );
                  indent.writeln('case $customTypeId:');
                  indent.nest(1, () {
                    final String customTypeName = _getClassName(
                      module,
                      customType.name,
                    );
                    final String snakeCustomTypeName = _snakeCaseFromCamelCase(
                      customTypeName,
                    );
                    final String castMacro = _getClassCastMacro(
                      module,
                      customType.name,
                    );
                    if (customType.type == CustomTypes.customClass) {
                      indent.writeln(
                        'return ${codecMethodPrefix}_write_$snakeCustomTypeName(codec, buffer, $castMacro(fl_value_get_custom_value_object(value)), error);',
                      );
                    } else if (customType.type == CustomTypes.customEnum) {
                      indent.writeln(
                        'return ${codecMethodPrefix}_write_$snakeCustomTypeName(codec, buffer, reinterpret_cast<FlValue*>(const_cast<gpointer>(fl_value_get_custom_value(value))), error);',
                      );
                    }
                  });
                }
              },
            );
          },
        );

        indent.newln();
        indent.writeln(
          'return FL_STANDARD_MESSAGE_CODEC_CLASS(${codecMethodPrefix}_parent_class)->write_value(codec, buffer, value, error);',
        );
      },
    );

    for (final EnumeratedType customType in customTypes) {
      final String customTypeName = _getClassName(module, customType.name);
      final String snakeCustomTypeName = _snakeCaseFromCamelCase(
        customTypeName,
      );
      final String customTypeId = _getCustomTypeId(module, customType);
      indent.newln();
      indent.writeScoped(
        'static FlValue* ${codecMethodPrefix}_read_$snakeCustomTypeName($_standardCodecName* codec, GBytes* buffer, size_t* offset, GError** error) {',
        '}',
        () {
          if (customType.type == CustomTypes.customClass) {
            indent.writeln(
              'g_autoptr(FlValue) values = fl_standard_message_codec_read_value(codec, buffer, offset, error);',
            );
            indent.writeScoped('if (values == nullptr) {', '}', () {
              indent.writeln('return nullptr;');
            });
            indent.newln();
            indent.writeln(
              'g_autoptr($customTypeName) value = ${snakeCustomTypeName}_new_from_list(values);',
            );
            indent.writeScoped('if (value == nullptr) {', '}', () {
              indent.writeln(
                'g_set_error(error, FL_MESSAGE_CODEC_ERROR, FL_MESSAGE_CODEC_ERROR_FAILED, "Invalid data received for MessageData");',
              );
              indent.writeln('return nullptr;');
            });
            indent.newln();
            indent.writeln(
              'return fl_value_new_custom_object($customTypeId, G_OBJECT(value));',
            );
          } else if (customType.type == CustomTypes.customEnum) {
            indent.writeln(
              'return fl_value_new_custom($customTypeId, fl_standard_message_codec_read_value(codec, buffer, offset, error), (GDestroyNotify)fl_value_unref);',
            );
          }
        },
      );
    }

    indent.newln();
    indent.writeScoped(
      'static FlValue* ${codecMethodPrefix}_read_value_of_type($_standardCodecName* codec, GBytes* buffer, size_t* offset, int type, GError** error) {',
      '}',
      () {
        indent.writeScoped('switch (type) {', '}', () {
          for (final EnumeratedType customType in customTypes) {
            final String customTypeName = _getClassName(
              module,
              customType.name,
            );
            final String customTypeId = _getCustomTypeId(module, customType);
            final String snakeCustomTypeName = _snakeCaseFromCamelCase(
              customTypeName,
            );
            indent.writeln('case $customTypeId:');
            indent.nest(1, () {
              indent.writeln(
                'return ${codecMethodPrefix}_read_$snakeCustomTypeName(codec, buffer, offset, error);',
              );
            });
          }

          indent.writeln('default:');
          indent.nest(1, () {
            indent.writeln(
              'return FL_STANDARD_MESSAGE_CODEC_CLASS(${codecMethodPrefix}_parent_class)->read_value_of_type(codec, buffer, offset, type, error);',
            );
          });
        });
      },
    );

    indent.newln();
    _writeInit(indent, module, _codecBaseName, () {});

    indent.newln();
    _writeClassInit(indent, module, _codecBaseName, () {
      indent.writeln(
        'FL_STANDARD_MESSAGE_CODEC_CLASS(klass)->write_value = ${codecMethodPrefix}_write_value;',
      );
      indent.writeln(
        'FL_STANDARD_MESSAGE_CODEC_CLASS(klass)->read_value_of_type = ${codecMethodPrefix}_read_value_of_type;',
      );
    }, hasDispose: false);

    indent.newln();
    indent.writeScoped(
      'static $codecClassName* ${codecMethodPrefix}_new() {',
      '}',
      () {
        _writeObjectNew(indent, module, _codecBaseName);
        indent.writeln('return self;');
      },
    );
  }

  @override
  void writeFlutterApi(
    InternalGObjectOptions generatorOptions,
    Root root,
    Indent indent,
    Api api, {
    required String dartPackageName,
  }) {
    final String module = _getModule(generatorOptions, dartPackageName);
    final String className = _getClassName(module, api.name);
    final String methodPrefix = _getMethodPrefix(module, api.name);
    final String codecClassName = _getClassName(module, _codecBaseName);
    final String codecMethodPrefix = _getMethodPrefix(module, _codecBaseName);

    indent.newln();
    _writeObjectStruct(indent, module, api.name, () {
      indent.writeln('FlBinaryMessenger* messenger;');
      indent.writeln('gchar *suffix;');
    });

    indent.newln();
    _writeDefineType(indent, module, api.name);

    indent.newln();
    _writeDispose(indent, module, api.name, () {
      _writeCastSelf(indent, module, api.name, 'object');
      indent.writeln('g_clear_object(&self->messenger);');
      indent.writeln('g_clear_pointer(&self->suffix, g_free);');
    });

    indent.newln();
    _writeInit(indent, module, api.name, () {});

    indent.newln();
    _writeClassInit(indent, module, api.name, () {});

    indent.newln();
    indent.writeScoped(
      '$className* ${methodPrefix}_new(FlBinaryMessenger* messenger, const gchar* suffix) {',
      '}',
      () {
        _writeObjectNew(indent, module, api.name);
        indent.writeln(
          'self->messenger = FL_BINARY_MESSENGER(g_object_ref(messenger));',
        );
        indent.writeln(
          'self->suffix = suffix != nullptr ? g_strdup_printf(".%s", suffix) : g_strdup("");',
        );
        indent.writeln('return self;');
      },
    );

    for (final Method method in api.methods) {
      final String methodName = _getMethodName(method.name);
      final String responseName = _getResponseName(api.name, method.name);
      final String responseClassName = _getClassName(module, responseName);
      final String responseMethodPrefix = _getMethodPrefix(
        module,
        responseName,
      );
      final String testResponseMacro =
          '${_snakeCaseFromCamelCase(module)}_IS_${_snakeCaseFromCamelCase(responseName)}'
              .toUpperCase();

      indent.newln();
      _writeObjectStruct(indent, module, responseName, () {
        indent.writeln('FlValue* error;');
        if (!method.returnType.isVoid) {
          indent.writeln('FlValue* return_value;');
          if (_isNullablePrimitiveType(method.returnType)) {
            final String primitiveType = _getType(
              module,
              method.returnType,
              primitive: true,
            );
            indent.writeln('$primitiveType return_value_;');
          }
        }
      });

      indent.newln();
      _writeDefineType(indent, module, responseName);

      indent.newln();
      _writeDispose(indent, module, responseName, () {
        _writeCastSelf(indent, module, responseName, 'object');
        indent.writeln('g_clear_pointer(&self->error, fl_value_unref);');
        if (!method.returnType.isVoid) {
          indent.writeln(
            'g_clear_pointer(&self->return_value, fl_value_unref);',
          );
        }
      });

      indent.newln();
      _writeInit(indent, module, responseName, () {});

      indent.newln();
      _writeClassInit(indent, module, responseName, () {});

      indent.newln();
      indent.writeScoped(
        'static $responseClassName* ${responseMethodPrefix}_new(FlValue* response) {',
        '}',
        () {
          _writeObjectNew(indent, module, responseName);
          indent.writeScoped(
            'if (fl_value_get_length(response) > 1) {',
            '}',
            () {
              indent.writeln('self->error = fl_value_ref(response);');
            },
          );
          if (!method.returnType.isVoid) {
            indent.writeScoped('else {', '}', () {
              indent.writeln(
                'FlValue* value = fl_value_get_list_value(response, 0);',
              );
              indent.writeln('self->return_value = fl_value_ref(value);');
            });
          }
          indent.writeln('return self;');
        },
      );

      indent.newln();
      indent.writeScoped(
        'gboolean ${responseMethodPrefix}_is_error($responseClassName* self) {',
        '}',
        () {
          indent.writeln(
            'g_return_val_if_fail($testResponseMacro(self), FALSE);',
          );
          indent.writeln('return self->error != nullptr;');
        },
      );

      indent.newln();
      indent.writeScoped(
        'const gchar* ${responseMethodPrefix}_get_error_code($responseClassName* self) {',
        '}',
        () {
          indent.writeln(
            'g_return_val_if_fail($testResponseMacro(self), nullptr);',
          );
          indent.writeln('g_assert(${responseMethodPrefix}_is_error(self));');
          indent.writeln(
            'return fl_value_get_string(fl_value_get_list_value(self->error, 0));',
          );
        },
      );

      indent.newln();
      indent.writeScoped(
        'const gchar* ${responseMethodPrefix}_get_error_message($responseClassName* self) {',
        '}',
        () {
          indent.writeln(
            'g_return_val_if_fail($testResponseMacro(self), nullptr);',
          );
          indent.writeln('g_assert(${responseMethodPrefix}_is_error(self));');
          indent.writeln(
            'return fl_value_get_string(fl_value_get_list_value(self->error, 1));',
          );
        },
      );

      indent.newln();
      indent.writeScoped(
        'FlValue* ${responseMethodPrefix}_get_error_details($responseClassName* self) {',
        '}',
        () {
          indent.writeln(
            'g_return_val_if_fail($testResponseMacro(self), nullptr);',
          );
          indent.writeln('g_assert(${responseMethodPrefix}_is_error(self));');
          indent.writeln('return fl_value_get_list_value(self->error, 2);');
        },
      );

      if (!method.returnType.isVoid) {
        final String primitiveType = _getType(
          module,
          method.returnType,
          primitive: true,
        );

        indent.newln();
        final String returnType =
            _isNullablePrimitiveType(method.returnType)
                ? '$primitiveType*'
                : primitiveType;
        indent.writeScoped(
          '$returnType ${responseMethodPrefix}_get_return_value($responseClassName* self${_isNumericListType(method.returnType) ? ', size_t* return_value_length' : ''}) {',
          '}',
          () {
            indent.writeln(
              'g_return_val_if_fail($testResponseMacro(self), ${_getDefaultValue(module, method.returnType)});',
            );
            indent.writeln(
              'g_assert(!${responseMethodPrefix}_is_error(self));',
            );
            if (method.returnType.isNullable) {
              indent.writeScoped(
                'if (fl_value_get_type(self->return_value) == FL_VALUE_TYPE_NULL) {',
                '}',
                () {
                  indent.writeln('return nullptr;');
                },
              );
            }
            if (_isNumericListType(method.returnType)) {
              indent.writeScoped(
                'if (return_value_length != nullptr) {',
                '}',
                () {
                  indent.writeln(
                    '*return_value_length = fl_value_get_length(self->return_value);',
                  );
                },
              );
            }
            if (_isNullablePrimitiveType(method.returnType)) {
              indent.writeln(
                'self->return_value_ = ${_fromFlValue(module, method.returnType, 'self->return_value')};',
              );
              indent.writeln('return &self->return_value_;');
            } else {
              indent.writeln(
                'return ${_fromFlValue(module, method.returnType, 'self->return_value')};',
              );
            }
          },
        );
      }

      indent.newln();
      indent.writeScoped(
        'static void ${methodPrefix}_${methodName}_cb(GObject* object, GAsyncResult* result, gpointer user_data) {',
        '}',
        () {
          indent.writeln('GTask* task = G_TASK(user_data);');
          indent.writeln(
            'g_task_return_pointer(task, result, g_object_unref);',
          );
        },
      );

      final List<String> asyncArgs = <String>['$className* self'];
      for (final Parameter param in method.parameters) {
        final String name = _snakeCaseFromCamelCase(param.name);
        asyncArgs.add('${_getType(module, param.type)} $name');
        if (_isNumericListType(param.type)) {
          asyncArgs.add('size_t ${name}_length');
        }
      }
      asyncArgs.addAll(<String>[
        'GCancellable* cancellable',
        'GAsyncReadyCallback callback',
        'gpointer user_data',
      ]);
      indent.newln();
      indent.writeScoped(
        "void ${methodPrefix}_$methodName(${asyncArgs.join(', ')}) {",
        '}',
        () {
          indent.writeln('g_autoptr(FlValue) args = fl_value_new_list();');
          for (final Parameter param in method.parameters) {
            final String name = _snakeCaseFromCamelCase(param.name);
            final String value = _makeFlValue(
              root,
              module,
              param.type,
              name,
              lengthVariableName: '${name}_length',
            );
            indent.writeln('fl_value_append_take(args, $value);');
          }
          final String channelName = makeChannelName(
            api,
            method,
            dartPackageName,
          );
          indent.writeln(
            'g_autofree gchar* channel_name = g_strdup_printf("$channelName%s", self->suffix);',
          );
          indent.writeln(
            'g_autoptr($codecClassName) codec = ${codecMethodPrefix}_new();',
          );
          indent.writeln(
            'FlBasicMessageChannel* channel = fl_basic_message_channel_new(self->messenger, channel_name, FL_MESSAGE_CODEC(codec));',
          );
          indent.writeln(
            'GTask* task = g_task_new(self, cancellable, callback, user_data);',
          );
          indent.writeln(
            'g_task_set_task_data(task, channel, g_object_unref);',
          );
          indent.writeln(
            'fl_basic_message_channel_send(channel, args, cancellable, ${methodPrefix}_${methodName}_cb, task);',
          );
        },
      );

      final List<String> finishArgs = <String>[
        '$className* self',
        'GAsyncResult* result',
        'GError** error',
      ];
      indent.newln();
      indent.writeScoped(
        "$responseClassName* ${methodPrefix}_${methodName}_finish(${finishArgs.join(', ')}) {",
        '}',
        () {
          indent.writeln('g_autoptr(GTask) task = G_TASK(result);');
          indent.writeln(
            'GAsyncResult* r = G_ASYNC_RESULT(g_task_propagate_pointer(task, nullptr));',
          );
          indent.writeln(
            'FlBasicMessageChannel* channel = FL_BASIC_MESSAGE_CHANNEL(g_task_get_task_data(task));',
          );
          indent.writeln(
            'g_autoptr(FlValue) response = fl_basic_message_channel_send_finish(channel, r, error);',
          );
          indent.writeScoped('if (response == nullptr) { ', '}', () {
            indent.writeln('return nullptr;');
          });
          indent.writeln('return ${responseMethodPrefix}_new(response);');
        },
      );
    }
  }

  @override
  void writeHostApi(
    InternalGObjectOptions generatorOptions,
    Root root,
    Indent indent,
    Api api, {
    required String dartPackageName,
  }) {
    final String module = _getModule(generatorOptions, dartPackageName);
    final String className = _getClassName(module, api.name);

    final String methodPrefix = _getMethodPrefix(module, api.name);
    final String vtableName = _getVTableName(module, api.name);

    final String codecClassName = _getClassName(module, _codecBaseName);
    final String codecMethodPrefix = _getMethodPrefix(module, _codecBaseName);

    final bool hasAsyncMethod = api.methods.any(
      (Method method) => method.isAsynchronous,
    );
    if (hasAsyncMethod) {
      indent.newln();
      _writeObjectStruct(indent, module, '${api.name}ResponseHandle', () {
        indent.writeln('FlBasicMessageChannel* channel;');
        indent.writeln('FlBasicMessageChannelResponseHandle* response_handle;');
      });

      indent.newln();
      _writeDefineType(indent, module, '${api.name}ResponseHandle');

      indent.newln();
      _writeDispose(indent, module, '${api.name}ResponseHandle', () {
        _writeCastSelf(indent, module, '${api.name}ResponseHandle', 'object');
        indent.writeln('g_clear_object(&self->channel);');
        indent.writeln('g_clear_object(&self->response_handle);');
      });

      indent.newln();
      _writeInit(indent, module, '${api.name}ResponseHandle', () {});

      indent.newln();
      _writeClassInit(indent, module, '${api.name}ResponseHandle', () {});

      indent.newln();
      indent.writeScoped(
        'static ${className}ResponseHandle* ${methodPrefix}_response_handle_new(FlBasicMessageChannel* channel, FlBasicMessageChannelResponseHandle* response_handle) {',
        '}',
        () {
          _writeObjectNew(indent, module, '${api.name}ResponseHandle');
          indent.writeln(
            'self->channel = FL_BASIC_MESSAGE_CHANNEL(g_object_ref(channel));',
          );
          indent.writeln(
            'self->response_handle = FL_BASIC_MESSAGE_CHANNEL_RESPONSE_HANDLE(g_object_ref(response_handle));',
          );
          indent.writeln('return self;');
        },
      );
    }

    for (final Method method in api.methods) {
      final String responseName = _getResponseName(api.name, method.name);
      final String responseClassName = _getClassName(module, responseName);
      final String responseMethodPrefix = _getMethodPrefix(
        module,
        responseName,
      );

      if (method.isAsynchronous) {
        indent.newln();
        _writeDeclareFinalType(indent, module, responseName);
      }

      indent.newln();
      _writeObjectStruct(indent, module, responseName, () {
        indent.writeln('FlValue* value;');
      });

      indent.newln();
      _writeDefineType(indent, module, responseName);

      indent.newln();
      _writeDispose(indent, module, responseName, () {
        _writeCastSelf(indent, module, responseName, 'object');
        indent.writeln('g_clear_pointer(&self->value, fl_value_unref);');
      });

      indent.newln();
      _writeInit(indent, module, responseName, () {});

      indent.newln();
      _writeClassInit(indent, module, responseName, () {});

      final String returnType = _getType(module, method.returnType);
      indent.newln();
      final List<String> constructorArgs = <String>[
        if (returnType != 'void') '$returnType return_value',
        if (_isNumericListType(method.returnType)) 'size_t return_value_length',
      ];
      indent.writeScoped(
        "${method.isAsynchronous ? 'static ' : ''}$responseClassName* ${responseMethodPrefix}_new(${constructorArgs.join(', ')}) {",
        '}',
        () {
          _writeObjectNew(indent, module, responseName);
          indent.writeln('self->value = fl_value_new_list();');
          indent.writeln(
            "fl_value_append_take(self->value, ${_makeFlValue(root, module, method.returnType, 'return_value', lengthVariableName: 'return_value_length')});",
          );
          indent.writeln('return self;');
        },
      );

      indent.newln();
      indent.writeScoped(
        '${method.isAsynchronous ? 'static ' : ''}$responseClassName* ${responseMethodPrefix}_new_error(const gchar* code, const gchar* message, FlValue* details) {',
        '}',
        () {
          _writeObjectNew(indent, module, responseName);
          indent.writeln('self->value = fl_value_new_list();');
          indent.writeln(
            'fl_value_append_take(self->value, fl_value_new_string(code));',
          );
          indent.writeln(
            'fl_value_append_take(self->value, fl_value_new_string(message != nullptr ? message : ""));',
          );
          indent.writeln(
            'fl_value_append_take(self->value, details != nullptr ? fl_value_ref(details) : fl_value_new_null());',
          );
          indent.writeln('return self;');
        },
      );
    }

    indent.newln();
    _writeObjectStruct(indent, module, api.name, () {
      indent.writeln('const ${className}VTable* vtable;');
      indent.writeln('gpointer user_data;');
      indent.writeln('GDestroyNotify user_data_free_func;');
    });

    indent.newln();
    _writeDefineType(indent, module, api.name);

    indent.newln();
    _writeDispose(indent, module, api.name, () {
      _writeCastSelf(indent, module, api.name, 'object');
      indent.writeScoped('if (self->user_data != nullptr) {', '}', () {
        indent.writeln('self->user_data_free_func(self->user_data);');
      });
      indent.writeln('self->user_data = nullptr;');
    });

    indent.newln();
    _writeInit(indent, module, api.name, () {});

    indent.newln();
    _writeClassInit(indent, module, api.name, () {});

    indent.newln();
    indent.writeScoped(
      'static $className* ${methodPrefix}_new(const $vtableName* vtable, gpointer user_data, GDestroyNotify user_data_free_func) {',
      '}',
      () {
        _writeObjectNew(indent, module, api.name);
        indent.writeln('self->vtable = vtable;');
        indent.writeln('self->user_data = user_data;');
        indent.writeln('self->user_data_free_func = user_data_free_func;');
        indent.writeln('return self;');
      },
    );

    for (final Method method in api.methods) {
      final String methodName = _getMethodName(method.name);
      final String responseName = _getResponseName(api.name, method.name);
      final String responseClassName = _getClassName(module, responseName);

      indent.newln();
      indent.writeScoped(
        'static void ${methodPrefix}_${methodName}_cb(FlBasicMessageChannel* channel, FlValue* message_, FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {',
        '}',
        () {
          _writeCastSelf(indent, module, api.name, 'user_data');

          indent.newln();
          indent.writeScoped(
            'if (self->vtable == nullptr || self->vtable->$methodName == nullptr) {',
            '}',
            () {
              indent.writeln('return;');
            },
          );

          indent.newln();
          final List<String> methodArgs = <String>[];
          for (int i = 0; i < method.parameters.length; i++) {
            final Parameter param = method.parameters[i];
            final String paramName = _snakeCaseFromCamelCase(param.name);
            final String paramType = _getType(module, param.type);
            indent.writeln(
              'FlValue* value$i = fl_value_get_list_value(message_, $i);',
            );
            if (_isNullablePrimitiveType(param.type)) {
              final String primitiveType = _getType(
                module,
                param.type,
                primitive: true,
              );
              indent.writeln('$paramType $paramName = nullptr;');
              indent.writeln('$primitiveType ${paramName}_value;');
              indent.writeScoped(
                'if (fl_value_get_type(value$i) != FL_VALUE_TYPE_NULL) {',
                '}',
                () {
                  final String paramValue = _fromFlValue(
                    module,
                    method.parameters[i].type,
                    'value$i',
                  );
                  indent.writeln('${paramName}_value = $paramValue;');
                  indent.writeln('$paramName = &${paramName}_value;');
                },
              );
            } else {
              final String paramValue = _fromFlValue(
                module,
                method.parameters[i].type,
                'value$i',
              );
              indent.writeln('$paramType $paramName = $paramValue;');
            }
            methodArgs.add(paramName);
            if (_isNumericListType(method.parameters[i].type)) {
              indent.writeln(
                'size_t ${paramName}_length = fl_value_get_length(value$i);',
              );
              methodArgs.add('${paramName}_length');
            }
          }
          if (method.isAsynchronous) {
            final List<String> vfuncArgs = <String>[];
            vfuncArgs.addAll(methodArgs);
            vfuncArgs.addAll(<String>['handle', 'self->user_data']);
            indent.writeln(
              'g_autoptr(${className}ResponseHandle) handle = ${methodPrefix}_response_handle_new(channel, response_handle);',
            );
            indent.writeln(
              "self->vtable->$methodName(${vfuncArgs.join(', ')});",
            );
          } else {
            final List<String> vfuncArgs = <String>[];
            vfuncArgs.addAll(methodArgs);
            vfuncArgs.add('self->user_data');
            indent.writeln(
              "g_autoptr($responseClassName) response = self->vtable->$methodName(${vfuncArgs.join(', ')});",
            );
            indent.writeScoped('if (response == nullptr) {', '}', () {
              indent.writeln(
                'g_warning("No response returned to %s.%s", "${api.name}", "${method.name}");',
              );
              indent.writeln('return;');
            });

            indent.newln();
            indent.writeln('g_autoptr(GError) error = NULL;');
            indent.writeScoped(
              'if (!fl_basic_message_channel_respond(channel, response_handle, response->value, &error)) {',
              '}',
              () {
                indent.writeln(
                  'g_warning("Failed to send response to %s.%s: %s", "${api.name}", "${method.name}", error->message);',
                );
              },
            );
          }
        },
      );
    }

    indent.newln();
    indent.writeScoped(
      'void ${methodPrefix}_set_method_handlers(FlBinaryMessenger* messenger, const gchar* suffix, const $vtableName* vtable, gpointer user_data, GDestroyNotify user_data_free_func) {',
      '}',
      () {
        indent.writeln(
          'g_autofree gchar* dot_suffix = suffix != nullptr ? g_strdup_printf(".%s", suffix) : g_strdup("");',
        );
        indent.writeln(
          'g_autoptr($className) api_data = ${methodPrefix}_new(vtable, user_data, user_data_free_func);',
        );

        indent.newln();
        indent.writeln(
          'g_autoptr($codecClassName) codec = ${codecMethodPrefix}_new();',
        );
        for (final Method method in api.methods) {
          final String methodName = _getMethodName(method.name);
          final String channelName = makeChannelName(
            api,
            method,
            dartPackageName,
          );
          indent.writeln(
            'g_autofree gchar* ${methodName}_channel_name = g_strdup_printf("$channelName%s", dot_suffix);',
          );
          indent.writeln(
            'g_autoptr(FlBasicMessageChannel) ${methodName}_channel = fl_basic_message_channel_new(messenger, ${methodName}_channel_name, FL_MESSAGE_CODEC(codec));',
          );
          indent.writeln(
            'fl_basic_message_channel_set_message_handler(${methodName}_channel, ${methodPrefix}_${methodName}_cb, g_object_ref(api_data), g_object_unref);',
          );
        }
      },
    );

    indent.newln();
    indent.writeScoped(
      'void ${methodPrefix}_clear_method_handlers(FlBinaryMessenger* messenger, const gchar* suffix) {',
      '}',
      () {
        indent.writeln(
          'g_autofree gchar* dot_suffix = suffix != nullptr ? g_strdup_printf(".%s", suffix) : g_strdup("");',
        );

        indent.newln();
        indent.writeln(
          'g_autoptr($codecClassName) codec = ${codecMethodPrefix}_new();',
        );
        for (final Method method in api.methods) {
          final String methodName = _getMethodName(method.name);
          final String channelName = makeChannelName(
            api,
            method,
            dartPackageName,
          );
          indent.writeln(
            'g_autofree gchar* ${methodName}_channel_name = g_strdup_printf("$channelName%s", dot_suffix);',
          );
          indent.writeln(
            'g_autoptr(FlBasicMessageChannel) ${methodName}_channel = fl_basic_message_channel_new(messenger, ${methodName}_channel_name, FL_MESSAGE_CODEC(codec));',
          );
          indent.writeln(
            'fl_basic_message_channel_set_message_handler(${methodName}_channel, nullptr, nullptr, nullptr);',
          );
        }
      },
    );

    for (final Method method in api.methods.where(
      (Method method) => method.isAsynchronous,
    )) {
      final String returnType = _getType(module, method.returnType);
      final String methodName = _getMethodName(method.name);
      final String responseName = _getResponseName(api.name, method.name);
      final String responseClassName = _getClassName(module, responseName);
      final String responseMethodPrefix = _getMethodPrefix(
        module,
        responseName,
      );

      indent.newln();
      final List<String> respondArgs = <String>[
        '${className}ResponseHandle* response_handle',
        if (returnType != 'void') '$returnType return_value',
        if (_isNumericListType(method.returnType)) 'size_t return_value_length',
      ];
      indent.writeScoped(
        "void ${methodPrefix}_respond_$methodName(${respondArgs.join(', ')}) {",
        '}',
        () {
          final List<String> returnArgs = <String>[
            if (returnType != 'void') 'return_value',
            if (_isNumericListType(method.returnType)) 'return_value_length',
          ];
          indent.writeln(
            'g_autoptr($responseClassName) response = ${responseMethodPrefix}_new(${returnArgs.join(', ')});',
          );
          indent.writeln('g_autoptr(GError) error = nullptr;');
          indent.writeScoped(
            'if (!fl_basic_message_channel_respond(response_handle->channel, response_handle->response_handle, response->value, &error)) {',
            '}',
            () {
              indent.writeln(
                'g_warning("Failed to send response to %s.%s: %s", "${api.name}", "${method.name}", error->message);',
              );
            },
          );
        },
      );

      indent.newln();
      final List<String> respondErrorArgs = <String>[
        '${className}ResponseHandle* response_handle',
        'const gchar* code',
        'const gchar* message',
        'FlValue* details',
      ];
      indent.writeScoped(
        "void ${methodPrefix}_respond_error_$methodName(${respondErrorArgs.join(', ')}) {",
        '}',
        () {
          indent.writeln(
            'g_autoptr($responseClassName) response = ${responseMethodPrefix}_new_error(code, message, details);',
          );
          indent.writeln('g_autoptr(GError) error = nullptr;');
          indent.writeScoped(
            'if (!fl_basic_message_channel_respond(response_handle->channel, response_handle->response_handle, response->value, &error)) {',
            '}',
            () {
              indent.writeln(
                'g_warning("Failed to send response to %s.%s: %s", "${api.name}", "${method.name}", error->message);',
              );
            },
          );
        },
      );
    }
  }
}

// Returns the module name to use.
String _getModule(
  InternalGObjectOptions generatorOptions,
  String dartPackageName,
) {
  return generatorOptions.module ?? _camelCaseFromSnakeCase(dartPackageName);
}

// Returns the header guard defintion for [headerFileName].
String _getGuardName(String? headerFileName) {
  const String prefix = 'PIGEON_';
  if (headerFileName != null) {
    return '$prefix${headerFileName.replaceAll('.', '_').toUpperCase()}_';
  } else {
    return '${prefix}H_';
  }
}

// Writes the GObject macro to generate a new type.
void _writeDeclareFinalType(
  Indent indent,
  String module,
  String name, {
  String parentClassName = 'GObject',
}) {
  final String upperModule = _snakeCaseFromCamelCase(module).toUpperCase();
  final String className = _getClassName(module, name);
  final String snakeClassName = _snakeCaseFromCamelCase(name);
  final String upperSnakeClassName = snakeClassName.toUpperCase();
  final String methodPrefix = _getMethodPrefix(module, name);

  indent.writeln(
    'G_DECLARE_FINAL_TYPE($className, $methodPrefix, $upperModule, $upperSnakeClassName, $parentClassName)',
  );
}

// Writes the GObject macro to define a new type.
void _writeDefineType(
  Indent indent,
  String module,
  String name, {
  String parentType = 'G_TYPE_OBJECT',
}) {
  final String className = _getClassName(module, name);
  final String methodPrefix = _getMethodPrefix(module, name);

  indent.writeln('G_DEFINE_TYPE($className, $methodPrefix, $parentType)');
}

// Writes the struct for a GObject.
void _writeObjectStruct(
  Indent indent,
  String module,
  String name,
  void Function() func, {
  String parentClassName = 'GObject',
}) {
  final String className = _getClassName(module, name);

  indent.writeScoped('struct _$className {', '};', () {
    indent.writeln('$parentClassName parent_instance;');
    indent.newln();

    func();
  });
}

// Writes the dispose method for a GObject.
void _writeDispose(
  Indent indent,
  String module,
  String name,
  void Function() func,
) {
  final String methodPrefix = _getMethodPrefix(module, name);

  indent.writeScoped(
    'static void ${methodPrefix}_dispose(GObject* object) {',
    '}',
    () {
      func();
      indent.writeln(
        'G_OBJECT_CLASS(${methodPrefix}_parent_class)->dispose(object);',
      );
    },
  );
}

// Writes the init function for a GObject.
void _writeInit(
  Indent indent,
  String module,
  String name,
  void Function() func,
) {
  final String className = _getClassName(module, name);
  final String methodPrefix = _getMethodPrefix(module, name);

  indent.writeScoped(
    'static void ${methodPrefix}_init($className* self) {',
    '}',
    () {
      func();
    },
  );
}

// Writes the class init function for a GObject.
void _writeClassInit(
  Indent indent,
  String module,
  String name,
  void Function() func, {
  bool hasDispose = true,
}) {
  final String className = _getClassName(module, name);
  final String methodPrefix = _getMethodPrefix(module, name);

  indent.writeScoped(
    'static void ${methodPrefix}_class_init(${className}Class* klass) {',
    '}',
    () {
      if (hasDispose) {
        indent.writeln(
          'G_OBJECT_CLASS(klass)->dispose = ${methodPrefix}_dispose;',
        );
      }
      func();
    },
  );
}

// Writes the constructor for a GObject.
void _writeObjectNew(Indent indent, String module, String name) {
  final String className = _getClassName(module, name);
  final String methodPrefix = _getMethodPrefix(module, name);
  final String castMacro = _getClassCastMacro(module, name);

  indent.writeln(
    '$className* self = $castMacro(g_object_new(${methodPrefix}_get_type(), nullptr));',
  );
}

// Writes the cast used at the top of GObject methods.
void _writeCastSelf(
  Indent indent,
  String module,
  String name,
  String variableName,
) {
  final String className = _getClassName(module, name);
  final String castMacro = _getClassCastMacro(module, name);
  indent.writeln('$className* self = $castMacro($variableName);');
}

// Converts a string from CamelCase to snake_case.
String _snakeCaseFromCamelCase(String camelCase) {
  return camelCase.replaceAllMapped(
    RegExp(r'[A-Z]'),
    (Match m) => '${m.start == 0 ? '' : '_'}${m[0]!.toLowerCase()}',
  );
}

// Converts a string from snake_case to CamelCase
String _camelCaseFromSnakeCase(String snakeCase) {
  return snakeCase
      .split('_')
      .map((String v) => v[0].toUpperCase() + v.substring(1))
      .join();
}

// Returns the GObject class name for [name].
String _getClassName(String module, String name) {
  return '$module$name';
}

// Returns the name to use for a class field with [name].
String _getFieldName(String name) {
  final List<String> reservedNames = <String>['type'];
  if (reservedNames.contains(name)) {
    name += '_';
  }
  return _snakeCaseFromCamelCase(name);
}

// Returns the name to user for a class method with [name]
String _getMethodName(String name) {
  final List<String> reservedNames = <String>['new', 'get_type'];
  if (reservedNames.contains(name)) {
    name += '_';
  }
  return _snakeCaseFromCamelCase(name);
}

/// Return the name of the VTable structure to use for API requests.
String _getVTableName(String module, String name) {
  final String className = _getClassName(module, name);
  return '${className}VTable';
}

// Returns the GObject macro to cast a GObject to a class of [name].
String _getClassCastMacro(String module, String name) {
  final String className = _getClassName(module, name);
  final String snakeClassName = _snakeCaseFromCamelCase(className);
  return snakeClassName.toUpperCase();
}

// Returns the prefix used for methods in class [name].
String _getMethodPrefix(String module, String name) {
  final String className = _getClassName(module, name);
  return _snakeCaseFromCamelCase(className);
}

// Returns the code for the custom type id definition for [customType].
String _getCustomTypeId(String module, EnumeratedType customType) {
  final String customTypeName = _getClassName(module, customType.name);

  final String snakeCustomTypeName = _snakeCaseFromCamelCase(customTypeName);

  final String customTypeId = '${snakeCustomTypeName}_type_id';
  return customTypeId;
}

// Returns an enumeration value in C++ form.
String _getEnumValue(String module, String enumName, String memberName) {
  final String snakeEnumName = _snakeCaseFromCamelCase(enumName);
  final String snakeMemberName = _snakeCaseFromCamelCase(memberName);
  return '${module}_${snakeEnumName}_$snakeMemberName'.toUpperCase();
}

// Returns code for storing a value of [type].
String _getType(
  String module,
  TypeDeclaration type, {
  bool isOutput = false,
  bool primitive = false,
}) {
  if (type.isClass) {
    return '${_getClassName(module, type.baseName)}*';
  } else if (type.isEnum) {
    final String name = _getClassName(module, type.baseName);
    return type.isNullable && !primitive ? '$name*' : name;
  } else if (_isFlValueWrappedType(type)) {
    return 'FlValue*';
  } else if (type.baseName == 'void') {
    return 'void';
  } else if (type.baseName == 'bool') {
    return type.isNullable && !primitive ? 'gboolean*' : 'gboolean';
  } else if (type.baseName == 'int') {
    return type.isNullable && !primitive ? 'int64_t*' : 'int64_t';
  } else if (type.baseName == 'double') {
    return type.isNullable && !primitive ? 'double*' : 'double';
  } else if (type.baseName == 'String') {
    return isOutput ? 'gchar*' : 'const gchar*';
  } else if (type.baseName == 'Uint8List') {
    return isOutput ? 'uint8_t*' : 'const uint8_t*';
  } else if (type.baseName == 'Int32List') {
    return isOutput ? 'int32_t*' : 'const int32_t*';
  } else if (type.baseName == 'Int64List') {
    return isOutput ? 'int64_t*' : 'const int64_t*';
  } else if (type.baseName == 'Float32List') {
    return isOutput ? 'float*' : 'const float*';
  } else if (type.baseName == 'Float64List') {
    return isOutput ? 'double*' : 'const double*';
  } else {
    throw Exception('Unknown type ${type.baseName}');
  }
}

// Returns true if [type] is a *List typed numeric list type.
bool _isNumericListType(TypeDeclaration type) {
  return type.baseName == 'Uint8List' ||
      type.baseName == 'Int32List' ||
      type.baseName == 'Int64List' ||
      type.baseName == 'Float32List' ||
      type.baseName == 'Float64List';
}

// Returns true if [type] is a nullable type with a primitive native data type.
bool _isNullablePrimitiveType(TypeDeclaration type) {
  if (!type.isNullable) {
    return false;
  }

  return type.isEnum ||
      type.baseName == 'bool' ||
      type.baseName == 'int' ||
      type.baseName == 'double';
}

// Whether [type] is a type that needs to stay an FlValue* since it can't be
// expressed as a more concrete type.
bool _isFlValueWrappedType(TypeDeclaration type) {
  return type.baseName == 'List' ||
      type.baseName == 'Map' ||
      type.baseName == 'Object';
}

// Returns code to clear a value stored in [variableName], or null if no function required.
String? _getClearFunction(TypeDeclaration type, String variableName) {
  if (type.isClass) {
    return 'g_clear_object(&$variableName)';
  } else if (_isFlValueWrappedType(type)) {
    return 'g_clear_pointer(&$variableName, fl_value_unref)';
  } else if (type.baseName == 'String') {
    return 'g_clear_pointer(&$variableName, g_free)';
  } else if (_isNullablePrimitiveType(type)) {
    return 'g_clear_pointer(&$variableName, g_free)';
  } else {
    return null;
  }
}

// Returns code for the default value for [type].
String _getDefaultValue(
  String module,
  TypeDeclaration type, {
  bool primitive = false,
}) {
  if (type.isClass || (type.isNullable && !primitive)) {
    return 'nullptr';
  } else if (type.isEnum) {
    final String enumName = _getClassName(module, type.baseName);
    return 'static_cast<$enumName>(0)';
  } else if (_isFlValueWrappedType(type)) {
    return 'nullptr';
  } else if (type.baseName == 'void') {
    return '';
  } else if (type.baseName == 'bool') {
    return 'FALSE';
  } else if (type.baseName == 'int') {
    return '0';
  } else if (type.baseName == 'double') {
    return '0.0';
  } else if (type.baseName == 'String') {
    return 'nullptr';
  } else if (_isNumericListType(type)) {
    return 'nullptr';
  } else {
    throw Exception('Unknown type ${type.baseName}');
  }
}

// Returns code to copy the native data type stored in [variableName].
//
// [lengthVariableName] must be provided for the typed numeric *List types.
String _referenceValue(
  String module,
  TypeDeclaration type,
  String variableName, {
  String? lengthVariableName,
}) {
  if (type.isClass) {
    final String castMacro = _getClassCastMacro(module, type.baseName);
    return '$castMacro(g_object_ref($variableName))';
  } else if (_isFlValueWrappedType(type)) {
    return 'fl_value_ref($variableName)';
  } else if (type.baseName == 'String') {
    return 'g_strdup($variableName)';
  } else if (type.baseName == 'Uint8List') {
    return 'static_cast<uint8_t*>(memcpy(malloc($lengthVariableName), $variableName, $lengthVariableName))';
  } else if (type.baseName == 'Int32List') {
    return 'static_cast<int32_t*>(memcpy(malloc(sizeof(int32_t) * $lengthVariableName), $variableName, sizeof(int32_t) * $lengthVariableName))';
  } else if (type.baseName == 'Int64List') {
    return 'static_cast<int64_t*>(memcpy(malloc(sizeof(int64_t) * $lengthVariableName), $variableName, sizeof(int64_t) * $lengthVariableName))';
  } else if (type.baseName == 'Float32List') {
    return 'static_cast<float*>(memcpy(malloc(sizeof(float) * $lengthVariableName), $variableName, sizeof(float) * $lengthVariableName))';
  } else if (type.baseName == 'Float64List') {
    return 'static_cast<double*>(memcpy(malloc(sizeof(double) * $lengthVariableName), $variableName, sizeof(double) * $lengthVariableName))';
  } else {
    return variableName;
  }
}

String _getCustomTypeIdFromDeclaration(
  Root root,
  TypeDeclaration type,
  String module,
) {
  return _getCustomTypeId(
    module,
    getEnumeratedTypes(root, excludeSealedClasses: true).firstWhere(
      (EnumeratedType t) =>
          (type.isClass && t.associatedClass == type.associatedClass) ||
          (type.isEnum && t.associatedEnum == type.associatedEnum),
    ),
  );
}

// Returns code to convert the native data type stored in [variableName] to a FlValue.
//
// [lengthVariableName] must be provided for the typed numeric *List types.
String _makeFlValue(
  Root root,
  String module,
  TypeDeclaration type,
  String variableName, {
  String? lengthVariableName,
}) {
  final String value;
  if (type.isClass) {
    final String customTypeId = _getCustomTypeIdFromDeclaration(
      root,
      type,
      module,
    );
    value =
        'fl_value_new_custom_object($customTypeId, G_OBJECT($variableName))';
  } else if (type.isEnum) {
    final String customTypeId = _getCustomTypeIdFromDeclaration(
      root,
      type,
      module,
    );
    value =
        'fl_value_new_custom($customTypeId, fl_value_new_int(${type.isNullable ? '*$variableName' : variableName}), (GDestroyNotify)fl_value_unref)';
  } else if (_isFlValueWrappedType(type)) {
    value = 'fl_value_ref($variableName)';
  } else if (type.baseName == 'void') {
    value = 'fl_value_new_null()';
  } else if (type.baseName == 'bool') {
    value =
        type.isNullable
            ? 'fl_value_new_bool(*$variableName)'
            : 'fl_value_new_bool($variableName)';
  } else if (type.baseName == 'int') {
    value =
        type.isNullable
            ? 'fl_value_new_int(*$variableName)'
            : 'fl_value_new_int($variableName)';
  } else if (type.baseName == 'double') {
    value =
        type.isNullable
            ? 'fl_value_new_float(*$variableName)'
            : 'fl_value_new_float($variableName)';
  } else if (type.baseName == 'String') {
    value = 'fl_value_new_string($variableName)';
  } else if (type.baseName == 'Uint8List') {
    value = 'fl_value_new_uint8_list($variableName, $lengthVariableName)';
  } else if (type.baseName == 'Int32List') {
    value = 'fl_value_new_int32_list($variableName, $lengthVariableName)';
  } else if (type.baseName == 'Int64List') {
    value = 'fl_value_new_int64_list($variableName, $lengthVariableName)';
  } else if (type.baseName == 'Float32List') {
    value = 'fl_value_new_float32_list($variableName, $lengthVariableName)';
  } else if (type.baseName == 'Float64List') {
    value = 'fl_value_new_float_list($variableName, $lengthVariableName)';
  } else {
    throw Exception('Unknown type ${type.baseName}');
  }

  if (type.isNullable) {
    return '$variableName != nullptr ? $value : fl_value_new_null()';
  } else {
    return value;
  }
}

// Returns code to convert the FlValue stored in [variableName] to a native data type.
String _fromFlValue(String module, TypeDeclaration type, String variableName) {
  if (type.isClass) {
    final String castMacro = _getClassCastMacro(module, type.baseName);
    return '$castMacro(fl_value_get_custom_value_object($variableName))';
  } else if (type.isEnum) {
    final String enumName = _getClassName(module, type.baseName);
    return 'static_cast<$enumName>(fl_value_get_int(reinterpret_cast<FlValue*>(const_cast<gpointer>(fl_value_get_custom_value($variableName)))))';
  } else if (_isFlValueWrappedType(type)) {
    return variableName;
  } else if (type.baseName == 'bool') {
    return 'fl_value_get_bool($variableName)';
  } else if (type.baseName == 'int') {
    return 'fl_value_get_int($variableName)';
  } else if (type.baseName == 'double') {
    return 'fl_value_get_float($variableName)';
  } else if (type.baseName == 'String') {
    return 'fl_value_get_string($variableName)';
  } else if (type.baseName == 'Uint8List') {
    return 'fl_value_get_uint8_list($variableName)';
  } else if (type.baseName == 'Int32List') {
    return 'fl_value_get_int32_list($variableName)';
  } else if (type.baseName == 'Int64List') {
    return 'fl_value_get_int64_list($variableName)';
  } else if (type.baseName == 'Float32List') {
    return 'fl_value_get_float32_list($variableName)';
  } else if (type.baseName == 'Float64List') {
    return 'fl_value_get_float_list($variableName)';
  } else {
    throw Exception('Unknown type ${type.baseName}');
  }
}

// Returns the name of a GObject class used to send responses to [methodName].
String _getResponseName(String name, String methodName) {
  final String upperMethodName =
      methodName[0].toUpperCase() + methodName.substring(1);
  return '$name${upperMethodName}Response';
}
