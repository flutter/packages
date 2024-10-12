// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';
import 'functional.dart';
import 'generator.dart';
import 'generator_tools.dart';
import 'pigeon_lib.dart' show Error;

/// General comment opening token.
const String _commentPrefix = '//';

const String _voidType = 'void';

/// Documentation comment spec.
const DocumentCommentSpecification _docCommentSpec =
    DocumentCommentSpecification(_commentPrefix);

/// The default serializer for Flutter.
const String _standardCodecSerializer = 'flutter::StandardCodecSerializer';

/// The name of the codec serializer.
const String _codecSerializerName = '${classNamePrefix}CodecSerializer';

const String _overflowClassName = '${classNamePrefix}CodecOverflow';

final NamedType _overflowType = NamedType(
    name: 'type',
    type: const TypeDeclaration(baseName: 'int', isNullable: false));
final NamedType _overflowObject = NamedType(
    name: 'wrapped',
    type: const TypeDeclaration(baseName: 'Object', isNullable: false));
final List<NamedType> _overflowFields = <NamedType>[
  _overflowType,
  _overflowObject,
];
final Class _overflowClass =
    Class(name: _overflowClassName, fields: _overflowFields);
final EnumeratedType _enumeratedOverflow = EnumeratedType(
    _overflowClassName, maximumCodecFieldKey, CustomTypes.customClass,
    associatedClass: _overflowClass);

/// Options that control how C++ code will be generated.
class CppOptions {
  /// Creates a [CppOptions] object
  const CppOptions({
    this.headerIncludePath,
    this.namespace,
    this.copyrightHeader,
    this.headerOutPath,
  });

  /// The path to the header that will get placed in the source filed (example:
  /// "foo.h").
  final String? headerIncludePath;

  /// The namespace where the generated class will live.
  final String? namespace;

  /// A copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// The path to the output header file location.
  final String? headerOutPath;

  /// Creates a [CppOptions] from a Map representation where:
  /// `x = CppOptions.fromMap(x.toMap())`.
  static CppOptions fromMap(Map<String, Object> map) {
    return CppOptions(
      headerIncludePath: map['headerIncludePath'] as String?,
      namespace: map['namespace'] as String?,
      copyrightHeader: map['copyrightHeader'] as Iterable<String>?,
      headerOutPath: map['cppHeaderOut'] as String?,
    );
  }

  /// Converts a [CppOptions] to a Map representation where:
  /// `x = CppOptions.fromMap(x.toMap())`.
  Map<String, Object> toMap() {
    final Map<String, Object> result = <String, Object>{
      if (headerIncludePath != null) 'headerIncludePath': headerIncludePath!,
      if (namespace != null) 'namespace': namespace!,
      if (copyrightHeader != null) 'copyrightHeader': copyrightHeader!,
    };
    return result;
  }

  /// Overrides any non-null parameters from [options] into this to make a new
  /// [CppOptions].
  CppOptions merge(CppOptions options) {
    return CppOptions.fromMap(mergeMaps(toMap(), options.toMap()));
  }
}

/// Class that manages all Cpp code generation.
class CppGenerator extends Generator<OutputFileOptions<CppOptions>> {
  /// Constructor.
  const CppGenerator();

  /// Generates C++ file of type specified in [generatorOptions]
  @override
  void generate(
    OutputFileOptions<CppOptions> generatorOptions,
    Root root,
    StringSink sink, {
    required String dartPackageName,
  }) {
    assert(generatorOptions.fileType == FileType.header ||
        generatorOptions.fileType == FileType.source);
    if (generatorOptions.fileType == FileType.header) {
      const CppHeaderGenerator().generate(
        generatorOptions.languageOptions,
        root,
        sink,
        dartPackageName: dartPackageName,
      );
    } else if (generatorOptions.fileType == FileType.source) {
      const CppSourceGenerator().generate(
        generatorOptions.languageOptions,
        root,
        sink,
        dartPackageName: dartPackageName,
      );
    }
  }
}

/// Writes C++ header (.h) file to sink.
class CppHeaderGenerator extends StructuredGenerator<CppOptions> {
  /// Constructor.
  const CppHeaderGenerator();

