// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/functional.dart';

import 'ast.dart';
import 'generator_tools.dart';

/// Options that control how C++ code will be generated.
class CppOptions {
  /// Creates a [CppOptions] object
  const CppOptions({
    this.header,
    this.namespace,
    this.copyrightHeader,
  });

  /// The path to the header that will get placed in the source filed (example:
  /// "foo.h").
  final String? header;

  /// The namespace where the generated class will live.
  final String? namespace;

  /// A copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// Creates a [CppOptions] from a Map representation where:
  /// `x = CppOptions.fromMap(x.toMap())`.
  static CppOptions fromMap(Map<String, Object> map) {
    return CppOptions(
      header: map['header'] as String?,
      namespace: map['namespace'] as String?,
      copyrightHeader: map['copyrightHeader'] as Iterable<String>?,
    );
  }

  /// Converts a [CppOptions] to a Map representation where:
  /// `x = CppOptions.fromMap(x.toMap())`.
  Map<String, Object> toMap() {
    final Map<String, Object> result = <String, Object>{
      if (header != null) 'header': header!,
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

String _getCodecName(Api api) => '${api.name}CodecSerializer';

void _writeCodecHeader(Indent indent, Api api, Root root) {
  final String codecName = _getCodecName(api);
  indent.write('class $codecName : public flutter::StandardCodecSerializer ');
  indent.scoped('{', '};', () {
    indent.scoped('public:', '', () {
      indent.writeln('');
      indent.format('''
inline static $codecName& Instance() {
\tstatic $codecName sInstance;
\treturn sInstance;
}
''');
      indent.writeln('$codecName();');
    });
    if (getCodecClasses(api, root).isNotEmpty) {
      indent.writeScoped('protected:', '', () {
        indent.writeln(
            'flutter::EncodableValue ReadValueOfType(uint8_t type, flutter::ByteStreamReader* stream) const;');
        indent.writeln(
            'void WriteValue(const flutter::EncodableValue& value, flutter::ByteStreamWriter* stream) const;');
      });
    }
  });
}

void _writeCodecSource(Indent indent, Api api, Root root) {
  final String codecName = _getCodecName(api);
  indent.writeln('$codecName::$codecName() {}');
  if (getCodecClasses(api, root).isNotEmpty) {
    indent.write(
        'flutter::EncodableValue $codecName::ReadValueOfType(uint8_t type, flutter::ByteStreamReader* stream) const');
    indent.scoped('{', '}', () {
      indent.write('switch (type) ');
      indent.scoped('{', '}', () {
        for (final EnumeratedClass customClass in getCodecClasses(api, root)) {
          indent.write('case ${customClass.enumeration}: ');
          indent.writeScoped('', '', () {
            indent.writeln(
                'return flutter::CustomEncodableValue(${customClass.name}(std::get<flutter::EncodableMap>(ReadValue(stream))));');
          });
        }
        indent.write('default:');
        indent.writeScoped('', '', () {
          indent.writeln(
              'return flutter::StandardCodecSerializer::ReadValueOfType(type, stream);');
        });
      });
    });
    indent.write(
        'void $codecName::WriteValue(const flutter::EncodableValue& value, flutter::ByteStreamWriter* stream) const');
    indent.writeScoped('{', '}', () {
      indent.write(
          'if(const flutter::CustomEncodableValue* customValue = std::get_if<flutter::CustomEncodableValue>(&value))');
      indent.scoped('{', '} else ', () {
        for (final EnumeratedClass customClass in getCodecClasses(api, root)) {
          indent
              .write('if(customValue->type() == typeid(${customClass.name}))');
          indent.scoped('{', '} else ', () {
            indent.writeln('stream->WriteByte(${customClass.enumeration});');
            indent.writeln(
                'WriteValue(std::any_cast<${customClass.name}>(*customValue).ToEncodableMap(), stream);');
          });
        }
        indent.scoped('{', '}', () {
          indent.writeln(
              'flutter::StandardCodecSerializer::WriteValue(value, stream);');
        });
      });
      indent.scoped('{', '}', () {
        indent.writeln(
            'flutter::StandardCodecSerializer::WriteValue(value, stream);');
      });
    });
  }
}

void _writeHostApiHeader(Indent indent, Api api) {
  assert(api.location == ApiLocation.host);

  indent.writeln(
      '/** Generated class from Pigeon that represents a handler of messages from Flutter.*/');
  indent.write('class ${api.name} ');
  indent.scoped('{', '};', () {
    indent.scoped('public:', '', () {
      for (final Method method in api.methods) {
        final String returnType = method.isAsynchronous
            ? 'void'
            : _cppTypeForDartType(method.returnType);
        final List<String> argSignature = <String>[];
        if (method.arguments.isNotEmpty) {
          final Iterable<String> argTypes = method.arguments
              .map((NamedType e) => _cppTypeForDartType(e.type));
          final Iterable<String> argNames =
              method.arguments.map((NamedType e) => e.name);
          argSignature.addAll(
              map2(argTypes, argNames, (String argType, String argName) {
            return '$argType $argName';
          }));
        }
        if (method.isAsynchronous) {
          final String returnType = method.returnType.isVoid
              ? 'void'
              : _cppTypeForDartType(method.returnType);
          argSignature.add('flutter::MessageReply<$returnType> result');
        }
        indent.writeln(
            'virtual $returnType ${method.name}(${argSignature.join(', ')}) = 0;');
      }
      indent.addln('');
      indent.writeln('/** The codec used by ${api.name}. */');
      indent.writeln('static const flutter::StandardMessageCodec& GetCodec();');
      indent.writeln(
          '/** Sets up an instance of `${api.name}` to handle messages through the `binaryMessenger`. */');
      indent.writeln(
          'static void Setup(flutter::BinaryMessenger* binaryMessenger, ${api.name}* api);');
      indent.writeln(
          'static flutter::EncodableMap WrapError(std::exception exception);');
    });
  });
}

void _writeHostApiSource(Indent indent, Api api) {
  assert(api.location == ApiLocation.host);

  final String codecName = _getCodecName(api);
  indent.format('''
/** The codec used by ${api.name}. */
const flutter::StandardMessageCodec& ${api.name}::GetCodec() {
\treturn flutter::StandardMessageCodec::GetInstance(&$codecName::Instance());
}
''');
  indent.writeln(
      '/** Sets up an instance of `${api.name}` to handle messages through the `binaryMessenger`. */');
  indent.write(
      'void ${api.name}::Setup(flutter::BinaryMessenger* binaryMessenger, ${api.name}* api) ');
  indent.scoped('{', '}', () {
    for (final Method method in api.methods) {
      final String channelName = makeChannelName(api, method);
      indent.write('');
      indent.scoped('{', '}', () {
        indent.writeln(
            'auto channel = std::make_unique<flutter::BasicMessageChannel<flutter::EncodableValue>>(');
        indent.inc();
        indent.inc();
        indent.writeln('binaryMessenger, "$channelName", &GetCodec());');
        indent.dec();
        indent.dec();
        indent.write('if (api != nullptr) ');
        indent.scoped('{', '} else {', () {
          indent.write(
              'channel->SetMessageHandler([api](const auto& message, auto reply)');
          indent.scoped('{', '});', () {
            final String returnType = _cppTypeForDartType(method.returnType);
            indent.writeln('auto wrapped = flutter::EncodableMap();');
            indent.write('try ');
            indent.scoped('{', '}', () {
              final List<String> methodArgument = <String>[];
              if (method.arguments.isNotEmpty) {
                indent.writeln(
                    'auto args = std::get<flutter::EncodableList>(message);');
                enumerate(method.arguments, (int index, NamedType arg) {
                  final String argType = _cppTypeForDartType(arg.type);
                  final String argName = _getSafeArgumentName(index, arg);
                  indent.writeln(
                      '$argType $argName = std::any_cast<$argType>(std::get<flutter::CustomEncodableValue>(args.at($index)));');
                  /*indent.write('if ($argName == nullptr) ');
                  indent.scoped('{', '}', () {
                    indent.writeln(
                        'throw exception("$argName unexpectedly null.");');
                  });
                  */
                  methodArgument.add(argName);
                });
              }
              if (method.isAsynchronous) {
                final String resultValue = method.returnType.isVoid
                    ? 'flutter::EncodableValue()'
                    : 'flutter::CustomEncodableValue(result)';
                methodArgument.add(
                  '[wrapped, reply](auto result) { '
                  'wrapped.insert(std::make_pair(flutter::EncodableValue("${Keys.result}"), $resultValue)); '
                  'reply(wrapped); '
                  '}',
                );
              }
              final String call =
                  'api->${method.name}(${methodArgument.join(', ')})';
              if (method.isAsynchronous) {
                indent.writeln('$call;');
              } else if (method.returnType.isVoid) {
                indent.writeln('$call;');
                indent.writeln(
                    'wrapped.insert(std::make_pair(flutter::EncodableValue("${Keys.result}"), flutter::EncodableValue()));');
              } else {
                indent.writeln('$returnType output = $call;');
                indent.writeln(
                    'wrapped.insert(std::make_pair(flutter::EncodableValue("${Keys.result}"), flutter::CustomEncodableValue(output)));');
              }
            });
            indent.write('catch (std::exception exception)');
            indent.scoped('{', '}', () {
              indent.writeln(
                  'wrapped.insert(std::make_pair(flutter::EncodableValue("${Keys.error}"), WrapError(exception)));');
              if (method.isAsynchronous) {
                indent.writeln('reply(wrapped);');
              }
            });
            if (!method.isAsynchronous) {
              indent.writeln('reply(wrapped);');
            }
          });
        });
        indent.scoped(null, '}', () {
          indent.writeln('channel->SetMessageHandler(nullptr);');
        });
      });
    }
  });
}

String _getArgumentName(int count, NamedType argument) =>
    argument.name.isEmpty ? 'arg$count' : argument.name;

/// Returns an argument name that can be used in a context where it is possible to collide.
String _getSafeArgumentName(int count, NamedType argument) =>
    _getArgumentName(count, argument) + 'Arg';

void _writeFlutterApiHeader(Indent indent, Api api) {
  assert(api.location == ApiLocation.flutter);
  indent.writeln(
      '/** Generated class from Pigeon that represents Flutter messages that can be called from C++.*/');
  indent.write('class ${api.name} ');
  indent.scoped('{', '};', () {
    indent.scoped('private:', '', () {
      indent.writeln('flutter::BinaryMessenger* binaryMessenger;');
    });
    indent.scoped('public:', '', () {
      indent
          .write('${api.name}(flutter::BinaryMessenger* argBinaryMessenger);');
      // final String codecName = _getCodecName(api);
      indent.writeln('');
      indent.format('''
  static const flutter::StandardMessageCodec& GetCodec();
  ''');
      for (final Method func in api.methods) {
        final String returnType = func.returnType.isVoid
            ? 'void'
            : _cppTypeForDartType(func.returnType);
        if (func.arguments.isEmpty) {
          indent.write(
              'void ${func.name}(std::function<void($returnType)>&& callback);');
        } else {
          final Iterable<String> argTypes =
              func.arguments.map((NamedType e) => _cppTypeForDartType(e.type));
          final Iterable<String> argNames =
              indexMap(func.arguments, _getSafeArgumentName);
          final String argsSignature =
              map2(argTypes, argNames, (String x, String y) => '$x $y')
                  .join(', ');
          indent.write(
              'void ${func.name}($argsSignature, std::function<void($returnType)>&& callback);');
        }
      }
    });
  });
}

void _writeFlutterApiSource(Indent indent, Api api) {
  assert(api.location == ApiLocation.flutter);
  indent.writeln(
      '/** Generated class from Pigeon that represents Flutter messages that can be called from C++.*/');
  indent.write(
      '${api.name}::${api.name}(flutter::BinaryMessenger* argBinaryMessenger)');
  indent.scoped('{', '}', () {
    indent.writeln('this->binaryMessenger = argBinaryMessenger;');
  });
  final String codecName = _getCodecName(api);
  indent.format('''
const flutter::StandardMessageCodec& ${api.name}::GetCodec() {
\treturn flutter::StandardMessageCodec::GetInstance(&$codecName::Instance());
}
''');
  for (final Method func in api.methods) {
    final String channelName = makeChannelName(api, func);
    final String returnType =
        func.returnType.isVoid ? 'void' : _cppTypeForDartType(func.returnType);
    String sendArgument;
    if (func.arguments.isEmpty) {
      indent.write(
          'void ${api.name}::${func.name}(std::function<void($returnType)>&& callback) ');
      sendArgument = 'flutter::EncodableValue()';
    } else {
      final Iterable<String> argTypes =
          func.arguments.map((NamedType e) => _cppTypeForDartType(e.type));
      final Iterable<String> argNames =
          indexMap(func.arguments, _getSafeArgumentName);
      // Need to add support for multiple parameters
      sendArgument = 'flutter::CustomEncodableValue(${argNames.join(', ')})';
      final String argsSignature =
          map2(argTypes, argNames, (String x, String y) => '$x $y').join(', ');
      indent.write(
          'void ${api.name}::${func.name}($argsSignature, std::function<void($returnType)>&& callback) ');
    }
    indent.scoped('{', '}', () {
      const String channel = 'channel';
      indent.writeln(
          'auto channel = std::make_unique<flutter::BasicMessageChannel<flutter::EncodableValue>>(');
      indent.inc();
      indent.inc();
      indent.writeln('binaryMessenger, "$channelName", &GetCodec());');
      indent.dec();
      indent.dec();
      indent.write(
          '$channel->Send($sendArgument, [callback](const uint8_t* reply, size_t reply_size)');
      indent.scoped('{', '});', () {
        if (func.returnType.isVoid) {
          indent.writeln('callback(nullptr);');
        } else {
          indent.writeln(
              'auto decodedReply = GetCodec().DecodeMessage(reply, reply_size);');
          indent.writeln(
              'flutter::EncodableMap args = *(flutter::EncodableMap*)(decodedReply.release());');
          const String output = 'output';
          indent.writeln('$returnType $output = $returnType(args);');
          indent.writeln('callback($output);');
        }
      });
    });
  }
}

String _makeGetter(NamedType field) {
  final String uppercased =
      field.name.substring(0, 1).toUpperCase() + field.name.substring(1);
  return 'get$uppercased';
}

String _makeSetter(NamedType field) {
  final String uppercased =
      field.name.substring(0, 1).toUpperCase() + field.name.substring(1);
  return 'set$uppercased';
}

/// Converts a [List] of [TypeDeclaration]s to a comma separated [String] to be
/// used in C++ code.
String _flattenTypeArguments(List<TypeDeclaration> args) {
  return args.map<String>(_cppTypeForDartType).join(', ');
}

String? _cppTypeForBuiltinDartType(TypeDeclaration type) {
  const Map<String, String> cppTypeForDartTypeMap = <String, String>{
    'bool': 'bool',
    'int': 'int64_t',
    'String': 'std::string',
    'double': 'double',
    'Uint8List': 'byte[]',
    'Int32List': 'int[]',
    'Int64List': 'int64_t[]',
    'Float64List': 'double[]',
    'Map': 'flutter::EncodableMap',
  };
  if (cppTypeForDartTypeMap.containsKey(type.baseName)) {
    return cppTypeForDartTypeMap[type.baseName];
  } else if (type.baseName == 'List') {
    if (type.typeArguments.isEmpty) {
      return 'List<Object>';
    } else {
      return 'List<${_flattenTypeArguments(type.typeArguments)}>';
    }
  } else {
    return null;
  }
}

String _cppTypeForDartType(TypeDeclaration type) {
  return _cppTypeForBuiltinDartType(type) ?? type.baseName;
}

/// Generates the ".h" file for the AST represented by [root] to [sink] with the
/// provided [options].
void generateCppHeader(CppOptions options, Root root, StringSink sink) {
  final Indent indent = Indent(sink);
  if (options.copyrightHeader != null) {
    addLines(indent, options.copyrightHeader!, linePrefix: '// ');
  }
  indent.writeln('// $generatedCodeWarning');
  indent.writeln('// $seeAlsoWarning');
  indent.addln('');
  indent.writeln('#pragma once');
  indent.writeln('#include <flutter/encodable_value.h>');
  indent.writeln('#include <flutter/basic_message_channel.h>');
  indent.writeln('#include <flutter/binary_messenger.h>');
  indent.writeln('#include <flutter/standard_message_codec.h>');
  indent.writeln('#include <map>');
  indent.writeln('#include <string>');

  indent.addln('');

  if (options.namespace != null) {
    indent.writeln('namespace ${options.namespace} {');
  }

  indent.addln('');
  indent.writeln('/** Generated class from Pigeon. */');

  for (final Enum anEnum in root.enums) {
    indent.writeln('');
    indent.write('enum class ${anEnum.name} ');
    indent.scoped('{', '};', () {
      int index = 0;
      for (final String member in anEnum.members) {
        indent.writeln(
            '$member = $index${index == anEnum.members.length - 1 ? '' : ','}');
        index++;
      }
    });
  }

  for (final Class klass in root.classes) {
    indent.addln('');
    indent.writeln(
        '/** Generated class from Pigeon that represents data sent in messages. */');
    indent.write('class ${klass.name} ');
    indent.scoped('{', '};', () {
      indent.scoped('public:', '', () {
        for (final NamedType field in klass.fields) {
          final HostDatatype hostDatatype = getHostDatatype(field, root.classes,
              root.enums, (NamedType x) => _cppTypeForBuiltinDartType(x.type));
          indent.writeln('${hostDatatype.datatype} ${_makeGetter(field)}();');
          indent.writeln(
              'void ${_makeSetter(field)}(${hostDatatype.datatype} setterArg);');
          indent.addln('');
        }
        indent.write('flutter::EncodableMap ToEncodableMap(); ');

        indent.addln('');
        indent.write('${klass.name}(); ');
        indent.addln('');
        indent.write('${klass.name}(flutter::EncodableMap map); ');
      });

      indent.scoped('private:', '', () {
        for (final NamedType field in klass.fields) {
          final HostDatatype hostDatatype = getHostDatatype(field, root.classes,
              root.enums, (NamedType x) => _cppTypeForBuiltinDartType(x.type));
          indent.writeln('${hostDatatype.datatype} ${field.name};');
        }
      });
    });
  }

  for (final Api api in root.apis) {
    _writeCodecHeader(indent, api, root);
    indent.addln('');
    if (api.location == ApiLocation.host) {
      _writeHostApiHeader(indent, api);
    } else if (api.location == ApiLocation.flutter) {
      _writeFlutterApiHeader(indent, api);
    }
  }

  if (options.namespace != null) {
    indent.writeln('} // namespace');
  }
}

/// Generates the ".cpp" file for the AST represented by [root] to [sink] with the
/// provided [options].
void generateCppSource(CppOptions options, Root root, StringSink sink) {
  final Set<String> rootClassNameSet =
      root.classes.map((Class x) => x.name).toSet();
  final Set<String> rootEnumNameSet =
      root.enums.map((Enum x) => x.name).toSet();
  final Indent indent = Indent(sink);
  if (options.copyrightHeader != null) {
    addLines(indent, options.copyrightHeader!, linePrefix: '// ');
  }
  indent.writeln('// $generatedCodeWarning');
  indent.writeln('// $seeAlsoWarning');
  indent.addln('');
  indent.addln('#undef _HAS_EXCEPTIONS');
  indent.addln('');
  indent.writeln('#include <flutter/basic_message_channel.h>');
  indent.writeln('#include <flutter/binary_messenger.h>');
  indent.writeln('#include <flutter/standard_message_codec.h>');
  indent.writeln('#include <map>');
  indent.writeln('#include <string>');

  indent.writeln('#include "${options.header}"');

  indent.addln('');

  indent.addln('');

  if (options.namespace != null) {
    indent.writeln('namespace ${options.namespace} {');
  }

  indent.addln('');
  indent.writeln('/** Generated class from Pigeon. */');

  for (final Class klass in root.classes) {
    indent.addln('');
    indent.scoped('' /* ${klass.name} */ '', '', () {
      for (final NamedType field in klass.fields) {
        final HostDatatype hostDatatype = getHostDatatype(field, root.classes,
            root.enums, (NamedType x) => _cppTypeForBuiltinDartType(x.type));
        indent.writeln(
            '${hostDatatype.datatype} ${klass.name}::${_makeGetter(field)}() { return ${field.name}; }');
        indent.writeln(
            'void ${klass.name}::${_makeSetter(field)}(${hostDatatype.datatype} setterArg) { this->${field.name} = setterArg; }');
        indent.addln('');
      }
      indent.write('flutter::EncodableMap ${klass.name}::ToEncodableMap() ');
      indent.scoped('{', '}', () {
        indent.writeln('flutter::EncodableMap toMapResult;');
        for (final NamedType field in klass.fields) {
          final HostDatatype hostDatatype = getHostDatatype(field, root.classes,
              root.enums, (NamedType x) => _cppTypeForBuiltinDartType(x.type));
          String toWriteValue = '';
          if (!hostDatatype.isBuiltin &&
              rootClassNameSet.contains(field.type.baseName)) {
            final String fieldName = field.name;
            toWriteValue = '$fieldName.ToEncodableMap()';
          } else if (!hostDatatype.isBuiltin &&
              rootEnumNameSet.contains(field.type.baseName)) {
            toWriteValue = 'flutter::EncodableValue((int)${field.name})';
          } else {
            toWriteValue = 'flutter::EncodableValue(${field.name})';
          }
          indent.writeln(
              'toMapResult.insert(std::make_pair(flutter::EncodableValue("${field.name}"), $toWriteValue));');
        }
        indent.writeln('return toMapResult;');
      });
      indent.writeln('${klass.name}::${klass.name}() {}');
      indent.write('${klass.name}::${klass.name}(flutter::EncodableMap map) ');
      indent.scoped('{', '}', () {
        for (final NamedType field in klass.fields) {
          indent.writeln(
              'auto encodable${field.name} = map.at(flutter::EncodableValue("${field.name}"));');
          if (rootEnumNameSet.contains(field.type.baseName)) {
            indent.writeln(
                'if(const int32_t* pval${field.name} = std::get_if<int32_t>(&encodable${field.name}))\t${field.name} = (${field.type.baseName})*pval${field.name};');
          } else {
            final HostDatatype hostDatatype = getHostDatatype(
                field,
                root.classes,
                root.enums,
                (NamedType x) => _cppTypeForBuiltinDartType(x.type));
            if (field.type.baseName == 'int') {
              indent.format('''
if(const int32_t* pval${field.name} = std::get_if<int32_t>(&encodable${field.name}))
\t${field.name} = *pval${field.name};
else if(const int64_t* pval2${field.name} = std::get_if<int64_t>(&encodable${field.name}))
\t${field.name} = *pval2${field.name};''');
            } else if (!hostDatatype.isBuiltin &&
                root.classes
                    .map((Class x) => x.name)
                    .contains(field.type.baseName)) {
              indent.writeln(
                  'if(const flutter::EncodableMap* pval${field.name} = std::get_if<flutter::EncodableMap>(&encodable${field.name})) ${field.name} = ${hostDatatype.datatype}(*pval${field.name});');
            } else {
              indent.writeln(
                  'if(const ${hostDatatype.datatype}* pval${field.name} = std::get_if<${hostDatatype.datatype}>(&encodable${field.name})) ${field.name} = *pval${field.name};');
            }
          }
        }
      });
    });
  }

  for (final Api api in root.apis) {
    _writeCodecSource(indent, api, root);
    indent.addln('');
    if (api.location == ApiLocation.host) {
      _writeHostApiSource(indent, api);

      indent.format('''
flutter::EncodableMap ${api.name}::WrapError(std::exception exception) {
\treturn flutter::EncodableMap({
\t\t{flutter::EncodableValue("${Keys.errorMessage}"), flutter::EncodableValue(exception.what())},
\t\t{flutter::EncodableValue("${Keys.errorCode}"), flutter::EncodableValue("Error")},
\t\t{flutter::EncodableValue("${Keys.errorDetails}"), flutter::EncodableValue()}
\t});
}''');
    } else if (api.location == ApiLocation.flutter) {
      _writeFlutterApiSource(indent, api);
    }
  }

  if (options.namespace != null) {
    indent.writeln('} // namespace');
  }
}
