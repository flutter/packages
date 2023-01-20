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

/// Documentation comment spec.
const DocumentCommentSpecification _docCommentSpec =
    DocumentCommentSpecification(_commentPrefix);

/// The default serializer for Flutter.
const String _defaultCodecSerializer = 'flutter::StandardCodecSerializer';

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
      headerIncludePath: map['header'] as String?,
      namespace: map['namespace'] as String?,
      copyrightHeader: map['copyrightHeader'] as Iterable<String>?,
      headerOutPath: map['cppHeaderOut'] as String?,
    );
  }

  /// Converts a [CppOptions] to a Map representation where:
  /// `x = CppOptions.fromMap(x.toMap())`.
  Map<String, Object> toMap() {
    final Map<String, Object> result = <String, Object>{
      if (headerIncludePath != null) 'header': headerIncludePath!,
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
  void generate(OutputFileOptions<CppOptions> generatorOptions, Root root,
      StringSink sink) {
    assert(generatorOptions.fileType == FileType.header ||
        generatorOptions.fileType == FileType.source);
    if (generatorOptions.fileType == FileType.header) {
      const CppHeaderGenerator()
          .generate(generatorOptions.languageOptions, root, sink);
    } else if (generatorOptions.fileType == FileType.source) {
      const CppSourceGenerator()
          .generate(generatorOptions.languageOptions, root, sink);
    }
  }
}

/// Writes C++ header (.h) file to sink.
class CppHeaderGenerator extends StructuredGenerator<CppOptions> {
  /// Constructor.
  const CppHeaderGenerator();

  @override
  void writeFilePrologue(
      CppOptions generatorOptions, Root root, Indent indent) {
    if (generatorOptions.copyrightHeader != null) {
      addLines(indent, generatorOptions.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('$_commentPrefix $generatedCodeWarning');
    indent.writeln('$_commentPrefix $seeAlsoWarning');
    indent.newln();
  }

  @override
  void writeFileImports(CppOptions generatorOptions, Root root, Indent indent) {
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
      CppOptions generatorOptions, Root root, Indent indent, Enum anEnum) {
    indent.newln();
    addDocumentationComments(
        indent, anEnum.documentationComments, _docCommentSpec);
    indent.write('enum class ${anEnum.name} ');
    indent.addScoped('{', '};', () {
      enumerate(anEnum.members, (int index, final EnumMember member) {
        addDocumentationComments(
            indent, member.documentationComments, _docCommentSpec);
        indent.writeln(
            '${member.name} = $index${index == anEnum.members.length - 1 ? '' : ','}');
      });
    });
  }

  @override
  void writeGeneralUtilities(
      CppOptions generatorOptions, Root root, Indent indent) {
    _writeErrorOr(indent, friends: root.apis.map((Api api) => api.name));
  }

  @override
  void writeDataClass(
      CppOptions generatorOptions, Root root, Indent indent, Class klass) {
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
        indent, klass.documentationComments, _docCommentSpec,
        generatorComments: generatedMessages);

    indent.write('class ${klass.name} ');
    indent.addScoped('{', '};', () {
      indent.addScoped(' public:', '', () {
        indent.writeln('${klass.name}();');
        for (final NamedType field in getFieldsInSerializationOrder(klass)) {
          addDocumentationComments(
              indent, field.documentationComments, _docCommentSpec);
          final HostDatatype baseDatatype = getFieldHostDatatype(
              field, root.classes, root.enums, _baseCppTypeForBuiltinDartType);
          indent.writeln(
              '${_getterReturnType(baseDatatype)} ${_makeGetterName(field)}() const;');
          indent.writeln(
              'void ${_makeSetterName(field)}(${_unownedArgumentType(baseDatatype)} value_arg);');
          if (field.type.isNullable) {
            // Add a second setter that takes the non-nullable version of the
            // argument for convenience, since setting literal values with the
            // pointer version is non-trivial.
            final HostDatatype nonNullType = _nonNullableType(baseDatatype);
            indent.writeln(
                'void ${_makeSetterName(field)}(${_unownedArgumentType(nonNullType)} value_arg);');
          }
          indent.newln();
        }
      });

      indent.addScoped(' private:', '', () {
        indent.writeln('${klass.name}(const flutter::EncodableList& list);');
        indent.writeln('flutter::EncodableList ToEncodableList() const;');
        for (final Class friend in root.classes) {
          if (friend != klass &&
              friend.fields.any(
                  (NamedType element) => element.type.baseName == klass.name)) {
            indent.writeln('friend class ${friend.name};');
          }
        }
        for (final Api api in root.apis) {
          // TODO(gaaclarke): Find a way to be more precise with our
          // friendships.
          indent.writeln('friend class ${api.name};');
          indent.writeln('friend class ${_getCodecSerializerName(api)};');
        }
        if (testFixtureClass != null) {
          indent.writeln('friend class $testFixtureClass;');
        }

        for (final NamedType field in getFieldsInSerializationOrder(klass)) {
          final HostDatatype hostDatatype = getFieldHostDatatype(
              field, root.classes, root.enums, _baseCppTypeForBuiltinDartType);
          indent.writeln(
              '${_valueType(hostDatatype)} ${_makeInstanceVariableName(field)};');
        }
      });
    }, nestCount: 0);
    indent.newln();
  }

  @override
  void writeFlutterApi(
    CppOptions generatorOptions,
    Root root,
    Indent indent,
    Api api,
  ) {
    assert(api.location == ApiLocation.flutter);
    if (getCodecClasses(api, root).isNotEmpty) {
      _writeCodec(generatorOptions, root, indent, api);
    }
    const List<String> generatedMessages = <String>[
      ' Generated class from Pigeon that represents Flutter messages that can be called from C++.'
    ];
    addDocumentationComments(indent, api.documentationComments, _docCommentSpec,
        generatorComments: generatedMessages);
    indent.write('class ${api.name} ');
    indent.addScoped('{', '};', () {
      indent.addScoped(' private:', '', () {
        indent.writeln('flutter::BinaryMessenger* binary_messenger_;');
      });
      indent.addScoped(' public:', '', () {
        indent
            .write('${api.name}(flutter::BinaryMessenger* binary_messenger);');
        indent.newln();
        indent
            .writeln('static const flutter::StandardMessageCodec& GetCodec();');
        for (final Method func in api.methods) {
          final HostDatatype returnType = getHostDatatype(func.returnType,
              root.classes, root.enums, _baseCppTypeForBuiltinDartType);
          addDocumentationComments(
              indent, func.documentationComments, _docCommentSpec);

          final Iterable<String> argTypes = func.arguments.map((NamedType arg) {
            final HostDatatype hostType = getFieldHostDatatype(
                arg, root.classes, root.enums, _baseCppTypeForBuiltinDartType);
            return _flutterApiArgumentType(hostType);
          });
          final Iterable<String> argNames =
              indexMap(func.arguments, _getArgumentName);
          final List<String> parameters = <String>[
            ...map2(argTypes, argNames, (String x, String y) => '$x $y'),
            ..._flutterApiCallbackParameters(returnType),
          ];
          indent.writeln(
              'void ${_makeMethodName(func)}(${parameters.join(', ')});');
        }
      });
    }, nestCount: 0);
    indent.newln();
  }

  @override
  void writeHostApi(
    CppOptions generatorOptions,
    Root root,
    Indent indent,
    Api api,
  ) {
    assert(api.location == ApiLocation.host);
    if (getCodecClasses(api, root).isNotEmpty) {
      _writeCodec(generatorOptions, root, indent, api);
    }
    const List<String> generatedMessages = <String>[
      ' Generated interface from Pigeon that represents a handler of messages from Flutter.'
    ];
    addDocumentationComments(indent, api.documentationComments, _docCommentSpec,
        generatorComments: generatedMessages);
    indent.write('class ${api.name} ');
    indent.addScoped('{', '};', () {
      indent.addScoped(' public:', '', () {
        indent.writeln('${api.name}(const ${api.name}&) = delete;');
        indent.writeln('${api.name}& operator=(const ${api.name}&) = delete;');
        indent.writeln('virtual ~${api.name}() { };');
        for (final Method method in api.methods) {
          final HostDatatype returnType = getHostDatatype(method.returnType,
              root.classes, root.enums, _baseCppTypeForBuiltinDartType);
          final String returnTypeName = _hostApiReturnType(returnType);

          final List<String> argSignature = <String>[];
          if (method.arguments.isNotEmpty) {
            final Iterable<String> argTypes =
                method.arguments.map((NamedType arg) {
              final HostDatatype hostType = getFieldHostDatatype(arg,
                  root.classes, root.enums, _baseCppTypeForBuiltinDartType);
              return _hostApiArgumentType(hostType);
            });
            final Iterable<String> argNames =
                method.arguments.map((NamedType e) => _makeVariableName(e));
            argSignature.addAll(
                map2(argTypes, argNames, (String argType, String argName) {
              return '$argType $argName';
            }));
          }

          addDocumentationComments(
              indent, method.documentationComments, _docCommentSpec);

          if (method.isAsynchronous) {
            argSignature
                .add('std::function<void($returnTypeName reply)> result');
            indent.writeln(
                'virtual void ${_makeMethodName(method)}(${argSignature.join(', ')}) = 0;');
          } else {
            indent.writeln(
                'virtual $returnTypeName ${_makeMethodName(method)}(${argSignature.join(', ')}) = 0;');
          }
        }
        indent.newln();
        indent.writeln('$_commentPrefix The codec used by ${api.name}.');
        indent
            .writeln('static const flutter::StandardMessageCodec& GetCodec();');
        indent.writeln(
            '$_commentPrefix Sets up an instance of `${api.name}` to handle messages through the `binary_messenger`.');
        indent.writeln(
            'static void SetUp(flutter::BinaryMessenger* binary_messenger, ${api.name}* api);');
        indent.writeln(
            'static flutter::EncodableValue WrapError(std::string_view error_message);');
        indent.writeln(
            'static flutter::EncodableValue WrapError(const FlutterError& error);');
      });
      indent.addScoped(' protected:', '', () {
        indent.writeln('${api.name}() = default;');
      });
    }, nestCount: 0);
  }

  void _writeCodec(
      CppOptions generatorOptions, Root root, Indent indent, Api api) {
    assert(getCodecClasses(api, root).isNotEmpty);
    final String codeSerializerName = _getCodecSerializerName(api);
    indent
        .write('class $codeSerializerName : public $_defaultCodecSerializer ');
    indent.addScoped('{', '};', () {
      indent.addScoped(' public:', '', () {
        indent.newln();
        indent.format('''
inline static $codeSerializerName& GetInstance() {
\tstatic $codeSerializerName sInstance;
\treturn sInstance;
}
''');
        indent.writeln('$codeSerializerName();');
      });
      indent.writeScoped(' public:', '', () {
        indent.writeln(
            'void WriteValue(const flutter::EncodableValue& value, flutter::ByteStreamWriter* stream) const override;');
      });
      indent.writeScoped(' protected:', '', () {
        indent.writeln(
            'flutter::EncodableValue ReadValueOfType(uint8_t type, flutter::ByteStreamReader* stream) const override;');
      });
    }, nestCount: 0);
    indent.newln();
  }

  void _writeErrorOr(Indent indent,
      {Iterable<String> friends = const <String>[]}) {
    final String friendLines = friends
        .map((String className) => '\tfriend class $className;')
        .join('\n');
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
};

template<class T> class ErrorOr {
 public:
\tErrorOr(const T& rhs) { new(&v_) T(rhs); }
\tErrorOr(const T&& rhs) { v_ = std::move(rhs); }
\tErrorOr(const FlutterError& rhs) {
\t\tnew(&v_) FlutterError(rhs);
\t}
\tErrorOr(const FlutterError&& rhs) { v_ = std::move(rhs); }

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
      CppOptions generatorOptions, Root root, Indent indent) {
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
      CppOptions generatorOptions, Root root, Indent indent) {
    if (generatorOptions.copyrightHeader != null) {
      addLines(indent, generatorOptions.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('$_commentPrefix $generatedCodeWarning');
    indent.writeln('$_commentPrefix $seeAlsoWarning');
    indent.newln();
    indent.addln('#undef _HAS_EXCEPTIONS');
    indent.newln();
  }

  @override
  void writeFileImports(CppOptions generatorOptions, Root root, Indent indent) {
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
      CppOptions generatorOptions, Root root, Indent indent) {
    if (generatorOptions.namespace != null) {
      indent.writeln('namespace ${generatorOptions.namespace} {');
    }
  }

  @override
  void writeDataClass(
      CppOptions generatorOptions, Root root, Indent indent, Class klass) {
    final Set<String> customClassNames =
        root.classes.map((Class x) => x.name).toSet();
    final Set<String> customEnumNames =
        root.enums.map((Enum x) => x.name).toSet();

    indent.newln();
    indent.writeln('$_commentPrefix ${klass.name}');
    indent.newln();

    // Getters and setters.
    for (final NamedType field in getFieldsInSerializationOrder(klass)) {
      _writeCppSourceClassField(generatorOptions, root, indent, klass, field);
    }

    // Serialization.
    writeClassEncode(generatorOptions, root, indent, klass, customClassNames,
        customEnumNames);

    // Default constructor.
    indent.writeln('${klass.name}::${klass.name}() {}');
    indent.newln();

    // Deserialization.
    writeClassDecode(generatorOptions, root, indent, klass, customClassNames,
        customEnumNames);
  }

  @override
  void writeClassEncode(
    CppOptions generatorOptions,
    Root root,
    Indent indent,
    Class klass,
    Set<String> customClassNames,
    Set<String> customEnumNames,
  ) {
    indent.write(
        'flutter::EncodableList ${klass.name}::ToEncodableList() const ');
    indent.addScoped('{', '}', () {
      indent.addScoped('return flutter::EncodableList{', '};', () {
        for (final NamedType field in getFieldsInSerializationOrder(klass)) {
          final HostDatatype hostDatatype = getFieldHostDatatype(
              field, root.classes, root.enums, _baseCppTypeForBuiltinDartType);
          final String encodableValue = _wrappedHostApiArgumentExpression(
              root, _makeInstanceVariableName(field), field.type, hostDatatype);
          indent.writeln('$encodableValue,');
        }
      });
    });
    indent.newln();
  }

  @override
  void writeClassDecode(
    CppOptions generatorOptions,
    Root root,
    Indent indent,
    Class klass,
    Set<String> customClassNames,
    Set<String> customEnumNames,
  ) {
    indent.write(
        '${klass.name}::${klass.name}(const flutter::EncodableList& list) ');
    indent.addScoped('{', '}', () {
      enumerate(getFieldsInSerializationOrder(klass),
          (int index, final NamedType field) {
        final String instanceVariableName = _makeInstanceVariableName(field);
        final String pointerFieldName =
            '${_pointerPrefix}_${_makeVariableName(field)}';
        final String encodableFieldName =
            '${_encodablePrefix}_${_makeVariableName(field)}';
        indent.writeln('auto& $encodableFieldName = list[$index];');
        if (customEnumNames.contains(field.type.baseName)) {
          indent.writeln(
              'if (const int32_t* $pointerFieldName = std::get_if<int32_t>(&$encodableFieldName))\t$instanceVariableName = (${field.type.baseName})*$pointerFieldName;');
        } else {
          final HostDatatype hostDatatype = getFieldHostDatatype(
              field, root.classes, root.enums, _baseCppTypeForBuiltinDartType);
          if (field.type.baseName == 'int') {
            indent.format('''
if (const int32_t* $pointerFieldName = std::get_if<int32_t>(&$encodableFieldName))
\t$instanceVariableName = *$pointerFieldName;
else if (const int64_t* ${pointerFieldName}_64 = std::get_if<int64_t>(&$encodableFieldName))
\t$instanceVariableName = *${pointerFieldName}_64;''');
          } else if (!hostDatatype.isBuiltin &&
              root.classes
                  .map((Class x) => x.name)
                  .contains(field.type.baseName)) {
            indent.write(
                'if (const flutter::EncodableList* $pointerFieldName = std::get_if<flutter::EncodableList>(&$encodableFieldName)) ');
            indent.addScoped('{', '}', () {
              indent.writeln(
                  '$instanceVariableName = ${hostDatatype.datatype}(*$pointerFieldName);');
            });
          } else {
            indent.write(
                'if (const ${hostDatatype.datatype}* $pointerFieldName = std::get_if<${hostDatatype.datatype}>(&$encodableFieldName)) ');
            indent.addScoped('{', '}', () {
              indent.writeln('$instanceVariableName = *$pointerFieldName;');
            });
          }
        }
      });
    });
  }

  @override
  void writeFlutterApi(
    CppOptions generatorOptions,
    Root root,
    Indent indent,
    Api api,
  ) {
    assert(api.location == ApiLocation.flutter);
    if (getCodecClasses(api, root).isNotEmpty) {
      _writeCodec(generatorOptions, root, indent, api);
    }
    indent.writeln(
        '$_commentPrefix Generated class from Pigeon that represents Flutter messages that can be called from C++.');
    indent.write(
        '${api.name}::${api.name}(flutter::BinaryMessenger* binary_messenger) ');
    indent.addScoped('{', '}', () {
      indent.writeln('this->binary_messenger_ = binary_messenger;');
    });
    indent.newln();
    final String codeSerializerName = getCodecClasses(api, root).isNotEmpty
        ? _getCodecSerializerName(api)
        : _defaultCodecSerializer;
    indent.format('''
const flutter::StandardMessageCodec& ${api.name}::GetCodec() {
\treturn flutter::StandardMessageCodec::GetInstance(&$codeSerializerName::GetInstance());
}
''');
    for (final Method func in api.methods) {
      final String channelName = makeChannelName(api, func);
      final HostDatatype returnType = getHostDatatype(func.returnType,
          root.classes, root.enums, _baseCppTypeForBuiltinDartType);

      // Determine the input paramater list, saved in a structured form for later
      // use as platform channel call arguments.
      final Iterable<_HostNamedType> hostParameters =
          indexMap(func.arguments, (int i, NamedType arg) {
        final HostDatatype hostType = getFieldHostDatatype(
            arg, root.classes, root.enums, _baseCppTypeForBuiltinDartType);
        return _HostNamedType(_getSafeArgumentName(i, arg), hostType, arg.type);
      });
      final List<String> parameters = <String>[
        ...hostParameters.map((_HostNamedType arg) =>
            '${_flutterApiArgumentType(arg.hostType)} ${arg.name}'),
        ..._flutterApiCallbackParameters(returnType),
      ];
      indent.write(
          'void ${api.name}::${_makeMethodName(func)}(${parameters.join(', ')}) ');
      indent.writeScoped('{', '}', () {
        const String channel = 'channel';
        indent.writeln(
            'auto channel = std::make_unique<flutter::BasicMessageChannel<>>(binary_messenger_, '
            '"$channelName", &GetCodec());');

        // Convert arguments to EncodableValue versions.
        const String argumentListVariableName = 'encoded_api_arguments';
        indent.write('flutter::EncodableValue $argumentListVariableName = ');
        if (func.arguments.isEmpty) {
          indent.addln('flutter::EncodableValue();');
        } else {
          indent.addScoped(
              'flutter::EncodableValue(flutter::EncodableList{', '});', () {
            for (final _HostNamedType param in hostParameters) {
              final String encodedArgument = _wrappedHostApiArgumentExpression(
                  root, param.name, param.originalType, param.hostType);
              indent.writeln('$encodedArgument,');
            }
          });
        }

        indent.write('$channel->Send($argumentListVariableName, '
            // ignore: missing_whitespace_between_adjacent_strings
            '[on_success = std::move(on_success), on_error = std::move(on_error)]'
            '(const uint8_t* reply, size_t reply_size) ');
        indent.addScoped('{', '});', () {
          final String successCallbackArgument;
          if (func.returnType.isVoid) {
            successCallbackArgument = '';
          } else {
            successCallbackArgument = 'return_value';
            final String encodedReplyName =
                'encodable_$successCallbackArgument';
            indent.writeln(
                'std::unique_ptr<flutter::EncodableValue> response = GetCodec().DecodeMessage(reply, reply_size);');
            indent.writeln('const auto& $encodedReplyName = *response;');
            _writeEncodableValueArgumentUnwrapping(indent, returnType,
                argName: successCallbackArgument,
                encodableArgName: encodedReplyName);
          }
          indent.writeln('on_success($successCallbackArgument);');
        });
      });
    }
  }

  @override
  void writeHostApi(
      CppOptions generatorOptions, Root root, Indent indent, Api api) {
    assert(api.location == ApiLocation.host);
    if (getCodecClasses(api, root).isNotEmpty) {
      _writeCodec(generatorOptions, root, indent, api);
    }

    final String codeSerializerName = getCodecClasses(api, root).isNotEmpty
        ? _getCodecSerializerName(api)
        : _defaultCodecSerializer;
    indent.format('''
/// The codec used by ${api.name}.
const flutter::StandardMessageCodec& ${api.name}::GetCodec() {
\treturn flutter::StandardMessageCodec::GetInstance(&$codeSerializerName::GetInstance());
}
''');
    indent.writeln(
        '$_commentPrefix Sets up an instance of `${api.name}` to handle messages through the `binary_messenger`.');
    indent.write(
        'void ${api.name}::SetUp(flutter::BinaryMessenger* binary_messenger, ${api.name}* api) ');
    indent.addScoped('{', '}', () {
      for (final Method method in api.methods) {
        final String channelName = makeChannelName(api, method);
        indent.write('');
        indent.addScoped('{', '}', () {
          indent.writeln(
              'auto channel = std::make_unique<flutter::BasicMessageChannel<>>(binary_messenger, '
              '"$channelName", &GetCodec());');
          indent.write('if (api != nullptr) ');
          indent.addScoped('{', '} else {', () {
            indent.write(
                'channel->SetMessageHandler([api](const flutter::EncodableValue& message, const flutter::MessageReply<flutter::EncodableValue>& reply) ');
            indent.addScoped('{', '});', () {
              indent.write('try ');
              indent.addScoped('{', '}', () {
                final List<String> methodArgument = <String>[];
                if (method.arguments.isNotEmpty) {
                  indent.writeln(
                      'const auto& args = std::get<flutter::EncodableList>(message);');

                  enumerate(method.arguments, (int index, NamedType arg) {
                    final HostDatatype hostType = getHostDatatype(
                        arg.type,
                        root.classes,
                        root.enums,
                        (TypeDeclaration x) =>
                            _baseCppTypeForBuiltinDartType(x));
                    final String argName = _getSafeArgumentName(index, arg);

                    final String encodableArgName =
                        '${_encodablePrefix}_$argName';
                    indent.writeln(
                        'const auto& $encodableArgName = args.at($index);');
                    if (!arg.type.isNullable) {
                      indent.write('if ($encodableArgName.IsNull()) ');
                      indent.addScoped('{', '}', () {
                        indent.writeln(
                            'reply(WrapError("$argName unexpectedly null."));');
                        indent.writeln('return;');
                      });
                    }
                    _writeEncodableValueArgumentUnwrapping(indent, hostType,
                        argName: argName, encodableArgName: encodableArgName);
                    methodArgument.add(argName);
                  });
                }

                final HostDatatype returnType = getHostDatatype(
                    method.returnType,
                    root.classes,
                    root.enums,
                    _baseCppTypeForBuiltinDartType);
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
            indent.writeln('channel->SetMessageHandler(nullptr);');
          });
        });
      }
    });

    indent.newln();
    indent.format('''
flutter::EncodableValue ${api.name}::WrapError(std::string_view error_message) {
\treturn flutter::EncodableValue(flutter::EncodableList{
\t\tflutter::EncodableValue(std::string(error_message)),
\t\tflutter::EncodableValue("Error"),
\t\tflutter::EncodableValue()
\t});
}
flutter::EncodableValue ${api.name}::WrapError(const FlutterError& error) {
\treturn flutter::EncodableValue(flutter::EncodableList{
\t\tflutter::EncodableValue(error.message()),
\t\tflutter::EncodableValue(error.code()),
\t\terror.details()
\t});
}''');
    indent.newln();
  }

  void _writeCodec(
    CppOptions generatorOptions,
    Root root,
    Indent indent,
    Api api,
  ) {
    assert(getCodecClasses(api, root).isNotEmpty);
    final String codeSerializerName = _getCodecSerializerName(api);
    indent.newln();
    indent.writeln('$codeSerializerName::$codeSerializerName() {}');
    indent.write(
        'flutter::EncodableValue $codeSerializerName::ReadValueOfType(uint8_t type, flutter::ByteStreamReader* stream) const ');
    indent.addScoped('{', '}', () {
      indent.write('switch (type) ');
      indent.addScoped('{', '}', () {
        for (final EnumeratedClass customClass in getCodecClasses(api, root)) {
          indent.write('case ${customClass.enumeration}:');
          indent.writeScoped('', '', () {
            indent.writeln(
                'return flutter::CustomEncodableValue(${customClass.name}(std::get<flutter::EncodableList>(ReadValue(stream))));');
          });
        }
        indent.write('default:');
        indent.writeScoped('', '', () {
          indent.writeln(
              'return $_defaultCodecSerializer::ReadValueOfType(type, stream);');
        }, addTrailingNewline: false);
      });
    });
    indent.newln();
    indent.write(
        'void $codeSerializerName::WriteValue(const flutter::EncodableValue& value, flutter::ByteStreamWriter* stream) const ');
    indent.writeScoped('{', '}', () {
      indent.write(
          'if (const flutter::CustomEncodableValue* custom_value = std::get_if<flutter::CustomEncodableValue>(&value)) ');
      indent.addScoped('{', '}', () {
        for (final EnumeratedClass customClass in getCodecClasses(api, root)) {
          indent.write(
              'if (custom_value->type() == typeid(${customClass.name})) ');
          indent.addScoped('{', '}', () {
            indent.writeln('stream->WriteByte(${customClass.enumeration});');
            indent.writeln(
                'WriteValue(flutter::EncodableValue(std::any_cast<${customClass.name}>(*custom_value).ToEncodableList()), stream);');
            indent.writeln('return;');
          });
        }
      });
      indent.writeln('$_defaultCodecSerializer::WriteValue(value, stream);');
    });
    indent.newln();
  }

  void _writeCppSourceClassField(CppOptions generatorOptions, Root root,
      Indent indent, Class klass, NamedType field) {
    final HostDatatype hostDatatype = getFieldHostDatatype(
        field, root.classes, root.enums, _baseCppTypeForBuiltinDartType);
    final String instanceVariableName = _makeInstanceVariableName(field);
    final String qualifiedGetterName =
        '${klass.name}::${_makeGetterName(field)}';
    final String qualifiedSetterName =
        '${klass.name}::${_makeSetterName(field)}';
    final String returnExpression = hostDatatype.isNullable
        ? '$instanceVariableName ? &(*$instanceVariableName) : nullptr'
        : instanceVariableName;

    // Generates the string for a setter treating the type as [type], to allow
    // generating multiple setter variants.
    String makeSetter(HostDatatype type) {
      const String setterArgumentName = 'value_arg';
      final String valueExpression = type.isNullable
          ? '$setterArgumentName ? ${_valueType(type)}(*$setterArgumentName) : std::nullopt'
          : setterArgumentName;
      return 'void $qualifiedSetterName(${_unownedArgumentType(type)} $setterArgumentName) '
          '{ $instanceVariableName = $valueExpression; }';
    }

    indent.writeln(
        '${_getterReturnType(hostDatatype)} $qualifiedGetterName() const '
        '{ return $returnExpression; }');
    indent.writeln(makeSetter(hostDatatype));
    if (hostDatatype.isNullable) {
      // Write the non-nullable variant; see _writeCppHeaderDataClass.
      final HostDatatype nonNullType = _nonNullableType(hostDatatype);
      indent.writeln(makeSetter(nonNullType));
    }

    indent.newln();
  }

  String _wrapResponse(Indent indent, Root root, TypeDeclaration returnType,
      {String prefix = ''}) {
    final String nonErrorPath;
    final String errorCondition;
    final String errorGetter;

    const String nullValue = 'flutter::EncodableValue()';
    if (returnType.isVoid) {
      nonErrorPath = '${prefix}wrapped.push_back($nullValue);';
      errorCondition = 'output.has_value()';
      errorGetter = 'value';
    } else {
      final HostDatatype hostType = getHostDatatype(
          returnType, root.classes, root.enums, _baseCppTypeForBuiltinDartType);
      const String extractedValue = 'std::move(output).TakeValue()';
      final String wrapperType = hostType.isBuiltin
          ? 'flutter::EncodableValue'
          : 'flutter::CustomEncodableValue';
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
${prefix}flutter::EncodableList wrapped;
$nonErrorPath
${prefix}reply(flutter::EncodableValue(std::move(wrapped)));''';
  }

  @override
  void writeCloseNamespace(
      CppOptions generatorOptions, Root root, Indent indent) {
    if (generatorOptions.namespace != null) {
      indent.writeln('}  // namespace ${generatorOptions.namespace}');
    }
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

String _getCodecSerializerName(Api api) => '${api.name}CodecSerializer';

const String _pointerPrefix = 'pointer';
const String _encodablePrefix = 'encodable';

String _getArgumentName(int count, NamedType argument) =>
    argument.name.isEmpty ? 'arg$count' : _makeVariableName(argument);

/// Returns an argument name that can be used in a context where it is possible to collide.
String _getSafeArgumentName(int count, NamedType argument) =>
    '${_getArgumentName(count, argument)}_arg';

/// Returns a non-nullable variant of [type].
HostDatatype _nonNullableType(HostDatatype type) {
  return HostDatatype(
      datatype: type.datatype, isBuiltin: type.isBuiltin, isNullable: false);
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

String? _baseCppTypeForBuiltinDartType(TypeDeclaration type) {
  const Map<String, String> cppTypeForDartTypeMap = <String, String>{
    'void': 'void',
    'bool': 'bool',
    'int': 'int64_t',
    'String': 'std::string',
    'double': 'double',
    'Uint8List': 'std::vector<uint8_t>',
    'Int32List': 'std::vector<int32_t>',
    'Int64List': 'std::vector<int64_t>',
    'Float64List': 'std::vector<double>',
    'Map': 'flutter::EncodableMap',
    'List': 'flutter::EncodableList',
    'Object': 'flutter::EncodableValue',
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

/// Returns the C++ type to use for the paramer to the asyncronous "return"
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

/// Returns the expression to create an EncodableValue from a host API argument
/// with the given [variableName] and types.
String _wrappedHostApiArgumentExpression(Root root, String variableName,
    TypeDeclaration dartType, HostDatatype hostType) {
  final String encodableValue;
  if (!hostType.isBuiltin &&
      root.classes.any((Class c) => c.name == dartType.baseName)) {
    final String operator = hostType.isNullable ? '->' : '.';
    encodableValue =
        'flutter::EncodableValue($variableName${operator}ToEncodableList())';
  } else if (!hostType.isBuiltin &&
      root.enums.any((Enum e) => e.name == dartType.baseName)) {
    final String nonNullValue =
        hostType.isNullable ? '(*$variableName)' : variableName;
    encodableValue = 'flutter::EncodableValue((int)$nonNullValue)';
  } else {
    final String operator = hostType.isNullable ? '*' : '';
    encodableValue = 'flutter::EncodableValue($operator$variableName)';
  }

  if (hostType.isNullable) {
    return '$variableName ? $encodableValue : flutter::EncodableValue()';
  }
  return encodableValue;
}

// Writes the code to declare and populate a variable of type [hostType] called
// [argName] to use as a parameter to an API method call, from an existing
// EncodableValue variable called [encodableArgName].
void _writeEncodableValueArgumentUnwrapping(
  Indent indent,
  HostDatatype hostType, {
  required String argName,
  required String encodableArgName,
}) {
  if (hostType.isNullable) {
    // Nullable arguments are always pointers, with nullptr corresponding to
    // null.
    if (hostType.datatype == 'int64_t') {
      // The EncodableValue will either be an int32_t or an int64_t depending
      // on the value, but the generated API requires an int64_t so that it can
      // handle any case. Create a local variable for the 64-bit value...
      final String valueVarName = '${argName}_value';
      indent.writeln(
          'const int64_t $valueVarName = $encodableArgName.IsNull() ? 0 : $encodableArgName.LongValue();');
      // ... then declare the arg as a reference to that local.
      indent.writeln(
          'const auto* $argName = $encodableArgName.IsNull() ? nullptr : &$valueVarName;');
    } else if (hostType.datatype == 'flutter::EncodableValue') {
      // Generic objects just pass the EncodableValue through directly.
      indent.writeln('const auto* $argName = &$encodableArgName;');
    } else if (hostType.isBuiltin) {
      indent.writeln(
          'const auto* $argName = std::get_if<${hostType.datatype}>(&$encodableArgName);');
    } else {
      indent.writeln(
          'const auto* $argName = &(std::any_cast<const ${hostType.datatype}&>(std::get<flutter::CustomEncodableValue>($encodableArgName)));');
    }
  } else {
    // Non-nullable arguments are either passed by value or reference, but the
    // extraction doesn't need to distinguish since those are the same at the
    // call site.
    if (hostType.datatype == 'int64_t') {
      // The EncodableValue will either be an int32_t or an int64_t depending
      // on the value, but the generated API requires an int64_t so that it can
      // handle any case.
      indent.writeln('const int64_t $argName = $encodableArgName.LongValue();');
    } else if (hostType.datatype == 'flutter::EncodableValue') {
      // Generic objects just pass the EncodableValue through directly. This
      // creates an alias just to avoid having to special-case the
      // argName/encodableArgName distinction at a higher level.
      indent.writeln('const auto& $argName = $encodableArgName;');
    } else if (hostType.isBuiltin) {
      indent.writeln(
          'const auto& $argName = std::get<${hostType.datatype}>($encodableArgName);');
    } else {
      indent.writeln(
          'const auto& $argName = std::any_cast<const ${hostType.datatype}&>(std::get<flutter::CustomEncodableValue>($encodableArgName));');
    }
  }
}

/// Validates an AST to make sure the cpp generator supports everything.
List<Error> validateCpp(CppOptions options, Root root) {
  final List<Error> result = <Error>[];
  for (final Api api in root.apis) {
    for (final Method method in api.methods) {
      for (final NamedType arg in method.arguments) {
        if (isEnum(root, arg.type)) {
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