  @override
  void writeFilePrologue(
    CppOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (generatorOptions.copyrightHeader != null) {
      addLines(indent, generatorOptions.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('$_commentPrefix ${getGeneratedCodeWarning()}');
    indent.writeln('$_commentPrefix $seeAlsoWarning');
    indent.newln();
  }

  @override
  void writeFileImports(
    CppOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    final String guardName = _getGuardName(generatorOptions.headerIncludePath);
    indent.writeln('#ifndef $guardName');
    indent.writeln('#define $guardName');

    _writeSystemHeaderIncludeBlock(indent, <String>[
      'flutter/basic_message_channel.h',
      'flutter/binary_messenger.h',
      'flutter/encodable_value.h',
      'flutter/standard_message_codec.h',
    ]);
    indent.newln();
    _writeSystemHeaderIncludeBlock(indent, <String>[
      'map',
      'string',
      'optional',
    ]);
    indent.newln();
    if (generatorOptions.namespace != null) {
      indent.writeln('namespace ${generatorOptions.namespace} {');
    }
    indent.newln();
    if (generatorOptions.namespace?.endsWith('_pigeontest') ?? false) {
      final String testFixtureClass =
          '${_pascalCaseFromSnakeCase(generatorOptions.namespace!.replaceAll('_pigeontest', ''))}Test';
      indent.writeln('class $testFixtureClass;');
    }
    indent.newln();
    indent.writeln('$_commentPrefix Generated class from Pigeon.');
  }

  @override
  void writeEnum(
    CppOptions generatorOptions,
    Root root,
    Indent indent,
    Enum anEnum, {
    required String dartPackageName,
  }) {
    indent.newln();
    addDocumentationComments(
        indent, anEnum.documentationComments, _docCommentSpec);
    indent.write('enum class ${anEnum.name} ');
    indent.addScoped('{', '};', () {
      enumerate(anEnum.members, (int index, final EnumMember member) {
        addDocumentationComments(
            indent, member.documentationComments, _docCommentSpec);
        final String valueName = 'k${_pascalCaseFromCamelCase(member.name)}';
        indent.writeln(
            '$valueName = $index${index == anEnum.members.length - 1 ? '' : ','}');
      });
    });
  }

  @override
  void writeGeneralUtilities(
    CppOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    final bool hasHostApi = root.apis
        .whereType<AstHostApi>()
        .any((Api api) => api.methods.isNotEmpty);
    final bool hasFlutterApi = root.apis
        .whereType<AstFlutterApi>()
        .any((Api api) => api.methods.isNotEmpty);

    _writeFlutterError(indent);
    if (hasHostApi) {
      _writeErrorOr(
        indent,
        friends: root.apis
            .where((Api api) => api is AstFlutterApi || api is AstHostApi)
            .map((Api api) => api.name),
      );
    }
    if (hasFlutterApi) {
      // Nothing yet.
    }
  }

  @override
  void writeDataClasses(
    CppOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.newln();
    super.writeDataClasses(
      generatorOptions,
      root,
      indent,
      dartPackageName: dartPackageName,
    );
    if (root.requiresOverflowClass) {
      writeDataClass(
        generatorOptions,
        root,
        indent,
        _overflowClass,
        dartPackageName: dartPackageName,
        isOverflowClass: true,
      );
    }
  }

  @override
  void writeDataClass(
    CppOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
    bool isOverflowClass = false,
  }) {
    // When generating for a Pigeon unit test, add a test fixture friend class to
    // allow unit testing private methods, since testing serialization via public
    // methods is essentially an end-to-end test.
    String? testFixtureClass;
    if (generatorOptions.namespace?.endsWith('_pigeontest') ?? false) {
      testFixtureClass =
          '${_pascalCaseFromSnakeCase(generatorOptions.namespace!.replaceAll('_pigeontest', ''))}Test';
    }
    indent.newln();

    const List<String> generatedMessages = <String>[
      ' Generated class from Pigeon that represents data sent in messages.'
    ];

    addDocumentationComments(
        indent, classDefinition.documentationComments, _docCommentSpec,
        generatorComments: generatedMessages);

    final Iterable<NamedType> orderedFields =
        getFieldsInSerializationOrder(classDefinition);

    indent.write('class ${classDefinition.name} ');
    indent.addScoped('{', '};', () {
      _writeAccessBlock(indent, _ClassAccess.public, () {
        final Iterable<NamedType> requiredFields =
            orderedFields.where((NamedType type) => !type.type.isNullable);
        // Minimal constructor, if needed.
        if (requiredFields.length != orderedFields.length) {
          _writeClassConstructor(root, indent, classDefinition, requiredFields,
              'Constructs an object setting all non-nullable fields.');
        }
        // All-field constructor.
        _writeClassConstructor(root, indent, classDefinition, orderedFields,
            'Constructs an object setting all fields.');

        // If any fields are pointer type, then the class requires a custom
        // copy constructor, so declare the rule-of-five group of functions.
        if (orderedFields.any((NamedType field) => _isPointerField(
            getFieldHostDatatype(field, _baseCppTypeForBuiltinDartType)))) {
          final String className = classDefinition.name;
          // Add the default destructor, since unique_ptr destroys itself.
          _writeFunctionDeclaration(indent, '~$className', defaultImpl: true);
          // Declare custom copy/assign to deep-copy the pointer.
          _writeFunctionDeclaration(indent, className,
              isConstructor: true,
              isCopy: true,
              parameters: <String>['const $className& other']);
          _writeFunctionDeclaration(indent, 'operator=',
              returnType: '$className&',
              parameters: <String>['const $className& other']);
          // Re-add the default move operations, since they work fine with
          // unique_ptr.
          _writeFunctionDeclaration(indent, className,
              isConstructor: true,
              isCopy: true,
              parameters: <String>['$className&& other'],
              defaultImpl: true);
          _writeFunctionDeclaration(indent, 'operator=',
              returnType: '$className&',
              parameters: <String>['$className&& other'],
              defaultImpl: true,
              noexcept: true);
        }

        for (final NamedType field in orderedFields) {
          addDocumentationComments(
              indent, field.documentationComments, _docCommentSpec);
          final HostDatatype baseDatatype =
              getFieldHostDatatype(field, _baseCppTypeForBuiltinDartType);
          // Declare a getter and setter.
          _writeFunctionDeclaration(indent, _makeGetterName(field),
              returnType: _getterReturnType(baseDatatype), isConst: true);
          final String setterName = _makeSetterName(field);
          _writeFunctionDeclaration(indent, setterName,
              returnType: _voidType,
              parameters: <String>[
                '${_unownedArgumentType(baseDatatype)} value_arg'
              ]);
          if (field.type.isNullable) {
            // Add a second setter that takes the non-nullable version of the
            // argument for convenience, since setting literal values with the
            // pointer version is non-trivial.
            final HostDatatype nonNullType = _nonNullableType(baseDatatype);
            _writeFunctionDeclaration(indent, setterName,
                returnType: _voidType,
                parameters: <String>[
                  '${_unownedArgumentType(nonNullType)} value_arg'
                ]);
          }
          indent.newln();
        }
      });

      _writeAccessBlock(indent, _ClassAccess.private, () {
        _writeFunctionDeclaration(indent, 'FromEncodableList',
            returnType: isOverflowClass
                ? 'flutter::EncodableValue'
                : classDefinition.name,
            parameters: <String>['const flutter::EncodableList& list'],
            isStatic: true);
        _writeFunctionDeclaration(indent, 'ToEncodableList',
            returnType: 'flutter::EncodableList', isConst: true);
        if (isOverflowClass) {
          _writeFunctionDeclaration(indent, 'Unwrap',
              returnType: 'flutter::EncodableValue');
        }
        if (!isOverflowClass && root.requiresOverflowClass) {
          indent.writeln('friend class $_overflowClassName;');
        }
        for (final Class friend in root.classes) {
          if (friend != classDefinition &&
              friend.fields.any((NamedType element) =>
                  element.type.baseName == classDefinition.name)) {
            indent.writeln('friend class ${friend.name};');
          }
        }
        for (final Api api in root.apis
            .where((Api api) => api is AstFlutterApi || api is AstHostApi)) {
          // TODO(gaaclarke): Find a way to be more precise with our
          // friendships.
          indent.writeln('friend class ${api.name};');
        }
        indent.writeln('friend class $_codecSerializerName;');
        if (testFixtureClass != null) {
          indent.writeln('friend class $testFixtureClass;');
        }

        for (final NamedType field in orderedFields) {
          final HostDatatype hostDatatype =
              getFieldHostDatatype(field, _baseCppTypeForBuiltinDartType);
          indent.writeln(
              '${_fieldType(hostDatatype)} ${_makeInstanceVariableName(field)};');
        }
      });
    }, nestCount: 0);
    indent.newln();
  }

  @override
  void writeGeneralCodec(
    CppOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.newln();
    indent.write(
        'class $_codecSerializerName : public $_standardCodecSerializer ');
    indent.addScoped('{', '};', () {
      _writeAccessBlock(indent, _ClassAccess.public, () {
        _writeFunctionDeclaration(indent, _codecSerializerName,
            isConstructor: true);
        _writeFunctionDeclaration(indent, 'GetInstance',
            returnType: '$_codecSerializerName&',
            isStatic: true, inlineBody: () {
          indent.writeln('static $_codecSerializerName sInstance;');
          indent.writeln('return sInstance;');
        });
        indent.newln();
        _writeFunctionDeclaration(indent, 'WriteValue',
            returnType: _voidType,
            parameters: <String>[
              'const flutter::EncodableValue& value',
              'flutter::ByteStreamWriter* stream'
            ],
            isConst: true,
            isOverride: true);
      });
      indent.writeScoped(' protected:', '', () {
        _writeFunctionDeclaration(indent, 'ReadValueOfType',
            returnType: 'flutter::EncodableValue',
            parameters: <String>[
              'uint8_t type',
              'flutter::ByteStreamReader* stream'
            ],
            isConst: true,
            isOverride: true);
      });
    }, nestCount: 0);
    indent.newln();
  }

  @override
  void writeFlutterApi(
    CppOptions generatorOptions,
    Root root,
    Indent indent,
    AstFlutterApi api, {
    required String dartPackageName,
  }) {
    const List<String> generatedMessages = <String>[
      ' Generated class from Pigeon that represents Flutter messages that can be called from C++.'
    ];
    addDocumentationComments(indent, api.documentationComments, _docCommentSpec,
        generatorComments: generatedMessages);
    indent.write('class ${api.name} ');
    indent.addScoped('{', '};', () {
      _writeAccessBlock(indent, _ClassAccess.public, () {
        _writeFunctionDeclaration(indent, api.name, parameters: <String>[
          'flutter::BinaryMessenger* binary_messenger',
        ]);
        _writeFunctionDeclaration(indent, api.name, parameters: <String>[
          'flutter::BinaryMessenger* binary_messenger',
          'const std::string& message_channel_suffix',
        ]);
        _writeFunctionDeclaration(indent, 'GetCodec',
            returnType: 'const flutter::StandardMessageCodec&', isStatic: true);
        for (final Method func in api.methods) {
          final HostDatatype returnType =
              getHostDatatype(func.returnType, _baseCppTypeForBuiltinDartType);
          addDocumentationComments(
              indent, func.documentationComments, _docCommentSpec);

          final Iterable<String> argTypes =
              func.parameters.map((NamedType arg) {
            final HostDatatype hostType =
                getFieldHostDatatype(arg, _baseCppTypeForBuiltinDartType);
            return _flutterApiArgumentType(hostType);
          });
          final Iterable<String> argNames =
              indexMap(func.parameters, _getArgumentName);
          final List<String> parameters = <String>[
            ...map2(argTypes, argNames, (String x, String y) => '$x $y'),
            ..._flutterApiCallbackParameters(returnType),
          ];
          _writeFunctionDeclaration(indent, _makeMethodName(func),
              returnType: _voidType, parameters: parameters);
        }
      });
      indent.addScoped(' private:', null, () {
        indent.writeln('flutter::BinaryMessenger* binary_messenger_;');
        indent.writeln('std::string message_channel_suffix_;');
      });
    }, nestCount: 0);
    indent.newln();
  }

  @override
  void writeHostApi(
    CppOptions generatorOptions,
    Root root,
    Indent indent,
    AstHostApi api, {
    required String dartPackageName,
  }) {
    const List<String> generatedMessages = <String>[
      ' Generated interface from Pigeon that represents a handler of messages from Flutter.'
    ];
    addDocumentationComments(indent, api.documentationComments, _docCommentSpec,
        generatorComments: generatedMessages);
    indent.write('class ${api.name} ');
    indent.addScoped('{', '};', () {
      _writeAccessBlock(indent, _ClassAccess.public, () {
        // Prevent copying/assigning.
        _writeFunctionDeclaration(indent, api.name,
            parameters: <String>['const ${api.name}&'], deleted: true);
        _writeFunctionDeclaration(indent, 'operator=',
            returnType: '${api.name}&',
            parameters: <String>['const ${api.name}&'],
            deleted: true);
        // No-op virtual destructor.
        _writeFunctionDeclaration(indent, '~${api.name}',
            isVirtual: true, inlineNoop: true);
        for (final Method method in api.methods) {
          final HostDatatype returnType = getHostDatatype(
              method.returnType, _baseCppTypeForBuiltinDartType);
          final String returnTypeName = _hostApiReturnType(returnType);

          final List<String> parameters = <String>[];
          if (method.parameters.isNotEmpty) {
            final Iterable<String> argTypes =
                method.parameters.map((NamedType arg) {
              final HostDatatype hostType =
                  getFieldHostDatatype(arg, _baseCppTypeForBuiltinDartType);
              return _hostApiArgumentType(hostType);
            });
            final Iterable<String> argNames =
                method.parameters.map((NamedType e) => _makeVariableName(e));
            parameters.addAll(
                map2(argTypes, argNames, (String argType, String argName) {
              return '$argType $argName';
            }));
          }

          addDocumentationComments(
              indent, method.documentationComments, _docCommentSpec);
          final String methodReturn;
          if (method.isAsynchronous) {
            methodReturn = _voidType;
            parameters.add('std::function<void($returnTypeName reply)> result');
          } else {
            methodReturn = returnTypeName;
          }
          _writeFunctionDeclaration(indent, _makeMethodName(method),
              returnType: methodReturn,
              parameters: parameters,
              isVirtual: true,
              isPureVirtual: true);
        }
        indent.newln();
        indent.writeln('$_commentPrefix The codec used by ${api.name}.');
        _writeFunctionDeclaration(indent, 'GetCodec',
            returnType: 'const flutter::StandardMessageCodec&', isStatic: true);
        indent.writeln(
            '$_commentPrefix Sets up an instance of `${api.name}` to handle messages through the `binary_messenger`.');
        _writeFunctionDeclaration(indent, 'SetUp',
            returnType: _voidType,
            isStatic: true,
            parameters: <String>[
              'flutter::BinaryMessenger* binary_messenger',
              '${api.name}* api',
            ]);
        _writeFunctionDeclaration(indent, 'SetUp',
            returnType: _voidType,
            isStatic: true,
            parameters: <String>[
              'flutter::BinaryMessenger* binary_messenger',
              '${api.name}* api',
              'const std::string& message_channel_suffix',
            ]);
        _writeFunctionDeclaration(indent, 'WrapError',
            returnType: 'flutter::EncodableValue',
            isStatic: true,
            parameters: <String>['std::string_view error_message']);
        _writeFunctionDeclaration(indent, 'WrapError',
            returnType: 'flutter::EncodableValue',
            isStatic: true,
            parameters: <String>['const FlutterError& error']);
      });
      _writeAccessBlock(indent, _ClassAccess.protected, () {
        indent.writeln('${api.name}() = default;');
      });
    }, nestCount: 0);
  }

  void _writeClassConstructor(Root root, Indent indent, Class classDefinition,
      Iterable<NamedType> params, String docComment) {
    final List<String> paramStrings = params.map((NamedType param) {
      final HostDatatype hostDatatype =
          getFieldHostDatatype(param, _baseCppTypeForBuiltinDartType);
      return '${_hostApiArgumentType(hostDatatype)} ${_makeVariableName(param)}';
    }).toList();
    indent.writeln('$_commentPrefix $docComment');
    _writeFunctionDeclaration(indent, classDefinition.name,
        isConstructor: true, parameters: paramStrings);
    indent.newln();
  }

  void _writeFlutterError(Indent indent) {
    indent.format('''

class FlutterError {
 public:
\texplicit FlutterError(const std::string& code)
\t\t: code_(code) {}
\texplicit FlutterError(const std::string& code, const std::string& message)
\t\t: code_(code), message_(message) {}
\texplicit FlutterError(const std::string& code, const std::string& message, const flutter::EncodableValue& details)
\t\t: code_(code), message_(message), details_(details) {}

\tconst std::string& code() const { return code_; }
\tconst std::string& message() const { return message_; }
\tconst flutter::EncodableValue& details() const { return details_; }

 private:
\tstd::string code_;
\tstd::string message_;
\tflutter::EncodableValue details_;
};''');
  }

  void _writeErrorOr(Indent indent,
      {Iterable<String> friends = const <String>[]}) {
    final String friendLines = friends
        .map((String className) => '\tfriend class $className;')
        .join('\n');
    indent.format('''

template<class T> class ErrorOr {
 public:
\tErrorOr(const T& rhs) : v_(rhs) {}
\tErrorOr(const T&& rhs) : v_(std::move(rhs)) {}
\tErrorOr(const FlutterError& rhs) : v_(rhs) {}
\tErrorOr(const FlutterError&& rhs) : v_(std::move(rhs)) {}

\tbool has_error() const { return std::holds_alternative<FlutterError>(v_); }
\tconst T& value() const { return std::get<T>(v_); };
\tconst FlutterError& error() const { return std::get<FlutterError>(v_); };

 private:
$friendLines
\tErrorOr() = default;
\tT TakeValue() && { return std::get<T>(std::move(v_)); }

\tstd::variant<T, FlutterError> v_;
};
''');
  }

  @override
  void writeCloseNamespace(
    CppOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (generatorOptions.namespace != null) {
      indent.writeln('}  // namespace ${generatorOptions.namespace}');
    }
    final String guardName = _getGuardName(generatorOptions.headerIncludePath);
    indent.writeln('#endif  // $guardName');
  }
}

/// Writes C++ source (.cpp) file to sink.
class CppSourceGenerator extends StructuredGenerator<CppOptions> {
  /// Constructor.
  const CppSourceGenerator();

  @override
  void writeFilePrologue(
    CppOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (generatorOptions.copyrightHeader != null) {
      addLines(indent, generatorOptions.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('$_commentPrefix ${getGeneratedCodeWarning()}');
    indent.writeln('$_commentPrefix $seeAlsoWarning');
    indent.newln();
    indent.addln('#undef _HAS_EXCEPTIONS');
    indent.newln();
  }

  @override
  void writeFileImports(
    CppOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.writeln('#include "${generatorOptions.headerIncludePath}"');
    indent.newln();
    _writeSystemHeaderIncludeBlock(indent, <String>[
      'flutter/basic_message_channel.h',
      'flutter/binary_messenger.h',
      'flutter/encodable_value.h',
      'flutter/standard_message_codec.h',
    ]);
    indent.newln();
    _writeSystemHeaderIncludeBlock(indent, <String>[
      'map',
      'string',
      'optional',
    ]);
    indent.newln();
  }

  @override
  void writeOpenNamespace(
    CppOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (generatorOptions.namespace != null) {
      indent.writeln('namespace ${generatorOptions.namespace} {');
    }
  }

  @override
  void writeGeneralUtilities(
    CppOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    final List<String> usingDirectives = <String>[
      'flutter::BasicMessageChannel',
      'flutter::CustomEncodableValue',
      'flutter::EncodableList',
      'flutter::EncodableMap',
      'flutter::EncodableValue',
    ];
    usingDirectives.sort();
    for (final String using in usingDirectives) {
      indent.writeln('using $using;');
    }
    indent.newln();
    _writeFunctionDefinition(indent, 'CreateConnectionError',
        returnType: 'FlutterError',
        parameters: <String>['const std::string channel_name'], body: () {
      indent.format('''
  return FlutterError(
      "channel-error",
      "Unable to establish connection on channel: '" + channel_name + "'.",
      EncodableValue(""));''');
    });
  }

  @override
  void writeDataClass(
    CppOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    indent.writeln('$_commentPrefix ${classDefinition.name}');
    indent.newln();

    final Iterable<NamedType> orderedFields =
        getFieldsInSerializationOrder(classDefinition);
    final Iterable<NamedType> requiredFields =
        orderedFields.where((NamedType type) => !type.type.isNullable);
    // Minimal constructor, if needed.
    if (requiredFields.length != orderedFields.length) {
      _writeClassConstructor(root, indent, classDefinition, requiredFields);
    }
    // All-field constructor.
    _writeClassConstructor(root, indent, classDefinition, orderedFields);

    // Custom copy/assign to handle pointer fields, if necessary.
    if (orderedFields.any((NamedType field) => _isPointerField(
        getFieldHostDatatype(field, _baseCppTypeForBuiltinDartType)))) {
      _writeCopyConstructor(root, indent, classDefinition, orderedFields);
      _writeAssignmentOperator(root, indent, classDefinition, orderedFields);
    }

    // Getters and setters.
    for (final NamedType field in orderedFields) {
      _writeCppSourceClassField(
          generatorOptions, root, indent, classDefinition, field);
    }

    // Serialization.
    writeClassEncode(
      generatorOptions,
      root,
      indent,
      classDefinition,
      dartPackageName: dartPackageName,
    );

    // Deserialization.
    writeClassDecode(
      generatorOptions,
      root,
      indent,
      classDefinition,
      dartPackageName: dartPackageName,
    );
  }

  @override
  void writeClassEncode(
    CppOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    _writeFunctionDefinition(indent, 'ToEncodableList',
        scope: classDefinition.name,
        returnType: 'EncodableList',
        isConst: true, body: () {
      indent.writeln('EncodableList list;');
      indent.writeln('list.reserve(${classDefinition.fields.length});');
      for (final NamedType field
          in getFieldsInSerializationOrder(classDefinition)) {
        final HostDatatype hostDatatype =
            getFieldHostDatatype(field, _shortBaseCppTypeForBuiltinDartType);
        final String encodableValue = _wrappedHostApiArgumentExpression(
          root,
          _makeInstanceVariableName(field),
          field.type,
          hostDatatype,
          true,
        );
        indent.writeln('list.push_back($encodableValue);');
      }
      indent.writeln('return list;');
    });
  }

  @override
  void writeClassDecode(
    CppOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    // Returns the expression to convert the given EncodableValue to a field
    // value.
    String getValueExpression(NamedType field, String encodable) {
      if (field.type.baseName == 'Object') {
        return encodable;
      } else {
        final HostDatatype hostDatatype =
            getFieldHostDatatype(field, _shortBaseCppTypeForBuiltinDartType);
        if (field.type.isClass || field.type.isEnum) {
          return _classReferenceFromEncodableValue(hostDatatype, encodable);
        } else {
          return 'std::get<${hostDatatype.datatype}>($encodable)';
        }
      }
    }

    _writeFunctionDefinition(indent, 'FromEncodableList',
        scope: classDefinition.name,
        returnType: classDefinition.name,
        parameters: <String>['const EncodableList& list'], body: () {
      const String instanceVariable = 'decoded';
      final Iterable<_IndexedField> indexedFields = indexMap(
          getFieldsInSerializationOrder(classDefinition),
          (int index, NamedType field) => _IndexedField(index, field));
      final Iterable<_IndexedField> nullableFields = indexedFields
          .where((_IndexedField field) => field.field.type.isNullable);
      final Iterable<_IndexedField> nonNullableFields = indexedFields
          .where((_IndexedField field) => !field.field.type.isNullable);

      // Non-nullable fields must be set via the constructor.
      String constructorArgs = nonNullableFields
          .map((_IndexedField param) =>
              getValueExpression(param.field, 'list[${param.index}]'))
          .join(',\n\t');
      if (constructorArgs.isNotEmpty) {
        constructorArgs = '(\n\t$constructorArgs)';
      }
      indent
          .format('${classDefinition.name} $instanceVariable$constructorArgs;');

      // Add the nullable fields via setters, since converting the encodable
      // values to the pointer types that the convenience constructor uses for
      // nullable fields is non-trivial.
      for (final _IndexedField entry in nullableFields) {
        final NamedType field = entry.field;
        final String setterName = _makeSetterName(field);
        final String encodableFieldName =
            '${_encodablePrefix}_${_makeVariableName(field)}';
        indent.writeln('auto& $encodableFieldName = list[${entry.index}];');

        final String valueExpression =
            getValueExpression(field, encodableFieldName);
        indent.writeScoped('if (!$encodableFieldName.IsNull()) {', '}', () {
          indent.writeln('$instanceVariable.$setterName($valueExpression);');
        });
      }

      // This returns by value, relying on copy elision, since it makes the
      // usage more convenient during deserialization than it would be with
      // explicit transfer via unique_ptr.
      indent.writeln('return $instanceVariable;');
    });
  }

  void _writeCodecOverflowUtilities(
    CppOptions generatorOptions,
    Root root,
    Indent indent,
    List<EnumeratedType> types, {
    required String dartPackageName,
  }) {
    _writeClassConstructor(root, indent, _overflowClass, _overflowFields);
    // Getters and setters.
    for (final NamedType field in _overflowFields) {
      _writeCppSourceClassField(
          generatorOptions, root, indent, _overflowClass, field);
    }
    // Serialization.
    writeClassEncode(
      generatorOptions,
      root,
      indent,
      _overflowClass,
      dartPackageName: dartPackageName,
    );

    indent.format('''
EncodableValue $_overflowClassName::FromEncodableList(
    const EncodableList& list) {
  return $_overflowClassName(list[0].LongValue(),
                                list[1].IsNull() ? EncodableValue() : list[1])
      .Unwrap();
}''');

    indent.writeScoped('EncodableValue $_overflowClassName::Unwrap() {', '}',
        () {
      indent.writeScoped('if (wrapped_.IsNull()) {', '}', () {
        indent.writeln('return EncodableValue();');
      });
      indent.writeScoped('switch(type_) {', '}', () {
        for (int i = totalCustomCodecKeysAllowed; i < types.length; i++) {
          indent.write('case ${types[i].enumeration - maximumCodecFieldKey}: ');
          _writeCodecDecode(indent, types[i], 'wrapped_');
        }
      });
      indent.writeln('return EncodableValue();');
    });
  }

  void _writeCodecDecode(
      Indent indent, EnumeratedType customType, String value) {
    indent.addScoped('{', '}', () {
      if (customType.type == CustomTypes.customClass) {
        if (customType.name == _overflowClassName) {
          indent.writeln(
              'return ${customType.name}::FromEncodableList(std::get<EncodableList>($value));');
        } else {
          indent.writeln(
              'return CustomEncodableValue(${customType.name}::FromEncodableList(std::get<EncodableList>($value)));');
        }
      } else if (customType.type == CustomTypes.customEnum) {
        indent.writeln('const auto& encodable_enum_arg = $value;');
        indent.writeln(
            'const int64_t enum_arg_value = encodable_enum_arg.IsNull() ? 0 : encodable_enum_arg.LongValue();');
        indent.writeln(
            'return encodable_enum_arg.IsNull() ? EncodableValue() : CustomEncodableValue(static_cast<${customType.name}>(enum_arg_value));');
      }
    });
  }

  @override
  void writeGeneralCodec(
    CppOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    final List<EnumeratedType> enumeratedTypes =
        getEnumeratedTypes(root).toList();
    indent.newln();
    if (root.requiresOverflowClass) {
      _writeCodecOverflowUtilities(
          generatorOptions, root, indent, enumeratedTypes,
          dartPackageName: dartPackageName);
    }
    _writeFunctionDefinition(indent, _codecSerializerName,
        scope: _codecSerializerName);
    _writeFunctionDefinition(indent, 'ReadValueOfType',
        scope: _codecSerializerName,
        returnType: 'EncodableValue',
        parameters: <String>[
          'uint8_t type',
          'flutter::ByteStreamReader* stream',
        ],
        isConst: true, body: () {
      if (enumeratedTypes.isNotEmpty) {
        indent.writeln('switch (type) {');
        indent.inc();
        for (final EnumeratedType customType in enumeratedTypes) {
          if (customType.enumeration < maximumCodecFieldKey) {
            indent.write('case ${customType.enumeration}: ');
            indent.nest(1, () {
              _writeCodecDecode(indent, customType, 'ReadValue(stream)');
            });
          }
        }
        if (root.requiresOverflowClass) {
          indent.write('case $maximumCodecFieldKey:');
          _writeCodecDecode(indent, _enumeratedOverflow, 'ReadValue(stream)');
        }
        indent.writeln('default:');
        indent.inc();
      }
      indent.writeln(
          'return $_standardCodecSerializer::ReadValueOfType(type, stream);');
      if (enumeratedTypes.isNotEmpty) {
        indent.dec();
        indent.writeln('}');
        indent.dec();
      }
    });
    _writeFunctionDefinition(indent, 'WriteValue',
        scope: _codecSerializerName,
        returnType: _voidType,
        parameters: <String>[
          'const EncodableValue& value',
          'flutter::ByteStreamWriter* stream',
        ],
        isConst: true, body: () {
      if (enumeratedTypes.isNotEmpty) {
        indent.write(
            'if (const CustomEncodableValue* custom_value = std::get_if<CustomEncodableValue>(&value)) ');
        indent.addScoped('{', '}', () {
          for (final EnumeratedType customType in enumeratedTypes) {
            final String encodeString = customType.type ==
                    CustomTypes.customClass
                ? 'std::any_cast<${customType.name}>(*custom_value).ToEncodableList()'
                : 'static_cast<int>(std::any_cast<${customType.name}>(*custom_value))';
            final String valueString =
                customType.enumeration < maximumCodecFieldKey
                    ? encodeString
                    : 'wrap.ToEncodableList()';
            final int enumeration =
                customType.enumeration < maximumCodecFieldKey
                    ? customType.enumeration
                    : maximumCodecFieldKey;
            indent.write(
                'if (custom_value->type() == typeid(${customType.name})) ');
            indent.addScoped('{', '}', () {
              indent.writeln('stream->WriteByte($enumeration);');
              if (enumeration == maximumCodecFieldKey) {
                indent.writeln(
                    'const auto wrap = $_overflowClassName(${customType.enumeration - maximumCodecFieldKey}, $encodeString);');
              }
              indent
                  .writeln('WriteValue(EncodableValue($valueString), stream);');
              indent.writeln('return;');
            });
          }
        });
      }
      indent.writeln('$_standardCodecSerializer::WriteValue(value, stream);');
    });
  }

  @override
  void writeFlutterApi(
    CppOptions generatorOptions,
    Root root,
    Indent indent,
    AstFlutterApi api, {
    required String dartPackageName,
  }) {
    indent.writeln(
        '$_commentPrefix Generated class from Pigeon that represents Flutter messages that can be called from C++.');
    _writeFunctionDefinition(
      indent,
      api.name,
      scope: api.name,
      parameters: <String>[
        'flutter::BinaryMessenger* binary_messenger',
      ],
      initializers: <String>[
        'binary_messenger_(binary_messenger)',
        'message_channel_suffix_("")'
      ],
    );
    _writeFunctionDefinition(
      indent,
      api.name,
      scope: api.name,
      parameters: <String>[
        'flutter::BinaryMessenger* binary_messenger',
        'const std::string& message_channel_suffix'
      ],
      initializers: <String>[
        'binary_messenger_(binary_messenger)',
        'message_channel_suffix_(message_channel_suffix.length() > 0 ? std::string(".") + message_channel_suffix : "")'
      ],
    );
    _writeFunctionDefinition(
      indent,
      'GetCodec',
      scope: api.name,
      returnType: 'const flutter::StandardMessageCodec&',
      body: () {
        indent.writeln(
            'return flutter::StandardMessageCodec::GetInstance(&$_codecSerializerName::GetInstance());');
      },
    );
    for (final Method func in api.methods) {
      final HostDatatype returnType =
          getHostDatatype(func.returnType, _shortBaseCppTypeForBuiltinDartType);

      // Determine the input parameter list, saved in a structured form for later
      // use as platform channel call arguments.
      final Iterable<_HostNamedType> hostParameters =
          indexMap(func.parameters, (int i, NamedType arg) {
        final HostDatatype hostType =
            getFieldHostDatatype(arg, _shortBaseCppTypeForBuiltinDartType);
        return _HostNamedType(_getSafeArgumentName(i, arg), hostType, arg.type);
      });
      final List<String> parameters = <String>[
        ...hostParameters.map((_HostNamedType arg) =>
            '${_flutterApiArgumentType(arg.hostType)} ${arg.name}'),
        ..._flutterApiCallbackParameters(returnType),
      ];
      _writeFunctionDefinition(indent, _makeMethodName(func),
          scope: api.name,
          returnType: _voidType,
          parameters: parameters, body: () {
        indent.writeln(
            'const std::string channel_name = "${makeChannelName(api, func, dartPackageName)}" + message_channel_suffix_;');
        indent.writeln('BasicMessageChannel<> channel(binary_messenger_, '
            'channel_name, &GetCodec());');

        // Convert arguments to EncodableValue versions.
        const String argumentListVariableName = 'encoded_api_arguments';
        indent.write('EncodableValue $argumentListVariableName = ');
        if (func.parameters.isEmpty) {
          indent.addln('EncodableValue();');
        } else {
          indent.addScoped('EncodableValue(EncodableList{', '});', () {
            for (final _HostNamedType param in hostParameters) {
              final String encodedArgument = _wrappedHostApiArgumentExpression(
                root,
                param.name,
                param.originalType,
                param.hostType,
                false,
              );
              indent.writeln('$encodedArgument,');
            }
          });
        }

        indent.write('channel.Send($argumentListVariableName, '
            // ignore: missing_whitespace_between_adjacent_strings
            '[channel_name, on_success = std::move(on_success), on_error = std::move(on_error)]'
            '(const uint8_t* reply, size_t reply_size) ');
        indent.addScoped('{', '});', () {
          String successCallbackArgument;
          successCallbackArgument = 'return_value';
          final String encodedReplyName = 'encodable_$successCallbackArgument';
          final String listReplyName = 'list_$successCallbackArgument';
          indent.writeln(
              'std::unique_ptr<EncodableValue> response = GetCodec().DecodeMessage(reply, reply_size);');
          indent.writeln('const auto& $encodedReplyName = *response;');
          indent.writeln(
              'const auto* $listReplyName = std::get_if<EncodableList>(&$encodedReplyName);');
          indent.writeScoped('if ($listReplyName) {', '} ', () {
            indent.writeScoped('if ($listReplyName->size() > 1) {', '} ', () {
              indent.writeln(
                  'on_error(FlutterError(std::get<std::string>($listReplyName->at(0)), std::get<std::string>($listReplyName->at(1)), $listReplyName->at(2)));');
            }, addTrailingNewline: false);
            indent.addScoped('else {', '}', () {
              if (func.returnType.isVoid) {
                successCallbackArgument = '';
              } else {
                _writeEncodableValueArgumentUnwrapping(
                  indent,
                  root,
                  returnType,
                  argName: successCallbackArgument,
                  encodableArgName: '$listReplyName->at(0)',
                  apiType: ApiType.flutter,
                );
              }
              indent.writeln('on_success($successCallbackArgument);');
            });
          }, addTrailingNewline: false);
          indent.addScoped('else {', '} ', () {
            indent.writeln('on_error(CreateConnectionError(channel_name));');
          });
        });
      });
    }
  }

  @override
  void writeHostApi(
    CppOptions generatorOptions,
    Root root,
    Indent indent,
    AstHostApi api, {
    required String dartPackageName,
  }) {
    indent.writeln('/// The codec used by ${api.name}.');
    _writeFunctionDefinition(indent, 'GetCodec',
        scope: api.name,
        returnType: 'const flutter::StandardMessageCodec&', body: () {
      indent.writeln(
          'return flutter::StandardMessageCodec::GetInstance(&$_codecSerializerName::GetInstance());');
    });
    indent.writeln(
        '$_commentPrefix Sets up an instance of `${api.name}` to handle messages through the `binary_messenger`.');
    _writeFunctionDefinition(
      indent,
      'SetUp',
      scope: api.name,
      returnType: _voidType,
      parameters: <String>[
        'flutter::BinaryMessenger* binary_messenger',
        '${api.name}* api',
      ],
      body: () {
        indent.writeln('${api.name}::SetUp(binary_messenger, api, "");');
      },
    );
    _writeFunctionDefinition(indent, 'SetUp',
        scope: api.name,
        returnType: _voidType,
        parameters: <String>[
          'flutter::BinaryMessenger* binary_messenger',
          '${api.name}* api',
          'const std::string& message_channel_suffix',
        ], body: () {
      indent.writeln(
          'const std::string prepended_suffix = message_channel_suffix.length() > 0 ? std::string(".") + message_channel_suffix : "";');
      for (final Method method in api.methods) {
        final String channelName =
            makeChannelName(api, method, dartPackageName);
        indent.writeScoped('{', '}', () {
          indent.writeln('BasicMessageChannel<> channel(binary_messenger, '
              '"$channelName" + prepended_suffix, &GetCodec());');
          indent.writeScoped('if (api != nullptr) {', '} else {', () {
            indent.write(
                'channel.SetMessageHandler([api](const EncodableValue& message, const flutter::MessageReply<EncodableValue>& reply) ');
            indent.addScoped('{', '});', () {
              indent.writeScoped('try {', '}', () {
                final List<String> methodArgument = <String>[];
                if (method.parameters.isNotEmpty) {
                  indent.writeln(
                      'const auto& args = std::get<EncodableList>(message);');

                  enumerate(method.parameters, (int index, NamedType arg) {
                    final HostDatatype hostType = getHostDatatype(
                        arg.type,
                        (TypeDeclaration x) =>
                            _shortBaseCppTypeForBuiltinDartType(x));
                    final String argName = _getSafeArgumentName(index, arg);

                    final String encodableArgName =
                        '${_encodablePrefix}_$argName';
                    indent.writeln(
                        'const auto& $encodableArgName = args.at($index);');
                    if (!arg.type.isNullable) {
                      indent.writeScoped(
                          'if ($encodableArgName.IsNull()) {', '}', () {
                        indent.writeln(
                            'reply(WrapError("$argName unexpectedly null."));');
                        indent.writeln('return;');
                      });
                    }
                    _writeEncodableValueArgumentUnwrapping(
                      indent,
                      root,
                      hostType,
                      argName: argName,
                      encodableArgName: encodableArgName,
                      apiType: ApiType.host,
                    );
                    final String unwrapEnum =
                        arg.type.isEnum && arg.type.isNullable
                            ? ' ? &(*$argName) : nullptr'
                            : '';
                    methodArgument.add('$argName$unwrapEnum');
                  });
                }

                final HostDatatype returnType = getHostDatatype(
                    method.returnType, _shortBaseCppTypeForBuiltinDartType);
                final String returnTypeName = _hostApiReturnType(returnType);
                if (method.isAsynchronous) {
                  methodArgument.add(
                    '[reply]($returnTypeName&& output) {${indent.newline}'
                    '${_wrapResponse(indent, root, method.returnType, prefix: '\t')}${indent.newline}'
                    '}',
                  );
                }
                final String call =
                    'api->${_makeMethodName(method)}(${methodArgument.join(', ')})';
                if (method.isAsynchronous) {
                  indent.format('$call;');
                } else {
                  indent.writeln('$returnTypeName output = $call;');
                  indent.format(_wrapResponse(indent, root, method.returnType));
                }
              }, addTrailingNewline: false);
              indent.add(' catch (const std::exception& exception) ');
              indent.addScoped('{', '}', () {
                // There is a potential here for `reply` to be called twice, which
                // is a violation of the API contract, because there's no way of
                // knowing whether or not the plugin code called `reply` before
                // throwing. Since use of `@async` suggests that the reply is
                // probably not sent within the scope of the stack, err on the
                // side of potential double-call rather than no call (which is
                // also an API violation) so that unexpected errors have a better
                // chance of being caught and handled in a useful way.
                indent.writeln('reply(WrapError(exception.what()));');
              });
            });
          });
          indent.addScoped(null, '}', () {
            indent.writeln('channel.SetMessageHandler(nullptr);');
          });
        });
      }
    });

    _writeFunctionDefinition(indent, 'WrapError',
        scope: api.name,
        returnType: 'EncodableValue',
        parameters: <String>['std::string_view error_message'], body: () {
      indent.format('''
return EncodableValue(EncodableList{
\tEncodableValue(std::string(error_message)),
\tEncodableValue("Error"),
\tEncodableValue()
});''');
    });
    _writeFunctionDefinition(indent, 'WrapError',
        scope: api.name,
        returnType: 'EncodableValue',
        parameters: <String>['const FlutterError& error'], body: () {
      indent.format('''
return EncodableValue(EncodableList{
\tEncodableValue(error.code()),
\tEncodableValue(error.message()),
\terror.details()
});''');
    });
  }

  void _writeClassConstructor(Root root, Indent indent, Class classDefinition,
      Iterable<NamedType> params) {
    final Iterable<_HostNamedType> hostParams = params.map((NamedType param) {
      return _HostNamedType(
        _makeVariableName(param),
        getFieldHostDatatype(
          param,
          _shortBaseCppTypeForBuiltinDartType,
        ),
        param.type,
      );
    });

    final List<String> paramStrings = hostParams
        .map((_HostNamedType param) =>
            '${_hostApiArgumentType(param.hostType)} ${param.name}')
        .toList();
    final List<String> initializerStrings = hostParams
        .map((_HostNamedType param) =>
            '${param.name}_(${_fieldValueExpression(param.hostType, param.name)})')
        .toList();
    _writeFunctionDefinition(indent, classDefinition.name,
        scope: classDefinition.name,
        parameters: paramStrings,
        initializers: initializerStrings);
  }

  void _writeCopyConstructor(Root root, Indent indent, Class classDefinition,
      Iterable<NamedType> fields) {
    final List<String> initializerStrings = fields.map((NamedType param) {
      final String fieldName = _makeInstanceVariableName(param);
      final HostDatatype hostType = getFieldHostDatatype(
        param,
        _shortBaseCppTypeForBuiltinDartType,
      );
      return '$fieldName(${_fieldValueExpression(hostType, 'other.$fieldName', sourceIsField: true)})';
    }).toList();
    _writeFunctionDefinition(indent, classDefinition.name,
        scope: classDefinition.name,
        parameters: <String>['const ${classDefinition.name}& other'],
        initializers: initializerStrings);
  }

  void _writeAssignmentOperator(Root root, Indent indent, Class classDefinition,
      Iterable<NamedType> fields) {
    _writeFunctionDefinition(indent, 'operator=',
        scope: classDefinition.name,
        returnType: '${classDefinition.name}&',
        parameters: <String>['const ${classDefinition.name}& other'], body: () {
      for (final NamedType field in fields) {
        final HostDatatype hostDatatype =
            getFieldHostDatatype(field, _shortBaseCppTypeForBuiltinDartType);

        final String ivarName = _makeInstanceVariableName(field);
        final String otherIvar = 'other.$ivarName';
        final String valueExpression;
        if (_isPointerField(hostDatatype)) {
          final String constructor =
              'std::make_unique<${hostDatatype.datatype}>(*$otherIvar)';
          valueExpression = hostDatatype.isNullable
              ? '$otherIvar ? $constructor : nullptr'
              : constructor;
        } else {
          valueExpression = otherIvar;
        }
        indent.writeln('$ivarName = $valueExpression;');
      }
      indent.writeln('return *this;');
    });
  }

  void _writeCppSourceClassField(CppOptions generatorOptions, Root root,
      Indent indent, Class classDefinition, NamedType field) {
    final HostDatatype hostDatatype =
        getFieldHostDatatype(field, _shortBaseCppTypeForBuiltinDartType);
    final String instanceVariableName = _makeInstanceVariableName(field);
    final String setterName = _makeSetterName(field);
    final String returnExpression;
    if (_isPointerField(hostDatatype)) {
      // Convert std::unique_ptr<T> to either T* or const T&.
      returnExpression = hostDatatype.isNullable
          ? '$instanceVariableName.get()'
          : '*$instanceVariableName';
    } else if (hostDatatype.isNullable) {
      // Convert std::optional<T> to T*.
      returnExpression =
          '$instanceVariableName ? &(*$instanceVariableName) : nullptr';
    } else {
      returnExpression = instanceVariableName;
    }

    // Writes a setter treating the type as [type], to allow generating multiple
    // setter variants.
    void writeSetter(HostDatatype type) {
      const String setterArgumentName = 'value_arg';
      _writeFunctionDefinition(
        indent,
        setterName,
        scope: classDefinition.name,
        returnType: _voidType,
        parameters: <String>[
          '${_unownedArgumentType(type)} $setterArgumentName'
        ],
        body: () {
          indent.writeln(
              '$instanceVariableName = ${_fieldValueExpression(type, setterArgumentName)};');
        },
      );
    }

    _writeFunctionDefinition(
      indent,
      _makeGetterName(field),
      scope: classDefinition.name,
      returnType: _getterReturnType(hostDatatype),
      isConst: true,
      body: () {
        indent.writeln('return $returnExpression;');
      },
    );
    writeSetter(hostDatatype);
    if (hostDatatype.isNullable) {
      // Write the non-nullable variant; see _writeCppHeaderDataClass.
      writeSetter(_nonNullableType(hostDatatype));
    }

    indent.newln();
  }

  /// Returns the value to use when setting a field of the given type from
  /// an argument of that type.
  ///
  /// For non-nullable and non-custom-class values this is just the variable
  /// itself, but for other values this handles the conversion between an
  /// argument type (a pointer or value/reference) and the field type
  /// (a std::optional or std::unique_ptr).
  String _fieldValueExpression(HostDatatype type, String variable,
      {bool sourceIsField = false}) {
    if (_isPointerField(type)) {
      final String constructor = 'std::make_unique<${type.datatype}>';
      // If the source is a pointer field, it always needs dereferencing.
      final String maybeDereference = sourceIsField ? '*' : '';
      return type.isNullable
          ? '$variable ? $constructor(*$variable) : nullptr'
          : '$constructor($maybeDereference$variable)';
    }
    return type.isNullable
        ? '$variable ? ${_valueType(type)}(*$variable) : std::nullopt'
        : variable;
  }

  String _wrapResponse(Indent indent, Root root, TypeDeclaration returnType,
      {String prefix = ''}) {
    final String nonErrorPath;
    final String errorCondition;
    final String errorGetter;

    const String nullValue = 'EncodableValue()';
    if (returnType.isVoid) {
      nonErrorPath = '${prefix}wrapped.push_back($nullValue);';
      errorCondition = 'output.has_value()';
      errorGetter = 'value';
    } else {
      final HostDatatype hostType =
          getHostDatatype(returnType, _shortBaseCppTypeForBuiltinDartType);

      const String extractedValue = 'std::move(output).TakeValue()';
      final String wrapperType =
          hostType.isBuiltin ? 'EncodableValue' : 'CustomEncodableValue';
      if (returnType.isNullable) {
        // The value is a std::optional, so needs an extra layer of
        // handling.
        nonErrorPath = '''
${prefix}auto output_optional = $extractedValue;
${prefix}if (output_optional) {
$prefix\twrapped.push_back($wrapperType(std::move(output_optional).value()));
$prefix} else {
$prefix\twrapped.push_back($nullValue);
$prefix}''';
      } else {
        nonErrorPath =
            '${prefix}wrapped.push_back($wrapperType($extractedValue));';
      }
      errorCondition = 'output.has_error()';
      errorGetter = 'error';
    }
    // Ideally this code would use an initializer list to create
    // an EncodableList inline, which would be less code. However,
    // that would always copy the element, so the slightly more
    // verbose create-and-push approach is used instead.
    return '''
${prefix}if ($errorCondition) {
$prefix\treply(WrapError(output.$errorGetter()));
$prefix\treturn;
$prefix}
${prefix}EncodableList wrapped;
$nonErrorPath
${prefix}reply(EncodableValue(std::move(wrapped)));''';
  }

  @override
  void writeCloseNamespace(
    CppOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (generatorOptions.namespace != null) {
      indent.writeln('}  // namespace ${generatorOptions.namespace}');
    }
  }

  /// Returns the expression to create an EncodableValue from a host API argument
  /// with the given [variableName] and types.
  String _wrappedHostApiArgumentExpression(
    Root root,
    String variableName,
    TypeDeclaration dartType,
    HostDatatype hostType,
    bool isNestedClass,
  ) {
    final String encodableValue;
    if (!hostType.isBuiltin) {
      final String nonNullValue =
          hostType.isNullable || (!hostType.isEnum && isNestedClass)
              ? '*$variableName'
              : variableName;
      encodableValue = 'CustomEncodableValue($nonNullValue)';
    } else if (dartType.baseName == 'Object') {
      final String operator = hostType.isNullable ? '*' : '';
      encodableValue = '$operator$variableName';
    } else {
      final String operator = hostType.isNullable ? '*' : '';
      encodableValue = 'EncodableValue($operator$variableName)';
    }

    if (hostType.isNullable) {
      return '$variableName ? $encodableValue : EncodableValue()';
    }
    return encodableValue;
  }

  /// Writes the code to declare and populate a variable of type [hostType]
  /// called [argName] to use as a parameter to an API method call, from an
  /// existing EncodableValue variable called [encodableArgName].
  void _writeEncodableValueArgumentUnwrapping(
    Indent indent,
    Root root,
    HostDatatype hostType, {
    required String argName,
    required String encodableArgName,
    required ApiType apiType,
  }) {
    if (hostType.isNullable) {
      // Nullable arguments are always pointers, with nullptr corresponding to
      // null.
      if (hostType.datatype == 'EncodableValue') {
        // Generic objects just pass the EncodableValue through directly.
        indent.writeln('const auto* $argName = &$encodableArgName;');
      } else if (hostType.isBuiltin) {
        indent.writeln(
            'const auto* $argName = std::get_if<${hostType.datatype}>(&$encodableArgName);');
      } else if (hostType.isEnum) {
        indent.format('''
${hostType.datatype} ${argName}_value;
const ${hostType.datatype}* $argName = nullptr;
if (!$encodableArgName.IsNull()) {
  ${argName}_value = ${_classReferenceFromEncodableValue(hostType, encodableArgName)};
  $argName = &${argName}_value;
}''');
      } else {
        indent.writeln(
            'const auto* $argName = $encodableArgName.IsNull() ? nullptr : &(${_classReferenceFromEncodableValue(hostType, encodableArgName)});');
      }
    } else {
      // Non-nullable arguments are either passed by value or reference, but the
      // extraction doesn't need to distinguish since those are the same at the
      // call site.
      if (hostType.datatype == 'int64_t') {
        // The EncodableValue will either be an int32_t or an int64_t depending
        // on the value, but the generated API requires an int64_t so that it can
        // handle any case.
        indent
            .writeln('const int64_t $argName = $encodableArgName.LongValue();');
      } else if (hostType.datatype == 'EncodableValue') {
        // Generic objects just pass the EncodableValue through directly. This
        // creates an alias just to avoid having to special-case the
        // argName/encodableArgName distinction at a higher level.
        indent.writeln('const auto& $argName = $encodableArgName;');
      } else if (hostType.isBuiltin) {
        indent.writeln(
            'const auto& $argName = std::get<${hostType.datatype}>($encodableArgName);');
      } else {
        indent.writeln(
            'const auto& $argName = ${_classReferenceFromEncodableValue(hostType, encodableArgName)};');
      }
    }
  }

  /// A wrapper for [_baseCppTypeForBuiltinDartType] that generated Flutter
  /// types without the namespace, since the implementation file uses `using`
  /// directives.
  String? _shortBaseCppTypeForBuiltinDartType(TypeDeclaration type) {
    return _baseCppTypeForBuiltinDartType(type, includeFlutterNamespace: false);
  }

  /// Returns the code to extract a `const {type.datatype}&` from an EncodableValue
  /// variable [variableName] that contains an instance of [type].
  String _classReferenceFromEncodableValue(
      HostDatatype type, String variableName) {
    return 'std::any_cast<const ${type.datatype}&>(std::get<CustomEncodableValue>($variableName))';
  }
}

/// Contains information about a host function argument.
///
/// This is comparable to a [NamedType], but has already gone through host type
/// and variable name mapping, and it tracks the original [NamedType] that it
/// was created from.
class _HostNamedType {
  const _HostNamedType(this.name, this.hostType, this.originalType);
  final String name;
  final HostDatatype hostType;
  final TypeDeclaration originalType;
}

/// Contains a class field and its serialization index.
class _IndexedField {
  const _IndexedField(this.index, this.field);
  final int index;
  final NamedType field;
}

const String _encodablePrefix = 'encodable';

String _getArgumentName(int count, NamedType argument) =>
    argument.name.isEmpty ? 'arg$count' : _makeVariableName(argument);

/// Returns an argument name that can be used in a context where it is possible to collide.
String _getSafeArgumentName(int count, NamedType argument) =>
    '${_getArgumentName(count, argument)}_arg';

/// Returns a non-nullable variant of [type].
HostDatatype _nonNullableType(HostDatatype type) {
  return HostDatatype(
    datatype: type.datatype,
    isBuiltin: type.isBuiltin,
    isNullable: false,
    isEnum: type.isEnum,
  );
}

String _pascalCaseFromCamelCase(String camelCase) =>
    camelCase[0].toUpperCase() + camelCase.substring(1);

String _snakeCaseFromCamelCase(String camelCase) {
  return camelCase.replaceAllMapped(RegExp(r'[A-Z]'),
      (Match m) => '${m.start == 0 ? '' : '_'}${m[0]!.toLowerCase()}');
}

String _pascalCaseFromSnakeCase(String snakeCase) {
  final String camelCase = snakeCase.replaceAllMapped(
      RegExp(r'_([a-z])'), (Match m) => m[1]!.toUpperCase());
  return _pascalCaseFromCamelCase(camelCase);
}

String _makeMethodName(Method method) => _pascalCaseFromCamelCase(method.name);

String _makeGetterName(NamedType field) => _snakeCaseFromCamelCase(field.name);

String _makeSetterName(NamedType field) =>
    'set_${_snakeCaseFromCamelCase(field.name)}';

String _makeVariableName(NamedType field) =>
    _snakeCaseFromCamelCase(field.name);

String _makeInstanceVariableName(NamedType field) =>
    '${_makeVariableName(field)}_';

// TODO(stuartmorgan): Remove this in favor of _isPodType once callers have
// all been updated to using HostDatatypes.
bool _isReferenceType(String dataType) {
  switch (dataType) {
    case 'bool':
    case 'int64_t':
    case 'double':
      return false;
    default:
      return true;
  }
}

/// Returns the parameters to use for the success and error callbacks in a
/// Flutter API function signature.
List<String> _flutterApiCallbackParameters(HostDatatype returnType) {
  return <String>[
    'std::function<void(${_flutterApiReturnType(returnType)})>&& on_success',
    'std::function<void(const FlutterError&)>&& on_error',
  ];
}

/// Returns true if [type] corresponds to a plain-old-data type (i.e., one that
/// should generally be passed by value rather than pointer/reference) in C++.
bool _isPodType(HostDatatype type) {
  return !_isReferenceType(type.datatype);
}

String? _baseCppTypeForBuiltinDartType(
  TypeDeclaration type, {
  bool includeFlutterNamespace = true,
}) {
  final String flutterNamespace = includeFlutterNamespace ? 'flutter::' : '';
  final Map<String, String> cppTypeForDartTypeMap = <String, String>{
    'void': 'void',
    'bool': 'bool',
    'int': 'int64_t',
    'String': 'std::string',
    'double': 'double',
    'Uint8List': 'std::vector<uint8_t>',
    'Int32List': 'std::vector<int32_t>',
    'Int64List': 'std::vector<int64_t>',
    'Float64List': 'std::vector<double>',
    'Map': '${flutterNamespace}EncodableMap',
    'List': '${flutterNamespace}EncodableList',
    'Object': '${flutterNamespace}EncodableValue',
  };
  if (cppTypeForDartTypeMap.containsKey(type.baseName)) {
    return cppTypeForDartTypeMap[type.baseName];
  } else {
    return null;
  }
}

/// Returns the C++ type to use in a value context (variable declaration,
/// pass-by-value, etc.) for the given C++ base type.
String _valueType(HostDatatype type) {
  final String baseType = type.datatype;
  return type.isNullable ? 'std::optional<$baseType>' : baseType;
}

/// Returns the C++ type to use when declaring a data class field for the
/// given type.
String _fieldType(HostDatatype type) {
  return _isPointerField(type)
      ? 'std::unique_ptr<${type.datatype}>'
      : _valueType(type);
}

/// Returns true if [type] should be stored as a pointer, rather than a
/// value type, in a data class.
bool _isPointerField(HostDatatype type) {
  // Custom class types are stored as `unique_ptr`s since they can have
  // arbitrary size, and can also be arbitrarily (including recursively)
  // nested, so must be stored as pointers.
  return !type.isBuiltin && !type.isEnum;
}

/// Returns the C++ type to use in an argument context without ownership
/// transfer for the given base type.
String _unownedArgumentType(HostDatatype type) {
  final bool isString = type.datatype == 'std::string';
  final String baseType = isString ? 'std::string_view' : type.datatype;
  if (isString || _isPodType(type)) {
    return type.isNullable ? 'const $baseType*' : baseType;
  }
  // TODO(stuartmorgan): Consider special-casing `Object?` here, so that there
  // aren't two ways of representing null (nullptr or an isNull EncodableValue).
  return type.isNullable ? 'const $baseType*' : 'const $baseType&';
}

/// Returns the C++ type to use for arguments to a host API. This is slightly
/// different from [_unownedArgumentType] since passing `std::string_view*` in
/// to the host API implementation when the actual type is `std::string*` is
/// needlessly complicated, so it uses `std::string` directly.
String _hostApiArgumentType(HostDatatype type) {
  final String baseType = type.datatype;
  if (_isPodType(type)) {
    return type.isNullable ? 'const $baseType*' : baseType;
  }
  return type.isNullable ? 'const $baseType*' : 'const $baseType&';
}

/// Returns the C++ type to use for arguments to a Flutter API.
String _flutterApiArgumentType(HostDatatype type) {
  // Nullable strings use std::string* rather than std::string_view*
  // since there's no implicit conversion for the pointer types, making them
  // more awkward to use. For consistency, and since EncodableValue will end
  // up making a std::string internally anyway, std::string is used for the
  // non-nullable case as well.
  if (type.datatype == 'std::string') {
    return type.isNullable ? 'const std::string*' : 'const std::string&';
  }
  return _unownedArgumentType(type);
}

/// Returns the C++ type to use for the return of a getter for a field of type
/// [type].
String _getterReturnType(HostDatatype type) {
  final String baseType = type.datatype;
  if (_isPodType(type)) {
    // Use pointers rather than optionals even for nullable POD, since the
    // semantics of using them is essentially identical and this makes them
    // consistent with non-POD.
    return type.isNullable ? 'const $baseType*' : baseType;
  }
  return type.isNullable ? 'const $baseType*' : 'const $baseType&';
}

/// Returns the C++ type to use for the return of a host API method returning
/// [type].
String _hostApiReturnType(HostDatatype type) {
  if (type.datatype == 'void') {
    return 'std::optional<FlutterError>';
  }
  String valueType = type.datatype;
  if (type.isNullable) {
    valueType = 'std::optional<$valueType>';
  }
  return 'ErrorOr<$valueType>';
}

/// Returns the C++ type to use for the paramer to the asynchronous "return"
/// callback of a Flutter API method returning [type].
String _flutterApiReturnType(HostDatatype type) {
  if (type.datatype == 'void') {
    return 'void';
  }
  // For anything other than void, handle it the same way as a host API argument
  // since it has the same basic structure of being a function defined by the
  // client, being called by the generated code.
  return _hostApiArgumentType(type);
}

String _getGuardName(String? headerFileName) {
  const String prefix = 'PIGEON_';
  if (headerFileName != null) {
    return '$prefix${headerFileName.replaceAll('.', '_').toUpperCase()}_';
  } else {
    return '${prefix}H_';
  }
}

void _writeSystemHeaderIncludeBlock(Indent indent, List<String> headers) {
  headers.sort();
  for (final String header in headers) {
    indent.writeln('#include <$header>');
  }
}

enum _FunctionOutputType { declaration, definition }

/// Writes a function declaration or definition to [indent].
///
/// If [parameters] are given, each should be a string of the form 'type name'.
void _writeFunction(
  Indent indent,
  _FunctionOutputType type, {
  required String name,
  String? returnType,
  String? scope,
  List<String> parameters = const <String>[],
  List<String> startingAnnotations = const <String>[],
  List<String> trailingAnnotations = const <String>[],
  List<String> initializers = const <String>[],
  void Function()? body,
}) {
  assert(body == null || type == _FunctionOutputType.definition);

  // Set the initial indentation.
  indent.write('');
  // Write any starting annotations (e.g., 'static').
  for (final String annotation in startingAnnotations) {
    indent.add('$annotation ');
  }
  // Write the signature.
  if (returnType != null) {
    indent.add('$returnType ');
  }
  if (scope != null) {
    indent.add('$scope::');
  }
  indent.add(name);
  // Write the parameters.
  if (parameters.isEmpty) {
    indent.add('()');
  } else if (parameters.length == 1) {
    indent.add('(${parameters.first})');
  } else {
    indent.addScoped('(', null, () {
      enumerate(parameters, (int index, final String param) {
        if (index == parameters.length - 1) {
          indent.write('$param)');
        } else {
          indent.writeln('$param,');
        }
      });
    }, addTrailingNewline: false);
  }
  // Write any trailing annotations (e.g., 'const').
  for (final String annotation in trailingAnnotations) {
    indent.add(' $annotation');
  }
  // Write the initializer list, if any.
  if (initializers.isNotEmpty) {
    indent.newln();
    indent.write(' : ');
    // The first item goes on the same line as the ":", the rest go on their
    // own lines indented two extra levels, with no comma or newline after the
    // last one. The easiest way to express the special casing of the first and
    // last is with a join+format.
    indent.format(initializers.join(',\n\t\t'),
        leadingSpace: false, trailingNewline: false);
  }
  // Write the body or end the declaration.
  if (type == _FunctionOutputType.declaration) {
    indent.addln(';');
  } else {
    if (body != null) {
      indent.addScoped(' {', '}', body);
    } else {
      indent.addln(' {}');
    }
  }
}

void _writeFunctionDeclaration(
  Indent indent,
  String name, {
  String? returnType,
  List<String> parameters = const <String>[],
  bool isStatic = false,
  bool isVirtual = false,
  bool isConstructor = false,
  bool isCopy = false,
  bool isPureVirtual = false,
  bool isConst = false,
  bool isOverride = false,
  bool deleted = false,
  bool defaultImpl = false,
  bool inlineNoop = false,
  bool noexcept = false,
  void Function()? inlineBody,
}) {
  assert(!(isVirtual && isOverride), 'virtual is redundant with override');
  assert(isVirtual || !isPureVirtual, 'pure virtual methods must be virtual');
  assert(returnType == null || !isConstructor,
      'constructors cannot have return types');
  assert(!(deleted && defaultImpl), 'a function cannot be deleted and default');
  _writeFunction(
    indent,
    inlineNoop || (inlineBody != null)
        ? _FunctionOutputType.definition
        : _FunctionOutputType.declaration,
    name: name,
    returnType: returnType,
    parameters: parameters,
    startingAnnotations: <String>[
      if (inlineBody != null) 'inline',
      if (isStatic) 'static',
      if (isVirtual) 'virtual',
      if (isConstructor && parameters.isNotEmpty && !isCopy) 'explicit'
    ],
    trailingAnnotations: <String>[
      if (isConst) 'const',
      if (noexcept) 'noexcept',
      if (isOverride) 'override',
      if (deleted) '= delete',
      if (defaultImpl) '= default',
      if (isPureVirtual) '= 0',
    ],
    body: inlineBody,
  );
}

void _writeFunctionDefinition(
  Indent indent,
  String name, {
  String? returnType,
  String? scope,
  List<String> parameters = const <String>[],
  bool isConst = false,
  List<String> initializers = const <String>[],
  void Function()? body,
}) {
  _writeFunction(
    indent,
    _FunctionOutputType.definition,
    name: name,
    scope: scope,
    returnType: returnType,
    parameters: parameters,
    trailingAnnotations: <String>[
      if (isConst) 'const',
    ],
    initializers: initializers,
    body: body,
  );
  indent.newln();
}

enum _ClassAccess { public, protected, private }

void _writeAccessBlock(
    Indent indent, _ClassAccess access, void Function() body) {
  final String accessLabel;
  switch (access) {
    case _ClassAccess.public:
      accessLabel = 'public';
    case _ClassAccess.protected:
      accessLabel = 'protected';
    case _ClassAccess.private:
      accessLabel = 'private';
  }
  indent.addScoped(' $accessLabel:', '', body);
}

/// Validates an AST to make sure the cpp generator supports everything.
List<Error> validateCpp(CppOptions options, Root root) {
  final List<Error> result = <Error>[];
  for (final Api api in root.apis) {
    for (final Method method in api.methods) {
      for (final NamedType arg in method.parameters) {
        if (arg.type.isEnum) {
          // TODO(gaaclarke): Add line number and filename.
          result.add(Error(
              message:
                  "Nullable enum types aren't supported in C++ arguments in method:${api.name}.${method.name} argument:(${arg.type.baseName} ${arg.name})."));
        }
      }
    }
  }
  return result;
}
